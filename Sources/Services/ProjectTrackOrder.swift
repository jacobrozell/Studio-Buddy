import Foundation

enum ProjectTrackOrder {
    typealias Snapshot = [(trackID: UUID, position: Int)]

    static func snapshot(from tracks: [ProjectTrack]) -> Snapshot {
        tracks.map { ($0.id, $0.position) }
    }

    static func restore(_ snapshot: Snapshot, on tracks: [ProjectTrack]) {
        let byID = Dictionary(uniqueKeysWithValues: tracks.map { ($0.id, $0) })
        for entry in snapshot {
            byID[entry.trackID]?.position = entry.position
        }
    }
}
