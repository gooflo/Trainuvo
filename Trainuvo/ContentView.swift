import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: [SortDescriptor(\Exercise.sortOrder), SortDescriptor(\Exercise.name)]) private var exercises: [Exercise]
    @Query(sort: \TrainingEntry.date, order: .reverse) private var entries: [TrainingEntry]
    @State private var showingExercise = false
    @State private var showingHelp = false
    @State private var showingExerciseOrder = false
    @State private var showingSettings = false
    @State private var editingTraining: TrainingEntry?
    @State private var quickTrainingExercise: Exercise?

    private var trainingDays: [TrainingDaySummary] {
        TrainingDaySummary.grouped(entries)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if exercises.isEmpty {
                        ContentUnavailableView {
                            Label("Dein Training beginnt hier", systemImage: "dumbbell")
                        } description: {
                            Text("Lege deine erste Übung an und wähle den passenden Übungstyp.")
                        } actions: {
                            Button("Übung anlegen") { showingExercise = true }
                                .buttonStyle(.borderedProminent)
                        }
                    } else {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Deine Übungen").font(.title2.bold())
                            Spacer()
                            Menu {
                                Button("Übung anlegen", systemImage: "plus") {
                                    showingExercise = true
                                }
                                Button("Übungen sortieren", systemImage: "arrow.up.arrow.down") {
                                    showingExerciseOrder = true
                                }
                                .disabled(exercises.count < 2)
                            } label: {
                                Label("Übungen verwalten", systemImage: "pencil")
                                    .labelStyle(.iconOnly)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 12)], spacing: 12) {
                            ForEach(exercises, id: \.id) { exercise in
                                ZStack(alignment: .topTrailing) {
                                    NavigationLink {
                                        ExerciseDetailView(exercise: exercise)
                                    } label: {
                                        GoalCard(exercise: exercise)
                                    }
                                    .buttonStyle(.plain)
                                    Button {
                                        quickTrainingExercise = exercise
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .frame(width: 44, height: 44)
                                    }
                                    .buttonStyle(.borderless)
                                    .padding(4)
                                    .accessibilityLabel("Training für \(exercise.name) erfassen")
                                }
                            }
                        }
                        if !trainingDays.isEmpty {
                            Text("Trainingstage").font(.title2.bold())
                            LazyVStack(alignment: .leading, spacing: 16) {
                                ForEach(trainingDays) { day in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(day.date, format: .dateTime.day().month(.wide).year())
                                            .font(.headline)
                                        VStack(spacing: 0) {
                                            ForEach(day.entries, id: \.id) { entry in
                                                if entry.exercise != nil {
                                                    Button {
                                                        editingTraining = entry
                                                    } label: {
                                                        DayTrainingRow(entry: entry)
                                                    }
                                                    .buttonStyle(.plain)
                                                } else {
                                                    DayTrainingRow(entry: entry)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(.background, in: RoundedRectangle(cornerRadius: 16))
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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Einstellungen", systemImage: "gearshape") { showingSettings = true }
                    Button("Hilfe", systemImage: "questionmark.circle") { showingHelp = true }
                }
            }
            .sheet(isPresented: $showingExercise) { ExerciseEditor() }
            .sheet(isPresented: $showingHelp) { HelpView() }
            .sheet(isPresented: $showingSettings) { SettingsView() }
            .sheet(item: $quickTrainingExercise) { exercise in
                TrainingEditor(exercise: exercise)
            }
            .sheet(item: $editingTraining) { entry in
                if let exercise = entry.exercise {
                    TrainingEditor(exercise: exercise, entry: entry)
                }
            }
            .sheet(isPresented: $showingExerciseOrder) { ExerciseOrderEditor(exercises: exercises) }
        }
        .tint(.blue)
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
            .padding(.trailing, 44)
            .frame(minHeight: 44)
            if let progress = exercise.progress {
                ProgressView(value: min(progress, 1))
                    .tint(progress >= 1 ? .green : .blue)
            }
            if exercise.activityType.usesWeights {
                HStack(spacing: 8) {
                    Text("Ziel: \(exercise.targetWeight.map { TrainingFormat.weight($0) } ?? "–")")
                    Text("Erreicht: \(exercise.latestEntryForCurrentType?.workingWeight.map { TrainingFormat.weight($0) } ?? "–")")
                    Spacer(minLength: 0)
                    if let latest = exercise.latestEntryForCurrentType {
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
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(exercise.activityType.title)
                        Spacer()
                        if let latest = exercise.latestEntryForCurrentType {
                            Text(latest.date, format: .dateTime.day().month().year(.twoDigits))
                        }
                    }
                    if let latest = exercise.latestEntryForCurrentType {
                        Text(latest.freeTextSummary)
                            .lineLimit(2)
                    } else {
                        Text("Noch kein Training")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct DayTrainingRow: View {
    let entry: TrainingEntry
    @ScaledMetric(relativeTo: .subheadline) private var effortColumnWidth: CGFloat = 26

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(entry.exercise?.name ?? "Unbekannte Übung")
                .fontWeight(.medium)
                .lineLimit(1)
            Spacer(minLength: 4)
            if !entry.activityType.usesWeights {
                Text(entry.freeTextSummary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
            } else if let group = entry.workingGroup {
                Text(entry.effort?.symbol ?? "")
                    .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                    .frame(width: effortColumnWidth)
                    .accessibilityLabel(entry.effort?.title ?? "")
                    .accessibilityHidden(entry.effort == nil)
                Text("\(group.prescription) @")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(TrainingFormat.weight(group.weight))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .layoutPriority(1)
            } else {
                Text("Kein Arbeitsgewicht").foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .contentShape(Rectangle())
    }
}

struct TrainingSummary: View {
    let entry: TrainingEntry
    @ScaledMetric(relativeTo: .subheadline) private var effortColumnWidth: CGFloat = 26

    var body: some View {
        ForEach(entry.sortedGroups, id: \.id) { group in
            if entry.activityType.usesWeights {
                HStack(alignment: .firstTextBaseline) {
                    Text(group.isWorking ? entry.effort?.symbol ?? "" : "")
                        .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                        .frame(width: effortColumnWidth)
                        .accessibilityLabel(entry.effort?.title ?? "")
                        .accessibilityHidden(!group.isWorking || entry.effort == nil)
                    Text(group.prescription)
                    Spacer()
                    Image(systemName: "target")
                        .foregroundStyle(.blue)
                        .frame(width: 18)
                        .opacity(group.isWorking ? 1 : 0)
                        .accessibilityLabel("Arbeitsgewicht")
                        .accessibilityHidden(!group.isWorking)
                    Text(TrainingFormat.weight(group.weight))
                        .fontWeight(.medium)
                        .monospacedDigit()
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.subheadline)
            } else {
                Text(group.prescription)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
    @State private var activeAlert: DetailAlert?

    var body: some View {
        List {
            Section {
                LabeledContent("Übungstyp", value: exercise.activityType.title)
                if exercise.activityType.usesWeights, let target = exercise.targetWeight {
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
                ForEach(exercise.sortedEntries, id: \.id) { entry in
                    Button {
                        editingEntry = entry
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(entry.date, format: .dateTime.day().month(.wide).year())
                                    .font(.headline)
                                if entry.activityType != exercise.activityType {
                                    Spacer()
                                    Text(entry.activityType.title).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            TrainingSummary(entry: entry)
                        }
                        .foregroundStyle(.primary)
                        .padding(.vertical, 6)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("Training löschen", role: .destructive) { activeAlert = .deleteTraining(entry) }
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Übung bearbeiten", systemImage: "pencil") { editingExercise = true }
                    Button("Übung löschen", systemImage: "trash", role: .destructive) { activeAlert = .deleteExercise }
                } label: {
                    Label("Übungsaktionen", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $editingExercise) { ExerciseEditor(exercise: exercise) }
        .sheet(isPresented: $addingTraining) { TrainingEditor(exercise: exercise) }
        .sheet(item: $editingEntry) { entry in TrainingEditor(exercise: exercise, entry: entry) }
        .alert(activeAlert?.title ?? "", isPresented: Binding(
            get: { activeAlert != nil },
            set: { if !$0 { activeAlert = nil } }
        ), presenting: activeAlert) { alert in
            switch alert {
            case .deleteTraining(let entry):
                Button("Abbrechen", role: .cancel) {}
                Button("Training löschen", role: .destructive) { deleteEntry(entry) }
            case .deleteExercise:
                Button("Abbrechen", role: .cancel) {}
                Button("Übung und Trainings löschen", role: .destructive) { deleteExercise() }
            case .error:
                Button("OK", role: .cancel) {}
            }
        } message: { alert in
            Text(alert.message)
        }
    }

    private enum DetailAlert {
        case deleteTraining(TrainingEntry)
        case deleteExercise
        case error(String)

        var title: String {
            switch self {
            case .deleteTraining: "Training löschen?"
            case .deleteExercise: "Übung wirklich löschen?"
            case .error: "Speichern fehlgeschlagen"
            }
        }

        var message: String {
            switch self {
            case .deleteTraining: "Der Trainingseintrag mit seinen Sätzen wird gelöscht. Die Übung und ihre Standardsätze bleiben erhalten."
            case .deleteExercise: "Die Übung sowie alle zugehörigen Trainings und Standardsätze werden gelöscht."
            case .error(let message): message
            }
        }
    }

    private func deleteExercise() {
        modelContext.delete(exercise)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            activeAlert = .error(error.localizedDescription)
        }
    }

    private func deleteEntry(_ entry: TrainingEntry) {
        do {
            try entry.deleteKeepingExercise(in: modelContext)
        } catch {
            activeAlert = .error(error.localizedDescription)
        }
    }
}

private struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "TrainuvoInternalVersion") as? String ?? "0.8.0"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Trainuvo \(version)") {
                    Text("Lege über den Stift neben „Deine Übungen“ eine Übung mit optionalem Zielgewicht an. Das Plus auf einer Zielkarte öffnet sofort die Trainingserfassung. Antippen der Karte öffnet den Verlauf. Einstellungen und Hilfe stehen oben rechts.")
                }
                Section("Übungen sortieren") {
                    Text("Tippe auf der Startseite neben „Deine Übungen“ auf den Stift und dann auf „Übungen sortieren“. Ziehe die Übungen an den Griffen in die gewünschte Reihenfolge und tippe auf „Speichern“. Neue Übungen werden am Ende angefügt.")
                }
                Section("Übungstypen und Freitext") {
                    Text("Beim Anlegen oder Bearbeiten einer Übung wählst du Krafttraining, Ergometer, Schwimmen, Joggen oder Andere. Bei Ergometer, Schwimmen, Joggen und Andere beschreibst du die Trainingseinheiten frei, etwa mit Dauer, Strecke oder Belastung.")
                    Text("Über „Trainingseinheit hinzufügen“ lassen sich mehrere Freitexteinheiten erfassen. Neue Einträge übernehmen die passenden Vorlagen der Übung. Ohne Vorlagen starten sie mit einem leeren Textfeld und normaler Tastatur. Auf der Startseite und im Verlauf erscheinen deine Texte.")
                    Text("Jeder Eintrag behält seinen gespeicherten Übungstyp. Wenn du den Typ der Übung später änderst, lassen sich ältere Trainings weiterhin in ihrer ursprünglichen Form öffnen.")
                }
                Section("Vorlagen für Freitextübungen") {
                    Text("Öffne die Übung und wähle „Übung bearbeiten“. Unter „Vorlagen für Trainingseinheiten“ kannst du mehrere freie Einheiten vorgeben, umordnen und entfernen. Neue Trainings übernehmen diese Texte zum Anpassen.")
                    Text("Die Vorlagen werden je Übungstyp gespeichert. Ein Wechsel des Übungstyps erhält die Vorlagen der anderen Typen. Vorhandene Trainings behalten ihre eigenen Texte.")
                }
                Section("Standardsätze pro Übung") {
                    Text("Öffne die Übung und wähle im Menü … „Übung bearbeiten“. Hinterlege die Satzgruppen in Trainingsreihenfolge, zum Beispiel 1 × 5, 1 × 5, 3 × 5, 1 × 5. Mit den Pfeilen verschiebst du Gruppen. Markiere eine Gruppe als Arbeitsgewicht.")
                    Text("Neue Trainings übernehmen die Standardsätze samt Arbeitsgewicht-Markierung. Trage nur noch die kg ein. Änderungen an den Standardsätzen gelten für künftige Trainings.")
                }
                Section("Sätze und Gewichte") {
                    Text("Oben in der Trainingserfassung steht der Übungsname als eigene Überschrift. Er bleibt auch beim Scrollen und bei geöffneter Tastatur sichtbar. Das Datum wählst du separat darunter.")
                    Text("Bei einem neuen Training wird das erste kg-Feld automatisch aktiviert. Die numerische Tastatur öffnet sich mit „Fertig“ zum Schließen. Bestehende Trainings öffnen sich zum Bearbeiten ohne automatischen Tastaturstart.")
                    Text("Die Erfassung zeigt jede Satzgruppe in einer Zeile: Arbeitsgewicht-Markierung, Sätze, Satzauswahl und kg. Tippe auf die Zielscheibe bzw. den Kreis, um die Arbeitsgruppe zu wählen. Über den Pfeil kannst du die Vorauswahl öffnen oder eine Gruppe entfernen. Entfernen geht auch durch Wischen nach links.")
                    Text("Jede Satzgruppe enthält Sätze und Wiederholungen sowie ein Gewicht. Wähle 1 × 3, 1 × 5, 3 × 5, 3 × 3 oder 5 × 3 oder gib eigenen Text wie 1 × 5 oder 5/5/4 ein.")
                    Text("Erfasse zum Beispiel 1 × 5 mit 50 kg, 1 × 5 mit 70 kg und 3 × 5 mit 100 kg. Markiere genau eine Gruppe als Arbeitsgewicht. Sie bestimmt den Zielfortschritt. Im Verlauf steht das Zielscheiben-Symbol links neben dem Arbeitsgewicht. Die Gewichte sind rechtsbündig untereinander angeordnet.")
                }
                Section("Anstrengung beim Arbeitsgewicht") {
                    Text("Unter den Satzgruppen kannst du die Bewertung direkt antippen: -- Sehr schwer, - Schwer, o Neutral, + Leicht oder ++ Sehr leicht. Die gewählte Fläche ist blau und die volle Bedeutung steht darüber. In Tagesübersicht und Verlauf steht das Symbol links vor den Sätzen der Arbeitsgruppe.")
                    Text("Jedes neue Training beginnt mit „Nicht bewertet“. Beim Bearbeiten kannst du die Bewertung nachtragen oder ändern. Über das X neben der Bewertungsüberschrift entfernst du sie wieder.")
                }
                Section("Trainingstage") {
                    Text("Die Startseite fasst Trainings nach Kalendertag zusammen. Jede Zeile zeigt Übungsname, Sätze und Wiederholungen sowie das Arbeitsgewicht, zum Beispiel Kniebeuge 3 × 5 @ 60 kg. Eine Bewertung steht links vor den Sätzen. Aufwärmgruppen bleiben im Übungsdetail sichtbar.")
                    Text("Wenn eine Übung an einem Tag mehrfach erfasst wurde, erscheint pro Trainingseintrag eine Zeile. Die Zeilen folgen deiner Übungsreihenfolge. Tippe auf eine Tageszeile, um genau diesen Trainingseintrag zu bearbeiten oder zu löschen. Den vollständigen Verlauf öffnest du über die Zielkarte der Übung.")
                }
                Section("Trainings löschen") {
                    Text("Tippe auf der Startseite auf eine Trainingszeile oder öffne im Übungsverlauf einen Eintrag. Unten findest du „Dieses Training löschen“. Bestätige die Löschung. Alternativ kannst du im Trainingsverlauf nach links wischen und „Training löschen“ wählen. Die Übung, ihre Standardsätze und andere Trainings bleiben erhalten, auch beim Löschen des letzten Trainings. Eine Übung löschst du über das separate Menü … und „Übung löschen“.")
                }
                Section("Fortschritt und Verlauf") {
                    Text("Die Zielkarten zeigen Zielgewicht, erreichtes Arbeitsgewicht und Datum des letzten Trainings gemeinsam in einer Zeile. Prozentwert und Balken zeigen den Fortschritt. Ein grünes Häkchen markiert erreichte Ziele.")
                    Text("Der Fortschritt ergibt sich aus dem Arbeitsgewicht des zeitlich letzten Trainings geteilt durch das aktuelle Zielgewicht. 60 kg bei einem Ziel von 100 kg ergeben 60 %. Bei gleichem Trainingsdatum gilt der zuletzt angelegte Eintrag.")
                    Text("Beim Erfassen ist heute vorausgewählt. Du kannst ältere Trainings nachtragen. Beim neuen Training werden die hinterlegten Standardsätze mit leeren Gewichtsfeldern übernommen. Ohne Standardsätze dient das letzte Training als Vorschlag. Tippe im Verlauf auf einen Eintrag zum Bearbeiten oder wische zum Löschen nach links.")
                }
                Section("Einstellungen und Beispieldaten") {
                    Text("Über das Zahnrad öffnest du die Einstellungen. „Beispieldaten anlegen“ ergänzt Press, Kniebeuge, Bankdrücken und Kreuzheben mit Standardsätzen und je einem Training vom 14. und 17.11.2026. Am 14.11. liegen die Arbeitsgewichte jeweils 2 kg niedriger. Die jeweils letzte Gruppe ist das Arbeitsgewicht. Gleichnamige Übungen werden wiederverwendet und identische Beispieltrainings übersprungen.")
                    Text("„Alles löschen“ entfernt nach ausdrücklicher Bestätigung alle Übungen, Trainings und Standardsätze auf diesem Gerät.")
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
