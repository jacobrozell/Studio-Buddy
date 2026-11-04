import SwiftData

enum StudioBuddySchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [Song.self, Mix.self, Project.self, ProjectTrack.self]
    }
}

enum StudioBuddyMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [StudioBuddySchemaV1.self]
    }

    static var stages: [MigrationStage] { [] }
}
