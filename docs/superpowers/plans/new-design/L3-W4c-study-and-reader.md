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

## Lead motion source clarification, October 14

BMEdit_n92 keeps translateY(-124px) unchanged from10000to10200ms. Its200ms houseOut
settle concerns scale1.03→1 and shadow→none, not an additional position animation. Implement
150ms lift and200ms decoration settling through the public proxy decorator and an independent
local animation controller using existing motion tokens. Listen to the public animation status;
clean up listeners/controllers and handle short releases, cancellation, unmount and reduced
motion. Do not mutate the SDK or claim an unrepresented position duration is approved.

A separate real difference remains: neighbors BMEdit_n89/n86 move62px over250ms houseOut;
the installed SDK moves gap offsets over250ms easeInOut, with no public curve parameter.
Do not silently accept that curve or replace the drag system. The lead will present this
specific difference to Aedwon. Preserve the verified checkpoint and proceed with independent
reader tasks after saving the decoration slice; full Task8/family acceptance remains pending
until this represented neighbor-motion requirement is resolved.

## Aedwon's accepted motion exception, October 14

Exact reply: "accept built-in". For neighboring gap offsets only, use the existing SDK250ms
 easeInOut cubic(.42,0,.58,1). This supersedes the pending neighbor-curve hold above after
comparisonv1. Do not replace the drag system. Lift150ms and drop-decoration200ms houseOut
remain binding. This is not a wider visual waiver or final phone acceptance.

## Lead execution order, October 14

The integrated base5e6cda45 and current assigned23113d73 contain the real LessonDayContext
and quiz-entry contracts. The earlier missing-contract hold on Tasks5/7 and Home endings is
therefore resolved; use those exact contracts, not local substitutes. Complete the remaining
Task8 decoration fidelity first if it is achievable within approved presentation. Then execute
Tasks5,6,7 and9 in order with task-scoped checks/commits. If a genuine visual departure blocks
only Task8, preserve its verified checkpoint and proceed with independent Tasks5/6/7 while the
lead resolves that specific presentation. Task9/full-family acceptance cannot pass with an
unresolved Task8 requirement. Read main boards and later rulings before affected code.

## Lead Task5 technical clarification, October14

Reuse PantasSheet with an additive readerContents variant for RD_Contents/RD_Plan: intrinsic
contents height within viewport,450ms opening/400ms closing slideC,350ms ease wash32%,105%
translation, no background page shift/scale. Preserve generic/bookmarks defaults and existing
shared behavior. Ownership extends only to that shared component and its focused tests for this
board-required variant, not other families. Tests compare exact drawn motion values, reduced
motion, dismissal/focus/back, large text and existing modes. No feature-local sheet copy.

Bookmarks-origin reader must return to the still-open bookmark sheet: preserve the sheet behind
the pushed reader rather than close it before pushing. Keep real origin on return stack.
Do not navigate to absent plan/performance destinations. When no truthful origin stack exists,
use the existing Home/Study fallback and label that actual destination. Test normal bookmark
return, day-context route extra, and deep-link fallback before accepting the affected navigation.
Do not create routes owned by another family to fill missing callers.

Task5 shared ContentsGlyph may add optional strokeWidth default1.5, preserving existing
callers. Reader uses the board's23px size and1.8 stroke in24-unit SVG coordinates with approved
color. Reuse the existing painter/paths; repaint when stroke changes and cover default versus
reader stroke in a focused shared test. Ownership extends only to that helper and its test;
no local duplicate. The lead inspected its current hardcoded1.5 scaled stroke before this rule.

Task5 contents fade is pending Aedwon's specific presentation decision. Actual RD_Contents
shows eight rows inside an intrinsic list capped400px, with unconditional56px transparent-to-white
bottom overlay. It covers active final-row text even when all rows fit; foreground-token changes
cannot overcome its opaque endpoint. No scroll-end state is represented in the board timeline.
Lead offers contents-fade-options-v1: Current fade versus Readable end (fade only with real rows
remaining below viewport; absent when fit/at end). Preview isolates the light contents list,
omitting icons, lesson selection, surrounding reader and opening/closing animation. Do not treat
it as whole-screen acceptance or implement a fade exception/change until Aedwon chooses.
Other approved origin/error/bookmark-return/day/topic contents work may continue. Task5 cannot
be finally accepted while its represented fade treatment remains unresolved.

## Aedwon's accepted contents fade, October14

Exacttypedreply: "current fade". KeepCurrent fade fromcontents-fade-options-v1: thedrawn
unconditional56px bottomgradient forRD_Contents, includingfitting-list/end states. Theknown
partlymaskedfinalrow wasdisclosed. Mask-induced compositecontrast exception covers only row
content naturally under this exactoverlay: text, Reading tags and read/current-state marks.
Do not lift glyphs above the mask or invent another layer order. Base text/icon tokens still
pass their normal contrast tests before masking; controls outside this overlay retain every
existing contrast requirement. Do not removefadeatend, addbottominset,
or substituteanotherbehavior. DarkmodeusesW1surface endpoint. RD_Plan/dayContents followsits
ownboard; do notbroaden theexception. This supersedesthependingchoiceabove, notphoneacceptance.
Theexplicittypedchoicecontrolsover widgetlastviewedReadable end context.

Task8 row separators: the source currently leaves ListRow.divider false although BM_Edit draws
0.5px separators. Correct through the existing shared row option only if its placement matches
the board; add focused first/middle/last and subject-group checks. If the shared placement cannot
match, report the exact required extension before code. Do not mark fullTask8 accepted meanwhile.


## Lead Task6 shared pull-ring clarification, October15

Source review confirms ProgressRing's public constructors do not support the approved pull ring:
RD_End uses44px viewport, center22/radius19,2.5px track/fill and butt-cap accent progress from
live hand displacement. Current shared component animates fill600ms with different radius/cap.
Extend existing ProgressRing with a narrow named pull variant taking fraction and optional child,
fixed44/r19/2.5/butt geometry, immediate fraction repaint with no generated percentage/Done
semantics or completion check. The owning pull action provides its existing meaningful action
label. Reuse the existing shared painter where possible; do not duplicate a feature-local ring.
Preserve all current constructors/defaults and their motion/semantics. Handle widget variant
updates, theme/reduced-motion changes and disposal consistently; no delayed old fill can resume
inside pull mode. Ownership extends only to this shared component and its focused tests.
Tests first cover exactgeometry/cap and immediatefraction0/partial/1, absenceofspuriouspercent/
completionsemantics, childpreservation, light/dark and existinggeneric/studyregressions. This
implements the approvedboard, not a newpresentation, gesturethreshold orstudentfigure.


## Lead Task6 advance clarification, October15

RDEnd_n15/n16 move outgoing and incoming bodies together over480ms using cubic(.22,1,.36,1),
existing PantasCurves.slideA. The earlier handoff's houseOut name for advance was wrong; the
plate entrance uses its own houseOut. Do not substitute sequential480ms halves or the old190/320.
Keep stationary chrome/contents and one active read/position controller. Prefer extracting the
existing lesson-content subtree and painting a passive incoming preview from the already warmed,
real next ReaderContext in the same clipped transition Stack. Preview has independent layout/
scroll surface but no marking, position persistence, reading timer or interactive/duplicate
semantics. On successful completion activate actual next body in place, preserving original
origin/day and resetting its real progress/read floor as designed. Currentbody retains its own
correct saved offset/fraction until handoff. No route-stack replacement or bitmap snapshot.
Freeze the real loaded destination for the committed motion; do not begin without available
content then flash back to outgoing/loading chrome at handoff. Existing loading/error/retry
patterns apply to unavailable destinations. Cancel/unmount/stale destination and account/exam
changes cannot advance or write the wrong lesson. Reduced motion activates the final state.
Tests first cover simultaneous midpoint/end geometry, stationary chrome, handoff continuity,
actual day/topic/terminal destinations, passive preview no writes/read marks, cancellation and
controller disposal. If this cannot preserve existing ownership, report before a larger refactor.


## Lead Task6 topic boundary and neutral-button clarification, October15

Topic entry is already part of the approved chain: stage0/gap-c-study row26 says keep pulling
past the last lesson into its topic plate, then pull from the plate to the next topic.
G-c-11's "plate with no pull" means no onward pull on the final exam topic's plate; it does not
remove the last lesson's entry gesture or automatically replace reading/quiz content.
Use the existing drawn "Pull up for X" / "Let go for X" template with that actual topic name for
the entry destination. No new "finish topic" wording, extra action or alternate layout.
Inside the plate, X is the actual next topic name and its destination is that topic's first
real corpus-order lesson. Final topic plate has no onward control. Home's real day order takes
precedence: last day lesson uses the already drawn "Pull up to finish today" / "Let go to finish
today" and the day ending. Keep ordinary lesson content/quiz accessible until the explicit pull
or equivalent tap, preserve original origin/day/back semantics, and never push a plate route
whose back label falsely claims the original screen. Existing standalone ending route remains
valid for its own direct caller. Test terminal plate entry without onward pull, nonterminal
plate onward destination, stopped-short plate/unread choices and day precedence.

Shared PantasButton currently has no enabled fill-background/label-foreground mode. Add a
narrow neutral variant for RD_End's existing52px/r14 quiz button, using current fill/label tokens
and shared interaction, text wrapping, busy/disabled, focus/semantics and reduced-motion handling.
Preserve all current variant defaults. Ownership extends only to this shared component and its
focused regression tests. Reuse from ReaderGap instead of a feature-local styled duplicate.
Read line uses the drawn18px teal check and15px/500 "Read"; remove superseded "marked
automatically" and material-duration copy per stage0 row24. No student-data/read-floor change.
Tests first cover actual neutral geometry/colors in both themes, press/reduced-motion,
large text and unchanged existing variants. No new presentation is substituted.


## Lead Task6 reader boundary capture, October15

Reuse the existing Task8 boundary pattern and SyncActiveContextStore. For initial reader
boundary capture only, if readSnapshot is absent, initialize the existing anonymous envelope
inside that capture transaction, then retain its token. This is the same absent-only use of
clearStable already implemented in BookmarkPrefsRepository.remove. It is not permission to
clear or rotate any recognized snapshot, including a recognized anonymous envelope.

The "never rotate/clear just for reading" instruction prohibits replacing recognized contexts;
it does not prohibit establishing the missing legacy guest token. Do not compare null tokens
as a boundary identity. Establish capture before enabling guarded asynchronous handoff/writes.
Once captured, missing or different current token expires the old reader operation. Retry,
dispose, position-save or a stale callback must never initialize/recreate an expired boundary.
Use the existing actor/auth/exam lifecycle signals for in-flight capture and cancellation; no
new global lifetime mechanism, core wiper edit, schema or synchronization protocol.

Test initial missing guest envelope, preservation of stable and anonymous snapshots, real wipe
then stale completion, same-account reset, account/exam changes, ordinary current save/handoff,
and capture/cancel races. Validate write guards in the same transaction before mutation.
No passive preview may mark read, start a reading timer or save position.

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


## Lead Task6 capture-owner clarification, October16

The lead opened the actual cached readerContextProvider family, LessonPage ownership/warming,
and SyncActiveContextStore. Capturing/initializing inside the cached content provider would
repeat on invalidate/retry after wipe. Initial absent-envelope initialization therefore belongs
to one fresh reader-page lifetime, before enabling content loading, warming, marking or saves.
Use the existing page and auth/exam lifetime signals, not a global owner or new lifecycle system.
Cancel an in-flight initial capture transaction if that owner expires or its actor/exam changes.
A surviving page never recaptures after token loss, retry or a stale completion. A genuinely new
page may establish its own initial capture through the same absent-only transaction.

The content provider may read/capture the already existing snapshot before its asynchronous
content load, validate it afterward, and carry its provenance. It never creates an envelope.
The page retains its original capture and rejects missing/different provenance from loaded or
warmed contexts, including cached results. Retry reloads content under that same token; it cannot
initialize or adopt a replacement token. After boundary expiry, drop stale retained content and
preview, cancel committed motion and writes, and use the existing failure/back behavior.
Mutation guards still run in the actual write transaction. Ordinary current-boundary behavior
and the recognized-context preservation rule remain unchanged.

Tests first: fresh page with missing guest envelope; provider retry/invalidation after real wipe
without token recreation; cached/warmed old token rejection; actor/exam/cancel during initial
capture; valid fresh-page entry after reset; ordinary same-token read/save/handoff. This is a
technical owner correction required by the already approved no-recreation rule, not a larger
refactor, new persistence format, new product behavior or visual departure.


### October16 expired-page action clarification

An expired retained reader token cannot recover through content retry, because retry must
never recapture or adopt a replacement token. Do not render a Try Again control with an empty
callback. Reuse the existing StateView failure presentation and actual origin Back control
without an unavailable retry action. Transient content errors retain their working retry under
the original token. Fresh page entry keeps the approved initial-capture behavior. No new copy,
shared-state helper, automatic navigation, replacement token or visual redesign is required.


## Lead Task6 direct ending-route ownership clarification, October16

Root inspected all production references to /study/ending/:topicId and TopicEndingPage. There
is no production push left; the declared route remains a supported direct entry and tests.
A real nonterminal topic ending must retain its approved onward pull, and the final topic
ending must have none. Do not introduce a second token/marking/preview owner in that legacy
page or leave a reachable alternate nonterminal plate without its approved onward action.

Reuse LessonPage's existing guarded owner for the real direct route, with a narrow initial
ending state anchored to that topic's actual corpus-last lesson/context. The adapter resolves
real content and reuses the same EndingContent/pull/preview/chrome. Preserve its truthful Study
return/fallback. Pure explicitly supplied ending fixtures may still render the shared layout
without pretending to be a loaded interactive route. No route replacement, new global owner,
synthetic lesson, additional capture mechanism or new visual treatment.

Showing a plate must not mark/open/save its anchor lesson merely to resolve context. Reading
ownership begins only with an actual active lesson body. On an active reader's transition to
a plate, save its outgoing measured offset/fraction once; plate disposal or onward handoff
must not overwrite that lesson's saved position with reset zero. Tests first cover direct
nonterminal onward preview and correct first next lesson, terminal no onward, actual back,
no anchor read/recent/position mutation, and preservation of the outgoing reader offset/fraction
after plate departure. If the adapter cannot reuse the existing owner narrowly, report before
a larger refactor. This keeps the already approved route and chain consistent.


### October16 active reader bookmark guard

The existing active reader bookmark action also writes membership and per-exam preferences
asynchronously. Reuse the same retained reader token/current-owner guarded transaction around
that existing action, preserving its behavior, schema, keys and sync shape. Capture needed
repositories before awaits and avoid late WidgetRef use after disposal. Do not introduce
another owner or broadly rewrite bookmark behavior. A held-read then wipe/account/exam/cancel
regression must reject or roll back stale membership/order writes; ordinary same-boundary
bookmark and actual ReaderBar state still work. Preview remains noninteractive and never
invokes this action. This completes the existing actual-write boundary scope.


### October16 Task8 closeout: held actions before boundary changes

Before Task8 closeout, test the actual sheet's Remove operation held before its first mutation
across real wipe, same-account reset, actor and exam changes, not only Undo held after a completed
removal. Root inspected _save/_remove/_move/_expireUndo: _save only serializes busy state,
_expireUndo returns when no completed removal exists, and removal obtains its transaction token
after an asynchronous exam lookup. This is a concrete unverified entry-path risk, not a claim
that the existing Undo transaction is broken. Include stale failed-save Retry and held sort/
reorder preference writes in the affected lifetime review.

If a meaningful test reproduces a stale write, return the narrow view/repository provenance
proposal before edits. Reuse existing auth/exam and SyncActiveContextStore token/cancellation
patterns. No new global owner, schema, sync/wiper change or speculative framework is authorized.
A stale view must not initialize an absent token from mutation/retry, touch another boundary's
membership/order, or retain an actionable old write retry. Ordinary same-boundary actions and
the already approved initial legacy-guest behavior remain. Root records the concrete correction
after reproduction, before its implementation. Other settled W4c tasks can continue.


## Lead Task8 held-action correction contract, October16

The actual held-Remove checks reproduced four failures: after real wipe a late removal
initialized a new anonymous envelope; after same-account reset, actor change or exam change
it deleted the current boundary's same-lesson bookmark. This establishes a write-ownership
defect beyond the already guarded held-Undo path. Authorize this narrow correction before
Task8 acceptance, inside the existing lesson-owned sheet/providers/preferences repository
and affected tests. No global owner, schema, sync/wiper change or generic framework.

Capture the view's actor/exam/operation epoch before its first asynchronous work. Resolve one
initial sheet-action boundary with existing absent-only SyncActiveContextStore initialization
and cancellation checks; preserve recognized stable/anonymous contexts. Retain that original
exam/token. Actions may await that one capture; mutation and failed-save Retry never initialize
or adopt another token. Carry original exam/token plus the current-view predicate through
Remove, Undo, Sort and Move/drag into their actual repository write transactions, validating
before and after awaits. The order controller publishes only after a current successful write.
Expire selections, held work and failed retries on actor/exam/token expiry even when there is
no completed removal/Undo payload. Preserve ordinary same-boundary behavior and exact order,
timestamps, sort, announcements, motion and restoration semantics.

A reset/wipe while initial capture is still pending must cancel that original view even before
a token has been assigned. Use existing lifecycle or database update signals; do not skip
expiry merely because the captured-token field is still null. Include this initial-await
case in the reader and sheet regression checks, alongside actual wipe/reset/actor/exam during
held mutations and retry. A genuinely fresh post-reset view may establish its initial capture.
Any narrowly shared feature-owned extraction may reuse the existing guard implementation;
do not create another protocol or duplicate the core active-context store.

Tests first prove the four reported failures and affected Sort/Move/Retry paths, cancellation
during capture, current ordinary actions, and recognized-context preservation. Renew affected
reader/bookmark/storage boundary checks, then final family/project gates at Task9. Root
personally reviews the data correction and the required Astra audit precedes integration.


### Empty-store capture ordering, October16 checkpoint

Actual initial-await reader RED remains after an empty sync_meta wipe: Drift reports no table
update when DELETE affects zero rows. A table-update listener alone cannot identify that reset
when initial capture waits on auth first. Next investigate moving the existing initial context
capture to view start before auth/exam/content waits, retaining that captured token and binding
the resolved exam only after guarded identity checks. Preserve every recognized snapshot and
use the existing absent-only initialization once. Prove actual transaction/queue ordering against
wipe, cancellation during capture, and valid fresh post-reset entry; do not assume event emission.
This is a narrowly authorized feature-owned approach to test, not proof of a finished fix or
permission to change a global lifecycle, schema, sync protocol or wiper. If the existing seams
cannot meet the recorded contract, report the precise remaining capability gap before such edits.


### October17 early-anchor assertion clarification

The lead read the draft that starts the existing context transaction before auth/exam waits.
An anchor transaction completed while the view is current may leave its original envelope
when the view later unmounts or identity loading fails. It contains no lesson activity; do
not delete it or recapture from that expired view. The old assertion that every held-auth
unmount must leave no envelope no longer describes this authorized ordering. Assert the
stronger actual contract: retain an already completed original token without student writes;
cancel and roll back a genuinely pending transaction; a real wipe removes the anchor and
prevents old-view recreation; a genuinely new view may establish its own absent-only anchor.
Preserve recognized envelopes. This is not a waiver of pending-capture cancellation.

The lead also opened readOrder/readCustomOrder migration writes and their asynchronous provider
callers. Inspect/test a held migration read across wipe/replacement before Task8 closes. If it
reproduces prior preference persistence into the new boundary, report a narrow feature-owned
proposal before changes. This is an investigation, not a confirmed defect or wider authorization.


### October17 guarded first-read migration correction

Actual held custom/sort migration tests fail2/2: after wipe and replacement context, delayed
legacy migration overwrites the new custom order ['fresh'] with ['old'], and Recent with
Oldest. Root read the actual RED output and authorizes this narrow feature-owned correction
before implementation. Reuse the existing ReaderBoundary read-only capture and guarded actual
write transaction in BookmarkPrefsRepository and its lesson-provider callers. No schema, core
lifecycle, sync protocol, wiper or new framework change.

Scoped readOrder/readCustomOrder migration must retain the original existing exam/token and
current-provider predicate before the first relevant async preference/membership read. Carry
it through the actual fallback persistence. Missing envelope may return the fallback but must
not persist it or initialize context. A fresh view's approved early capture permits normal
subsequent first-read migration. Preserve recognized anonymous/stable snapshots and ordinary
one-time legacy fallback and per-exam isolation. Seed an existing anonymous context in tests
that assert persistence; add a missing-envelope no-write check.

Do not capture a replacement token after the provider already collected a legacyOrder list.
Retain provenance before collecting that list, or obtain its fallback afresh under the original
guard. Expired reads may not overwrite new sort/order or publish an old controller state.
Cover the reproduced reset cases, absent-token no writes, caller disposal/identity changes,
and ordinary scoped migration. Renew affected tests and final Task9 gates. The lead personally
reviews this data correction, followed by the required whole-family Astra audit.


### October17 missing-token read publication correction

Root read actual absent-provider RED0pass/1fail: a provider that initially found no token
returned stale l1 after real wipe and replacement context. New preference values survived;
this finding concerns publishing stale rows. The lead approves the narrow existing-signal
correction before implementation. For an initially missing token, observe existing bookmark
membership/preference changes before async student-data reads and reject expired results.
Compare the read-only token again before publishing; a replacement token cannot authorize
older rows or sort. Apply this to affected row/order reads, without initialization or writes
from a missing-token read. Use existing provider invalidation/current predicates; capture
repositories before awaits. Token-present reads retain existing guarded provenance.

Keep ordinary first guest display and migration fallback working; do not hide all missing-token
data. Prove wipe with and without a replacement envelope, changed membership/preferences,
disposal, and fresh ordinary loading. An empty wipe cannot replay data that does not exist;
the already approved fresh-view early anchor handles action ownership. No global owner, schema,
sync, wiper change or new data protocol. Final analysis/focused checks must be clean before
saving source; the prior migration run still has a crossfade timeout and two lint findings.


### October17 mutation-default consistency

The legacy default remove API still initializes an absent envelope even though the production
sheet now passes its retained guard. The lead agrees to remove that fallback under the already
recorded owner-only capture contract. Recheck actual callers; update repository baselines to
perform explicit fresh-owner capture. Direct absent-context Remove must reject without any
envelope, membership or preference write. Preserve recognized contexts and ordinary guarded
Remove/Undo. This is existing-contract consistency, not a new lifecycle or product change.


### October18 Task9 direct-ending retired-state cleanup

Root opened TopicEndingPage: the real map-loading path still imports FaintBars, while active
reader and Study paths already consume W4h loadingFor. Replace that retired loader with the
existing loadingFor(asyncMap) pattern. Replace legacy textStyles/color aliases in its retained
error/null/not-found text with current body/secondaryLabel tokens. Preserve messages, loading
container, lookup/route behavior and the single LessonPage owner. Cover loading/error/null
regressions, including the delayed/reduced-motion shared loader behavior as applicable. This
implements Task9 retired-component removal and the existing W4h state contract, with no new
copy, route, visual choice, local state helper or second reader owner.


## October19 audit1 bounded fix pass

Audit record gates/w4c-astra-audit-1.md is binding before affected edits. Root accepts all six
Important findings and regrades truthful preview origin Important. Correct all seven through
existing lesson-owned providers/page/widgets/repos and their tests, with additive narrowly
needed callbacks only. No server/core content/schema/sync/wiper changes, generic framework or
new visual choice. Keep original auth/exam/token guards and current repository signatures.

Move Retry retains the immutable intended order rather than applying indices again. Remove
retains its committed original rows/timestamps/order across postcommit validation failure; Retry
never performs deletion twice. Expiry clears pending recovery and cannot adopt a new token.

Refresh Last opened and recent-history consumers only after a successful current-owner open,
including in-place handoff. Failed opens/bookmarks/marks do not escape unhandled futures.
Mark pending and completed states are separate; only successful persistence latches completed.
Use existing save-failure presentation/Retry where needed, retaining original intent and owner,
with no new copy or automatic navigation. Do not reset the original floor merely on retry.

Stationary short/end-held lessons re-evaluate at the existing15second wall-time floor. Marking
requires current visible active body/end metrics. Suppress automatic writes while app/route/
Contents cover it, re-evaluate on real visibility, and cancel timers/queued callbacks on expire/
disposal. Do not introduce a foreground-time accumulator or change the15second product rule.
Use existing local lifecycle/route signals, not a new global observer framework.

Normal-size topic/lesson/bookmark-preview lists use shared one-line ellipsis as drawn and full
semantic labels. Cover actual long titles at390dp/100% and200% without overflow. Study preview
returns to Study; sheet-origin reader returns to the retained sheet. Preserve accepted fade/
neighbor-motion exceptions and every default/shared caller contract.

Port the five meaningful external reproductions into appropriate existing tests before fixes.
Add real overflow/origin/open-bookmark-error/visibility-cancel regressions as affected. Run
focused checks during fixes, then final full --concurrency=1 suite/static gates on one frozen
candidate, not after each tiny change. Root reviews exact source and evidence before source
upload/integration. This is one completed family audit plus its fix pass, not repeated audits.


### October20 affected shared test correction

Lead opened test/core/ui/components/study_map_extensions_test.dart after expanded checks
reported its two normal-size expectations against StudyLessonRow. Its unconditional null
maxLines assertion contradicts audit1's already approved normal single-line correction.
Extend fix-pass ownership only to that test: normal size expects one line/ellipsis; 200%
retains wrapping and no overflow. Keep its contrast, geometry and keyboard assertions intact.
No shared production component, new presentation or baseline exception is authorized.
