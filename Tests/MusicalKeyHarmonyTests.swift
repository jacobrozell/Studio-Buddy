import Testing
@testable import StudioBuddy

@Suite("Musical key harmony")
struct MusicalKeyHarmonyTests {
    @Test("Includes relative major and minor")
    func relativePair() {
        let compatible = MusicalKey.harmonicallyCompatible(with: .aMinor)
        #expect(compatible.contains(.cMajor))
        #expect(compatible.contains(.aMinor))
    }

    @Test("Unknown key lists all songs when filtering")
    func unknownIncludesAll() {
        #expect(MusicalKey.harmonicallyCompatible(with: .unknown).contains(.gMajor))
    }
}
