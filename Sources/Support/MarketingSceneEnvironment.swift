import SwiftUI

private struct MarketingSceneKey: EnvironmentKey {
    static let defaultValue: MarketingLaunch.Scene? = nil
}

extension EnvironmentValues {
    var marketingScene: MarketingLaunch.Scene? {
        get { self[MarketingSceneKey.self] }
        set { self[MarketingSceneKey.self] = newValue }
    }
}
