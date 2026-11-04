# Telemetry — Studio Buddy

Feature code calls `AppLog.shared` only. Events are allowlisted in `AnalyticsEventAllowlist`.

## Firebase Analytics (GA4)

Allowlisted events: `app_launched`, `main_tab_presented`, `song_imported`, `project_created`, `share_card_exported`, `songs_merged` (count bucket only).

No song titles, filenames, notes, or audio in parameters.

## Crashlytics

Non-fatal errors can be wired through `AppLog` in future; Release builds collect Crashlytics when Firebase is configured.
