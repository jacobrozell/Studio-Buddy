import XCTest

/// Automated WCAG regression checks for core Studio Buddy screens.
final class WCAGAccessibilityUITests: StudioBuddyUITestCase {
    func testLibraryPassesAccessibilityAudits() {
        let app = launchApp()
        XCTAssertTrue(app.navigationBars["Library"].waitForExistence(timeout: timeout))

        runWCAGAudit(on: app, auditTypes: WCAGAccessibilityAuditProfile.nameRoleValue)
        runWCAGAudit(on: app, auditTypes: WCAGAccessibilityAuditProfile.touchTargets) { issue in
            Self.ignoringRootNavigationChrome(issue)
        }
    }

    func testSongDetailPassesAccessibilityAudits() {
        let app = launchApp()
        let song = seededSong(in: app)
        XCTAssertTrue(song.waitForExistence(timeout: timeout))
        song.tap()
        XCTAssertTrue(app.navigationBars[Self.seededSongTitle].waitForExistence(timeout: timeout))

        runWCAGAudit(on: app, auditTypes: WCAGAccessibilityAuditProfile.nameRoleValue)
        runWCAGAudit(on: app, auditTypes: WCAGAccessibilityAuditProfile.touchTargets)
    }

    func testProjectsPassesAccessibilityAudits() {
        let app = launchApp()
        tapTab(named: "Projects", in: app)
        XCTAssertTrue(app.navigationBars["Projects"].waitForExistence(timeout: timeout))

        runWCAGAudit(on: app, auditTypes: WCAGAccessibilityAuditProfile.nameRoleValue)
        runWCAGAudit(on: app, auditTypes: WCAGAccessibilityAuditProfile.touchTargets) { issue in
            Self.ignoringRootNavigationChrome(issue)
        }
    }

    func testFullPlayerPassesAccessibilityAudits() {
        let app = launchApp()
        let song = seededSong(in: app)
        XCTAssertTrue(song.waitForExistence(timeout: timeout))
        song.tap()
        XCTAssertTrue(app.navigationBars[Self.seededSongTitle].waitForExistence(timeout: timeout))
        tapSeededPlay(in: app)
        XCTAssertTrue(app.buttons["player.playPause"].waitForExistence(timeout: timeout))
        runWCAGAudit(on: app, auditTypes: WCAGAccessibilityAuditProfile.nameRoleValue)
    }

    func testSettingsPassesAccessibilityAudits() {
        let app = launchApp()
        let settings = app.buttons[Self.settingsButtonID]
        XCTAssertTrue(settings.waitForExistence(timeout: timeout))
        settings.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: timeout))

        runWCAGAudit(on: app, auditTypes: WCAGAccessibilityAuditProfile.nameRoleValue)
        runWCAGAudit(on: app, auditTypes: WCAGAccessibilityAuditProfile.touchTargets)
    }
}
