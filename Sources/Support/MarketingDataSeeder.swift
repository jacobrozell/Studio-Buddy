import Foundation
import SwiftData

enum MarketingDataSeeder {
    @MainActor
    static func seedIfRequested(into context: ModelContext) async {
        guard MarketingLaunch.isSeedRequested else { return }
        let songCount = (try? context.fetchCount(FetchDescriptor<Song>())) ?? 0
        guard songCount == 0 else { return }

        if DemoAudioSeeder.hasBundleTracks {
            let imported = await DemoAudioSeeder.importBundleTracks()
            _ = SongImportService.importSongs(imported, into: context, scheduleBackgroundWork: false)
        } else {
            let placeholder = Song(
                title: "Starlight",
                artist: "Demo",
                genre: "Electronic",
                bpm: 128,
                key: .aMinor,
                category: .mastered
            )
            context.insert(placeholder)
            let mix = Mix(name: "Master", fileName: "placeholder.m4a", duration: 204, isPrimary: true, role: .master)
            mix.song = placeholder
            context.insert(mix)
        }

        let songs = (try? context.fetch(FetchDescriptor<Song>(sortBy: [SortDescriptor(\.title)]))) ?? []
        guard let hero = songs.first else { return }

        if hero.mixes.count < 2, let firstMix = hero.mixes.first {
            let rough = Mix(
                name: "Rough",
                fileName: firstMix.fileName,
                duration: firstMix.duration,
                role: .rough
            )
            rough.song = hero
            context.insert(rough)
        }

        let project = Project(title: "Release EP", subtitle: "Summer 2026", kind: .ep)
        context.insert(project)
        for (index, song) in songs.prefix(5).enumerated() {
            song.bpm = 110 + index * 8
            let track = ProjectTrack(position: index, song: song)
            track.project = project
            context.insert(track)
        }
        try? context.save()
    }
}
