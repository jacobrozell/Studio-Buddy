import SwiftUI
import UIKit

private enum VerticalTabBarClearance {
    static let width: CGFloat = 64
}

extension View {
    /// Paints app windows with the brand background so Duo uncovered edges are not white.
    func studioWindowChrome() -> some View {
        background(StudioBuddyWindowBackground())
    }

    @ViewBuilder
    func studioNavigationBarBackground() -> some View {
        if #available(iOS 26, *) {
            containerBackground(Brand.background, for: .navigation)
        } else {
            self
        }
    }

    /// Clears the vertical tab bar on iPhone Duo inner display.
    func verticalTabBarClearance() -> some View {
        modifier(VerticalTabBarClearanceModifier())
    }
}

private struct VerticalTabBarClearanceModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 27.1, *) {
            content.modifier(VerticalTabBarClearanceIOS271())
        } else {
            content
        }
    }
}

@available(iOS 27.1, *)
private struct VerticalTabBarClearanceIOS271: ViewModifier {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge

    func body(content: Content) -> some View {
        content.padding(.trailing, toolbarVerticalEdge == .trailing ? VerticalTabBarClearance.width : 0)
    }
}

private struct StudioBuddyWindowBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> StudioBuddyWindowBackgroundView {
        StudioBuddyWindowBackgroundView()
    }

    func updateUIView(_ uiView: StudioBuddyWindowBackgroundView, context: Context) {
        uiView.applyBackground()
    }
}

private final class StudioBuddyWindowBackgroundView: UIView {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        applyBackground()
    }

    func applyBackground() {
        guard let window = window else { return }
        window.backgroundColor = Brand.uiBackground
    }
}
