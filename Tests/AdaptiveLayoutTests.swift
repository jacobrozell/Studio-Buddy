import Testing
@testable import StudioBuddy

@Suite("Adaptive layout", .tags(.unit, .accessibility))
struct AdaptiveLayoutTests {
    @Test("Detects landscape phone height")
    func compactHeight() {
        #expect(AdaptiveLayout.isCompactHeight(.compact))
        #expect(!AdaptiveLayout.isCompactHeight(.regular))
        #expect(!AdaptiveLayout.isCompactHeight(nil))
    }

    @Test("Player artwork shrinks in landscape")
    func playerArtworkSize() {
        let landscape = AdaptiveLayout.playerArtworkSize(compactHeight: true)
        let portrait = AdaptiveLayout.playerArtworkSize(compactHeight: false)
        #expect(landscape < portrait)
    }

    @Test("Sidebar width widens for accessibility Dynamic Type")
    func splitColumnWidthAccessibility() {
        let standard = AdaptiveLayout.splitColumnWidth(dynamicType: .large)
        let largeText = AdaptiveLayout.splitColumnWidth(dynamicType: .accessibility3)
        #expect(largeText.ideal > standard.ideal)
    }

    @Test("Split navigation needs regular width and regular height")
    func splitNavigationSizeClasses() {
        #expect(AdaptiveLayout.usesSplitNavigation(horizontal: .regular, vertical: .regular))
        #expect(!AdaptiveLayout.usesSplitNavigation(horizontal: .regular, vertical: .compact))
        #expect(!AdaptiveLayout.usesSplitNavigation(horizontal: .compact, vertical: .regular))
        #expect(!AdaptiveLayout.usesSplitNavigation(horizontal: .compact, vertical: .compact))
        #expect(!AdaptiveLayout.usesSplitNavigation(horizontal: nil, vertical: .regular))
    }

    @Test("Sidebar width tracks the window and stays ordered")
    func splitColumnFollowsWindow() {
        let wide = AdaptiveLayout.splitColumnWidth(containerWidth: 1100, dynamicType: .large)
        let narrow = AdaptiveLayout.splitColumnWidth(containerWidth: 700, dynamicType: .large)
        #expect(wide.min <= wide.ideal)
        #expect(wide.ideal <= wide.max)
        #expect(narrow.min <= narrow.ideal)
        #expect(narrow.ideal <= narrow.max)
        #expect(narrow.ideal < wide.ideal)
    }
}
