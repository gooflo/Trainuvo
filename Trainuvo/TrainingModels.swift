import Foundation
import SwiftData

enum TrainuvoSchemaV4: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(4, 0, 0) }
    static var models: [any PersistentModel.Type] { [Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self, TrainingDayNote.self] }

    @Model
    final class Exercise {
        var id: UUID = UUID()
        var name: String = ""
        var sortOrder: Int = 0
        var targetWeight: Double?
        var targetDescription: String?
        var hiddenFromHome: Bool?

        var isHiddenFromHome: Bool { hiddenFromHome ?? false }

        func setHiddenFromHome(_ hidden: Bool, in context: ModelContext) throws {
            hiddenFromHome = hidden
            do { try context.save() } catch { context.rollback(); throw error }
        }
        var activityTypeRawValue: String?
        @Relationship(deleteRule: .cascade, inverse: \TrainingEntry.exercise)
        var entries: [TrainingEntry]? = []

        var trainingEntries: [TrainingEntry] {
            get { entries ?? [] }
            set { entries = newValue }
        }
        @Relationship(deleteRule: .cascade, inverse: \ExerciseSetTemplate.exercise)
        var setTemplates: [ExerciseSetTemplate]? = []

        var templates: [ExerciseSetTemplate] {
            get { setTemplates ?? [] }
            set { setTemplates = newValue }
        }

        var sortedSetTemplates: [ExerciseSetTemplate] {
            sortedSetTemplates(for: activityType)
        }

        func sortedSetTemplates(for type: ExerciseType) -> [ExerciseSetTemplate] {
            templates.filter { $0.activityType == type }.sorted {
                if $0.position != $1.position { return $0.position < $1.position }
                return $0.id.uuidString < $1.id.uuidString
            }
        }

        init(name: String, targetWeight: Double?, activityType: ExerciseType = .strength) {
            self.name = name
            self.targetWeight = targetWeight
            self.activityTypeRawValue = activityType.rawValue
        }

        var activityType: ExerciseType {
            get { ExerciseType.storedType(activityTypeRawValue) }
            set { activityTypeRawValue = newValue.rawValue }
        }

        var latestEntryForCurrentType: TrainingEntry? {
            sortedEntries.first { $0.activityType == activityType }
        }

        var sortedEntries: [TrainingEntry] {
            trainingEntries.sorted {
                if $0.date == $1.date { return $0.createdAt > $1.createdAt }
                return $0.date > $1.date
            }
        }

        var latestEntry: TrainingEntry? { sortedEntries.first }

        var progress: Double? {
            guard activityType.usesWeights, let targetWeight, targetWeight > 0,
                  let weight = latestEntryForCurrentType?.workingWeight else { return nil }
            return weight / targetWeight
        }
    }


    @Model
    final class ExerciseSetTemplate {
        var id: UUID = UUID()
        var position: Int = 0
        var prescription: String = ""
        var isWorking: Bool = false
        var detailText: String?
        var activityTypeRawValue: String?
        @Relationship(deleteRule: .nullify)
        var exercise: Exercise?

        init(position: Int, prescription: String, isWorking: Bool, activityType: ExerciseType = .strength, detailText: String? = nil) {
            self.position = position
            self.prescription = prescription
            self.isWorking = isWorking
            self.detailText = detailText
            self.activityTypeRawValue = activityType.rawValue
        }

        var activityType: ExerciseType {
            get { ExerciseType.storedType(activityTypeRawValue) }
            set { activityTypeRawValue = newValue.rawValue }
        }
    }

    @Model
    final class TrainingEntry {
        var id: UUID = UUID()
        var date: Date = Date()
        var createdAt: Date = Date()
        var effortRawValue: String?
        var activityTypeRawValue: String?
        @Relationship(deleteRule: .nullify)
        var exercise: Exercise?
        @Relationship(deleteRule: .cascade, inverse: \SetGroup.entry)
        var groups: [SetGroup]? = []

        var setGroups: [SetGroup] {
            get { groups ?? [] }
            set { groups = newValue }
        }

        init(date: Date, exercise: Exercise) {
            self.date = date
            self.exercise = exercise
            self.activityTypeRawValue = exercise.activityType.rawValue
        }

        var activityType: ExerciseType {
            get { ExerciseType.storedType(activityTypeRawValue) }
            set { activityTypeRawValue = newValue.rawValue }
        }

        var sortedGroups: [SetGroup] { setGroups.sorted { $0.position < $1.position } }
        var workingGroup: SetGroup? {
            guard activityType.usesSets else { return nil }
            return sortedGroups.first(where: \.isWorking)
        }

        var freeTextSummary: String {
            sortedGroups.map { $0.summary(for: activityType) }.joined(separator: " · ")
        }
        var workingWeight: Double? { activityType.usesWeights ? workingGroup?.weight : nil }

        func deleteKeepingExercise(in context: ModelContext) throws {
            // Remove the parent link before deleting the training and its owned groups.
            exercise = nil
            context.delete(self)
            do {
                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }

        var effort: TrainingEffort? {
            get { effortRawValue.flatMap(TrainingEffort.init(rawValue:)) }
            set { effortRawValue = newValue?.rawValue }
        }
    }

    @Model
    final class SetGroup {
        var completedSetsRawValue: String?

        var completedSets: Set<Int> {
            get {
                let indices = Set((completedSetsRawValue ?? "").split(separator: ",").compactMap { Int($0) })
                return TrainingSetProgress.valid(indices, for: prescription)
            }
            set {
                let indices = TrainingSetProgress.valid(newValue, for: prescription)
                completedSetsRawValue = indices.isEmpty ? nil : indices.sorted().map { String($0) }.joined(separator: ",")
            }
        }

        var id: UUID = UUID()
        var position: Int = 0
        var prescription: String = ""
        var weight: Double = 0
        var isWorking: Bool = false
        var detailText: String?
        @Relationship(deleteRule: .nullify)
        var entry: TrainingEntry?

        init(position: Int, prescription: String, weight: Double, isWorking: Bool, detailText: String? = nil) {
            self.position = position
            self.prescription = prescription
            self.weight = weight
            self.isWorking = isWorking
            self.detailText = detailText
        }

        func valueText(for type: ExerciseType) -> String {
            type.usesWeights ? TrainingFormat.weight(weight) : (detailText ?? "")
        }

        func summary(for type: ExerciseType) -> String {
            [prescription, valueText(for: type)]
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .joined(separator: type.usesSets ? " @ " : " – ")
        }
    }


    @Model
    final class TrainingDayNote {
        var id: UUID = UUID()
        var dayKey: String = ""
        var text: String = ""

        init(date: Date, text: String, calendar: Calendar = .current) {
            self.dayKey = Self.key(for: date, calendar: calendar)
            self.text = text
        }

        static func key(for date: Date, calendar: Calendar = .current) -> String {
            formatter(calendar).string(from: date)
        }

        func date(calendar: Calendar = .current) -> Date? {
            Self.formatter(calendar).date(from: dayKey)
        }

        private static func formatter(_ calendar: Calendar) -> DateFormatter {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = calendar.timeZone
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }

        static func combined(_ notes: [TrainingDayNote]) -> String {
            notes.sorted { $0.id.uuidString < $1.id.uuidString }
                .map(\.text).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .joined(separator: "\n\n")
        }

        static func save(text: String, date: Date, in context: ModelContext, calendar: Calendar = .current) throws {
            let dayKey = Self.key(for: date, calendar: calendar)
            let matching = try context.fetch(FetchDescriptor<TrainingDayNote>()).filter { $0.dayKey == dayKey }
                .sorted { $0.id.uuidString < $1.id.uuidString }
            let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if clean.isEmpty {
                for note in matching { context.delete(note) }
            } else if let first = matching.first {
                first.text = clean
                for note in matching.dropFirst() { context.delete(note) }
            } else {
                context.insert(TrainingDayNote(date: date, text: clean, calendar: calendar))
            }
            do { try context.save() } catch { context.rollback(); throw error }
        }
    }

    @Model
    final class Item {
        var timestamp: Date = Date()
        
        init(timestamp: Date) {
            self.timestamp = timestamp
        }
    }
}

typealias Item = TrainuvoSchemaV4.Item
typealias Exercise = TrainuvoSchemaV4.Exercise
typealias ExerciseSetTemplate = TrainuvoSchemaV4.ExerciseSetTemplate
typealias TrainingEntry = TrainuvoSchemaV4.TrainingEntry
typealias SetGroup = TrainuvoSchemaV4.SetGroup
typealias TrainingDayNote = TrainuvoSchemaV4.TrainingDayNote

enum TrainingFormat {
    static let prescriptions = ["1 × 3", "1 × 5", "3 × 5", "3 × 3", "5 × 3"]

    static func isValidUnit(prescription: String, value: String, type: ExerciseType, isTemplate: Bool = false) -> Bool {
        let left = prescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let right = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if type == .other { return !left.isEmpty || !right.isEmpty }
        guard !left.isEmpty else { return false }
        if isTemplate { return true }
        return type.usesWeights ? parseWeight(right) != nil : !right.isEmpty
    }

    static func number(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }

    static func weight(_ value: Double) -> String { "\(number(value)) kg" }

    static func parseWeight(_ text: String) -> Double? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value.isFinite,
              value >= 0, value <= 100_000 else { return nil }
        return value
    }
}

enum TrainingEffort: String, CaseIterable, Identifiable {
    case veryHard
    case hard
    case okay
    case easy
    case veryEasy

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .veryHard: "--"
        case .hard: "-"
        case .okay: "o"
        case .easy: "+"
        case .veryEasy: "++"
        }
    }

    var title: String {
        switch self {
        case .veryHard: "Sehr schwer"
        case .hard: "Schwer"
        case .okay: "Neutral"
        case .easy: "Leicht"
        case .veryEasy: "Sehr leicht"
        }
    }

    var selectionTitle: String { "\(symbol) \(title)" }
}

struct TrainingDaySummary: Identifiable {
    let date: Date
    let entries: [TrainingEntry]
    var noteText: String = ""

    var id: Date { date }

    static func grouped(_ entries: [TrainingEntry], notes: [TrainingDayNote] = [], calendar: Calendar = .current) -> [TrainingDaySummary] {
        let days = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        let notesByDay = Dictionary(grouping: notes.compactMap { note -> (Date, TrainingDayNote)? in
            guard let date = note.date(calendar: calendar), !note.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return (calendar.startOfDay(for: date), note)
        }, by: { $0.0 })
        return Set(days.keys).union(notesByDay.keys).sorted(by: >).map { day in
            let ordered = (days[day] ?? []).sorted { left, right in
                let leftOrder = left.exercise?.sortOrder ?? Int.max
                let rightOrder = right.exercise?.sortOrder ?? Int.max
                if leftOrder != rightOrder { return leftOrder < rightOrder }
                let leftName = left.exercise?.name ?? ""
                let rightName = right.exercise?.name ?? ""
                if leftName != rightName { return leftName < rightName }
                if left.date != right.date { return left.date > right.date }
                return left.createdAt > right.createdAt
            }
            return TrainingDaySummary(date: day, entries: ordered, noteText: TrainingDayNote.combined((notesByDay[day] ?? []).map { $0.1 }))
        }
    }
}

enum ExerciseType: String, CaseIterable, Identifiable {
    case strength
    case sets
    case other

    var id: String { rawValue }
    var usesWeights: Bool { self == .strength }
    var usesSets: Bool { self != .other }
    var workingTitle: String { usesWeights ? "Arbeitsgewicht" : "Arbeitsgruppe" }

    // Keep the stored raw values untouched; retired free-text types share Andere.
    static func storedType(_ rawValue: String?) -> ExerciseType {
        switch rawValue {
        case "ergometer", "swimming", "jogging": .other
        default: rawValue.flatMap(ExerciseType.init(rawValue:)) ?? .strength
        }
    }

    var title: String {
        switch self {
        case .strength: "Krafttraining"
        case .sets: "Satzübung"
        case .other: "Andere"
        }
    }
}
