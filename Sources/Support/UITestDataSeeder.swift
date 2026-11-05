import Foundation
import SwiftData

/// Seeds a minimal catalog for UI smoke tests (no audio files required).
enum UITestDataSeeder {
    static let songTitle = "UITest Song"
    static let projectTitle = "UITest EP"

    @MainActor
    static func seedIfEmpty(into context: ModelContext) {
        let songCount = (try? context.fetchCount(FetchDescriptor<Song>())) ?? 0
        guard songCount == 0 else { return }

        let song = Song(title: songTitle, artist: "Studio Buddy QA", bpm: 120, key: .aMinor, category: .readyToMix)
        context.insert(song)

        let fileName = "uitest-master.wav"
        writeSilentWav(named: fileName)
        let mix = Mix(name: "Master", fileName: fileName, duration: 1, isPrimary: true)
        mix.song = song
        context.insert(mix)

        let project = Project(title: projectTitle, subtitle: "Smoke test project", kind: .ep)
        context.insert(project)

        let track = ProjectTrack(position: 0, song: song)
        track.project = project
        context.insert(track)

        try? context.save()
    }

    /// A one-second silent WAV so playback tests can load real audio.
    private static func writeSilentWav(named fileName: String) {
        let url = AudioStorage.audioDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path) { return }
        let sampleRate = 8_000
        let sampleCount = sampleRate
        let dataSize = sampleCount * 2
        var data = Data()
        func appendString(_ value: String) { data.append(contentsOf: value.utf8) }
        func append32(_ value: UInt32) {
            var little = value.littleEndian
            withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
        }
        func append16(_ value: UInt16) {
            var little = value.littleEndian
            withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
        }
        appendString("RIFF")
        append32(UInt32(36 + dataSize))
        appendString("WAVE")
        appendString("fmt ")
        append32(16)
        append16(1)
        append16(1)
        append32(UInt32(sampleRate))
        append32(UInt32(sampleRate * 2))
        append16(2)
        append16(16)
        appendString("data")
        append32(UInt32(dataSize))
        data.append(Data(count: dataSize))
        try? data.write(to: url)
    }
}
