import FirebaseCrashlytics
import Foundation

struct FirebaseCrashlyticsLogSink: LogSink {
    var appVersion: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String

    func write(_ record: LogRecord) {
        guard FirebaseBootstrap.shouldConfigure, FirebaseBootstrap.isCrashlyticsCollectionEnabled else { return }

        if let error = FirebaseCrashlyticsEventMapping.nonFatalError(for: record, appVersion: appVersion) {
            Crashlytics.crashlytics().record(error: error)
        }

        if record.level >= .info {
            Crashlytics.crashlytics().log(
                FirebaseCrashlyticsEventMapping.breadcrumb(
                    category: record.category,
                    eventName: record.eventName
                )
            )
        }
    }
}
