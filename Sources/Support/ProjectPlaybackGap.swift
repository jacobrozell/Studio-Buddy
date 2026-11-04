import Foundation

enum ProjectPlaybackGap: Int, CaseIterable, Identifiable {
    case none = 0
    case short = 2
    case medium = 4

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .none: return "No gap"
        case .short: return "2 seconds"
        case .medium: return "4 seconds"
        }
    }

    static let storageKey = "projectPlaybackGapSeconds"

    static var current: ProjectPlaybackGap {
        let stored = UserDefaults.standard.integer(forKey: storageKey)
        return ProjectPlaybackGap(rawValue: stored) ?? .short
    }

    static func save(_ gap: ProjectPlaybackGap) {
        UserDefaults.standard.set(gap.rawValue, forKey: storageKey)
    }
}
