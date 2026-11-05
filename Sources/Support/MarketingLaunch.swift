import Foundation

/// Debug-only launch scenes for App Store screenshot scripts.
enum MarketingLaunch {
    enum Scene: String {
        case library
        case songDetail = "marketing_song_detail"
        case player = "marketing_player"
        case project = "marketing_project"
        case shareCard = "marketing_share_card"
    }

    static let seedArgument = "-seed_marketing"

    static var isSeedRequested: Bool {
        CommandLine.arguments.contains(seedArgument)
    }

    static var scene: Scene? {
        Scene.allCases.last { ProcessInfo.processInfo.arguments.contains($0.rawValue) }
    }
}

extension MarketingLaunch.Scene: CaseIterable {}
