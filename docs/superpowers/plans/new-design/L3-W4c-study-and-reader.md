# L3 W4c: Study and reader (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4c-study-and-reader.md`. Base: integration branch after W2 and W4h's pattern
task. Executor: one worker, own worktree (strategy B7 as amended Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; Opus lead reviews). Landing order: W0 Task 4b (figure credits) is in the base; W4b Task 3 (`LessonDayContext`) before
Task 5; W4d Task 1 (`startLessonQuiz`, `startQuickQuiz`) before Task 7. Closes N5-1 (drag handle).

All code is in `lib/features/lesson/` (only `router.dart` imports it). Before each screen task:
open its boards and run `timeline.py`. Every task: widget tests first for each drawn state (light,
dark, 200% text, lesson text scale from W1), then code, task checks (`flutter test
test/features/lesson test/app/study_route_test.dart test/core/ui`), commit. Screens move to W1's
theme API and W2's components (the reader body uses W2's `ContentRenderer` and `MathText`, wrapped
in W1's `LessonTextScale`).

## Lead rulings, October 12 (W4c stop at 2eae3d9f)

1. ST_TopicOpen Today tag (`#6E6E73` on `#EDEDF0`, 4.34:1): text on the `fill` color uses a new
   token `onFillLabel`, light `#636366` (5.1:1 on fill), dark `#98989D` (same as secondary label,
   4.9:1 on dark fill). Add it to `pantas_colors.dart` with a token test; background as drawn. Lead
   default, reported to Aedwon, who may change it. Use this token wherever a board draws secondary
   text on `fill`.
2. BM_Edit and BM_ScreenReader drag handles (`#AEAEB2` on white, 2.21:1): use the existing
   `controlOutline` token (light `#8A8A8E`, 3.44:1; dark `#8E8E93`). A handle is a meaningful icon.
3. Reader eyebrow (Task 4): as RD_Real draws it, one line. Do not add a second name.
4. Order: do Tasks 1, 4 and 8 now, and the parts of Task 6 that do not need the day context. Tasks
   5, 7, 9 and the Home endings of Task 6 wait for W4b Task 3 (`LessonDayContext`) and W4d Task 1
   (quiz entry functions) to reach the integration branch; the lead resumes this worker then. No
   local substitutes.

5. (Added Oct 12.) Reading fraction contract: see standing ruling 5 in `L3-parallel-map.md`. Add
   it as the first commit of the next run, alone.

## Lead review clarification, October 14: Undo boundaries

Task 8 Undo must not restore a retained prior-account or prior-reset payload. Reuse the existing
SyncActiveContextStore snapshot token, which rotates on runtime quiesce/wipe and exists for an
anonymous envelope too. Capture the token with removed rows/order inside the removal transaction.
Validate the same token before any restoration writes inside the restore transaction. A mismatched
or missing current token expires the old Undo; it must not reintroduce membership or preferences.
The sheet also expires its retained Undo state when auth, exam or reset identity changes.

Preserve every recognized active snapshot. A missing legacy token may initialize only the existing
anonymous envelope through the existing store, never a new schema or account/sync mechanism.
No stable context may be cleared merely because the student removes a bookmark. Tests first:
actual wipe then held Undo; account/token change then held Undo; anonymous missing-token baseline;
exam change while the sheet survives; ordinary same-boundary Undo still restores timestamps/order
and retains newly added bookmarks. Record reproduction and exact results before acceptance.

## Task 1. Study map

Boards ST_Map, ST_MapEmpty, ST_TopicOpen, ST_Pinned; D-117 to D-125, D-140, D-141. No counts on
subjects and topics; topic ring (empty, filling, check); read lessons plain teal check, name gray, no
"Read"; unread show minutes; Today tag on today's lessons (from `roadmapTodayProvider`); one topic
open, pinned bar closes it; scroll anchoring kept; Last opened hidden until a lesson was opened;
Resume opens where the student left off (store the scroll offset with the last-opened lesson).
Keep `studyMapProvider`, `OpenTopicController`, `lastOpenedLessonProvider`.

## Task 2. Search

Boards ST_Search, ST_NoMatch; D-124. W2 `SearchField`; title folds and Cancel shows; empty query
shows RECENTLY OPENED (last three) or nothing when none (G-c-3); results "N LESSONS" with bold match
and snippet; extend `searchResultsProvider` to match topic names (returns that topic's lessons).

## Task 3. States

Boards ST_Loading, ST_Error, ST_NoLessons, ST_NoExam, RD_Error, RD_ImageFail; D-142; W4h patterns.
"Try a Quick Quiz" on ST_NoLessons only (wired in Task 7). Choose Exam opens the picker.

## Task 4. Reader body and figures

Boards RD_Real, RD_Resume, RD_RealScroll, RD_Figure; D-127, D-131, D-132, D-137, D-139. `ContentRenderer` (W2) with
Geist text and Source Serif 4 math; figures framed with expand, full screen on black with pinch zoom
and X, credit line from the image block's `asset.credit` (W0 Task 4b writes it from
`content/illustrations/sources/*.yaml`; no credit means no line; the corpus description becomes
the screen-reader text); code-drawn figures and tables in the same frame
(S0-41); a described figure with no image is skipped silently. Subject and topic eyebrow above the
title.

## Task 5. Reader bar, strip, progress line, contents

Boards RD_Contents, RD_Plan, BM_MarkTeal; D-128 to D-130, D-146. `ReaderOrigin` becomes `{ study, home, bookmarks, search,
plan, performance }`; back label names the screen it returns to (G-c-13); Home and plan pass W4b's
`LessonDayContext` (as GoRouter `extra`, with `from=home` kept for deep links). From Home: day
counter "2 of N" opens today's lessons in the contents sheet and the progress line spans the day
with ticks. Title moves into the strip over the first 90 px. Bookmark pops teal. Contents sheet on
W2 `PantasSheet`.

## Task 6. End of lesson, pull, endings

Boards RD_End, RD_TopicDone, RD_TopicShort, RD_DayDone, RD_DayEnd; D-133 to D-135, D-138. Read on reaching the end after
15 s (exists); "Quiz yourself, 5 questions" button; pull with the filling circle ("Pull up for X",
"Let go for X"), tappable circle for screen readers; next lesson is the next in topic order, read or
not (D-143: corpus order until authored order exists); last topic of the exam shows its plate with no
pull (G-c-11); from Home the day's last lesson pulls into "That's enough for today." with Back to
Home. Plates replace `bookplate.dart` (no name line; dates via `PantasDates`).

## Task 7. Quiz buttons

"Quiz yourself" calls W4d's `startLessonQuiz(lessonId)`; "Try a Quick Quiz" calls
`startQuickQuiz()`. Remove direct pushes to `/quiz/inline/...` and `/quiz`.

## Task 8. Bookmarks

Boards BM_Open, BM_Order, BM_Edit, BM_One, BM_Empty, BM_ScreenReader; D-145 to D-151. Study section
(three rows, See all, empty state), sheet on W2's 74% `PantasSheet` variant, sort Recent, Oldest,
By subject, Custom; Edit with checkboxes and drag handles (N5-1: W1 `reorder` getter); Remove with
Undo restoring exact positions; Move up and Move down for screen readers. Per-exam order and sort:
prefs keys `bookmark_order.<examId>` and `bookmark_sort.<examId>`, first read falls back to the old
global `bookmark_order` (no schema change; synced prefs shape noted in evidence). Replace
`ReorderableListView.onReorder` with `onReorderItem` or the non-deprecated API (R-21). Free for all;
no ribbon on topics, no notes (S0-30). Backend bookmark sync unchanged (G-c-28).

## Task 9. Delete and check

Delete replaced widgets and their tests (`learn_tab_home.dart` wrapper `LearnTabHome` is unused,
`dismiss_quiz_nudge.dart` has no caller, `bookplate.dart` after Task 6), stop importing retired
components. All required checks; evidence `evidence/W4c.md`; independent review; Aedwon's visual
check against the ST_*, RD_* and BM_* boards.
