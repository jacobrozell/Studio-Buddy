import Foundation

enum FirebaseBootstrap {
    static var shouldConfigure: Bool {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let appID = plist["GOOGLE_APP_ID"] as? String
        else {
            return false
        }
        return !appID.contains("REPLACE_WITH")
    }

    static var isAnalyticsCollectionEnabled: Bool {
        shouldConfigure && isRemoteTelemetryCollectionEnabled
    }

    static var isCrashlyticsCollectionEnabled: Bool {
        shouldConfigure && isRemoteTelemetryCollectionEnabled
    }

    private static var isRemoteTelemetryCollectionEnabled: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-disable_analytics") || arguments.contains("-disable_firebase_analytics") {
            return false
        }
        if arguments.contains("-enable_analytics") || arguments.contains("-firebase_analytics_debug") {
            return true
        }
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
}
