import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID = UUID()
    var name: String = ""
    var sortOrder: Int = 0
    var targetWeight: Double?
    var activityTypeRawValue: String?
    @Relationship(deleteRule: .cascade, inverse: \TrainingEntry.exercise)
    var entries: [TrainingEntry] = []
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSetTemplate.exercise)
    var setTemplates: [ExerciseSetTemplate] = []

    var sortedSetTemplates: [ExerciseSetTemplate] {
        sortedSetTemplates(for: activityType)
    }

    func sortedSetTemplates(for type: ExerciseType) -> [ExerciseSetTemplate] {
        setTemplates.filter { $0.activityType == type }.sorted { $0.position < $1.position }
    }

    init(name: String, targetWeight: Double?, activityType: ExerciseType = .strength) {
        self.name = name
        self.targetWeight = targetWeight
        self.activityTypeRawValue = activityType.rawValue
    }

    var activityType: ExerciseType {
        get { activityTypeRawValue.flatMap(ExerciseType.init(rawValue:)) ?? .strength }
        set { activityTypeRawValue = newValue.rawValue }
    }

    var latestEntryForCurrentType: TrainingEntry? {
        sortedEntries.first { $0.activityType == activityType }
    }

    var sortedEntries: [TrainingEntry] {
        entries.sorted {
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
    var activityTypeRawValue: String?
    @Relationship(deleteRule: .nullify)
    var exercise: Exercise?

    init(position: Int, prescription: String, isWorking: Bool, activityType: ExerciseType = .strength) {
        self.position = position
        self.prescription = prescription
        self.isWorking = isWorking
        self.activityTypeRawValue = activityType.rawValue
    }

    var activityType: ExerciseType {
        get { activityTypeRawValue.flatMap(ExerciseType.init(rawValue:)) ?? .strength }
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
    var groups: [SetGroup] = []

    init(date: Date, exercise: Exercise) {
        self.date = date
        self.exercise = exercise
        self.activityTypeRawValue = exercise.activityType.rawValue
    }

    var activityType: ExerciseType {
        get { activityTypeRawValue.flatMap(ExerciseType.init(rawValue:)) ?? .strength }
        set { activityTypeRawValue = newValue.rawValue }
    }

    var sortedGroups: [SetGroup] { groups.sorted { $0.position < $1.position } }
    var workingGroup: SetGroup? {
        guard activityType.usesWeights else { return nil }
        return sortedGroups.first(where: \.isWorking)
    }

    var freeTextSummary: String {
        sortedGroups.map(\.prescription).joined(separator: " · ")
    }
    var workingWeight: Double? { workingGroup?.weight }

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
    var id: UUID = UUID()
    var position: Int = 0
    var prescription: String = ""
    var weight: Double = 0
    var isWorking: Bool = false
    @Relationship(deleteRule: .nullify)
    var entry: TrainingEntry?

    init(position: Int, prescription: String, weight: Double, isWorking: Bool) {
        self.position = position
        self.prescription = prescription
        self.weight = weight
        self.isWorking = isWorking
    }
}

enum TrainingFormat {
    static let prescriptions = ["1 × 3", "1 × 5", "3 × 5", "3 × 3", "5 × 3"]

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

    var id: Date { date }

    static func grouped(_ entries: [TrainingEntry], calendar: Calendar = .current) -> [TrainingDaySummary] {
        let days = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        return days.keys.sorted(by: >).map { day in
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
            return TrainingDaySummary(date: day, entries: ordered)
        }
    }
}

enum ExerciseType: String, CaseIterable, Identifiable {
    case strength
    case ergometer
    case swimming
    case jogging
    case other

    var id: String { rawValue }
    var usesWeights: Bool { self == .strength }

    var title: String {
        switch self {
        case .strength: "Krafttraining"
        case .ergometer: "Ergometer"
        case .swimming: "Schwimmen"
        case .jogging: "Joggen"
        case .other: "Andere"
        }
    }
}
