# Studio Buddy — release todo

Status legend: `[ ]` todo · `[x]` done

Build guide: [`../agent-build-checklist.md`](../agent-build-checklist.md) · Roadmap: [`../../ROADMAP.md`](../../ROADMAP.md)

## Phase 16 — release QA

- [ ] **Device smoke** — import → library → playback → mix compare → share card
- [ ] **VoiceOver + AXXXL** — library, song detail, full player
- [ ] **GitHub Pages** — privacy + support URLs verified
- [ ] **App Store Connect** — listing, screenshots, privacy labels
- [ ] **TestFlight upload** — version bump + What to Test notes

## Pre-submit gates

- [x] **SwiftLint / CI green** — unit tests on push (Firebase SPM + schema V1; run `verify-local.sh` on device Mac)
- [ ] **Release-surface audit** — only shipped features in listing copy
- [ ] **Version-aware import** — compare UI smoke on device
