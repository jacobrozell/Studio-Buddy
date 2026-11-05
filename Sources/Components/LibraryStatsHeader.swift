import SwiftUI

/// Summary stat grid for the library home screen.
struct LibraryStatsHeader: View {
    let songCount: Int
    let mixCount: Int
    let projectCount: Int

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DS.Spacing.sm
        ) {
            StatTile(
                value: "\(songCount)",
                label: "Songs",
                systemImage: "music.note",
                spokenLabel: SpokenCount.phrase(songCount, singular: "song", plural: "songs")
            )
            StatTile(
                value: "\(mixCount)",
                label: "Mixes",
                systemImage: "waveform",
                spokenLabel: SpokenCount.phrase(mixCount, singular: "mix", plural: "mixes")
            )
            StatTile(
                value: "\(projectCount)",
                label: "Projects",
                systemImage: "square.stack.3d.up",
                spokenLabel: SpokenCount.phrase(projectCount, singular: "project", plural: "projects")
            )
        }
    }
}
