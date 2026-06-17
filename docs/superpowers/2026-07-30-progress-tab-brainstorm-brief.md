# Brainstorming brief: replacing two weak screens in Pantas

You are helping design a feature for a real, in-development mobile app. Read the whole
brief before answering. At the end there is a specific problem to solve, a list of
constraints you may not break, and a shorter list of premises you are invited to attack.

Do not be agreeable. The last three rounds of this design were improved by someone
pointing out that a number we planned to ship was not defensible. If you think the
framing is wrong, say so and say why.

---

## 1. What the app is

**Pantas** is a Flutter mobile app for Filipino students revising for high-stakes
entrance and licensure exams. Seven exams are supported: UPCAT, USTET, ACET, DCAT,
MSU-SASE (university entrance), NMAT (medical school) and the Civil Service Exam
Professional level.

Positioning: a knowledge repository for the public, not a cram school. Subscription
only, no one-time unlocks. Base facts are never paywalled.

Content today: 1,117 questions, 144 lessons, 19 topics, shipped as a bundled JSON seed
that loads into a local SQLite database on first run. Content is authored in Sanity CMS
and there is a sync pipeline, but the shipping path is the bundled seed.

Stack: Flutter, Drift (SQLite), Riverpod, Firebase Auth, an own implementation of the
**FSRS** spaced repetition scheduler.

Users: Filipino teenagers, mostly 16 to 18, revising in short sessions on a phone,
often late at night, frequently on cheap Android hardware. Reading level target is
deliberately low. English UI, Filipino greetings.

---

## 2. The four tabs, and what each one already owns

This matters more than anything else in this brief. **The most common failure in this
design has been proposing something that another tab already does.** Every idea you
propose must survive the question "which tab already answers this?"

**Home.** Greeting with the student's name, active exam and a countdown to exam day.
Two headline figures (accuracy, lessons read out of total). "Up next": three unread
lessons drawn from the student's weakest topics, with the app's single primary action,
"Continue lesson". "Weakest areas": topic rows with a meter and a percentage, coloured
by severity. "Your tendencies": a swipeable deck of four behavioural insights, one at a
time, Pro gated, which hands off to Progress for full detail.

**Study.** The lesson index: subject headings, topic rows that expand in place to their
lesson rows, read fractions throughout, search, bookmarks, and the lesson reader itself.
Owns navigation and reading. There is deliberately no per-topic page: a topic expands
in place rather than opening a screen.

**Quiz.** Today's session (drawn from what FSRS says is due), mock exams, per-topic
practice, a flagged-questions section, the answer reveal after each question, and a
post-session debrief where the student can tag their own mistakes. Owns all practice
and all scheduling of what to answer next.

**Progress.** The analytical tab. This is what we are designing. It currently has four
screens, described in section 5.

---

## 3. What data actually exists

Be concrete and build on what is here. Proposing a feature that needs data the app does
not collect is a valid answer only if you say so explicitly and estimate the cost.

**Stored locally today (SQLite tables that exist and are populated):**

- Per-question FSRS review state: **stability** (how many days the memory is expected
  to last), difficulty, due date, review count.
- Every attempt, per item, with **response time in milliseconds** and correctness.
- Quiz sessions, with start and end times.
- Mock exam attempts, with per-section payloads.
- Lesson read progress, per lesson.
- A diagnostic assessment result containing **per-topic mastery** estimates, written the
  first time the student uses the app, so a non-zero figure exists from minute one.
- Streak state, days active.
- Flagged questions.
- Wrapped-style generated artifacts, and a resolved "archetype" (a named behavioural
  persona, for example "Night-Owl Sprinter").

**Behavioural signals already computed in code.** Thirteen exist. Only the first four
are surfaced anywhere in the app. **The other nine are written, tested and unused,
which makes them the cheapest possible material for a new idea.**

| Signal | Output | Surfaced? |
|---|---|---|
| Test-mode delta | accuracy practising vs accuracy under time | Home and Progress |
| Mock stamina | accuracy first half vs last half of a long paper | Home and Progress |
| Read-then-quiz | accuracy when the lesson was read first vs not | Home and Progress |
| Per-question speed | response time distribution, split by correct and incorrect | Home and Progress |
| **Difficulty calibration** | a calibration curve: is the student right when they feel confident | unused |
| **Retention shape** | a retention curve over time | unused |
| **Subject affinity** | accuracy and speed, per subject | unused |
| **Time of day** | a day and hour histogram of activity and accuracy | unused |
| **Session shape** | distribution of session durations | unused |
| **Consistency** | streak pattern | unused |
| **Coverage breadth** | percentage of the syllabus touched | unused |
| **Mock pacing** | pacing profile within a timed paper | unused |
| **Flag revisit** | how often flagged questions are returned to | unused |

**Specced but not yet built** (so it is available to design against, but it costs
implementation):

- The student's chosen name and their exam date, captured in onboarding. Until this
  ships, the app does not know the exam date for anyone, so any countdown is
  hypothetical.
- The mistake-tag debrief: after a session, the app shows the student its own inferred
  reasons for each miss (rushed, slipped, first time seeing it) and offers three
  optional taps per miss: "I misread it", "I knew this, I just slipped", "I didn't know
  it". Currently specced as a Pro-only feature.

**Does not exist, and would be real work:**

- **An exam blueprint**: how many items the real paper devotes to each section and each
  topic, and the suggested minutes per section. The database table, the parser and the
  sampler are all written. There are zero rows of content. Section and item counts are
  published for some of the seven exams; the split of items across topics inside a
  section is published nowhere and would be an editorial estimate.
- Any calibration between the difficulty of the app's own questions and the difficulty
  of real exam items. No equating study, no anchor items, no item response theory.
- Any tracking of reading time. Lesson reads are recorded as a boolean, not a duration.

---

## 4. Rules you may not break

These are settled decisions with reasons behind them. An idea that violates one of
these is not usable, however good it is otherwise.

**Honesty about prediction.**

1. **No score projection of any kind.** The app may never say what the student will
   score, nor imply it. The word "readiness" is reserved until a real predictive model
   exists, which it does not.
2. **No claim that requires equating** the app's own questions to real exam items,
   because nothing calibrates the two.
3. **Losses may be stated only when they are already true and still preventable.**
   Never a countdown to a loss the app itself chooses to inflict. Manufactured urgency
   is out.
4. If a figure would swing visibly between sessions because of small samples, it may
   not be shown as a precise number.

**Visual identity, called "Ink and Rule".** The app looks like well-set print on paper,
not like a dashboard.

5. Banned by name: card elevation and drop shadows, large corner radii, tinted callout
   boxes, coloured left-border panels, blur, lock icons, shimmer loading. These read as
   generic AI-generated UI and have been rejected repeatedly.
6. Grouping is done with hairline rules and rectangles, the oldest device in print.
7. Colour is nearly absent and that is deliberate. There is one dark green used
   exclusively for the single primary action on a screen, and a severity ramp of rust
   then amber then plain ink. Colour must always carry meaning. Decoration is not a
   reason to add colour.
8. Two typefaces only: a serif for headings and figures, a sans for body and data rows.

**Voice.**

9. Grade-5-simple English. Short sentences. No jargon, ever: the student never sees the
   words FSRS, retention, stability, algorithm, or card.
10. Scores are "points", never "marks". Questions are "questions", never "cards".
11. No em dashes. Use a comma or a colon.
12. State the fact, then what it means. Never restate a figure in words next to itself.

**Money.**

13. Subscription only. The free tier must survive six weeks of daily use, because
    industry data says most conversions in this category happen after that point.
14. The gate is **granularity, not redaction**. Free is told the verdict at a coarse
    level and always has one real thing to act on. Pro is told the specific lesson.
    Faint bars where a number would be are the approved teaser treatment. Blur, locks
    and blocked screens are not.
15. **Nothing the student produced themselves is ever paywalled.** Their own records,
    their own history, their own notes about their own mistakes.

**Psychology, from the project's own principles document.**

16. Never start a student at zero. A brand new user must see a true non-zero figure.
17. The free tier must be a real short report with the offer beneath it, not a redacted
    one.
18. When the student's own input is shown back to them, attribute it as theirs.
19. Reduce decisions. A screen opens on an answer, not on a menu of equal options.

---

## 5. The current design, and the problem

Progress has four screens. Two are considered good and two are considered weak. The
weak two are your problem.

**Screen 1, the tab itself.** Opens on:

- **"Your pace"**: percentage of lessons read, days left, and one sentence of pure
  arithmetic, for example "At three lessons a week you finish nine days after the exam.
  Four a week closes the gap." This is regarded as the strongest single element in the
  whole tab and must survive any redesign.
- **"Points within reach"**: five topic rows, ordered by how many exam points the
  student could recover, each showing a figure like "+6". **This is problem one.**
- **"Why you lose points"**: three counts drawn from the student's own mistake tags
  (slipped, didn't know, misread) plus one sentence interpreting them.
- **"Go deeper"**: three rows leading to the other three screens.

**Screen 2, "How you work".** The student's name, their archetype, then four
comparisons, each led by the gap rather than the pair: how much they lose under time
pressure, how much they lose over a long paper, how much reading the lesson first is
worth, and how much longer they take when unsure. Then the hours and days they actually
work best. **Considered good. Do not redesign this.**

**Screen 3, "What's fading".** Two counts, an explainer of spaced repetition in plain
words, then four topics that decay fastest, each reading "fades in 6 days", and a
closing line saying eleven topics are still solid. **This is problem two.**

**Screen 4, "Your record".** Totals since starting, an accuracy trend line, and a list
of mock exams taken. **Considered good. Do not redesign this.**

### Problem one: "Points within reach" is not defensible

The figure was to be the real paper's item count for a topic multiplied by the share the
student is currently getting wrong, presented as points recoverable.

It was challenged and it does not hold up. Nothing equates the app's questions to real
exam items. It assumes studying takes the error rate to zero. With eight practice
questions on a topic the figure would swing between sessions. Some of these exams do not
report raw scores at all. And most decisively, it is a score projection, which rule 1
bans, just a small local one rather than a total.

What is defensible is the **ranking**: the exam's published weight for a topic times an
observed error rate says where the largest expected loss sits, and rankings tolerate
noise that magnitudes do not. But that only works if the exam blueprint gets authored,
which is real content work, and the section then has to justify itself against Home's
"Weakest areas", which already ranks topics by how badly the student is doing.

**Your task: what should occupy this slot?** It can be a rescued version of the same
idea, or something completely different. The slot's job is to answer "where are my
points going, and why?" at the top of the analytical tab. It must not duplicate Home's
weakest areas, Quiz's practice picker, or Study's index.

### Problem two: "What's fading" has no job

The screen tells the student that sixty one questions are fading, then tells them those
questions are already in this week's sessions, so nothing is required of them. A screen
whose message is "nothing is required of you" does not earn a place in the navigation.

An earlier version had a button to practise those questions. It was cut, correctly,
because Quiz already draws today's session from exactly those questions, and a second
door to the same place is a known failure in this app's history.

The one thing this data could say that nothing else says is whether a topic will still
be in the student's head on exam day, given how fast it currently decays. That is
appealing but delicate: if the app keeps scheduling reviews then the memory will in fact
hold, so any claim that something "will be gone" is false, and rule 3 forbids inventing
the loss.

**Your task: either give this screen a real job, or argue that it should be cut and say
where its two useful pieces go.** The two useful pieces are the plain-language
explanation of how spaced repetition works, which students otherwise never learn, and
the fact that some topics decay much faster than others.

---

## 6. Things already tried and rejected

Do not propose these. If you want to revive one, you must address the stated reason.

- A projected exam score, or a projected total of any kind. Needs a model that does not
  exist.
- A fifth Progress section for pace. Pace belongs at the top of the diagnosis, not in
  its own destination.
- A "practise these" button on the fading screen. Duplicates today's session in Quiz.
- Starting a practice session from a Progress row. Recreates Home's practice rows.
- Rotating a row open to reveal the questions the student keeps missing. Good depth, but
  it quietly turns a free row into a paywall.
- Adding green as a healthy fourth step on the severity ramp. Spends the primary-action
  colour budget, and would then have to apply across the whole app.
- Ranking the fading topics by how many times they were relearned. Reads as an
  accusation and is not actionable.
- A list of the student's strongest topics on the fading screen. Mixes an accuracy
  measure into a screen whose axis is days, and it belongs with the app's shareable
  year-in-review feature instead.
- An "exam-room self" section covering performance under exam conditions. Already
  covered by the four comparisons on "How you work".

---

## 7. What a good answer looks like

Give me **three to five distinct options**, not one. For each:

1. A name for the section, in the app's voice, that states why the student should care.
   The two weak screens are partly weak because their names describe the data rather
   than the reason to look at it.
2. What is on the screen, concretely. Actual example copy, with real-looking numbers.
3. **Which stored data or existing signal it runs on.** Name it from section 3. If it
   needs something that does not exist, say exactly what and estimate the work.
4. Which tab could be accused of already doing this, and why yours is different.
5. The strongest argument against your own option. Not a hedge, a real cost.
6. What it looks like for a student on day one, with almost no data, and for a free user.

Then rank them and recommend one, with reasoning.

Finally, and separately: **tell me if you think the four-screen shape is wrong.** The
brief above assumes the analytical tab should answer four questions in descending
urgency: where are my points going, who am I as a test taker, am I actually moving, and
what am I losing. If you think that is the wrong decomposition, or that two screens
would beat four, that is a more useful answer than a better version of screen three.
