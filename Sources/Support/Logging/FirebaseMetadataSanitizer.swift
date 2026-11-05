import Foundation

enum FirebaseMetadataSanitizer {
    static func sanitize(
        _ metadata: [String: String],
        allowedKeys: Set<String>,
        maxValueLength: Int = 100
    ) -> [String: String] {
        metadata.reduce(into: [:]) { result, pair in
            guard allowedKeys.contains(pair.key) else { return }
            guard !AnalyticsMetadataKeys.isBlockedPersonalDataKey(pair.key) else { return }
            let value = String(pair.value.prefix(maxValueLength))
            guard !value.isEmpty else { return }
            result[pair.key] = value
        }
    }
}

enum AnalyticsMetadataKeys {
    /// Song titles, filenames, notes, and paths never leave the device.
    private static let blockedPersonalDataKeys: Set<String> = [
        "title", "artist", "filename", "fileName", "file_name", "notes", "note",
        "subtitle", "path", "url", "email", "name", "query", "message"
    ]

    static func isBlockedPersonalDataKey(_ key: String) -> Bool {
        blockedPersonalDataKeys.contains(key)
    }
}

enum AnalyticsCountBucket {
    static func bucket(_ count: Int) -> String {
        switch count {
        case ...0: return "0"
        case 1: return "1"
        case 2...3: return "2-3"
        case 4...10: return "4-10"
        default: return "11+"
        }
    }
}
