import Foundation
import Testing
@testable import StudioBuddy

@Suite("Analytics mapping", .tags(.unit))
struct AnalyticsMappingTests {
    @Test("Launch maps to app_open and drops song titles")
    func launchOverrideStripsPersonalData() {
        let record = LogRecord(
            level: .info,
            category: .app,
            eventName: "app_launched",
            message: "started",
            metadata: ["title": "Midnight Demo", "count": "1"],
            correlationId: nil
        )
        let event = StudioBuddyAnalyticsMapping.map(record, appVersion: "1.0")
        #expect(event?.name == "app_open")
        #expect(event?.parameters["title"] == nil)
        #expect(event?.parameters["count"] == "1")
        #expect(event?.parameters["app_version"] == "1.0")
        #expect(event?.parameters["log_category"] == "app")
    }

    @Test("Unknown events and debug logs stay off Analytics")
    func dropsUnknownAndDebug() {
        let unknown = LogRecord(
            level: .info,
            category: .ui,
            eventName: "not_a_product_event",
            message: "nope",
            metadata: nil,
            correlationId: nil
        )
        let debug = LogRecord(
            level: .debug,
            category: .app,
            eventName: "app_launched",
            message: "debug",
            metadata: nil,
            correlationId: nil
        )
        #expect(StudioBuddyAnalyticsMapping.map(unknown, appVersion: "1.0") == nil)
        #expect(StudioBuddyAnalyticsMapping.map(debug, appVersion: nil) == nil)
    }

    @Test("Crashlytics non-fatals use stable codes and breadcrumbs omit messages")
    func crashlyticsMapping() {
        let failure = LogRecord(
            level: .error,
            category: .persistence,
            eventName: "catalog_save_failed",
            message: "disk full at /private/secret.mp3",
            metadata: ["title": "Secret"],
            correlationId: nil
        )
        let error = FirebaseCrashlyticsEventMapping.nonFatalError(for: failure, appVersion: "1.0")
        #expect(error?.code == 2001)
        #expect(error?.userInfo["title"] == nil)
        #expect(error?.userInfo["event_name"] as? String == "catalog_save_failed")

        let info = LogRecord(
            level: .info,
            category: .ui,
            eventName: "tab_selected",
            message: "Library",
            metadata: ["tab": "library"],
            correlationId: nil
        )
        #expect(FirebaseCrashlyticsEventMapping.nonFatalError(for: info, appVersion: "1.0") == nil)
        #expect(
            FirebaseCrashlyticsEventMapping.breadcrumb(category: .ui, eventName: "tab_selected")
                == "[ui] tab_selected"
        )
    }
}
