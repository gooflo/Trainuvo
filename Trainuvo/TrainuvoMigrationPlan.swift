import SwiftData

enum TrainuvoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [TrainuvoSchemaV1.self, TrainuvoSchemaV2.self] }
    static var stages: [MigrationStage] {
        [.lightweight(fromVersion: TrainuvoSchemaV1.self, toVersion: TrainuvoSchemaV2.self)]
    }
}
