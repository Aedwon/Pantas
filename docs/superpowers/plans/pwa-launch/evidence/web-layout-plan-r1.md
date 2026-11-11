# Plan wide web layout

October 30, 2026. Implemented on `web/web-layout-r1` for lead review.
No staging, commits, fetches, pushes, branch switches, screenshots, or browser use.
Initial worktree was clean. Existing tests remain unchanged.

Policy: AGENTS.md, WORKFLOW.md, SUBAGENTS.md read with `git show origin/main`.
Policy commit: `245edecd31902824c8a97daaaa0458c5f4415c7b`.
Source HEAD: `65a37229da0d374ce6d41c7f8015797d2a61c346`.

Controlling documents: origin/main's 2026-10-30-web-layout-design.md and
pwa-launch/web-layout-board-map.md, local pantas-handoff/HANDOFF.md,
PL_* board HTML, and web/shared/pantas.css.

## Completed scope

1. PL_Plan, PL_Free: Today and Coming Up on the left. History on the right.
   Free shows Today and the exam. Its right column retains the Pro invitation
   and the existing paused entitlement presentation. Stored plan data and
   stored history text are used without sample dates, exams, or numbers.
2. PL_Week, PL_WeekCustom: the week occupies the right column. Selected week
   is highlighted. Rest days are dimmed and inert. The study-days label stays
   provider-backed. Change opens the existing exam settings page on wide web.
   Escape and Close return to the previous page.
3. PL_Day: the day occupies the right column. Lessons expose Read. Future
   questions have no invented counts. Read lessons show their saved state.
4. PL_DayRead: a 620px reader drawer uses the existing LessonPage, content,
   ownership boundary, progress tracking, read marking, and save errors.
   Done/Enter, Close/Escape, and the scrim dismiss the drawer. The app routing
   layer supplies the reader composition callback, preserving feature layering.
5. PL_DayPast: past dates in the wide Home week strip open a read-only 400px
   popover. Its lesson rows do not launch reading. Completion counts come from
   the stored day. Escape and outside click dismiss it.
6. PL_History, PL_HistoryEnd: See more opens a full History page within /plan.
   It has a back action, a 720px column, stored reasons, pagination, retained
   data during loading, retry, and the end line. The board map permits a pane.
   No new URL is added, preserving the existing route inventory test unchanged.
7. PL_Error: wide error card and Try Again. Loading retains the shared delayed
   loading behavior. L_PlanSlow depicts the first daily plan on Home; the
   existing HomeWebLoading already provides that presentation and 300ms delay.
   No dedicated DK_Plan board exists. All new layouts use shared dark tokens.

Only context.wideWeb enables these presentations. Native and narrow web retain
existing presentation branches. No providers, schema, seeds, generated files,
content, dependencies, or existing tests were changed. No motion boards built.
Performance/PF_* is the separately implemented results area, not this PL_* task.

## Preserved approved behavior and differences

- Done closes the reader. Existing end-of-content and reading-time checks still
  decide when a lesson is marked read. The board's immediate completion on Done
  is not used to bypass that existing behavior.
- History copy, exam labels, dates, question counts, and plan nodes come from the
  app. Board sample UPCAT lessons and inferred history explanations are not
  substituted for stored facts.
- Week rings remain empty when no measured week completion fraction exists in
  the existing plan view. No fraction is invented from the sample board.
- History uses a full-page pane under /plan. Its Back action returns to the
  columns. A first implementation added /plan/history; the unchanged route
  inventory test rejected it. The board-map-approved pane resolves that conflict.

## Files touched

- lib/features/home/presentation/plan_web.dart: new wide plan/frame/history UI.
- lib/features/home/presentation/plan_page.dart: presentation fork only.
- lib/features/home/presentation/plan_day_page.dart: wide day/week presentations.
- lib/features/home/presentation/plan_screen.dart: pane composition, history,
  popover, and reader callback using existing providers and launch guard.
- lib/features/home/presentation/widgets/home_masthead.dart: wide past-day entry.
- lib/features/lesson/presentation/lesson_page.dart: optional Plan drawer
  presentation and closing callbacks, including loading/error states.
- lib/app/routes/home_routes.dart: inject the reader-drawer composition callback.
  Route paths are unchanged.
- test/features/home/presentation/plan_web_test.dart: 1440px light/dark plan,
  Free gate, week/rest/keyboard, future/past day, History, loading/error/retry.
- test/features/home/presentation/plan_reader_web_test.dart: 1440px light/dark
  real provider-backed Plan reader and Enter/Escape dismissal.
- This evidence file and docs/ui-audit.md: implementation/verification status.

## Verification

The first wide Plan test failed on the existing implementation because WebCard
and side-by-side History were absent. It passed after the presentation fork.
An initial layering check rejected direct Home-to-Reader presentation imports.
Composition moved to the app layer. No architecture exception was added.

Broad affected-area check:
`flutter test test/features/home/presentation test/features/lesson/presentation test/app`

```text
01:46 +732: All tests passed!
```

Final amended-source checks and source hashes are recorded below.

## Review and acceptance

Implemented and self-checked. Lead review and Aedwon's visual acceptance remain
pending. No independent review or visual acceptance is claimed. No emulator,
real browser, screenshot, protected-content build, or full repository test suite
was run. The assigned focused areas plus test/app were run.

## Final amended-source evidence

Flutter 3.44.6 (ee80f08bbf), Dart 3.12.2, macOS.

`flutter analyze`

```text
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 10.3s)
```

`dart format --output=none --set-exit-if-changed lib test`

```text
Formatted 1636 files (0 changed) in 5.72 seconds.
```

`dart run tool/check_layering.dart`

```text
Running build hooks...Running build hooks...check_layering: OK
```

`dart run tool/check_no_ai_attribution.dart`

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

`flutter test test/features/home/presentation/plan_web_test.dart test/features/home/presentation/plan_reader_web_test.dart test/features/home/presentation/plan_day_page_test.dart test/features/home/presentation/plan_page_test.dart test/features/home/presentation/plan_screen_test.dart test/app`

```text
00:32 +149: All tests passed!
```

### Final source identity

SHA-256 for each changed source/test file:

```text
6e1fe55a244c9faa296a864d04768dfda2ea35180c898efea2eb0dc78e32e7c4  lib/app/routes/home_routes.dart
52a809c41c5516a6dd76b7b5662e70641eabdc4ecf9aba09da1f00c4e7e42d39  lib/features/home/presentation/plan_day_page.dart
4e41507995f510091ce2a6f04a7a7187a85b98101f5a0bc10d5ccc2d73a07f3a  lib/features/home/presentation/plan_page.dart
7dc66d5664ebdf51bc3772292fa95742dc9288d3dd154b182eab5382acf99068  lib/features/home/presentation/plan_screen.dart
9e87d3cc66800204b4c2f05b6eeb25f5a463a8bfafdd4d5913395770bfd87331  lib/features/home/presentation/plan_web.dart
d5db86148ec27bf5cfd5497024be48103016664a7e3cedae0dd69eba819b2a83  lib/features/home/presentation/widgets/home_masthead.dart
c7ec6c7e4b6651a8c6d3954141f173fa62339229d83c5e2b2e1cf6f6cc568a1d  lib/features/lesson/presentation/lesson_page.dart
927c06fa7915c4b9754ac60d1950932ec11f39e0d910022ff0d7362cc247aa8c  test/features/home/presentation/plan_reader_web_test.dart
3a8865f4e6fbb485846eafc2d5b5ce216b35e7ff72c6a11cb02ddc223a063e8b  test/features/home/presentation/plan_web_test.dart
```

Existing tracked tests: `git diff --name-only -- test` returned no paths.

### Release build

`flutter build web --release`

```text
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 13660 bytes (97.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 11368 bytes (99.3% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             86.5s
✓ Built build/web
```

Build succeeded. It reports a missing CupertinoIcons font-family warning.
No Cupertino icons, font declarations, or dependencies were added by this task.
Wasm dry run succeeded. No browser runtime check or artifact publication occurred.

## Review corrections, October 30

This section supersedes the earlier pane decision and verification identity.
Policy read from origin/main at 245edecd31902824c8a97daaaa0458c5f4415c7b.
All five review findings accepted:
- History now pushes /plan/history. Back returns to the preceding Plan columns.
- Wide Today goes to /home from Plan, week, or day. Narrow behavior is preserved.
- Week lesson titles wrap through an opt-in on the shared WebRow.
- Unread lessons, reviews, and new questions show progress circles. Stored completed
  question groups show checks. Saved read lessons retain their checked indicator.
- The reader footer names the scheduled weekday from LessonDayContext.

Additional file: lib/core/ui/web/web_components.dart, to extend the shared row
without changing its default behavior. Regression tests cover navigation, long
titles, partial and complete days, and Tuesday footer copy at 1440 in both themes.

The required History route conflicts with the unchanged exact route inventory in
test/app/router_paths_preserved_test.dart. The spec explicitly permits PL_History
as a new route. That test was preserved. Lead resolution remains required.
No finding rejected. No staging, commits, branch changes, fetch, screenshots,
browser operations, or generated source changes.

Fresh automated evidence:
- Broad Home and Lesson presentation plus test/app: +731 -1, Some tests failed.
  Sole failure: route split preserves W1 paths and approved quiz additions.
- Plan light/dark regression suite: +18, All tests passed!
- Format: Formatted 1636 files (0 changed).
- Layering: check_layering: OK.
- Attribution: check_no_ai_attribution: OK.
Analysis and release build results follow after completion.
Visual acceptance remains with Aedwon. No browser runtime check performed.

Final checks after review corrections:
```text
flutter analyze
No issues found! (exit 0)

dart format --output=none --set-exit-if-changed lib test
Formatted 1636 files (0 changed) in 2.59 seconds.

dart run tool/check_layering.dart
check_layering: OK

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK

flutter build web --release
Wasm dry run succeeded.
Compiling lib/main.dart for the Web... 83.6s
✓ Built build/web
```

Build retains the existing missing CupertinoIcons font warning.
Final analyzer fixes added trailing commas only to new tests. No behavior changed.
Broad test run and regression results above remain applicable.

Files edited in this correction pass:
- lib/app/routes/home_routes.dart
- lib/core/ui/web/web_components.dart
- lib/features/home/presentation/plan_screen.dart
- lib/features/home/presentation/plan_day_page.dart
- lib/features/lesson/presentation/lesson_page.dart
- test/features/home/presentation/plan_web_test.dart
- test/features/home/presentation/plan_reader_web_test.dart
- docs/ui-audit.md
- this evidence record

Final correction source SHA-256:
```text
a51f1b8f261f0c801581ecdfe8c73b02fa30d100ec2966db6ad464da8ace82c0  lib/app/routes/home_routes.dart
fab6a8ce1c0b63d371a79e2d39184b5acffc5f27d61b029e35960a011298731b  lib/core/ui/web/web_components.dart
b7d629073e1dc61998e4355594128aa6737c567efbbc1a5c36d34f4fbbf44221  lib/features/home/presentation/plan_screen.dart
2aeb33456b4d272e68597ea7efbe2850792d887308ee3f85cd5c9246b522068c  lib/features/home/presentation/plan_day_page.dart
44087a47446121515274766dd1bd2c33f2c73b7d554dfa3ac2c0b5fba4438df3  lib/features/lesson/presentation/lesson_page.dart
b70395c27966fd91718758ca35fc195317742a1ad98dda9f82b6c832da299ca0  test/features/home/presentation/plan_web_test.dart
6b355b11bc28b0cc01a0c30c70d67fe484d377dc2059e9876446e18702d60df2  test/features/home/presentation/plan_reader_web_test.dart
```
