# Studio Buddy — release todo

Status legend: `[ ]` todo · `[x]` done

Build guide: [`../agent-build-checklist.md`](../agent-build-checklist.md) · Roadmap: [`../../ROADMAP.md`](../../ROADMAP.md)

## Phase 16 — release QA

- [ ] **Device smoke** — import → library → playback → mix compare → share card
- [ ] **VoiceOver + AXXXL** — library, song detail, full player
- [ ] **GitHub Pages** — privacy + support URLs verified
- [ ] **App Store Connect** — iPhone 6.7" and iPad 13" screenshots uploaded 2026-11-05. Privacy labels and Duo shots still open
- [ ] **TestFlight upload** — build 5 archive started (Xcode Cloud run 5). What to Test notes still open

## Pre-submit gates

- [x] **SwiftLint / CI green** — unit tests on push (Firebase SPM + schema V1; run `verify-local.sh` on device Mac)
- [ ] **Release-surface audit** — only shipped features in listing copy
- [ ] **Version-aware import** — compare UI smoke on device
