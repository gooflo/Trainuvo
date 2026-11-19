import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import UIKit

struct TrainingExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @Query private var entries: [TrainingEntry]
    private enum PeriodMode { case month, range }
    @State private var mode: PeriodMode = .month
    @State private var month = Calendar.current.component(.month, from: Date())
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var from = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
    @State private var to = Date()
    @State private var document: TrainingExportDocument?
    @State private var fileType: UTType = .json
    @State private var filename = ""
    @State private var showingExporter = false
    @State private var message: String?
    private let calendar = Calendar.current

    private var start: Date {
        mode == .month ? calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? from : calendar.startOfDay(for: from)
    }
    private var end: Date {
        if mode == .range { return calendar.startOfDay(for: to) }
        return calendar.date(byAdding: .day, value: -1,
                             to: calendar.date(byAdding: .month, value: 1, to: start) ?? start) ?? start
    }
    private var selected: [TrainingEntry] { TrainingExport.selected(entries, from: start, to: end, calendar: calendar) }
    private var preview: String { TrainingExport.text(selected, calendar: calendar) }
    private var canExport: Bool { start <= end && !selected.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Zeitraum") {
                    Picker("Zeitraum", selection: $mode) {
                        Text("Monat").tag(PeriodMode.month)
                        Text("Von–Bis").tag(PeriodMode.range)
                    }.pickerStyle(.segmented)
                    if mode == .month {
                        Picker("Monat", selection: $month) {
                            ForEach(1...12, id: \.self) { value in
                                Text(monthName(value)).tag(value)
                            }
                        }
                        Picker("Jahr", selection: $year) {
                            ForEach((1900...2100).reversed(), id: \.self) { value in
                                Text(verbatim: String(value)).tag(value)
                            }
                        }
                    } else {
                        DatePicker("Von", selection: $from, displayedComponents: .date)
                        DatePicker("Bis", selection: $to, displayedComponents: .date)
                    }
                    if start > end {
                        Text("Das Bis-Datum muss am oder nach dem Von-Datum liegen.").foregroundStyle(.red)
                    }
                }
                Section {
                    Button("Text kopieren", systemImage: "doc.on.doc") {
                        UIPasteboard.general.string = preview
                        message = "Text für OneNote kopiert."
                    }
                    Button("Textdatei", systemImage: "doc.text") { export("txt") }
                    Button("Excel", systemImage: "tablecells") { export("xlsx") }
                    Button("JSON", systemImage: "curlybraces") { export("json") }
                } header: {
                    Text("Export")
                } footer: {
                    Text("Neueste Tage zuerst, Übungen in deiner Reihenfolge. Text: ein Absatz je Tag mit Arbeitsgruppen bzw. freien Einheiten. Excel und JSON: alle Gruppen einschließlich Aufwärmsätzen.")
                }
                .disabled(!canExport)
                Section("Vorschau · \(selected.count) Trainings") {
                    if selected.isEmpty {
                        Text("Keine Trainings im gewählten Zeitraum.").foregroundStyle(.secondary)
                    } else {
                        Text(preview).font(.callout).textSelection(.enabled)
                    }
                }

            }
            .navigationTitle("Export")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Fertig") { dismiss() } } }
            .fileExporter(isPresented: $showingExporter, document: document, contentType: fileType, defaultFilename: filename) { result in
                if case .failure(let error) = result { message = error.localizedDescription }
            }
            .alert("Export", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
                Button("OK") { message = nil }
            } message: { Text(message ?? "") }
        }
    }

    private func monthName(_ value: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        return formatter.monthSymbols[value - 1]
    }

    private func export(_ suffix: String) {
        guard canExport else { return }
        do {
            let url: URL
            if suffix == "xlsx" {
                url = try TrainingExportExcel.create(entries: selected, from: start, to: end)
            } else {
                url = try TrainingExport.fileURL(from: start, to: end, extension: suffix)
                let data = suffix == "json" ? try TrainingExport.json(selected, from: start, to: end) : Data(preview.utf8)
                try data.write(to: url, options: .atomic)
            }
            document = TrainingExportDocument(data: try Data(contentsOf: url))
            filename = url.deletingPathExtension().lastPathComponent
            fileType = UTType(filenameExtension: suffix) ?? .data
            showingExporter = true
        } catch { message = error.localizedDescription }
    }
}

struct TrainingExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json, .plainText, UTType(filenameExtension: "xlsx") ?? .data] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        self.data = data
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
