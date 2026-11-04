import Foundation
import Testing
@testable import StudioBuddy

@Suite("Project track order undo")
struct ProjectTrackOrderTests {
    @Test("Restores previous positions")
    func restoreSnapshot() {
        let first = ProjectTrack(position: 0)
        let second = ProjectTrack(position: 1)
        let snapshot = ProjectTrackOrder.snapshot(from: [first, second])
        first.position = 1
        second.position = 0
        ProjectTrackOrder.restore(snapshot, on: [first, second])
        #expect(first.position == 0)
        #expect(second.position == 1)
    }
}
