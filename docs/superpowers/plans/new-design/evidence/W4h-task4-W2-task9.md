# W4h Task 4 fixes and W2 Task 9 close-out

Date: October 25, 2026. Worktree `Pantas-wt-new-design-w4h-r2`, branch `web/new-design-w4h-r2`. Base `ca231750`.

## Scope and authorization

The lead brief authorizes edits across W4 families, including native and deferred paths. This supersedes the original inventory-only boundary. No commit, staging, merge, push, dependency addition, protected-content rebuild, or deployment is authorized or performed. The previous run's uncommitted work was preserved.

Controlling sources: L3/L2 W2 and W4h, the October 5 amendment spec, relevant family plans and later rulings from existing `origin/main`. In this worktree those plans are available through Git. No fetch or pull. The October 14 reader ContentsGlyph ruling explicitly preserves its painter and paths. The repository's older WORKFLOW.md is absent; this brief supplies the current task and verification instructions.

## W4h Task 4

Native MockStartRoute now uses the existing `errorFor('mock', retry)` for preparation, start, resume, submit and discard failures. Each action retains its actual retry operation. Fresh-load retry invalidates failed blueprint/question-pool providers. Corrupt saved attempts retain Discard. Raw exceptions go to `telemetryProvider.recordError`.

ServerMockRoute no longer passes failed-precondition server messages into visible copy. It uses the same generic mock error and Retry. The original ServerMockException remains available to telemetry, including the message copied by the Firebase adapter. No server text is mapped into student copy.

QuizController's eight `toString()` matches are internal failure data. QuizPage uses `errorFor('quiz', retry)` and never renders that data. The initial inventory classified those as non-exposures. No change to quiz launch or persistence behavior is needed for those matches.

Tests cover native fresh-load diagnostics, generic error and successful Retry; corrupt saved-state diagnostics and Discard; and server refusal text hidden with generic copy, telemetry and successful Retry. See the failing-first and final logs below.

## W2 Task 9

Remaining legacy callers move to the named W2 replacements: GroupedSection/ListRow, PantasButton, PantasPage, LoadingShapes, current QuestionCard/ChoiceRow/AnswerReveal/PassageCard and ContentRenderer. Retired helpers with zero callers and their dedicated tests/accessibility cases are deleted. Theme users now read PantasColors/PantasType directly. AppColors, AppTextStyles and AppDimensions adapters are removed. Source Sans 3 and Source Serif 4 font files, declarations and obsolete license registration are removed. Math uses the existing KaTeX font contract.

Interim redirects for retired routes are removed. Route tests now assert live destinations and the absence of retired paths.

Kept: ContentsGlyph, because L3 W4c's October 14 Task 5 ruling explicitly requires the existing painter/paths and its optional strokeWidth. This later ruling supersedes the generic W2 retirement list for this reader control. Other retained helpers, such as ReviewList, ExamNameLine, LessonSvg, MathSupport, ReportForm and TodayQuestions, have no named replacement in the retirement plan and serve live screens.

The remaining flag callers in QuizPage, FlaggedListPage, MockReviewPage and ReviewList now use W1 PantasIcons.flag. Existing quiz pop timing, action semantics and hit targets stay in place. The old PennantMark painter/test/accessibility case is deleted. Its regression assertions failed before the replacement (resume-full-test.log), then passed in the 102-test focused run.

Final deleted-path audit: 43 component files and three theme adapters removed. Zero import/export callers remain for those 46 exact deleted Dart paths in lib/test. The audit resolves relative and package imports and distinguishes new_design replacements from their deleted same-named predecessors. Dedicated obsolete tests are removed; surviving renderer, accessibility, theme and screen tests target current replacements. The source changes also cover figure/preview-tool token consumers after adapter removal.

## Failing-first evidence

The interrupted earlier run saved actual RED results in `build/w4h-task4-w2-task9/`:

- `run2-red.log`: server refusal still visible, and corrupt saved-state diagnostics still visible. 26 passed, 2 failed.
- `run2-retry-red.log`: native generic error could not recover to Start the Paper after Retry. 0 passed, 1 failed.
- `run2-migration-red.log`: font retirement contract, current review pieces and preparation loader/button expectations. 25 passed, 4 failed.
- `run2-page-red.log` and `run2-routes-red.log`: current page/retired-route expectations before migration.

Resume started with `git status --short` and `git diff --stat`: 174 changed files, 752 insertions and 10,076 deletions. No changes were reverted. The resumed suite reproduced stale expectations in ReviewList, image-rendering tests and a Settings redirect test. Those assertions now target the actual replacement contracts. The first resumed broad run reached 4,797 passes and 11 failures, including the two intentional flag RED assertions. It was interrupted while the roadmap property test was still running and is not full-suite evidence. All nine stale-contract assertions were corrected. A separate probe demonstrated progress through generated cases, and the unmodified property test passed alone: `03:53 +1: All tests passed!`.

`resume-focused.log`: `00:07 +102: All tests passed!`, covering ReviewList, image renderer, router redirects, quiz flags and StartTodaySession. The reported StartTodaySession failure did not reproduce; no domain/storage source or test change was made to hide it.

First resumed analysis found 12 style infos. Existing changed code/tests were corrected for import ordering, trailing commas and one redundant default argument. Final analysis is clean.

## Verification

Detailed local logs are under `build/w4h-task4-w2-task9/` (ignored). All requested gates passed on the final source. The full run completed normally with exit 0. No application/test/tool source changed during the final run.

```text
$ flutter test --reporter expanded
09:58 +4804: All tests passed!

$ flutter analyze lib test tool
Analyzing 3 items...
No issues found! (ran in 10.8s)

$ dart format --output=none --set-exit-if-changed lib test tool
Formatted 1515 files (0 changed) in 3.71 seconds.

$ dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK
```

No phone/screenshot check, live web build, backend suite or independent review is claimed. Aedwon's visual acceptance remains separate.

## Final attribution and working-tree output

```text
$ dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK

$ git status --short
 D assets/fonts/OFL-SourceSans3.txt
 D assets/fonts/OFL-SourceSerif4.txt
 D assets/fonts/SourceSans3-Bold.ttf
 D assets/fonts/SourceSans3-Regular.ttf
 D assets/fonts/SourceSans3-SemiBold.ttf
 D assets/fonts/SourceSerif4-Regular.ttf
 D assets/fonts/SourceSerif4-Semibold.ttf
 M docs/superpowers/plans/new-design/evidence/W4h-task4-W2-task9.md
 M lib/app/routes/mock_routes.dart
 M lib/app/routes/onboarding_routes.dart
 M lib/app/routes/quiz_routes.dart
 M lib/app/routes/settings_routes.dart
 D lib/core/ui/components/accessible_math.dart
 D lib/core/ui/components/answer_reveal.dart
 D lib/core/ui/components/answer_row.dart
 D lib/core/ui/components/back_chevron.dart
 D lib/core/ui/components/board_button.dart
 D lib/core/ui/components/bookmark_ribbon.dart
 D lib/core/ui/components/confirmation_dialog.dart
 M lib/core/ui/components/content_renderer.dart
 M lib/core/ui/components/contents_glyph.dart
 D lib/core/ui/components/data_row_tile.dart
 D lib/core/ui/components/empty_state.dart
 D lib/core/ui/components/error_banner.dart
 D lib/core/ui/components/exam_date_sheet.dart
 M lib/core/ui/components/exam_name_line.dart
 D lib/core/ui/components/exam_selection_row.dart
 D lib/core/ui/components/faint_bars.dart
 D lib/core/ui/components/ink_checkbox.dart
 D lib/core/ui/components/ink_chevron.dart
 D lib/core/ui/components/ink_magnifier.dart
 D lib/core/ui/components/ink_plate_rule.dart
 D lib/core/ui/components/ink_sheet.dart
 D lib/core/ui/components/ink_table_row.dart
 D lib/core/ui/components/ink_wheel.dart
 D lib/core/ui/components/inline_math_text.dart
 D lib/core/ui/components/inline_meter.dart
 D lib/core/ui/components/nav_glyph.dart
 D lib/core/ui/components/page_scaffold.dart
 M lib/core/ui/components/pantas_page.dart
 D lib/core/ui/components/passage_card.dart
 D lib/core/ui/components/pennant_mark.dart
 D lib/core/ui/components/portable_text_renderer.dart
 D lib/core/ui/components/progress_rule.dart
 D lib/core/ui/components/question_card.dart
 D lib/core/ui/components/question_grid_sheet.dart
 D lib/core/ui/components/quiz_progress_bar.dart
 M lib/core/ui/components/review_list.dart
 D lib/core/ui/components/ruled_panel.dart
 D lib/core/ui/components/ruled_section.dart
 D lib/core/ui/components/section_header.dart
 D lib/core/ui/components/settings_bar.dart
 D lib/core/ui/components/settings_group.dart
 D lib/core/ui/components/settings_switch.dart
 D lib/core/ui/components/settings_value_row.dart
 D lib/core/ui/components/spaced_repetition_note.dart
 D lib/core/ui/components/stats_band.dart
 D lib/core/ui/components/tab_header.dart
 D lib/core/ui/components/theme_control.dart
 D lib/core/ui/components/topic_scope_index.dart
 M lib/core/ui/figures/biology_diagram_figure.dart
 M lib/core/ui/figures/chart_figure.dart
 M lib/core/ui/figures/chemistry_diagram_figure.dart
 M lib/core/ui/figures/concept_diagram_figure.dart
 M lib/core/ui/figures/coordinate_graph_figure.dart
 M lib/core/ui/figures/cube_net_figure.dart
 M lib/core/ui/figures/earth_science_diagram_figure.dart
 M lib/core/ui/figures/figure_matrix_figure.dart
 M lib/core/ui/figures/figure_series_figure.dart
 M lib/core/ui/figures/fluid_vessel_figure.dart
 M lib/core/ui/figures/gear_train_figure.dart
 M lib/core/ui/figures/geometry_diagram_figure.dart
 M lib/core/ui/figures/lesson_figure_widget.dart
 M lib/core/ui/figures/lever_balance_figure.dart
 M lib/core/ui/figures/paper_fold_figure.dart
 M lib/core/ui/figures/physics_energy_diagram_figure.dart
 M lib/core/ui/figures/physics_mechanics_diagram_figure.dart
 M lib/core/ui/figures/pulley_system_figure.dart
 M lib/core/ui/figures/question_figure.dart
 M lib/core/ui/figures/reading_diagram_figure.dart
 M lib/core/ui/figures/shape_row_figure.dart
 M lib/core/ui/figures/spring_scale_figure.dart
 M lib/core/ui/figures/stability_shape_figure.dart
 M lib/core/ui/severity.dart
 D lib/core/ui/theme/app_colors.dart
 D lib/core/ui/theme/app_dimensions.dart
 D lib/core/ui/theme/app_text_styles.dart
 M lib/core/ui/theme/app_theme.dart
 M lib/core/ui/theme/font_licenses.dart
 M lib/core/ui/theme/pantas_colors.dart
 M lib/core/ui/theme/pantas_type.dart
 M lib/features/home/presentation/widgets/home_masthead.dart
 M lib/features/lesson/presentation/learn_tab_home.dart
 M lib/features/mock_exam/presentation/pages/custom_mock_setup_route.dart
 M lib/features/mock_exam/presentation/pages/mock_review_page.dart
 M lib/features/mock_exam/presentation/pages/mock_setup_page.dart
 M lib/features/mock_exam/presentation/pages/mock_setup_route.dart
 M lib/features/mock_exam/presentation/pages/mock_start_preparation_page.dart
 M lib/features/mock_exam/presentation/pages/mock_start_route.dart
 M lib/features/mock_exam/presentation/pages/server_mock_route.dart
 M lib/features/mock_exam/presentation/widgets/exam_marks_offer.dart
 M lib/features/mock_exam/presentation/widgets/mock_resume_sheet.dart
 M lib/features/mock_exam/presentation/widgets/mock_status_card.dart
 M lib/features/mock_exam/presentation/widgets/score_headline.dart
 M lib/features/notifications/presentation/permission_rationale_page.dart
 M lib/features/quiz/presentation/pages/flagged_list_page.dart
 M lib/features/quiz/presentation/quiz_page.dart
 M lib/features/shell/presentation/app_shell.dart
 M lib/features/wrapped/presentation/my_shared_cards_page.dart
 M lib/features/wrapped/presentation/share_privacy_sheet.dart
 M lib/features/wrapped/presentation/wrapped_reveal_page.dart
 M pubspec.yaml
 M test/app/router_paths_preserved_test.dart
 M test/app/router_redirect_test.dart
 M test/app/router_settings_test.dart
 M test/core/ui/components/accessibility_test.dart
 D test/core/ui/components/answer_reveal_test.dart
 D test/core/ui/components/answer_row_test.dart
 D test/core/ui/components/board_button_test.dart
 D test/core/ui/components/confirmation_dialog_test.dart
 D test/core/ui/components/data_row_tile_test.dart
 M test/core/ui/components/destructive_contrast_test.dart
 D test/core/ui/components/empty_state_test.dart
 D test/core/ui/components/error_banner_test.dart
 D test/core/ui/components/exam_date_sheet_test.dart
 M test/core/ui/components/exam_name_line_test.dart
 D test/core/ui/components/exam_selection_row_test.dart
 D test/core/ui/components/faint_bars_test.dart
 D test/core/ui/components/ink_checkbox_test.dart
 D test/core/ui/components/ink_chevron_test.dart
 D test/core/ui/components/ink_plate_rule_test.dart
 D test/core/ui/components/ink_sheet_test.dart
 D test/core/ui/components/ink_table_row_test.dart
 D test/core/ui/components/ink_wheel_test.dart
 D test/core/ui/components/inline_math_text_test.dart
 M test/core/ui/components/lesson_svg_test.dart
 M test/core/ui/components/math_accessibility_test.dart
 D test/core/ui/components/nav_glyph_test.dart
 D test/core/ui/components/pennant_mark_test.dart
 D test/core/ui/components/portable_text_renderer_test.dart
 D test/core/ui/components/progress_rule_test.dart
 D test/core/ui/components/question_card_test.dart
 D test/core/ui/components/question_grid_sheet_test.dart
 M test/core/ui/components/review_list_test.dart
 D test/core/ui/components/ruled_panel_test.dart
 D test/core/ui/components/ruled_section_test.dart
 D test/core/ui/components/section_header_test.dart
 D test/core/ui/components/settings_group_test.dart
 D test/core/ui/components/settings_switch_test.dart
 D test/core/ui/components/settings_value_row_test.dart
 D test/core/ui/components/spaced_repetition_note_test.dart
 D test/core/ui/components/stats_band_test.dart
 D test/core/ui/components/tab_header_test.dart
 D test/core/ui/components/theme_control_test.dart
 D test/core/ui/components/topic_scope_index_test.dart
 M test/core/ui/figures/lesson_original_code_a_test.dart
 M test/core/ui/figures/lesson_original_code_b_test.dart
 D test/core/ui/theme/app_colors_test.dart
 D test/core/ui/theme/app_dimensions_test.dart
 D test/core/ui/theme/app_text_styles_test.dart
 M test/core/ui/theme/app_theme_test.dart
 M test/core/ui/theme/font_licenses_test.dart
 M test/core/ui/theme/fonts_declared_test.dart
 M test/core/ui/theme/pantas_theme_test.dart
 M test/core/ui/theme/pantas_type_test.dart
 M test/features/lesson/presentation/learn_tab_home_test.dart
 M test/features/lesson/presentation/topic_ending_page_test.dart
 M test/features/mock_exam/presentation/mock_review_page_test.dart
 M test/features/mock_exam/presentation/mock_start_route_persistence_test.dart
 M test/features/mock_exam/presentation/pages/mock_start_preparation_page_test.dart
 M test/features/mock_exam/presentation/server_mock_route_test.dart
 M test/features/quiz/passage_regression_test.dart
 M test/features/quiz/presentation/pages/flagged_list_page_test.dart
 M test/features/quiz/presentation/quiz_page_chrome_test.dart
 M test/features/shell/app_shell_test.dart
 M test/helpers/pump_app.dart
 M test/tools/lesson_illustration_preview_renderer_test.dart
 M tools/lesson_author/illustration_preview_renderer.dart
 M tools/lesson_author/render_illustration_previews_test.dart
```

## Completion and limits

- W4h Task 4 fixes: done for every student-facing raw-error exposure in the inventory, including the native path. Internal QuizFailure data is still not rendered.
- W2 Task 9: caller migrations, unused component/test deletion, theme/font retirement and interim-route close-out are done. ContentsGlyph is retained under the later explicit reader ruling.
- The reported StartTodaySession failure did not recur in either the focused or final full run. No unrelated quiz/roadmap behavior was changed.
- Verification: 4,804 tests passed, scoped analysis clean, format unchanged, layering OK, attribution OK. Final git status is pasted above. All 179 changed paths remain uncommitted. No new dependency or attribution text was introduced.
- Visual/device acceptance, web build/live PWA checks, backend tests and independent review were not run. This is implementation evidence, not a claim of those separate approvals.


## Review fixes, October 26, 2026

Lead brief: two bounded review fixes on clean base
`5ac7888bd945670e81e73be7bb882a0a151c23f7`, in the assigned worktree only.
Policy read with `git show origin/main:<file>` at
`44afc369259e599acdfdc6417d808014e578c1fc`: AGENTS.md, WORKFLOW.md,
SUBAGENTS.md and linked startup/routing/resource guidance. No fetch or pull.
Read L2/L3 W4h and W2, the amendment spec, and the parallel map from that
existing reference. This brief authorizes the native retry and test changes.
No staging, commit, merge, push, dependency addition, protected-content build,
key access or other worktree edit was performed.

### Item 1: scoring-load retry

The submit error's Try Again callback now invalidates
`mockScoringQuestionsProvider(attemptId)` before submitting again.
The widget test starts a real seeded paper, answers one question, submits,
observes a scoring-load failure and an unfinished attempt, clears the cause,
and taps Try Again. It checks a second load, results navigation, completed
persistence and a score of 1 out of 2. The generic error hides diagnostics.

Failing first: `build/w4h-review-retry-red.log`, exit 1. After correcting an
initial test assertion that compared a database string to the domain enum,
the unchanged production code failed at the intended retry assertion:

```text
Expected: <2>
  Actual: <1>
00:00 +0 -1: Some tests failed.
```

### Item 2: restored fraction coverage

Restored all eight deleted `displayFractions` cases in
`test/core/ui/components/math_support_test.dart`, importing the surviving
`math_support.dart` used by ContentRenderer. These cover braceless fractions,
adjacent fractions, numerator and denominator nesting, nesting inside an
existing dfrac, already-promoted input, and input without fractions.
The original helper passes all eight. No math regression or math source change
was needed.

These are restored coverage, not a newly reproduced production defect.
To check that the assertions can fail, temporarily disabled promotion and then
temporarily promoted every fraction, including nested ones. Both mutations
were restored immediately, before final verification:

```text
$ flutter test test/core/ui/components/math_support_test.dart
# Promotion disabled, build/w4h-review-math-mutation-red.log, exit 1
00:00 +3 -5: Some tests failed.
# Every fraction promoted, build/w4h-review-math-nesting-red.log, exit 1
00:00 +5 -3: Some tests failed.
```

The second mutation failed the numerator, denominator and existing-dfrac
nesting cases. The first failed promotion, braceless and adjacent cases.

Renewed focused check on restored source, exit 0:

```text
$ flutter test test/features/mock_exam/presentation/mock_start_route_persistence_test.dart test/core/ui/components/math_support_test.dart
00:02 +20: All tests passed!
```

Files touched: native MockStartRoute, its persistence widget test, the new
math_support_test.dart and this evidence file. No other source files changed.
Independent review and visual/device acceptance remain with the lead.

### Review-fix verification

All commands ran locally. Flutter 3.44.6 (ee80f08bbf), Dart 3.12.2.
Full-suite source remained unchanged throughout its run. Initial scoped analysis
then found one required trailing comma in the new test. Added that comma and
reran the affected tests and every remaining gate. This formatting-only change
did not change test assertions or behavior. No second full-suite run is claimed.

Final code/test identity: SHA-256 of `git diff -- lib test` followed by the new
math_support_test.dart bytes: `cb7df56957d359fe15099abd2d72146751ad98591e79b88c0e78eecd23420aee`.
Ignored raw logs: `build/w4h-review/` and `build/w4h-review-*.log`.

Actual summaries (each command exited 0):

```text
$ flutter test
16:22 +4813: All tests passed!

$ flutter test test/features/mock_exam/presentation/mock_start_route_persistence_test.dart test/core/ui/components/math_support_test.dart
00:08 +20: All tests passed!

$ flutter analyze lib test tool
Analyzing 3 items...
No issues found! (ran in 29.0s)

$ dart format --output=none --set-exit-if-changed lib test tool
Formatted 1516 files (0 changed) in 5.40 seconds.

$ dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK

$ dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK

$ git status --short
 M docs/superpowers/plans/new-design/evidence/W4h-task4-W2-task9.md
 M lib/features/mock_exam/presentation/pages/mock_start_route.dart
 M test/features/mock_exam/presentation/mock_start_route_persistence_test.dart
?? test/core/ui/components/math_support_test.dart
```

`git diff --check` also exited 0. Both review items are implemented and tested.
No unresolved finding or stop condition remains from this assignment.
No backend, device, screenshot, visual acceptance or independent review is claimed.
The lead owns review and commit.
