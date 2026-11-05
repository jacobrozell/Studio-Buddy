# Telemetry — Studio Buddy

Feature code calls `AppLog.shared` only. Never call Firebase Analytics or Crashlytics from a screen or service.

Pattern matches Puzzle Buddy: one logger, an allowlist, Release-only collection, and breadcrumbs that are `[category] eventName` with no free-text message.

## Firebase Analytics (GA4)

| Local event | Firebase name | When | Parameters |
|-------------|---------------|------|------------|
| `app_launched` | `app_open` | Cold start | — |
| `main_tab_presented` | same | Root tabs appear | — |
| `tab_selected` | same | Library or Projects | `tab` |
| `song_imported` | same | New songs saved | `count` bucket |
| `project_created` | same | New project saved | `kind` |
| `share_card_exported` | same | User taps Share Image | `format` |
| `songs_merged` | same | Versions moved onto one song | `count` bucket |
| `share_card_render_failed` | same | PNG render failed | `format` |
| `catalog_save_failed` | same | SwiftData save failed | — |

Every event also sends `log_category` and `app_version`.

Allowed parameter keys: `count`, `tab`, `format`, `kind`. Titles, artist names, filenames, notes, and paths are dropped even if a call site passes them.

`count` is a bucket (`1`, `2-3`, `4-10`, `11+`), not a raw total.

## Crashlytics

Info and above write a breadcrumb `[category] eventName`. The message stays in the local console log.

These errors also record a non-fatal:

| Event | Code |
|-------|------|
| `catalog_save_failed` | 2001 |
| `share_card_render_failed` | 2002 |

## Collection

Release builds send telemetry when a real `GoogleService-Info.plist` is bundled. Debug stays off unless launched with `-enable_analytics` or `-firebase_analytics_debug`. `-disable_analytics` and UI tests stay off.

See [firebase-setup.md](firebase-setup.md).
