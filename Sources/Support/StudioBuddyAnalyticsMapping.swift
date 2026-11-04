import Foundation

enum StudioBuddyAnalyticsMapping {
    private static let allowlistedParameterKeys: Set<String> = [
        "count",
        "tab",
        "format"
    ]

    static func firebaseParameters(
        eventName: String,
        category: LogCategory,
        metadata: [String: String]?
    ) -> [String: Any]? {
        guard AnalyticsEventAllowlist.allowed(eventName) else { return nil }

        var parameters: [String: Any] = [:]
        if let metadata {
            for key in allowlistedParameterKeys {
                guard let value = metadata[key], !value.isEmpty else { continue }
                parameters[key] = String(value.prefix(100))
            }
        }
        parameters["log_category"] = category.rawValue
        return parameters
    }
}
