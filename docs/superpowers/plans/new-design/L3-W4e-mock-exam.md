# L3 W4e: mock exam (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4e-mock-exam.md`. Base: integration branch after W2, W3 and W4h's pattern task.
Executor: one worker, own worktree (strategy B7 as amended Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; Opus lead reviews); if the worker stops twice on Task 6 (the finale), the
lead re-plans it.
Landing order: Task 1 (`MockCard`) before W4d's Quiz tab task. Closes N5-2 (decoding old results).

Before each screen task: open its boards and run `timeline.py`. Every task: widget tests first per
drawn state (light, dark, 200% text, reduce motion last frame), unit tests per rule, then code, task
checks (`flutter test test/features/mock_exam test/app`), commit. W1 theme API, W2 components.

Pro gates read W3's `proForActiveExamProvider` (Pro for the active exam), never `proIsActive` (level 3 gate review 2).

While W3's entitlement state is `paused`, each Pro gate shows W2's `ProPausedLine` instead of the Pro
invitation, with a widget test (amended Oct 6, abuse review 1).

Contrast (W1 audit 1, Oct 10): this family's rebuilt screens test the last-minute timer against its real background at 4.5:1 or better in light and dark; if a board's color fails, stop and ask the lead.

## Task 1. Mock card (lands first)

`MockCardModel` and `MockCard` in `lib/features/mock_exam/presentation/widgets/mock_card.dart`,
replacing `MockPanel`. Boards QZ_Tab, QZ_Free, QZ_Resume, QZ_First (card part); D-157. States: never
taken, Free waiting ("Your next one opens Fri, Oct 10." with View Last Results), Pro, in progress with
Resume, paused-quiz block, custom track ("Set one up", "Change the setup"). Free limit from W3
`mockLimit(examId)` (replaces the 14-day constant in `mock_availability_provider.dart`).

## Task 2. Data and scoring

Fill W0's JSON fields: `SectionResult.wrong` and `blank` in `compute_results.dart` and
`submit_mock.dart`; mock answer `missReason`, `blankReason`, `reasonNote` written by the review.
Per-exam scoring rule: UPCAT right minus a quarter per wrong, blanks zero (D-193), others right over
total; the score is computed from the stored counts, never stored as a rounded decimal; retired
questions leave the total (G-e-13). Fix the percent defect (fraction in `mock_results_route.dart`,
0 to 100 in `compute_results.dart`): one representation, 0 to 100, with a test. N5-2: the encoder is
`submit_mock.dart` `_sectionResultsJson` (writes `wrong` and `blank`); the one decoder is the section
parse in `mock_results_route.dart`, which recomputes null `wrong` and `blank` from `answersJson` for
old rows. The metrics reader (`lib/features/metrics/signals/mock_payload_reader.dart`) is unchanged;
a test shows it ignores the new keys (run `flutter test test/features/metrics` with this task).
Questions avoid the student's last two finished mocks for the exam (pass their ids to the sampler,
S0-28). Tests for each rule.

## Task 3. Setup

Boards MK_Setup, MK_SetupStrict, MK_SetupDCAT, MK_SetupCSE, L_MockStart (setting out the paper); D-186, D-198. Table with total row, how
it runs, what is left out; strict switch on this screen applies to this mock only (default from
Settings, S0-38); short-paper line when the bank cannot fill a part (S0-29); "Start the Mock Exam"
with "The clock starts when you tap.". Blueprints: author `content/mock/cse_pro.yaml`,
`cse_sub.yaml` and `acet.yaml` with W0's placeholder marker (first make the app's blueprint
readers accept the marker, `BlueprintValue.fromJson`, with a test; they read plain integers today;
W0 audit, Oct 6) on CSE per-subject item counts and the
ACET aptitude time (R-20), shown through W2 `PlaceholderFigure`; tell the content track first.
These content files need the signed package rebuilt before release: the release package is built once
after the last content change, in W5 Task 1, before the other W5 checks (W0 Task 6 procedure, Aedwon's authorization).

## Task 4. The paper

Boards MK_Paper, MK_FiveMin, MK_LastMinute, MK_Proctor, MK_LastQ, MK_EndEarly, MK_Sheet, MK_SheetCSE,
MK_SubmitCSE, MK_BetweenA, MK_PartEnded; D-187 to D-189, D-195. Centered clock with hours, thick bar
amber under 5 minutes, red in the last minute; pause on the right (gone in strict); part named above
the question; floating bar with centered counter; proctor calls at 10, 5, 1; End Part on the last
question; between-parts screen with the clock stopped (wire `PartTransitionPage`'s replacement);
one-block exams submit from the sheet. Close with a declared route, not `context.go('/')`.

## Task 5. Pause, strict mode, leaving, recovery

Boards MK_PauseWarn, MK_PauseA, MK_PauseFlow, MK_Discard, MK_Forfeit, MK_LastQStrict (strict on:
no pause, › dimmed with a quiet line saying why); D-190, D-191; S0-37. Pause
warning with "Don't show this again" stored in app preferences (`mock_pause_warning_seen`);
hourglass; discard deletes answers and does not use up a mock. Strict grace 10 seconds (change
`strict_mode_lifecycle.dart` from 5), then Not finished with everything answered scored. Strict off:
leaving the app pauses; system back acts like pause (strict off) or is blocked with a line (strict
on). Reopening resumes with the clock having run; time run out while closed goes to results; a broken
saved mock offers Discard.

## Task 6. Finale and results

Boards MK_Finale, MK_FinaleUPCAT, MK_Results, MK_ResultsFree, MK_PastFreeOpen, MK_PastFreeLocked,
MK_PastPro, MK_Forfeit; D-192 to D-194, D-197, S0-2. The end animation as one sequence (keep order
and overlaps; if any part cannot be built as drawn, stop and ask); W2 `HalfRingGauge` with the
two-ball UPCAT variant; PERFORMANCE BREAKDOWN bars; VERSUS PAST RESULTS only with earlier mocks; See
all questions (Pro, and Free until the next mock opens; then score and breakdown only with "Go
through all N questions again with Pro."); after a Pro lapse the Free rule applies (Aedwon, Oct 6);
no pill, confetti, comparison sentence or Strict badge (S0-27); Done returns where results were opened. Remove the "Reopens
in 7 days." footer.

## Task 7. All questions after a mock

Boards MK_ReviewWrong, MK_ReviewAll, MK_ReviewFlagged, MK_ReviewQ, MK_ReviewQNote, MK_ReviewQFree,
MK_ReviewBlank, MK_ReviewWrongFree; D-196, D-197. Tabs All, Wrong, Flagged (Wrong first), rows by
part, viewer moving through the tab, notes (Pro) writing `missReason` and `reasonNote`, blank reasons
writing `blankReason`, save-flags offer on the Flagged tab only; flags never gated.

## Task 8. Custom-track mock setup

Boards CM_Setup, CM_Wheel, CM_Breakdown, CM_Ceiling; D-243; S0-39. Questions and Time open in place
(W2 `ValueWheel`, no sheets); section breakdown; ceiling in red with Tick More Subjects; unset subject rows
block Save with a line (G-e-20); reopening a
saved setup shows its saved values; the track name replaces the exam name.

## Task 9. Delete and check

Delete `MockPanel`, the value wheel sheets, the mock questions sheet (replaced by W2
`QuestionGridSheet` mock mode), `mock_floating_bar.dart` (replaced by W2 `FloatingBar`), the unwired
history page, the `/mock-exam` stub screen, and their tests. All required checks; evidence
`evidence/W4e.md`; independent review; Aedwon's visual check against the MK_* and CM_* boards.


## Lead Tasks4–6 ownership and shared contract clarification, October16

Task3 remains separately owned and unverified. Its fifteen saved draft paths are snapshotted
by SHA256 before Tasks4–6 work. The lead inspected the full mock_start_route.dart Task3 diff: it
adds strictMode input, prepared blueprint/sample/parts, delayed explicit start and preparation
view. Those exact additions and setup behavior must be preserved, never absorbed into a verified
Task4/5 commit or silently repaired. Tasks4/5 may edit only existing running-session lifecycle,
paper/grid/pause/part/exit wiring in that shared file. Keep an exact Task3 patch and exclude its
hunks when staging; verify the actual staged/committed Task4/5 candidate in isolation without
Task3 drafts before claiming verification. If the changes cannot remain independent, leave only
that integration pending and report the precise required Task3 contract. Other fourteen Task3
paths stay byte-for-byte unchanged. No Task3 takeover or completion claim is authorized.

The lead opened W2 new_design/QuestionGridSheet and CenteredDialog, plus MK_SheetCSE and
MK_SubmitCSE. Neither exposes the drawn one-block submit action. Authorize only these additive
shared extensions and focused tests before mock callers: an optional grid footer/action child
(default null), rendered in the existing sheet after its ordinary grid/help content, with drawn
spacing; an opt-in non-destructive inline action layout in CenteredDialog, with filled accent
primary/onAccent and fill/label cancel, existing inline pill geometry, and ordinary keyboard/
focus/large-text behavior. Preserve all quiz grid and dialog defaults and existing destructive
actions. Do not call a submit action destructive merely to obtain its layout, build a local
dialog/grid copy, or omit an implementable required submit action. W4e owns these two extensions
in its own worktree and saves them as a verified standalone slice. D's separately saved grid
changes must remain intact at eventual reviewed integration. No other W2 ownership is granted.

W4d currently owns an additive quiz-count HalfRingGauge extension in its separate worktree.
W4e must use existing percentage/overlay contracts while it inspects its finale, and report
any concrete additional gap before editing that shared file. No concurrent shared-gauge edits
or approximate animation substitution is authorized.


### October16 saved Task3 base update

The separate Task3 author committed and uploaded ac712f6fd18042cf37f4a3f17a68386e026af207
(parent5e6cda45) during the usage stop. Fresh fetch confirms local/remote matching; Task3 paths
are clean. Tasks4–6 use this committed source base and preserve its preparation/explicit-start
behavior. The prior dirty Task3-hunk exclusion/isolated-index requirement is now inapplicable.
Normal Task4/5 runtime edits may commit on this base. This source-availability update does not
claim independent acceptance or authorize reworking Task3, its setup, blueprints or content.


## Lead Task4 between-parts recovery clarification, October16

Root opened MockSessionController, SnapshotCodec, MockFlushPayload, ResumeMock and the mock sync
mapper. The controller advances parts immediately and existing saved session metadata has no
between-parts state. The approved stopped-clock transition must survive process closure, rather
than opening the next part before explicit Start. Authorize additive optional boolean fields
betweenParts and endedEarly in the existing feature-owned _session JSON envelope, carried by
its snapshot/flush path. Absent fields preserve legacy running behavior. Existing question/sample/
answer encodings, SQL schema, sync envelope/mapper and other data-layer contracts stay intact.
The sync mapper already carries this JSON as an opaque string; no sync protocol change is needed.

Persist actual next-part index/position with its unstarted clock and transition metadata in
the same existing progress write. Resume restores the between-parts page and stopped clock;
it never starts a part merely by reopening. Count closed-part answers/blanks from real data,
without flags in the transition dots. Only explicit Start clears the gate and starts the
next-part clock; persist that new authoritative state in order before later progress writes.
Between-parts wall time cannot consume the next part. Preserve the approved strict-background
grace/recovery precedence rather than using a pause marker to bypass strict mode. Validate
metadata types and consistency with real frozen parts/current index; malformed state uses
existing recovery/error/discard, never a guessed transition or remapped saved answers.

Tests first: elapsed and early endings, persisted transition/reopen, no running time while
waiting, exactly-once explicit Start, old snapshots, invalid fields, last-part submission,
queued flush ordering/failure and strict-background/expiry precedence. Use feature-owned
controller/snapshot/flush/resume paths and tests only. Save the data contract as a verified
bounded slice before presentation integration. Root reviews this student-data change; no
new generic persistence framework, schema migration, core sync/wiper edit or product choice.


## October19 PWA web mock adapter ruling

Approved PWA plan A4/C8b and pwa-launch/W4-client-coordination.md supersede local-only web
paper/clock/allowance assumptions. Root inspected staging2c2332e0 mock.ts and CSE blueprints,
then reviewed the implementor's narrow proposal before dependent production changes.

Ownership extends to feature-owned data/server_mock_api.dart, domain/server_mock_paper.dart,
application/server_mock_session.dart, their focused tests and existing mock routes/providers.
Use a concrete callable adapter with an injected function for tests, not a new shared protocol
or framework. Select one web owner at the existing route/platform seam; preserve native
sampler/part flow and Task3's explicit Start. No core content, storage schema, sync/wiper,
Claude-owned branch or server edits. Existing content repository signatures hydrate pinned
question ids/set ids through C7; never sample a replacement web paper.

Decode actual startMock/getMockPaper/controlMock/submitMock responses. Account/mock/exam ids
and paper identity come from the server; an existing open paper can name a different exam
from current selection and must not be remapped. Show server remainingMs with a monotonic
display-only elapsed anchor. Each server response replaces authoritative state. Web CSE uses
one overall clock; no invented sectional timing. Cursor/flags use existing feature-local
cache under original uid+mockId only. No local web allowance or local authoritative result
scoring. Save, pause, resume, discard and submit follow actual named server operations.

Retain original account/session ownership across awaits. Reject queued work and stale UI/cache
publication after actor/exam/disposal changes. Order answer/control writes so delayed earlier
saves cannot replace newer answers or follow acknowledged submission. Failed operations keep
the original immutable intended payload for Retry; do not rerun indices against mutated state.
Test actual ordinary, retry, auth/disposal, delayed-call, server refusal and expired-paper paths.
Validate decoded ids, question uniqueness, types and finite time values; malformed responses
use existing error/recovery, not guessed paper or durations. Avoid empty save payloads that the
actual server rejects; blank answers must describe real pinned questions. Do not call on clock
ticks. No pending credentials or live deployment is required for fake/emulator contract checks.

Setup may read server/catalog blueprint values and actual returned identity, preserving explicit
Start and existing presentation. Do not rewrite separately authored source/content blueprints.
Professional155 test questions are approved; the170-item explanatory UI sentence is not yet
approved. Other launch-exam limits follow current approved PWA records, not old placeholders.

Production card availability, completed results/history/review remain blocked on the Claude
server-owned reader for nextEligibleAt/status, score/breakdown/duration/endedBy/submittedAt
and tier-filtered canReview/reviewUntil/answers/notes. Do not invent endpoints, promote local
cache into that authority or silently omit the final required controls. Pure view models and
presentation can proceed. The accepted server client-correctness trust limit is not a new
blocker. Record exact remaining dependencies before family completion/audit.

Focused tests first, then task checks. Final full family gates and one final engineering audit
are required; web build runs on integrated foundation afterward. Root personally reviews
student-data/session changes. Workers do not upload or integrate their own source.


## October20 approved-details finish contract

User: "Finish/review W4e". Policy main23c5be4e; clean W4e b5da6f99. The October20 PWA decision log's exact picks 1A,2A,3B,4A,5B,6A,7B and its board-fidelity rulings supersede the builder's listed visible gaps. Preserve the already-approved wheels, Set pills and 2.6-second Resume sequence. Add the exact held-Save sentence, previous/next slides (380ms,40px,Cubic(.2,.9,.3,1)), explicit grid-jump crossfade (200ms, even adjacent jumps), strict Back note and stored pause-warning checkbox.

Technical ownership clarification before edits: W4e may add an optional content slot to CenteredDialog, plus optional per-part count/locked-note and mock help text to QuestionGridSheet, preserving existing quiz/default layouts. Use the existing row/control patterns where suitable and the platform checkbox interaction with the approved board geometry; no CheckboxRow exists on this candidate. These additive extensions implement already-approved boards rather than new product choices; focused shared-component regression tests are required. Gauge changes, if needed for Task6, must preserve W4d's independent quiz-count extension at eventual integration. The drawn 264x128/56pt/one-decimal mock variant is approved; do not scale the existing 220x112 variant as an approximation.

Review source and evidence for the prior builder's paper/session changes. Server-owned completed results/history/review visibility/next eligibility remain required dependencies. No guessed endpoint/local authority, server-branch mutation or family-complete claim is allowed. Current native result/review files are legacy and do not establish completion. Full family engineering audit occurs only after remaining required inputs are available and the candidate is complete.


### October20 session review correction boundary

Root source review found strict-exit submission deliberately drops every answer; the server replaces saved answers with that payload. Correct it to send the original pinned questions, actual answers and real blanks, preserving the required answered-work score. Also guard the interval between requesting and acknowledging submission: freeze local edits, permit only one original terminal intent and Retry that immutable payload, and suppress tick-driven duplicate submissions. Bind idle/local edits and route rendering to the original actor as well as queued writes; once the actor changes, the session cannot revive after A-to-B-to-A. Tests must reproduce strict-answer loss, delayed submission edits/duplicates and idle account changes before production fixes. Keep these corrections within the existing feature-owned session/route and tests. No new server, data schema or product policy is introduced.


### October20 bounded results/review implementor ownership

One isolated implementor continues Tasks6–7 from saved b5da6f99 while the lead owns the paper/pause/grid/custom-setup and server-session corrections in the existing E worktree. Implementor ownership: mock_results_page.dart, mock_results_route.dart (retain the single decoder and its tested behavior), mock_review_page.dart, mock_results_providers.dart, mock_review_providers.dart; feature-owned new finale/review view and note files; their tests; and only an additive mock-size variant in core/ui/components/half_ring_gauge.dart with its tests. Default gauge behavior and W4d's separate quiz-count contract remain intact. Native route wiring may change only result/review destinations in app/routes/mock_routes.dart if required; no server runtime route, start route, setup/paper, content/schema, sync/wiper, Claude branch, or other family's files.

Implement the approved boards and timeline exactly, including the complete finale when representable, correct stored-count score, breakdown, past-result visibility, tier review lifetime, All/Wrong/Flagged viewer, notes and flags. Keep web reader-dependent wiring explicitly pending; never add a local authority for it. A missing inter-family destination/control is listed under Waiting on a contract without a dead substitute. Root reviews scoped output and combines verification; no worker upload or merge. One full-family engineering audit remains due after the required candidate/dependencies are complete; narrow source review does not claim that acceptance.


### October20 finale caller contract

Worker owns presentation/widgets/mock_finale.dart: MockFinaleOutcome(correct,wrong,blank), immutable MockFinaleQuestion(id,outcome), MockFinalePart(name,questions), and MockFinaleInput(reason: MockSubmitReason,currentPartIndex,currentQuestionIndex,parts), with defensively unmodifiable lists. Root owns the native submit caller. Its actual saved snapshot, sample order, current part/cursor, scoring questions and terminal reason construct the input after scoring/saving; GoRouter extra carries it and fresh=1 selects finale only for that submission. endedPart is the actual one-based terminal part, never a guessed historic value. Worker parses these result-route inputs. Original launch stack is preserved by the existing pushReplacement.

Retired questions leave finale dot/outcome lists consistently with scoring. Current cursor becomes the number of retained ids before the original cursor, clamped to the retained list if the final current item retired. Part order/current part remains the actual frozen part order, even if a part becomes empty. If every question retired, omit the finale input and use the measured empty-results state rather than synthesizing outcomes. No historical record may reconstruct a terminal animation from aggregates. Root tests mapping, reason and navigation; worker tests immutable input and animation/reduced-motion.
