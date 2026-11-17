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
        let schema = Schema([Item.self, Exercise.self, TrainingEntry.self, SetGroup.self])
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

        let reader = ModelContext(container)
        let saved = try #require(reader.fetch(FetchDescriptor<Exercise>()).first)
        #expect(saved.entries.count == 1)
        #expect(saved.latestEntry?.groups.count == 1)
        #expect(saved.progress == 0.6)

        reader.delete(saved)
        try reader.save()
        #expect(try reader.fetchCount(FetchDescriptor<TrainingEntry>()) == 0)
        #expect(try reader.fetchCount(FetchDescriptor<SetGroup>()) == 0)
    }
}
