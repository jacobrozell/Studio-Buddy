import Foundation

enum UITestSupport {
    static let disableFirebaseAnalytics = "-disable_firebase_analytics"

    static var isRunningUnderTest: Bool {
        ProcessInfo.processInfo.arguments.contains(UITestLaunch.resetArgument)
            || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
