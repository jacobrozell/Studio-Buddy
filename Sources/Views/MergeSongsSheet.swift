import SwiftUI
import SwiftData

/// Picks another song whose mixes will be folded into the destination song.
struct MergeSongsSheet: View {
    let destination: Song
    let candidates: [Song]
    let onMerge: (Song) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedSourceID: UUID?

    var body: some View {
        NavigationStack {
            List {
                if let selectedSource {
                    Section("Preview") {
                        Text(previewText(for: selectedSource))
                            .accessibilityIdentifier(A11yID.Song.mergePreview)
                    }
                }

                Section("Choose a song to merge") {
                    ForEach(candidates) { song in
                        MergeCandidateRow(
                            song: song,
                            isSelected: selectedSourceID == song.id
                        ) {
                            selectedSourceID = song.id
                        }
                    }
                }
            }
            .navigationTitle("Merge into this song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Merge") {
                        if let selectedSource {
                            onMerge(selectedSource)
                            dismiss()
                        }
                    }
                    .disabled(selectedSourceID == nil)
                    .accessibilityIdentifier(A11yID.Song.mergeConfirm)
                }
            }
            .accessibilityIdentifier(A11yID.Song.mergeSheet)
        }
    }

    private var selectedSource: Song? {
        guard let selectedSourceID else { return nil }
        return candidates.first { $0.id == selectedSourceID }
    }

    private func previewText(for source: Song) -> String {
        let count = source.mixes.count
        let word = count == 1 ? "version" : "versions"
        return "Moves \(count) \(word) from \"\(source.title)\"."
    }
}

private struct MergeCandidateRow: View {
    let song: Song
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .foregroundStyle(.primary)
                    Text("\(song.mixes.count) version\(song.mixes.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .accessibilityLabel("\(song.title), \(song.mixes.count) versions")
    }
}
