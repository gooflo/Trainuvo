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
        try autoreleasepool {
            let schema = Schema(versionedSchema: TrainuvoSchemaV2.self)
            let container = try ModelContainer(for: schema, configurations: [
                ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
            ])
            let context = ModelContext(container)
            context.insert(Exercise(name: "PRIVATE_TRAINING_CONTENT", targetWeight: 123))
            try context.save()
        }
        let before = try Data(contentsOf: url)
        let report = StoreDiagnostics.report(error: NSError(domain: NSCocoaErrorDomain, code: 134504), storeURL: url)
        #expect(try Data(contentsOf: url) == before)
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
