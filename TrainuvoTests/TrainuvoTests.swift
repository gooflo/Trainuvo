import Foundation
import SwiftData
import Testing
@testable import Trainuvo

@MainActor
struct TrainuvoTests {
    @Test func acceptsGermanAndEnglishWeights() {
        #expect(TrainingFormat.parseWeight(" 72,5 ") == 72.5)
        #expect(TrainingFormat.parseWeight("72.5") == 72.5)
        #expect(TrainingFormat.parseWeight("0") == 0)
        #expect(TrainingFormat.parseWeight("-1") == nil)
        #expect(TrainingFormat.parseWeight("NaN") == nil)
        #expect(TrainingFormat.parseWeight("inf") == nil)
        #expect(TrainingFormat.parseWeight("") == nil)
    }

    @Test func latestTrainingUsesMarkedWorkingWeight() {
        let exercise = Exercise(name: "Kreuzheben", targetWeight: 100)
        let older = TrainingEntry(date: Date(timeIntervalSince1970: 100), exercise: exercise)
        older.groups = [SetGroup(position: 0, prescription: "3 × 5", weight: 90, isWorking: true)]
        let latest = TrainingEntry(date: Date(timeIntervalSince1970: 200), exercise: exercise)
        latest.groups = [
            SetGroup(position: 0, prescription: "1 × 5", weight: 50, isWorking: false),
            SetGroup(position: 1, prescription: "3 × 5", weight: 60, isWorking: true)
        ]
        exercise.entries = [latest, older]
        #expect(exercise.progress == 0.6)
        exercise.targetWeight = 50
        #expect(exercise.progress == 1.2)
        exercise.targetWeight = nil
        #expect(exercise.progress == nil)
    }

    @Test func relationshipAndCascadePersistInStore() throws {
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self, ExerciseSetTemplate.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        let exercise = Exercise(name: "Bankdrücken", targetWeight: 100)
        context.insert(exercise)
        let training = TrainingEntry(date: Date(), exercise: exercise)
        context.insert(training)
        let group = SetGroup(position: 0, prescription: "3 × 5", weight: 60, isWorking: true)
        context.insert(group)
        training.groups.append(group)
        try context.save()

        let template = ExerciseSetTemplate(position: 0, prescription: "1 × 3", isWorking: true)
        context.insert(template)
        exercise.setTemplates.append(template)
        try context.save()

        let reader = ModelContext(container)
        let saved = try #require(reader.fetch(FetchDescriptor<Exercise>()).first)
        #expect(saved.entries.count == 1)
        #expect(saved.latestEntry?.groups.count == 1)
        #expect(saved.progress == 0.6)
        #expect(saved.sortedSetTemplates.map(\.prescription) == ["1 × 3"])
        #expect(saved.latestEntry?.sortedGroups.first?.prescription == "3 × 5")

        reader.delete(saved)
        try reader.save()
        #expect(try reader.fetchCount(FetchDescriptor<TrainingEntry>()) == 0)
        #expect(try reader.fetchCount(FetchDescriptor<SetGroup>()) == 0)
        #expect(try reader.fetchCount(FetchDescriptor<ExerciseSetTemplate>()) == 0)
    }

    @Test func templatesRetainOrderAndDoNotChangeTraining() {
        let exercise = Exercise(name: "Kreuzheben", targetWeight: 130)
        exercise.setTemplates = [
            ExerciseSetTemplate(position: 3, prescription: "1 × 5", isWorking: false),
            ExerciseSetTemplate(position: 1, prescription: "1 × 5", isWorking: false),
            ExerciseSetTemplate(position: 0, prescription: "1 × 5", isWorking: false),
            ExerciseSetTemplate(position: 2, prescription: "3 × 5", isWorking: true)
        ]
        #expect(exercise.sortedSetTemplates.map(\.prescription) == ["1 × 5", "1 × 5", "3 × 5", "1 × 5"])
        #expect(exercise.sortedSetTemplates.first(where: \.isWorking)?.position == 2)
        let training = TrainingEntry(date: Date(), exercise: exercise)
        training.groups = [SetGroup(position: 0, prescription: "3 × 3", weight: 60, isWorking: true)]
        exercise.entries = [training]
        exercise.setTemplates[0].prescription = "1 × 3"
        #expect(training.sortedGroups.first?.prescription == "3 × 3")
        #expect(training.workingWeight == 60)
        #expect(TrainingFormat.prescriptions.contains("1 × 3"))
        #expect(TrainingFormat.prescriptions.contains("1 × 5"))
    }
}
