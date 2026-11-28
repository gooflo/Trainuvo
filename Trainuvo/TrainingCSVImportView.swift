import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TrainingCSVImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    @State private var choosingFile = false
    @State private var document: TrainingCSV.Document?
    @State private var preview: [TrainingCSVImport.PreviewRow] = []
    @State private var selected: Set<Int> = []
    @State private var fileName = ""
    @State private var errorMessage: String?
    @State private var showingConfirmation = false
    @State private var summary: String?

    private var canImport: Bool {
        document?.issues.isEmpty == true && !selected.isEmpty && exercise.activityType == .strength
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Übung", value: exercise.name)
                    Text("Eine Zeile wird ein Training mit einer Arbeitsgruppe. Vorhandene Trainings, Ziele und Vorlagen bleiben erhalten.")
                    Button("CSV-Datei auswählen", systemImage: "doc.badge.plus") { choosingFile = true }
                        .disabled(summary != nil)
                    if !fileName.isEmpty { Text(fileName).font(.caption).foregroundStyle(.secondary) }
                }
                if let summary {
                    Section("Import abgeschlossen") {
                        Text(summary)
                        Button("Fertig") { dismiss() }
                    }
                } else {
                    Section("CSV-Format") {
                        Text("Datum;Sätze;Gewicht;Bewertung\n18.11.2026;3x5;90;o\n13.11.2026;3x5;87,5;+")
                            .font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                        Text("Semikolon als Trennzeichen, Datum TT.MM.JJJJ, Gewicht ohne kg, Dezimalkomma oder -punkt. Bewertung leer oder --, -, o, +, ++. Textkodierung UTF-8 oder UTF-16 mit BOM. Maximal 2 MB und 10.000 Trainings. Nur Krafttraining; eine Arbeitsgruppe pro Zeile.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    if let document {
                        if !document.issues.isEmpty {
                            Section("Dateifehler – Import gesperrt") {
                                Text("Korrigiere die Datei und wähle sie erneut aus. Es wurde nichts gespeichert.")
                                ForEach(document.issues) { issue in
                                    Text("Zeile \(issue.line): \(issue.message)").foregroundStyle(.red)
                                }
                            }
                        }
                        Section {
                            ForEach(preview) { item in previewRow(item) }
                        } header: {
                            Text("Vorschau: \(selected.count) ausgewählt, \(preview.filter { $0.status == .duplicate }.count) identisch")
                        } footer: {
                            Text("Identische Arbeitsgruppen am selben Tag einschließlich Bewertung werden übersprungen, auch innerhalb der Datei. Abweichende Trainings am selben Tag sind zunächst abgewählt. Wähle sie nur aus, wenn du ein zusätzliches Training anlegen möchtest. Es wird nichts überschrieben.")
                        }
                    }
                }
            }
            .navigationTitle("Trainings importieren")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(summary == nil ? "Abbrechen / Cancel" : "Schließen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if summary == nil {
                        Button("Importieren") { showingConfirmation = true }.disabled(!canImport)
                    }
                }
            }
            .fileImporter(isPresented: $choosingFile, allowedContentTypes: [.commaSeparatedText, .plainText]) { result in
                load(result)
            }
            .alert("Trainings importieren?", isPresented: $showingConfirmation) {
                Button("Abbrechen / Cancel", role: .cancel) {}
                Button("Importieren") { save() }
            } message: {
                Text("\(selected.count) ausgewählte Trainings für „\(exercise.name)“ hinzufügen? Vorhandene Daten werden nicht überschrieben.")
            }
            .alert("Import nicht möglich", isPresented: Binding(
                get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
        }
    }

    @ViewBuilder private func previewRow(_ item: TrainingCSVImport.PreviewRow) -> some View {
        let row = item.row
        if item.status == .duplicate {
            rowLabel(item).foregroundStyle(.secondary)
        } else {
            Toggle(isOn: Binding(
                get: { selected.contains(row.id) },
                set: { value in
                    if value { selected.insert(row.id) } else { selected.remove(row.id) }
                }
            )) { rowLabel(item) }
        }
    }

    private func rowLabel(_ item: TrainingCSVImport.PreviewRow) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.row.date, format: .dateTime.day(.twoDigits).month(.twoDigits).year())
                .font(.headline)
            Text("\(item.row.prescription) @ \(TrainingFormat.weight(item.row.weight)) · \(item.row.effortSymbol ?? "ohne Bewertung")")
            Text("Zeile \(item.row.line): \(item.status.title)")
                .font(.caption).foregroundStyle(item.status == .conflict ? Color.orange : Color.secondary)
        }
    }

    private func load(_ result: Result<URL, Error>) {
        document = nil; preview = []; selected = []; fileName = ""
        do {
            let url = try result.get()
            let access = url.startAccessingSecurityScopedResource()
            defer { if access { url.stopAccessingSecurityScopedResource() } }
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size <= TrainingCSV.maximumBytes else {
                throw TrainingCSV.CSVError.message("Die Datei ist zu groß. Erlaubt sind höchstens 2 MB.")
            }
            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }
            let data = try handle.read(upToCount: TrainingCSV.maximumBytes + 1) ?? Data()
            let parsed = try TrainingCSV.parse(TrainingCSV.decode(data))
            let checkContext = ModelContext(modelContext.container)
            let exerciseID = exercise.id
            let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.id == exerciseID })
            guard let current = try checkContext.fetch(descriptor).first, current.activityType == .strength else {
                throw TrainingCSV.CSVError.message("Die Kraftübung ist nicht mehr verfügbar.")
            }
            preview = TrainingCSVImport.preview(parsed.rows, entries: current.trainingEntries)
            selected = Set(preview.filter { $0.status == .new }.map(\.id))
            document = parsed
            fileName = url.lastPathComponent
        } catch {
            if (error as NSError).code != NSUserCancelledError { errorMessage = error.localizedDescription }
        }
    }

    private func save() {
        guard let document, canImport else { return }
        do {
            let approved = Set(preview.filter { $0.status == .conflict && selected.contains($0.id) }.map(\.id))
            let result = try TrainingCSVImport.save(document, selected: selected, approvedConflicts: approved,
                                                    exerciseID: exercise.id, container: modelContext.container)
            summary = "\(result.imported) Trainings importiert. \(result.duplicates) identische Einträge übersprungen. \(result.omitted) Einträge nicht ausgewählt."
            selected = []
        } catch { errorMessage = error.localizedDescription }
    }
}
