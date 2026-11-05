import XCTest

/// Shared launch configuration for Studio Buddy UI tests.
class StudioBuddyUITestCase: XCTestCase {
    static let seededSongTitle = "UITest Song"
    static let seededProjectTitle = "UITest EP"
    static let settingsButtonID = "settings.button"
    static let splitSelectSongID = "split.selectSong"
    static let splitSelectProjectID = "split.selectProject"

    let timeout: TimeInterval = 12

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        MainActor.assumeIsolated {
            if XCUIDevice.shared.orientation != .portrait {
                XCUIDevice.shared.orientation = .portrait
            }
        }
    }

    override func tearDown() {
        MainActor.assumeIsolated {
            if XCUIDevice.shared.orientation != .portrait {
                XCUIDevice.shared.orientation = .portrait
            }
            XCUIApplication().terminate()
        }
        super.tearDown()
    }

    func launchApp(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-ui_test_reset",
            "-disable_analytics",
            "-ui_test_skip_onboarding",
            "-ui_test_seed_catalog"
        ] + extraArguments
        app.launch()
        waitForMainShell(in: app)
        return app
    }

    /// Waits until the root tab shell is visible (tab bar on iPhone, sidebar tabs on iPad).
    func waitForMainShell(in app: XCUIApplication) {
        let tabBarReady = app.tabBars.firstMatch.waitForExistence(timeout: 2)
        if tabBarReady { return }

        let libraryTab = app.buttons["Library"].firstMatch
        XCTAssertTrue(libraryTab.waitForExistence(timeout: timeout), "Main shell did not appear")
    }

    func seededSong(in app: XCUIApplication) -> XCUIElement {
        app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH %@", Self.seededSongTitle)
        ).firstMatch
    }

    /// Library and song detail both expose `song.play`. Tap the one on screen.
    func tapSeededPlay(in app: XCUIApplication) {
        let query = app.buttons.matching(identifier: "song.play")
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let play = query.allElementsBoundByIndex.first(where: { $0.isHittable }) {
                play.tap()
                return
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        }
    }

    func tapTab(named name: String, in app: XCUIApplication) {
        let tabBarTab = app.tabBars.buttons[name]
        if tabBarTab.waitForExistence(timeout: 2) {
            tabBarTab.tap()
            return
        }

        // iPad regular width: SwiftUI TabView uses a sidebar instead of a tab bar.
        let sidebarTab = app.buttons[name].firstMatch
        XCTAssertTrue(sidebarTab.waitForExistence(timeout: timeout), "Missing tab \(name)")
        sidebarTab.tap()
    }

    func resetSimulatorOrientationToPortrait() {
        MainActor.assumeIsolated {
            if XCUIDevice.shared.orientation != .portrait {
                XCUIDevice.shared.orientation = .portrait
            }
        }
    }

    func rotateToLandscapeLeft(app: XCUIApplication) {
        MainActor.assumeIsolated {
            XCUIDevice.shared.orientation = .landscapeLeft
        }
        RunLoop.current.run(until: Date().addingTimeInterval(0.75))
        waitForMainShell(in: app)
    }

    /// Skips when the UI test bundle is not running on an iPad simulator.
    func requireIPad() throws {
        let isPad = MainActor.assumeIsolated { UIDevice.current.userInterfaceIdiom == .pad }
        guard isPad else {
            throw XCTSkip("Requires iPad simulator")
        }
    }
}
