import SwiftUI
import SwiftData

struct ExerciseEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]
    let exercise: Exercise?
    @State private var name: String
    @State private var templates: [SetGroupDraft]
    @State private var workingTemplateID: UUID?
    @State private var target: String
    @FocusState private var inputFocused: Bool
    @State private var errorMessage: String?

    init(exercise: Exercise? = nil) {
        self.exercise = exercise
        let initial: [SetGroupDraft]
        if let exercise {
            initial = exercise.sortedSetTemplates.map {
                SetGroupDraft(id: $0.id, prescription: $0.prescription)
            }
        } else {
            initial = [SetGroupDraft()]
        }
        _templates = State(initialValue: initial)
        _workingTemplateID = State(initialValue: exercise?.sortedSetTemplates.first(where: \.isWorking)?.id ?? initial.first?.id)
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
        if templates.contains(where: { $0.prescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            return "Fülle die Standardsätze aus oder entferne die leere Gruppe."
        }
        if !templates.isEmpty && !templates.contains(where: { $0.id == workingTemplateID }) {
            return "Markiere eine Standardgruppe als Arbeitsgewicht."
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
                Section {
                    ForEach($templates) { $template in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                TextField("Sätze × Wiederholungen", text: $template.prescription)
                                    .focused($inputFocused)
                                Menu {
                                    ForEach(TrainingFormat.prescriptions, id: \.self) { preset in
                                        Button(preset) { template.prescription = preset }
                                    }
                                } label: {
                                    Label("Vorauswahl", systemImage: "list.bullet")
                                        .labelStyle(.iconOnly)
                                }
                            }
                            HStack(spacing: 16) {
                                Button {
                                    workingTemplateID = template.id
                                } label: {
                                    Label(
                                        workingTemplateID == template.id ? "Arbeitsgewicht" : "Arbeitsgewicht wählen",
                                        systemImage: workingTemplateID == template.id ? "checkmark.circle.fill" : "circle"
                                    )
                                }
                                .font(.caption)
                                Spacer(minLength: 0)
                                Button { moveTemplate(template.id, by: -1) } label: {
                                    Image(systemName: "arrow.up")
                                }
                                .accessibilityLabel("Satzgruppe nach oben")
                                .disabled(templates.first?.id == template.id)
                                Button { moveTemplate(template.id, by: 1) } label: {
                                    Image(systemName: "arrow.down")
                                }
                                .accessibilityLabel("Satzgruppe nach unten")
                                .disabled(templates.last?.id == template.id)
                                Button(role: .destructive) { removeTemplate(template.id) } label: {
                                    Image(systemName: "trash")
                                }
                                .accessibilityLabel("Standardgruppe entfernen")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 4)
                    }
                    Button("Standardgruppe hinzufügen", systemImage: "plus.circle") {
                        let group = SetGroupDraft(prescription: "1 × 5")
                        templates.append(group)
                        if workingTemplateID == nil { workingTemplateID = group.id }
                    }
                } header: {
                    Text("Standardsätze in Trainingsreihenfolge")
                } footer: {
                    Text("Neue Trainings übernehmen diese Gruppen und die Arbeitsgewicht-Markierung. Du ergänzt die kg. Mit den Pfeilen änderst du die Reihenfolge. Ohne Standardsätze dient das letzte Training als Vorschlag.")
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

    private func moveTemplate(_ id: UUID, by offset: Int) {
        guard let index = templates.firstIndex(where: { $0.id == id }),
              templates.indices.contains(index + offset) else { return }
        templates.swapAt(index, index + offset)
    }

    private func removeTemplate(_ id: UUID) {
        templates.removeAll { $0.id == id }
        if workingTemplateID == id { workingTemplateID = templates.first?.id }
    }

    private func save() {
        guard validation == nil else { return }
        let targetWeight = TrainingFormat.parseWeight(cleanTarget)
        let savedExercise: Exercise
        if let exercise {
            savedExercise = exercise
            exercise.name = cleanName
            exercise.targetWeight = targetWeight
            for template in exercise.setTemplates { modelContext.delete(template) }
            exercise.setTemplates = []
        } else {
            savedExercise = Exercise(name: cleanName, targetWeight: targetWeight)
            savedExercise.sortOrder = (exercises.map(\.sortOrder).max() ?? -1) + 1
            modelContext.insert(savedExercise)
        }
        for (position, draft) in templates.enumerated() {
            let template = ExerciseSetTemplate(
                position: position,
                prescription: draft.prescription.trimmingCharacters(in: .whitespacesAndNewlines),
                isWorking: draft.id == workingTemplateID
            )
            modelContext.insert(template)
            savedExercise.setTemplates.append(template)
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
    @State private var effort: TrainingEffort?
    @State private var errorMessage: String?
    @State private var showingDeleteConfirmation = false
    private enum Field: Hashable {
        case prescription(UUID)
        case weight(UUID)
    }

    @FocusState private var focusedField: Field?

    init(exercise: Exercise, entry: TrainingEntry? = nil) {
        self.exercise = exercise
        self.entry = entry
        _effort = State(initialValue: entry?.effort)
        _date = State(initialValue: entry?.date ?? Date())
        let initial: [SetGroupDraft]
        let selectedWorkingID: UUID?
        if let entry {
            initial = entry.sortedGroups.map {
                SetGroupDraft(id: $0.id, prescription: $0.prescription, weight: TrainingFormat.number($0.weight))
            }
            selectedWorkingID = entry.sortedGroups.first(where: \.isWorking)?.id
        } else if !exercise.setTemplates.isEmpty {
            initial = exercise.sortedSetTemplates.map {
                SetGroupDraft(id: $0.id, prescription: $0.prescription)
            }
            selectedWorkingID = exercise.sortedSetTemplates.first(where: \.isWorking)?.id
        } else {
            initial = exercise.latestEntry?.sortedGroups.map {
                SetGroupDraft(id: $0.id, prescription: $0.prescription, weight: TrainingFormat.number($0.weight))
            } ?? []
            selectedWorkingID = exercise.latestEntry?.sortedGroups.first(where: \.isWorking)?.id
        }
        let drafts = initial.isEmpty ? [SetGroupDraft()] : initial
        _groups = State(initialValue: drafts)
        _workingID = State(initialValue: selectedWorkingID ?? drafts[0].id)
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
                    DatePicker("Datum", selection: $date, in: ...Date(), displayedComponents: .date)
                    .accessibilityLabel("Trainingsdatum für \(exercise.name)")
                }
                Section {
                    ForEach($groups) { $group in
                        HStack(spacing: 4) {
                            Button {
                                workingID = group.id
                            } label: {
                                Image(systemName: workingID == group.id ? "target" : "circle")
                                    .foregroundStyle(workingID == group.id ? Color.blue : Color.secondary)
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityLabel("Als Arbeitsgewicht wählen")
                            .accessibilityValue(workingID == group.id ? "Ausgewählt" : "Nicht ausgewählt")

                            TextField("Sätze", text: $group.prescription)
                                .focused($focusedField, equals: .prescription(group.id))
                                .accessibilityLabel("Sätze und Wiederholungen")
                                .frame(minWidth: 60)

                            Menu {
                                ForEach(TrainingFormat.prescriptions, id: \.self) { preset in
                                    Button(preset) { group.prescription = preset }
                                }
                                if groups.count > 1 {
                                    Divider()
                                    Button("Satzgruppe entfernen", systemImage: "trash", role: .destructive) {
                                        removeGroup(group.id)
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.down.circle")
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityLabel("Satzauswahl und Aktionen")

                            TextField("Gewicht", text: $group.weight)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .weight(group.id))
                                .multilineTextAlignment(.trailing)
                                .monospacedDigit()
                                .frame(minWidth: 60, idealWidth: 80, maxWidth: 100)
                                .accessibilityLabel("Gewicht in Kilogramm")
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 12))
                        .swipeActions {
                            if groups.count > 1 {
                                Button("Entfernen", role: .destructive) { removeGroup(group.id) }
                            }
                        }
                    }
                    Picker("Arbeitsgewicht war …", selection: $effort) {
                        Text("Nicht bewertet").tag(Optional<TrainingEffort>.none)
                        ForEach(TrainingEffort.allCases) { value in
                            Text(value.selectionTitle).tag(Optional(value))
                        }
                    }
                    .pickerStyle(.menu)
                    Button("Satzgruppe hinzufügen", systemImage: "plus.circle") {
                        groups.append(SetGroupDraft(prescription: "1 × 5"))
                    }
                } header: {
                    Text("Sätze und Gewichte")
                } footer: {
                    Text("Zielscheibe = Arbeitsgewicht. Satzauswahl und Entfernen über den Pfeil.")
                }
                if entry != nil {
                    Section {
                        Button("Dieses Training löschen", systemImage: "trash", role: .destructive) {
                            focusedField = nil
                            showingDeleteConfirmation = true
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                Text(exercise.name)
                    .font(.title2.bold())
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(.systemGroupedBackground))
                    .accessibilityAddTraits(.isHeader)
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
                    Button("Fertig") { focusedField = nil }
                }
            }
            .task {
                guard entry == nil else { return }
                // Match Cashuvo: attach the sheet and keyboard toolbar before requesting focus.
                do {
                    try await Task.sleep(for: .milliseconds(350))
                } catch {
                    return
                }
                guard !Task.isCancelled, focusedField == nil, let first = groups.first else { return }
                focusedField = .weight(first.id)
            }
            .confirmationDialog("Dieses Training löschen?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Dieses Training löschen", role: .destructive) { deleteTraining() }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                if let entry {
                    Text("Training vom \(entry.date.formatted(date: .abbreviated, time: .omitted)) für \(exercise.name) mit seinen Sätzen löschen? Die Übung und ihre Standardsätze bleiben erhalten.")
                }
            }
            .alert("Aktion fehlgeschlagen", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func deleteTraining() {
        guard let entry else { return }
        do {
            try entry.deleteKeepingExercise(in: modelContext)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func removeGroup(_ id: UUID) {
        if focusedField == .weight(id) || focusedField == .prescription(id) { focusedField = nil }
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
        training.effort = effort
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}
