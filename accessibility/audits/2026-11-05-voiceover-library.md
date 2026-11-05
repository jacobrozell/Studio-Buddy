# VoiceOver pass — Library — 2026-11-05

Simulator accessibility tree, not a device VoiceOver run. Speech, Magic Tap, the escape gesture, and drag reorder were not exercised.

## How this was taken

| Item | Value |
|------|--------|
| Device | iPhone 18 Pro simulator, iOS 27.0 |
| UDID | `51142907-5DF5-4DBE-9891-E47A3DED12EE` |
| Bundle | `com.jacobrozell.mixstack` |
| Launch | Fresh install, then `-ui_test_reset -disable_analytics -ui_test_skip_onboarding -ui_test_seed_catalog` |
| Dump | `idb ui describe-all --json --nested` (companion 1.1.8) |
| Screen | 402 × 874 pt |

`idb ui tap` failed: SimulatorKit is not at `Xcode.app/Contents/Developer/Library/PrivateFrameworks`. Point queries used `idb ui describe-point`. An XCUITest on the same simulator (`testVoiceOverTreeDump`, result Passed) reached the song, Projects, project, and Settings screens. Those trees were not retained in the result log, so this note quotes the Library dump only.

The nested dump omits traits, so `selected` is not in it.

## What a swipe would speak (nested dump, in order)

1. Application, “Studio Buddy”
2. Nav bar group, no label (unique id `Library`), no children in this dump
3. Text, “1 Songs”
4. Text, “1 Mixes”
5. Text, “1 Projects”
6. Button, “All” (46 × 44)
7. Button, “Filters” (id `library.filtersButton`, about 72 × 44)
8. Button, “Idea”
9. Button, “Demo”
10. Button, “Work in Progress” (starts at x=293, wider than the 402 pt screen)
11. Button, “Ready to Mix” (x=448, off the visible width)
12. Button, “Mastered” (off screen)
13. Button, “Released” (off screen)
14. Group, “UITest Song, Studio Buddy QA, 120 BPM, Ready to Mix”
15. Group, “Tab Bar”, no children in this dump

The song group’s custom actions, in order: “Delete”, “Add to Project”, “Favorite”, “Favorite”, “Add to Project”, “Delete”.

## Point queries on the same screen

| Point | Spoken element |
|-------|----------------|
| 24, 110 | Pop up button, “Sort” (`library.sortMenu`) |
| 200, 100 | Button, “Settings” (`settings.button`) |
| 360, 110 | Pop up button, “Add” (`library.addMenu`) |
| 40, 400 | Button, “All” |
| 121, 471 | Text, “UITest Song” |
| 100, 830 and 300, 830 | Group, “Tab Bar” only |

Sort, Settings, and Add are real elements. The nested dump did not list them under the nav bar.

## What failed

- Song row custom actions are duplicated. Each of Favorite, Add to Project, and Delete appears twice.
- Stats are spoken as “1 Songs”, “1 Mixes”, and “1 Projects”.
- The tab bar is one unlabeled group in both the nested dump and point queries. No “Library” or “Projects” button was returned there. A later XCUITest could still activate Projects, so this needs a device swipe before treating the tabs as missing.
- Category chips from “Ready to Mix” onward sit outside the 402 pt width. They are in the tree, so a swipe may still reach them inside the horizontal scroller.

## Still needs a device

- VoiceOver speech, Magic Tap, and the escape gesture
- Whether double-tap on the song group opens the song (the dump’s row is a group; a point query also found inner text “UITest Song”)
- Whether the tab bar buttons are in the rotor
- Drag reorder on a project running order
- Song detail, full player, Projects, and Settings trees (XCUITest reached them; this pass does not quote them)
- Selected state on “All” (not in the JSON dump)
