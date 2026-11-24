import SwiftData

enum TrainuvoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TrainuvoSchemaBeforeDayNotes.self, TrainuvoSchemaV1.self, TrainuvoSchemaV2.self, TrainuvoSchemaV3.self]
    }
    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: TrainuvoSchemaBeforeDayNotes.self, toVersion: TrainuvoSchemaV1.self),
            .lightweight(fromVersion: TrainuvoSchemaV1.self, toVersion: TrainuvoSchemaV2.self),
            .lightweight(fromVersion: TrainuvoSchemaV2.self, toVersion: TrainuvoSchemaV3.self)
        ]
    }
}
