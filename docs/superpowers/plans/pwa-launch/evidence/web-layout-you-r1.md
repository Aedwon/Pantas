# You, bookmarks, and custom quiz wide web layout

October 30, 2026. Implemented in `web/web-layout-r1`. Ready for the lead's
review. Nothing staged, committed, pushed, fetched, or merged. No branch
switches, screenshots, browser control, credential access, seed changes,
generated-code changes, or new dependencies.

Policy read with `git show origin/main:<file>`: AGENTS.md, WORKFLOW.md,
SUBAGENTS.md. Policy revision: 245edecd31902824c8a97daaaa0458c5f4415c7b.
Source HEAD: 9017f056c61f9a9f287a2a2c54cded6d56eeee7b.
Initial worktree: clean. Existing tests were not edited.

Controlling scope: origin/main's 2026-10-30-web-layout-design.md and
pwa-launch/web-layout-board-map.md. HANDOFF.md, the assigned HTML boards,
and pantas.css supplied the presentation. Shared wide-layout helper,
tokens, cards, rows, buttons, segments, keyboard hints, and sidebar reused.

## Completed scope

1. MY_Record, MY_RecordFree, MY_RecordFirst, MY_RecordRest: split totals
   and history, three-column totals, measured accuracy line, first-week
   placeholder, rest-day date omission, and existing mock destinations.
   Wrapped is absent, including when a caller supplies the native extension.
2. MY_TendPro, MY_TendNew, MY_TendFree, MY_TendError: full-width profile,
   two-column findings, measured comparisons, neutral early/Forming/Free
   pictures, working-hour totals, existing Pro/paused behavior, retry.
   MY_Profiles' twelve labels and MY_Pictures are embedded references,
   not new routes. All twelve identities have light/dark widget coverage.
3. L_ProgressSlow: 112px profile placeholder, 140px section placeholder,
   two columns of 180px finding placeholders. Existing LoadingShapes keep
   the 300ms delay and reduced-motion behavior. Record uses the same delayed
   history-loading family. Both screens use wide error cards.
4. CZ_None, CZ_Picker, CZ_TotalTime, CZ_Adjust, CZ_One, CZ_Many,
   CZ_ManyTime, CZ_Short, CZ_RunsShort, CZ_Long: retained the existing wide
   picker and its logic. Corrected the summary to 400px, put its header
   above the card, matched checkbox rounding, tightened length presets into
   a single row, and used a natural-width 50px Start button with Enter.
   Invalid times remain struck out and disabled. Saved counts, adjustments,
   pool caps, mode conversion, and launch callbacks remain unchanged.
5. BM_Open, BM_Order, BM_Custom, BM_Edit, BM_Removed, BM_Empty, BM_One,
   BM_Keyboard, BM_MarkTeal: the committed Study/Reader implementation
   already supplies the right drawer, sort modes, grouping, custom order,
   edit/remove/Undo, empty/single-row states, Alt-arrow movement,
   announcements, Escape/outside dismissal, and B with a toast key hint.
   Retained those source files and tests unchanged. Their automated checks
   passed again. Drawer width is 480px, as specified inline by BM_* boards.
6. Corrected shared route composition so Record and Tendencies highlight
   Home in the existing sidebar. Custom quiz already highlights Quiz.

No dedicated DK_* board belongs to these screens. The new layouts use the
shared charcoal/dark-red tokens and have 1440px light/dark tests. No motion
boards, Wrapped, new features, schema additions, or extra routes were built.
Phone/narrow paths keep the original widgets. AccuracyLine's optional web
presentation defaults off for every existing caller.

## Preserved app behavior and board differences

- Runtime CSE exam names, actual totals, measured figures, available lessons,
  and history replace example UPCAT values. No sample statistics are shipped.
- Tendency headings, findings, confidence, unlock-action wording, and available
  working-hour data still come from the existing provider. Early/forming
  comparisons never reveal their figures. Prerequisite prompts remain text,
  matching existing app behavior; no new mock/review launch flow was invented.
- Custom quiz supports saved phone values beyond the board's preset examples.
  Such a saved value stays visible in the web preset row. The existing
  five-minute time values remain available when already saved.
- Done/Pro destinations, bookmark ordering, selection, persistence, Undo,
  mutation boundaries, and question-allocation rules are unchanged.

## Files touched

- `lib/app/web_route_shell.dart`
- `lib/features/home/presentation/record_page.dart`
- `lib/features/home/presentation/record_screen.dart`
- `lib/features/home/presentation/tendencies_page.dart`
- `lib/features/home/presentation/tendencies_screen.dart`
- `lib/features/home/presentation/widgets/accuracy_line.dart`
- `lib/features/home/presentation/widgets/web_record_layout.dart`
- `lib/features/home/presentation/widgets/web_tendencies_layout.dart`
- `lib/features/quiz/presentation/practice_picker_screen.dart`
- `test/features/home/presentation/web_record_tendencies_test.dart`
- `test/features/quiz/presentation/web_custom_quiz_states_test.dart`

The area-specific layouts are new presentation files. AccuracyLine was extended
instead of duplicating its measured chart and spoken summary. The shared route
composition file was needed for the sidebar selection defect. This evidence
file records the assignment. Specs and plans were not edited.

## Verification

All commands below exited 0. These are actual output tails, not inferred passes.
Source identity for the final code/tests is SHA-256 over sorted paths, followed
by NUL, file bytes, and NUL for each listed source file:

`7eee8948c32439804d5e2efc8a9c1293ce16e05f6296f1568ab54f1c79870a84`

`flutter analyze`

```text
No issues found! (ran in 9.7s)
```

`dart format --output=none --set-exit-if-changed lib test`

```text
Formatted 1618 files (0 changed) in 1.83 seconds.
```

`dart run tool/check_layering.dart`

```text
Running build hooks...Running build hooks...check_layering: OK
```

`dart run tool/check_no_ai_attribution.dart`

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

Focused existing/native and wide MY/CZ tests plus test/app:

```bash
flutter test test/features/home/presentation/record_page_test.dart test/features/home/presentation/record_screen_test.dart test/features/home/presentation/tendencies_page_test.dart test/features/home/presentation/web_record_tendencies_test.dart test/features/quiz/presentation/practice_picker_screen_test.dart test/features/quiz/presentation/web_quiz_picker_test.dart test/features/quiz/presentation/web_custom_quiz_states_test.dart test/app --reporter expanded
```

```text
00:18 +228: All tests passed!
```

After the sidebar correction, reran MY tests, shell tests, and test/app:

```bash
flutter test test/features/home/presentation/web_record_tendencies_test.dart test/features/shell/web_shell_test.dart test/app --reporter expanded
```

```text
00:10 +169: All tests passed!
```

The new CZ state tests are in the first run. The final MY test file has
50 cases, including four added route-composition regression cases. Tests
cover actual callbacks and structure; there are no goldens.

Unchanged bookmarks and reader checks:

```bash
flutter test test/features/lesson/presentation/web_bookmarks_test.dart test/features/lesson/presentation/bookmarks_sheet_test.dart test/features/lesson/presentation/bookmarks_section_test.dart test/features/lesson/presentation/web_study_reader_test.dart --reporter expanded
```

```text
00:07 +102: All tests passed!
```

Existing accuracy chart checks:

```bash
flutter test test/features/home/presentation/widgets/accuracy_line_test.dart --reporter expanded
```

```text
00:00 +5: All tests passed!
```

`flutter build web --release` on the final application source:

```text
Compiling lib/main.dart for the Web...                             32.0s
✓ Built build/web
```

The release build also reported a successful Wasm dry run, normal font
subsetting, and a missing CupertinoIcons font-family warning. This assignment
adds no Cupertino icons and does not change the existing font bundle.

`git diff --check`: exit 0, no output. Nothing staged.

## Findings and limits

- Fixed: Record and Tendencies had no highlighted sidebar tab. Regression
  tests observed activeIndex -1 before the change and 0 after it.
- One parallel native-hook invocation failed while rewriting objective_c.dylib
  with install_name_tool. Serialized reruns of layering and attribution passed.
  No source/cache deletion or package regeneration was used to resolve it.
- Initial new tests failed for missing wide cards/columns and incorrect CZ
  width. Those tests passed after implementation. New loading/error and chart
  assertions also failed before their respective presentation changes.
- No unresolved stop condition. No unrelated test failure was found.
- The full repository suite, device checks, independent lead review, and visual
  acceptance were not performed. The requested focused tests, test/app, static
  gates, and web release build were performed. Aedwon retains visual acceptance.

## Review correction pass, October 30, 2026

This section supersedes the verification identity above for the amended files.
Existing uncommitted work was preserved. No findings were rejected.

1. Pressure bars now represent the complete 0–100% range. Ticks are 0%, 50%, and 100%. The board’s cropped 40–80% example range clipped valid measured scores. Tests cover 85/95% and 20/35% in light and dark.
2. The custom quiz summary uses a pinned sliver beside the scrolling topic tree. It pins at the shell’s 28px top inset. Tests scroll 30 topics in every quiz state and verify the summary position and accessible Start button. The existing stacked fallback remains.
3. The wide accuracy chart draws three gridlines at the board’s relative positions. Line, fill, and endpoint dot share the inset endpoints (10 and 590 at 600px width). Native chart coordinates remain unchanged.
4. The answer-time difference uses a natural-width teal pill, with 12px semibold text, 2px/8px padding, and dark tint tokens.

Files changed in this correction pass:

- `lib/features/home/presentation/widgets/accuracy_line.dart`
- `lib/features/home/presentation/widgets/web_tendencies_layout.dart`
- `lib/features/quiz/presentation/practice_picker_screen.dart`
- `test/features/home/presentation/web_record_tendencies_test.dart`
- `test/features/quiz/presentation/web_custom_quiz_states_test.dart`
- This evidence file.

Policy: `245edecd31902824c8a97daaaa0458c5f4415c7b`. HEAD: `9017f056c61f9a9f287a2a2c54cded6d56eeee7b`.
Correction source/test SHA-256 (sorted path + NUL + bytes + NUL): `36b7ea35af70032f73612df65fa0d01459a4f63a80e1806a1ebe3e6bc279d55b`.

`flutter analyze`, exit 0:

```text
No issues found! (ran in 14.8s)
```

`dart format --output=none --set-exit-if-changed lib test`, exit 0:

```text
Formatted 1618 files (0 changed) in 3.65 seconds.
```

`dart run tool/check_layering.dart`, exit 0:

```text
Running build hooks...Running build hooks...check_layering: OK
```

`dart run tool/check_no_ai_attribution.dart`, exit 0:

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

`Focused MY/CZ/BM tests, accuracy painter tests, and test/app, same paths as the initial evidence plus accuracy_line_test.dart and bookmarks tests`, exit 0:

```text
00:22 +321: All tests passed!
```

`flutter build web --release`, exit 0:

```text
Compiling lib/main.dart for the Web...                             40.1s
✓ Built build/web
```

The tests total 321. Before fixes, new assertions failed for five chart rules, saturated pressure bars, a missing pill, and a summary scrolling above the viewport. A strengthened scroll test initially used a title finder that the sliver removed offscreen; it now locates the persistent scrollable. Final tests pass.

The release build retains the existing missing CupertinoIcons font-family warning. No new dependency, icon bundle, or generated file was added. `git diff --check` passes. Nothing staged, committed, pushed, fetched, or switched. No browser or screenshot use. Full repository tests, device checks, independent review, and visual acceptance remain with the lead/Aedwon.
