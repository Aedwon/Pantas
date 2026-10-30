# Web layout: tablet tiers, keyboard hints and Home cards

Implemented on `web/web-layout-r1`. Ready for the lead's independent review.
Nothing staged, committed, pushed, fetched, or switched. No browser or screenshot use.
The worktree was clean at startup.

## Source identity and authority

- HEAD: `cb0490f588f3881cf00b2f84b63c6d390a6e8cea`, plus this unstaged patch.
- Policy and product documents read from origin/main: `fa19ee05743b4ac580fe4e1f646980327ad48628`.
- Startup: AGENTS.md, WORKFLOW.md and SUBAGENTS.md via `git show origin/main:<file>`.
- Product: `2026-10-30-web-layout-design.md`, `pwa-launch/web-layout-board-map.md`, and the October 30 "Tablet layouts, keyboard hints and Home cards" entry in `2026-10-19-pwa-launch-log.md`.
- Local handoff: `/Users/aedwon/Documents/Projects/Pantas/web-design/pantas-handoff/HANDOFF.md`, shared CSS, X_Side and X_More HTML.
- Flutter 3.44.6 stable, framework `ee80f08bbf`, macOS local execution.

Source/test manifest SHA-256: `96a7a893d815471f617a5de2b865b7e0440345f72b4f2ade0571f5afbd6703fe`.
Reproduce by sorting changed/untracked `lib/` and `test/` paths and hashing each
UTF-8 path, NUL, complete file bytes, NUL. This evidence file is excluded.

## Assignment completed

1. Named phone, tablet portrait, tablet landscape and desktop tiers. Native stays
   on the phone presentation. Portrait web routes center the phone presentation
   in a 640px column, bounded by the viewport, with theme-colored gutters.
   Landscape uses desktop content and AppNavBar at 358px wide and 24px above
   the viewport bottom. Main content reserves 100px below it. Focus routes keep
   their existing content insets and shorten their viewport by 72px, placing
   their existing 28px-bottom action bars 12px above navigation. Sidebar and
   global search start at 1280px. Study's own search stays intact.
2. A web-only scope above the router checks `(pointer: fine)` through SDK JS
   interop. HardwareKeyboard reveals every shared key hint after the first
   nonsynthesized key-down. The scope persists across route changes and resizing.
   Shortcut handlers still receive the event. No dependency added.
3. Home already used two separate WebCard surfaces with the required light/dark
   tokens. Preserved that implementation and added explicit surface tests.

No requested tasks omitted. No new board/app behavior conflicts found.
No content, schema, providers, generated code, seed assets or native presentation
were changed. Focus routes do not subscribe to sidebar-only profile providers.

## Files

- `lib/app/web_route_shell.dart`
- `lib/core/ui/web/web_components.dart`
- `lib/core/ui/web/web_keyboard_hints.dart`
- `lib/core/ui/web/web_layout.dart`
- `lib/core/ui/web/web_layout_theme.dart`
- `lib/core/ui/web/web_pointer_stub.dart`
- `lib/core/ui/web/web_pointer_web.dart`
- `lib/features/shell/presentation/web_shell.dart`
- `test/core/ui/web/web_responsive_test.dart`
- `test/features/home/presentation/web/home_cards_test.dart`
- `test/features/shell/web_responsive_shell_test.dart`

The new pointer adapters and hint scope implement the requested web input rule.
The three new test files cover the required boundaries, route/shell structure,
actual focused-route bar spacing, coarse/fine pointer states, shortcut delivery,
hint persistence after child replacement, and separate light/dark Home cards.
Existing tests were not edited. This evidence file records worker completion;
the lead owns shared status, independent review, integration and acceptance.

## Verification

Broader affected checks before the final gutter/provider-scope adjustment:

```text
flutter test test/core/ui/web test/features/shell test/features/home/presentation/web test/app test/features/assessment test/features/quiz/presentation test/features/mock_exam/presentation test/features/lesson/presentation
01:28 +1252: All tests passed!
```

Final checks on the exact source/test manifest above:

```text
flutter test test/core/ui/web/web_responsive_test.dart test/features/shell/web_responsive_shell_test.dart test/features/home/presentation/web/home_cards_test.dart test/app
00:11 +129: /Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1/test/app/router_redirect_test.dart: settings detail routes build
00:11 +130: /Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1/test/app/router_redirect_test.dart: /legal/privacy route builds real legal page
00:11 +131: /Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1/test/app/router_redirect_test.dart: age gate passed, invalid persisted exam id → onboarding picker
00:11 +132: All tests passed!
exit: 0
```

```text
flutter analyze
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 4.1s)
exit: 0
```

```text
dart format --output=none --set-exit-if-changed lib test
Formatted 1647 files (0 changed) in 1.84 seconds.
exit: 0
```

```text
dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK
exit: 0
```

```text
dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK
exit: 0
```

```text
flutter build web --release
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 11368 bytes (99.3% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 13660 bytes (97.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             39.7s
✓ Built build/web
exit: 0
```

`git diff --check` is clean. The index is unchanged.

## Findings, recovery and limits

- Initial parallel Dart checks collided while rewriting shared native build-hook
  libraries. Both were rerun sequentially and passed. Final gates ran sequentially.
- The new focused-route test initially omitted the app theme. Added the real
  theme to its harness, then reran the final checks successfully.
- Release build warns that CupertinoIcons fonts are referenced but not bundled.
  The build completes. This patch adds no icon references or dependencies.
- No unresolved stop condition. No unrelated failing tests observed.
- No visual acceptance, browser/device input checks, native builds or full-suite
  claim. Aedwon owns visual checking. The lead owns independent review.

## Review-finding fixes, October 30

Both findings accepted and fixed. No rejected findings or new behavior conflicts.
The initial dirty work was preserved. This section supersedes the earlier final
manifest and verification for the amended source.

- P2: `WebKeyHint` distinguishes keyboard labels from other chip instructions.
  Account's "Click to copy" opts out of keyboard visibility.
- P3: button hint visibility controls its spacer and right padding too.
- Added a widget regression for touch copy instructions, equal button sizes with
  hidden hints, and hint restoration after a hardware key. Confirmed failure on
  the missing copy instruction before applying the fix.
- Files edited in this follow-up: `lib/core/ui/web/web_components.dart`,
  `lib/features/settings/presentation/pages/account_page.dart`,
  `test/core/ui/web/web_responsive_test.dart`, and this evidence file.

HEAD remains `cb0490f588f3881cf00b2f84b63c6d390a6e8cea`.
Policy origin/main: `6ca0bf7fc0893b6da4de3143127a87241d17c35c`.
Source/test manifest SHA-256, using the method above:
`1acd2a5feb957abc335fbe2294f650499e96293eccdf4d599126006334875420`.

Actual completed verification summaries (all exit 0):

```text
flutter test test/core/ui/web test/features/shell test/features/home/presentation/web test/features/settings test/app
00:43 +692: All tests passed!

flutter analyze
No issues found! (ran in 7.8s)

dart format --output=none --set-exit-if-changed lib test
Formatted 1647 files (0 changed) in 3.02 seconds.

dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK

dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK

flutter build web --release
Compiling lib/main.dart for the Web...                             32.6s
✓ Built build/web
```

The release build retains the previously reported missing CupertinoIcons font
warning. `git diff --check` passes. No browser, screenshots, native builds or
visual acceptance. Nothing staged, committed, pushed, fetched or switched.
No requested fixes or verification commands left undone. Lead review remains.
