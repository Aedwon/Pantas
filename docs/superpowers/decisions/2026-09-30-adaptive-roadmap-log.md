# Adaptive roadmap decision log

The design round on the adaptive roadmap, the orchestration layer that turns the app's
existing parts into one plan telling the student what to work on next. Chronological.
Later entries append; they never edit earlier ones.

Policy revision read at start: `origin/main` `feccc8b293a83b90721469180c671262d456c92b`.
Candidate inspected: `web/e09-qlp5-prepared-next-r1` at `13938943f447956af43d2de7e1f9999eb2418aee`,
confirmed as the current E09 product branch by the Readiness SSOT (Google Doc).

---

## 30 September 2026: the gap, and the brief

Aedwon paused all engineering. From his brief, verbatim:

> "The adaptive roadmap is supposed to be Pantas's main USP: Pantas should tell the student what
> to work on next and dynamically adjust that plan as they study. I recently discovered that this
> promise is not actually implemented end-to-end. The app has many of the pieces needed for the
> USP, but the orchestration layer that turns them into one adaptive roadmap is missing."

Inputs he named: exam and exam date, included topics, unread lessons, unseen questions, reviews
due from FSRS, quiz/assessment performance, completed lessons. "The roadmap should also be smart
enough to reassess if a user is behind or chooses to advance." UI is a later conversation.

### What the candidate actually does (checked in source, not from specs)

- The `/plan` route exists, but its data providers throw `UnimplementedError` and nothing in
  `lib/` overrides them. The page is the May mastery design (pace curve, tolerance band), not the
  approved 4 August forward calendar.
- Today's quiz session introduces new questions against `QuizPreferences.newCardCap`, a fixed
  default of 10, independent of the exam date.
- Home's Up next is a hard-coded three unread lessons from the weakest topics
  (`targetCount = 3`). It ignores the exam date and topic exclusions (track scope).
- Working parts: FSRS scheduler and review states, topic accuracy ranking, exam date with month
  precision, track scope (topic exclusions), daily new-question introduction counter.

---

## 30 September 2026: behind or ahead is handled silently

Options offered: (1) recompute silently, (2) recompute and state plain counts (recommended),
(3) reopen behind/ahead/on-track verdicts.

> "go 1, it must be as frictionless as possible to the user while still being motivating. is that
> feasible? i don't want users to think too much about things. they should just be shown their
> updated roadmap. but of course, that's only on the surface. for power users maybe the underlying
> system can keep logs of what changed in the roadmap due to them advancing or being behind. does
> that make sense? we can talk about the UI later because there are things I want to change
> overall so that's another conversation"

**Chosen: 1, plus a change log.** The plan recomputes; the student sees only the updated plan.
The engine records every change and its cause (missed days, extra work, exam date change, topic
change, new content) from the start, synced with the account. Motivation comes from measured facts
(today done, consecutive days, coverage out of total), never verdicts. My recommendation (2) was
not taken.

---

## 30 September 2026: lessons and new questions within a topic

Options: (1) strict lesson first, (2) independent streams, (3) lesson first by default, questions
still arrive on time if the lesson is skipped (recommended).

> "go with 3"

---

## 30 September 2026: topic order

Options: (1) authored order, (2) weakest first, (3) authored order with weak topics moved up
(recommended).

> "um my answer to that would be, weakest first, but if there are dependencies/prerequisites then
> those are prioritized"

**Chosen: weakest first, uncovered prerequisites ahead of their dependents.** No performance data
means authored order. A prerequisite already covered is not rescheduled.

**Correction during the exchange:** the content has no prerequisite data. Options: author links
(recommended), infer from authored order, defer prerequisites.

> "then we will audit the content to have prerequisite/dependency data. would that be feasible?"

**Chosen: a content audit adds topic-level prerequisite links.** I first said about 160 topics;
the actual corpus is 25 topics and 158 lessons. Links are validated (no cycles, no unknown
topics); a link to an excluded topic is ignored. The content change requires the E09 content
evidence to be rerun, which the code change requires anyway.

---

## 30 September 2026: execution routing for this workstream

> "you can use codex with the 6.1 Sol model to execute it. you only need to give it very specific
> bounds and plans. heck, you can use even smaller models like 6 Luna (you decide the effort
> level) if possible. i have codex cli installed and i've already logged in. for your task, only
> planning this and code work is necessary. if it's not code, you can delegate it to codex"

Recorded as a routing instruction for this workstream. It differs from
`2026-09-25-chatgpt-web-relay-routing.md` and should be reconciled there before dispatch.

---

## 30 September 2026: performance changes order, never amount

I asked whether strong topics may shrink or be skipped. He asked what he had decided before.
Answer given: the 4 August "let them cram" decision covered lack of time, not strong performance,
so this was new.

> "yes let's go with your recommendation. their strong topics will still have to appear time to
> time based on the FSRS. this is better to ensure retention correct?"

**Chosen: coverage stays complete; strong topics are scheduled later.** Correction given: FSRS
only holds questions already answered, so coverage is what brings a strong topic's unseen
questions in; FSRS then keeps them.

---

## 30 September 2026: review backlog after an absence

Options first offered: show all, cap and spread over a short window (recommended, with "days away"
as the window), pause new material. He asked whether the backlog spreads to the exam; I said no
and compared spread-to-exam with catch-up over the days away.

> "i don't think this matter should be up to my preference. which is the most scientifically
> backed decision?"

Checked externally. FSRS author's simulations (Anki Forums, "Improving sort orders") found that
under limited daily capacity, retrievability-descending order best maintains retention; with
unlimited capacity, order does not matter. The Anki manual suggests ascending retrievability for
backlogs; the simulation evidence was weighed higher. No source supports a particular catch-up
window length. **My earlier "most overdue first" was the weaker choice and was withdrawn.**

Revised recommendation: daily backlog reviews equal to the student's own measured recent daily
volume, ordered by descending retrievability, new material continues at pace.

> "okay, as long as it's backed up with data"

**Chosen.**

---

## 30 September 2026: study-method decisions are made from evidence

While I was offering mock-scheduling options:

> "moving forward actually, i'd like decisions like these to be made not of my preference but by
> data. i should only be asked on my preference if there is no clear data to decide on it. this
> applies to the concept of studying. for how the app "feels" i still have a majority say"

Added to `WORKFLOW.md` (Conversation and complexity) on main after he answered "proceed" to the
request to add it there.

---

## 30 September 2026: one scheduled mock, 1 to 6 days before the exam

Options first offered: keep 4 August (no scheduling), schedule a mid-plan and a late mock
(recommended), one late mock. Withdrawn under the evidence rule above and decided from sources:

- Adesope, Trevisan and Sundararajan (2017), meta-analysis of practice testing, 272 effects from
  188 experiments: practice tests beat restudying (g = 0.51); one practice test outperformed
  several; a 1 to 6 day lag before the final test gave the largest effect (g = 0.82) versus under
  a day (g = 0.56).
- Phys. Rev. PER 19, 010130 (2023): a mock one week before the exam changed study intentions, not
  study behavior.
- No evidence found for a mid-plan mock. Topic order already takes performance from quizzes.

**Decided: the roadmap schedules one mock, 1 to 6 days before the exam, inside the review-only
stretch, respecting the Free 14-day limit.** Strength stated as moderate: the evidence is on
practice tests generally, not full-length mocks. This reverses the 4 August choice that the plan
never schedules mocks. My mid-plan recommendation is withdrawn.

> "proceed"

---

## 30 September 2026: going ahead is a one-tap continue, not a setting

Options: (1) keep the 4 August "Do more each day" switch (1.5x, a multiplier with no basis),
(2) after today's plan is done, one tap continues into tomorrow's items and the plan recomputes
(recommended), (3) both.

> "go with 2 except copy correction "I want to advance" or something?"

**Chosen: 2.** The switch and its 1.5x multiplier are struck, reversing that part of the
4 August spec. Button wording is provisional and belongs to the later UI round; his direction is
wording in the spirit of "I want to advance".

---

## 30 September 2026: the roadmap sets daily amounts; the day is served in sittings

He confirmed the roadmap controls daily lesson and quiz counts:

> "also i must mention/clarify that the amount of lessons and quiz items for the day are
> controlled by the roadmap correct? so the 10-item quiz isn't set it stone"

The fixed new-question cap (`newCardCap`, default 10) and Home's fixed three lessons are removed.
Options for large days: (1) sittings sized by the existing session-length setting (recommended),
(2) one session, (3) drop the setting. He asked which gives a smart default the user can change,
the rationale, and whether a day can have several sittings. Rationale given: comfort and
motivation; evidence on within-day sitting length is weak, so this is a feel decision.

> "yes, keep sittings with 10 as default."

**Chosen: sittings, default 10, options 5, 10, 20 and All.** The setting splits the day; it never
changes the day's total or topics.

---

## 30 September 2026: session ordering setting and edge cases

He asked whether "How sessions are built" (One topic only, Interleaved tail, All mixed up)
affects the roadmap. Answer: it arranges each sitting, never what the day holds. Its copy assumes
a fixed 10 and must become proportional; "One topic only" changes meaning to grouping today's
questions by topic. Default to be decided from interleaving evidence in the spec.

Edge-case list presented (23 items) with decisions derived from the agreed rules: month
precision to the first of the month; date change recomputes; exam tomorrow schedules all that is
left; exam today is reviews only; mock placement under the Free 14-day limit; excluded topics leave
the plan with history kept; new content is scheduled even in the review-only stretch (coverage
wins); everything covered becomes reviews only; no performance data uses authored order;
mid-day performance changes apply tomorrow; off-plan study counts; a lesson counts as read at its
end; day boundary at 4 a.m. local; offline on device; log synced; per-exam plans with shared
review history; roadmap and log are Free per the entitlement table.

He asked what "reviews only" means: only already-answered questions the scheduler has due, no
new lessons or questions assigned; free study stays open.

Passed exam date: (1) ask once whether they took it, offering a new date or an exam switch,
reviews only until answered (recommended); (2) continue quietly.

> "okay ask once"

**Chosen: 1.**

---

## 30 September 2026: roadmap tier, and a gate missing from the entitlement table

He asked for Free versus Pro to be considered across all surfaces, first as a table and then
visually. Pages shown (companion session 62184-1790763846): `free-vs-pro-roadmap.html`,
`roadmap-tiers-visual.html`, `free-vs-pro-all-surfaces.html`. His comment on fidelity:

> "some of the things rendered are not the actual screens but eh it's enough representation i
> get it already."

Earlier exchange on the 4 August tier line: it was derived in the spec from the "nothing the
student produced is paywalled" rule, never chosen directly. He pointed out:

> "um the student did not produce the roadmap so it doesn't apply? it was on our side? the app's
> engine did that roadmap correct? the results are still shown"

Correct: the engine produces the roadmap; the student's own results stay free regardless.

Options: A split, Free gets today's adaptive plan and Pro gets the weeks ahead, the mock date in
advance and the change log (recommended); B all Free; C all Pro, Free falls back to fixed amounts.

> "1. A"

**Chosen: A.** Reverses the 4 August "plan screen is wholly Free". Add a row to the entitlement
table under Gate 1.

**Found in source:** cloud backup and sync are Pro-only (2026-08-28 sync spec, account model:
anonymous Free and named Free are local only). The 2 August entitlement table does not list it.
**Corrects edge case 21:** a Free student's plan state and change log are device-only and do not
survive a reinstall. A Pro student can buy without signing in; backup needs sign-in and Pro.

---

## 30 September 2026: spec drafted, and what grounding changed

He asked for the spec to be grounded in the actual app, not only specced:

> "okay go write the spec, meanwhile i'll enable the google workspace connector. that's not a
> prereq for you to write the spec right? also please ensure we're not just speccing, please ground
> yourself with what the project/app actually has rn. i will have to make adjustments to the UI but
> the underlying engine, from the top-down will come from this roadmap maker"

Spec: `docs/superpowers/specs/2026-09-30-adaptive-roadmap-design.md`, grounded against
`web/e09-qlp5-prepared-next-r1` at `13938943`. Corrections and lead calls made while grounding,
each stated in the spec for his review:

- **Day boundary is local midnight, not 4 a.m.** Streaks already use local midnight; two
  definitions of "today" would disagree. Reverses edge case 19 as I proposed it.
- **Backup is Pro-only**, so a Free student's change log is device-only (already logged above).
- **The exam date is one per student**, not per exam. Whether switching exams asks for a new date
  is left to the UI round.
- **Weak-spot drilling leaves the daily plan** (evidence: FSRS lapses reschedule wrong answers;
  reviews before due add little). Weak topics are served by order. Drills stay in free practice.
- **Vocabulary questions stay grouped within a sitting** (Brunmair and Richter 2019: blocking
  better for words).
- **Topic continuity:** a started topic's lessons finish before the next topic starts. Lead's
  call, not evidence.
- **Unmeasured topics rank at the student's overall accuracy.** Lead's call, not evidence.
- **Month precision inside the current month:** ask once for the day; plan to the month's last
  day until answered. Lead's call, flagged as easy to reverse.
- **Mock placement fixed in self-review** so an exam 2 or 3 days out never puts the mock on the
  exam day; **backlog capacity** counts all answers so it cannot become zero.

---

## 30 September 2026: partial advance

> "suppose the user presses I want to advance but they don't finish all. does the system take
> that into consideration?"

It did for pacing (tomorrow recomputes from what is left), but the spec would have logged the
unfinished extras as missed work and could have left the day not done. **Fixed:** today is done
when the original items are done; unfinished advanced items return to the pool and are logged as
advanced with the count completed, never as missed.

---

## 30 September 2026: mock results feed reviews (reverses May D4)

> "question, how does the results of a mock exam affect the roadmap?"

Found from source: not at all. Mock answers live only in `mock_attempts`; they reach neither the
review scheduler nor topic accuracy, and mock questions stay "unseen".

> "there was a spec before that we didn't include mock results in the roadmap because it would
> ruin the FSRS or something. can you investigate this?"

`2026-05-17-mock-exam-design.md` D4 kept mocks summative-only so one mock would not dump 80 to
120 misses into the review queue, and to avoid a "punishment for taking the mock" feel. No evidence
was cited. The flood concern is now answered by the roadmap's backlog cap. Evidence (Rowland 2014;
Butler and Roediger 2008) favors feedback and relearning after tests.

> "yes it should be amended. so there was a way for that problem then? it was just missing a
> higher mechanism (this roadmap engine) to consolidate things?"

**Decision:** every terminal mock except a discarded one records its answered items as ordinary
answers (reviews and topic accuracy), under the daily review cap. Amendments to the May mock spec
and the Progress spec are listed in the roadmap spec, Part 2 Section 7.

---

## 30 September 2026: weak topics wording and the scheduler's role

> "\"No extra 'weak spot' drilling in the daily plan\" is this advisable? isn't the roadmap
> supposed to surface your weak spots first? or am i misunderstanding"

> "but FSRS is still being utilized here? can you explain to me their relationship/mechanism in
> simple terms"

> "okay make the necessary changes please"

No change in behavior. Part 1 Section 5 item 1 renamed "Weak topics are handled by order and
reviews, not an extra drill block" and rewritten to name both channels. Part 1 Section 4 gains a
plain statement of the split: the scheduler decides when each answered question returns; the
roadmap decides how much and in what order.

---

## 30 September 2026: Part 1 approved

> "Part 1 is approved. do I need to read Part 2?"

Part 1 of `specs/2026-09-30-adaptive-roadmap-design.md` approved as of commit e4bc9511. Part 2 is
the implementer's section; the one consequential item surfaced to Aedwon from it is that the
prerequisite links drafted in the content audit need Aedwon's or a reviewer's approval before merge.
Complexity level pending.

---

## 30 September 2026: reconciled with the Readiness SSOT checkpoint

> "before that, you've checked the entire checkpoint tab of the google doc right? nothing you
> haven't considered?"

Mistake: the spec was called grounded before the whole Readiness tab was read; only keyword
searches had been run. The full tab (900 lines) was then read. Three gaps found:

1. The QLP work built one prepared launch path for Today (`TodayQuizPreparer`,
   `QuizLaunchCoordinator`, `QuizPreparationStamp`); the spec did not say the roadmap must run
   through it.
2. QLP-1 forbids full-bank hydration; the spec only said "no regression".
3. Prerequisites in the protected content package would change the frozen E09 content identity
   and force the CP-T5 device proofs to be redone.

> "okay update it. but hold on they're not going against what we design the roadmap to be right?"

No conflict with the approved design. QLP had preserved the old selection policy (cap and
buckets) only until a design ruling; the roadmap is that ruling. **Changed:** roadmap plugs into
the preparer's plan-builder seam and the preparation stamp; inputs are metadata only; QLP-5
budgets apply; prerequisite links move to an app-side map validated by a unit test, leaving the
protected package unchanged (Part 1 Sections 8 and 9 reworded accordingly). Amendment 9 added.

---

## 30 September 2026: complexity level and reuse of E09 work

> "go with balanced, but also work has been done until E09, that can be reused right? or maybe
> not. i'll leave the judgement for engineering specifics to you"

**Complexity: balanced** (as recommended: full spec, change log syncs for Pro, property tests for
coverage, idempotent mock recording; about 1 week of build). Engineering specifics delegated to
the lead. Reuse judgement recorded in the implementation plan.

---

## 30 September 2026: implementation plan written; lead technical revisions

Plan: `docs/superpowers/plans/2026-09-30-adaptive-roadmap-engine.md`, grounded read-only on the
E09 candidate worktree at 13938943. No code changed; engineering remains paused until Aedwon lifts
the E09 stop for this work.

**Reuse of E09 work (delegated judgement):** the roadmap branch starts from the E09 candidate and
keeps E02 to E08 work. CP-T5 content proof stands (content identity unchanged). E09 functional
#22 to #28, QLP-5 and QLP-6 are rerun on the new candidate.

**Lead technical revisions to Part 2, found while grounding:**

1. Sitting arrangement does not reuse the Today pickers. They select as well as order (a topic id
   drops other topics; the fully mixed picker drops items it cannot place), which would silently
   drop planned items. The planner arranges with the existing non-dropping helpers
   (`RecencyFilter.noConsecutiveSameTopic`, `groupPassageSets`).
2. Mock answers are recorded like the placement assessment: `responseMs: 0`, origin `mock` added
   to the untimed set, rating good or again, no review log rows (no per-question timing exists).
   Readers that already count `mock_attempts` (Your record, test-mode delta) skip `mock` rows so
   nothing is counted twice.
3. New change-log cause `mockAnswersRecorded` names the recompute spec 4.7 requires.
4. Lessons are read through a new lightweight metadata query; the existing `lessonsByTopics`
   decodes every lesson body and would break the QLP-1 rule.
5. Home's weakest-topic rows (Today requests with a topic) stay free practice outside the plan on
   the existing bucket path, with the fixed new-question cap removed.
6. The change log's cloud backup touches `firestore.rules` and the `cleanupSyncData` function;
   they are edited and tested locally only. Deploying them is a separate authorized step.

**Live defect found:** `AttemptsRepository.averageResponseMs` and `averageResponseMsByTopic` count
the placement assessment's `responseMs: 0` items, which lowers the practice picker's pace and the
debrief's per-topic averages. Fixed in plan Task 15 because mock answers would make it worse.

**Deferred to the UI round:** the advance control, the plan screen, the log viewer, "2 of N",
Settings copy. The engine exposes what they need.

**Process mistake:** commits 54a0ecf5, e4bc9511, b722d285, 6bf9725e, e7c5a070 and the balanced
entry carried a `Co-Authored-By` trailer, which `WORKFLOW.md` forbids and the attribution check
rejects. Stopped from this commit on. Rewriting published main history needs Aedwon's explicit
authorization.

---

## 30 September 2026: history rewrite and build start

> "yes rewrite them, and go ahead with the build but use codex, i have the cli installed. use
> 6.1 Sol High"

**History rewrite:** the six commits from 54a0ecf5 to 7b0aea3b (and the plan commit after them)
were rewritten on main to drop the credit trailer, with identical trees
(`82bea2e4` tree equals `7d6b110a` tree). Pushed with `--force-with-lease` against 7d6b110a.
New SHAs: 299373fc, b6740235, 4bd00552, f6b65433, cb22fe6c, f8f1e668, 82bea2e4. Earlier SHAs in
this log refer to the pre-rewrite commits with the same subjects.

**Build:** the E09 stop is lifted for the roadmap build only. All Codex tasks run on
`gpt-6.1-sol` with high reasoning, overriding the plan's Luna rows. Device work (plan Task 18
Step 6) still waits for Aedwon's go-ahead.

---

## 30 September 2026: Codex runs without a sandbox; lead orchestrates

> "i authorize you to invoke --dangerously-skip-permissions to codex as needed. your role should
> be an orchestrator/overseer"

Codex's equivalent flag is `--dangerously-bypass-approvals-and-sandbox`; used from Task 3 on
(Task 2 was already running in the sandbox). Reason it was needed: the sandbox blocked git's
lock files, so Codex could not commit (Task 1 was committed by the lead after review, cb5c453e).
Briefs still confine Codex to the roadmap worktree and forbid destructive commands, pushes,
merges and deploys. The lead dispatches, reviews each result against the plan, and does not
write implementation code.

Finding from Task 1 (not fixed, outside the plan): the streak's gap count uses
`Duration.inDays` between local midnights, which undercounts across a daylight-saving change.
No effect in the Philippines, which has no daylight saving.
