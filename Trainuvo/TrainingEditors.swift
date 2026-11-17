import SwiftUI
import SwiftData

struct ExerciseEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]
    let exercise: Exercise?
    @State private var name: String
    @State private var target: String
    @FocusState private var inputFocused: Bool
    @State private var errorMessage: String?

    init(exercise: Exercise? = nil) {
        self.exercise = exercise
        _name = State(initialValue: exercise?.name ?? "")
        _target = State(initialValue: exercise.flatMap { $0.targetWeight }.map { TrainingFormat.number($0) } ?? "")
    }

    private var cleanName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanTarget: String { target.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var validation: String? {
        if cleanName.isEmpty { return "Gib einen Übungsnamen ein." }
        if exercises.contains(where: {
            $0.id != exercise?.id && $0.name.compare(cleanName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }) { return "Eine Übung mit diesem Namen ist bereits vorhanden." }
        if !cleanTarget.isEmpty {
            guard let value = TrainingFormat.parseWeight(cleanTarget), value >= 0.01 else {
                return "Das Zielgewicht muss zwischen 0,01 und 100.000 kg liegen."
            }
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Übung") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.sentences)
                        .focused($inputFocused)
                }
                Section {
                    HStack {
                        TextField("Zielgewicht (optional)", text: $target)
                            .keyboardType(.decimalPad)
                            .focused($inputFocused)
                        Text("kg").foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("Das Arbeitsgewicht des letzten Trainings wird mit diesem Ziel verglichen.")
                }
                if let validation {
                    Section { Text(validation).foregroundStyle(.secondary) }
                }
            }
            .navigationTitle(exercise == nil ? "Neue Übung" : "Übung bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }.disabled(validation != nil)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fertig") { inputFocused = false }
                }
            }
            .alert("Speichern fehlgeschlagen", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func save() {
        guard validation == nil else { return }
        let targetWeight = TrainingFormat.parseWeight(cleanTarget)
        if let exercise {
            exercise.name = cleanName
            exercise.targetWeight = targetWeight
        } else {
            modelContext.insert(Exercise(name: cleanName, targetWeight: targetWeight))
        }
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}

private struct SetGroupDraft: Identifiable {
    let id: UUID
    var prescription: String
    var weight: String

    init(id: UUID = UUID(), prescription: String = "3 × 5", weight: String = "") {
        self.id = id
        self.prescription = prescription
        self.weight = weight
    }
}

struct TrainingEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    let entry: TrainingEntry?
    @State private var date: Date
    @State private var groups: [SetGroupDraft]
    @State private var workingID: UUID
    @State private var errorMessage: String?
    @FocusState private var inputFocused: Bool

    init(exercise: Exercise, entry: TrainingEntry? = nil) {
        self.exercise = exercise
        self.entry = entry
        _date = State(initialValue: entry?.date ?? Date())
        let source = entry ?? exercise.latestEntry
        let copied = source?.sortedGroups.map {
            SetGroupDraft(id: $0.id, prescription: $0.prescription, weight: TrainingFormat.number($0.weight))
        } ?? []
        let initial = copied.isEmpty ? [SetGroupDraft()] : copied
        _groups = State(initialValue: initial)
        _workingID = State(initialValue: source?.sortedGroups.first(where: \.isWorking)?.id ?? initial[0].id)
    }

    private var isValid: Bool {
        !groups.isEmpty && groups.contains(where: { $0.id == workingID }) &&
        groups.allSatisfy {
            !$0.prescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            TrainingFormat.parseWeight($0.weight) != nil
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(exercise.name).font(.headline)
                    DatePicker("Datum", selection: $date, in: ...Date(), displayedComponents: .date)
                }
                ForEach($groups) { $group in
                    Section {
                        HStack {
                            TextField("Sätze × Wiederholungen", text: $group.prescription)
                                .focused($inputFocused)
                            Menu {
                                ForEach(["3 × 5", "3 × 3", "5 × 3"], id: \.self) { preset in
                                    Button(preset) { group.prescription = preset }
                                }
                            } label: {
                                Label("Vorauswahl", systemImage: "list.bullet")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        HStack {
                            TextField("Gewicht", text: $group.weight)
                                .keyboardType(.decimalPad)
                                .focused($inputFocused)
                            Text("kg").foregroundStyle(.secondary)
                        }
                        Button {
                            workingID = group.id
                        } label: {
                            Label(
                                workingID == group.id ? "Arbeitsgewicht" : "Als Arbeitsgewicht wählen",
                                systemImage: workingID == group.id ? "checkmark.circle.fill" : "circle"
                            )
                        }
                        if groups.count > 1 {
                            Button("Satzgruppe entfernen", role: .destructive) { removeGroup(group.id) }
                        }
                    } header: {
                        Text("Satzgruppe \((groups.firstIndex(where: { $0.id == group.id }) ?? 0) + 1)")
                    }
                }
                Section {
                    Button("Satzgruppe hinzufügen", systemImage: "plus.circle") {
                        groups.append(SetGroupDraft(prescription: "1 × 5"))
                    }
                } footer: {
                    Text("Eine Satzgruppe als Arbeitsgewicht markieren. Diese bestimmt den Zielfortschritt. Sätze frei eingeben, zum Beispiel 1 × 5 oder 5/5/4. Gewichte ab 0 kg sind möglich.")
                }
            }
            .navigationTitle(entry == nil ? "Training erfassen" : "Training bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }.disabled(!isValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fertig") { inputFocused = false }
                }
            }
            .alert("Speichern fehlgeschlagen", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func removeGroup(_ id: UUID) {
        groups.removeAll { $0.id == id }
        if workingID == id, let first = groups.first { workingID = first.id }
    }

    private func save() {
        guard isValid else { return }
        let training: TrainingEntry
        if let entry {
            training = entry
            for group in entry.groups { modelContext.delete(group) }
            training.groups = []
            training.date = date
        } else {
            training = TrainingEntry(date: date, exercise: exercise)
            modelContext.insert(training)
        }
        for (position, draft) in groups.enumerated() {
            guard let weight = TrainingFormat.parseWeight(draft.weight) else { continue }
            let group = SetGroup(
                position: position,
                prescription: draft.prescription.trimmingCharacters(in: .whitespacesAndNewlines),
                weight: weight,
                isWorking: draft.id == workingID
            )
            modelContext.insert(group)
            training.groups.append(group)
        }
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}
