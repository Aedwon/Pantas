# L3 W2: shared components (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 9d2c0b5f.
Level 2 plan: `L2-W2-shared-components.md`. Base: integration branch after W1 integrates.
Executor: one worker, own worktree (strategy B7 as amended Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; Opus lead reviews). Closes carry-forward N4-6.
Inventory facts (Oct 6): none of the contract names exists yet; 49 Ink-era files in
`lib/core/ui/components/`; 40 component tests plus `accessibility_test.dart` and
`math_accessibility_test.dart`.

Every task: tests first per component (each state in the L2 table, light and dark, reduce motion
shows the last frame, `expectSurvivesTextScale` at 200% from `test/helpers/accessibility.dart`),
then the component, read only W1 tokens, no business logic, no feature-file edits. One commit per
task. Before building a component, open the board named and run `timeline.py` on it.

Level 2 amendment (Oct 6, inventory): the question and content pieces used by W4a, W4c, W4d and
W4e are shared too, so W2 also owns `QuestionCard`, `ChoiceRow`, `AnswerReveal`, `PassageCard`,
`ContentRenderer` (the lesson and explanation renderer) and `PantasPage` (title, back link, large
title collapse). Recorded in the decision record; L2 W2 §3 lists them.

## Task 1. Structure

`GroupedSection`, `ListRow` (all variants), `PantasButton` and `ButtonPair`, `PantasSwitch`,
`SegmentedSwitch`, `PantasPage`. Boards: ST_Root, ST_Practice, ST_Exam, ST_Reminders_v2, HP_NoDate
(button pair), DT_TopicsA (segmented), ST_DarkRoot. Rules under test: titles one line with "…"
(D-181); value moves under the label at large text (G-a-20 stacking); stacked buttons put primary on
top, side by side primary on the right (D-67). Supersedes (callers move in W4): `settings_group`,
`ruled_section`, `ruled_panel`, `section_header`, `settings_value_row`, `ink_table_row`,
`data_row_tile`, `exam_selection_row`, `settings_switch`, `ink_checkbox`, `ink_chevron`,
`theme_control`, `board_button`, `settings_bar`, `tab_header`, `page_scaffold`.
Checks: `flutter test test/core/ui/components` green (this task's new tests plus the existing
component, `accessibility_test.dart` and `math_accessibility_test.dart` suites); `flutter analyze`
no new issues.

## Task 2. Progress marks

`ProgressRing`, `CheckMark`, `HalfRingGauge`, `AccuracyBar`, `WeekStrip`, `SortCycleButton`.
Boards: HP_Day (ring to check), HP_Free (week strip, half ring), DT_TopicsA and DT_SortFlow (bars,
sort morph), MK_Finale (gauge extension point). `AccuracyBar` color rule (D-111) tested at 30%, 40%,
60%, 80%, 95%. `WeekStrip` takes Sunday-first days from `PantasDates.weekStart`. Supersedes:
`inline_meter`, `progress_rule`, `quiz_progress_bar`, `stats_band`.
Checks: `flutter test test/core/ui/components` green (this task's new tests plus the existing
component, `accessibility_test.dart` and `math_accessibility_test.dart` suites); `flutter analyze`
no new issues.

## Task 3. Containers

`PantasSheet` (standard and 74% bookmarks variant with the settling page), `CenteredDialog`
(standard and destructive), `Toast`, `NoticeStrip`, `FloatingBar`, `QuestionGridSheet` (quiz mode
and mock mode in one component; replaces both `question_grid_sheet.dart` and the mock
`question_navigator_sheet.dart`/`mock_question_grid.dart` grids once W4d and W4e move).
Boards: BM_Open, QV_Leave, MK_Discard, QV_Flag, HP_NoDate, QV_Answer, QV_Grid, QV_GridBack, MK_Sheet,
MK_SheetCSE. Notice rules (D-66, D-68) under test: 52pt row, 44x44 close, no solid button.
Supersedes: `ink_sheet` (`showInkSheet`), `confirmation_dialog`, `error_banner` (banner use),
`proctor_toast` pattern (W4e keeps its own copy), `mock_floating_bar` (W4e moves).
Checks: `flutter test test/core/ui/components` green (this task's new tests plus the existing
component, `accessibility_test.dart` and `math_accessibility_test.dart` suites); `flutter analyze`
no new issues.

## Task 4. Inputs

`ValueWheel` (with struck-out invalid values, QZE_Short), `MonthFirstDatePicker`, `ScopePicker`
(at-least-one shake, "No questions yet" dimmed, "Unread" tag, dash for partial), `SearchField`,
`Avatar`. Boards: CM_Wheel, QZE_Short, O_DateKnown, O_DateChange, O_DateToday, ST_ExamDate,
QZ_Picker, ST_Included, ST_IncludedLast, ST_Search, ST_Avatars. Date rules D-30 to D-40 under test
(past days greyed, "Today" mark, month-only, no year limit, leap years).
Supersedes: `ink_wheel`, `exam_date_sheet`, `topic_scope_index`, `ink_magnifier`.
Checks: `flutter test test/core/ui/components` green (this task's new tests plus the existing
component, `accessibility_test.dart` and `math_accessibility_test.dart` suites); `flutter analyze`
no new issues.

## Task 5. States and marks

`LoadingShapes` (shown only after 300 ms; Pro-gate shapes still), `StepsScreen`, `StateView`
(inline and full-screen), `ProTag`, `ProPausedLine` (the approved paused line; amended Oct 6; test: the exact string "Connect once to
keep using Pro.", body text style, no button), `PlaceholderFigure` plus `test/core/ui/placeholders_test.dart`,
which scans `lib/` and lists every `PlaceholderFigure` use (W5's blocker list reads it).
Boards: L_Rules, ST_Loading, L_Restore, L_Delete, L_MockStart, YO_Error, SY_Error, YR_WrappedFree
(Pro tag). Raw error text is never shown (test passes an exception and asserts no `toString`).
Supersedes: `faint_bars`, `empty_state`. `app_error_view` is deleted by W4h Task 5, not here.
Checks: `flutter test test/core/ui/components` green (this task's new tests plus the existing
component, `accessibility_test.dart` and `math_accessibility_test.dart` suites); `flutter analyze`
no new issues.

## Task 6. Question and content pieces

`QuestionCard` (stem, subject label, figure on a white card, passage), `ChoiceRow` (picked, right,
wrong, dimmed; teal outline when picked), `AnswerReveal` (correct-answer card, "your pick" card for
Pro), `PassageCard`, `ContentRenderer` (headings, examples with SOLUTION box, quotes with rule,
lists, tables with horizontal scroll, figures framed with expand and credit, code-drawn figures in
the same frame, fallback card for unknown blocks), `MathText` (Source Serif 4, `\frac` to `\dfrac`
at top level, spoken labels, fit to width). Boards: QV_Answer, QV_MissPro, QV_MissFree, QV_Long,
QV_Figure, RD_Real, RD_Figure, RD_ImageFail.
S0-46: apply the archived patch `dirty/Pantas-wt-a11y-inline-math-sentence-r1.tracked.diff` from
`origin/archive/pre-restart-kept-work` to `math_accessibility_test.dart` first (no duplicate focus
node for inline formulas; painted-height check), then make `MathText` pass it.
Supersedes: `question_card`, `answer_row`, `answer_reveal`, `passage_card`,
`portable_text_renderer`, `inline_math_text`, `accessible_math`, `spaced_repetition_note` (deleted
by S0-15), `pennant_mark`, `bookmark_ribbon`, `contents_glyph`, `back_chevron`, `nav_glyph`
(W1 replaces its use).
Checks: `flutter test test/core/ui/components` green (this task's new tests plus the existing
component, `accessibility_test.dart` and `math_accessibility_test.dart` suites); `flutter analyze`
no new issues.

## Task 7. Gallery

`lib/core/ui/gallery/component_gallery_page.dart`, route `/settings/_gallery` in
`lib/app/routes/dev_routes.dart`, built only when `kDebugMode` (route absent in release; test
asserts `collectRoutePaths` in a release-mode build config lacks it). Lists every component and
state with a light/dark toggle for Aedwon's visual check. W4f adds the link from the debug page.
Checks: `flutter test test/core/ui/components` green (this task's new tests plus the existing
component, `accessibility_test.dart` and `math_accessibility_test.dart` suites); `flutter analyze`
no new issues.

## Task 8. Full checks and integration

All required checks; evidence in `evidence/W2.md`; GPT-6 Astra audit and the Opus lead's review; lead
integrates. Old components and their tests stay green until close-out.

## Task 9. Close-out (runs after the last W4 family integrates)

Delete every superseded file listed in Tasks 1 to 6 whose `grep -rln` caller count in `lib/` is 0,
with its test file and its `accessibility_test.dart` case; delete `ink_plate_rule.dart` (no callers
today) and `ink_sheet.dart`; delete W1's theme adapters (`AppColors`, `AppTextStyles`,
`AppDimensions`), the `SourceSans3` font files and declaration, and W1's interim redirects for
retired routes. Then `grep` for every deleted name returns nothing in `lib/` and `test/`, and
`flutter analyze` is clean with no deprecation infos. A remaining caller means a W4 family missed a
call site: report it to the lead; do not edit the feature file.
