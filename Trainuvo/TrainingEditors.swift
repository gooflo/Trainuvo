import SwiftUI
import SwiftData

struct ExerciseEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]
    let exercise: Exercise?
    @State private var name: String
    @State private var activityType: ExerciseType
    @State private var templates: [SetGroupDraft]
    @State private var templateDrafts: [ExerciseType: [SetGroupDraft]] = [:]
    @State private var workingDrafts: [ExerciseType: UUID] = [:]
    @State private var workingTemplateID: UUID?
    @State private var target: String
    @State private var setTarget: String
    @FocusState private var inputFocused: Bool
    @State private var errorMessage: String?

    init(exercise: Exercise? = nil) {
        self.exercise = exercise
        let initial: [SetGroupDraft]
        if let exercise {
            initial = exercise.sortedSetTemplates.map {
                SetGroupDraft(id: $0.id, prescription: $0.prescription, weight: $0.detailText ?? "")
            }
        } else {
            initial = [SetGroupDraft()]
        }
        _templates = State(initialValue: initial)
        _workingTemplateID = State(initialValue: exercise?.sortedSetTemplates.first(where: \.isWorking)?.id ?? initial.first?.id)
        _name = State(initialValue: exercise?.name ?? "")
        _activityType = State(initialValue: exercise?.activityType ?? .strength)
        _setTarget = State(initialValue: exercise?.targetDescription ?? "")
        _target = State(initialValue: exercise.flatMap { $0.targetWeight }.map { TrainingFormat.number($0) } ?? "")
    }

    private var cleanName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanTarget: String { target.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var validation: String? {
        if cleanName.isEmpty { return "Gib einen Übungsnamen ein." }
        if exercises.contains(where: {
            $0.id != exercise?.id && $0.name.compare(cleanName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }) { return "Eine Übung mit diesem Namen ist bereits vorhanden." }
        if activityType.usesWeights && !cleanTarget.isEmpty {
            guard let value = TrainingFormat.parseWeight(cleanTarget), value >= 0.01 else {
                return "Das Zielgewicht muss zwischen 0,01 und 100.000 kg liegen."
            }
        }
        if templates.contains(where: { !$0.isValid(for: activityType, isTemplate: true) }) {
            return "Fülle die Vorlagen aus oder entferne die leere Einheit."
        }
        if activityType.usesSets && !templates.isEmpty && !templates.contains(where: { $0.id == workingTemplateID }) {
            return "Markiere eine Standardgruppe als \(activityType.workingTitle)."
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
                    Picker("Übungstyp", selection: $activityType) {
                        ForEach(ExerciseType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                }
                if activityType.usesWeights {
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
                }
                if activityType == .sets {
                    Section("Ziel") {
                        TextField("Ziel (optional)", text: $setTarget)
                            .focused($inputFocused)
                    }
                }
                Section {
                    ForEach($templates) { $template in
                        VStack(alignment: .leading, spacing: 10) {
                            if activityType.usesSets {
                                HStack {
                                    TextField("Sätze × Wiederholungen", text: $template.prescription)
                                        .focused($inputFocused)
                                    Menu {
                                        ForEach(TrainingFormat.prescriptions, id: \.self) { preset in
                                            Button(preset) { template.prescription = preset }
                                        }
                                    } label: {
                                        Label("Vorauswahl", systemImage: "list.bullet").labelStyle(.iconOnly)
                                    }
                                }
                            } else {
                                HStack(alignment: .top) {
                                    TextField("Angabe links", text: $template.prescription, axis: .vertical)
                                        .focused($inputFocused)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    TextField("Angabe rechts (optional)", text: $template.weight, axis: .vertical)
                                        .focused($inputFocused)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .lineLimit(1...5)
                            }
                            if activityType == .sets {
                                TextField("Angabe rechts (optional)", text: $template.weight, axis: .vertical)
                                    .focused($inputFocused)
                                    .multilineTextAlignment(.trailing)
                            }
                            HStack(spacing: 16) {
                                if activityType.usesSets {
                                    Button {
                                        workingTemplateID = template.id
                                    } label: {
                                        Label(
                                            workingTemplateID == template.id ? activityType.workingTitle : "\(activityType.workingTitle) wählen",
                                            systemImage: workingTemplateID == template.id ? "checkmark.circle.fill" : "circle"
                                        )
                                    }
                                    .font(.caption)
                                }
                                Spacer(minLength: 0)
                                Button { moveTemplate(template.id, by: -1) } label: {
                                    Image(systemName: "arrow.up")
                                }
                                .accessibilityLabel("Vorlageneinheit nach oben")
                                .disabled(templates.first?.id == template.id)
                                Button { moveTemplate(template.id, by: 1) } label: {
                                    Image(systemName: "arrow.down")
                                }
                                .accessibilityLabel("Vorlageneinheit nach unten")
                                .disabled(templates.last?.id == template.id)
                                Button(role: .destructive) { removeTemplate(template.id) } label: {
                                    Image(systemName: "trash")
                                }
                                .accessibilityLabel("Vorlageneinheit entfernen")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 4)
                    }
                    Button(activityType.usesSets ? "Standardgruppe hinzufügen" : "Trainingseinheit hinzufügen", systemImage: "plus.circle") {
                        let group = SetGroupDraft(prescription: activityType.usesSets ? "1 × 5" : "")
                        templates.append(group)
                        if activityType.usesSets && workingTemplateID == nil { workingTemplateID = group.id }
                    }
                } header: {
                    Text(activityType.usesSets ? "Standardsätze in Trainingsreihenfolge" : "Vorlagen für Trainingseinheiten")
                } footer: {
                    if activityType.usesWeights {
                        Text("Neue Trainings übernehmen diese Gruppen und die Arbeitsgewicht-Markierung. Du ergänzt die kg. Mit den Pfeilen änderst du die Reihenfolge.")
                    } else if activityType == .sets {
                        Text("Neue Trainings übernehmen Sätze, freie Angaben und Arbeitsgruppe. Rechts ergänzt du deine Angaben ohne feste Einheit.")
                    } else {
                        Text("Zum Beispiel links 200 W und rechts 30 min. In der Vorlage darf ein Feld leer bleiben. Neue Trainings übernehmen beide Angaben in dieser Reihenfolge.")
                    }
                }
                if let validation {
                    Section { Text(validation).foregroundStyle(.secondary) }
                }
            }
            .navigationTitle(exercise == nil ? "Neue Übung" : "Übung bearbeiten")
            .onChange(of: activityType) { oldType, newType in
                changeTemplateType(from: oldType, to: newType)
            }
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

    private func changeTemplateType(from oldType: ExerciseType, to newType: ExerciseType) {
        templateDrafts[oldType] = templates
        if oldType.usesSets { workingDrafts[oldType] = workingTemplateID }
        let stored = exercise?.sortedSetTemplates(for: newType) ?? []
        templates = templateDrafts[newType] ?? stored.map {
            SetGroupDraft(id: $0.id, prescription: $0.prescription, weight: $0.detailText ?? "")
        }
        workingTemplateID = newType.usesSets
            ? (workingDrafts[newType] ?? stored.first(where: \.isWorking)?.id ?? templates.first?.id)
            : nil
        inputFocused = false
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
        } else {
            savedExercise = Exercise(name: cleanName, targetWeight: nil, activityType: activityType)
            savedExercise.sortOrder = (exercises.map(\.sortOrder).max() ?? -1) + 1
            modelContext.insert(savedExercise)
        }
        savedExercise.activityType = activityType
        if activityType.usesWeights { savedExercise.targetWeight = targetWeight }
        if activityType == .sets { savedExercise.targetDescription = setTarget.trimmingCharacters(in: .whitespacesAndNewlines) }
        let replacedTemplates = savedExercise.sortedSetTemplates(for: activityType)
        savedExercise.templates.removeAll { $0.activityType == activityType }
        for template in replacedTemplates {
            template.exercise = nil
            modelContext.delete(template)
        }
        for (position, draft) in templates.enumerated() {
            let template = ExerciseSetTemplate(
                position: position,
                prescription: draft.prescription.trimmingCharacters(in: .whitespacesAndNewlines),
                isWorking: activityType.usesSets && draft.id == workingTemplateID,
                activityType: activityType,
                detailText: activityType.usesWeights ? nil : draft.weight.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            modelContext.insert(template)
            savedExercise.templates.append(template)
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
    var completedSets: Set<Int> = []

    init(id: UUID = UUID(), prescription: String = "3 × 5", weight: String = "") {
        self.id = id
        self.prescription = prescription
        self.weight = weight
    }

    func isValid(for type: ExerciseType, isTemplate: Bool = false) -> Bool {
        TrainingFormat.isValidUnit(prescription: prescription, value: weight, type: type, isTemplate: isTemplate)
    }
}

struct TrainingEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    let entry: TrainingEntry?
    private let activityType: ExerciseType
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
        let type = entry?.activityType ?? exercise.activityType
        self.activityType = type
        _effort = State(initialValue: entry?.effort)
        _date = State(initialValue: entry?.date ?? Date())
        let initial: [SetGroupDraft]
        let selectedWorkingID: UUID?
        if let entry {
            initial = entry.sortedGroups.map {
                var draft = SetGroupDraft(id: $0.id, prescription: $0.prescription, weight: type.usesWeights ? TrainingFormat.number($0.weight) : ($0.detailText ?? ""))
                draft.completedSets = $0.completedSets
                return draft
            }
            selectedWorkingID = entry.sortedGroups.first(where: \.isWorking)?.id
        } else if !exercise.sortedSetTemplates.isEmpty {
            initial = exercise.sortedSetTemplates.map {
                SetGroupDraft(id: $0.id, prescription: $0.prescription, weight: $0.detailText ?? "")
            }
            selectedWorkingID = exercise.sortedSetTemplates.first(where: \.isWorking)?.id
        } else if !exercise.activityType.usesSets {
            initial = [SetGroupDraft(prescription: "")]
            selectedWorkingID = nil
        } else {
            initial = exercise.latestEntryForCurrentType?.sortedGroups.map {
                SetGroupDraft(id: $0.id, prescription: $0.prescription, weight: type.usesWeights ? TrainingFormat.number($0.weight) : ($0.detailText ?? ""))
            } ?? []
            selectedWorkingID = exercise.latestEntryForCurrentType?.sortedGroups.first(where: \.isWorking)?.id
        }
        let drafts = initial.isEmpty ? [SetGroupDraft()] : initial
        _groups = State(initialValue: drafts)
        _workingID = State(initialValue: selectedWorkingID ?? drafts[0].id)
    }

    private var isValid: Bool {
        guard !groups.isEmpty else { return false }
        if activityType.usesSets && !groups.contains(where: { $0.id == workingID }) { return false }
        return groups.allSatisfy { $0.isValid(for: activityType) }
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
                        if activityType.usesSets {
                            HStack(spacing: 4) {
                                Button {
                                    workingID = group.id
                                } label: {
                                    Image(systemName: workingID == group.id ? "target" : "circle")
                                        .foregroundStyle(workingID == group.id ? Color.blue : Color.secondary)
                                        .frame(width: 28, height: 44)
                                }
                                .accessibilityLabel("Als \(activityType.workingTitle) wählen")
                                .accessibilityValue(workingID == group.id ? "Ausgewählt" : "Nicht ausgewählt")

                                TextField("Sätze", text: $group.prescription)
                                    .focused($focusedField, equals: .prescription(group.id))
                                    .accessibilityLabel("Sätze und Wiederholungen")
                                    .frame(minWidth: 38)

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
                                        .frame(width: 28, height: 44)
                                }
                                .accessibilityLabel("Satzauswahl und Aktionen")

                                SetCompletionButtons(prescription: group.prescription, completed: $group.completedSets)

                                TextField(activityType.usesWeights ? "Gewicht" : "Angabe", text: $group.weight)
                                    .keyboardType(activityType.usesWeights ? .decimalPad : .default)
                                    .focused($focusedField, equals: .weight(group.id))
                                    .multilineTextAlignment(.trailing)
                                    .monospacedDigit()
                                    .frame(minWidth: 44, idealWidth: 52, maxWidth: 64)
                                    .accessibilityLabel(activityType.usesWeights ? "Gewicht in Kilogramm" : "Freie Angabe zur Satzgruppe")
                                if activityType.usesWeights {
                                    Text("kg").foregroundStyle(.secondary)
                                }
                            }
                            .onChange(of: group.prescription) { _, value in
                                group.completedSets = TrainingSetProgress.valid(group.completedSets, for: value)
                            }
                            .buttonStyle(.borderless)
                            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 12))
                            .swipeActions {
                                if groups.count > 1 {
                                    Button("Entfernen", role: .destructive) { removeGroup(group.id) }
                                }
                            }
                        } else {
                            HStack(alignment: .top) {
                                TextField("Angabe links", text: $group.prescription, axis: .vertical)
                                    .focused($focusedField, equals: .prescription(group.id))
                                    .accessibilityLabel("Trainingseinheit, linke Angabe")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                TextField("Angabe rechts", text: $group.weight, axis: .vertical)
                                    .focused($focusedField, equals: .weight(group.id))
                                    .multilineTextAlignment(.trailing)
                                    .accessibilityLabel("Trainingseinheit, rechte Angabe")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                if groups.count > 1 {
                                    Button("Trainingseinheit entfernen", systemImage: "minus.circle") {
                                        removeGroup(group.id)
                                    }
                                    .labelStyle(.iconOnly)
                                    .frame(width: 44, height: 44)
                                    .buttonStyle(.borderless)
                                }
                            }
                            .lineLimit(1...5)
                            .padding(.vertical, 4)
                            .swipeActions {
                                if groups.count > 1 {
                                    Button("Entfernen", role: .destructive) { removeGroup(group.id) }
                                }
                            }
                        }
                    }
                    TrainingEffortSelector(selection: $effort)
                    Button(activityType.usesSets ? "Satzgruppe hinzufügen" : "Trainingseinheit hinzufügen", systemImage: "plus.circle") {
                        groups.append(SetGroupDraft(prescription: activityType.usesSets ? "1 × 5" : ""))
                    }
                } header: {
                    Text(activityType.usesSets ? (activityType.usesWeights ? "Sätze und Gewichte" : "Sätze und Angaben") : "Trainingseinheiten")
                } footer: {
                    if activityType.usesWeights {
                        Text("Kästchen pro Satz abhaken. Zielscheibe = Arbeitsgewicht. Satzauswahl und Entfernen über den Pfeil.")
                    } else if activityType == .sets {
                        Text("Kästchen pro Satz abhaken. Rechts steht deine freie Angabe ohne feste Einheit. Zielscheibe = Arbeitsgruppe; Satzauswahl und Entfernen über den Pfeil.")
                    } else {
                        Text("Zwei freie Angaben je Einheit, zum Beispiel links 200 W und rechts 30 min. Mindestens ein Feld pro Einheit ausfüllen.")
                    }
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
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry == nil ? "Training erfassen" : "Training bearbeiten")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(exercise.name)
                        .font(.title2.bold())
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)
            }
            .navigationTitle("")
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
                focusedField = activityType.usesSets || (!first.prescription.isEmpty && first.weight.isEmpty)
                    ? .weight(first.id) : .prescription(first.id)
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
            for group in entry.setGroups { modelContext.delete(group) }
            training.setGroups = []
            training.date = date
        } else {
            training = TrainingEntry(date: date, exercise: exercise)
            modelContext.insert(training)
        }
        for (position, draft) in groups.enumerated() {
            let weight = activityType.usesWeights ? (TrainingFormat.parseWeight(draft.weight) ?? 0) : 0
            let group = SetGroup(
                position: position,
                prescription: draft.prescription.trimmingCharacters(in: .whitespacesAndNewlines),
                weight: weight,
                isWorking: activityType.usesSets && draft.id == workingID,
                detailText: activityType.usesWeights ? nil : draft.weight.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            group.completedSets = activityType.usesSets ? draft.completedSets : []
            modelContext.insert(group)
            training.setGroups.append(group)
        }
        training.activityType = activityType
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

private struct TrainingEffortSelector: View {
    @Binding var selection: TrainingEffort?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .caption) private var labelHeight: CGFloat = 28

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 6),
            count: dynamicTypeSize.isAccessibilitySize ? 2 : 5
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Training bewerten")
                        .font(.subheadline.weight(.semibold))
                    Text(selection?.title ?? "Nicht bewertet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                Button("Bewertung entfernen", systemImage: "xmark.circle") {
                    selection = nil
                }
                .labelStyle(.iconOnly)
                .frame(width: 44, height: 44)
                .buttonStyle(.borderless)
                .disabled(selection == nil)
            }
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(TrainingEffort.allCases) { value in
                    Button {
                        selection = value
                    } label: {
                        VStack(spacing: 2) {
                            Text(value.symbol)
                                .font(.system(.title3, design: .monospaced).weight(.semibold))
                            Text(value.title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(minHeight: labelHeight)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(value.displayColor)
                        .background(
                            selection == value ? value.displayColor.opacity(0.10) : Color(.tertiarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    selection == value ? value.displayColor : Color.secondary.opacity(0.25),
                                    lineWidth: selection == value ? 3 : 1
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(value.selectionTitle)
                    .accessibilityAddTraits(selection == value ? .isSelected : [])
                }
            }
        }
        .padding(.vertical, 4)
    }
}
