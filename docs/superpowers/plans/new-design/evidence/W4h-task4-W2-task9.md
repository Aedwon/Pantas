# W4h Task 4 and W2 Task 9

Date: October 25, 2026. CSE PWA launch scope. Worker evidence, not lead acceptance.

## Identity and authorization

- Worktree: `/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w4h-r2`.
- Branch: `web/new-design-w4h-r2`.
- Source HEAD: `fefe36a064ebcd287c2a099488bad829da3289e4`.
- Policy and controlling documents read from existing `origin/main`, `3812935160b2d245244bc0ae92a4f85e7ddc1316`. No fetch or pull.
- Read AGENTS.md, WORKFLOW.md, SUBAGENTS.md, full L3/L2 W4h and W2 plans, PWA launch plan, and the relevant new-design STATUS rows. STATUS lives under `docs/superpowers/plans/new-design/`, not the repository root.
- Main STATUS still says A7 queued, with older unfinished W4 family rows. The current explicit assignment establishes the candidate and authorizes this check. No status lock or other worktree changed.
- No commit, staging, merge, push, deploy, dependency addition, feature-file edit, board change, or screenshot capture.

## W4h Task 4: inventory performed, clean acceptance not met

Task 4 is check-only. Family owners fix their own screens. No behavior was changed, so no new failing-first behavior test is claimed.

Actual required grep output:

```text
['grep', '-rnF', 'Error: $'] lib/features/*/presentation
(empty output)

exit: 1

['grep', '-rnE', '\\b(e|err|error|exception)\\.toString\\(\\)'] lib/features/*/presentation
lib/features/mock_exam/presentation/pages/mock_start_route.dart:181:          _errorMessage = e.toString();
lib/features/mock_exam/presentation/pages/mock_start_route.dart:245:          _errorMessage = e.toString();
lib/features/mock_exam/presentation/pages/mock_start_route.dart:355:          _errorMessage = e.toString();
lib/features/mock_exam/presentation/pages/mock_start_route.dart:552:          _errorMessage = e.toString();
lib/features/mock_exam/presentation/pages/mock_start_route.dart:705:      if (mounted) setState(() => _errorMessage = error.toString());
lib/features/quiz/presentation/quiz_controller.dart:124:      if (mounted) state = QuizFailure(e.toString());
lib/features/quiz/presentation/quiz_controller.dart:164:      state = QuizFailure(e.toString());
lib/features/quiz/presentation/quiz_controller.dart:189:      state = QuizFailure(e.toString());
lib/features/quiz/presentation/quiz_controller.dart:235:      if (mounted) state = QuizFailure(e.toString());
lib/features/quiz/presentation/quiz_controller.dart:277:      if (mounted) state = QuizFailure(e.toString());
lib/features/quiz/presentation/quiz_controller.dart:383:      state = QuizFailure(e.toString());
lib/features/quiz/presentation/quiz_controller.dart:406:      state = QuizFailure(e.toString());
lib/features/quiz/presentation/quiz_controller.dart:433:      state = QuizFailure(e.toString());

exit: 0

['grep', '-rnE', 'Text\\([^)]*\\$\\{?(e|err|error|exception)\\b'] lib/features/*/presentation
(empty output)

exit: 1
```

Classification after reading the consumers:

- `mock_start_route.dart:181,245,355,552,705` stores raw exception text. At lines 798-806 the widget displays it through ErrorBanner. Native legacy path: `mock_routes.dart:51` chooses it only when `mockUsesServerProvider` is false; that provider defaults to `kIsWeb`. Reported to W4e/lead, not edited here.
- Quiz controller's eight matches are internal failure data. `quiz_page.dart:524-530` shows `errorFor('quiz', retry)` without the stored message. These matches do not themselves expose exception text.
- Additional launch-path finding missed by the greps: `server_mock_route.dart:312-314` forwards `ServerMockException.message` into `errorFor` for `failed-precondition`. `data/server_mock_api.dart:111` copies `FirebaseFunctionsException.message` directly. `state_patterns.dart:31` renders the supplied message. Backend text can reach the CSE web mock widget. W4e/lead must decide the safe code-to-copy mapping. This worker did not edit another family's screen or invent replacement copy.

Silent-section spot checks: Home focus and Today data use `errorFor`; Home masthead handles either failed provider with a retry; Study renders a plan error when Today lessons fail; bookmarks, Study search, reader contents, assessment results, exam picker, included content and Quiz async sections have explicit error branches. No claim of exhaustive runtime failure injection. Home masthead and server mock still use FaintBars directly, retaining a retired loading component; listed below for family reconciliation.

## W2 Task 9: blocked, no retirement applied

The plan says: "A remaining caller means a W4 family missed a call site: report it to the lead; do not edit the feature file." It also requires keeping a retired component while callers remain. Remaining callers prevent complete close-out. SUBAGENTS Part 6 requires reporting stop conditions. No partial deletion set was applied or represented as completed close-out.

Inventory resolves import/export URIs to exact files. This distinguishes old question pieces from same-named replacements under `components/new_design/`.

```text
settings_group: 0 caller(s)
ruled_section: 1 caller(s)
  lib/features/mock_exam/presentation/widgets/mock_status_card.dart:3
ruled_panel: 0 caller(s)
section_header: 0 caller(s)
settings_value_row: 0 caller(s)
ink_table_row: 1 caller(s)
  lib/features/wrapped/presentation/wrapped_reveal_page.dart:5
data_row_tile: 0 caller(s)
exam_selection_row: 0 caller(s)
settings_switch: 1 caller(s)
  lib/core/ui/components/settings_value_row.dart:3
ink_checkbox: 1 caller(s)
  lib/core/ui/components/topic_scope_index.dart:2
ink_chevron: 2 caller(s)
  lib/core/ui/components/ink_table_row.dart:2
  lib/core/ui/components/settings_value_row.dart:2
theme_control: 0 caller(s)
board_button: 11 caller(s)
  lib/core/ui/components/exam_date_sheet.dart:3
  lib/core/ui/components/empty_state.dart:2
  lib/core/ui/components/confirmation_dialog.dart:2
  lib/features/mock_exam/presentation/pages/mock_start_preparation_page.dart:4
  lib/features/mock_exam/presentation/pages/mock_review_page.dart:7
  lib/features/mock_exam/presentation/pages/mock_setup_page.dart:5
  lib/features/mock_exam/presentation/widgets/mock_resume_sheet.dart:2
  lib/features/mock_exam/presentation/widgets/mock_status_card.dart:2
  lib/features/mock_exam/presentation/widgets/exam_marks_offer.dart:2
  lib/features/wrapped/presentation/wrapped_reveal_page.dart:3
  lib/features/notifications/presentation/permission_rationale_page.dart:5
settings_bar: 0 caller(s)
tab_header: 0 caller(s)
page_scaffold: 1 caller(s)
  lib/features/lesson/presentation/learn_tab_home.dart:8
inline_meter: 1 caller(s)
  lib/core/ui/components/data_row_tile.dart:2
progress_rule: 1 caller(s)
  lib/core/ui/components/quiz_progress_bar.dart:2
quiz_progress_bar: 0 caller(s)
stats_band: 0 caller(s)
ink_sheet: 1 caller(s)
  lib/core/ui/components/exam_date_sheet.dart:4
confirmation_dialog: 0 caller(s)
error_banner: 1 caller(s)
  lib/features/mock_exam/presentation/pages/mock_start_route.dart:9
ink_wheel: 1 caller(s)
  lib/core/ui/components/exam_date_sheet.dart:5
exam_date_sheet: 0 caller(s)
topic_scope_index: 0 caller(s)
ink_magnifier: 0 caller(s)
faint_bars: 8 caller(s)
  lib/features/home/presentation/widgets/home_masthead.dart:9
  lib/features/mock_exam/presentation/pages/custom_mock_setup_route.dart:13
  lib/features/mock_exam/presentation/pages/mock_start_preparation_page.dart:5
  lib/features/mock_exam/presentation/pages/mock_setup_route.dart:6
  lib/features/mock_exam/presentation/pages/mock_start_route.dart:10
  lib/features/mock_exam/presentation/pages/server_mock_route.dart:10
  lib/features/wrapped/presentation/my_shared_cards_page.dart:3
  lib/features/wrapped/presentation/wrapped_reveal_page.dart:4
empty_state: 0 caller(s)
question_card: 1 caller(s)
  lib/features/mock_exam/presentation/pages/mock_review_page.dart:10
answer_row: 1 caller(s)
  lib/core/ui/components/question_card.dart:6
answer_reveal: 2 caller(s)
  lib/core/ui/components/review_list.dart:5
  lib/features/mock_exam/presentation/pages/mock_review_page.dart:6
passage_card: 2 caller(s)
  lib/core/ui/components/review_list.dart:6
  lib/core/ui/components/question_card.dart:7
portable_text_renderer: 4 caller(s)
  lib/core/ui/components/review_list.dart:8
  lib/core/ui/components/question_card.dart:8
  lib/core/ui/components/answer_reveal.dart:5
  lib/features/mock_exam/presentation/pages/mock_review_page.dart:9
inline_math_text: 2 caller(s)
  lib/core/ui/components/answer_row.dart:2
  lib/core/ui/components/portable_text_renderer.dart:5
accessible_math: 1 caller(s)
  lib/core/ui/components/portable_text_renderer.dart:4
spaced_repetition_note: 0 caller(s)
pennant_mark: 6 caller(s)
  lib/core/ui/components/review_list.dart:7
  lib/core/ui/components/question_grid_sheet.dart:2
  lib/core/ui/components/bookmark_ribbon.dart:2
  lib/features/mock_exam/presentation/pages/mock_review_page.dart:8
  lib/features/quiz/presentation/quiz_page.dart:20
  lib/features/quiz/presentation/pages/flagged_list_page.dart:14
bookmark_ribbon: 0 caller(s)
contents_glyph: 1 caller(s)
  lib/features/lesson/presentation/widgets/reader_bar.dart:4
back_chevron: 1 caller(s)
  lib/core/ui/components/settings_bar.dart:2
nav_glyph: 0 caller(s)
ink_plate_rule: 0 caller(s)
question_grid_sheet: 0 caller(s)
```

Further retirement blockers:

- `lib/core/ui/theme/pantas_colors.dart:5` extends AppColors. `app_theme.dart` still constructs AppTextStyles and installs both compatibility extensions.
- Feature imports of AppDimensions remain in `features/shell/presentation/app_shell.dart:8`, `features/mock_exam/presentation/pages/mock_review_page.dart:13`, and deferred Wrapped.
- SourceSans3 remains referenced by the legacy passage and question-grid components. Font files and declaration remain required until callers retire.
- `pantas_type.dart:139` still returns SourceSerif4 for math. `font_licenses.dart:9` registers its license. Tests still require that font. Removing files alone would leave an invalid font contract.
- Retired-route redirects remain in onboarding, quiz, settings and mock route files. They are owned by feature families. No route was removed here.
- Wrapped is deferred at launch but still imports legacy components. Launch-only scope does not authorize deleting its live dependencies.

## Web-lineage reconciliation

Do not port B7, web content bootstrap or App Check from `web/pwa-staging-r1` here. No bootstrap file changed. On later integration, recheck loading delay and safe error/retry patterns against the web content/deferred-route lifecycle. Preserve the separate startup and App Check changes. Recheck the server mock failed-precondition message against the handed-off backend error contract. No live web or protected-content verification was performed.

## Verification

Initial `flutter test` found absent ignored generated files, including `lib/l10n/app_localizations.dart`, domain Freezed/JSON files, and Drift database files. The run was interrupted after repeated compile failures. This is environment setup failure, not a deliberate behavior RED test. Initial output remains in `build/w4h-task4-w2-task9/flutter-test.log`.

Generated ignored files using `flutter gen-l10n` (exit 0), then `dart run build_runner build --delete-conflicting-outputs` (exit 0):

```text
Built with build_runner/aot in 27s; wrote 3129 outputs.
```

Final candidate has no tracked application/test/tool diff from HEAD. Only this evidence file is untracked. Ignored generated files are setup outputs, not source changes. No behavior RED test was added or claimed.

All final commands exited 0. Actual output summaries:

```text
$ flutter test
08:41 +5059: All tests passed!

$ flutter analyze lib test tool
Analyzing 3 items...                                            
No issues found! (ran in 8.6s)

$ dart format --output=none --set-exit-if-changed lib test tool
Formatted 1598 files (0 changed) in 2.72 seconds.

$ dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK

$ dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK

$ git status --short
?? docs/superpowers/plans/new-design/evidence/W4h-task4-W2-task9.md
```

One intermediate concurrent Dart hook run failed while rewriting `objective_c.dylib` with `input file ... is not a Mach-O file`. The final layering and attribution checks were run sequentially and both exited 0. This was a tooling collision, not an attribution finding. The initial missing-generated-files run was interrupted and has no full-suite result. The complete generated-input suite above finished normally.

Local detailed outputs are under `build/w4h-task4-w2-task9/` (ignored). The final summaries above are preserved in this evidence file. No web build, backend suite, deployment, independent review or phone/visual check was run. Task 4's inventory/report is complete; its no-student-facing-raw-error acceptance is not met. Task 9 is not implemented because live callers remain. Lead-owned STATUS has not been changed or represented as current acceptance.


## Product decisions and remaining work

No product decision was made by this worker. Lead rulings needed: safe failed-precondition copy for the web mock; family ownership and scope for remaining legacy callers, fonts, theme adapters and route redirects, including native/deferred screens. Family owners must finish the caller migrations before complete W2 retirement. Aedwon retains visual acceptance. Independent review, web build/live PWA checks and launch acceptance are not claimed.
