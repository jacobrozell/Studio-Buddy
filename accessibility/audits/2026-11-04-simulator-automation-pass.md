# Simulator accessibility pass — 2026-11-04

Automated coverage from `StudioBuddyUIAccessibility` and extended landscape smoke tests.

## Covered in simulator

- Library, song detail, Projects, Settings — WCAG `performAccessibilityAudit`
- Full player — WCAG audit (when opened from seeded catalog)
- Landscape — library, projects, song detail, project chart controls hittable

## Still requires physical device (open)

1. VoiceOver on library filters and BPM range sheet
2. VoiceOver drag reorder on a project running order
3. Full player at accessibility extra-extra-extra-large Dynamic Type
