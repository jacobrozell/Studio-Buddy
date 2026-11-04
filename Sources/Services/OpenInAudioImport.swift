import Foundation
import SwiftData

enum OpenInAudioImport {
    @MainActor
    static func importURL(_ url: URL, context: ModelContext) async -> String {
        let mixes = (try? context.fetch(FetchDescriptor<Mix>())) ?? []
        do {
            let audio = try await AudioStorage.importAudio(from: url, existingMixes: mixes)
            let outcome = SongImportService.importSongs([audio], into: context)
            try? context.save()
            var parts: [String] = []
            if outcome.newSongs > 0 {
                parts.append("\(outcome.newSongs) new song\(outcome.newSongs == 1 ? "" : "s")")
            }
            if outcome.addedVersions > 0 {
                parts.append("\(outcome.addedVersions) new version\(outcome.addedVersions == 1 ? "" : "s")")
            }
            if parts.isEmpty {
                return "Imported audio into your library."
            }
            return "Imported " + parts.joined(separator: ", ") + "."
        } catch let error as AudioStorageError {
            if case let .duplicateInLibrary(songTitle) = error {
                return "This file is already in your library as \"\(songTitle)\"."
            }
            return "Could not import this audio file."
        } catch {
            return "Could not import this audio file."
        }
    }
}
