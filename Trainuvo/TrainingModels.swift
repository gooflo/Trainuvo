import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID = UUID()
    var name: String = ""
    var sortOrder: Int = 0
    var targetWeight: Double?
    @Relationship(deleteRule: .cascade, inverse: \TrainingEntry.exercise)
    var entries: [TrainingEntry] = []
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSetTemplate.exercise)
    var setTemplates: [ExerciseSetTemplate] = []

    var sortedSetTemplates: [ExerciseSetTemplate] {
        setTemplates.sorted { $0.position < $1.position }
    }

    init(name: String, targetWeight: Double?) {
        self.name = name
        self.targetWeight = targetWeight
    }

    var sortedEntries: [TrainingEntry] {
        entries.sorted {
            if $0.date == $1.date { return $0.createdAt > $1.createdAt }
            return $0.date > $1.date
        }
    }

    var latestEntry: TrainingEntry? { sortedEntries.first }

    var progress: Double? {
        guard let targetWeight, targetWeight > 0,
              let weight = latestEntry?.workingWeight else { return nil }
        return weight / targetWeight
    }
}


@Model
final class ExerciseSetTemplate {
    var id: UUID = UUID()
    var position: Int = 0
    var prescription: String = ""
    var isWorking: Bool = false
    var exercise: Exercise?

    init(position: Int, prescription: String, isWorking: Bool) {
        self.position = position
        self.prescription = prescription
        self.isWorking = isWorking
    }
}

@Model
final class TrainingEntry {
    var id: UUID = UUID()
    var date: Date = Date()
    var createdAt: Date = Date()
    var exercise: Exercise?
    @Relationship(deleteRule: .cascade, inverse: \SetGroup.entry)
    var groups: [SetGroup] = []

    init(date: Date, exercise: Exercise) {
        self.date = date
        self.exercise = exercise
    }

    var sortedGroups: [SetGroup] { groups.sorted { $0.position < $1.position } }
    var workingWeight: Double? { sortedGroups.first(where: \.isWorking)?.weight }
}

@Model
final class SetGroup {
    var id: UUID = UUID()
    var position: Int = 0
    var prescription: String = ""
    var weight: Double = 0
    var isWorking: Bool = false
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
