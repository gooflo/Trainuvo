import SwiftData

// Frozen five-model layout shipped before training-day comments (0.9.x–0.10.x).
// The unchanged entities are shared with frozen V1; do not substitute V2 types.
enum TrainuvoSchemaBeforeDayNotes: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(0, 9, 0) }
    static var models: [any PersistentModel.Type] {
        [
            TrainuvoSchemaV1.Item.self,
            TrainuvoSchemaV1.Exercise.self,
            TrainuvoSchemaV1.TrainingEntry.self,
            TrainuvoSchemaV1.SetGroup.self,
            TrainuvoSchemaV1.ExerciseSetTemplate.self
        ]
    }
}
