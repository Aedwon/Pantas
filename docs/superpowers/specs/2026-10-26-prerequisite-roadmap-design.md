# Prerequisite-aware roadmap and its Free and Pro split

Date: October 26, 2026. Status: design agreed in conversation with Aedwon; queued for the engineering path
after the CSE content work (STATUS rows R1 to R3). Complexity for R1 and R2 is to be chosen at engineering
kickoff (recommendation: balanced).

## Why

The roadmap orders whole topics from a hardcoded list of four links (`lib/features/roadmap/data/topic_prerequisites.dart`,
approved October 1) and orders lessons inside a topic by `ordering`, which no lesson sets, so the content export falls
back to file order (alphabetical). The audit's lesson-level prerequisite map (`lesson-prerequisites.json` on the audit
branch) is never read. Aedwon's direction:

> a strict lesson order isn't good i think. because the purpose of having the dependencies is that the roadmap should
> recommend learning a prereq first before another lesson, if that makes sense.
> a 2nd consideration of it is the performance for that lesson.
> think of this as a smart but systematic roadmap maker. this should be carefully but intelligently considered

> could we make a distinction for Free and Pro? just to give users a better reason to convert.

## Content input (owned by the content work, not engineering)

- Each lesson's frontmatter gains `prerequisites`, a list of `{lesson: <lesson id>, strength: required | helpful}`.
  Links may cross topics and subjects. `required` means the lesson cannot be understood without the other (the October 1
  rule: real dependency, never authored order). `helpful` means it is easier with it.
- Wrong-choice rationales may carry an optional `gapLesson: <lesson id>` when the mistake comes from a prerequisite gap
  (for example "added numerators and denominators" points to fractions). Used by the diagnosis (R2).
- Topic links are derived, not hand-kept: topic A depends on topic B when any lesson in A has a `required` link to a
  lesson in B. This replaces the hardcoded map.
- Codex drafts both from the audit's prerequisite data and the lessons; the lead reviews every `required` link.
  Lesson `ordering` stays an authored tie-breaker only.

## R1. Prerequisite-aware recommendations (launch)

Rules over the lesson map, using inputs the engine already has (topic scores, lesson read times, FSRS due reviews,
question-to-lesson tags, exam date, study days). Applies to the client roadmap domain (`lib/features/roadmap`) and
the server roadmap (C10) so both produce the same plan.

1. Per-lesson mastery state from the student's answers to that lesson's questions: `unseen` (not read), `learning`
   (read, fewer than 5 answers), `weak` (5 or more answers, recent accuracy below the threshold), `solid`. Recency
   weighting and FSRS recall decide "recent": a lesson's recall is the mean FSRS retrievability of its questions.
   Starting threshold 70%; tune with data.
2. Choose the next target as today (exam weight, weakness, coverage, exam date pressure).
3. Before recommending a target, walk its `required` prerequisites. If one is `unseen` or `weak`, recommend it first.
   Recurse, stopping at the first prerequisite whose own required links are solid. Never recommend a lesson whose
   required prerequisite is weak unless the student opens it themselves.
4. After a session, attribute misses: if a missed question's lesson has a weak required prerequisite (or the chosen
   wrong choice carries `gapLesson`), schedule that prerequisite before re-practicing the lesson. If the prerequisites
   are solid, the gap is in the lesson itself.
5. Never block. Every lesson stays openable. `helpful` links and authored `ordering` only break ties.
6. Every recommendation carries a short reason string (`because`), for example "Percent problems build on it."
7. FSRS is unchanged: it stays the per-question memory model and keeps scheduling reviews. Due reviews remain plan
   items; overdue reviews are always eligible. Mastery reads FSRS; nothing here writes FSRS state.
8. Cycles in the lesson map are a content error: the export rejects them; the engine ignores a link that closes a cycle
   (the existing `cycleDetected` handling).

Acceptance: unit tests for each rule, including a weak prerequisite two levels deep, a solid prerequisite (no detour),
a cycle, a lesson with no questions, and topic links derived from lesson links matching the old four links for UPCAT.

## R2. Free and Pro split for the roadmap (launch for the debrief line; screens after launch)

Follows the settled gates (August 2 and October 4): Pro interprets, Pro gets the instrument, Pro lifts volume caps;
nothing the student produced is ever paywalled; Free gets today's adaptive plan, Pro gets the weeks ahead, the mock
date in advance and the change log (September 30).

| | Free | Pro |
|---|---|---|
| Today's plan | the full engine, including prerequisite detours | same |
| Why a pick | the one-line `because` | the diagnosis: which misses trace to which prerequisite, and the mistake behind them |
| Knowledge map | not shown | lessons marked known, ready to learn or blocked, prerequisites drawn (after launch) |
| Looking ahead | today only | weeks-ahead plan (existing) and a readiness forecast for exam day (after launch) |
| What if | none | change study days or time and see the plan and forecast move (after launch) |

The engine is never weaker for Free. Recommended, to confirm at kickoff: no cap on how far a Free user can advance
(it would re-gate free lessons and punish the most engaged users, against the October 4 and quiz-tab decisions).

### The debrief gap line (approved placement)

Aedwon chose the session-finished screen ("1 sounds good"; mockup shown October 26 in the new design's session end
layout, `session_end_screen.dart` on `integration/new-design-r1`).

- Free: inside the "Next" card, under the free recommendation and its `because` line, one dismissible row: gold `PRO`
  tag, "3 of your misses trace to an earlier lesson. See which", opening the paywall at the diagnosis.
- Pro: the row becomes a section "Where your misses came from" above "Your mistakes": one row per traced prerequisite
  ("3 trace to converting fractions" with the question numbers and the mistake from `gapLesson` rationales) and one row
  for misses within the lesson.
- Honesty rules: show only when R1 attribution actually traced misses to a prerequisite; at most once per session,
  dismissible, never on two screens the same day. Free still gets the fix through the plan.
- UI changes follow the visual-companion rule: the final board needs Aedwon's acceptance before implementation.

## R3. After launch: the probabilistic engine

Replace R1's states with beliefs, once real answer data exists to tune against:

- Mastery as a probability per lesson, updated by answers and spread along the map (success on a lesson raises belief
  in its prerequisites; failure lowers it a little until confirmed), decaying with FSRS recall.
- Recommend new lessons from the "ready to learn" frontier: all required prerequisites likely known.
- Pick the next activity by expected score gain per minute until the exam: exam weight × mastery gap × chance of
  learning it now ÷ minutes, plus an unlock bonus for prerequisites that block many lessons; shift toward review and
  high-weight topics as the exam nears.
- Adaptive placement: the existing assessment picks each next question for the most information on the map
  (about 15 questions instead of a long diagnostic).
- The Pro knowledge map, readiness forecast and what-if screens from R2 build on this.
