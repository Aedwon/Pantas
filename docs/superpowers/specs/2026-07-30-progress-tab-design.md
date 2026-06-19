# Progress tab redesign

**Date:** 30 July 2026
**Supersedes:** Spec 11 (`2026-06-10-spec-11-progress-amendment-design.md`) for everything
on this tab, and Amendment D's per-panel Free and Pro table.
**Decision log:** `docs/superpowers/decisions/2026-07-29-progress-tab-decision-log.md`
**Brainstorm brief:** `docs/superpowers/2026-07-30-progress-tab-brainstorm-brief.md`

---

## Problem

Progress is the analytical tab and it currently renders almost nothing. Its trend
and weakness panels say "Charts land here in an upcoming update",
`_SignalStatsPanel` returns `SizedBox.shrink()`, and the archetype block does the
same. Thirteen behavioural signals are written and tested in
`lib/features/metrics/signals/`; four are surfaced on Home and nine appear nowhere.

The first design of this tab shipped a figure it could not defend: points
recoverable per topic, computed as the exam's item count for a topic times the
share the student was getting wrong. That was challenged and withdrawn. Section 1
is the rule that replaced it.

---

## Scope

In: the Progress tab and its two sub-screens, the exam blueprint as a data
prerequisite, and the Free and Pro rule for this tab.

Out: Milestones, which needs its own design pass. Home, Study and Quiz, except
where this spec amends them in Section 11.

---

## Section 0: Corrections to the record

1. **Points recoverable is withdrawn.** It required equating this app's questions
   to real exam items, which nothing calibrates; it assumed study takes an error
   rate to zero; it would swing between sessions on small samples; and some of the
   seven exams do not report raw scores at all. Decisively, it was a score
   projection, which this project has banned since `2026-07-18-ui-redesign-design.md`
   reserved the word "readiness". A smaller local projection is still a projection.
2. **Decision 3 of the decision log is reversed.** "Score impact ships as a delta,
   never a total" is replaced by "no projected figure at any scale".
3. **Decision 7 is amended.** The chevron destination is no longer a topic. See
   Section 6.
4. **"What's fading" is cut as a screen.** Its data becomes the fifth tendency on
   How you work. See Section 4.
5. **Blueprint effort was misstated on 29 July.** It was described as needing an
   editorial estimate of topic weights. In fact `BlueprintSection._readWeights`
   treats `topicWeights` as optional and defaults every topic in a section to equal
   weight, so a blueprint of published facts alone is authorable with no schema
   change. See Section 10.
6. **Sectional timing constrains the time insight.** Because UPCAT, USTET, NMAT and
   CSE time their parts separately, minutes cannot be moved between sections. Any
   time-triage reading is valid only inside one section.

---

## Section 1: The evidentiary rule

Every figure printed on this tab falls into one of four tiers. **The first three
may be shown. The fourth may not be shown as a figure at all.**

| Tier | Meaning | Example |
|---|---|---|
| **T1 Measured** | Directly observed from this student's own use | response times, correctness, lessons read, days active |
| **T2 Published** | A fact about the exam, transcribed from the testing body | items per section, minutes per section |
| **T3 Method output** | The output of a named published algorithm used as designed | FSRS stability, FSRS lapse rate |
| **T4 Our own inference** | A mapping this project invented | items per topic inside a section, points recoverable, what a behaviour "means" |

Two consequences that bind the rest of this spec:

- **No figure may be the product of a measurement and an assumption.** Two facts may
  sit side by side in a row and let the reader combine them. The app does not do the
  multiplication and print the result.
- **T3 may not be extended past the method's own claims.** FSRS states how long a
  memory is expected to last. It does not state what a student will score, so
  stability may never be phrased as an exam-day outcome.

---

## Section 2: Three destinations

| | Screen | Question it answers |
|---|---|---|
| 1 | **The tab**, `/progress` | Where am I losing, and why? |
| 2 | **How you work** | Who am I as a test taker? |
| 3 | **Your record** | Am I actually moving? |

The tab opens on the diagnosis, not on a menu. The two sub-screens are reached from
"Go deeper" rows at the bottom, after the content.

**A single scrolling page was rejected.** The three screens combined run eight to
twelve phone screens. The Study spec bounded its index to one open topic at a time
on exactly this ground, calling roughly ten and a half screens unacceptable, and
flattening Progress would reintroduce that fault. It would also lose the
opens-on-an-answer property, since the answer would sit inside a long roll.

---

## Section 3: The tab, `/progress`

App bar "Progress". Exam short name in serif 22/700 beneath it.

### Your pace

A ruled panel, plated heading "Your pace". Two figures: percentage of lessons read,
and days left. Then one sentence of arithmetic:

> At three lessons a week you finish **nine days after** the exam. Four a week
> closes the gap.

Amber on the overshoot only. **T1 and T1.** Runs on `lesson_progress_local` against
`lessons`, and the exam date from onboarding.

**Hard rule: this stays arithmetic.** It may never become a score projection. It
states a conditional about the current rate and nothing else.

Wholly Free. Spec 11 already placed the on-pace indicator in the Free tier.

### Performance

The section title is **"Performance"**, not "Performance breakdown": the shorter
title leaves room for the level control in the header's right slot.

**Composition, in order:**

1. **Section header.** Serif 16/700 title, and in the right slot the level control
   (Section 6). **The header does not draw its own rule when a table head follows
   it**, because the head draws one. Two rules four pixels apart is the fault caught
   on the eighth pass.
2. **The table head.** A ruled row: the left cell names what the rows are
   ("Subject", "Topic" or "Lesson") in 11px uppercase `inkMuted`; the right cells are
   **"Score"** and **"Time"**, each a sort control. Closed by a 1px `rule`.
3. **The rows.** Title in sans 14/400, a subtext line, and two right-aligned figure
   columns of 52px: accuracy, and seconds per question. The inactive column is
   `inkMuted` at weight 400; the active column is `ink` at 600 with severity colour.

**The subtext** carries the row's parent at topic and lesson level, and the section's
published size at subject level ("60 of 180 questions").

**Sorting.** Tapping a column head sorts by it. Tapping the active head reverses it.
A 7px solid caret shows direction and appears only on the active head. No separate
control exists, because the labels that sort are the labels that name the data. This
is the elegance requirement met by removing the widget rather than restyling it.

**Default order: Score, ascending.** Weakest first, which is the actionable
direction. Sorting Score descending is the deliberate other case: it is the view a
student screenshots.

**Colour.** Severity applies to accuracy wherever accuracy appears, rust below 50,
amber below 70, plain ink above. **A row's colour never changes because the table was
re-sorted.** Board green appears nowhere in this table.

**Evidentiary status.** Accuracy and seconds are T1. Section size is T2. Nothing is
multiplied and nothing is projected. The rows state two facts and the student
combines them.

**Where the numbers come from.** `SubjectAffinitySignal` already returns `correct`,
`total` and `averageMs` keyed by subject, which is the subject level exactly.
Topic and lesson levels need the same query grouped differently; both run on
existing tables. **Time comes from timed mock attempts only**, via
`MockPacingSignal` and the mock payloads, because a claim about the exam clock may
not be measured on untimed late-night practice. With no mock sat, **the Time column
and its head are absent**, not filled with placeholders, and the sort falls back to
Score. One line explains it:

> Your pace per question appears here after your first full length mock, because
> that is the only place the app can measure you against a real clock.

**What this is not.** Home ranks topics by accuracy alone with a meter. This table is
the only place the published size of each part of the paper appears anywhere in the
app. No ordering explanation is printed, because the student chose the order.

### Why you miss questions

**Pro only, redacted for Free.**

Three counts in a ruled band, then one interpreting sentence:

> **6** had it right before · **3** never seen it · **2** answered too fast
>
> You mostly know this material already. What is missing is a second pass, not a
> first one.

**Derived with no student input.** "Had it right before" is a prior correct attempt
on the same question. "Never seen it" is no prior attempt and no FSRS state.
"Answered too fast" is `AttemptItem.responseMs` far below this student's own
distribution from `PerQuestionSpeedSignal`. All T1.

Pro additionally shows which topics each cause concentrates in, and the misreads the
student notes themselves in the Quiz debrief.

**Free sees the redaction treatment**, not the counts. This is a deliberate
narrowing of the earlier proposal: the endowment principle protects a student's own
notes, and Free users never produce tags because the Quiz spec's debrief invitation
is Pro only, so there is nothing of theirs being withheld.

### Go deeper

Two navigational rows, serif 14/700 with a chevron and a subtitle carrying that
screen's verdict.

- **How you work**, "Night-Owl Sprinter. Sharpest at 9 pm, in 8 minute sits."
- **Your record**, "Day 18. Best mock 68%, up 11 since May."

---

## Section 4: How you work

Panel "Your profile", **centred**: the student's chosen name in serif 24/700, the
archetype beneath it in sans 13/600, then one line. Centring matches Home's stats
band and tendency deck. With no name stored, the panel shows the "Add your name"
invitation Home already specifies.

Then **five tendencies**, each a section header over one comparison. The comparison
uses the **gap-first** treatment: the difference as a serif 34/700 figure on the
left, the sentence naming what it costs, and the two source figures demoted to an
11.5px caption. Losses carry rust. Gains stay ink; **board green is not spent here.**

| Heading | Signal | Tier |
|---|---|---|
| Under pressure | `TestModeDeltaSignal` → `PressureDelta` | T1 |
| Stamina | `MockStaminaSignal` → `StaminaDelta` | T1 |
| How you study | `ReadThenQuizSignal` → `WorkflowRatio` | T1 |
| How you answer | `PerQuestionSpeedSignal` → `LatencyDistribution` | T1 |
| **How long you remember** | `RetentionShapeSignal` → `RetentionCurve` | T3 |

**"How you study" was renamed on 2 August**, from "What works for you". The rename is
an evidentiary correction: `WorkflowRatio` holds two counts and **no accuracy**, so the
app knows which order the student works in and nothing about which order works. Adding
accuracy per branch was rejected, because the student chooses which lessons to read
first and reads them on topics they already find hard, so any gap is selection rather
than effect. That is Section 1's ban, and the same circularity that keeps
`DifficultyCalibrationSignal` unused.

**It keeps the gap-first treatment**, as the only one of the five where **neither
direction is a loss**, so it never carries rust. One card looking different on a screen
of five reads as a mistake, and the gap figure being less pointed here than on its four
neighbours is the accepted cost. It renders:

> **8**, and the line reads: You usually read the lesson first.
> read first 12 vs. answered first 4

The sentence has three states, chosen by the ratio, and they are the same three Home
prints: usually reads first, usually goes straight to the questions, or splits about
evenly.

The fifth is new and replaces the deleted "What's fading" screen.
`RetentionCurve` returns `averageStability` and `lapseRate`, which is **one average,
not a per-topic claim**:

> **9d**, and the line reads: what you learn holds about nine days before you need it again
> you lapse on 18% of the questions that come back

The nine days is the scheduler's own estimate and must be phrased as such. It is
never a promise, and it is never compared to the exam date.

Then **"When you work"**: three data rows where the meta column holds the answer and
the subtext says what it is measured against. `TimeOfDaySignal` and
`SessionShapeSignal`.

Then the spaced repetition explainer, which moved here with the decay figure:

> Pantas shows a question again just before you would forget it. The ones you forget
> fast come back often. The ones that stick come back rarely, so your time goes where
> it is needed. This is called **spaced repetition**.

The words FSRS, stability, retention and algorithm never appear.

**Free** sees all five headings and both comparison labels with `FaintBars` where the
figures go, and does not see "When you work". Knowing what is being compared is what
creates the want; this is Home's already-approved treatment.

---

## Section 5: Your record

Unchanged from the fourth pass and **wholly Free**, because it is the student's own
history and nothing they produced is ever paywalled.

Panel "Since you started" (weeks in, day streak, and the date the streak began).
"Your totals": questions answered, time in sessions, lessons read, days active,
longest streak, best mock. "Accuracy across your prep" as a single board line on
hairline gridlines. "Your mocks".

**"Time in sessions", never "time studied".** Reading time is not tracked; the label
carries the limit.

Milestones are deliberately absent.

---

## Section 6: The controls

### The level control

Three labels in the section header's right slot: **Subject · Topic · Lesson**. 12px,
`inkMuted`, active in `ink` at 700, separated by 1px by 11px `rule` ticks. No pills.
Nothing hidden behind a picker.

- **Free is fixed at Subject**, and sees the other two labels **dimmed rather than
  hidden**, so it knows what Pro opens.
- **Lesson level depends on lesson tagging.** Questions carry a `topicId` and no
  `lessonId` today. The Quiz spec commits to authoring a `lessonId` across all 1,117
  questions before that tab ships. **If Progress ships first, the Lesson label is
  absent, not dimmed and not empty.**
- **Pro cannot go deeper on the paper's composition, only on performance.** A
  topic-level item count is the unpublished T4 number that was cut. Section size
  stays a subject-level fact at every level of the table.

### Row destinations

A row's chevron is replaced by the level control: the table is a reading surface, not
a launcher, and Home already owns starting a session. **Amends decision 7**, which
sent a topic row into the Study map.

At **Lesson** level a row opens `/lesson/:lessonId`, the reader, which is a real
destination and the only level that has one. Use `context.push`, since the reader
sits outside the tab shell.

### Retained order

The chosen sort, direction and level **survive leaving and returning to the tab**,
stored silently. No dialogue on change, following the Study spec's rule that a prompt
on every sort change punishes exploring.

**A Settings row governs it**, so a student who wants the table to open the same way
every time can say so. This follows the precedent that quiz ordering is a setting
rather than a rule.

---

## Section 7: Free and Pro

**The gate is granularity, not redaction, except where a feature is wholly Pro.**

| Surface | Free | Pro adds |
|---|---|---|
| Your pace | Everything | Nothing |
| Performance | Subject rows, both figure columns | Topic and lesson levels |
| Why you miss questions | **Redacted** | The whole section, plus per-topic causes and self-noted misreads |
| How you work | Five headings and both comparison labels, figures redacted | The figures, and "When you work" |
| Your record | Everything | Nothing |

**Nothing the student produced themselves is paywalled.** Their record and their
totals are theirs.

**One stated exception, added 2 August.** Home's Practice panel shows **three**
topic-level accuracies to Free users, as the teaser for this table. The gate here is
unchanged: Free still sees Subject rows only, with Topic and Lesson dimmed. Knowing
your three worst topics is the diagnosis, and the table is what you buy. Recorded so
it reads as a decision rather than a leak. See
`2026-07-26-home-and-navigation-design.md` Section 3 and
`decisions/2026-08-02-home-weakest-areas-log.md`.

**One teaser per screen, maximum.** Placed after the free content, never before it,
never twice on one screen. `PaywallTeaserPanel` is retired from Progress; the
treatment is `FaintBars` where figures would sit, plus one line of prose and "Unlock
with Pro" in board green. No lock icons, no blur, no banners, no interstitials.

The tab's teaser sits on the redacted mistake causes. How you work's sits after the
fifth tendency. Your record has none.

---

## Section 8: Layout grammar

- **Data rows:** sans 14/400 title, subtext on its own line in 12px `inkMuted`,
  figures in sans 13/600 tabular.
- **Navigational rows:** serif 14/700 with a chevron.
- **Section headers:** serif 16/700, one step above navigational rows so a header
  always outranks its own rows.
- **Table head cells:** 11px uppercase `inkMuted`, active in `ink` at 700.
- Rows are **30 tall with 4px padding**. Tappable rows keep the same visual box; the
  44px touch target is padded past it with `MaterialTapTargetSize.padded`. A 44px
  visual floor put 12px of air around every title and was the spacing fault caught on
  the sixth pass.
- A section header binds to its list: about 5px below the rule, tighter than the gap
  between rows, so a list reads as one block.
- **A section header draws no rule when a table head follows it.**
- Compared figures are joined by "vs." only in prose, never by a hairline.

---

## Section 9: States

| State | Treatment |
|---|---|
| Loading | `FaintBars`: 7px paper-toned bars at `ruleFaint`, radius 2, 5px vertical margins. Never gray blocks, never shimmer |
| Error | `ErrorBanner` in its error variant: 3px `rust` accent, rules top and bottom, "Could not load your progress. Pull down to try again." Never the exception string |
| No exam chosen | The existing fallback: "Choose your exam" over "Pick the exam you are reviewing for." and a board "Choose exam" |

### Day one

**A student with no attempts sees an invitation, not a table of zeros.** There is no
progress to report for someone who has not started, and manufacturing one would be
the dishonesty this whole tab was rewritten to avoid.

The assessment is **not** part of onboarding: it lives at `/assessment/:examId` on
its own, so a new user genuinely can arrive here with nothing.

`EmptyState`: serif headline "Nothing to report yet", body "Take the assessment and
this fills in. It takes about twenty minutes and it is how Pantas learns where you
are.", a board **"Take the assessment"** as the primary action routing to
`/assessment/:examId`, and a secondary text link to `/mock-exam`.

**Partial states are per section, not per tab.** A student who has taken the
assessment but sat no mock sees Performance without its Time column, and How you work
with the two mock-dependent tendencies showing "Not enough data yet" plus the action
that unlocks each, in muted text, never board.

---

## Section 10: Data and content work

### The blueprint, T2 only

One document per exam: sections, item count per section, minutes per section, and
which topics belong to each section. **`topicWeights` is omitted entirely**, and the
sampler distributes a section's items evenly across its topics, which
`BlueprintSection._readWeights` already does when the field is absent. No schema
change, no invented number.

**Provenance is a new field.** Some numbers will come from student reports rather
than a bulletin, so each blueprint records where its figures came from and when, for
example "student reports, UPCAT 2026, five independent accounts agreeing". This is
what makes a crowdsourced figure defensible for exactly what it is and correctable
later without pretending it was ever official. New Sanity field, new Drift column,
one parser line.

**Known status, 30 July 2026:** UPCAT, USTET, NMAT and CSE researched. DCAT has a
total of 280 items and 4h30m but no published per-section split. ACET has four
subtests plus an essay and about 3.5 hours. MSU-SASE has about 150 items. For all
three, per-section counts and minutes need the student-report route.

### Delivery, which is currently broken

`assets/seed/content.db` exists but **is not declared in `pubspec.yaml`**, and
`SeedInstaller` **has no callers**, so nothing installs it. The bundled file is a
20 July artifact holding 16 questions and **zero blueprint rows**. Wiring this is a
prerequisite for this spec and for mock exams, which cannot run at all without it:
`MockSetupPage` takes a blueprint as a required argument and both it and
`mockBlueprintsProvider` currently have no callers anywhere.

### Signals consumed

Newly surfaced by this spec: `SubjectAffinitySignal`, `RetentionShapeSignal`,
`MockPacingSignal`, `SessionShapeSignal`, `TimeOfDaySignal`.

Still unused after this spec, and deliberately: `DifficultyCalibrationSignal`
(circular, since FSRS difficulty rises partly because the student got the question
wrong, so it cannot be evidence about the material), `ConsistencySignal` and
`CoverageBreadthSignal` (covered by Your record and Your pace),
`FlagRevisitSignal` (belongs beside Quiz's flagged list).

### Storage

Three new preference keys: the table's sort key, its direction, and its level, plus
the Settings flag governing whether they are retained.

---

## Section 11: Amendments to other specs

1. **Spec 11 Amendment D** is superseded for this tab by Section 7.
2. **`2026-07-18-ui-redesign-design.md`**: `PaywallTeaserPanel` is retired from
   Progress. `FaintBars` remains the redaction treatment.
3. **Decision log decisions 3 and 7** are reversed and amended per Section 0.
4. **The Quiz spec's lesson tagging** becomes a dependency of the Lesson level, not
   only of the reader coda and the picker.
5. **The Home spec's "See full details"** still lands on Progress, and now lands on a
   tab that has the four tendencies in full plus a fifth.
6. **`2026-07-26-home-and-navigation-design.md` Section 2** (onboarding captures name
   and exam date) becomes a prerequisite: Your pace cannot render without the exam
   date, and Your profile cannot render its heading without the name.
7. **Settings** gains one row, for retained table order.

---

## Deferred, with reasons

- **Milestones.** Provenance is real: four Wrapped artifacts,
  `user_metrics_artifacts_local`, and the shipped `wrapped_history_stub` panel. The
  form was never designed. Its own pass.
- **Best subjects as a shareable card.** Sorting Score descending now covers the
  bragging case inside Progress, so a separate Wrapped card may be redundant.
  Revisit when Wrapped is next opened.
- **Per-topic decay.** Cut with the "What's fading" screen. Nothing shows which
  specific topics fade fastest; the tab shows one average instead.
- **Difficulty calibration**, for the circularity reason in Section 10.

---

## Verification

- A new user with no attempts sees the assessment invitation, never a zero.
- No figure on the tab is the product of a measurement and an assumption.
- The words FSRS, stability, retention, algorithm, card and marks appear nowhere in
  a user-facing string.
- With no mock sat, the Time column and its head are absent and Score is the sort.
- With no blueprint, the subject subtext drops its "of 180 questions" clause and the
  table still renders.
- Free sees exactly one teaser per screen.
- Every section header outranks its own rows, and no header draws a rule directly
  above a table head.
- Re-sorting the table never changes any row's colour.
- Sort, direction and level survive a tab switch, and the Settings row turns that off.
