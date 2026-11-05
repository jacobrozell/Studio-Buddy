import Foundation

enum FirebaseCrashlyticsEventMapping {
    private static let errorDomain = "com.jacobrozell.studiobuddy.logger"

    /// Stable codes so Crashlytics groups the same failure together.
    static let eventCodes: [String: Int] = [
        "catalog_save_failed": 2001,
        "share_card_render_failed": 2002
    ]

    static func breadcrumb(category: LogCategory, eventName: String) -> String {
        "[\(category.rawValue)] \(eventName)"
    }

    static func nonFatalError(for record: LogRecord, appVersion: String?) -> NSError? {
        guard record.level >= .error, let code = eventCodes[record.eventName] else { return nil }

        var userInfo = FirebaseMetadataSanitizer.sanitize(
            record.metadata ?? [:],
            allowedKeys: ["count", "tab", "format", "kind"]
        )
        userInfo["log_category"] = record.category.rawValue
        userInfo["event_name"] = record.eventName
        if let appVersion, !appVersion.isEmpty {
            userInfo["app_version"] = String(appVersion.prefix(100))
        }
        return NSError(domain: errorDomain, code: code, userInfo: userInfo)
    }
}
