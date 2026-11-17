import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: [SortDescriptor(\Exercise.sortOrder), SortDescriptor(\Exercise.name)]) private var exercises: [Exercise]
    @Query(sort: \TrainingEntry.date, order: .reverse) private var entries: [TrainingEntry]
    @State private var showingExercise = false
    @State private var showingHelp = false
    @State private var showingExerciseOrder = false

    private var latestDay: [TrainingEntry] {
        guard let date = entries.first?.date else { return [] }
        return entries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if exercises.isEmpty {
                        ContentUnavailableView {
                            Label("Dein Training beginnt hier", systemImage: "dumbbell")
                        } description: {
                            Text("Lege deine erste Übung an und setze dir ein Zielgewicht.")
                        } actions: {
                            Button("Übung anlegen") { showingExercise = true }
                                .buttonStyle(.borderedProminent)
                        }
                    } else {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Deine Ziele").font(.title2.bold())
                            Spacer()
                            Button("Sortieren", systemImage: "arrow.up.arrow.down") {
                                showingExerciseOrder = true
                            }
                            .font(.subheadline)
                            .disabled(exercises.count < 2)
                        }
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 12)], spacing: 12) {
                            ForEach(exercises) { exercise in
                                NavigationLink {
                                    ExerciseDetailView(exercise: exercise)
                                } label: {
                                    GoalCard(exercise: exercise)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        if let latest = entries.first {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Calendar.current.isDateInToday(latest.date) ? "Training heute" : "Letzter Trainingstag")
                                    .font(.title2.bold())
                                Text(latest.date, format: .dateTime.day().month(.wide).year())
                                    .foregroundStyle(.secondary)
                                ForEach(latestDay) { entry in
                                    if let exercise = entry.exercise {
                                        NavigationLink {
                                            ExerciseDetailView(exercise: exercise)
                                        } label: {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(exercise.name).font(.headline)
                                                TrainingSummary(entry: entry)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(.background, in: RoundedRectangle(cornerRadius: 18))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 1000)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Trainuvo")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hilfe", systemImage: "questionmark.circle") { showingHelp = true }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Übung anlegen", systemImage: "plus") { showingExercise = true }
                }
            }
            .sheet(isPresented: $showingExercise) { ExerciseEditor() }
            .sheet(isPresented: $showingHelp) { HelpView() }
            .sheet(isPresented: $showingExerciseOrder) { ExerciseOrderEditor(exercises: exercises) }
        }
        .tint(.teal)
    }
}

private struct GoalCard: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(exercise.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer(minLength: 4)
                if let progress = exercise.progress {
                    Text(progress, format: .percent.precision(.fractionLength(0)))
                        .font(.title3.bold())
                        .monospacedDigit()
                        .foregroundStyle(progress >= 1 ? Color.green : Color.primary)
                        .layoutPriority(1)
                    if progress >= 1 {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                            .accessibilityLabel("Ziel erreicht")
                    }
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let progress = exercise.progress {
                ProgressView(value: min(progress, 1))
                    .tint(progress >= 1 ? .green : .teal)
            }
            HStack(spacing: 8) {
                Text("Ziel: \(exercise.targetWeight.map { TrainingFormat.weight($0) } ?? "–")")
                Text("Erreicht: \(exercise.latestEntry?.workingWeight.map { TrainingFormat.weight($0) } ?? "–")")
                Spacer(minLength: 0)
                if let latest = exercise.latestEntry {
                    Text(latest.date, format: .dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits))
                        .accessibilityLabel("Letztes Training")
                        .accessibilityValue(latest.date.formatted(date: .long, time: .omitted))
                } else {
                    Text("–").accessibilityLabel("Noch kein Training")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct TrainingSummary: View {
    let entry: TrainingEntry
    @ScaledMetric(relativeTo: .subheadline) private var effortColumnWidth: CGFloat = 26

    var body: some View {
        ForEach(entry.sortedGroups) { group in
            HStack(alignment: .firstTextBaseline) {
                Text(group.prescription)
                Spacer()
                Image(systemName: "target")
                    .foregroundStyle(.teal)
                    .frame(width: 18)
                    .opacity(group.isWorking ? 1 : 0)
                    .accessibilityLabel("Arbeitsgewicht")
                    .accessibilityHidden(!group.isWorking)
                Text(group.isWorking ? entry.effort?.symbol ?? "" : "")
                    .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                    .frame(width: effortColumnWidth)
                    .accessibilityLabel(entry.effort?.title ?? "")
                    .accessibilityHidden(!group.isWorking || entry.effort == nil)
                Text(TrainingFormat.weight(group.weight))
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .fixedSize(horizontal: true, vertical: false)
            }
            .font(.subheadline)
        }
    }
}

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    @State private var editingExercise = false
    @State private var addingTraining = false
    @State private var editingEntry: TrainingEntry?
    @State private var deletingExercise = false
    @State private var deletingEntry: TrainingEntry?
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section {
                if let target = exercise.targetWeight {
                    LabeledContent("Zielgewicht", value: TrainingFormat.weight(target))
                }
                if let progress = exercise.progress {
                    LabeledContent("Aktueller Fortschritt") {
                        Text(progress, format: .percent.precision(.fractionLength(0)))
                    }
                }
                Button("Training erfassen", systemImage: "plus.circle.fill") { addingTraining = true }
            }
            Section("Trainingsverlauf") {
                if exercise.entries.isEmpty {
                    Text("Erfasse dein erstes Training.").foregroundStyle(.secondary)
                }
                ForEach(exercise.sortedEntries) { entry in
                    Button {
                        editingEntry = entry
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(entry.date, format: .dateTime.day().month(.wide).year())
                                .font(.headline)
                            TrainingSummary(entry: entry)
                        }
                        .foregroundStyle(.primary)
                        .padding(.vertical, 6)
                    }
                    .swipeActions {
                        Button("Löschen", role: .destructive) { deletingEntry = entry }
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Übung bearbeiten", systemImage: "pencil") { editingExercise = true }
                    Button("Übung löschen", systemImage: "trash", role: .destructive) { deletingExercise = true }
                } label: {
                    Label("Übungsaktionen", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $editingExercise) { ExerciseEditor(exercise: exercise) }
        .sheet(isPresented: $addingTraining) { TrainingEditor(exercise: exercise) }
        .sheet(item: $editingEntry) { entry in TrainingEditor(exercise: exercise, entry: entry) }
        .alert("Übung und alle zugehörigen Trainings löschen?", isPresented: $deletingExercise) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) { deleteExercise() }
        }
        .alert("Training löschen?", isPresented: Binding(
            get: { deletingEntry != nil },
            set: { if !$0 { deletingEntry = nil } }
        )) {
            Button("Abbrechen", role: .cancel) { deletingEntry = nil }
            Button("Löschen", role: .destructive) {
                if let entry = deletingEntry { deleteEntry(entry) }
                deletingEntry = nil
            }
        }
        .alert("Speichern fehlgeschlagen", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func deleteExercise() {
        modelContext.delete(exercise)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }

    private func deleteEntry(_ entry: TrainingEntry) {
        modelContext.delete(entry)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}

private struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "TrainuvoInternalVersion") as? String ?? "0.4.0"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Trainuvo \(version)") {
                    Text("Lege über + eine Übung mit optionalem Zielgewicht an. Tippe auf eine Übung, um ein Training zu erfassen oder den Verlauf zu öffnen.")
                }
                Section("Übungen sortieren") {
                    Text("Tippe auf der Startseite neben „Deine Ziele“ auf „Sortieren“. Ziehe die Übungen an den Griffen in die gewünschte Reihenfolge und tippe auf „Speichern“. Neue Übungen werden am Ende angefügt.")
                }
                Section("Standardsätze pro Übung") {
                    Text("Öffne die Übung und wähle im Menü … „Übung bearbeiten“. Hinterlege die Satzgruppen in Trainingsreihenfolge, zum Beispiel 1 × 5, 1 × 5, 3 × 5, 1 × 5. Mit den Pfeilen verschiebst du Gruppen. Markiere eine Gruppe als Arbeitsgewicht.")
                    Text("Neue Trainings übernehmen die Standardsätze samt Arbeitsgewicht-Markierung. Trage nur noch die kg ein. Änderungen an den Standardsätzen gelten für künftige Trainings.")
                }
                Section("Sätze und Gewichte") {
                    Text("Die Erfassung zeigt jede Satzgruppe in einer Zeile: Arbeitsgewicht-Markierung, Sätze, Satzauswahl und kg. Tippe auf die Zielscheibe bzw. den Kreis, um die Arbeitsgruppe zu wählen. Über den Pfeil kannst du die Vorauswahl öffnen oder eine Gruppe entfernen. Entfernen geht auch durch Wischen nach links.")
                    Text("Jede Satzgruppe enthält Sätze und Wiederholungen sowie ein Gewicht. Wähle 1 × 3, 1 × 5, 3 × 5, 3 × 3 oder 5 × 3 oder gib eigenen Text wie 1 × 5 oder 5/5/4 ein.")
                    Text("Erfasse zum Beispiel 1 × 5 mit 50 kg, 1 × 5 mit 70 kg und 3 × 5 mit 100 kg. Markiere genau eine Gruppe als Arbeitsgewicht. Sie bestimmt den Zielfortschritt. Im Verlauf steht das Zielscheiben-Symbol links neben dem Arbeitsgewicht. Die Gewichte sind rechtsbündig untereinander angeordnet.")
                }
                Section("Anstrengung beim Arbeitsgewicht") {
                    Text("Unter den Satzgruppen kannst du optional wählen, wie das Arbeitsgewicht war: -- Sehr schwer, - Schwer, o OK oder + Leicht – Steigerung möglich. Im Verlauf und beim letzten Trainingstag steht das Symbol links vor dem Arbeitsgewicht.")
                    Text("Jedes neue Training beginnt mit „Nicht bewertet“. Beim Bearbeiten kannst du die Bewertung nachtragen, ändern oder über „Nicht bewertet“ entfernen.")
                }
                Section("Fortschritt und Verlauf") {
                    Text("Die Zielkarten zeigen Zielgewicht, erreichtes Arbeitsgewicht und Datum des letzten Trainings gemeinsam in einer Zeile. Prozentwert und Balken zeigen den Fortschritt. Ein grünes Häkchen markiert erreichte Ziele.")
                    Text("Der Fortschritt ergibt sich aus dem Arbeitsgewicht des zeitlich letzten Trainings geteilt durch das aktuelle Zielgewicht. 60 kg bei einem Ziel von 100 kg ergeben 60 %. Bei gleichem Trainingsdatum gilt der zuletzt angelegte Eintrag.")
                    Text("Beim Erfassen ist heute vorausgewählt. Du kannst ältere Trainings nachtragen. Beim neuen Training werden die hinterlegten Standardsätze mit leeren Gewichtsfeldern übernommen. Ohne Standardsätze dient das letzte Training als Vorschlag. Tippe im Verlauf auf einen Eintrag zum Bearbeiten oder wische zum Löschen nach links.")
                }
                Section("Datenspeicherung") {
                    Text("Die Daten werden lokal auf diesem Gerät gespeichert. iCloud-Synchronisierung ist für eine spätere Version vorgesehen.")
                }
            }
            .navigationTitle("Hilfe")
            .toolbar { Button("Fertig") { dismiss() } }
        }
    }
}
