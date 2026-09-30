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
