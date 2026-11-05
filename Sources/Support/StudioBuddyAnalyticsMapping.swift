import Foundation

struct StudioBuddyAnalyticsEvent: Equatable, Sendable {
    let name: String
    let parameters: [String: String]
}

enum StudioBuddyAnalyticsMapping {
    /// GA4 recommended name for a cold start. Local event stays `app_launched`.
    static let firebaseNameOverrides: [String: String] = [
        "app_launched": "app_open"
    ]

    private static let allowlistedParameterKeys: Set<String> = [
        "count",
        "tab",
        "format",
        "kind"
    ]

    static func map(_ record: LogRecord, appVersion: String?) -> StudioBuddyAnalyticsEvent? {
        guard record.level >= .info else { return nil }
        guard AnalyticsEventAllowlist.allowed(record.eventName) else { return nil }

        var parameters = FirebaseMetadataSanitizer.sanitize(
            record.metadata ?? [:],
            allowedKeys: allowlistedParameterKeys
        )
        parameters["log_category"] = record.category.rawValue
        if let appVersion, !appVersion.isEmpty {
            parameters["app_version"] = String(appVersion.prefix(100))
        }

        let name = firebaseNameOverrides[record.eventName] ?? record.eventName
        return StudioBuddyAnalyticsEvent(name: name, parameters: parameters)
    }
}
