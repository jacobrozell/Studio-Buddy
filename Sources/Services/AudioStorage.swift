import Foundation
import AVFoundation
import CryptoKit

/// Manages on-disk storage of imported audio files. Files live in a dedicated
/// `Audio` subdirectory of the app's Documents folder and are referenced by
/// relative filename so the records remain valid across launches.
/// Everything learned about an audio file at import time: where it was stored
/// plus any metadata read from the file's embedded tags.
struct ImportedAudio: Sendable {
    let fileName: String
    let duration: Double
    /// Title from the file's embedded tags, if present.
    let title: String?
    /// Artist from the file's embedded tags, if present.
    let artist: String?
    /// A human-friendly fallback title derived from the original filename.
    let suggestedTitle: String
    /// Basename of the picked file (no extension), for prefix matching.
    let sourceBasename: String
}

enum AudioStorageError: LocalizedError {
    case duplicateInLibrary(songTitle: String)

    var errorDescription: String? {
        switch self {
        case let .duplicateInLibrary(songTitle):
            return "This file is already in your library as \"\(songTitle)\"."
        }
    }
}

enum AudioStorage {
    /// Directory where imported audio is copied. Created lazily on first access.
    static var audioDirectory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Audio", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    /// Copies a user-picked file into the audio directory under a unique name.
    /// - Parameter sourceURL: a security-scoped URL from the document picker.
    /// - Returns: the stored filename (relative to `audioDirectory`).
    static func contentDigest(of url: URL) throws -> SHA256.Digest {
        let needsStop = url.startAccessingSecurityScopedResource()
        defer { if needsStop { url.stopAccessingSecurityScopedResource() } }
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        return SHA256.hash(data: data)
    }

    static func contentDigest(ofStoredFile fileName: String) throws -> SHA256.Digest {
        let url = audioDirectory.appendingPathComponent(fileName)
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        return SHA256.hash(data: data)
    }

    @MainActor
    static func existingSongTitleForDuplicate(
        of sourceURL: URL,
        existingMixes: [Mix]
    ) -> String? {
        guard let incoming = try? contentDigest(of: sourceURL) else { return nil }
        for mix in existingMixes {
            guard let stored = try? contentDigest(ofStoredFile: mix.fileName),
                  stored == incoming,
                  let title = mix.song?.title else { continue }
            return title
        }
        return nil
    }

    @discardableResult
    @MainActor
    static func importFile(from sourceURL: URL, existingMixes: [Mix] = []) throws -> String {
        if let songTitle = existingSongTitleForDuplicate(of: sourceURL, existingMixes: existingMixes) {
            throw AudioStorageError.duplicateInLibrary(songTitle: songTitle)
        }

        let needsStop = sourceURL.startAccessingSecurityScopedResource()
        defer { if needsStop { sourceURL.stopAccessingSecurityScopedResource() } }

        let ext = sourceURL.pathExtension.isEmpty ? "m4a" : sourceURL.pathExtension
        let fileName = "\(UUID().uuidString).\(ext)"
        let destination = audioDirectory.appendingPathComponent(fileName)
        try FileManager.default.copyItem(at: sourceURL, to: destination)
        return fileName
    }

    /// Copies a file from the app bundle into storage (no security-scoped access).
    static func importBundledAudio(from bundleURL: URL) async throws -> ImportedAudio {
        let originalName = bundleURL.deletingPathExtension().lastPathComponent
        let ext = bundleURL.pathExtension.isEmpty ? "m4a" : bundleURL.pathExtension
        let fileName = "\(UUID().uuidString).\(ext)"
        let destination = audioDirectory.appendingPathComponent(fileName)
        try FileManager.default.copyItem(at: bundleURL, to: destination)
        return try await metadata(forStoredFile: fileName, originalName: originalName)
    }

    /// Copies a picked file into storage and reads its duration and embedded
    /// title/artist tags in one pass. Used by the import-first Library flow so a
    /// song can be created with sensible defaults already filled in.
    /// - Parameter sourceURL: a security-scoped URL from the document picker.
    @MainActor
    static func importAudio(from sourceURL: URL, existingMixes: [Mix] = []) async throws -> ImportedAudio {
        let originalName = sourceURL.deletingPathExtension().lastPathComponent
        let fileName = try importFile(from: sourceURL, existingMixes: existingMixes)
        return try await metadata(forStoredFile: fileName, originalName: originalName)
    }

    private static func metadata(forStoredFile fileName: String, originalName: String) async throws -> ImportedAudio {
        let asset = AVURLAsset(url: audioDirectory.appendingPathComponent(fileName))
        let duration = (try? await asset.load(.duration)).map(CMTimeGetSeconds) ?? 0

        var title: String?
        var artist: String?
        if let items = try? await asset.load(.commonMetadata) {
            for item in items {
                guard let key = item.commonKey else { continue }
                let value = try? await item.load(.stringValue)
                switch key {
                case .commonKeyTitle: title = nonEmpty(value)
                case .commonKeyArtist, .commonKeyCreator: artist = artist ?? nonEmpty(value)
                default: break
                }
            }
        }

        let suggested = nonEmpty(title) ?? nonEmpty(originalName) ?? "Untitled"
        return ImportedAudio(
            fileName: fileName,
            duration: duration,
            title: nonEmpty(title),
            artist: nonEmpty(artist),
            suggestedTitle: suggested,
            sourceBasename: originalName
        )
    }

    /// Returns the trimmed string, or nil when it is empty/whitespace-only.
    private static func nonEmpty(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else { return nil }
        return trimmed
    }

    /// Reads the duration in seconds of an audio file already in storage.
    static func duration(of fileName: String) async -> Double {
        let url = audioDirectory.appendingPathComponent(fileName)
        let asset = AVURLAsset(url: url)
        guard let duration = try? await asset.load(.duration) else { return 0 }
        return CMTimeGetSeconds(duration)
    }

    /// Removes a stored audio file, ignoring missing-file errors.
    static func deleteFile(named fileName: String) {
        let url = audioDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }
}
