# Study and reader wide web layout: worker handoff

Date: October 30, 2026.
Branch: `web/web-layout-r1`.
Source base: `863a388e9cee19b259cd76198607ac7950d4bd26`.
Policy read with `git show origin/main`: `245edecd31902824c8a97daaaa0458c5f4415c7b`. No fetch performed.
Changed lib/test identity: `14086c46bd50124d4eb47e71255eae2deac04696439d81dbeff61dd70a64346c` (sorted path, NUL, bytes, NUL).
Initial worktree was clean. Nothing was staged, committed, pushed, fetched, or switched.

## Assignment completed

1. Study: W_Study split map and selected topic; SD_MapEmpty, SD_NoLessons,
   SD_Loading, SD_Error, SD_NoExam. Loading waits 300 ms and honors reduced motion.
2. Search: SD_SearchRecent, SD_Search, SD_NoMatch. Ctrl K opens an overlay over
   the current sidebar or focus route. Arrow keys select; Enter opens; Esc closes.
   Existing search providers supply titles, snippets, highlighted matches and recents.
3. Bookmarks: BM_Open, BM_Order, BM_Custom, BM_Edit, BM_Removed, BM_Empty,
   BM_One, BM_Keyboard, BM_MarkTeal. The drawer is 480 px. It reuses existing
   guarded ordering, removal, Undo, and announcements. Alt arrows reorder rows.
   B bookmarks in the reader. Study lesson rows expose the existing bookmark action.
4. Reader: RD_Focus and RD_Real supply the layout; RD_RealScroll, RD_FocusOpen,
   RD_Contents, RD_Resume, RD_Figure, RD_ImageFail, RD_Error, RD_Plan,
   RD_DayEnd, RD_DayDone, RD_TopicDone, RD_TopicShort are handled as states.
   The column is 680 px at 1440. Its outline uses actual h2 blocks. The current
   lesson menu, measured progress, existing read marking, boundary validation,
   account/exam invalidation, next-lesson activation and persistence remain in place.
   The title follows the 90 px threshold; the bar can hide below 210 px.
   The progress line stays visible. Figure zoom adds + and − on wide web.
5. Tests: 22 new tests cover 1440-wide light and dark layouts, state copy,
   map/topic structure, natural button widths, actual reader-column width,
   search selection, B, Right Arrow, Enter, lesson menus, figures, image failure,
   bookmark counts, ordering, Alt arrows, editing, removal and Undo.

There are no separate L_* or DK_* Study/Reader boards in the map. SD_Loading
supplies this area's loading layout. All new layouts use the foundation's light
and charcoal dark tokens. RD_FocusMotion is deferred. No dedicated motion-board
animation, SKIP board, NEW-FEATURE board, Wrapped entry, schema change or sample
lesson content was added.

## Preserved app behavior and board differences

- The real selected exam and actual lessons supply all content and counters.
  The UPCAT/Circles samples do not replace CSE data. No published or student
  figures were invented. KaTeX remains the math renderer.
- RD_Plan suggests a Reviews handoff. The app's reader advances through the
  supplied day lesson list and then reaches DayFinished. That approved behavior
  remains: Finish today leads to the existing day ending and Home. No review
  destination or due count was fabricated.
- Back labels retain the real entry origin, including Bookmarks, Search, Your plan
  and Your performance. The boards' Study/Home samples do not replace return paths.
- The reader still marks Read through its existing dwell/visibility/end checks.
  Clicking the web next card uses the existing guarded advance. It does not mark
  a lesson read on its own.
- Expired account/exam boundaries retain the existing unavailable-reader behavior.
  Content-load failures retain retry. No expired content is kept for presentation.
- Handoff button heights (44/50) take precedence over 36/42 px board overrides.

## Files touched

- `lib/app/web_route_shell.dart`
- `lib/core/ui/components/content_renderer.dart`
- `lib/core/ui/components/toast.dart`
- `lib/core/ui/web/web_components.dart`
- `lib/features/lesson/presentation/learn_tab_home.dart`
- `lib/features/lesson/presentation/lesson_page.dart`
- `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart`
- `lib/features/lesson/presentation/widgets/ending_content.dart`
- `lib/features/lesson/presentation/widgets/reader_gap.dart`
- `lib/features/lesson/presentation/widgets/web_ending_layout.dart`
- `lib/features/lesson/presentation/widgets/web_lesson_search.dart`
- `lib/features/lesson/presentation/widgets/web_reader_layout.dart`
- `lib/features/lesson/presentation/widgets/web_study_layout.dart`
- `test/features/lesson/presentation/web_bookmarks_test.dart`
- `test/features/lesson/presentation/web_study_reader_test.dart`

The app route-shell change connects global search. The shared renderer change
adds wide reader typography, figure spacing and zoom keys. Toast gains an optional
key hint. Existing web components gain optional radius, title-style and row-padding
arguments so the area can reuse them. Defaults preserve other callers.
No existing test file, provider, repository, seed, generated file or dependency changed.

## Verification

Visual acceptance and independent area review remain with Aedwon and the lead.
No browser, screenshot, emulator or device action was performed. No claim of
visual acceptance is made.

Earlier checks caught missing Right Arrow handling, a missing search label local,
and loading-controller disposal before the 300 ms reveal. These were corrected.
A concurrent Dart hook invocation also failed while codesigning the SQLite dylib.
The final native hook checks ran separately. No unrelated test failure remained.

All final commands below exited 0. The release output is a local build only.

### `flutter analyze` (exit 0)

```text
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 8.0s)
```

### `dart format --output=none --set-exit-if-changed lib test` (exit 0)

```text
Formatted 1596 files (0 changed) in 1.89 seconds.
```

### `dart run tool/check_layering.dart` (exit 0)

```text
Running build hooks...Running build hooks...check_layering: OK
```

### `dart run tool/check_no_ai_attribution.dart` (exit 0)

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

### `flutter test --no-pub test/features/lesson test/app test/core/ui/components test/core/ui/web --reporter expanded` (exit 0)

```text
01:24 +1021: All tests passed!
```

### `flutter build web --release` (exit 0)

```text
Compiling lib/main.dart for the Web...                             29.4s
✓ Built build/web
```

The Wasm dry run also succeeded. The build reports a missing CupertinoIcons font
family warning. No font assets or dependencies were changed. Browser behavior,
visual fidelity and a separate `--wasm` runtime build were not verified.


## Review corrections, October 30, 2026

This section supersedes the earlier candidate identity and verification above.
The worktree already contained the study patch at startup. Those changes were
preserved. No files were staged. No fetch, commit, push, merge, branch switch,
browser action, or screenshot capture was performed.
Policy revision remains `245edecd31902824c8a97daaaa0458c5f4415c7b`.
HEAD remains `863a388e9cee19b259cd76198607ac7950d4bd26` on `web/web-layout-r1`.
Final changed lib/test identity (same sorted-path convention as above):
`80911bd15705dbad08158c3ad0f8d0dac48b9a2a38923f69803b6e27ae595eab`.

All eight findings were accepted and fixed:

1. Bookmark lists reorder only during editing or Custom order. By subject reaches
   its headings. Recent and Oldest show chevrons. Alt arrows still select Custom.
2. Right Arrow also binds at the reader root. The owner supplies the existing
   guarded advance callback. Outline and bookmark focus no longer disable it.
3. Wide figures use a centered card with 40 px padding, 18 px corners, a translucent
   scrim, a dark card edge, and a 14 px caption with zoom hints. Native and narrow
   figures retain the existing viewer.
4. Wide Read and quiz controls share a row. The quiz control aligns right. A rule
   and 28 px top padding precede the row.
5. The lesson control centers on the viewport independently of side controls.
6. Search and reader lesson-menu surfaces use the dark card-edge token.
7. Native widget tests override only the layout helper's platform input. The
   renderer now executes its wide branches. Tests assert the figure card, scrim,
   caption size, zoom keys, and image failure. Full LessonPage tests cover load
   failure and retry, and Home day context through both lessons to DayFinished.
8. Study states use secondary buttons. Error uses a warning icon and regular
   17 px text. No exam uses the existing exam icon. Its color stays neutral under
   HANDOFF's prohibition on red for neutral actions.

No findings were rejected. The preserved app behavior and board differences
listed above remain. No provider, schema, generated code, seed, or dependency
was changed. The layout helper's test override defaults to null. Production
selection still uses the web platform and the 1024 px breakpoint.

Files edited during this correction pass:

- `lib/core/ui/components/content_renderer.dart`
- `lib/core/ui/web/web_layout.dart` (test platform input)
- `lib/core/ui/web/web_tokens.dart` (figure scrim and caption roles)
- `lib/features/lesson/presentation/lesson_page.dart`
- `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart`
- `lib/features/lesson/presentation/widgets/reader_gap.dart`
- `lib/features/lesson/presentation/widgets/web_reader_layout.dart`
- `lib/features/lesson/presentation/widgets/web_lesson_search.dart`
- `lib/features/lesson/presentation/widgets/web_study_layout.dart`
- `test/features/lesson/presentation/web_bookmarks_test.dart`
- `test/features/lesson/presentation/web_study_reader_test.dart`
- This evidence file.

The bookmark regression test failed before the correction because Recent used a
ReorderableListView. The first broad run found one color-token audit failure.
The lightbox colors moved to shared web tokens and existing figure-viewer tokens.
The affected audit, native figure tests, and wide tests then passed:
`00:02 +50: All tests passed!`.

Visual fidelity and browser runtime behavior remain unverified. Aedwon owns the
visual check. The lead owns independent review and commits. No implementation
finding remains open.

Final verification, all commands exited 0:

### `flutter analyze`

```text
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 10.2s)
```

### `dart format --output=none --set-exit-if-changed lib test`

```text
Formatted 1596 files (0 changed) in 2.14 seconds.
```

### `dart run tool/check_layering.dart`

```text
Running build hooks...Running build hooks...check_layering: OK
```

### `dart run tool/check_no_ai_attribution.dart`

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

### `flutter test --no-pub test/features/lesson test/app test/core/ui/components test/core/ui/web --reporter expanded`

```text
01:11 +1027: All tests passed!
```

### `flutter build web --release`

```text
Compiling lib/main.dart for the Web...                             32.5s
✓ Built build/web
```

