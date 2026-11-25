import Foundation
import CoreData
import SwiftData
import Testing
@testable import Trainuvo

@MainActor
struct TrainingMigrationTests {
    private struct Fixture {
        let exerciseIDs = (0..<3).map { _ in UUID() }
        let trainingIDs = (0..<3).map { _ in UUID() }
        let templateIDs = (0..<3).map { _ in UUID() }
        let groupIDs = (0..<3).map { _ in UUID() }
        let noteID = UUID()
        let date = Date(timeIntervalSince1970: 1_795_000_000)
    }

    enum StoreSource: CaseIterable, Equatable, Sendable {
        case beforeDayNotes, unversionedV1, versionedV1
        var hasNotes: Bool { self != .beforeDayNotes }
    }

    // Exercise both unversioned released layouts and the explicitly versioned V1.
    @Test(arguments: StoreSource.allCases)
    func migratesReleasedStoreWithoutLosingTraining(_ source: StoreSource) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("default.store")
        let fixture = Fixture()
        try autoreleasepool { try writeReleasedStore(at: url, fixture: fixture, source: source) }
        if source == .beforeDayNotes {
            try autoreleasepool { try verifyReportedIPhoneFingerprint(at: url) }
        }
        try autoreleasepool { try verifyMigrationAndDeleteTraining(at: url, fixture: fixture, expectsNote: source.hasNotes) }
        try autoreleasepool {
            let container = try openCurrentStore(at: url)
            let context = ModelContext(container)
            #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 3)
            #expect(try context.fetchCount(FetchDescriptor<ExerciseSetTemplate>()) == 3)
            #expect(try context.fetchCount(FetchDescriptor<TrainingEntry>()) == 2)
            #expect(try context.fetchCount(FetchDescriptor<SetGroup>()) == 2)
            if source.hasNotes {
                #expect(try context.fetch(FetchDescriptor<TrainingDayNote>()).first?.text == "Bestandskommentar")
            } else {
                #expect(try context.fetchCount(FetchDescriptor<TrainingDayNote>()) == 0)
                try TrainingDayNote.save(text: "Kommentar nach Update", date: fixture.date, in: context)
            }
            let exercise = try #require(context.fetch(FetchDescriptor<Exercise>()).first { $0.id == fixture.exerciseIDs[0] })
            #expect(exercise.trainingEntries.isEmpty)
            let entry = TrainingEntry(date: fixture.date, exercise: exercise)
            context.insert(entry)
            let group = SetGroup(position: 0, prescription: "3 × 5", weight: 82, isWorking: true)
            context.insert(group)
            entry.setGroups.append(group)
            try context.save()
            #expect(exercise.latestEntry?.workingWeight == 82)
        }
        try autoreleasepool {
            let container = try openCurrentStore(at: url)
            let context = ModelContext(container)
            #expect(try context.fetchCount(FetchDescriptor<TrainingEntry>()) == 3)
            let exercise = try #require(context.fetch(FetchDescriptor<Exercise>()).first { $0.id == fixture.exerciseIDs[0] })
            #expect(exercise.latestEntry?.workingWeight == 82)
            #expect(exercise.templates.map(\.id) == [fixture.templateIDs[0]])
            let expectedComment = source.hasNotes ? "Bestandskommentar" : "Kommentar nach Update"
            #expect(try context.fetch(FetchDescriptor<TrainingDayNote>()).first?.text == expectedComment)
        }
    }

    private func writeReleasedStore(at url: URL, fixture: Fixture, source: StoreSource) throws {
        let schema: Schema
        switch source {
        case .beforeDayNotes: schema = Schema(TrainuvoSchemaBeforeDayNotes.models)
        case .unversionedV1: schema = Schema(TrainuvoSchemaV1.models)
        case .versionedV1: schema = Schema(versionedSchema: TrainuvoSchemaV1.self)
        }
        let container = try ModelContainer(for: schema, configurations: [
            ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        ])
        let context = ModelContext(container)
        for (index, type) in ExerciseType.allCases.enumerated() {
            let exercise = TrainuvoSchemaV1.Exercise(name: "Bestand \(index)", targetWeight: type.usesWeights ? 100 : nil, activityType: type)
            exercise.id = fixture.exerciseIDs[index]
            exercise.sortOrder = index + 5
            exercise.targetDescription = "Mein Ziel \(index)"
            context.insert(exercise)
            let template = TrainuvoSchemaV1.ExerciseSetTemplate(position: 2, prescription: "Vorlage \(index)", isWorking: type.usesSets, activityType: type, detailText: "Vorbelegung")
            template.id = fixture.templateIDs[index]
            context.insert(template)
            exercise.setTemplates.append(template)
            let entry = TrainuvoSchemaV1.TrainingEntry(date: fixture.date, exercise: exercise)
            entry.id = fixture.trainingIDs[index]
            entry.createdAt = fixture.date
            entry.effort = .veryEasy
            context.insert(entry)
            let group = TrainuvoSchemaV1.SetGroup(position: 2, prescription: "3 × 5", weight: type.usesWeights ? 80 : 0, isWorking: type.usesSets, detailText: "Freie Angabe")
            group.id = fixture.groupIDs[index]
            context.insert(group)
            entry.groups.append(group)
        }
        if source.hasNotes {
            let note = TrainuvoSchemaV1.TrainingDayNote(date: fixture.date, text: "Bestandskommentar")
            note.id = fixture.noteID
            context.insert(note)
        }
        context.insert(TrainuvoSchemaV1.Item(timestamp: fixture.date))
        try context.save()
    }

    private func openCurrentStore(at url: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: TrainuvoSchemaV4.self)
        return try ModelContainer(for: schema, migrationPlan: TrainuvoMigrationPlan.self, configurations: [
            ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        ])
    }

    private func verifyMigrationAndDeleteTraining(at url: URL, fixture: Fixture, expectsNote: Bool) throws {
        let container = try openCurrentStore(at: url)
        let context = ModelContext(container)
        let exercises = try context.fetch(FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\Exercise.sortOrder)]))
        #expect(exercises.map(\.id) == fixture.exerciseIDs)
        #expect(exercises.allSatisfy { !$0.isHiddenFromHome })
        #expect(exercises.map(\.name) == ["Bestand 0", "Bestand 1", "Bestand 2"])
        #expect(exercises.map(\.sortOrder) == [5, 6, 7])
        #expect(exercises.map(\.activityType) == ExerciseType.allCases)
        #expect(exercises.map(\.targetDescription) == ["Mein Ziel 0", "Mein Ziel 1", "Mein Ziel 2"])
        #expect(exercises.first?.progress == 0.8)
        for (index, exercise) in exercises.enumerated() {
            #expect(exercise.templates.map(\.id) == [fixture.templateIDs[index]])
            #expect(exercise.templates.first?.detailText == "Vorbelegung")
            #expect(exercise.templates.first?.prescription == "Vorlage \(index)")
            #expect(exercise.templates.first?.position == 2)
            #expect(exercise.templates.first?.isWorking == exercise.activityType.usesSets)
            #expect(exercise.templates.first?.exercise?.id == exercise.id)
            let entry = try #require(exercise.latestEntry)
            #expect(entry.id == fixture.trainingIDs[index])
            #expect(entry.date == fixture.date)
            #expect(entry.createdAt == fixture.date)
            #expect(entry.effort == .veryEasy)
            #expect(entry.activityType == exercise.activityType)
            #expect(entry.setGroups.map(\.id) == [fixture.groupIDs[index]])
            #expect(entry.setGroups.first?.entry?.id == entry.id)
            #expect(entry.setGroups.first?.detailText == "Freie Angabe")
            #expect(entry.setGroups.first?.position == 2)
            #expect(entry.setGroups.first?.prescription == "3 × 5")
            #expect(entry.setGroups.first?.weight == (exercise.activityType.usesWeights ? 80 : 0))
            #expect(entry.setGroups.first?.isWorking == exercise.activityType.usesSets)
        }
        if expectsNote {
            let note = try #require(context.fetch(FetchDescriptor<TrainingDayNote>()).first)
            #expect(note.id == fixture.noteID)
            #expect(note.dayKey == TrainingDayNote.key(for: fixture.date))
            #expect(note.text == "Bestandskommentar")
        } else {
            #expect(try context.fetchCount(FetchDescriptor<TrainingDayNote>()) == 0)
        }
        #expect(try context.fetch(FetchDescriptor<Item>()).first?.timestamp == fixture.date)
        let entry = try #require(exercises.first?.latestEntry)
        try entry.deleteKeepingExercise(in: context)
        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 3)
        #expect(try context.fetchCount(FetchDescriptor<ExerciseSetTemplate>()) == 3)
        #expect(try context.fetchCount(FetchDescriptor<TrainingDayNote>()) == (expectsNote ? 1 : 0))
    }


    private func verifyReportedIPhoneFingerprint(at url: URL) throws {
        // Public schema hashes only: no rows or user identifiers from the phone.
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType, at: url, options: [NSReadOnlyPersistentStoreOption: true]
        )
        let stored = try #require(metadata[NSStoreModelVersionHashesKey] as? [String: Data])
        let expected = [
            "Exercise": "LJeo1gPrElRTBaKoreDtVQPItqvkvGMdv3pZ8FJJ46s=",
            "ExerciseSetTemplate": "YIh3kqFYQ5m4oJgWEvCEOSbuAv7qTOXftFKKb6+hPIo=",
            "Item": "tz+EqCETrYpwWl4jr1szrkJaRxICg51GevZadC+AOhk=",
            "SetGroup": "CDNQvOu3SBwwFrc6C9hmhNjCKDvyca7PLj/nbPlyagI=",
            "TrainingEntry": "VEHXiA+bwS0eCsbx0F9TI2TI+Yu9WqxvfFZpjuwLE4M="
        ]
        #expect(stored.mapValues { $0.base64EncodedString() } == expected)
        #expect(metadata["NSStoreModelVersionChecksumKey"] as? String == "fUgx1q3CFT6KcSI2Oh1JRNA1XDK5EFVY+Gm0LIZ6zNg=")
    }

    @Test func anAlreadyMigratedV2StoreStillOpensWithExtendedPlan() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("default.store")
        let id = UUID()
        try autoreleasepool {
            let schema = Schema(versionedSchema: TrainuvoSchemaV2.self)
            let container = try ModelContainer(for: schema, configurations: [
                ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
            ])
            let context = ModelContext(container)
            let exercise = TrainuvoSchemaV2.Exercise(name: "Bereits V2", targetWeight: 100)
            exercise.id = id
            context.insert(exercise)
            context.insert(TrainuvoSchemaV2.TrainingDayNote(date: Date(), text: "Notiz aus Build 4"))
            try context.save()
        }
        try autoreleasepool {
            let container = try openCurrentStore(at: url)
            let context = ModelContext(container)
            #expect(try context.fetch(FetchDescriptor<Exercise>()).first?.id == id)
            #expect(try context.fetch(FetchDescriptor<Exercise>()).first?.isHiddenFromHome == false)
            #expect(try context.fetch(FetchDescriptor<TrainingDayNote>()).first?.text == "Notiz aus Build 4")
        }
    }

    @Test func missingCloudRelationshipsRemainSafeUntilImported() {
        let exercise = Exercise(name: "Noch ohne Beziehungen", targetWeight: 100)
        exercise.entries = nil
        exercise.setTemplates = nil
        #expect(exercise.sortedEntries.isEmpty)
        #expect(exercise.sortedSetTemplates.isEmpty)
        #expect(exercise.progress == nil)
        let entry = TrainingEntry(date: Date(), exercise: exercise)
        entry.groups = nil
        #expect(entry.sortedGroups.isEmpty)
        #expect(entry.workingWeight == nil)
        #expect(entry.freeTextSummary.isEmpty)
        exercise.trainingEntries.append(entry)
        exercise.templates.append(ExerciseSetTemplate(position: 0, prescription: "1 × 5", isWorking: true))
        entry.setGroups.append(SetGroup(position: 0, prescription: "1 × 5", weight: 60, isWorking: true))
        #expect(exercise.progress == 0.6)
        #expect(exercise.sortedSetTemplates.count == 1)
    }
}
