# W4c implementation evidence

## Assignment and source identity

- Current policy retrieved on the final October 12 resumption: `9e8e029d7edb38859a63aec4e906ed4685ed931b`. The earlier October 12 resumption read `1b42368085918a1cdf6df3e905b156b01387c451`. AGENTS.md, WORKFLOW.md and SUBAGENTS.md read again. Their contents and the W4c plans, amendment spec, traceability and parallel map are unchanged from the prior read. The later restart-log entry concerns the W3 audit and scheduling.
- Prior implementation policy: `da314d1e8bb1d68f617ef50ee0b23aea46ee605b`.
- Read current AGENTS.md, WORKFLOW.md and SUBAGENTS.md. The initial startup read used `56f642543e9c04de7dc673f8d1674c6cc222c4d6`; the user resumed before implementation, so main was fetched again.
- Code base: `cee7a9c55387674787030c722967104705d7bb3a`, branch `web/new-design-w4c-r1`, assigned worktree.
- Plans L2-W4c and L3-W4c, amendment spec, traceability W4c rows, current parallel map and W2 lead rulings read from main. Shared state-pattern notes read from the assigned worktree.
- Design boards and outline/timeline scripts are absent on the code base. Read their exact current main versions from the main checkout without editing it or merging main.
- No application-code freeze was lifted beyond this authorized workstream. No merge or push is authorized.

## Open questions and dependencies

1. Task 1, ST_TopicOpen Today tag: 12 px, weight 600, foreground `#6E6E73`, background `#EDEDF0`. WCAG sRGB contrast is `4.340286685319358:1`, below the binding 4.5:1 text rule. The explicit SearchField exception does not cover this tag. Task 1 is blocked until the lead records a darker text token, a lighter background, or a specific exception. No changed presentation has been implemented.
2. Task 5 depends on W4b Task 3's `LessonDayContext`. It is absent from this code base. No local substitute will be added.
3. Task 7 depends on W4d Task 1's `startLessonQuiz(lessonId)` and `startQuickQuiz()` entry contracts. They are absent from this code base. The existing `startQuickQuizProvider` is a different interface.

4. Task 4: RD_Real draws the eyebrow `EARTH SCIENCE AND ASTRONOMY` only, at 13 px/600 with 0.04em tracking, above the 30 px title. L3 Task 4 asks for a “Subject and topic eyebrow.” The lead must clarify whether the eyebrow stays topic-only as drawn or includes the subject too. No alternative eyebrow has been implemented.
5. Task 8: BM_Edit and BM_ScreenReader draw the enabled drag handles at 20 px, stroke 2, `#AEAEB2` on `#FFFFFF`. This is 2.21:1, below the binding 3:1 rule for meaningful icons. The unchecked circles also use `#C7C7CC`, but W2's explicit `controlOutline` ruling already covers unchecked selection boundaries. That ruling does not cover drag handles. The lead must approve a darker handle token or explicitly exempt this control.
6. Task 6's complete Home/day ending depends on the missing Task 5 day context. Task 9's deletions depend on Tasks 1 and 6; the reader still uses the older plates. Do not delete live callers.

## Task 2: search

Commit: `537d9ef894811c67b9d59c9a4b71b90d290b85d0`. Implemented and task checks pass. Independent acceptance remains with the lead.

Behavior: the W2 search field folds Study over 300 ms using the board's house curve; Cancel clears the query and restores the map. Search includes every lesson of a matching topic in corpus order without duplicate hits. Results show uppercase counts, bold matches, snippets, grouped rows and 15 px tabular minutes. Empty query with no recents shows nothing. Recents show at most three lessons. Result routes identify search as origin.

Shared component extensions authorized by the dispatch:
- `lib/core/ui/components/search_field.dart`: optional `onEditingChanged` lets a screen switch the body when editing starts and ends. `titleInset` defaults to zero; Study uses 4 px inside its 16 px screen gutter to reproduce the 20 px title gutter. ST_Search: title fold and Cancel 300 ms, `Cubic(.3,.9,.3,1)`.
- `lib/core/ui/components/list_row.dart`: optional rich title/subtitle spans, footer, leading widget, title color, value style and vertical padding. Defaults preserve other families. ST_Search: 17/400 title, 13 px topic/snippet, 15 px minutes, 12 px vertical inset. Real keyboard activation remains on W2's InkWell. Tests live beside W2 tests.

Files: those two shared components; lesson search provider; Study page's search call site; search field bar and result widgets; search provider, field bar, results, search board and existing pinned-transition tests; W2 search extension tests; this evidence. No other screen family changed.

Verification, run serially through the Mac relay:
- Issue 9409: initial test failed to compile because ignored generated files were absent. This was setup failure, not the required failing test.
- Issue 9410: `dart run build_runner build --delete-conflicting-outputs`, exit 0, `Built with build_runner/aot in 25s; wrote 2735 outputs.` Generated files remain ignored and uncommitted.
- Issue 9411: three search test files, exit 1, `00:00 +12 -8: Some tests failed.` Topic matching, W2 search field, uppercase headings and no-match copy failed as intended before their implementation.
- Issues 9412 and 9413: prescribed focused check, exit 1. Issue 9412 output was truncated. Issue 9413 captured full output in `.dart_tool/w4c-task2-check.log`: `00:39 +843 -6: Some tests failed.` Five failures came from the replacement search wrapper lacking Material in isolated tests. One old pinned test matched a TextField opacity widget too. Both causes corrected; no unrelated failure was ignored.
- Issue 9414: narrowed regressions, exit 1, `00:01 +9 -1: Some tests failed.` The Cancel test tapped before the newly required 300 ms reveal completed. The test now waits for that reveal.
- Issue 9415: light/dark, 100%/200% board metric tests, exit 1, `00:00 +0 -4: Some tests failed.` Each correctly found 17 px minutes where ST_Search requires 15 px. Shared value-style extension corrects this.
- Issue 9416: `flutter test test/features/lesson test/app/study_route_test.dart test/core/ui --reporter expanded`, exit 0, `00:32 +855: All tests passed!` Full log: `.dart_tool/w4c-task2-check-final.log`.
- Issue 9417: six relevant board and extension tests after making the test surfaces use the actual theme background and tightening the intermediate animation value, exit 0, `00:00 +6: All tests passed!` The title opacity at 150 ms is 0.057725, tolerance 0.001. Tests cover real light/dark contrast, 200% layout and keyboard activation.
- `dart format` on the changed Dart files: exit 0. `git diff --check`: exit 0.

The full Flutter suite has not run; these are the plan's focused checks only.

Task 2 file manifest:

- `docs/superpowers/plans/new-design/evidence/W4c.md`
- `lib/core/ui/components/list_row.dart`
- `lib/core/ui/components/search_field.dart`
- `lib/features/lesson/application/lesson_search_providers.dart`
- `lib/features/lesson/presentation/learn_tab_home.dart`
- `lib/features/lesson/presentation/widgets/search_field_bar.dart`
- `lib/features/lesson/presentation/widgets/search_results.dart`
- `test/core/ui/components/study_search_extensions_test.dart`
- `test/features/lesson/application/lesson_search_providers_test.dart`
- `test/features/lesson/presentation/learn_tab_home_test.dart`
- `test/features/lesson/presentation/search_board_test.dart`
- `test/features/lesson/presentation/search_field_bar_test.dart`
- `test/features/lesson/presentation/search_results_test.dart`

## Task 3: shared states

Implemented with passing focused checks. This evidence is saved in the Task 3 commit. Independent review and the held tasks remain. The prescribed focused command last passed in relay issue 9425: `00:37 +877: All tests passed!`, exit 0. The earlier 9422 run also passed 877 tests before two additional frame/back metrics exposed defects.

Behavior: Study keeps its title on every state, announces loading immediately, delays loading shapes for 300 ms, uses the shared retryable load failure and no-exam picker, and draws the no-lessons Quick Quiz action only in that state. Reader failures and missing lessons keep their back control. Retry re-reads the failed lesson. An advance failure is no longer hidden by the retained previous reader. Reader illustration failures keep the 223 px frame through Retry and expose no expand control while failed or waiting.

Shared extensions authorized by the dispatch:
- `StateView.boardLayout`: ST_Error, ST_NoLessons and RD_Error use the 40 px faint mark, 6 px gaps, 20/700 message at height 1.35 with -0.2 spacing, 36 px side insets and 150 px bottom inset. The secondary action uses a 44 px pill, radius 99, 22 px horizontal inset and 15/600 text. Other callers keep existing defaults.
- `errorFor`: optional approved message, icon and board layout allow RD_Error's exact “Could not load this lesson.” without a feature-local state copy. Defaults and exception privacy remain unchanged.
- `ContentRenderer.readerFigures`: RD_ImageFail uses a 223 px minimum frame, radius 14, 0.5 px separator border, background token, faint 30 px icon, 13 px secondary text and “Try Again” action. It announces its state. Pending and failed images have no expand control. Other screen families retain the default renderer presentation.
- The lesson uses ContentRenderer now because its illustration failure must use the shared variant. Task 4's eyebrow, credits, text scaling, body gutters and remaining figure work are not claimed complete.

Failing-first evidence:
- Issue 9418: state tests before state implementation, exit 1, `00:01 +1 -5: Some tests failed.` All five failures were the missing W4h states/back controls.
- Issue 9419: missing readerFigures constructor parameter, exit 1. This compilation result was not counted as the presentation test.
- Issue 9420: after adding the interface but before its behavior, exit 1, `00:00 +4 -4: Some tests failed.` All four light/dark and 100%/200% cases found the old image failure presentation.
- Issue 9421: focused check, exit 1, `00:33 +861 -4: Some tests failed.` The four image tests read the failure element after Retry removed it. Their contrast checks now run before Retry.
- Issue 9422: focused check, exit 0, `00:33 +877: All tests passed!`
- Issue 9423: new stable-frame and 44 px reader back checks, exit 1, `00:00 +5 -5: Some tests failed.` Retry collapsed the image frame, and the back control was too tall. Both corrected.
- Issue 9424: focused check, exit 1, `00:34 +876 -1: Some tests failed.` Flutter padded the back control's tap area to 48 px. Its tap target now uses the board's 44 px minimum without the added padding and can grow for large text.
- Issue 9425: prescribed focused check, exit 0, `00:37 +877: All tests passed!`
- Issue 9426: analysis initially found 103 issues: 100 missing commas, one unused import, one import-order issue in my changes, and the existing R-21 bookmark onReorder notice. The 102 new style issues were corrected. This also corrects Task 2 formatting in the same owned files; no Task 2 behavior changes.
- Issue 9426: `dart format --output=none --set-exit-if-changed lib test`, exit 0, `Formatted 1402 files (0 changed) in 1.35 seconds.` Layering and attribution both exit 0 with their OK output.

Final verification is recorded below. The one full-suite run preceded a final search-transition correction; the complete prescribed focused checks were repeated after that correction.

Task 3 file manifest (includes Task 2 lint and search-transition corrections):

- `docs/superpowers/plans/new-design/evidence/W4c.md`
- `lib/core/error/state_patterns.dart`
- `lib/core/ui/components/content_renderer.dart`
- `lib/core/ui/components/list_row.dart`
- `lib/core/ui/components/state_view.dart`
- `lib/features/lesson/application/lesson_search_providers.dart`
- `lib/features/lesson/presentation/learn_tab_home.dart`
- `lib/features/lesson/presentation/lesson_page.dart`
- `lib/features/lesson/presentation/widgets/search_field_bar.dart`
- `lib/features/lesson/presentation/widgets/search_results.dart`
- `test/core/ui/components/study_search_extensions_test.dart`
- `test/core/ui/components/study_state_extensions_test.dart`
- `test/features/lesson/presentation/learn_tab_home_test.dart`
- `test/features/lesson/presentation/reader_states_test.dart`
- `test/features/lesson/presentation/search_board_test.dart`
- `test/features/lesson/presentation/search_results_test.dart`
- `test/features/lesson/presentation/search_transition_test.dart`
- `test/features/lesson/presentation/study_map_page_test.dart`
- `test/features/lesson/presentation/study_states_board_test.dart`

Candidate source identity for final checks: HEAD `537d9ef894811c67b9d59c9a4b71b90d290b85d0` plus the staged lib/test diff, SHA-256 `92449b1a48373bfcb281b4105be07597152d753171950f8750babcee3332dc52`. Exact patch is preserved locally at `.dart_tool/w4c-final-source.patch`. No generated or seed files are staged.

## Remaining task status

- Task 1: held for the Today tag contrast ruling; no Study map rebuild committed.
- Task 2: implemented, focused checks passed and committed; independent review pending.
- Task 3: implemented and focused checks passed; saved in the commit carrying this evidence. Independent review pending.
- Task 4: held for the eyebrow ruling. The full reader body and figure contract is not complete.
- Task 5: held for the absent W4b day-context contract.
- Task 6: held for the complete reader/day context. Existing end, pull and plates remain.
- Task 7: held for the absent W4d quiz entry contracts. Existing direct quiz routes remain until that task can run.
- Task 8: held for the drag-handle contrast ruling. Per-exam prefs, Undo and the reorder notice remain unfinished.
- Task 9: unfinished. Live widgets have not been deleted; the full suite and static gates below check the partial candidate only.

The lead owns independent review, integration, the shared main STATUS update and visual acceptance. The STATUS file exists only on main, outside this worker's code base and assigned file set; no main update is authorized. Its W4c row needs the lead's handoff update. No screenshot, device check, merge or push has run.

## Final verification of the partial candidate

All commands ran serially through the Mac relay. No backend file changed and backend checks were not repeated.

- Issue 9427, `flutter test --reporter expanded`: exit 0, `03:52 +3758: All tests passed!` This was the only full-suite run. It applies to the pre-transition-fix source patch `92449b1a48373bfcb281b4105be07597152d753171950f8750babcee3332dc52`, not a claim of a full-suite run on the later source.
- The final board-source check found that the outgoing map disappeared immediately and the incoming search heading did not fade with its rows. ST_Search draws a 200 ms outgoing fade and a 300 ms incoming fade starting 100 ms later. Those two details were corrected. The outgoing map stays mounted to preserve its scroll and is excluded from focus, pointer input and semantics during search.
- Issue 9428, new transition test before the correction: exit 1, `00:00 +0 -1: Some tests failed.` The outgoing opacity widget did not exist.
- Issue 9429, transition assertions passed, but test cleanup failed because its semantics handle was disposed too late. Cleanup now uses finally.
- Issue 9430, `flutter test test/features/lesson test/app/study_route_test.dart test/core/ui --reporter expanded`: exit 0, `00:38 +878: All tests passed!` This covers the final behavioral source, including 100 ms outgoing opacity 0.057725, incoming opacity 0 at 100 ms and 0.942275 at 250 ms, heading fade, hidden map semantics and Cancel restoration.
- Issue 9430, `flutter analyze`: exit 1, `1 issue found. (ran in 3.7s)`. Exact remaining diagnostic: `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart:238:21`, `deprecated_member_use`, onReorder. This is R-21, assigned to the held Task 8. There are no remaining new analysis findings. The family is not accepted as analyzer-clean.
- Issue 9430, format check: exit 1, `Formatted 1403 files (1 changed) in 1.42 seconds.` The Task 2 search-field wrapper needed formatting after the mechanical comma fixes. Its formatting was corrected with no behavior change.
- Issue 9435, `dart format --output=none --set-exit-if-changed lib test`: exit 0, `Formatted 1403 files (0 changed) in 1.48 seconds.`
- Issue 9430, `dart run tool/check_layering.dart`: exit 0, `Running build hooks...Running build hooks...check_layering: OK`.
- Issue 9430, `dart run tool/check_no_ai_attribution.dart`: exit 0, `Running build hooks...Running build hooks...check_no_ai_attribution: OK`.
- `git diff --check`: exit 0.

Final source identity: HEAD `537d9ef894811c67b9d59c9a4b71b90d290b85d0` plus staged lib/test patch SHA-256 `49c387d8404b182763c3bdd24f0d13498069fef9b92d504f40d5a1a068ae2732`, preserved at `.dart_tool/w4c-handoff-source.patch`. The only source change after the 878-test run was whitespace formatting of the search-field wrapper. The earlier patch and all raw logs remain in `.dart_tool/` for the lead.

Environment: Flutter 3.44.6 stable, framework ee80f08bbf, Dart 3.12.2, DevTools 2.57.0. The lead-prepared ignored seed inputs were not rebuilt or staged. SHA-256 identities:

- `assets/seed/content.db`: `0ef89a64f2d2f63854b3d22048a7d992d5c04fb03df4fec2e7f4e898e6d083dc`
- `assets/seed/content.manifest.json`: `51bc0a766558879e540475ab972f03df7e3077241bab8f688c1b50ece5874f23`
- `assets/seed/content.manifest.sig`: `e0853df259529031344f14d5a5fe6628e1b92c367a96c584894058fe13199f31`

The branch contains the two task commits only. No merge or push is authorized or performed. No generated files or seed assets are committed. The full workstream remains incomplete because of the recorded design rulings and missing contracts.

## Acceptance

Tasks 2 and 3 are implemented, checked and saved locally. No tasks have independent or visual acceptance yet. Aedwon's Android/iPhone visual checks have not run. Tasks 1 and 4 to 9 remain held or unfinished as listed above. The partial candidate is not ready to integrate.

## October 12 authorized resumption

Policy revision: `e354ebe3c37e2d23a035f79da393c4e0da94a33e`, retrieved again with `git fetch origin`. Read current main AGENTS.md, WORKFLOW.md, SUBAGENTS.md, L3/L2 W4c, traceability, amendment spec, parallel map and later lead rulings. The worktree remained on `web/new-design-w4c-r1` at `2eae3d9f`; its uncommitted Task 1 changes were preserved. The remote feature branch does not exist. No push or merge.

The October 12 lead rulings resolve historical questions 1, 4 and 5 above. Today uses `onFillLabel` light `#636366`, dark `#98989D` on the existing fill. Reader has the board's single eyebrow. Bookmark handles use controlOutline. W2's October 10 contrast exceptions and KaTeX math ruling remain binding. Tasks 5, 7, 9 and Home/day endings remain held for their contracts. This resumption authorizes Tasks 1, 4, 8 and independent Task 6 only.

## Task 1: Study map

Implements the count-free map, Last opened and Resume position, Today tags from roadmapTodayProvider, one remembered topic, topic rings/checks, unread minutes and read checks, pinned close, shared section/save failures, preserved map/search and scroll anchoring. Resume offsets are device-local `lesson_offset.<examId>.<lessonId>` values, clamped to the current scroll extent. They save after a 300 ms scroll debounce and on leaving. No schema, sync or seed change.

ST_Map, ST_MapEmpty, ST_TopicOpen and ST_Pinned outlines and timelines were read from the main checkout, read-only. Metrics: last-opened 22/700 with 1.35 line height; Resume 52 high and radius 14; subject header 13/600, 16 inset and 7 gap; row 17/400, 1.35, 12 vertical and 16 horizontal; ring 24 with radius 10.5, track 2 and fill 2.4; Today 12/600, min-height 22, horizontal inset 8, radius 99; pinned min-height 47, title 17/600. Titles wrap for large text. Long topics measure natural height so the board's 800 px reveal cap never clips content.

Shared extensions: ListRow adds optional valueWidget, trailingWidget and wrapTitle, preserving default behavior. ProgressRing.study adds 24 px Study track metrics and a delayed 700 ms fill. SearchField adds optional fieldEntryDelay; its Study field starts at 100 ms and fades/translates 12 px over 450 ms. Map sections use their board delays (180, 260, then 520 + 120 per subject); rings start at 820 + 120 per subject. Topic arrows rotate over 300 ms and reveal/collapse over 700 ms, all with the board's house curve. Closed controls are excluded from focus and semantics. Pinned appearance is immediate, dismissal fades 200 ms. Tests beside W2 verify paint strokes, intermediate values, light/dark contrast, 200% layout and keyboard activation.

Verification, serialized Mac relay:
- 9440, failing first: two map test files, exit 1, `00:02 +4 -7: Some tests failed.` Old counts, read labels, headings and last-opened presentation failed as expected.
- 9441, prescribed focused check: exit 1, `01:30 +875 -1: Some tests failed.` See all semantics included its text twice. Corrected the semantics label.
- 9442, narrowed checks: exit 1, `00:04 +14 -2: Some tests failed.` Closing retained zero-height children visible to widget finders. Added Offstage only at zero height, preserving collapse motion.
- 9443, resume/topic checks: exit 0, `00:04 +12: All tests passed!`
- 9444, metric checks: exit 1, `00:01 +2 -4: Some tests failed.` Corrected test finders and float tolerances for font pixel rounding and native paint float precision.
- 9445, focused check: exit 1, `01:24 +882 -1: Some tests failed.` The isolated map fixture lacked today's plan; added its override. Analysis found 19 issues; new style findings were corrected. R-21 remains assigned to Task 8.
- 9446 and 9447 exposed a test compile error during painter-test refactoring and a num inference error from a mechanical style fix. The test now asserts actual canvas operations with Flutter paint matchers. The reveal cap is explicitly double. No failed run is counted as green.
- 9448, prescribed focused check: exit 0, `01:21 +883: All tests passed!` Analysis: exit 1, `1 issue found. (ran in 5.9s)`, only the existing Task 8 onReorder notice.
- 9449, new long-topic test before correction: exit 1, `00:01 +0 -1: Some tests failed.` Actual reveal height 3312 versus content height 8390 at 200% text. The reveal now measures natural content height. The final test also uses the 390 by 844 phone viewport.
- 9450, `flutter test test/features/lesson test/app/study_route_test.dart test/core/ui --reporter expanded`: exit 0, `01:23 +884: All tests passed!` Raw logs remain in `.dart_tool/w4c-t1-save-*.log`.
- Changed files formatted. `git diff --check`: exit 0. No full suite has run in this resumption.

Task 1 file manifest (authorized W2 extensions included):

- `lib/app/routes/study_routes.dart`
- `lib/core/ui/components/list_row.dart`
- `lib/core/ui/components/progress_ring.dart`
- `lib/core/ui/components/search_field.dart`
- `lib/core/ui/theme/pantas_colors.dart`
- `lib/features/lesson/application/reader_providers.dart`
- `lib/features/lesson/application/study_map_providers.dart`
- `lib/features/lesson/presentation/learn_tab_home.dart`
- `lib/features/lesson/presentation/lesson_page.dart`
- `lib/features/lesson/presentation/widgets/bookmarks_section.dart`
- `lib/features/lesson/presentation/widgets/pinned_topic_bar.dart`
- `lib/features/lesson/presentation/widgets/search_field_bar.dart`
- `lib/features/lesson/presentation/widgets/study_head_block.dart`
- `lib/features/lesson/presentation/widgets/study_topic_section.dart`
- `test/features/lesson/presentation/bookmarks_section_test.dart`
- `test/features/lesson/presentation/fake_open_topic.dart`
- `test/features/lesson/presentation/learn_tab_home_test.dart`
- `test/features/lesson/presentation/lesson_page_test.dart`
- `test/features/lesson/presentation/pinned_topic_bar_test.dart`
- `test/features/lesson/presentation/study_head_block_test.dart`
- `test/features/lesson/presentation/study_map_page_test.dart`
- `test/features/lesson/presentation/study_topic_section_test.dart`
- `lib/features/lesson/data/repos/reader_position_repository.dart`
- `lib/features/lesson/presentation/widgets/study_map_entry.dart`
- `test/core/ui/components/study_map_extensions_test.dart`
- `test/core/ui/components/study_map_tokens_test.dart`
- `docs/superpowers/plans/new-design/evidence/W4c.md`

Task 1 analysis follow-up: 9450 analysis found 12 issues (R-21 plus formatting/style findings in the newly added long-topic test). 9451 fixed the commas and found only R-21 and that test's long string. The long string was split into adjacent literals without changing its value. No production behavior changed after the 884-test run. Attribution in 9450: exit 0, `Running build hooks...Running build hooks...check_no_ai_attribution: OK`.

9452 final Task 1 analysis: exit 1, `1 issue found. (ran in 5.2s)`, only R-21 in the held bookmarks rebuild. No new diagnostics remain. Changed-file format and diff checks exit 0. This is task-level implementation evidence, not whole-family acceptance.

Task 1 source identity: base `2eae3d9f`, staged lib/test patch SHA-256 `7c8d1f53cc10f52ea2efa27d008b91d1e81188048fceec69b64e0fa5a9bb3ac6`, preserved at `.dart_tool/w4c-task1-source.patch`.

## Task 4: Reader body and figures

Policy refreshed with fetch before this task, unchanged at `e354ebe3c37e2d23a035f79da393c4e0da94a33e`. Read RD_Real, RD_Resume, RD_RealScroll and RD_Figure outlines and timelines from main read-only. The October 12 eyebrow ruling and October 10 KaTeX ruling supersede the older wording in the task.

Reader content uses the single uppercase topic eyebrow (13/600, 1.35, 0.52 tracking), 30/700 title (1.15, -0.66), 24 px horizontal gutter, 18 px top inset and 18 px gaps. Geist body and headings use W2 ContentRenderer inside W1 LessonTextScale. Corpus `#N:` headings have the gray numbered marker and 8 px gap. Corpus Solution blocks group into the 14-radius solution surface with 14/16 insets, 12/600 SOLUTION and 10 px gap; consecutive steps have 8 px gaps. The main reading surface is the W1 surface token. Reader controls keep phone text scaling.

Shared extensions:
- ContentRenderer.readerFigures now handles the full approved reader formatting, keeps the reader's “Content unavailable. Update the app.” fallback, skips described images with no URL without leaving gaps, reads image credit from asset.credit, and preserves corpus alt text. Figures and valid tables use the same 14-radius, 0.5 separator frame and 44 px expand target around a 30 px circle. Credits are 11/400, 1.35 with 6 px gap; the W2 secondaryLabel contrast ruling applies. No credit means no line. Other screen families keep their default frame, dialog and content behavior.
- MathText adds optional onErrorFallback so malformed reader math uses the existing shared renderer fallback. Normal math retains KaTeX fonts.
- W1 readerFigureBackground token records RD_Real's `#FAFAF7`. Like existing printed figure backing, it stays light in dark mode and figures use the existing light theme.
- Reader full-screen figures use the black viewer token, pinch zoom, a 44 px Close target and Escape. Opening fades 280 ms with CSS ease and scales the image from .92 to 1 over 380 ms with Cubic(.25,.9,.3,1). Closing lasts 280 ms. Reduced motion shows the final frame. The route owns its animation controller; no undisposed local controller was added.

Failing-first and checks, serialized relay:
- 9453, first test attempt: exit 1. The test HTTP override used a nonexistent getter, and the reader fixture omitted content storage. These setup failures did not count as presentation proof.
- 9454, corrected fixtures before implementation: exit 1, `00:02 +0 -14: Some tests failed.` Missing scale wrapper, eyebrow, reader frames, nested credits, skipped missing images, solution grouping and viewer motion failed as intended.
- 9455, targeted reader tests: exit 0, `00:02 +14: All tests passed!`
- 9456, prescribed focused check after a cleanup edit: exit 1, `01:39 +831 -14: Some tests failed.` I left a stale viewer argument and constructor parameter. Both were corrected. Analysis reported those two errors plus three style notices including R-21.
- 9457, targeted reader tests plus malformed math and reduced motion: exit 0, `00:02 +16: All tests passed!`. Analysis found R-21 and two unnecessary const notices; notices were corrected.
- 9458, `flutter test test/features/lesson test/app/study_route_test.dart test/core/ui --reporter expanded`: exit 0, `01:26 +901: All tests passed!` Includes actual two-pointer pinch, keyboard opening/Escape, light/dark/200% metrics, reader scale preference, table framing and intermediate viewer values at 140 ms.
- 9458, `flutter analyze`: exit 1, `1 issue found. (ran in 6.3s)`, only R-21 assigned to Task 8. Format commands and diff check exit 0.

Task 4 files:
- `lib/core/ui/components/content_renderer.dart`
- `lib/core/ui/components/math_text.dart`
- `lib/core/ui/theme/pantas_colors.dart`
- `lib/features/lesson/presentation/lesson_page.dart`
- `test/core/ui/components/reader_content_extensions_test.dart`
- `test/features/lesson/presentation/reader_body_board_test.dart`
- `docs/superpowers/plans/new-design/evidence/W4c.md`

Tasks 1 and 4 are implemented and saved locally. Tasks 2 and 3 remain at their prior commits. Task 8 and independent Task 6 are next. Tasks 5, 7, 9 and Home endings remain held. Independent review and Aedwon's visual acceptance are not performed.

Task 4 source identity: base `9e55a5ce`, staged lib/test patch SHA-256 `b9299075d910d59947b8dce38c13dde1511f03df67016bee30e3af6d9b7d2b33`.

## October 12 contract-first resumption after lead integration

Retrieved main policy at `900e9f3730a93442fbf4004c148e815bfd45170a`, then again at `cb4dc3cecb5788e9036db24d41c7478aacc3638d` on the next explicit resumption. Current AGENTS.md, WORKFLOW.md and SUBAGENTS.md were retrieved and match the previously read policy contents byte-for-byte. Read the current L3 parallel map and W4c lead rulings. The lead merged integration into this branch at `444daa51`, then `3bbf437c`. All unfinished Task 8 work was preserved. The merges include LessonDayContext and the newer mock family. This worker performed no merge or push. The feature branch still has no remote ref.

Current authorization: reading fraction contract first and alone; then finish Tasks 1, 4, 8, 5 and all applicable Task 6, including Home endings. Tasks 7 and 9 wait for W4d's quiz entry contract, still absent. Standing ruling 2 now requires omitting unavailable controls and listing them, while continuing independent work. Standing ruling 1 resolves contrast pairs using named tokens; changes go under Contrast changes. Analysis and format scope is lib, test, tool.

### Reading fraction contract

Public API in ReaderPositionRepository:
- `Future<double?> readFraction(String examId, String lessonId)` returns a valid measured fraction from 0 to 1. Missing, malformed or out-of-range data returns null for an empty ring.
- `Future<void> writeFraction(String examId, String lessonId, double fraction)` preserves the offset and saves its fraction.
- Existing `write(examId, lessonId, offset)` accepts optional `fraction`. The reader supplies its measured offset-over-extent progress, clamped to 0 to 1. A no-scroll lesson uses the reader's existing fully visible fraction of 1.

Offset and fraction live together in one device preference row, `lesson_offset.<examId>.<lessonId>`, as JSON `{ "offset": <double>, "fraction": <double> }`. An older scalar offset remains readable and has no fraction until measured again. One preference write saves the pair atomically. Repository writes keep their invocation order, and a failed write still reaches its caller without blocking a later retry. No schema, content, backend or sync shape changed. Reading position stays device-local.

Checks, serialized relay:
- 9481, signatures supplied before behavior: exit 1, `00:00 +2 -5: Some tests failed.` Fraction round trips, paired writes, legacy-offset preservation and invalid-input rejection failed as intended.
- 9482, first implementation: tests exit 1 and narrow analysis exit 3. Record offsets inferred as num/int where double was required. Corrected the literal types and trailing commas.
- 9483, `flutter test test/features/lesson/data/reader_position_repository_test.dart --reporter expanded`: exit 0, `00:00 +7: All tests passed!`
- 9483, `dart analyze lib/features/lesson/data/repos/reader_position_repository.dart test/features/lesson/data/reader_position_repository_test.dart`: exit 0, `No issues found!`
- Contract files formatted and diff check exit 0. The reader's save call and its existing resume assertion were updated to this storage contract. The updated reader widget assertion has not run yet because the preserved unfinished Task 8 UI does not compile. It will run with the next focused family check.

This first commit contains only the contract, its reader save call, its repository tests, its existing resume assertion and this evidence. The unfinished bookmark changes remain unstaged. Task 8's earlier 9462 run was canceled after compilation errors and provider timeouts; the relay reports exit 70 and no final output. The raw partial log is preserved at `.dart_tool/w4c-t8-first-1.log`. It is not passing evidence.

Contract file manifest:
- `lib/features/lesson/data/repos/reader_position_repository.dart`
- `lib/features/lesson/presentation/lesson_page.dart`
- `test/features/lesson/data/reader_position_repository_test.dart`
- `test/features/lesson/presentation/lesson_page_test.dart`
- `docs/superpowers/plans/new-design/evidence/W4c.md`

## October 13 resumption checkpoint: Task 8 incomplete

Lead requested a checkpoint at the short-window limit after relay 9518. No Task 8
completion, commit, integration, independent acceptance, visual acceptance or publication
is claimed. Tasks 5, 6, 7 and 9 were not started in this resumption.

### Startup and source identity

- Read current GitHub main AGENTS.md, WORKFLOW.md, SUBAGENTS.md, startup and visual-companion
  policy; L2/L3 W4c, parallel map, strategy, amendment spec and current design decisions.
  Policy revision: `93fe98f21f1d945fa5e78b423e7626d259b0d2e5`.
- Relay repository main README and project instructions retrieved and read. Relay fetch
  `9490` exited 0 on the self-hosted Mac runner.
- Assigned source remained `5e6cda4541a80609b27f2784fc2e58d39731a33b` on
  `web/new-design-w4c-r1`; remote `287a640b854bc9efa187360cec194e6960554c00`.
  The three local integration commits and 13 paused dirty files matched the lead's assignment.
  No switch, merge, reset, rebase, push or main edit was performed.
- The reading-fraction contract and Tasks 1-4 remain preserved. LessonDayContext and both
  quiz-start functions are present in this base; their formerly held controls can now proceed.
- Final lib/test dirty patch SHA-256:
  `1487bf1962c8a8554e20f4bf982dbaef2ca6ce7ebe5d9c3f7dffc11fcfca92b2`.
  Exact patch saved as `.dart_tool/w4c-2026-10-13-checkpoint.patch`.
  There are 16 dirty source/test files, plus this evidence update. No generated files staged.

### Task 8 recovery changes

Preserved and repaired the paused bookmark sheet and Study sheet integration.
The recovered implementation uses the existing shared variants, per-exam sort and
JSON custom order keys, unchanged membership schema, saved removal rows and exact
Undo order with newly added bookmarks retained.

- Bounded the checkbox reveal's height to 22 px; its OverflowBox previously received
  unbounded height inside the scrolling list.
- First scoped sort/custom-order reads copy their legacy values once. A later global
  sort change cannot alter an exam already migrated. The legacy row remains intact.
- Removed startup invalidation while preference migration is in flight. Change listeners
  attach after migration; the sort controller reads current storage rather than applying
  delayed snapshots. Oldest sorts the already-read timestamp rows rather than issuing
  another awaited query after listeners attach.
- Retained A-to-Z tie handling for Recent/Oldest and the scoped order update when a
  reader toggles a bookmark.
- Corrected reset's accessible label. Existing action tests now follow the approved
  44 px targets and show handles/reset only while editing.
- Added repository tests for per-exam migration isolation and Undo timestamps/order.
- Added explicit resource cleanup to the selected-exam widget test and Study route test.
  Both were reached without their former cleanup failures in relay 9518.

Shared extensions remain scoped to the paused draft:
`check_mark.dart`, `list_row.dart`, `pantas_sheet.dart`,
`segmented_switch.dart`, `state_view.dart`. They need independent review with the
full Task 8 diff. Other families' source was not edited.

### Exact checks and failed attempts

All execution used relay literal argv. Full logs remain under `.dart_tool/`.
The Python wrappers' child exits, rather than only their relay envelope exits,
determine results.

- `9491`: bookmark draft tests, child exit 1, 27 failures; narrow analysis child
  exit 2, 151 issues. The relay envelope incorrectly appeared successful because
  the initial wrapper did not propagate child failure. This is not passing evidence.
- `9495`: test updates and migration/Undo tests written, exit 0.
- `9497`: repository red check, exit 1, `00:00 +4 -1: Some tests failed.`
  The first scoped-read test found Recent after the global sort changed, rather
  than the previously migrated Oldest.
- `9499`: recovery source edits applied, then dart fix exited 64 because it
  accepts no path arguments. Tests did not run in that request.
- `9501`: style fixes and formatting completed; the reactive-watch attempt
  canceled pending async provider startup. Relay timed out at 180 seconds.
  Partial test output: `02:20 +6 -7`; no final test result. That attempt was replaced.
- `9504`: temporary test listeners traced preference events. One isolated sort
  test passed when the stream was started before awaiting the notifier. Trace
  instrumentation was removed; its passing result does not validate the unobserved
  startup path.
- `9508`: targeted data/sheet tests, exit 1,
  `00:05 +34 -2: Some tests failed.` Oldest startup and the omitted reset label
  remained. `9511` reproduced the same two failures. The Oldest-only extra await
  was then removed and reset's label added.
- `9513`: prescribed focused command:
  `flutter test test/features/lesson test/app/study_route_test.dart test/core/ui --no-pub --reporter expanded --timeout 20s`.
  Partial output reached `00:42 +908 -2`; relay exited 124 at 240 seconds.
  Failing tests: `shows only selected exam content` and
  `/study with a topicId opens that topic`. Both found a pending zero-delay
  Drift disposal timer. Analysis was not reached.
- `9516`: explicit unmount plus pump() and awaited db.close was insufficient.
  pump() advances no fake time; db.close waited on the pending fake timer.
  Relay exited 124 at 120 seconds. Analysis was not reached.
- `9518`: explicit `pump(Duration.zero)` before awaited db.close.
  The selected-exam and Study route cases no longer failed. Partial output:
  `00:02 +41 -1`; relay exited 124 at 120 seconds, with no final summary.
  Remaining failure: `reduced motion removes the pinned topic transitions`,
  which still uses implicit ProviderScope disposal. Analysis was not reached.
  Log: `.dart_tool/w4c-task8-timer-0.log`.
- `git diff --check`: exit 0 before the final fixture-only changes. Formatting
  and static gates still require a fresh run on the completed task.

### Disposal cause and next action

Installed Drift 2.34.3 `stream_queries.dart` confirms `markAsClosed` schedules
`Timer.run` to retain the query cache briefly. Its cancellation callback removes
the table subscription and cancels running queries. Its own source explicitly
instructs Flutter tests to await Database.close. Installed Flutter test binding
confirms pump() only flushes microtasks; a supplied Duration invokes fake-time
elapse. Thus pumping Duration.zero runs that cache-disposal timer before awaiting
database closure. These are expected disposal operations, not intentionally
retained subscriptions.

Next: apply the same explicit unmount, Duration.zero pump, and awaited db.close
to `reduced motion removes the pinned topic transitions`, then rerun the narrow
tests and the complete prescribed focused command. Run analysis/format for
`lib test tool`, layering and attribution. Finish remaining board-state/motion
coverage, including light/dark and 200% text, before recording Task 8 complete
and committing its scoped changes. Do not claim analysis or full-suite success
from the partial runs above.

### Contrast changes and acceptance

- Drag handles and unchecked selection outlines use controlOutline, as the standing
  ruling requires. Shared variant backgrounds remain the drawn values.
- No new figure, dependency, schema or product rule was introduced.
- No screen capture, autonomous UI control, device check or visual acceptance occurred.
- Account wipe, peer-device sync convergence and the complete Task 8 state/motion
  matrix remain unverified.
- No current contract is missing from this base. Reader/day and quiz controls are
  pending implementation, not waiting on absent contracts.
- Lead owns main STATUS/SSOT, review, integration and visual acceptance. The worker
  has not updated main STATUS; this checkpoint must be reflected there by the lead.

## October 13 evening: verified Task 8 partial checkpoint

Current policy and relay instructions were retrieved again after Aedwon resumed.
The policy blobs and L2/L3/parallel map match the earlier read. Relay fetch 9522
passed. Policy main revision after the fetch:
`56ca1b58fe164e4423765ea7181282b95887e898`.
Source stayed at `5e6cda4541a80609b27f2784fc2e58d39731a33b`; remote stayed at
`287a640b854bc9efa187360cec194e6960554c00`. The existing 17-file dirty checkpoint
and its `1487bf19...` source patch were preserved.

The lead explicitly authorized saving this verified partial checkpoint before the
remaining Task 8 fidelity work. Task 8 is not complete or accepted. The family is
not ready for integration or publication.

### Recovered behavior and new evidence

- Relay 9523: the remaining reduced-motion fixture now explicitly unmounts,
  advances zero fake time, and awaits database closure. Exit 0:
  `00:01 +4: All tests passed!`. This resolves the previously recorded disposal hang.
- Relay 9525: board tests failed as intended on 64 px editing rows instead of 62 px,
  and on the wrong 200 ms selection spring. Exit 1:
  `00:03 +32 -3: Some tests failed.`.
- Relay 9528 ran no tests because a literal-name filter was incorrectly used for two
  alternatives. Exit 79. It is not red-test evidence.
- Relay 9529: subject-heading and order-crossfade tests failed as intended:
  `00:01 +0 -2: Some tests failed.`.
- The implementation now uses the board's 62 px rows, popB selection spring,
  actual subject headings when sorted By subject, and a 200 ms linear crossfade
  between orders. Outgoing/incoming transition rows stay outside focus, pointer
  input and semantics until their transition completes.
- Relay 9530 still found the unchanged 64 px inset and a test observing the sort
  before its asynchronous write finished. The exact multiline inset was corrected;
  the motion test now waits for the actual order update, then measures 0.5 opacity
  at 100 ms of its 200 ms transition.
- Relay 9533: targeted tests exit 0, `00:03 +51: All tests passed!`.
  Analysis exited 2 with three remaining style findings, subsequently corrected.
- Relay 9536: the initial reader-cache fixture deadlocked when waiting for a new
  reader provider through runAsync while its widget scheduler needed a frame.
  The streamed log preserved the exact last fixture. No passing evidence claimed.
- Relay 9542: the fixture preloads the reader before binding its widget scheduler
  and pumps newly read results. It failed on the real defect:
  removing a bookmark left the cached reader flag true.
- Remove and Undo now invalidate the Study map alongside the bookmark rows,
  refreshing the reader's dependent bookmark flag.
- Relay 9546: all targeted tests exit 0,
  `00:03 +52: All tests passed!`. Analysis `lib test tool` exit 0:
  `No issues found!`.

The repository tests cover one-time legacy migration, separate exam sort/custom
order, clearing account preferences, timestamp preservation and exact Undo
positions with newer bookmarks retained. Widget checks cover light/dark,
100%/200% text, reduced motion, one/empty/edit states, drag and semantic move
behavior, order persistence, the actual selection spring and order crossfade,
and reader-state consistency after Remove/Undo. The synced account preference
row shape remains key/value strings; custom order is JSON lesson IDs. Schema,
membership storage and backend endpoints remain unchanged.

### Final focused verification for this checkpoint

Relay 9549, all child exits 0:

```text
HEAD 5e6cda4541a80609b27f2784fc2e58d39731a33b
PATCH_SHA256 74221bd0d8b85611ba4c007bb09d27b37fd7100484980fe418c4da256d6b71a8
flutter test test/features/lesson test/app/study_route_test.dart test/core/ui --no-pub --reporter expanded --timeout 30s
00:34 +925: All tests passed!
dart format --output=none --set-exit-if-changed lib test tool
Formatted 1459 files (0 changed) in 1.45 seconds.
dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK
dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK
git diff --check
exit 0
```

Exact source patch: `.dart_tool/w4c-task8-verification-source.patch`.
Complete logs: `.dart_tool/w4c-task8-verified-0.log` through
`.dart_tool/w4c-task8-verified-4.log`.
Analysis log: `.dart_tool/w4c-evening-task8-green-3.log`.

### Unfinished work and acceptance

- Task 8: the drag proxy's exact BM_Edit lift/drop presentation remains unfinished.
  Screen-reader move feedback still says “Moved [lesson]”; destination wording
  matching BM_ScreenReader remains unfinished.
- Task 5, all of Task 6, Task 7 and Task 9 remain pending in this resumption.
  Their contracts are present. No broad reader work has begun.
- Independent review, peer-device sync convergence and Android/iPhone visual
  acceptance remain unverified. No screen capture or autonomous UI control occurred.
- No full Flutter-suite pass is claimed on this checkpoint. Task 9 owns the final
  complete-family gates. No merge, upload, integration, main STATUS update or
  publication was performed by the worker.
- Contrast remains as ruled: selection outlines and handles use controlOutline;
  checked selection marks use full onAccent. No new contrast exception was introduced.

Scoped checkpoint manifest:
- `docs/superpowers/plans/new-design/evidence/W4c.md`
- `lib/core/ui/components/check_mark.dart`
- `lib/core/ui/components/list_row.dart`
- `lib/core/ui/components/pantas_sheet.dart`
- `lib/core/ui/components/segmented_switch.dart`
- `lib/core/ui/components/state_view.dart`
- `lib/features/lesson/application/bookmark_providers.dart`
- `lib/features/lesson/application/reader_providers.dart`
- `lib/features/lesson/data/repos/bookmark_prefs_repository.dart`
- `lib/features/lesson/domain/models/bookmark_order.dart`
- `lib/features/lesson/presentation/learn_tab_home.dart`
- `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart`
- `test/app/study_route_test.dart`
- `test/features/lesson/application/bookmark_providers_test.dart`
- `test/features/lesson/data/bookmark_prefs_repository_test.dart`
- `test/features/lesson/presentation/bookmarks_sheet_test.dart`
- `test/features/lesson/presentation/learn_tab_home_test.dart`

## October 14: lead-review Undo boundary correction

Aedwon resumed the existing assignment. Current GitHub main AGENTS, WORKFLOW and
SUBAGENTS were read in full again; their policy blobs remain
3bdc2905aa3c2eb85f6280947528969464d379a3,
f4f2415256b8afbb5715d850a4b588c169d2d48c, and
b539ba3da0255d6272486d147fa8b4c80050482d. Relay README and
CHATGPT_PROJECT_INSTRUCTIONS were refreshed from relay main, unchanged. Relay
9558 fetched main and the assigned branch before editing. The assigned tree was
clean at 606ee3fc6e569d187bad90e1cbcd880519fab72f; its remote remained
287a640b854bc9efa187360cec194e6960554c00. Fetched policy main at resumption:
cec54bd782e4e40e22c8c12a9c086186a57e3452. The later recorded L3 clarification
“October 14: Undo boundaries” was read before guard code (lead references
833c98da, decision log29e20a4c). The implementation preserves the earlier
checkpoint and its unfinished fidelity scope.

### Root cause and RED

The held removal payload had rows/order/exam only. The restore transaction
unconditionally reinserted those rows. LocalSyncMutationRecorder reads the
current context for causality, so it cannot prove the provenance of a retained
payload. SyncActiveContextStore already supplies a token, including anonymous
envelopes; runtime quiesce/activation rotates it. SyncLocalStateWiper.wipeAll
deletes account-owned rows, preferences and the token. Auth sign-out/account
deletion use this existing quiesce/wipe path. No replacement lifecycle is needed.

Relay9560, exit1, seven meaningful failures before production changes:
- held Undo cannot resurrect guest rows after the real wipe path
- held Undo cannot import rows into the next active account
- held Undo expires when the existing boundary token rotates
- held Undo cannot restore the previous exam while another is selected
- mounted sheet expires Undo after an exam change
- mounted sheet expires Undo after the real reset path
- mounted sheet expires Undo when the existing auth identity changes

The data failures actually restored old membership. The mounted sheet retained
Undo after each boundary. Log: .dart_tool/w4c-boundary-red.log.

Relay9564, exit1, two further failing fixtures:
- reset expires Undo and removes its failed-save Retry
- a late old Undo error does not recreate Retry after reset
Both retained Undo after the real wipe. Log:
.dart_tool/w4c-boundary-retry-red.log.

### Implemented correction

Removal captures the existing snapshot token with rows/order in its transaction.
Only an absent/unrecognized legacy snapshot initializes the existing anonymous
envelope through SyncActiveContextStore.clearStable. Every recognized active or
anonymous snapshot remains intact. Restore validates token and selected exam
before any restoration writes inside its transaction. Missing/mismatched token
returns false, without membership or preference resurrection.

The sheet expires retained Undo on existing auth UID, selected-exam, or account
preference/reset signals. Its reset check reads the existing token. Expiration
also discards pending selection, folding/restoring state and failed-save Retry.
A guarded restore returning false expires Undo without a save-error loop. A late
failure from an already expired operation cannot recreate Retry. Ordinary
current-boundary failures still offer Retry.

Tests use the actual SyncLocalStateWiper, active-context publish/clear methods,
the real device selection repository, and the existing auth stream. The next-exam
widget fixture contains a valid second content exam. Ordinary Undo now verifies
original timestamp and sortIndex, exact custom positions, and actual newly added
membership. Another test verifies that removal/Undo preserves both token and
active UID/generation, and guest reset coverage starts with a raw missing token.

### GREEN and exact verification

Relay9571: data12 tests passed, child exit0.
Relay9572: sheet36 tests passed, child exit0.
Relay9575: affected80 tests passed. Analyzer child exit0 still reported one style
info, so this was not accepted as clean analysis. The test constructor was fixed.
Relay9577: strengthening the fixture introduced a test-only ambiguous Drift
matcher import: two loading failures, analyzer child exit3. This was corrected by
importing only Value. No production guard change followed those failures.

Relay9579: all child exits0 on the final candidate:

```text
flutter test test/features/lesson/application/bookmark_providers_test.dart test/features/lesson/data/bookmark_prefs_repository_test.dart test/features/lesson/domain/bookmark_order_test.dart test/features/lesson/presentation/bookmarks_sheet_test.dart test/features/lesson/presentation/bookmarks_section_test.dart test/core/sync/sync_active_context_store_test.dart test/core/sync/local_state_wiper_test.dart test/core/sync/local_sync_mutation_recorder_test.dart --no-pub --reporter expanded --timeout 30s
00:03 +80: All tests passed!
dart analyze lib test tool
No issues found!
dart format --output=none --set-exit-if-changed lib test tool
Formatted 1459 files (0 changed) in 1.39 seconds.
dart run tool/check_layering.dart
check_layering: OK
dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
git diff --check
exit0
```

Source base: 606ee3fc6e569d187bad90e1cbcd880519fab72f.
lib/test/tool patch SHA256: 67a98d348b63c2368944fd09ad979203ea235f28ef3aaa1701abf8d2cfe595f6.
Patch: .dart_tool/w4c-boundary-verified-source.patch.
Final complete logs: .dart_tool/w4c-boundary-final-0.log through
.dart_tool/w4c-boundary-final-5.log. Earlier streamed logs remain available.
This is scoped correction evidence, not a full-family suite or acceptance claim.

Scoped manifest:
- lib/features/lesson/data/repos/bookmark_prefs_repository.dart
- lib/features/lesson/presentation/widgets/bookmarks_sheet.dart
- test/features/lesson/data/bookmark_prefs_repository_test.dart
- test/features/lesson/presentation/bookmarks_sheet_test.dart
- docs/superpowers/plans/new-design/evidence/W4c.md

### Remaining scope and acceptance

Task8 remains partial: exact drag proxy lift/drop and destination announcement
fidelity remain pending. Tasks5,6,7,9 remain pending. Their integrated contracts
are present; no waiting-on-contract control was added. No new dependency, schema,
sync/backend mechanism, figure or contrast exception was introduced. Existing
controlOutline/onAccent contrast rulings remain unchanged. Visual acceptance,
peer-device convergence, independent review and full-family gates remain
unverified. No screenshots, computer control, upload, merge, main edits or
publication occurred. Lead owns the scoped re-review and acceptance.

## October 14: bookmark destination announcement checkpoint

After the verified Undo guard checkpoint, the remaining Task8 fidelity boards
were reread from main, with their timeline/outline tools and motion/decision
rules. Engineering HEAD does not carry these exported boards, so main remains
the source. Main board blob identities:
BM_Edit cbcd81bd667526e4a25966a7f0d509ab854a3a3d;
BM_ScreenReader 9b2a776617efc2dc3c58e3e3e2c9a08df336929a.

BM_ScreenReader says “Moved above Chemical Bonding.” and “Moved above Layers of
the Earth and Composition.” The prior implementation said only “Moved [lesson]”.
The move now captures its destination before asynchronous persistence and
announces “Moved above/below [destination].” Move up/down actions and the
resulting saved Custom order remain unchanged.

Relay9583: both direction fixtures failed on the missing destination. Relay9585
exposed exact messages: expected “Moved above Lesson2.”, actual “Moved Lesson1”;
expected “Moved below Lesson2.”, actual “Moved Lesson3”. Exit1 with two meaningful
failures. Actual test strings include spaces between Lesson and its number.
The streamed exact RED log is .dart_tool/w4c-destination-exact-red.log.

Relay9587 ran the prescribed task scope: 935 passed and two new fixtures failed
because their SemanticsHandle remained active at Flutter end verification.
The destination message/order assertions had passed. addTearDown runs after that
verification; the fixtures now explicitly dispose the handle in try/finally.
The same candidate also had one analyzer line-length info. The destination
expression was split without changing behavior.

Relay9589, all child exits0 on the final candidate:

```text
flutter test test/features/lesson/presentation/bookmarks_sheet_test.dart --plain-name 'announces its destination' --no-pub --reporter expanded --timeout 30s
00:00 +2: All tests passed!
flutter test test/features/lesson test/app/study_route_test.dart test/core/ui --no-pub --reporter expanded --timeout 30s
00:39 +937: All tests passed!
dart analyze lib test tool
No issues found!
dart format --output=none --set-exit-if-changed lib test tool
Formatted 1459 files (0 changed) in 1.40 seconds.
dart run tool/check_layering.dart
check_layering: OK
dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
git diff --check
exit0
```

Source base: 4d1d9980de140d5e95d9a2ec1793a31842899017.
lib/test/tool patch SHA256: 358416d2929ce2cf0d679e0750cf2ed5988db3bb61098b3b374838eab4c5a308.
Patch: .dart_tool/w4c-destination-verified-source.patch.
Complete streamed logs: .dart_tool/w4c-destination-verified-0.log through
.dart_tool/w4c-destination-verified-7.log.

Scoped manifest:
- lib/features/lesson/presentation/widgets/bookmarks_sheet.dart
- test/features/lesson/presentation/bookmarks_sheet_test.dart
- docs/superpowers/plans/new-design/evidence/W4c.md

### Concrete remaining fidelity limitation

BM_Edit row BMEdit_n92: lift begins9000ms, reaches scale1.03 and shadow
0 8px 24px rgba(0,0,0,.14) at9150ms: 150ms, houseOut. On release at10000ms,
the row reaches scale1/no shadow at10200ms: 200ms, houseOut. Board movement
follows the finger while held.

The installed Flutter source
/opt/homebrew/share/flutter/packages/flutter/lib/src/widgets/reorderable_list.dart
hardcodes the proxy AnimationController duration250ms (around line1560), uses
reverse for drop, and lerps the drop position with Curves.easeOut (around line1665).
Its list gap controller also hardcodes250ms (around line1339). The public
proxyDecorator receives animation.view and can change the visual decoration;
it cannot retime the underlying proxy position/drop. No SDK patch or reflection
was attempted. This conflict was sent to the lead before any proxy workaround.

Task8 remains partial while the lead rules on implementing the exact lift/drop
without an unapproved timing substitute. Destination wording is now verified;
proxy code remains unchanged. Tasks5,6,7,9 remain pending per lead sequencing.
No missing external contract is blocking a control. No new schema, dependency,
sync mechanism, figure or contrast exception was introduced. The actual full
Flutter suite, combined-family acceptance, phone visual acceptance, peer-device
convergence and independent review remain unverified. No upload, merge,
publication, screenshots or computer control occurred. The immutable Undo
correction remains available separately for lead re-review.

## October 14: corrected motion reading and verified decoration slice

Aedwon continued after the usage reset. Current main AGENTS, WORKFLOW, SUBAGENTS
and startup were retrieved again and read. Policy blobs remain unchanged;
startup policy main:26b83566c12519bfd1a83600aa666b3faf265e73.
Current L2/L3, amendment spec and parallel map were refreshed. Relay README and
project instructions match the previously read main blobs668138ab and0f30ecd8.
Root reconciliation9595 reported clean23113, expected remote287a640b, local ahead6
and remote ahead0. Root then reviewed and normally uploaded the immutable
checkpoint through9596; local and remote23113 now match. The worker did not push.

### Correction of the earlier limitation

The earlier statement treated the200ms decoration settle as if it required
200ms proxy position settling. That was incorrect. Exact BMEdit_n92 source holds
translateY(-124px) at both74.074% and75.556% of13500ms (about10000/10200ms).
Only scale1.03→1 and shadow→none change during this200ms segment.
The source still specifies150ms pickup decoration and200ms release decoration,
both houseOut. No new position-duration choice is required for this slice.

The public proxy decorator receives Animation<double> with status listeners.
An independent local controller can observe pickup/reverse status and animate
decoration without changing Flutter's controller or position. Root recorded the
technical ruling before code in mainL3:b7176243c7ad723d2d88d6c8abbe2b5d82043bbb.
The order clarification5f5748fe resolves the old missing-contract hold. Root later
recorded the genuine neighboring-row curve question at main203384e/log747984f.

### Bounded implementation and RED/GREEN

The sheet now uses its public proxyDecorator to add:
-150ms scale1→1.03 and shadow0→0 8px 24px black14%, using houseOut.
-200ms scale1.03→1 and shadow→none on reverse status, using houseOut.
-Existing surface/shadow color tokens in light and dark.
-Flat final decoration with reduced motion.
-Removal of status listeners and disposal of the local controller on unmount.
-Dismissed/short-release handling that stops the local decoration animation.

No SDK field, list-gap curve, position animation, membership, order preference,
shared component or dependency was changed. The callback replaces Flutter's
default elevation decoration; the existing drag system remains intact.

Relay9600, exit1:7 RED fixtures. Five found a null proxyDecorator; two actual
gesture fixtures lacked the custom proxy. Exact log:
.dart_tool/w4c-drag-decoration-red.log.

Relay9602:4 passed/3 failed. Both exact timing/scale/shadow assertion sets passed,
but the synthetic parent250ms controller stayed active at fixture end because
addTearDown runs after Flutter's ticker verification. The short synthetic reverse
also had not reached dismissed status at the assumed30ms floating boundary.
The tests now dispose their parent controller in explicit finally blocks and
observe the actual dismissed lifecycle. The widget's own real cancel/unmount
cleanup already passed. Actual gestures move beyond recognizer slop before
inspection. Analyzer also reported test/style info; these were corrected.

Relay9603:8 focused tests passed, including light/dark exact75/150ms pickup and
100/200ms release samples, reduced motion, short synthetic release, actual short
release preserving selected membership/order, actual cancellation and unmount.
A remaining bool-conversion style info was corrected before the final gates.
No historical warning exception was used.

Relay9604, all child exits0:

```text
flutter test test/features/lesson test/app/study_route_test.dart test/core/ui --no-pub --reporter expanded --timeout 30s
00:38 +945: All tests passed!
dart analyze lib test tool
No issues found!
dart format --output=none --set-exit-if-changed lib test tool
Formatted 1459 files (0 changed) in 1.41 seconds.
dart run tool/check_layering.dart
check_layering: OK
dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
git diff --check
exit0
```

Source base: 23113d73a72ffa498f2c9ca652c9b2ee83af3d48.
lib/test/tool patch SHA256: f4c68ec7936ee4d6a3b880da7b6b3ea85f83e9d6418e5e4930815ee8add79db6.
Patch:.dart_tool/w4c-drag-decoration-verified-source.patch.
Complete logs:.dart_tool/w4c-drag-decoration-final-0.log through
.dart_tool/w4c-drag-decoration-final-6.log.

Scoped manifest:
-lib/features/lesson/presentation/widgets/bookmarks_sheet.dart
-test/features/lesson/presentation/bookmarks_sheet_test.dart
-docs/superpowers/plans/new-design/evidence/W4c.md

### Pending requirements and next order

Task8 decoration is implemented and automatically checked; full Task8 acceptance
is pending. There is a separate actual represented difference: neighboring rows
BMEdit_n89/n86 move62px over250ms houseOut. Installed Flutter gap offsets use250ms
easeInOut (reorderable_list.dart offset getter around1307 and controller around1339).
The public decorator cannot retime those neighboring offsets. That question
remains with Aedwon; no curve waiver or custom drag system was implemented.

Source inspection also noted a possible existing separator gap: sheet ListRow
calls leave divider false, while BM_Edit rows draw0.5px bottom separators.
This observation was sent to the lead; it was not added to this bounded slice.

Under the recorded execution order, proceed with independent Tasks5,6,7 and9.
Their real day-context/quiz-entry contracts are present. No waiting-on-contract
control was added. Task9/full-family acceptance cannot pass with unresolvedTask8.
The actual complete Flutter suite, combined review/integration, phone visual
acceptance and peer-device convergence remain unverified. No screenshot, computer
control, schema/figure change, new contrast exception, merge, worker upload or
publication occurred.


## October14 resumed Task8 separator checkpoint

Policy/main revision: `eaa9c924cb415bd508b44afaaccbbca08ea586c4`. Current AGENTS.md,
WORKFLOW.md, SUBAGENTS.md, startup, L2/L3c, amendment and parallel map retrieved/read.
Local/remote code base `cdda64f5bef052f201e263f1f466e3f0893bd545` reconciled before edits.
Relay offline; main records native isolated-worktree fallback. No relay request was queued.
The six Task5 source/test drafts are untouched: their HEAD-relative patch SHA256 remains
`ec0cc8158f00c2a86f68c3334d04db4d2a5a6de84e88db3c11f56e31ab565f47`.
Their prior capacity evidence remains unstaged outside this Task8 checkpoint.

Board source and outline/timeline read before the correction: BM_Edit and BM_Order, exact
62px box-sizing:border-box rows. Full-width bottom .5px separators follow actual states:
Recent/Oldest include the final row; Custom/Edit omit the final row; By subject omits each
subject group's final row. Existing ListRow.divider paints that exact edge. No shared-component
extension. Bottom content inset decreases by .5px only when bordered to account for Flutter's
added border padding and retain62px edit rows. Existing themed separator color retained;
no new contrast substitution. The approved built-in neighboring250ms easeInOut exception
and150/200ms houseOut decoration remain unchanged.

Source patch: `.dart_tool/w4c-separators-verified-source.patch`, SHA256
`cec630e7c9e4023a24f389255827ba58945cf7b562ca01b2031b27d8021f18ef`.
Changed production/test paths: BookmarksSheet and its widget test only; plus this evidence.

Actual native check results (full logs saved locally):
- Initial separator RED: exit1,0 passed/9 failed, missing borders. First GREEN attempt:
 6 passed/3 failed because test IDs assumed reverse chronology for By subject; source shows
 corpus order. Corrected those test identities, not product ordering. Final corrected tests
 rerun against exact unmodified cdda production: exit1,0 passed/9 failed, absent .5px borders;
 `.dart_tool/w4c-separators-red-exact.log`. Restored only our saved production patch afterward.
- Corrected GREEN: exit0,9 passed; `.dart_tool/w4c-separators-green-2.log`. Light/dark,
 all orders, editing first/middle/last and subject boundaries assert actual border/color,
 full sheet width and62px geometry. No image/browser capture.
- Affected checks: `flutter test test/features/lesson/presentation/bookmarks_sheet_test.dart
 test/features/lesson/presentation/bookmarks_section_test.dart
 test/features/lesson/domain/bookmark_order_test.dart
 test/features/lesson/data/bookmark_prefs_repository_test.dart
 test/features/lesson/application/bookmark_providers_test.dart
 test/core/ui/components/pantas_sheet_test.dart
 test/core/ui/components/structure_completion_test.dart
 test/core/ui/components/row_dialog_accessibility_test.dart
 test/core/ui/components/shared_board_corrections_test.dart
 test/core/ui/components/study_search_extensions_test.dart --no-pub --reporter expanded
 --timeout30s`: exit0, `00:06 +108: All tests passed!`;
 `.dart_tool/w4c-separators-final-0.log`. Includes Undo boundary/migration/reorder and drag
 cleanup regressions, existing shared row and bookmark sheet behavior.
- Scoped analysis initially reported3 trailing-comma infos despite child exit0. Fixed those
 test-only style issues. Final `dart analyze` on both changed Dart files: exit0,
 `No issues found!`; `.dart_tool/w4c-separators-analysis-final.log`.
- Scoped format:2 files,0 changes,exit0. Layering/attribution:each exit0,OK.
 `git diff --check`:exit0. Logs `.dart_tool/w4c-separators-final-2.log` through-5.

This is a verified separator slice. The unfinished reader draft is excluded from its staged
source; broader checks will run after that draft completes. Task8/family independent acceptance
and phone visual acceptance are unverified; the lead owns review, upload and integration.
No control is waiting on a new contract in this slice. Task5 reader Contents/navigation and
remaining Tasks6/7/9 continue under main a04aca18 and the recorded task-order ruling.


## October14 Task5 shared Contents variant checkpoint (partial)

Base `fa5d146f77990dbef72e86fa20f9b96ded9ca3ae`; current policy/main
`eaa9c924cb415bd508b44afaaccbbca08ea586c4`, including a04aca18's shared-mode ruling.
Native work uses the recorded offline-relay fallback. No queued/running relay.
RD_Contents/RD_Plan raw boards, outline and actual timeline read before changes.
They draw450ms open/400ms close slideC,350ms ease wash32%,105% translation,
intrinsic contents height within viewport, with no page shift or scale.

Added only optional PantasSheet.readerContents, defaultfalse. Generic and bookmark modes
retain their timing, wash, height and background transforms. The new mode shares all existing
focus/semantics, dismissal, scrolling and reduced-motion behavior. Reader callers/content are
not connected in this slice. No new route, data mechanism, dependency, schema or color.

Source identity: `.dart_tool/w4c-reader-contents-variant-verified-component.patch`, SHA256
`14bea9c38e8f1b8310059bdd28b1a82a0e2d3dee9570d1004496ac7c9fe91860`;
new `test/core/ui/components/reader_contents_sheet_variant_test.dart` SHA256
`e7bbbc1468423448967e274ef4071ae1619ee956c3e9dee6706e0f9665c43fbf`.
The six saved Task5 reader source/test drafts remain byte-for-byte unchanged,
HEAD-relative patch SHA256`ec0cc8158f00c2a86f68c3334d04db4d2a5a6de84e88db3c11f56e31ab565f47`.
Those drafts and their earlier capacity evidence stay unstaged outside this checkpoint.

Actual native results:
- Initial8-test run failed because broad finders also found MaterialApp's Navigator transition
 widgets. Those fixture failures are not behavioral RED. Scoped every timing/barrier finder
 to the actual PantasSheet and settled the initial Navigator transition before actions.
- With corrected tests against the base shared component plus API-only stub: exit1,4 pass/4 fail;
 `.dart_tool/w4c-reader-contents-variant-red-exact.log`. Both themes fail on missing105%
 translation and32% wash. Existing dismissal behavior already passes. Only our candidate
 component was temporarily replaced for this exact reproduction and restored afterward.
- Corrected candidate:exit0,8 pass; `.dart_tool/w4c-reader-contents-variant-fixture.log`.
 Exact225ms opening and200ms closing slide values,175ms wash values, final450/400ms
 boundaries, unchanged page transforms,200px intrinsic height,320px/200% text viewport
 cap, scrolling, reduced motion, escape/barrier/back/drag dismissal with page focus/semantics.
- Candidate plus existing sheet tests:exit0,17 pass;
 `.dart_tool/w4c-reader-contents-variant-affected.log`.
- All shared UI tests: `flutter test test/core/ui --no-pub --reporter expanded --timeout30s`,
 exit0, `00:24 +693: All tests passed!`;
 `.dart_tool/w4c-reader-contents-variant-final-0.log`. No broad lesson/family rerun while
 unrelated known reader draft is unfinished.
- Initial scoped analysis had7 style infos; format check exit1. Corrected those styles;
 second analysis had1 trailing-comma info, also fixed. Final scoped analysis on component
 and its new test:exit0,`No issues found!`;
 `.dart_tool/w4c-reader-contents-variant-analysis-final-2.log`.
- Scoped format2 files0 changes; layering/attribution/diff checks each exit0,OK where applicable;
 `.dart_tool/w4c-reader-contents-variant-gates-0.log` through-3. Later final change was only
 the required Offset trailing comma; dart format reported0 changes. No behavior changed.

This checkpoint implements only the authorized shared variant. Task5 still needs reader bar
geometry/icon fidelity, rail tests/contrast, actual topic/day Contents, bookmark return stack,
origin labels/parser/fallback and complete affected checks. Tasks6/7/9 have not started here.
Phone visual acceptance, family completion and independent acceptance remain unverified.
Lead owns source review/upload; no own push, integration or acceptance.
