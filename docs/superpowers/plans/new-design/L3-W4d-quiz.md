# L3 W4d: Quiz (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4d-quiz.md`. Base: integration branch after W2, W3 and W4h's pattern task.
Executor: one worker, own worktree (strategy B7 as amended Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; Opus lead reviews). Landing order: Task 1 before W4c's quiz-button task; W4e's
`MockCard` before Task 2.

Before each screen task: open its boards and run `timeline.py`. Every task: widget tests first per
drawn state (light, dark, 200% text, W1 lesson text scale on question bodies), unit tests per rule,
then code, task checks (`flutter test test/features/quiz test/features/review_prompt test/app`),
commit. Screens move to W1's theme API and W2's components (`FloatingBar`, `QuestionGridSheet`,
`QuestionCard`, `ChoiceRow`, `AnswerReveal`, `CenteredDialog`, `Toast`, `ScopePicker`,
`ValueWheel`). Notes gate reads W3's `proForActiveExamProvider`.

Traceability fix (Oct 6): D-242 (assessment question screen) belongs to W4a, which builds the
assessment; the row moves there.

Regression tests for GitHub issues #23 (Quiz tab stays on the assessment gate), #24, #27 and #28
(Resume card offered, unambiguous and cleared after completion) are written first in Task 2.

While W3's entitlement state is `paused` (Pro paused offline, not a quiz left partway), each Pro gate shows W2's `ProPausedLine` instead of the Pro
invitation, with a widget test (amended Oct 6, abuse review 1).

Contrast (W1 audit 1, Oct 10): this family's rebuilt screens test wrong-answer text against its real background at 4.5:1 or better in light and dark; if a board's color fails, stop and ask the lead.

## Lead rulings, October 12

Read "Standing rulings for the W4 families" in `L3-parallel-map.md` first.
1. Order: Task 1 first, alone. Second commit, alone: the Task 7 report entry function (standing
   ruling 5), with the form if it does not depend on later tasks. Then the plan in order.
2. Task 2 and W4e's `MockCard`: the Quiz tab keeps a widget slot (today `mockPanel`), and
   `lib/app/routes/quiz_routes.dart` passes `MockCard` into it. The quiz feature does not import
   `mock_exam` presentation (layering rule R2). `MockCard` and its model are on the integration
   branch from 958ed879.

## Lead clarifications, October 13

1. Task 3, Adjust in Total time mode: preserve the selected time and its question budget.
   Redistribute the budget among selected lessons within real question availability; do not let
   a stepper silently change the time wheel. QZS_1c and QZS_1d both keep 30 minutes and roughly 33
   questions while redistributing 28+5 into 20+13. QZE_One shows Questions per lesson, not Total
   time, so it is not evidence for changing the Total time budget. With one selected lesson in
   Total time, redistribution has no alternate destination; the corresponding steppers stay
   bounded and the time wheel changes the budget. Keep the drawn Adjust control in Questions
   per lesson mode. Preserve the approved real-pool shortfall behavior and Reset to the even split.
2. Task 3, seven-day recency: retain the planned AttemptsRepository.questionOutcomes query,
   supplemented by the existing ReviewStateRepository.byQuestionIds and checked-answer lastReview
   timestamps for the selected pool (only states with a real completed review, reps > 0). A checked
   answer is stored before the attempt completes; a discarded partial session therefore may have
   no saved attempt. Include those real checked answers in recency filtering. Reuse the existing
   repository API and account-boundary behavior; no schema or synchronization change. Tests cover a
   checked partial session that was discarded, a fresh seed state, the seven-day boundary and the
   required pool top-up. This fills the existing approved rule, not a new spacing decision.

3. Task 3, Adjust in Questions per lesson mode: the wheel is the base per-lesson allocation.
   Explicit row steppers may override that row's real question count within its available pool;
   recompute total questions and derived time. Do not silently move the wheel. Reset removes the
   overrides and restores the even base allocation; explicitly changing the wheel also removes
   overrides and applies the newly selected base. This keeps QZE_One's drawn Adjust useful and
   follows D-164's question-driven mode, row steppers and Reset behavior. Tests cover single-lesson
   overrides, pool bounds, totals/time, Reset and a wheel change after a manual adjustment.

4. Task 3, switching sizing modes: D-166's current "nearest matching value" means the
   closest equivalent aggregate quiz size using current selected lessons, pool caps and valid
   measured pace. Do not carry the same numeric wheel value from questions per lesson into total
   minutes. The retained July rule belonged to per-selection minutes and cannot reinstate that
   superseded meaning. Evaluate eligible destination wheel values by their actual total-question
   result; choose the closest match, with deterministic ties. Clear manual overrides on an explicit
   mode change. The first nearest match may round; repeated toggles without another user change
   must settle rather than creep. Tests cover 10 per lesson across six lessons at50seconds
   matching50 total minutes, pool shortfalls, a quantized case and repeated toggles. With no selected
   lessons, there is no aggregate size to convert; use the existing nearest valid default.
5. Task 3, measured pace: a nonpositive stored average is unavailable for duration sizing.
   Use the approved initial50-second pace consistently in core calculation and UI until a positive
   measured average exists. Guard zero/negative values before division. Tests cover zero and
   negative inputs in both core and time wheel; do not display zero-duration derived estimates for
   a nonempty quiz or manufacture an unbounded question budget.

6. Task3, positive sub-minute duration: the nonpositive-pace fallback does not replace a
   valid positive measurement. If a nonempty question-driven quiz has a positive derived duration
   that rounds to zero minutes, display the bounded value "<1" with unit "minute" in the existing
   derived metric and "under 1 min" in its summary. Do not clamp or manufacture a full minute.
   Keep zero for an empty quiz and the selected budget for Total time. Cover a real positive
   sub-minute total and ordinary/empty estimates. This is duration formatting of the existing
   approved estimator, not a new pace, layout or data source.

7. Task3, repeated-mode conversion target: actual UI reproduction found shrinking quiz size
   with pools[24,2,13], valid measured70000ms, Questions13. Stateless nearest conversion gives
   wheel sequence45min→12questions→40min→11questions across four toggles, violating rule4.
   Preserve the real aggregate question count at the first sizing-mode switch as a transient
   conversion target across subsequent mode-only toggles. Evaluate destination values against
   that same target and current real pools/valid pace; deterministic lower-wheel ties remain.
   Clear this target after an actual selection, wheel, manual allocation or Reset change, and
   when material selected-pool availability or effective pace changes. Next switch captures the
   new actual aggregate count. Clear overrides on explicit mode changes as already required.
   Reuse existing screen state; no schema, new data source, persisted history or student figure.
   Regression covers the reproduced45/13/45/13 stable sequence and each target-invalidating change.
   This preserves the approved no-creep rule rather than accepting statistical shrinkage.

8. Task3, owned async states: apply the existing W4h Task1 pattern guide. Use loadingFor
   for delayed LoadingShapes and its Loading announcement rather than an immediate local spinner;
   use errorFor('picks', retry) for picker loading failure and saveFailureLine for preference
   persistence failure, with the existing Try Again action. Retry invalidates index/pace/saved
   picks together. A launch failure uses the shared W2 StateView and plain "Could not start your
   quiz." with retrying the actual start action. Keep exception details out of interface text.
   Preserve normal picker/bar geometry. Tests first for300ms delayed shapes, announcement,
   all-input retry, save-failure retry and failed start recovery. This implements binding shared
   states instead of introducing a parallel local pattern; shared helpers/defaults stay intact.


## Lead Task4 split scope clarification, October15

DECISIONS Wording(3Oct), QV_Sources and stage0/gap-d-quiz rows3/7/40/41 define numbered
multi-session batches for today's Reviews. Custom practice remains its selected whole quiz;
new-question, lesson, past-mistake and flagged origins retain their own QV_Sources descriptions.
Do not globally split custom or relabel the legacy mixed Today plan as a review-only batch.
Real review-batch membership and actual chunking determine any printed ordinal/total, never
remaining due-count division or inferred historical sessions. Session length/order are captured
for an active batch; later preference changes apply to a new batch rather than rewriting the
active ordinal, membership or saved answers. Resume must retain that exact active definition.

Assigned source confirms no existing durable batch metadata in QuizSessionLocalRow and current
BuildTodayPlan truncates to one legacy mixed session. Before batch persistence implementation,
return a concrete bounded storage/transaction/boundary proposal to the lead using current
source. No SQL schema bump, changed questionIdsJson encoding, synthetic metadata or generic
batch infrastructure is authorized by this clarification. Independent pick/Check/reveal/grid/
flag/leave work continues. Existing missing Home shared-row/review-launch contracts remain
listed as dependencies, not replaced with a local row or fabricated review payload. The lead
records the durable representation and affected ownership before those code changes.


## Lead Task4 review-batch storage contract, October15

The lead read the actual devicePrefs/session repository, ResumeSession, BuildTodayPlan,
SyncLocalStateWiper and QuizCompletionCoordinator before accepting the worker's October15
evidence proposal with the constraints below. Implement within quiz-owned domain/application/
data and covering tests. No SQL schema/table or stored questionIdsJson/outcomesJson change,
new synchronization payload, account-wiper/security-rule edit or new generic batching framework.

- Reviews-only launch exposes real prepared review membership, actual chunk metadata and guarded
  start/continue for Home and Quiz callers. It is independent of the Home row widgets, which remain
  absent until their contract lands. Do not turn mixed Today into Reviews. Custom/other origins
  retain the existing whole session. Save this consumed contract as a verified standalone slice
  before dependent integration. The exact public API is documented in evidence with its tests.
- Store one versioned devicePrefs key quiz_review_batch.v1.<userId>.<examId>, containing version1,
  first real session UUID as batchId/anchor, stable principal/user/exam, captured local date,
  captured length/order, immutable actual question-ID chunks and their content versions,
  preassigned ordinary session UUIDs, and a validated current/next-ready lifecycle. Existing
  session rows stay authoritative for answers and terminal state. No history/unbounded keys.
- Reuse existing whole-passage grouping and hard session cap. Never split a passage set or exceed
  the chosen cap to fill a batch. Pack whole eligible groups in the existing selected order;
  finalize a shorter chunk when its next whole group cannot fit. A passage set larger than the
  captured cap remains due outside this batch under the existing PassageSetFiller contract.
  Do not count excluded work as completed or claim all reviews done. No empty chunks; All uses
  one actual eligible chunk. Print totals from actual chunks only, not ceil(due/cap).
- Capture settings/membership at new batch creation. Existing active batch resumes unchanged
  across preference/date changes. Its next session uses the next stored chunk, not a fresh
  selector. Changes apply to the next batch after finish or explicit discard.
- In one existing DB transaction, check current launch/account-lifetime guards before writes,
  honor the existing paused-session conflict decision, create first ordinary row and metadata.
  Roll back both on failure/cancel/stale principal. Never silently quit a different active
  custom/lesson/other session to claim a next review chunk.
- Advance batch lifecycle inside the existing AttemptsRepository.saveAtomically callback /
  QuizSessionRepository.completeRequired transaction, alongside the Attempt and completedAt.
  The onCommitted notification callback runs after commit and is not an atomic-write seam.
  Match current session ID/chunk/principal before mutation; retrying completion cannot advance
  twice. Next stays uncreated until explicit Start Session N or review Continue claims it.
  Next-row create and ordinal claim are one guarded transaction; concurrent claims resolve to
  the same authoritative row. Keep ordinary post-commit streak/notification ordering.
- Resume active row only if ID/user/exam/origin/question-ID order matches metadata. Store stable
  principal for process restart, use the existing runtime lifetime token for in-flight work.
  Every batch use validates the actual anchor row transactionally because generic devicePrefs
  survives wipe while quizSessions does not. Missing anchor or wrong principal invalidates and
  lazily deletes only unusable metadata, never another student's authoritative progress.
- Hydration must exactly preserve stored IDs/order and expected versions for a new batch.
  Missing/revised content fails through the existing shared load/resume error/retry path, with
  existing explicit discard available. Never shrink, replace or renumber around missing content,
  realign outcomes, or write answers against another question. Keep valid stored answers and
  batch intact for retry/discard. For legacy ordinary rows without metadata, preserve existing
  resume, require exact stored ID/order, and omit any invented ordinal/total.
- Parse version/types/nonempty unique chunks/IDs/valid ordinals and scope strictly. Malformed
  metadata cannot create a next session or produce student figures. Keep valid authoritative
  ordinary progress; report a generic shared failure rather than raw diagnostics. Remove
  orphan metadata if anchor absent. Remove terminal metadata in final completion and discarded
  metadata in its quit transaction; retain in-memory end-screen metadata needed for the actual
  completed session. No account reset assumption or stale in-memory counter as persistent ID.
- Tests first: actual chunk counts under cap/passage shortages/All; no custom split; frozen
  settings; atomic create/complete/next rollback; duplicate/concurrent claims; restart/resume;
  account/exam/lifetime changes during awaits; retained prefs after actual wipe; legacy/malformed;
  missing/revised content without answer corruption; final/discard cleanup; existing ordinary
  start/answer/complete regressions. Run affected storage/completion/sync boundary checks.
  Root personally reviews these student-data changes; Astra remains mandatory before integration.

This records implementation detail for the already approved Reviews behavior. Full Task4 and
family acceptance still require real caller wiring, checks and separate phone visual acceptance.


## Lead Task4 disabled Check label, October15

The lead opened actual QV_Answer/QV_Leave label styles and assigned PantasColors/PantasButton.
The drawn disabled Check text is light#B8B8BD; tertiaryLabel is#AEAEB2 and no current role matches.
Add W1 disabledActionLabel with light#B8B8BD and the existing dark disabled-label color#5A5A5E.
Wire normal PantasColors constructor/light/dark/copyWith/lerp behavior and focused token tests.
This is an additive semantic role for an already drawn disabled state, not a global recoloring.

Add optional PantasButton.disabledForeground defaultnull, consumed only by the ordinary disabled
foreground branch. Quiz Check opts into context.colors.disabledActionLabel. Preserve existing
enabled, busy, disabledOpacity/dimmed and all default variant behavior. Cover opt-in/default/
busy/dimmed interactions, theme transition/copy/lerp and exact Check state before save.
Ownership extends only to these two shared files and covering tests. No local button copy.

C's separate neutral variant is saved atc912fb21. D must not overwrite or copy that work; changes
remain isolated and orthogonal. The lead preserves both additive changes during eventual
integration and independently reviews any merge resolution. No cross-family merge is authorized
merely to obtain this option.

## Task 1. Start functions (lands first)

`startLessonQuiz(lessonId)`: replaces `StartInlineLessonQuiz`'s topic scope with the lesson's own
questions (W0 lesson id = question file subtopic), five questions. `startQuickQuiz()`: the existing
`StartQuickQuiz`, reached only from Study (S0-16). Both in `lib/features/quiz/application/quiz_starts.dart`.
Tests: lesson scope returns only that lesson's questions; fewer than five returns what exists.

## Task 2. Quiz tab

Boards QZ_Tab, QZ_Free, QZ_Resume, QZ_Done, QZ_First; D-156 to D-159. Today rows (Reviews, New
questions) with rings and sheets, Continue Reviews; W4e's `MockCard`; More ways to practice (Your
past mistakes with count, Customize your own, Flagged questions with count; empty states dimmed);
paused state blocks Customize your own and the mock; all done; before the assessment. Choose your
exam fallback (S0-32). Delete the study-first sheet and its storage (`_QuizNudgeSheet`,
`quizNudgeRepositoryProvider`, S0-17).

## Task 3. Customize your own and How long?

Boards QZ_Picker, QZS_1, QZS_1b, QZS_1c, QZS_1d, QZE_*; D-160 to D-166. W2 `ScopePicker` (every
lesson counts the same, "Unread" orange, "No questions yet" dimmed for topics and lessons, G-d-13),
floating bar with size and Start, How long? with Questions per lesson and Total time modes, struck-out
times, Adjust and Reset. Rules: mixed across lessons; skip questions answered in the last 7 days,
topping up with older ones before showing a smaller count (new selector over
`AttemptsRepository.questionOutcomes`); remember last picks and length (new prefs keys
`practice_last_picks.<examId>`, `practice_last_length.<examId>`); time estimate starts at 50 seconds a
question (Aedwon's approved default, D-166) and switches to the student's measured average once
`averageResponseMs` exists; a custom quiz left partway shows on the Quiz tab as paused.

## Task 4. Question screens

Boards QV_Answer, QV_Last, QV_Flag, QV_Grid, QV_GridBack, QV_Leave, QV_Long, QV_Figure, QV_MissPro, QV_MissFree, QV_GridMock (the
shared W2 sheet in mock mode, used by W4e Task 4; checked here); D-169 to
D-182. Pick then Check (split `QuizController.answer` into `pick` and `check`), colors not words,
explanation fades in, bar right or wrong color, Next and Finish; Flag in the bar, first-time toast
"Flagged. Find it in the Quiz tab." with Undo, and a short "Flag removed" toast (G-d-10); questions
sheet rules (read-only revisit with "Back to 4"); X and system back (`PopScope`) ask "Leave this
session?" once. Remove "back in X days" from the reveal (S0-14). Sessions split by the session
length setting with "Session 1 of 2" lines; wording "Session".

## Task 5. End of session

Boards QV_EndPro, QV_EndFree, QV_EndLowB, QV_EndPerfectB, QV_EndLastToday, QV_All, QV_Sources,
L_DebriefSlow (loading, only if slow); D-178. Half ring fill with popping circles, "in N minutes", YOUR MISTAKES (first three then See all),
See all questions, Pro invitation and Finish the Notes, Start Session 2 or Done; Done returns where
the session started (QV_Sources). Delete miss cause lines, return promise and the spaced-repetition
note (S0-14, S0-15). Store rating prompt after a session with 80% or more right (existing
`ReviewPromptController.maybeAsk`), with the 24-hour cool-off now recorded when the Settings Pro page
opens (`recordPaywallSeen` called from W4f's Pro page; W4f is told).

## Task 6. Viewer and notes

Boards QN_Correct, QN_Wrong, QN_WrongFree, QN_WrongOpen, QN_EditNote, QN_OwnWords; D-179, D-183,
D-276. Route `/quiz/viewer/:attemptId`. ‹ "1 of 10" ›, bar colored; Pro note icon opens "Why did you
miss it?" (I misread it, I knew it I just slipped, I didn't know it, Type my own); Add Note, Update,
Remove; writes W0's `AttemptItem.mistakeTag` (`other`) and `mistakeNote` through
`AttemptsRepository.tagItem` (extended for the note; run `flutter test test/core/storage` with
this task). Free: no icon, counter centered.

## Task 7. Report a question

Boards QN_Report, QN_ReportOffline, QN_ReportAgain, QN_ReportLimit; D-180, D-183. One-field form in
the bar, Send off until typing, thank-you line, teal icon after; limits 3 per question and 20 a day;
offline queue ("Saved. It sends when you're back online."). Client queue in
`lib/features/quiz/data/report_queue.dart` (local prefs). No backend exists: the queue holds reports
and the sender is a no-op until a function is approved (stop before any new deployed function;
report to the lead).

## Task 8. Flagged questions list

Boards: built like MK_ReviewAll rows (S0-5). Route `/quiz/flagged/:examId` rebuilt: grouped by
subject, row opens the viewer, Practice these starts a run through a declared route
(`/quiz/practice/:examId/run` with the flagged ids; the old push to the undeclared
`/quiz/session/:examId` is removed), empty state per W4h.

## Task 9. Delete and check

Delete `QuizResultsPage` and the `/review` and `/quiz/results` screens (routes already redirect via
W1), `lib/features/review/`, the old tab, panel, picker page, length wheel, debrief page and their
tests; stop importing retired components (`showInkSheet` at the questions sheet, `InkTableRow`,
`InkCheckbox`). All required checks; evidence `evidence/W4d.md`; independent review; Aedwon's visual
check against the QZ_*, QZS_*, QZE_*, QV_* and QN_* boards.


## Lead Task5 count gauge clarification, October16

The lead opened the existing HalfRingGauge and actual QV_EndPro SVG/keyframes. The existing
220x112 percentage view cannot represent its264x128/r108/16px arc and60px correct count,
24px /total, and correct label. Add a narrow named quiz-count constructor to the same shared
component, accepting real correct/total counts and preserving every existing percentage default.
Reuse the shared painter and lifecycle; the count variant selects the drawn geometry and rolling
count treatment. QVEndPro_n20/n21 move400–1600ms with cubic(.2,.8,.25,1), not the existing
percentage timing. Other end boards must be checked against their own timeline. Count semantics
announce actual correct/total, not a manufactured percentage; zero totals remain well-defined.

Ownership extends only to half_ring_gauge.dart and its focused regression tests for this
additive variant. Test exact geometry, timeline samples, rolling count, theme, reduced motion,
large text, updates/disposal, and unchanged percentage callers before the task consumes it.
Save the verified shared slice alone before the larger Task5 screen. W4e must not edit this
shared file concurrently. The lead preserves both families' needs at reviewed integration.
This implements the already approved presentation, without a new product or visual choice.


## Lead Task5/8 truthful flagged-origin clarification, October16

Root opened SessionOrigin, StartPractice.fromQuestionIds, its controller/caller, restart/resume,
Attempts origin storage, timing exclusions and the string-valued sync mapper. New flagged runs
currently persist drill, losing their real launch source. Authorize one feature-owned
SessionOrigin.flagged('flagged') using the existing origin string column, carried unchanged
through ordinary creation/completion/attempt/restart/resume. No schema or JSON/sync shape change.
The actual flagged-list launch opts in explicitly; preserve generic fromQuestionIds callers'
existing drill default rather than inferring a source from arbitrary IDs. New flagged runs
remain non-streak, timed ordinary practice, matching the prior drill behavior. Do not rewrite
legacy drill rows or infer flagged membership from current mutable flags.

Task5 can use that actual origin for approved Flagged questions wording and the actual return
stack. Legacy drill stays truthful generic quiz/practice unless actual live caller provenance
exists. Custom topic/source text comes from actual selected question lessons/topics, inline
from stored lessonId, Reviews only from validated batch data. Mixed Today never claims a
Reviews/New questions split. Preserve existing values and every exhaustive consumer.
Tests first cover flagged versus generic/custom starts, stored completion/restart/resume,
legacy drill behavior, unchanged timing/streak/metrics and truthful Done navigation. Save the
bounded origin contract separately before consumers. No generic source-metadata system,
new history, other-family caller edits or fabricated back destination.


## Lead Task5 short-duration wording, October16

Root opened the actual debrief timing builder/provider: it currently clamps measured duration
to at least one minute, which cannot represent a positive sub-minute completion truthfully.
For the approved duration line, use actual captured completion minus start. A positive
sub-minute duration reads "in under 1 minute"; exactly zero reads "in 0 minutes"; ordinary
whole-minute values use correct singular/plural. Never manufacture a minimum minute. Preserve
the actual completion endpoint across later viewing/rebuilds; reopening does not keep adding
wall time. If the source has no valid completion endpoint or has a negative duration, omit
that unavailable line instead of substituting a proxy or invented value. No new persisted
duration, pacing rule, data source or visual layout is authorized. Test positive sub-minute,
zero, one/several minutes, immutable completed timing and absent/invalid timing. This extends
existing truthful under-one-minute wording already recorded for Task3's derived duration.


## Lead Task6 note mutation contract, October22

Root inspected current AttemptsRepository.tagItem, LocalSyncMutationRecorder.runRecordedBatch, SyncActiveContextStore and the accepted W4c guarded reader pattern. Existing tagItem reads outside its recorded save transaction, so two edits can overwrite each other and a delayed rewrite can restore a wiped Attempt. Task6's planned note extension must correct this bounded path before the new viewer consumes it.

- Extend the existing tagItem path for optional note replacement and an optional FutureOr<bool> canPersist predicate. Preserve legacy callers' omitted-note behavior; explicit removal clears the note. No schema, JSON shape, new sync payload, dependency or generic mutation framework.
- Run read-modify-write inside the existing sync recorder transaction. Await the guard before the read, after the read and after the existing private write. Read the latest Attempt inside that transaction and replace only the requested item's tag/note. Concurrent edits to different items must survive. Missing Attempt or absent question membership fails without writing or recording a mutation. An expired guard rolls back the whole transaction.
- The viewer captures the original database instance, runtime account-lifetime token, selected exam and existing SyncActiveContextStore snapshot token before content/attempt hydration waits. Its predicate validates current runtime/database/exam/Pro and the original core snapshot token inside the actual mutation transaction, checking runtime validity around the token await. This includes anonymous same-identity wipes; current identity alone is insufficient. A missing initial envelope remains acceptable only while still missing; stale retry never initializes a fresh envelope or captures a replacement boundary.
- Cover actual concurrent different-item edits, removal and legacy tag-only behavior, missing/foreign membership, account/exam/Pro transitions, actual wipe/token replacement while pending, rollback and sync recording. Preserve the underlying question/answer identity and Attempt completion data. Root personally reviews the source and actual evidence before integration.

This is a technical correctness amendment within the already approved viewer/notes scope. It adds no product choice or changed student-data ownership. Full family review, final combined checks and Aedwon's phone acceptance remain separate.


## Lead Task6/8 list and flagged-viewer contracts, October22

Root inspected W2 ListRow, MathText and accepted W4e review source. W4e's review row is feature-owned, not a reusable shared contract. W2 ListRow renders only a plain String, which would print raw math in fallback question stems. Add only an optional titleWidget to that existing shared component, preserving the required title and all default Text, semantics, geometry, variants and callers. Consumers wrap MathText in a single-line DefaultTextStyle with ellipsis and no wrapping; use ordinary title for plain short labels. Save the verified shared slice separately before consumers. Ownership extends only to list_row.dart and focused title-widget/default regression tests. No generic row copy or new component system.

Task8 exposes flaggedExamReviewProvider(examId) returning existing List<ReviewEntry>. Its membership matches scopedTopicsProvider for that exam/track, preserves global stored flags, and reacts to existing flag invalidation. It supplies actual subject/passage data. Missing requested questions or required passages fail recoverably rather than silently shortening available flags or fabricating retirement. Lists show actual scoped membership only and keep the existing remove/practice behavior. No historical correctness or note data is invented for a flag.

A never-answered flag has no Attempt. The declared feature route /quiz/flagged/:examId/view/:questionId opens FlaggedQuestionViewerPage using actual scoped flagged membership, items:[] and existing report entry. It never fabricates an Attempt or miss note, and rejects a requested question outside current real membership. The existing /quiz/viewer/:attemptId remains the route for actual completed Attempts. Task8 list uses this exact route; the viewer owner registers it. Practice uses the declared /quiz/practice/:examId/run and explicit existing SessionOrigin.flagged.

This is bounded implementation detail for the approved flag list and math-capable question rows. The shared-rules adaptation for the undrawn flag list remains governed by stage0 item5; no newly designed screen or product choice is introduced. Root owns Task8 list/provider/tests and shared title-widget slice; implementor owns viewer wrapper/route registration. Both preserve other changes. Phone acceptance remains separate.
