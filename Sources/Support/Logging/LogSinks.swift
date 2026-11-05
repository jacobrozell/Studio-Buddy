import FirebaseAnalytics
import Foundation
import os

protocol LogSink: Sendable {
    func write(_ record: LogRecord)
}

struct CompositeLogSink: LogSink {
    let sinks: [LogSink]

    func write(_ record: LogRecord) {
        for sink in sinks {
            sink.write(record)
        }
    }
}

struct ConsoleLogSink: LogSink {
    private let logger = Logger(subsystem: "com.jacobrozell.studiobuddy", category: "app")

    func write(_ record: LogRecord) {
        let suffix = record.metadata.map { " \($0)" } ?? ""
        let line = "[\(record.category.rawValue)] \(record.eventName): \(record.message)\(suffix)"
        switch record.level {
        case .debug: logger.debug("\(line, privacy: .public)")
        case .info: logger.info("\(line, privacy: .public)")
        case .warning: logger.warning("\(line, privacy: .public)")
        case .error: logger.error("\(line, privacy: .public)")
        case .fault: logger.fault("\(line, privacy: .public)")
        }
    }
}

/// Allowlisted, privacy-safe analytics events routed to Firebase Analytics when configured.
struct AnalyticsLogSink: LogSink {
    var appVersion: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String

    func write(_ record: LogRecord) {
        guard FirebaseBootstrap.shouldConfigure, FirebaseBootstrap.isAnalyticsCollectionEnabled else { return }
        guard let event = StudioBuddyAnalyticsMapping.map(record, appVersion: appVersion) else { return }
        let parameters = Dictionary(uniqueKeysWithValues: event.parameters.map { ($0.key, $0.value as Any) })
        Analytics.logEvent(event.name, parameters: parameters)
    }
}

enum AnalyticsEventAllowlist {
    static func allowed(_ eventName: String) -> Bool {
        allowedEvents.contains(eventName)
    }

    private static let allowedEvents: Set<String> = [
        "app_launched",
        "main_tab_presented",
        "tab_selected",
        "song_imported",
        "project_created",
        "share_card_exported",
        "share_card_render_failed",
        "songs_merged",
        "catalog_save_failed"
    ]
}

struct DefaultAppLogger: AppLogger {
    private let sink: LogSink

    init(sink: LogSink) {
        self.sink = sink
    }

    static func makeForCurrentBuild() -> DefaultAppLogger {
        DefaultAppLogger(
            sink: CompositeLogSink(sinks: [
                ConsoleLogSink(),
                AnalyticsLogSink(),
                FirebaseCrashlyticsLogSink()
            ])
        )
    }

    func log(_ record: LogRecord) {
        var merged = record.metadata ?? [:]
        if let correlationId = record.correlationId {
            merged["correlation_id"] = correlationId
        }
        let payload = LogRecord(
            level: record.level,
            category: record.category,
            eventName: record.eventName,
            message: record.message,
            metadata: merged.isEmpty ? nil : merged,
            correlationId: record.correlationId
        )
        sink.write(payload)
    }
}

enum AppLog {
    static let shared: AppLogger = DefaultAppLogger.makeForCurrentBuild()
}
