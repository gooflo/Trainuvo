import Foundation
import SwiftData

@MainActor
enum TrainingDataOperations {
    struct ExampleResult {
        var exercisesCreated = 0
        var trainingsCreated = 0
    }

    private struct ExampleExercise {
        let name: String
        let target: Double
        let groups: [(String, Double)]
    }

    private enum DataError: LocalizedError {
        case invalidExampleDate

        var errorDescription: String? { "Das Datum der Beispieldaten konnte nicht erstellt werden." }
    }

    static func createExamples(in context: ModelContext) throws -> ExampleResult {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let examples = [
            ExampleExercise(name: "Press", target: 40, groups: [("1 × 5", 40), ("1 × 5", 52)]),
            ExampleExercise(name: "Kniebeuge", target: 100, groups: [("1 × 5", 52), ("3 × 5", 90)]),
            ExampleExercise(name: "Bankdrücken", target: 80, groups: [("1 × 5", 50), ("3 × 3", 85)]),
            ExampleExercise(name: "Kreuzheben", target: 130, groups: [("1 × 5", 50), ("1 × 5", 70), ("3 × 5", 100)])
        ]
        do {
            var exercises = try context.fetch(FetchDescriptor<Exercise>())
            var result = ExampleResult()
            for example in examples {
                let exercise: Exercise
                if let existing = exercises.first(where: {
                    $0.name.compare(example.name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                }) {
                    guard existing.activityType.usesWeights else { continue }
                    exercise = existing
                } else {
                    exercise = Exercise(name: example.name, targetWeight: example.target)
                    exercise.sortOrder = (exercises.map(\.sortOrder).max() ?? -1) + 1
                    context.insert(exercise)
                    exercises.append(exercise)
                    result.exercisesCreated += 1
                }

                if exercise.setTemplates.isEmpty {
                    for (position, group) in example.groups.enumerated() {
                        let template = ExerciseSetTemplate(
                            position: position,
                            prescription: group.0,
                            isWorking: position == example.groups.count - 1
                        )
                        context.insert(template)
                        exercise.setTemplates.append(template)
                    }
                }

                for day in [(number: 17, reduction: 0.0), (number: 14, reduction: 2.0)] {
                    guard let date = calendar.date(from: DateComponents(year: 2026, month: 11, day: day.number, hour: 12)) else {
                        throw DataError.invalidExampleDate
                    }
                    var trainingGroups = example.groups
                    trainingGroups[trainingGroups.count - 1].1 -= day.reduction
                    let alreadyExists = exercise.entries.contains { entry in
                        guard calendar.isDate(entry.date, inSameDayAs: date) else { return false }
                        let groups = entry.sortedGroups
                        return groups.count == trainingGroups.count &&
                            zip(groups, trainingGroups).allSatisfy { actual, expected in
                                actual.prescription == expected.0 && actual.weight == expected.1
                            }
                    }
                    if alreadyExists { continue }

                    let training = TrainingEntry(date: date, exercise: exercise)
                    context.insert(training)
                    for (position, group) in trainingGroups.enumerated() {
                        let set = SetGroup(
                            position: position,
                            prescription: group.0,
                            weight: group.1,
                            isWorking: position == trainingGroups.count - 1
                        )
                        context.insert(set)
                        training.groups.append(set)
                    }
                    result.trainingsCreated += 1
                }
            }
            try context.save()
            return result
        } catch {
            context.rollback()
            throw error
        }
    }

    static func deleteAll(in context: ModelContext) throws {
        do {
            let exercises = try context.fetch(FetchDescriptor<Exercise>())
            let trainings = try context.fetch(FetchDescriptor<TrainingEntry>())
            let groups = try context.fetch(FetchDescriptor<SetGroup>())
            let templates = try context.fetch(FetchDescriptor<ExerciseSetTemplate>())
            let starterItems = try context.fetch(FetchDescriptor<Item>())

            // Detach child-to-parent links before deleting the complete local data set.
            for group in groups { group.entry = nil }
            for template in templates { template.exercise = nil }
            for training in trainings { training.exercise = nil }
            for group in groups { context.delete(group) }
            for template in templates { context.delete(template) }
            for training in trainings { context.delete(training) }
            for exercise in exercises { context.delete(exercise) }
            for item in starterItems { context.delete(item) }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
