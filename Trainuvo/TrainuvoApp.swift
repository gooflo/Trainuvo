import SwiftUI
import SwiftData
#if DEBUG
import CoreData
import OSLog
#endif

@main
struct TrainuvoApp: App {
    private let storage: Result<ModelContainer, Error>

    init() {
        storage = Result { try Self.makeModelContainer() }
    }

    var body: some Scene {
        WindowGroup {
            switch storage {
            case .success(let container):
                ContentView()
                    .modelContainer(container)
            case .failure(let error):
                ContentUnavailableView {
                    Label("Daten konnten nicht geöffnet werden", systemImage: "externaldrive.badge.exclamationmark")
                } description: {
                    Text("Deine vorhandenen Daten werden bei diesem Fehler nicht gelöscht.")
                    Text(error.localizedDescription)
                }
            }
        }
    }

    private static func makeModelContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: TrainuvoSchemaV2.self)
        let containerID = "iCloud.com.vogtapps.Trainuvo"
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-initializeCloudKitSchema") {
            try autoreleasepool {
                try initializeCloudKitSchema(for: TrainuvoSchemaV2.models, containerID: containerID)
            }
        }
        #endif
        // No custom URL/name: preserve the released default.store and its object IDs.
        let configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .private(containerID))
        return try ModelContainer(for: schema, migrationPlan: TrainuvoMigrationPlan.self, configurations: [configuration])
    }

    #if DEBUG
    private static func initializeCloudKitSchema(
        for modelTypes: [any PersistentModel.Type],
        containerID: String
    ) throws {
        // Use an isolated store so schema setup never opens the user's database.
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        guard let model = NSManagedObjectModel.makeManagedObjectModel(for: modelTypes) else {
            throw CocoaError(.persistentStoreInvalidType)
        }

        let description = NSPersistentStoreDescription(
            url: directory.appendingPathComponent("CloudKitSchema.store")
        )
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: containerID
        )
        description.shouldAddStoreAsynchronously = false

        let container = NSPersistentCloudKitContainer(name: "TrainuvoCloudKitSchema", managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError {
            throw loadError
        }

        defer {
            for store in container.persistentStoreCoordinator.persistentStores {
                try? container.persistentStoreCoordinator.remove(store)
            }
        }

        try container.initializeCloudKitSchema()
        Logger(subsystem: "com.vogtapps.Trainuvo", category: "CloudKit").info("Development schema initialized")
    }
    #endif
}
