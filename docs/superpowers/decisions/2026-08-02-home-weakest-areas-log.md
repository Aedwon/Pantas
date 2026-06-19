# Home's Weakest areas, design decision log

Chronological. Later entries append; they never edit earlier ones. Source spec:
`specs/2026-07-26-home-and-navigation-design.md` Section 3, "Weakest areas", which the
2 August work checkpoint marked superseded and sent back to design.

---

## 2 August 2026: what had actually superseded it

Before putting any option to Aedwon I established why the section was marked superseded,
because the checkpoint asserts it in one line and never says by what. Two documented
causes and one undocumented one.

**Cause 1, the Quiz anchor lost its anchor.** On 26 July, recorded in
`2026-07-26-study-tab-brainstorm-state.md` under "Home's Quiz anchor", Weakest areas was
turned into a **Practice** panel: same three rows, same meters, same percentages, rows
firing `start_today_session(topic, mode: perTopic)`, "the same call the Quiz tab's own
rows make", and the plate action changed from "Practice these" to **"See all"** pointing
at the Quiz tab's per-topic queue.

Two days later the Quiz tab spec deleted that queue. Section 1 opens "It is not a topic
queue", and Section 10.1 supersedes Spec 4 §7.1 by name. So as of 28 July the panel's
action pointed at a surface that does not exist, and the reason given for its row call
referred to rows that do not exist. The 27 July Study spec's Section 8.1 records the 26
July half of this and could not have known about the 28 July half.

**Cause 2, Progress built the same ranking and gated it.** The 30 July Progress spec's
Performance table is topics ranked by accuracy, default sort Score ascending, severity
coloured, which is Home's Weakest areas as a full table. Its Section 7 fixes **Free at
Subject level** and sells Topic and Lesson as the Pro grant. Home prints topic-level
accuracy to everyone.

**Cause 3, found in the code and written down nowhere.** Home's figures come from
`AssessmentResult.topicMasteries`. That is a stored row in `assessment_results_local`,
written once by `CompleteAssessment` and **never recomputed**; nothing else in `lib/`
writes it. Two consequences nobody had recorded:

- The weakest three are **frozen on assessment day**. A student who has answered four
  hundred questions since still sees the May three.
- Each percentage is measured on **at most three questions**.
  `AssessmentQuestionSelector` takes `max(1, min(3, 35 ~/ contributing))` per contributing
  topic. "Chemistry 33%" is one wrong out of three, printed in rust behind a meter.

Cause 3 is also the mechanical reason for the duplication the 26 July round was trying to
solve. Up next and Weakest areas name the same three topics every day because they read
the same frozen list.

**What I got wrong on the way in.** I opened this round expecting to redesign a panel.
Two of the three problems are not composition problems at all: one is a dead link and one
is a data source. The panel's drawing was very nearly the only part of it that was fine.

## 2 August 2026: the four questions, and what was chosen

Put to Aedwon as four numbered questions with costs and a recommendation on each.

### 1. Where the figures come from

| Option | Cost |
|---|---|
| **A. Live, from all attempts**, the topic-level query Progress's Performance table already needs | One provider, and a per-topic floor state until enough is answered. Exposes the prerequisite in the next entry |
| B. Keep the assessment result | The freeze and the three-question sample stay. Home contradicts Progress within a week of use |
| C. Assessment until N attempts, then live | Two code paths, and a switchover the student cannot see happen |

**Chosen: A**, as recommended.

### 2. The Pro line

Progress sells topic granularity; Home would hand three topic rows to Free users.

| Option | Cost |
|---|---|
| **A. Home's three rows are the free teaser for the table.** Amend Progress Section 7 to say so | A hole in the gate, deliberately opened and stated. Same shape as the tendency deck: one on Home, the deck behind the gate |
| B. Home drops to subject rows | Coherent with the gate and useless to act on. "Science 61%" names nothing a student can open |
| C. Home gates the figures too | A paywall on the diagnosis, on the first screen, for a free user with nothing else to work from |

**Chosen: A**, as recommended.

### 3. The rows and the action

| Part | Option | Cost |
|---|---|---|
| Rows | **Start a topic-scoped session directly** | None in code: `StartTodaySession` already takes an optional `topicId`. Carries the defect in the next entry |
| Rows | Open the practice picker preselected to the topic | One extra tap, buys a length choice the student mostly does not want here |
| Action | **"See all" to Progress → Performance** | Matches "See full details" for tendencies. Depends on 2A, or a Free user lands on a table that cannot show topics |
| Action | Point at the practice picker | Free and topic-level, but it is a chooser and not a ranking, so "See all" becomes the wrong words |

**Chosen: rows start the session, action goes to Progress**, as recommended and
contingent on 2A, which carried.

### 4. Does the row keep its percentage and its meter

Keeping both makes Home a second figure surface; dropping the meter makes it a door with
a severity hint.

**Chosen: keep both.** `InlineMeter` exists and was written for this exact case.

### Aedwon's comment, verbatim

> go with your recommendations

One message, all four. No option was contested and nothing was reversed.

## 2 August 2026: two prerequisites 1A exposed, decided without asking

Both were found while writing the spec, after the choice above had been made. Recorded
here because neither is a preference and both are one line to reverse.

**The assessment writes no attempt row.** `CompleteAssessment` writes
`assessment_results_local` and seeds FSRS `review_state_local`, and that is all. It never
inserts into `attempts_local`. So every metrics signal, Progress's whole Performance
table, and now Home's live panel are blind to the assessment's twenty-one questions. A
live-attempts Home panel would therefore be **empty at the exact moment the panel is most
needed**, immediately after the assessment the app sold as "find what to study first".

Decided: **the assessment writes an `attempts_local` row like any other session**, under a
new `SessionOrigin.assessment`. This is the honest fix rather than a union of two sources,
and Progress gains twenty-one questions on day one from the same change.

**Which carries a hazard, so the fix is two parts.** `MetricAttemptItem.responseMs` is
required and non-nullable in `AttemptItemReader`, and the assessment captures no
per-question timing at all: `AssessmentSession.answers` is a bare question-to-choice map.
Writing zeros would tell `PerQuestionSpeedSignal` that twenty-one questions were answered
in zero milliseconds, and Progress's "answered too fast" count reads that signal's
distribution. So **the speed-based signals exclude `origin: assessment`** until the
assessment captures timing. Home's panel needs correctness only and is unaffected.

**The session-length line is wrong and is being cut.** The 26 July decision gave the panel
the lead line "Ten questions on whichever you tap." Session length is a student setting,
`quiz_session_length`, which the Quiz tab exposes under "Change how sessions are built".
Home may not promise ten.

**A live defect the rows inherit, named and not fixed here.** In
`start_today_session.dart:89`, the session's `topicId` is stored only when ordering is
`blocked`; under the default interleaved ordering it is written as null. And when a
`topicId` is passed, the pool is that topic alone, so `TodayInterleavedPicker` interleaves
a single-topic pool with itself. A Home Practice row under default settings therefore
starts a session that is topic-scoped in fact and unlabelled in storage. It belongs to the
Quiz thread, alongside the interleaved-tail item plan 2b already raised and left for
Aedwon.

## 2 August 2026: I got the floor wrong, caught on the spec self-review

My first version of the sample floor said topics with fewer than three answered questions
are **excluded from the ranking**, on the reasoning that a ranking led by an unmeasured
topic is worse than a short list. That is wrong, and it contradicted a verification item I
had written four paragraphs earlier in the same pass.

`AssessmentQuestionSelector` takes `max(1, min(3, 35 ~/ contributing))`. With 7 of UPCAT's
18 topics carrying questions today that is 3 each, so the floor looked safe. **Once all 18
are authored it is one each.** So the exclusion rule would empty this panel completely on
the day the question bank is finished. The better the content gets, the more broken Home
becomes.

**Corrected: the floor governs the figure, not the ranking.** A topic under the floor is
still ranked and still tappable; its row prints no percentage and no meter until the third
question is answered. A one-question sample is a fine reason to put Chemistry at the top of
a list to work on and a bad reason to print "0%" in rust.

Aedwon was not asked about either version. The first was decided without asking, and so is
the correction.

## 2 August 2026: what stays from 26 July

Not everything in the anchor decision broke, and the parts that held were kept rather than
redesigned for the sake of it.

- **The plate still reads Practice.** Its justification was "the two panels stop being
  duplicates the moment they stop sharing a destination", and that survives intact: Up
  next opens the reader, Practice starts a session.
- **The rows still carry a chevron**, under the Study spec's rule that a chevron marks a
  row that is its own destination. Each Practice row is an independent session.
- **Home still does not route to a topic page.** `/study/topic/:topicId` remains deleted
  by the Study spec, and Study Plan 2 Task 8 repoints the four live call sites.
