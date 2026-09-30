# The adaptive roadmap: one engine that decides what to study next

**Date:** 30 September 2026
**Status:** Draft for Aedwon's approval (Part 1). Part 2 is the agent section and must agree with it.
**Decision log:** `docs/superpowers/decisions/2026-09-30-adaptive-roadmap-log.md`
**Policy revision read:** `origin/main` `11417a5b3def098f70c367172a13738ec1ffd90a`
**Grounded against:** `web/e09-qlp5-prepared-next-r1` at `13938943f447956af43d2de7e1f9999eb2418aee`,
the current E09 candidate per the Readiness SSOT. Every "exists today" statement below was read
from that revision.
**Supersedes:** parts of `2026-08-04-study-plan-forward-calendar-design.md` (Section 7 of Part 2
lists exactly which). Its evidentiary line, pacing arithmetic, month rule and "let them cram"
principle survive and are restated here.

---

# Part 1: For approval

## 1. What this fixes

Pantas promises to tell a student what to study next and to adjust that plan as they study.
**The app does not do this today.** The pieces exist, but nothing joins them:

- The plan screen has a route, but nothing supplies its data, so it cannot work. It is also the
  old May design, not the one approved on 4 August.
- Today's quiz adds new questions up to a fixed 10 a day, whatever the exam date.
- Home's "Up next" is always three unread lessons from the weakest topics. It ignores the exam
  date and the topics the student excluded.

**This spec adds the missing piece: one roadmap engine.** It decides each day's lessons, new
questions and reviews. Every screen that talks about today's work reads from it, and none of them
decides on its own. The screens themselves are redesigned in a later UI round. This spec fixes the
engine they will all sit on.

## 2. The promise the engine keeps

> The app schedules the topics a student has to deal with inside the time they actually have.
> Someone who starts early is better off: they have more days, so their pace is gentler.
> Someone who starts late chose to cram, and the app does not protect them by covering less.

Unchanged from 4 August. **Everything is covered before the exam.** Performance changes the
order, never the amount.

## 3. What the student experiences

- **They open the app and see today's plan.** Nothing to set up or decide.
- **The plan adjusts on its own.** A missed day spreads its work over the days left. Extra work
  makes later days lighter. No messages, no "behind" or "ahead".
- **Today stays put.** Once today's plan is made, it does not reshuffle while they work. Items tick
  off as done.
- **Everything counts.** A lesson opened from the Study tab, a practice quiz, an in-lesson quiz:
  all count toward the plan.
- **Big days come in sittings.** The day's questions are split into sittings of 10 by default
  (5, 10, 20 or All in Settings). They can stop any time; the rest waits.
- **"I want to advance"** appears when today is done. One tap pulls in tomorrow's items, and later
  days get lighter. It replaces the "Do more each day" switch. Final wording is for the UI round.
  If they stop partway, what they did counts, the rest is scheduled normally, and today still
  counts as done.
- **Motivation comes from facts, not verdicts:** today done, days in a row, and how much of the
  material is covered. How these look is for the UI round.

## 4. How a day is built

**Two parts, two jobs.** The review scheduler (FSRS) handles questions the student has already
answered: for each one it estimates when the student is about to forget it and marks it due then.
A missed question comes back within a day or two; an easy one weeks later. The roadmap handles
everything else: how much new material fits each day before the exam, which topics come first,
how many due reviews fit today when there is a backlog, when the mock falls, and when new material
stops. Each day the roadmap takes the scheduler's due list, adds the new material, and splits the
day into sittings. The scheduler decides when each question returns; the roadmap decides how much
and in what order.

1. **Due reviews.** Questions the student has answered before that the review scheduler says are
   due. After an absence, see Section 5, item 3.
2. **Lessons.** Lessons left divided by working days, rounded up.
3. **New questions.** Unseen questions left divided by working days, rounded up.
4. **The mock,** on one day shortly before the exam (Section 5, item 5).

**Working days** run from today to the start of the **review-only stretch**, which is the last
7 days or the last quarter of the time left, whichever is shorter. In that stretch, only reviews
and the mock are scheduled.

**Lessons come before their questions.** A lesson's new questions are scheduled after it. If the
student skips the lesson, its questions still arrive on time, so the plan still finishes.

**Topic order.** Weakest topic first, measured from the student's quiz and assessment results. A
topic's prerequisites that are not yet covered go before it. With no results yet, the authored
order is used. Once a topic's lessons are started, they are finished before the next topic
starts, so a student is not bounced between half-read topics.

**Before the first plan, the student takes the short assessment**, as today. It gives the first
topic order.

## 5. Decisions made from evidence

Per the workflow rule adopted today, study mechanics follow evidence. Sources are in Part 2.

1. **Weak topics are handled by order and reviews, not an extra drill block.** Weak topics come
   first for new lessons and questions, and every missed question comes back within a day or two
   through the review scheduler. The plan does not add a third channel that re-asks answered,
   not-yet-due questions from weak topics: reviewing before a question is due gives little
   benefit and takes time from the reviews and new material the student needs. Free practice of
   weak topics stays available outside the plan.
2. **Strong topics are not dropped.** The scheduler only tracks questions already answered, so
   coverage brings a strong topic's unseen questions in; the scheduler then keeps them.
3. **Backlog after an absence.** Today includes as many reviews as the student has actually done
   on a typical recent day, from their own history. Most-likely-remembered first. The rest
   follow on later days. New material keeps its pace.
4. **Mixing within a sitting.** The existing "How sessions are built" setting keeps its default
   (mostly one topic, some from others). Mixing helps math and science problems and does not help
   word learning, so **vocabulary questions are kept together** within a sitting.
5. **One mock, 1 to 6 days before the exam**, on the first day of the review-only stretch that is
   no more than 6 days out, and never on the exam day itself. Free students' 14-day limit is respected. No mock is scheduled for an
   exam that has none.
6. **Mock answers count like any other answer.** Every mock, scheduled or not, feeds the review
   scheduler and topic scores. Missed mock questions come back as reviews, within the daily
   review limit in item 3, so a mock cannot flood the days after it. Practice tests help most when
   the student sees and relearns what they missed. This reverses the May mock spec, which kept mocks
   out of reviews to avoid that flood before any daily limit existed.

## 6. Free and Pro

One engine for everyone. The line is only in what is shown (your choice A):

| | Free | Pro |
|---|---|---|
| Today's plan: amounts, order, backlog, sittings, "I want to advance" | Yes | Yes |
| The mock, on its day | Yes | Yes |
| Weeks ahead: which topics come when, the review-only date, the mock date in advance | No | Yes |
| The change log: what changed and why | No | Yes |

**Backup follows the existing rule: only Pro backs up.** A Free student's plan history lives on
their phone and is lost with a reinstall. The plan itself is rebuilt from their progress, so only
the history is lost. **This corrects what I told you earlier** (edge case 21).

## 7. Edge cases

**Exam date**
- **Month only:** plan to the first of that month.
- **Month only, and that month has started:** ask once for the day. Until answered, plan to the
  last day of the month. *My call, not evidence; easy to reverse.*
- **Date changed:** recompute at once, and log it.
- **Exam tomorrow:** everything left is scheduled today.
- **Exam today:** reviews only.
- **Exam date passed:** ask once whether they took it: set a new date, or switch exams. Reviews
  only until they answer.
- **Far exam:** small days. Rounding up finishes early, which only adds review time.
- **The exam date is one per student, not per exam.** Switching exams keeps the same date. Whether
  switching should ask for a new date is for the UI round.

**Mock**
- **Free limit blocks the window:** the next allowed day in the window; if none, no mock.
- **Mock already taken in the window:** no second one.
- **Exam under 2 days away, or no mock exists for this exam:** none.
- **Mock submitted with many misses:** the misses join the reviews due; today's review limit
  still applies, most-likely-remembered first, and the rest follow on later days.
- **Mock questions the student never answered** (time ran out): nothing is recorded for them; they
  stay unseen.
- **Discarded mock:** nothing is recorded. **Forfeited strict-mode mock:** the answers given are
  recorded; unanswered ones are not.

**Topics and content**
- **Topics excluded or included mid-plan:** recompute at once. Excluded topics leave the plan
  with their reviews; history is kept.
- **New content arrives,** even in the review-only stretch: scheduled. Covering everything wins.
- **Content removed:** dropped from the plan.
- **Exam with no content:** no plan; the existing "unavailable" state shows.
- **Everything covered early:** reviews only; "I want to advance" has nothing new to add.
- **Reading passages:** a passage's questions are introduced together, so a day can run a few
  questions over its count.

**Student behavior**
- **Studying off-plan:** counts; tomorrow recomputes.
- **Lesson opened but not finished:** counts as read only when they reach the end, as today.
- **Performance changes mid-day:** new order from tomorrow.
- **A day ends at local midnight**, the same as streaks. *Corrected from the 4 a.m. I proposed,
  which would have made the plan and the streak disagree about what "today" is.*

**System**
- **Offline:** the engine runs on the phone.
- **Reinstall or new phone:** the plan is rebuilt from progress. Pro also keeps the change log.

## 8. What changes in the app

- **New:** the roadmap engine; a synced (Pro) change log; prerequisite links between topics,
  kept in the app rather than the protected content package, filled by a content audit with checks
  against loops and broken links.
- **Rewired to the engine:** today's quiz session, Home's "Up next", the lesson reader's "2 of N",
  notifications about today's work.
- **Removed:** the fixed 10 new questions a day; the unwired May plan code (pace curve, tolerance
  band, mastery inputs, the Light/Standard/Intense value); the planned "Do more each day" switch.
- **Changed:** mock answers now feed reviews and topic scores, so Progress figures include them.
- **Kept:** the review scheduler, topic accuracy, the exam date, topic exclusions, sitting length
  and mixing settings, the mock limit, streaks.
- **Later, in the UI round:** the plan screen, the "today done" moment, progress figures, the log
  viewer, button wording, and how the passed-exam and month questions are asked.

## 9. Cost to release

This changes app code and content on the paused E09 candidate. **E09's functional and
performance evidence has to be rerun on the new build**, as the Readiness SSOT requires for any
source or content change. The content audit is short (25 topics). Keeping the prerequisite links
in the app leaves the frozen content identity unchanged, so the content-protection device proofs
already accepted for E09 are not redone for this work. Today's session keeps the fast-start path
built for E09, so its speed targets still apply.

## 10. How we will know it works

- For any student, today's lessons and new questions, done every day, cover everything before the
  review-only stretch. Checked by tests across short, normal and far exam dates.
- No screen computes today's amounts itself. The quiz tab, Home and the reader all show the
  engine's numbers.
- Missing days, doing extra, changing the date or topics, and adding content each produce the
  right new plan and a log entry with the right cause.
- The fixed 10-a-day and fixed three lessons are gone from the code.
- Free sees today and the mock on its day; Pro also sees the weeks ahead and the log.
- No screen says "behind", "ahead", "on track", "ready" or "mastery". No number is shown for any
  week after the current one.
- Then E09's evidence is rerun on the new build, and you do the visual check after the UI round.

## 11. What needs your decision

- **Approve this Part 1**, or name changes.
- **Complexity level,** after approval: minimal, balanced or hardened. I will bring the three
  with scope and time.

---

# Part 2: Agent section

Technical detail for the implementer. It must agree with Part 1; where it seems not to, Part 1
wins and the lead is told.

## 1. What exists on the candidate (read, not remembered)

| Input | Where it lives | State |
|---|---|---|
| Selected exam | `activeExamFocusProvider` (`lib/core/storage/selected_exam_focus.dart`) | Works |
| Exam date + precision | `UserSettings.examDate` (`ExamDate`, `lib/core/storage/domain/exam_date.dart`); one per student | Works. `daysUntil` returns null at month precision; `monthStart` exists |
| Included topics | `scopedTopicsProvider(examId)` (`lib/core/storage/track_scope.dart`); custom track uses `corpusTopics` | Works |
| Lessons and read state | `contentLessons` (ordering per topic); `lessonProgressLocal.readAt`, written by `reader_providers.dart` when the end is reached and a dwell floor is met | Works |
| Questions | `content.selectionRowsByTopic`; `Question.lessonId`, `passageId` | Works |
| Review states | `reviewStateRepositoryProvider.allStates()`; `FsrsDueSelector`; `FsrsScheduler` | Works. Retrievability is private (`_retrievability`) |
| Performance | `topicAccuracyProvider` (from `performanceProvider` at topic level), floor 3 | Works |
| New introduced today | `NewCardIntroRepository.countForDay` | Works; used only against the fixed cap |
| Session settings | `QuizPreferences.sessionLength` (5, 10, 20, All; default 10), `ordering` (blocked, interleavedTail default, fullyMixed), `newCardCap` default 10 | Cap not shown in Settings |
| Assessment gate | `SessionPanelNeedsAssessment` in `today_providers.dart` | Works |
| Mock availability | `mockAvailabilityProvider`: in progress, no blueprint, cooldown 14 days from last submitted (Free), available | Works. Only `content/mock/upcat.yaml` ships a blueprint; custom tracks have a custom mock |
| Streak day | `StreakEvaluator._localDay`: local midnight | Works |
| Sync | `lib/core/sync/mapping/*` mappers; Named Pro only (2026-08-28 sync spec) | Works |
| Topic definitions | `tools/lesson_author/outline.json` → `tools/build_content_export` → `seed_writer` → protected package → `content_topics` (`id`, `subjectId`, `name`, `ordering`) | No prerequisite field; the package identity is frozen for E09 (releaseSequence 2) |
| Today launch path (QLP-2 to QLP-4) | `TodayQuizPreparer` (`TodayPlanBuilder` seam, cache, in-flight dedupe), `QuizLaunchCoordinator`, `QuizPreparationStamp` (includes `newCardCap`, `localDay`, `nextDueExpiry`) | Works; measured in QLP-5 |

**What is broken or missing:**

- `/plan` renders `PlanPage`, whose `studyPlanExamProvider` and `studyPlanSignalsProvider` throw
  `UnimplementedError` and are overridden nowhere in `lib/`. The feature (`pace_curve.dart`,
  `daily_sizer.dart` with its ±25% pace multipliers, `compute_plan_view.dart`) is the struck May
  design. `PlanPrefs` duplicates the exam date and carries `StudyPlanIntensity`.
- `todayInputsProvider` caps new questions at `newCardCap - introduced`, shared across topics in
  scoped-topic order. `todaySessionPlanProvider` names the session after the topic with the
  largest backlog (`BuildTodayQueue`) and builds one session of `sessionLength` from due,
  weakness and fresh buckets.
- `upNextProvider` takes `targetCount = 3` unread lessons from `topicAccuracyProvider` order,
  reading all topics of the exam, not `scopedTopicsProvider`.
- `/plan/dossier/:mockId` is a Pro route to a `_Stub`.

## 2. Engine shape

New feature `lib/features/roadmap/`. Pure domain core, thin application layer.

- **`domain/build_roadmap.dart`**: `Roadmap BuildRoadmap.call(RoadmapInputs)`. Pure, synchronous,
  no I/O, fully unit tested.
- **`RoadmapInputs`**: `today` (local date), `examId`, `ExamDate?`, scoped topics with
  `ordering`, `subjectId`, `prerequisiteTopicIds`; lessons per topic with `ordering` and read
  state; questions with `topicId`, `lessonId`, `passageId`, seen state; review states with due
  and retrievability at `today`; per-topic `TopicAccuracy`; the student's review-volume history
  (Section 4.6); mock availability facts (exists for exam, last submitted, `proIsActive`);
  assessment completed; content revision id; the prior persisted day and log.
- **`Roadmap`**: `DayPlan today`; `DateTime? reviewOnlyFrom`; `DateTime? mockDay`;
  `List<WeekPreview> weeksAhead` (topic ids per week, no counts); `RoadmapState state`
  (`needsAssessment`, `noContent`, `examPassedAwaitingAnswer`, `monthStartedAwaitingDay`,
  `planning`, `reviewOnly`, `allCovered`); `List<RoadmapChange> changes` (produced by diffing
  against the prior day, Section 4.9).
- **`DayPlan`**: ordered `lessonIds`; `reviewQuestionIds` (due, capped per 4.6, ordered by
  descending retrievability); `newQuestionIds` (ordered per 4.4); `isMockDay`; counts derived
  from the lists, never stored separately.
- **Application:** `roadmapProvider(examId)` gathers inputs from the existing repositories and
  providers above, calls `BuildRoadmap`, persists the day snapshot on first build of a local day,
  and returns the persisted snapshot minus completed items for the rest of that day.
- **Inputs are metadata only (QLP-1 rule).** Question inputs come from the lightweight selection
  metadata (`content.selectionRowsByTopic` and the QLP-1 count/metadata queries): ids, `topicId`,
  `lessonId`, `passageId`, active flag. Never hydrate stems, choices, explanations or figures to
  build the roadmap; only the questions of the sitting being launched are hydrated, by the
  existing batched path. No per-question queries; no unbounded `Future.wait`.
- **Launch path (QLP-2 to QLP-4).** Today's sitting is launched through the existing
  `TodayQuizPreparer` and `QuizLaunchCoordinator`, not a new path. Implement the preparer's
  `TodayPlanBuilder` seam from the roadmap: it returns the next sitting from `SittingPlanner`
  as the `TodaySessionPlan` the preparer and coordinator already consume. `QuizPreparationStamp`
  drops `newCardCap` and gains a roadmap snapshot token (exam day, `day`, `inputsDigest`) so that
  any roadmap rebuild (4.9) invalidates a stale prepared sitting through the existing freshness
  check. Warm Start, single-session creation, resume by saved identity and order, cancellation and
  the day-rollover and due-boundary invalidations all stay as QLP built them. Topic entry and
  Resume are untouched.
- **Budget.** The roadmap build is inside the first-recommendation timer. It must keep QLP-5's
  targets (first recommendation p95 at most 1,000 ms; warm Start p95 at most 500 ms; prepared Next
  p95 at most 100 ms) and not regress the recorded 8cbaaeea metrics. Build the day once per local
  day and per trigger (4.9); later reads use the persisted snapshot.
- **Sittings:** `SittingPlanner.split(DayPlan remaining, sessionLength, ordering)` returns the
  next sitting's question ids, applying 4.8. Reuse the existing pickers and `PassageSetFiller`;
  do not write new pickers.

## 3. Persistence

- **`roadmap_day_local`** (drift): `examId`, `day` (local `YYYY-MM-DD`), `planJson`,
  `inputsDigest`, `createdAt`. Primary key (`examId`, `day`). Device-local, not synced; it is
  derived and rebuilt on demand.
- **`roadmap_change_log_local`** (drift): `id` (uuid), `examId`, `occurredAt`, `cause` (enum
  string), `beforeJson`, `afterJson`, `syncState`. Append-only.
- **Sync:** add `roadmap_change_log_mapper.dart` following `review_log_mapper.dart` (append-only).
  Eligibility is the existing Named Pro rule; no new sync logic. Firestore rules and emulator
  tests are extended the same way the existing append-only collections are.
- **Wiping:** add both tables to `LocalStateWiper` and `dev_demo_switch.dart` beside
  `dailyNewCardIntro`.
- **Migration:** schema bump creating both tables. `QuizPreferences.newCardCap` is ignored and
  removed from the model; the stored preference key is left unread, not deleted, so an older
  build reading synced preferences does not fail. `StudyPlanIntensity` and `PlanPrefs` are
  deleted with the old feature; their stored key is likewise left unread.

## 4. Algorithms

All dates are local calendar days; the day boundary is local midnight (`_localDay` semantics).
Extract `_localDay` to a shared helper and use it in both the streak and the roadmap.

### 4.1 The planning date and states

- Day precision: `examDay = examDate.day`.
- Month precision, month not yet started: `examDay = monthStart` (4 August rule).
- Month precision, today is inside that month: state `monthStartedAwaitingDay`; plan against the
  last day of the month until the student gives a day (Part 1 Section 7, lead's call).
- Month precision, month over; or day precision, `today > examDay`: state
  `examPassedAwaitingAnswer`; plan is reviews only.
- No exam date: cannot occur after onboarding (the date step is required and rejects past dates).
  Defensive fallback only: reviews only, state `planning`, no pacing, log `missingExamDate`. Do not
  invent a window.
- No scoped content: state `noContent`, empty plan.
- Assessment not completed: state `needsAssessment`; the day's only item is the assessment
  (existing `AssessmentQuestionSelector`).

### 4.2 Pacing (4 August arithmetic, restated)

```
daysLeft       = examDay - today                     (whole days)
quiet          = min(7, floor(daysLeft / 4))
workingDays    = daysLeft - quiet
reviewOnlyFrom = examDay - quiet
lessonsToday   = workingDays > 0 ? ceil(lessonsLeft   / workingDays) : 0
newToday       = workingDays > 0 ? ceil(unseenLeft    / workingDays) : 0
```

`daysLeft == 0` (exam today): reviews only. `daysLeft == 1`: quiet 0, workingDays 1, everything
today. `lessonsLeft` = active lessons in scoped topics not read. `unseenLeft` = active questions
in scoped topics with no review state. New content inside the quiet stretch: if `workingDays <= 0`
and `unseenLeft > 0` or `lessonsLeft > 0` before `examDay`, schedule all of it today (coverage
wins; Part 1 Section 7).

**Anchored review-only start (technical revision, 1 October 2026).** `reviewOnlyFrom` is fixed by
the first plan built for an exam and exam date and carried forward in the stored days; it is
recomputed only when the exam or its date changes. From then on `workingDays = days from today
to reviewOnlyFrom`. Reason: recomputing `quiet` daily shrinks the stretch as the exam nears (12
days left gives 3, 4 gives 1), so a student following the plan exactly got new material until the
day before the exam; a simulation showed up to 7 days of overrun. On or after `reviewOnlyFrom`
with material left, it is spread over the days before the exam (`perDay(left, daysLeft)`), which
is the "let them cram" rule. Part 1's promise (last 7 days or last quarter) is unchanged.

**Worked checks the tests must include** (compute, do not copy):
- Today Wed 30 Sep 2026, exam Mon 7 Dec 2026: daysLeft 68, quiet 7, workingDays 61, review only
  from Mon 30 Nov; 120 lessons → 2/day; 900 unseen → 15/day.
- Exam in 10 days: quiet 2, workingDays 8.
- Exam in 4 days: quiet 1, workingDays 3.

### 4.3 Topic order

1. Rank scoped topics by accuracy ascending. A topic below the floor (`TopicAccuracy.isMeasured`
   false) is ranked at the student's overall accuracy across measured topics; with no measured
   topic at all, use authored order (`subject.ordering`, then `topic.ordering`). Ties: authored
   order.
2. **Continuity:** a topic with at least one read lesson and at least one unread lesson is placed
   first, ahead of the ranking, in the order they were started. It keeps its place until its
   lessons are all read.
3. **Prerequisites:** walking the ranked list, before emitting topic T, emit each prerequisite P
   of T that is in scope and not covered, recursively, depth first, in P's own rank order.
   Covered: every lesson of P read. A P with no lessons never blocks. P outside scope is ignored.
4. Covered topics drop out of the lesson sequence; their unseen questions stay in 4.4.

The build guarantees prerequisite links are acyclic (Section 6), so step 3 terminates. Defend
anyway: a visited set; on a revisit, skip and log `prerequisiteCycle`.

### 4.4 Choosing today's lessons and new questions

- **Lessons:** the first `lessonsToday` unread lessons walking the topic order, each topic's
  lessons in `ordering`.
- **New questions**, filled in this priority until `newToday` is reached:
  1. Unseen questions whose `lessonId` is a read lesson, oldest `readAt` first.
  2. Unseen questions whose `lessonId` is in today's lessons (they follow the lesson; 4.8).
  3. Unseen questions of topics in topic order, lessons' questions in lesson order, questions
     without a lesson last within their topic. This is what keeps the pace when lessons are
     skipped.
- **Passages:** a question with a `passageId` brings its whole unseen set
  (`PassageSetFiller`). The count may exceed `newToday` by the remainder of one set.

### 4.5 Reviews

Due = review states with `due <= end of today`, for questions in scoped topics. Order by
descending retrievability at `today`. Expose retrievability from `FsrsScheduler` as a public
`retrievability(ReviewState, DateTime now)` that calls the existing formula; do not duplicate it.

### 4.6 Backlog cap

- `capacity` = max(1, median of questions answered per day over the student's last 7 days on
  which they answered at least one question), read from attempts. Counting all answers, not only
  reviews, keeps a day of pure new material from producing a cap of zero. No such day: no cap.
- If due count `<= capacity`, include all. Otherwise include the first `capacity` in
  retrievability-descending order; the rest remain due and are reconsidered tomorrow.
- New material is not reduced by the backlog.

### 4.7 Mock day

- Only if the exam has a mock (`MockAvailability` is not `noBlueprint`; custom track uses its
  custom mock) and `daysLeft >= 2`.
- Window `[max(today, examDay - 6), examDay - 1]`. Target: `reviewOnlyFrom` clamped into the
  window. With `quiet == 0` (2 or 3 days left) that is `examDay - 1`, never the exam day.
- Free: if the target is before `lastSubmitted + 14 days`, move to that date if still in the
  window; else none.
- A mock submitted inside the window already: none.
- Pro and Free compute the same day; Free is shown it only on the day (Section 5).
- **Mock answers feed the pipeline (reverses May D4).** When a mock reaches a terminal status
  `completed`, `timeUp` or `forfeited` (not `discarded`), each answered question in `answersJson`
  is recorded exactly as a practice answer is: one `attempts_local` row with `origin = 'mock'`
  holding those items, and each item rated and applied to its review state by the same code path
  and correct-to-rating mapping practice uses, at `submittedAt`. Unanswered and retired questions
  are skipped. Recording is idempotent per mock attempt id (a re-run after a crash must not
  double-apply). Consequences, by design: answered mock questions stop being unseen; misses become
  due soon and enter 4.5 under the 4.6 cap; topic accuracy includes mock answers; the recompute
  trigger for answers (4.9) fires once after recording.
- Mock time per section (Progress "Time") is unchanged; it still reads `mock_attempts`.

### 4.8 Sitting composition

- A sitting takes `sessionLength` items from the remaining day (All: everything).
- Order of drawing: reviews first, then new questions whose lesson is read, then the rest.
  A new question whose lesson is in today's unread lessons is held back until that lesson is read
  or until the day's other items are exhausted.
- Arrangement inside the sitting follows the student's `ordering` setting using the existing
  pickers. **Exception:** questions from the Vocabulary topic are kept contiguous regardless of
  setting (Brunmair and Richter 2019: blocking better for words, g = -0.39; interleaving helps
  mathematics, g = 0.34; no effect for expository text).
- "One topic only" now means: group the sitting's items by topic, in topic order. Settings copy
  must stop saying "All 10 questions" and "seven from the topic, three from others" and describe
  proportions of the sitting. Copy is for the UI round.

### 4.9 Recompute and change log

- **Build triggers:** first read on a new local day; exam or exam date change; scope change;
  content revision change; assessment completion. Mid-day triggers rebuild today and replace the
  snapshot.
- **Within a day:** completed items are removed by id from the snapshot; nothing is added except
  by "I want to advance".
- **Advance:** when the snapshot's items are all done, `advance()` builds the plan for
  `today + 1` from current state and appends its lessons and new questions (not its reviews,
  which are not yet due) to today's snapshot, marked as advanced items. Log `advanced`.
- **Partial advance:** today counts as done when the original items are done; advanced items
  never make a day incomplete. Unfinished advanced items return to the remaining material and
  are scheduled normally. At day end they are logged as `advanced` with the count actually
  completed, never as `missedWork`, which counts only original items left unfinished.
- **Causes** (enum): `newDay`, `missedWork` (prior day's snapshot had unfinished items),
  `advanced`, `examDateChanged`, `examChanged`, `scopeChanged`, `contentChanged`,
  `orderChanged` (topic order differs because accuracy moved), `backlogCapped`,
  `assessmentCompleted`, `examPassed`, `prerequisiteCycle`, `missingExamDate`.
- Each entry stores before and after as the day counts (`lessonsToday`, `newToday`, reviews) plus
  the first three topic ids. Only counts that were real at the time are stored. **No entry states
  a verdict.** Log text rendering is for the UI round.

## 5. Consumers

| Surface | Today | After |
|---|---|---|
| Quiz tab session panel | `todaySessionPlanProvider` builds one session from buckets | Reads `roadmapProvider`; Start takes the next sitting from `SittingPlanner`. Keep `SessionPanelInProgress`, `NeedsAssessment`, `CaughtUp` states; `CaughtUp` becomes "today's plan done" and exposes advance |
| `todayInputsProvider`, `CountTodayBacklog`, `BuildTodayQueue`, weakness bucket in today's session | Cap and bucket logic | Removed from today's path. `WeaknessSelector` stays for drills and free practice |
| Home "Up next" | 3 lessons, all topics | `roadmap.today.lessonIds`; count from the engine; respects scope |
| Lesson reader "2 of N" | Reserved | N = today's lessons |
| Notifications composer | Streak and generic copy | Reads today's counts and `isMockDay` where it mentions today's work. Copy is UI round |
| `/plan` | Broken May page | Engine-backed; screen design is UI round. Free: today section; Pro: `weeksAhead`, `mockDay`, log |
| `/plan/dossier/:mockId` | Stub | Untouched |

Free and Pro: gate only at presentation, using the existing gate treatment
(`FaintBars`, heading kept, "Unlock with Pro" after free content, one teaser per screen).

## 6. Content: prerequisite links

- **Location: in the app, not the protected content package.** A checked-in Dart constant
  `lib/features/roadmap/data/topic_prerequisites.dart`: `Map<String, List<String>>` from topic id
  to prerequisite topic ids (`topic_upcat_<slug>` form). Reason: adding a field to the protected
  package changes the frozen E09 content identity (releaseSequence 2 payload, manifest and
  signature) and forces the CP-T5 device proofs to be redone; an app-side map does not. The
  engine reads it through a `TopicPrerequisites` provider so the source can move into content
  later without engine changes.
- **Validation (a unit test that fails CI):** every id exists in the shipped content topics; no
  self link; no cycle. Link across exams is allowed (the custom track spans exams). Unknown ids
  at runtime (content changed under an older app) are ignored and never block.
- **The audit:** a bounded Codex task drafts links for all 25 topics with a one-line reason each,
  mathematics and science first, into the map and a reviewable table in the plan. Aedwon or a
  reviewer approves before merge. Links only where a topic cannot be understood without the
  other; authored order within a subject is not a reason.
- **Protected package:** unchanged. No `releaseSequence` increment, no content digest change.

## 7. Amendments to other specs

1. `2026-08-04-study-plan-forward-calendar-design.md`: Section 3 "Do more each day" switch
   struck (replaced by advance). Section 4 mock marker: the plan now schedules one mock (evidence,
   log entry "one scheduled mock"). Section 4 "nothing tappable, no button" and screen composition
   are reopened for the UI round. Section 5 "wholly Free" replaced by Part 1 Section 6. Sections
   2 (evidentiary line) and 3 (pacing, month rule, cram) stand.
2. `2026-05-17-quiz-engine-and-modes-design.md` D7: the new-card cap and its override are struck;
   the engine decides. D7's fallback ("the engine must never hard depend on the plan") is
   replaced: today's session now depends on the roadmap by design; the fallback is the roadmap's
   own `planning` state.
3. `2026-08-02-pro-entitlement-consolidation-design.md` Section 2: add rows "Roadmap: today's
   plan — Free: everything — Pro adds: nothing — none" and "Roadmap: weeks ahead, mock date in
   advance, change log — Free: heading only — Pro: all — Gate 1". Add a row for cloud backup
   (Named Pro only), which is missing.
4. `2026-08-03-settings-design.md`: no "Do more each day" row. "How sessions are built" copy
   becomes proportional.
5. `2026-07-26-home-and-navigation-design.md` and `plans/2026-08-02-home-04-up-next.md`: Up next
   reads the engine.
6. `2026-07-28-quiz-tab-design.md`: today's session is sittings of the roadmap day; "caught up"
   is "today's plan done" plus advance.
7. `2026-05-17-mock-exam-design.md`: D4 ("Summative-only") and the non-goal "Feeding mock answers
   into FSRS" are struck. Its rationale (80 to 120 misses flooding the queue) is answered by the
   backlog cap (4.6), which did not exist then. The separate `mock_attempts` table stays; answers
   are additionally recorded per 4.7. The "Practice these next" link stays.
8. `2026-07-30-progress-tab-design.md`: accuracy and answer counts now include mock answers
   (`origin = 'mock'`). Time still comes from mocks only.
9. `2026-09-06-quiz-loading-performance-design.md` and the Readiness SSOT QLP entries: QLP
   preserved the existing selection policy (bucket accounting, the new-question cap) pending a
   design ruling. This spec is that ruling: the roadmap replaces the cap and buckets on the Today
   path. QLP's launch owner, preparation, freshness and performance rules stand and the roadmap
   runs inside them (Part 2 Section 2). The interleaved-tail ordering stays the default (4.8).

## 8. Evidence cited

- Review order under limited capacity: Jarrett Ye's FSRS simulations, "Improving sort orders",
  Anki Forums (https://forums.ankiweb.net/t/improving-sort-orders/50081). Retrievability
  descending best maintains retention; order irrelevant with unlimited capacity.
- Anki Manual, Deck Options (https://docs.ankiweb.net/deck-options.html), ascending
  retrievability suggested for backlogs; weighed lower than the simulation.
- Practice tests: Adesope, Trevisan and Sundararajan (2017), Review of Educational Research,
  272 effects, 188 experiments: g = 0.51 vs restudy; one practice test beat several; 1 to 6 day
  lag g = 0.82 vs under a day g = 0.56.
- Mock one week out changed intentions, not behavior: Phys. Rev. PER 19, 010130 (2023).
- Feedback after testing: Rowland (2014), Psychological Bulletin 140(6), meta-analysis of the
  testing effect: larger effects when tests are followed by feedback. Butler and Roediger (2008),
  Memory and Cognition 36(3): feedback after multiple-choice tests raised later correct recall and
  cut the lures students picked up from the test. Supports reviewing mock misses.
- Interleaving: Brunmair and Richter (2019), Psychological Bulletin, g = 0.42 overall; mathematics
  0.34; words -0.39; expository texts no effect.
- Early review gives less: FSRS models the stability gain as larger when retrievability is lower
  at review, so a review before due adds little; lapses reschedule wrong answers soon. This is the
  scheduler used as designed.

## 9. Verification

Focused while building; full on completion (AGENTS.md).

- **Engine unit tests** (pure): the three worked checks in 4.2; month rules; exam today,
  tomorrow, passed; coverage property: for random corpora and dates, following the plan daily
  reads every lesson and sees every question by `reviewOnlyFrom` (or by the exam for
  `workingDays <= 0`); topic order with and without accuracy, continuity, prerequisites, scope
  exclusions of a prerequisite, cycle defense; new-question priority and passage sets; backlog
  cap with 0, 1 and 7 history days; mock placement for Pro, Free cooldown in and out of window,
  no blueprint, taken already; advance; each log cause.
- **Mock recording:** completed, timeUp and forfeited record answered items only; discarded
  records nothing; a second run for the same attempt id changes nothing; 100 misses produce at
  most `capacity` reviews the next day.
- **Integration:** quiz tab Start draws sittings from the engine; completing items removes them;
  Home Up next equals `today.lessonIds`; scope change rebuilds; content revision change rebuilds;
  Free and Pro presentation gates.
- **Grep gates:** no `targetCount = 3`, no `newCardCap`, no `StudyPlanIntensity`, no
  `pace_curve`; no "behind", "ahead", "on track", "ready", "mastery" in roadmap strings.
- **Prerequisite map:** cycle, self link and unknown topic id each fail a unit test; the content
  digest and protected package identity are unchanged from E09.
- **Launch path:** Today's Start goes through `TodayQuizPreparer` and `QuizLaunchCoordinator`;
  a roadmap rebuild changes the stamp and invalidates the prepared sitting; the QLP-2 to QLP-4
  regressions (single session on rapid taps, warm Start without reselection, resume identity,
  late async results discarded) stay green. A query-count test proves the roadmap build reads no
  stem, choice, explanation or figure payloads.
- **Sync:** change log syncs for Named Pro and not for Free, in emulator tests.
- `flutter analyze` clean; `flutter test` green; build_runner regenerated, never hand edited.
- **Release:** E09 functional scenarios and QLP-5 device performance rerun on the new candidate
  (Readiness SSOT); Today-path performance must not regress against the recorded QLP-5 metrics.

## 10. Execution routing

Per Aedwon, 30 September: bounded code and non-code tasks go to Codex CLI (6.1 Sol, or 6 Luna
where the task is mechanical), each with an exact scope, files, commands and stop conditions. The
content audit (Section 6) is a Codex task. The lead keeps the engine core (Sections 4.3 to 4.9)
or reviews it line by line. Reconcile with
`docs/superpowers/decisions/2026-09-25-chatgpt-web-relay-routing.md` before dispatch.
Engineering stays paused until Aedwon lifts the E09 stop.
