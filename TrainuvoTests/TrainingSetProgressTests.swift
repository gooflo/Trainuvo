import Foundation
import SwiftData
import Testing
@testable import Trainuvo

@MainActor
struct TrainingSetProgressTests {
    @Test func parsesOnlyUnambiguousSetPrescriptions() {
        for (text, count) in [("1x5", 1), ("3 × 5", 3), ("5x5", 5), ("5x3", 5), (" 3 X 3 ", 3), ("10x5", 10)] {
            #expect(TrainingSetProgress.count(for: text) == count)
        }
        for text in ["", "Klimmzüge", "3", "0x5", "3x0", "-1x5", "3x5x2", "3x5 leicht", "101x5"] {
            #expect(TrainingSetProgress.count(for: text) == 0)
        }
        #expect(TrainingSetProgress.valid([0, 1, 3, 5], for: "3x5") == [1, 3])
    }

    @Test(arguments: [ExerciseType.strength, .sets])
    func migratesV3AndPersistsIndividualCheckmarks(_ type: ExerciseType) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("default.store")
        let exerciseID = UUID(), entryID = UUID(), groupID = UUID()
        let date = Date(timeIntervalSince1970: 1_795_000_000)
        try autoreleasepool {
            let schema = Schema(versionedSchema: TrainuvoSchemaV3.self)
            let container = try ModelContainer(for: schema, configurations: [
                ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
            ])
            let context = ModelContext(container)
            let exercise = TrainuvoSchemaV3.Exercise(name: "Bestandsübung", targetWeight: 100)
            exercise.id = exerciseID
            exercise.activityType = type
            exercise.hiddenFromHome = true
            context.insert(exercise)
            let entry = TrainuvoSchemaV3.TrainingEntry(date: date, exercise: exercise)
            entry.id = entryID
            entry.effort = .easy
            context.insert(entry)
            let group = TrainuvoSchemaV3.SetGroup(position: 0, prescription: "5 × 3", weight: 80, isWorking: true, detailText: "Ohne Band")
            group.id = groupID
            context.insert(group)
            entry.setGroups.append(group)
            try context.save()
        }
        try autoreleasepool {
            let context = ModelContext(try openStore(at: url))
            let exercise = try #require(context.fetch(FetchDescriptor<Exercise>()).first)
            let entry = try #require(exercise.latestEntry)
            let group = try #require(entry.sortedGroups.first)
            #expect(exercise.id == exerciseID && exercise.isHiddenFromHome)
            #expect(entry.id == entryID && entry.date == date && entry.effort == .easy)
            #expect(group.id == groupID && group.weight == 80 && group.isWorking)
            #expect(group.detailText == "Ohne Band")
            #expect(group.completedSets.isEmpty)
            group.completedSets = [1, 3, 5]
            try context.save()
        }
        try autoreleasepool {
            let context = ModelContext(try openStore(at: url))
            let group = try #require(context.fetch(FetchDescriptor<SetGroup>()).first)
            #expect(group.completedSets == [1, 3, 5])
            group.completedSets.remove(3)
            group.prescription = "3 × 5"
            let remaining = group.completedSets
            group.completedSets = remaining
            #expect(group.completedSets == [1])
            try context.save()
            let entry = try #require(context.fetch(FetchDescriptor<TrainingEntry>()).first)
            #expect(TrainingExport.snapshot([entry]).first?.groups.first?.completedSets == [1])
            let data = try TrainingExport.json([entry], from: date, to: date)
            let document = try JSONDecoder.isoDates.decode(TrainingExport.Document.self, from: data)
            #expect(document.entries.first?.groups.first?.completedSets == [1])
            let fresh = SetGroup(position: 0, prescription: "3x5", weight: 80, isWorking: true)
            #expect(fresh.completedSets.isEmpty)
        }
        try autoreleasepool {
            let context = ModelContext(try openStore(at: url))
            #expect(try context.fetch(FetchDescriptor<SetGroup>()).first?.completedSets == [1])
            #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 1)
            #expect(try context.fetchCount(FetchDescriptor<TrainingEntry>()) == 1)
        }
    }

    private func openStore(at url: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: TrainuvoSchemaV4.self)
        return try ModelContainer(for: schema, migrationPlan: TrainuvoMigrationPlan.self, configurations: [
            ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        ])
    }
}

private extension JSONDecoder {
    static var isoDates: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
