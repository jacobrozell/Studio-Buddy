import XCTest

final class LandscapeSmokeUITests: StudioBuddyUITestCase {
    func testLibraryRemainsUsableInLandscape() {
        let app = launchApp()
        rotateToLandscapeLeft(app: app)

        XCTAssertTrue(app.navigationBars["Library"].waitForExistence(timeout: timeout))
        XCTAssertTrue(seededSong(in: app).waitForExistence(timeout: timeout))

        let settings = app.buttons[Self.settingsButtonID]
        XCTAssertTrue(settings.waitForExistence(timeout: timeout))
    }

    func testProjectsTabInLandscape() {
        let app = launchApp()
        rotateToLandscapeLeft(app: app)

        tapTab(named: "Projects", in: app)
        XCTAssertTrue(app.staticTexts[Self.seededProjectTitle].waitForExistence(timeout: timeout))
    }

    func testSongDetailAndPlayerInLandscape() {
        let app = launchApp()
        rotateToLandscapeLeft(app: app)

        let song = seededSong(in: app)
        XCTAssertTrue(song.waitForExistence(timeout: timeout))
        song.tap()
        XCTAssertTrue(app.navigationBars[Self.seededSongTitle].waitForExistence(timeout: timeout))
        tapSeededPlay(in: app)
        XCTAssertTrue(app.buttons["player.playPause"].waitForExistence(timeout: timeout))
    }

    func testProjectChartInLandscape() {
        let app = launchApp()
        rotateToLandscapeLeft(app: app)
        tapTab(named: "Projects", in: app)
        app.staticTexts[Self.seededProjectTitle].firstMatch.tap()
        XCTAssertTrue(app.navigationBars[Self.seededProjectTitle].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["project.play"].waitForExistence(timeout: timeout))
    }
}
