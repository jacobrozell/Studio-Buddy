# Firebase setup — Studio Buddy

Firebase project: `studiobuddy-cd2e2` · iOS bundle id: `com.jacobrozell.mixstack`

## Local

1. Download `GoogleService-Info.plist` from Firebase Console.
2. Copy to the repo root (gitignored).
3. For CI, only `GoogleService-Info.plist.example` is committed.

## Xcode Cloud

Set workflow secret `GOOGLE_SERVICE_INFO_PLIST_BASE64` (base64 of the real plist).  
`ci_scripts/ci_post_clone.sh` writes the file before `xcodegen generate`.

## Debug

Release builds send telemetry when a real plist is bundled. Debug builds stay off unless you pass `-enable_analytics`. UI tests pass `-disable_analytics`.

See [telemetry.md](telemetry.md).
