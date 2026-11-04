import Foundation
import SwiftData

/// Builds the app's SwiftData container. UI tests use in-memory storage via `-ui_test_reset`.
enum ModelContainerFactory {
    enum StorageMode: Sendable {
        case appDefault
        case inMemory
        case customURL(URL)
    }

    static func makeContainer(mode: StorageMode = storageModeForCurrentProcess()) throws -> ModelContainer {
        let configuration: ModelConfiguration
        switch mode {
        case .inMemory:
            configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        case .appDefault:
            let url = appStoreURL()
            try ensureParentDirectoryExists(for: url)
            configuration = ModelConfiguration(url: url)
        case let .customURL(url):
            try ensureParentDirectoryExists(for: url)
            configuration = ModelConfiguration(url: url)
        }
        let schema = Schema(versionedSchema: StudioBuddySchemaV1.self)
        return try ModelContainer(
            for: schema,
            migrationPlan: StudioBuddyMigrationPlan.self,
            configurations: configuration
        )
    }

    static func storageModeForCurrentProcess() -> StorageMode {
        if ProcessInfo.processInfo.arguments.contains(UITestLaunch.resetArgument) {
            return .inMemory
        }
        return .appDefault
    }

    private static func appStoreURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("StudioBuddy.store")
    }

    private static func ensureParentDirectoryExists(for storeURL: URL) throws {
        let directory = storeURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}

extension ModelContext {
    /// Resolves a mix by its stable `id`. A `PersistentIdentifier` captured
    /// before save is temporary; `model(for:)` on that id yields a model whose
    /// backing data is already gone, and the next property write traps.
    func existingMix(id: UUID) -> Mix? {
        let target = id
        var descriptor = FetchDescriptor<Mix>(predicate: #Predicate { $0.id == target })
        descriptor.fetchLimit = 1
        return try? fetch(descriptor).first
    }

    func existingSong(id: UUID) -> Song? {
        let target = id
        var descriptor = FetchDescriptor<Song>(predicate: #Predicate { $0.id == target })
        descriptor.fetchLimit = 1
        return try? fetch(descriptor).first
    }
}
