import SwiftUI

/// Width constraints for a `NavigationSplitView` sidebar column.
struct SplitColumnWidth {
    let min: CGFloat
    let ideal: CGFloat
    let max: CGFloat
}

/// Shared size-class and Dynamic Type helpers for adaptive navigation and layout.
enum AdaptiveLayout {
    /// Landscape phone and other short-height layouts.
    static func isCompactHeight(_ vertical: UserInterfaceSizeClass?) -> Bool {
        vertical == .compact
    }

    /// Sidebar and list-detail split only when both size classes are regular
    /// (iPad, iPhone Duo inner display, a tall resizable window). iPhone Pro Max
    /// landscape is regular width and compact height, so it keeps the phone stack.
    static func usesSplitNavigation(
        horizontal: UserInterfaceSizeClass?,
        vertical: UserInterfaceSizeClass?
    ) -> Bool {
        horizontal == .regular && vertical == .regular
    }

    /// Extra bottom inset so content clears the tab bar and now-playing bar.
    static func bottomChromeClearance(
        dynamicType: DynamicTypeSize,
        showsNowPlayingBar: Bool
    ) -> CGFloat {
        var clearance = tabBarClearance(for: dynamicType)
        if showsNowPlayingBar { clearance += 56 }
        return clearance
    }

    static func tabBarClearance(for dynamicType: DynamicTypeSize) -> CGFloat {
        if dynamicType >= .accessibility5 { return 220 }
        if dynamicType >= .accessibility3 { return 160 }
        if dynamicType.isAccessibilitySize { return 120 }
        return 88
    }

    /// Prefer stacked layouts when text is large or height is compact (landscape).
    static func usesStackedLayout(
        dynamicType: DynamicTypeSize,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> Bool {
        dynamicType.isAccessibilitySize || isCompactHeight(verticalSizeClass)
    }

    /// Hero artwork cap in landscape so controls remain visible without scrolling.
    static func playerArtworkSize(compactHeight: Bool) -> CGFloat {
        compactHeight ? 140 : 280
    }

    /// Onboarding hero diameter scales down in landscape.
    static func onboardingHeroSize(compactHeight: Bool, scaled: CGFloat) -> CGFloat {
        compactHeight ? min(scaled, 96) : min(scaled, 140)
    }

    /// Sidebar column caps before the window width is known.
    static func splitColumnWidth(dynamicType: DynamicTypeSize) -> SplitColumnWidth {
        if dynamicType.isAccessibilitySize {
            SplitColumnWidth(min: 380, ideal: 420, max: 520)
        } else {
            SplitColumnWidth(min: 320, ideal: 380, max: 440)
        }
    }

    /// Sidebar width tracks the window so Stage Manager and iPad resize stay usable.
    static func splitColumnWidth(containerWidth: CGFloat, dynamicType: DynamicTypeSize) -> SplitColumnWidth {
        let caps = splitColumnWidth(dynamicType: dynamicType)
        guard containerWidth > 1 else { return caps }

        let minWidth = min(caps.min, max(240, containerWidth * 0.28))
        let ideal = min(max(containerWidth * 0.34, minWidth), caps.max)
        let maxWidth = min(max(containerWidth * 0.46, ideal), max(caps.max, ideal))
        return SplitColumnWidth(min: minWidth, ideal: ideal, max: maxWidth)
    }
}

private struct AdaptiveEmptyStateLayout: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        let clearance = AdaptiveLayout.tabBarClearance(for: dynamicTypeSize)
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView {
                content
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 8)
                    .padding(.bottom, clearance)
            }
            .scrollBounceBehavior(.basedOnSize)
        } else {
            content.safeAreaPadding(.bottom, clearance)
        }
    }
}

private struct ContainerWidthPreference: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        if next > 0 { value = next }
    }
}

extension View {
    /// Reports the view's width so split columns can follow iPad window resize.
    func onContainerWidthChange(_ width: Binding<CGFloat>) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear.preference(key: ContainerWidthPreference.self, value: proxy.size.width)
            }
        }
        .onPreferenceChange(ContainerWidthPreference.self) { width.wrappedValue = $0 }
    }

    /// Scrollable empty states with tab-bar clearance for accessibility text sizes.
    func adaptiveEmptyStateLayout() -> some View {
        modifier(AdaptiveEmptyStateLayout())
    }

    /// WCAG 2.5.5 — minimum 44×44 pt interactive target.
    func minimumTapTarget(_ size: CGFloat = 44) -> some View {
        frame(minWidth: size, minHeight: size, alignment: .center)
            .contentShape(Rectangle())
    }

    /// Sidebar selection tint and VoiceOver selected state for split-view lists.
    @ViewBuilder
    func listSidebarSelection(isSelected: Bool, enabled: Bool) -> some View {
        if enabled && isSelected {
            self
                .listRowBackground(Brand.accentMuted)
                .accessibilityAddTraits(.isSelected)
        } else {
            self
        }
    }
}
