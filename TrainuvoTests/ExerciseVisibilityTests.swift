import Foundation
import SwiftData
import Testing
@testable import Trainuvo

@MainActor
struct ExerciseVisibilityTests {
    @Test(arguments: ExerciseType.allCases)
    func hidingAndRestoringPreservesTrainingAndExports(_ type: ExerciseType) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("visibility.store")
        let exerciseID = UUID()
        let entryID = UUID()
        let templateID = UUID()
        let groupID = UUID()
        try autoreleasepool {
            let container = try open(at: url)
            let context = ModelContext(container)
            let exercise = Exercise(name: "Mein Ziel", targetWeight: 100, activityType: type)
            exercise.id = exerciseID
            exercise.sortOrder = 4
            exercise.targetDescription = "Mein Freitextziel"
            context.insert(exercise)
            let template = ExerciseSetTemplate(position: 0, prescription: "3 × 5", isWorking: true, activityType: type)
            template.id = templateID
            context.insert(template)
            exercise.templates.append(template)
            let entry = TrainingEntry(date: Date(), exercise: exercise)
            entry.id = entryID
            entry.effort = .easy
            context.insert(entry)
            let group = SetGroup(position: 0, prescription: "3 × 5", weight: 60, isWorking: true, detailText: "30 min")
            group.id = groupID
            context.insert(group)
            entry.setGroups.append(group)
            context.insert(TrainingDayNote(date: entry.date, text: "Kommentar bleibt"))
            try context.save()
            #expect(!exercise.isHiddenFromHome)
            try exercise.setHiddenFromHome(true, in: context)
        }
        try autoreleasepool {
            let container = try open(at: url)
            let context = ModelContext(container)
            let exercises = try context.fetch(FetchDescriptor<Exercise>())
            let exercise = try #require(exercises.first)
            #expect(exercises.count == 1)
            #expect(exercises.filter { !$0.isHiddenFromHome }.isEmpty)
            #expect(exercise.id == exerciseID)
            #expect(exercise.isHiddenFromHome)
            #expect(exercise.targetWeight == 100)
            #expect(exercise.targetDescription == "Mein Freitextziel")
            #expect(exercise.sortOrder == 4)
            #expect(exercise.templates.map(\.id) == [templateID])
            #expect(exercise.trainingEntries.map(\.id) == [entryID])
            #expect(exercise.latestEntry?.setGroups.map(\.id) == [groupID])
            #expect(exercise.latestEntry?.effort == .easy)
            let entries = try context.fetch(FetchDescriptor<TrainingEntry>())
            let notes = try context.fetch(FetchDescriptor<TrainingDayNote>())
            #expect(TrainingDaySummary.grouped(entries, notes: notes).flatMap(\.entries).map(\.id) == [entryID])
            #expect(TrainingExport.snapshot(entries).count == 1)
            #expect(notes.first?.text == "Kommentar bleibt")
            try exercise.setHiddenFromHome(false, in: context)
        }
        try autoreleasepool {
            let container = try open(at: url)
            let context = ModelContext(container)
            let exercises = try context.fetch(FetchDescriptor<Exercise>())
            #expect(exercises.filter { !$0.isHiddenFromHome }.map(\.id) == [exerciseID])
            #expect(try context.fetchCount(FetchDescriptor<TrainingEntry>()) == 1)
            #expect(try context.fetchCount(FetchDescriptor<SetGroup>()) == 1)
            #expect(try context.fetchCount(FetchDescriptor<ExerciseSetTemplate>()) == 1)
            #expect(try context.fetchCount(FetchDescriptor<TrainingDayNote>()) == 1)
        }
    }

    private func open(at url: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: TrainuvoSchemaV4.self)
        return try ModelContainer(for: schema, migrationPlan: TrainuvoMigrationPlan.self, configurations: [
            ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        ])
    }
}
