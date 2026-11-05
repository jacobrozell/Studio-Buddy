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

    /// Opaque nav fill on iOS 18–25. iOS 26+ uses Liquid Glass; an opaque bar leaves a white strip on iPhone Duo.
    @ViewBuilder
    func studioNavigationBarBackground() -> some View {
        if #available(iOS 26, *) {
            containerBackground(Brand.background, for: .navigation)
        } else {
            toolbarBackground(Brand.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    /// Sidebar tabs on iPad and the iPhone Duo inner display. Phones, including landscape, keep a tab bar.
    func studioTabStyle(sidebar: Bool) -> some View {
        modifier(StudioTabStyle(sidebar: sidebar))
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
        backgroundColor = .clear
        let color = Brand.uiBackground
        window?.backgroundColor = color
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for sceneWindow in windowScene.windows {
                sceneWindow.backgroundColor = color
                sceneWindow.rootViewController?.view.backgroundColor = color
            }
        }
    }
}

private struct StudioTabStyle: ViewModifier {
    let sidebar: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if sidebar {
            if #available(iOS 27, *) {
                content
                    .tabViewStyle(.sidebarAdaptable)
                    .defaultTabBarPlacement(.sidebar)
            } else {
                content
                    .tabViewStyle(.sidebarAdaptable)
                    .defaultAdaptableTabBarPlacement(.sidebar)
            }
        } else {
            content.tabViewStyle(.tabBarOnly)
        }
    }
}
