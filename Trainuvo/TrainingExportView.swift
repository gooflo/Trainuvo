import SwiftUI
import SwiftData
import UIKit

struct TrainingExportView: View {
    var exercise: Exercise? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @Query private var entries: [TrainingEntry]
    @Query private var notes: [TrainingDayNote]
    private enum PeriodMode { case month, range }
    @State private var mode: PeriodMode = .month
    @State private var month = Calendar.current.component(.month, from: Date())
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var from = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
    @State private var to = Date()
    private struct ExportFile: Identifiable { let id = UUID(); let url: URL }
    @State private var exportFile: ExportFile?
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
    private var selected: [TrainingEntry] {
        TrainingExport.selected(entries.filter { exercise == nil || $0.exercise?.id == exercise?.id }, from: start, to: end, calendar: calendar)
    }
    private var selectedNotes: [TrainingDayNote] {
        exercise == nil ? TrainingExport.selectedNotes(notes, from: start, to: end, calendar: calendar) : []
    }
    private var preview: String { TrainingExport.text(selected, notes: selectedNotes, calendar: calendar) }
    private var canExport: Bool { start <= end && (!selected.isEmpty || !selectedNotes.isEmpty) }

    var body: some View {
        NavigationStack {
            Form {
                if let exercise { Section { LabeledContent("Übung", value: exercise.name) } }
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
                        message = "Text in die Zwischenablage kopiert"
                    }
                    Button("Textdatei", systemImage: "doc.text") { export("txt") }
                    Button("Excel", systemImage: "tablecells") { export("xlsx") }
                    Button("CSV (Krafttraining)", systemImage: "tablecells") { export("csv") }
                        .disabled(!selected.contains { $0.activityType == .strength })
                    Button("JSON", systemImage: "curlybraces") { export("json") }
                } header: {
                    Text("Export")
                }
                .disabled(!canExport)
                Section("Vorschau · \(selected.count) Trainings") {
                    if selected.isEmpty && selectedNotes.isEmpty {
                        Text("Keine Trainings im gewählten Zeitraum.").foregroundStyle(.secondary)
                    } else {
                        Text(preview).font(.callout).textSelection(.enabled)
                    }
                }

            }
            .navigationTitle("Export")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Fertig") { dismiss() } } }
            .sheet(item: $exportFile) { file in
                TrainingExportFileNameView(sourceURL: file.url)
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
                url = try TrainingExportExcel.create(entries: selected, notes: selectedNotes, from: start, to: end)
            } else {
                url = try TrainingExport.fileURL(from: start, to: end, extension: suffix)
                let data: Data
                if suffix == "csv" { data = Data(("\u{FEFF}" + (try TrainingCSVExport.text(selected, calendar: calendar))).utf8) }
                else if suffix == "json" { data = try TrainingExport.json(selected, notes: selectedNotes, from: start, to: end) }
                else { data = Data(preview.utf8) }
                try data.write(to: url, options: .atomic)
            }
            exportFile = ExportFile(url: url)
        } catch { message = error.localizedDescription }
    }
}
