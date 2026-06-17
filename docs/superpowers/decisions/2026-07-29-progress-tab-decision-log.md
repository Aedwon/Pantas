# Progress tab: decision log and handoff

**Covers:** 28 to 29 July 2026, the Progress tab design session.
**Spec produced:** none yet. This document is the state of play.
**Companion session:** `.superpowers/brainstorm/7810-1785268427/` (gitignored).
Earlier plates in `.superpowers/brainstorm/2111-1785242838/`.

This is both the decision log and the handoff. Read it whole before continuing:
the conversation it came from was cleared.

---

## What Progress is

Four questions, in descending urgency, decided at the first plate-free round.

| | Section | Question it answers |
|---|---|---|
| B | **The diagnosis** | Where are my points going, and why? |
| C | **The mirror** ("How you work") | Who am I as a test taker? |
| A | **The record** ("Your record") | Am I actually moving? |
| D | **What's fading** | What am I losing? |

The tab **opens on B** rather than on a menu of four. C, A and D are reached
from three rows at the bottom, each carrying its own verdict in its subtitle.

---

## Settled decisions

### 1. All four sections, ordered B C A, plus D

**Rejected:** picking one charter. I proposed A, B or C as competing charters
and recommended B alone.

> "with your options, why not all three? they have different screens that go
> deeper. idk what do you think? in terms of order, we can do B C A. perhaps you
> might be able to come up with other things aside from the ones you already
> mentioned"

**D was added** because it is the only view of what FSRS already knows that no
surface shows: Quiz shows a due count, nothing shows the decay shape.

**F, "the exam-room self", was proposed and dissolved.** Aedwon:

> "F kind of but the 'How do I perform under conditions' question is already
> answered by tendencies in C right? correct me if I'm wrong"

He was right, and worse than he put it. X1 pressure and P4 stamina are Home's
two headline tendency cards. P2 pacing is already on the mock results screen as
"time against suggested". Only S1 flag discipline was unclaimed, and that is one
sentence inside C. The cross-mock view survives as history, which is A.

**Cost of the four-section shape:** more surface to build than a single-charter
tab, and four destinations to keep from drifting apart.

### 2. Pace lives as the opening of B, not as its own section

**Rejected:** its own section between B and C (adds a fifth destination to carry
two figures); and not shipping it at all (loses the only honest answer to "am I
ready").

> "yeah let's go with 1. that's also why i didn't select E because as I
> understood it, the diagnoses should come with the pace included."

Confirmed independently by the original Spec 11, where the "on pace / behind /
ahead" indicator was already in the **Free** tier.

**Hard rule:** this stays arithmetic. It may never grow into a score projection.
"Readiness" stays reserved per `2026-07-18-ui-redesign-design.md`.

### 3. Score impact ships as a delta, never a total

"Fixing these three is worth about 9 points." Nothing on the tab states a
projected total.

**Rejected:** a projected total ("fix these and you are looking at 72%"), which
needs a model mapping practice onto exam outcomes that does not exist; and
points-at-stake with no projection at all, which is safe but says where the
points are without saying what fixing them buys.

### 4. Free reads the verdict, Pro reads the working

Replaces Spec 11 Amendment D's per-panel Free/Pro table with one rule for the
whole tab.

**Evidence stack:** Home already decided this for the tendency deck ("knowing
what is being compared is what creates the want"); the Quiz log's freemium
research says EdTech converts at 2.6% with 23% of conversions past six weeks, so
the Free tier must survive six weeks of daily use; and principle 3 below.

**Status: proposed, not accepted.** The teaser question was deferred so the whole
surface could be judged first. See Open, item 1.

### 5. Vocabulary

- **Points**, never "marks". Saved as memory `pantas-score-vocabulary`.
  > "marks doesn't make sense in a Filipino learner's perspective. we don't use
  > that language to represent scores or grades."

  It was also a collision: `mark` already means the answered dot, the flag
  pennant and the outcome mark on a reviewed question.
- **Questions**, never "cards". FSRS jargon, never in a UI string.
- **No article on archetypes.** "Night-Owl Sprinter", not "The Night-Owl
  Sprinter". `archetype_catalog.dart` was always right; the article was my
  invention and read as AI-generated.

### 6. The six calls of 29 July

Asked as a numbered list, answered as one.

| | Question | Decision | Rejected, and its cost |
|---|---|---|---|
| 1 | Pace panel name | **"Your pace"** | "Finishing in time" (weak), "Pace to exam day", "Where you'll be by exam day" |
| 2 | Green as the healthy end of the severity ramp | **No.** Ramp stays rust, amber, ink | Board green as a fourth step would spend the primary-action budget and would then have to apply app-wide |
| 3 | Section name | **"Points within reach"** | "What fixing them is worth" had no referent for "them". The section below became "Why you lose points" for the same reason |
| 4 | "Practice the 61" button on What's fading | **Cut** | Today's session is already drawn from these questions. A second door repeats the deleted "Study" row's mistake |
| 5 | Milestones | **Its own design pass** | Four invented rows were drawn and caught. Provenance is real (4 Wrapped artifacts, `user_metrics_artifacts_local`, the shipped `wrapped_history_stub` panel); the form was never designed |
| 6 | Total time figure | **"Time in sessions"**, shown now | Cannot say "studied": reading time is untracked, deferred in the Study spec. The label carries the limit |

> "1. Your pace / 2. oh okay then don't go green then / 3. Points within reach /
> 4. okay cut it / 5. have to design this properly on its own / 6. sure you can
> use sessions"

### 7. The chevron on a point row opens the Study map at that topic

Recorded in the companion as `chev=study`.

**Rejected:** starting a practice session on the topic, which recreates Home's
Practice panel and is exactly the redundancy caught earlier; and a rotating
chevron unfolding to the questions you keep missing, which is real depth but
quietly turns the row into a paywall for Free users.

**Constraint this had to work around:** the Study spec Section 8 item 4 deleted
`/study/topic/:topicId` and `LessonListPage`, so there is no topic page to open.
The chevron scrolls the map to the topic.

### 8. Layout grammar, after two rejected passes

- **Data rows:** `bodyMedium`, Source Sans **14/400**, title and subtext each on
  their own line, meta in sans **13/600** tabular.
- **Navigational rows:** serif 15/700 with a chevron. This is the Quiz spec's
  practice-row rule and it now appears in exactly one place, the "Go deeper"
  rows.
- **Section headers:** serif 15/700 over a 1px rule.
- Rows are 40 tall, 44 where a chevron makes them tappable.
- Compared figures are joined by **"vs."**, not by a hairline, because the two
  figures are one fact.

> "the section header and the 'list' under it has the same weight. the subtext is
> also on the same line"

Two faults underneath that. A real bug: rows were nested `<span>`s, which are
inline, so every subtext rendered on its title's line. And a real design error:
I had used serif 15/700 for both headers and row titles, when `InkTableRow`
renders titles in sans 14 and always had.

---

## Applied psychological principles

From `~/Downloads/Private & Shared/Applied Psychological Principles`. Six
principles; four bear on Progress.

| # | Principle | How it applies |
|---|---|---|
| 1 | Decision fatigue | The tab opens on the diagnosis, not on a menu of four equal rows. Defaults read as recommendations |
| 2 | Goal gradient, never start at 0% | **Currently violated.** Progress renders blank for a new user: `_SignalStatsPanel` returns `SizedBox.shrink()` and the archetype block does the same. The assessment already writes `topicMasteries`, so a true non-zero figure exists from minute one |
| 3 | Reciprocity | The free tier must be a real short report with the offer beneath, not redacted bars. This is decision 4 above |
| 5 | Loss aversion | **D is its honest form.** FSRS produces a true loss every night, so nothing has to be manufactured. **Boundary written into the spec:** losses may be stated only when already true and still preventable. Never a countdown to a loss the app itself chooses to inflict |
| 6 | Contrast | The Pro offer always sits after the free content, so the comparison is what you already know against what is left, never a price in isolation |
| 4 | Endowment | The mistake tags are the student's own three taps. Progress shows them back attributed, as their notes, not absorbed into an anonymous chart |

---

## The four screens as drawn

Latest plate: `progress-v3.html`. A "Compare against" toggle shows the previous
pass.

**The tab.** App bar "Progress". Exam short name. Ruled panel **"Your pace"**
(62% read, 41 days left, "At three lessons a week you finish nine days after the
exam. Four a week closes the gap.", amber on the nine days only). Section
**"Points within reach"** (count "21 points"), five topic rows with sans 13/600
figures and a chevron. Closing line: "Ordered by what you can still get back, not
by what you are worst at. Home ranks the same topics differently, on purpose."
Section **"Why you lose points"** (count "11 noted"), a StatsBand of the three
debrief tags, then an interpretation, not a restatement. Section **"Go deeper"**
with three navigational rows.

**How you work.** Panel "Your profile" with the archetype and its line. Then
Under pressure, Stamina, What works for you, How you answer, each as two figures
joined by vs. plus one sentence. Then "When you work", where the meta column
holds the answer and the subtext says what it is measured against.

**What's fading.** Panel "This week" (61 start to slip, 340 holding). No button.
One axis throughout: **holds N days**. "Never quite sticks" at the short end,
"Holding well" at the long end.

**Your record.** Panel "Since you started". **"Your totals"**, the
screenshot block: questions answered, time in sessions, lessons read, days
active, longest streak, best mock. Accuracy trend as a single board line on
hairline gridlines. "Your mocks". Milestones deliberately absent.

---

## Open

1. **Free and Pro treatment.** Every screen drawn so far is Free tier. The
   proposal is decision 4: a real short report with the teaser covering only the
   genuinely Pro block, retiring `PaywallTeaserPanel` from Progress. Rejected
   alternative is the approved redaction, which is what
   `2026-07-18-ui-redesign-design.md` specifies and what ships in
   `faint_bars.dart`. Taking the proposal amends that spec.
2. **What feeds "Points within reach".** Dynamic, recomputing after every
   completed session and every mock. Figure is the blueprint's item count for a
   topic times the share currently wrong. Open: whether every attempt counts the
   same (recommended, since a Free user may have no mocks) or mock attempts count
   for more (better predictor, jumpy or absent in practice).
3. **Whether "Holding well" stays a list** or collapses to one closing line
   ("Eleven topics are holding, the longest for 94 days. You can leave those
   alone."). Recommended: collapse. It is not actionable and its only job is to
   stop the screen being all bad news.
4. **Milestones**, its own design pass.
5. **The day-one empty state**, per principle 2 above.

---

## Working notes for whoever picks this up

- **Check `lib/core/ui/components/` and the decision logs before drawing
  anything.** Both rejected plates were rejected for inventing something already
  decided and written down. The Quiz glyph in particular was reopened on 28 July,
  Plate 9: it is **S1, three options and rules, middle bubble shaded**, and the
  Home and Study specs both still say "a single answer bubble" and are stale.
- **Edit plates, do not rewrite them.** Each is around 900 lines.
- Companion page dark, device preview starts on Paper, toggle governs the phones
  only.
- Never set `data-theme` on `documentElement` in a plate while also using
  `[data-theme]` as a click target. Every element is a descendant of `<html>`, so
  the handler swallows every click on the page. This cost a whole round.
