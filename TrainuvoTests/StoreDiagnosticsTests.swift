import Foundation
import CoreData
import SwiftData
import Testing
@testable import Trainuvo

@MainActor
struct StoreDiagnosticsTests {
    @Test func reportingMissingStoreDoesNotCreateOne() {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = directory.appendingPathComponent("default.store")
        let error = NSError(domain: NSCocoaErrorDomain, code: 134504)
        let report = StoreDiagnostics.report(error: error, storeURL: url)
        #expect(report.contains("Datenbank vorhanden: false"))
        #expect(report.contains("NSCocoaErrorDomain / 134504"))
        #expect(!FileManager.default.fileExists(atPath: directory.path))
        #expect(!report.contains(url.path))
    }

    @Test func reportingExistingStorePreservesBytesAndOmitsTrainingContents() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("default.store")
        // Use an explicitly detached Core Data fixture so no asynchronous
        // SwiftData teardown/checkpoint can race the file comparison.
        try writeClosedFixture(at: url)
        let before = try fileSnapshot(in: directory)
        let report = StoreDiagnostics.report(error: NSError(domain: NSCocoaErrorDomain, code: 134504), storeURL: url)
        #expect(try fileSnapshot(in: directory) == before)
        #expect(report.contains("Datenbank vorhanden: true"))
        #expect(report.contains("Store Exercise:"))
        #expect(report.contains("Kompatibel: true"))
        #expect(!report.contains("PRIVATE_TRAINING_CONTENT"))
        #expect(!report.contains(url.path))
        try autoreleasepool {
            let schema = Schema(versionedSchema: TrainuvoSchemaV2.self)
            let container = try ModelContainer(for: schema, migrationPlan: TrainuvoMigrationPlan.self, configurations: [
                ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
            ])
            let context = ModelContext(container)
            #expect(try context.fetch(FetchDescriptor<Exercise>()).first?.name == "PRIVATE_TRAINING_CONTENT")
        }
    }


    private func writeClosedFixture(at url: URL) throws {
        let model: NSManagedObjectModel?
        if #available(iOS 26, *) {
            model = NSManagedObjectModel.makeManagedObjectModel(for: Schema(versionedSchema: TrainuvoSchemaV2.self))
        } else {
            model = NSManagedObjectModel.makeManagedObjectModel(for: TrainuvoSchemaV2.models)
        }
        let managedModel = try #require(model)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedModel)
        let store = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType, configurationName: nil, at: url,
            options: [NSSQLitePragmasOption: ["journal_mode": "WAL"]]
        )
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        let exercise = NSEntityDescription.insertNewObject(forEntityName: "Exercise", into: context)
        exercise.setValue(UUID(), forKey: "id")
        exercise.setValue("PRIVATE_TRAINING_CONTENT", forKey: "name")
        exercise.setValue(0, forKey: "sortOrder")
        exercise.setValue(123.0, forKey: "targetWeight")
        exercise.setValue("strength", forKey: "activityTypeRawValue")
        try context.save()
        context.reset()
        try coordinator.remove(store)
    }

    private func fileSnapshot(in directory: URL) throws -> [String: Data] {
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isRegularFileKey])
        let regularFiles = try files.filter { try $0.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true }
        return try Dictionary(uniqueKeysWithValues: regularFiles.map { ($0.lastPathComponent, try Data(contentsOf: $0)) })
    }

    @Test func errorReportOmitsPrivateErrorDescriptionsAndUserInfo() {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = directory.appendingPathComponent("default.store")
        let nested = NSError(domain: NSCocoaErrorDomain, code: 134504, userInfo: [
            NSLocalizedDescriptionKey: "PRIVATE_NESTED_DESCRIPTION"
        ])
        let error = NSError(domain: "SyntheticError", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "PRIVATE_TRAINING_CONTENT",
            "PrivateValue": "PRIVATE_USER_INFO",
            NSUnderlyingErrorKey: nested
        ])
        let report = StoreDiagnostics.report(error: error, storeURL: url)
        #expect(report.contains("SyntheticError / 1"))
        #expect(report.contains("NSCocoaErrorDomain / 134504"))
        #expect(!report.contains("PRIVATE_"))
    }
}
