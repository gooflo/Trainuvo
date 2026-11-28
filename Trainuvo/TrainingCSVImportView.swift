import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TrainingCSVImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var exercise: Exercise? = nil
    @State private var choosingFile = false
    @State private var document: TrainingCSV.Document?
    @State private var preview: [TrainingCSVImport.PreviewRow] = []
    @State private var destinations: [String: TrainingCSVImport.Destination] = [:]
    @State private var options: [ExerciseOption] = []
    @State private var selected: Set<Int> = []
    @State private var fileName = ""
    @State private var allowNameMismatch = false
    @State private var errorMessage: String?
    @State private var showingConfirmation = false
    @State private var summary: String?

    private struct ExerciseOption: Identifiable { let id: UUID; let name: String; let label: String }
    private var sourceNames: [String] { Array(Set(document?.trainings.map { $0.exerciseName ?? "" } ?? [])).sorted() }
    private var multipleNamesInSingleImport: Bool { exercise != nil && sourceNames.count > 1 }
    private var nameMismatch: Bool {
        guard let exercise else { return false }
        return sourceNames.contains { !$0.isEmpty && TrainingCSVImport.nameKey($0) != TrainingCSVImport.nameKey(exercise.name) }
    }
    private var canImport: Bool {
        document?.issues.isEmpty == true && !selected.isEmpty && !multipleNamesInSingleImport && (!nameMismatch || allowNameMismatch)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let exercise { LabeledContent("Zielübung", value: exercise.name) }
                    else { Text("Kraftübungen aus einer gemeinsamen CSV importieren.") }
                    Button("CSV-Datei auswählen", systemImage: "doc.badge.plus") { choosingFile = true }.disabled(summary != nil)
                    if !fileName.isEmpty { Text(fileName).font(.caption).foregroundStyle(.secondary) }
                    Text("Vorhandene Trainings, Ziele und Vorlagen werden nicht überschrieben.").font(.caption)
                }
                if let summary {
                    Section("Import abgeschlossen") { Text(summary); Button("Fertig") { dismiss() } }
                } else {
                    Section("CSV-Format") {
                        Text(TrainingCSV.header).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                        Text("Eine Zeile je Satzgruppe, gleiche Training-ID für zusammengehörige Gruppen. Nummerierung ab 1, genau eine Arbeitsgruppe mit ja; alle anderen nein. Name, Datum und Bewertung müssen je Training gleich sein. Aufwärmsätze einschließlich 0 kg bleiben erhalten.")
                        Text("Datum TT.MM.JJJJ, Gewicht ohne kg mit Komma oder Punkt, Bewertung leer oder --, -, o, +, ++. UTF-8/UTF-16 mit BOM, maximal 2 MB und 10.000 Satzgruppen. Das bisherige Vier-Spalten-Format bleibt erlaubt; dort ist jede Zeile eine Arbeitsgruppe.").font(.caption).foregroundStyle(.secondary)
                    }
                    if let document {
                        mappingSection
                        if !document.issues.isEmpty {
                            Section("Dateifehler – Import gesperrt") {
                                Text("Datei korrigieren und erneut auswählen. Es wurde nichts gespeichert.")
                                ForEach(document.issues) { Text("Zeile \($0.line): \($0.message)").foregroundStyle(.red) }
                            }
                        }
                        Section {
                            ForEach(preview) { item in
                                if item.status == .duplicate || item.status == .unassigned { rowLabel(item).foregroundStyle(.secondary) }
                                else {
                                    Toggle(isOn: Binding(get: { selected.contains(item.id) }, set: { value in
                                        if value { selected.insert(item.id) } else { selected.remove(item.id) }
                                    })) { rowLabel(item) }
                                }
                            }
                        } header: { Text("Vorschau: \(selected.count) ausgewählt, \(preview.filter { $0.status == .duplicate }.count) identisch") } footer: { Text("Abweichende oder weitere Trainings am selben Tag sind zunächst abgewählt. Nur ausdrücklich ausgewählte Trainings werden zusätzlich angelegt. Bei gleicher ID und geändertem Inhalt wird niemals überschrieben. Die Prüfung berücksichtigt alle Satzgruppen, Reihenfolge, Arbeitsgruppe und Bewertung.") }
                        Button("Vorschau aktualisieren", systemImage: "arrow.clockwise") { refresh() }
                    }
                }
            }
            .navigationTitle("Trainings importieren")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(summary == nil ? "Abbrechen / Cancel" : "Schließen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    if summary == nil { Button("Importieren") { showingConfirmation = true }.disabled(!canImport) }
                }
            }
            .fileImporter(isPresented: $choosingFile, allowedContentTypes: [.commaSeparatedText, .plainText]) { load($0) }
            .alert("Trainings importieren?", isPresented: $showingConfirmation) {
                Button("Abbrechen / Cancel", role: .cancel) {}
                Button("Importieren") { save() }
            } message: {
                Text("\(selected.count) ausgewählte Trainings mit allen Satzgruppen hinzufügen? Ausdrücklich ausgewählte neue Übungen werden dabei angelegt. Vorhandene Daten werden nicht überschrieben.")
            }
            .alert("Import nicht möglich", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
        }
    }

    @ViewBuilder private var mappingSection: some View {
        Section("Übungszuordnung") {
            if let exercise {
                if multipleNamesInSingleImport { Text("Die Datei enthält mehrere Übungen. Bitte den Gesamtimport in Einstellungen verwenden.").foregroundStyle(.red) }
                else {
                    Text("Alle Trainings werden „\(exercise.name)“ zugeordnet.")
                    if nameMismatch {
                        Text("Übungsname in der Datei: \(sourceNames.joined(separator: ", "))").foregroundStyle(.orange)
                        Toggle("Abweichenden Namen bestätigen und dieser Übung zuordnen", isOn: $allowNameMismatch)
                    }
                }
            } else {
                ForEach(sourceNames, id: \.self) { name in
                    Picker(name.isEmpty ? "Ohne Übungsname (altes Format)" : name, selection: Binding(
                        get: { destinations[name] ?? .unassigned },
                        set: { destinations[name] = $0; refresh() }
                    )) {
                        Text("Bitte zuordnen").tag(TrainingCSVImport.Destination.unassigned)
                        ForEach(options) { option in
                            Text(option.label).tag(TrainingCSVImport.Destination.existing(option.id))
                        }
                        if !name.isEmpty && !options.contains(where: { TrainingCSVImport.nameKey($0.name) == TrainingCSVImport.nameKey(name) }) {
                            Text("Neue Kraftübung „\(name)“ anlegen").tag(TrainingCSVImport.Destination.create(name))
                        }
                    }
                }
                Text("Neue Übungen werden nur bei entsprechender Auswahl und bestätigtem Import angelegt, ohne Ziel und Standardsätze.").font(.caption)
            }
        }
    }

    private func rowLabel(_ item: TrainingCSVImport.PreviewRow) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.training.date, format: .dateTime.day(.twoDigits).month(.twoDigits).year()).font(.headline)
            if let name = item.training.exerciseName { Text(name).font(.subheadline) }
            ForEach(Array(item.training.groups.enumerated()), id: \.offset) { index, group in
                Text("\(index + 1). \(group.isWorking ? "◎ " : "")\(group.prescription) @ \(TrainingFormat.weight(group.weight))")
            }
            Text("Bewertung: \(item.training.effortSymbol ?? "ohne Bewertung")").font(.caption)
            Text("Zeile \(item.id): \(item.status.title)").font(.caption)
                .foregroundStyle(item.status == .conflict ? Color.orange : Color.secondary)
        }
    }

    private func load(_ result: Result<URL, Error>) {
        document = nil; preview = []; destinations = [:]; selected = []; fileName = ""; allowNameMismatch = false
        do {
            let url = try result.get()
            let access = url.startAccessingSecurityScopedResource()
            defer { if access { url.stopAccessingSecurityScopedResource() } }
            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }
            let data = try handle.read(upToCount: TrainingCSV.maximumBytes + 1) ?? Data()
            document = try TrainingCSV.parse(TrainingCSV.decode(data))
            fileName = url.lastPathComponent
            refresh(initial: true)
        } catch { if (error as NSError).code != NSUserCancelledError { errorMessage = error.localizedDescription } }
    }

    private func refresh(initial: Bool = false) {
        guard let document else { return }
        do {
            let context = ModelContext(modelContext.container)
            let exercises = try context.fetch(FetchDescriptor<Exercise>())
            let sorted = exercises.filter { $0.activityType == .strength }.sorted {
                $0.name == $1.name ? $0.id.uuidString < $1.id.uuidString : $0.name < $1.name
            }
            options = sorted.enumerated().map { index, value in
                let duplicated = sorted.filter { $0.name == value.name }.count > 1
                let label = duplicated ? "\(value.name) (\(index + 1))" : value.name
                return ExerciseOption(id: value.id, name: value.name, label: label)
            }
            if initial { destinations = TrainingCSVImport.initialDestinations(document, exercises: exercises, fixedExerciseID: exercise?.id) }
            preview = TrainingCSVImport.preview(document, destinations: destinations, exercises: exercises)
            selected = Set(preview.filter { $0.status == .new }.map(\.id))
        } catch { errorMessage = error.localizedDescription }
    }

    private func save() {
        guard let document, canImport else { return }
        do {
            let approved = Set(preview.filter { $0.status == .conflict && selected.contains($0.id) }.map(\.id))
            let result = try TrainingCSVImport.save(document, selected: selected, approvedConflicts: approved,
                destinations: destinations, fixedExerciseID: exercise?.id, allowNameMismatch: allowNameMismatch,
                container: modelContext.container)
            summary = "\(result.imported) Trainings importiert, \(result.exercisesCreated) Übungen angelegt. \(result.duplicates) identisch, \(result.omitted) nicht ausgewählt."
            selected = []
        } catch { errorMessage = error.localizedDescription }
    }
}
