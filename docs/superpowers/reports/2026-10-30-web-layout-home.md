# Home wide web layout handoff

Date: October 30, 2026. Implementor handoff for lead review. Nothing is staged,
committed, pushed, fetched, or merged. No branch was changed.

## Source and instructions

- Worktree: `/Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1`
- Branch: `web/web-layout-r1`
- HEAD: `36064db79d1ff2e6adcb73e8c932a328e3416243`
- Policy read with `git show origin/main`: AGENTS.md, WORKFLOW.md, SUBAGENTS.md.
- Policy revision: `245edecd31902824c8a97daaaa0458c5f4415c7b`.
- Product scope: `docs/superpowers/specs/2026-10-30-web-layout-design.md` and
  board-map Home sections, Main, X_Perf, X_More, DK_Home, and L_PlanSlow.
- Visual source: local handoff HANDOFF.md, Home boards, and shared pantas.css.
- The existing layout helper remains the switch: web and width at least 1024.
- Source digest below covers the sorted changed/new lib and test paths. Hash
  input is UTF-8 path, NUL, file bytes, NUL for each file.

Source SHA-256: `f9b9dc64f6892752583006ec8e34d68f358a0b5e8dc37658fa0d03b33a8d7431`

## Tasks completed

1. Main, HM_Free, and DK_Home: header, Sunday-first week and calendar chip,
   Today and performance columns, More rows, natural-width actions, web tokens.
2. Checklist states: start, mid-day, done, advanced, advance again, resume,
   long titles, many lessons, mock day, and the combined busy-day board.
   Read titles use secondary text. Up next has its own tag. Long titles truncate
   and expose their full text in a tooltip.
3. Quiet states: before assessment, exam day, exam passed, no content, nothing
   due, review-only, day off, review week, and last study day. Day notes render
   under the greeting for return after a break, carry-over, and moved mocks.
4. Notices: folded, no date, month only, trial, Pro welcome, and service message.
   Existing priority, dismissal, saving, retry, routes, and provider data remain.
5. Date dialogs: month list beside a Sunday-first calendar, required-day mode,
   disabled past days, natural-width Cancel/Save, and Enter to save.
6. Lessons, reviews, and new-question drawers: 440px at the browser's right edge,
   independently scrolling contents, lesson groups by subject, bottom action,
   Enter to start, Escape/close/barrier to dismiss. The root overlay covers the
   sidebar and the shell's padding.
7. Loading shapes appear after 300ms. The header, Today, More placeholder, and
   performance placeholder have wide layouts. Dark mode uses foundation tokens.
8. Added 89 wide/state/regression tests across the two new test files, including
   light and dark at 1440, narrow web, and native presentation at wide widths.

No SKIP, NEW-FEATURE, Wrapped, or MOTION boards were added. No new routes,
providers, dependencies, schemas, seeds, or generated code were introduced.

## Existing behavior and data differences retained

- The prepaid web trial says the student will not be charged. See Pro and Got It
  remain its actions. No board price or store-charge promise was copied.
- Exam labels and mock durations come from the active exam and existing data.
  No UPCAT sample data or additional exam offering was introduced.
- Home keeps the current absence of performance and More before assessment and
  when content is unavailable. An empty measured performance card stays hidden.
  The assessment board's sample placeholder subjects were not fabricated.
- Subjects without answers remain hidden. The overall score uses the supplied
  overall totals when present, including answers outside displayed subjects.
- Advance appears only with the existing permission. Today counts, lesson
  membership, review sessions, moved mocks, and day notes use existing data.
- Aggregate Today time estimates shown in the comps have no field in HomeTodayData
  or TodayQuestionWork. They were omitted. Lesson minutes and published mock
  duration still use their existing data sources.
- Resume/Continue Lesson keeps the app's existing lesson-details step and guarded
  launch. The board's direct-reader prototype link did not replace that flow.
- The month-only notice retains inline day selection and Save. Pick the Day also
  opens its required-day dialog. Existing notice wording stays intact.

## Files touched

- `lib/core/ui/components/half_ring_gauge.dart`
- `lib/core/ui/web/web_components.dart`
- `lib/features/home/presentation/home_tab.dart`
- `lib/features/home/presentation/home_today_screen.dart`
- `lib/features/home/presentation/widgets/home_exam_date_sheet.dart`
- `lib/features/home/presentation/widgets/home_exam_day.dart`
- `lib/features/home/presentation/widgets/home_masthead.dart`
- `lib/features/home/presentation/widgets/home_notice_strip.dart`
- `lib/features/home/presentation/widgets/home_performance_card.dart`
- `lib/features/home/presentation/widgets/home_performance_section.dart`
- `lib/features/home/presentation/widgets/home_state_card.dart`
- `lib/features/home/presentation/widgets/home_today_checklist.dart`
- `lib/features/home/presentation/widgets/home_web_layout.dart`
- `test/features/home/presentation/web/home_header_wide_test.dart`
- `test/features/home/presentation/web/home_wide_test.dart`

The two shared component changes were needed to reuse the foundation:
`WebRow` gained optional title color and suffix fields for read/Up next states.
`HalfRingGauge` gained opt-in Home web geometry (224x118, 14px arc, 48px figure).
Existing callers retain their previous defaults and geometry.
The new report is this file. No existing spec or plan was edited.

## Verification evidence

Full local logs: `build/verification/web-layout-home/` (build output, not staged).

`flutter analyze`:

```text
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 13.1s)
```

`dart format --output=none --set-exit-if-changed lib test`:

```text
Formatted 1590 files (0 changed) in 2.34 seconds.
```

`dart run tool/check_layering.dart`:

```text
Running build hooks...Running build hooks...check_layering: OK
```

`dart run tool/check_no_ai_attribution.dart`:

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

Focused suite:

```sh
flutter test test/features/home test/app test/core/ui/web \
  test/core/ui/components/half_ring_gauge_test.dart \
  test/core/ui/components/half_ring_gauge_quiz_count_test.dart \
  test/core/ui/components/mock_gauge_reveal_test.dart
```

```text
00:36 +591: All tests passed!
```

After the final equivalent date-label refactor, the wide tests and unchanged
native date-sheet tests were also rerun:

```sh
flutter test test/features/home/presentation/web \
  test/features/home/presentation/widgets/home_exam_date_sheet_test.dart
```

```text
00:02 +92: All tests passed!
```

`flutter build web --release`:

```text
Compiling lib/main.dart for the Web...                             30.0s
✓ Built build/web
```

All commands above exited 0. The release build reported a missing
`packages/cupertino_icons/CupertinoIcons` font-family warning. It also printed
its successful Wasm dry-run notice. The release artifact was produced.

## Findings and remaining acceptance

- No unresolved implementation stop condition remains. No unrelated existing
  test failure was found in the requested focused scope.
- The missing aggregate time estimate data and retained behavior differences are
  listed above for the lead. No substitute figures were created.
- Independent review belongs to the lead. This is an implementor handoff.
- Visual acceptance belongs to Aedwon. No screenshots, browser control, device
  test, or signed-in browser smoke test was performed.
- The full repository test suite was not run. The requested focused Home/app
  suite and the affected shared component tests were run.

## Review fixes, October 30

All four P2 findings were accepted and fixed. None were rejected.

- Today uses `todayFraction` for its 34px progress ring and its white completed
  check. The provider can keep reporting `WeekDayState.today` after completion.
- Add Exam Date stays 560px. Pick the Day uses 440px. Close shares the title's
  vertical space. The footer puts the selected date and measured days from today
  beside Cancel and Save.
- Exam-passed actions share a horizontal row. Switch Exams uses the foundation's
  white outlined button variant.
- The dark checklist footer uses the card surface, #1F1F1F.

Files changed in this correction pass: `home_tab.dart`, `home_exam_date_sheet.dart`,
`home_masthead.dart`, `home_state_card.dart`, `home_today_checklist.dart`,
`home_web_layout.dart`, both existing wide test files, and this report.
All other existing uncommitted work was preserved. No mobile presentation branch
was changed. No spec, plan, provider, generated code, or seed was changed.

Policy remains `245edecd31902824c8a97daaaa0458c5f4415c7b`.
New source SHA-256, using the same path/NUL/bytes/NUL method above:
`4dfd6c19131f7ca99f026148558c18826ab9b58bc908a85df3af784e4023c32d`.
Earlier verification evidence above describes the earlier source digest.
Current logs are in `build/verification/web-layout-home-fixes/`.

Regression tests were run before fixes and failed on missing progress, vertical
exam-passed actions, and missing date-distance text. After fixes, light and dark
checks also cover completed today, dialog widths and close placement, white
button variant, and the exact dark footer color.

Current gate output (all exit 0):

```text
flutter analyze
No issues found! (ran in 18.2s)

dart format --output=none --set-exit-if-changed lib test
Formatted 1590 files (0 changed) in 3.46 seconds.

dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK

dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK

flutter test test/features/home test/app test/core/ui/web test/core/ui/components/half_ring_gauge_test.dart test/core/ui/components/half_ring_gauge_quiz_count_test.dart test/core/ui/components/mock_gauge_reveal_test.dart
00:38 +591: All tests passed!

flutter test test/features/home/presentation/web test/features/home/presentation/widgets/home_exam_date_sheet_test.dart
00:03 +92: All tests passed!
```

The final 92-test run followed analyzer-only comma and const fixes. No unrelated
failure or unresolved stop condition occurred. Browser, screenshot, device, and
visual acceptance checks remain unperformed as instructed. Lead review remains
pending. Nothing was staged, committed, pushed, fetched, merged, or switched.

Release build also exited 0:

```text
flutter build web --release
Compiling lib/main.dart for the Web...                             34.5s
✓ Built build/web
```

The existing missing CupertinoIcons font-family warning remains. Wasm dry run
succeeded. `git diff --check` exited 0.
