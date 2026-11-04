import FirebaseAnalytics
import FirebaseCore
import FirebaseCrashlytics
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        guard FirebaseBootstrap.shouldConfigure, !UITestSupport.isRunningUnderTest else {
            return true
        }

        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(FirebaseBootstrap.isAnalyticsCollectionEnabled)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(
            FirebaseBootstrap.isCrashlyticsCollectionEnabled
        )
        return true
    }
}
