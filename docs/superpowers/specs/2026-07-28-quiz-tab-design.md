# Quiz tab, answer reveal, session debrief and the practice picker

**Date:** 2026-07-28
**Status:** Approved by Aedwon, validated interactively against live mockups in
`.superpowers/brainstorm/80560-1785139437/content/`
**Amends:** `2026-05-17-quiz-engine-and-modes-design.md` (Spec 4),
`2026-05-17-mock-exam-design.md` (Spec 5), `2026-07-27-study-tab-and-reader-design.md`,
`2026-07-26-home-and-navigation-design.md`, `2026-07-18-ui-redesign-design.md`
**Closes:** the "quiz entrance in Study" deferred item of 2026-07-27

## Problem

The Quiz tab is four rows and a button. `quiz_tab_home.dart` renders the exam name,
one filled "Start today's session", then `Retake mistakes`, `Drill a topic`, and a
`Study` row that duplicates the tab bar two pixels beneath it. Its error state prints
`e.toString()` to students.

Underneath it sits an engine built for something else. `BuildTodayQueue` sorts topics
by backlog, marks the largest `isRecommended`, and zeroes the new-card count when the
daily cap is hit. It is pure, it has four passing unit tests, and **outside those tests
nothing in `lib/` references it**. There is no `todayTopicQueueProvider`.

Three more pieces are built and unreachable:

- `ResumeSession` and `RestartSession` have providers (`quiz_controller.dart:101`,
  `:112`) and no widget reads either, so a session abandoned at question 6 is gone.
- `MockQuizTabTile` is written and unit tested and rendered by no screen.
  `/mock-exam` and `/review` are literal `_Stub` routes.
- `QuizPreferencesRepository` holds `quiz_session_length`,
  `quiz_today_interleaved` and `quiz_new_card_cap`. `startToday` reads them. Nothing
  in `lib/features/settings` writes them, so all three are permanently at defaults.

And the screen the tab exists to open does nothing when a student commits. Tapping a
choice submits and advances: no mark, no correct answer, no explanation.

## Scope

`/quiz`, the practice picker it opens, the answer reveal, and the end-of-session
debrief. Session composition and ordering. Question flags. The Free and Pro line
across all of the above.

**Out of scope, and deliberately so:**

- **The quiz viewer** was out of scope when this spec was written and was designed on
  28 July. It is now **Section 7.5**: the bar, the rail, going back, the question grid,
  the travelling caret and leaving. The flag control is in Section 6.
- **The mock viewer.** Its own design job, and it inherits nothing from here. See
  "The mock viewer, carried forward" at the end.
- Home, Study, Progress, Settings. The ordering control lands in Settings and is
  specified here only as a requirement on that work.

---

## Section 0: Corrections to the record

Everything below was verified against the code or the seed rather than recalled.
Six prior statements, several of them mine during this design, are wrong.

1. **The assessment is not a fixed 10 questions.**
   `AssessmentQuestionSelector._maxQuestions` is **35**, and it takes up to 3 per
   *contributing* topic, `max(1, min(3, 35 ~/ contributing))`. With 7 of UPCAT's 18
   topics carrying questions today that yields **21**. Once all 18 are authored the
   formula gives 1 each, so **18**. Any surface stating the length must compute it.
2. **The app calls it "the assessment".** Three shipped strings: "Take the assessment
   to find what to study first.", "Start the assessment", "Take the assessment". Spec
   5's copy rules additionally ban the word "diagnostic" by name. "Placer" and
   "diagnostic" are both out.
3. **The mock is not locked for new users.** Spec 5's availability table reads "Free
   no-prior → available". A brand new free account may sit one on day one.
4. **Drill returns identical questions forever.** `StartDrill` loads
   `questionsByTopic`, tags every candidate `subtopicId: null`
   (`start_drill.dart:59`), and `DrillPicker` calls `SubtopicFilter.general`, which
   returns every question whose subtopic is null, in database order, then takes the
   first N. No shuffle, no dedupe. Spec 4 §4.3 specified "random within sub-topic,
   deduped against the last 7 days" and none of it was built.
5. **The lesson-scoped quiz is topic-scoped.** `start_inline_lesson_quiz.dart:55`
   fetches `questionsByTopic(lesson.topicId)` and takes the first five, so **all 17
   Chemistry lessons hand out the same five questions**. The reader coda approved on
   2026-07-27 is therefore live and wrong today.
6. **The spelling is American.** The repository contains zero instances of "practice"
   and seventeen of "practice".

Two constraints that follow:

- **"Flag" is the Quiz word and "Bookmark" is the Study word.** The 2026-07-27 spec
  avoided "flag" for lessons because `MockSessionState.flags` had taken it. That was
  the right call for lessons and the wrong inference for questions: mock flags are
  question flags, so they belong to this feature rather than colliding with it. They do
  **not** merge automatically: see Section 6.
- **Exam size is not a design constraint**, per the Study spec. Eleven UPCAT topics
  have no authored questions. That is unfinished content. It gets an honest state, not
  a shape.

---

## Section 1: The Quiz tab, `/quiz`

The tab is the **assessment hub**, which is Spec 5's own term for it: "All mock
screens live under the Quiz route prefix to reinforce Spec 4's IA (Quiz tab =
assessment hub)". It is not a topic queue. Composition, top to bottom: app bar, exam
short name, the session panel, the mock panel, the practice rows, the flagged section.

### App bar

Height 56, `background`, no elevation, no scroll shadow. Title "Quiz" in
`headlineMedium` (Source Serif 4, 18/700). **No trailing element.**

### Exam name

The exam short name in `displaySmall` (serif 22/700, tracking -0.2), 6px below the
bar, at the 20px page gutter. Matches the Study map exactly.

### Ruled panels

The two stateful objects are drawn as **ruled panels**: a 1px `rule` border, square
corners, on the same paper as the page, padding 14 by 15 with 16 below, per the Home
spec's device. Each opens with a **plated heading**: serif 15/700 underscored by a
1.6px `ink` rule.

The panel header carries at most one trailing element, and it is **a count in 12px
`inkMuted`, tabular figures**, never a status word. Status words ("ready", "not yet")
were tried and cut: in this identity the top right of a section is either an action in
board at 12/600 or a count, and a word is neither, which is why it read as forced.

### The session panel

Four states, one per condition of the day.

| State | Heading | Trailing count | Body |
|---|---|---|---|
| No assessment taken | "Start with the assessment" | computed length, e.g. "21 questions" | "A few questions from every subject, to find out where you stand. Everything Pantas gives you afterwards is built on it." Board button "Take the assessment" |
| Session available | "Today's session" | none | Two centered figures, the composition line, the settings link, board button "Start" |
| Caught up | "Today's session" | none | Two centered figures, no button at all |
| Session in progress | "Still going" | "6 of 10" | "You stopped partway through **Chemistry**. Every answer was saved." Board button "Resume", then Discard |

**Figures are centered**, amending nothing: the Home spec already centers its stats
band, and the tab was the surface out of step. Value in serif 21/700 with tabular
figures, a 12px sans suffix in `inkMuted` where one is needed, label beneath in 11.5
`inkMuted`.

- Available: **questions** and **duration**. Not "about". Not the streak, which lives
  on Home and in Progress and does not need a third home.
- Caught up: **answered today** and **got right**.

**The composition line** is one tabular line in 12.5 `inkMuted`: `6 due · 3 weak spots
· 1 new`. Beneath it, a board 12/600 text action: **"Change how sessions are built"**,
routing to the ordering setting in Section 5. The tail is not explained in prose here;
the setting explains itself.

**Resume and Discard.** "Resume" only, never "Pick up where you left off". Beneath it,
centered at 12.5, **"Discard this session"** in **board green**, matching every other
text action in the app.

**"Start over" is deleted.** `RestartSession` quits the active row and creates a new
one **with the same question ids**, while the answers already submitted remain written
to `quiz_attempts` and the FSRS state. Restarting therefore re-asks the same six
questions and feeds the scheduler twice. Discard is the honest control: it marks the
session quit and loses nothing, because everything answered is already recorded.

### The mock panel

Heading "Mock exam". The trailing count is the **cooldown, precise to the hour**:
`9d 14h`. Absent when no cooldown applies.

| State | Body |
|---|---|
| Never taken | "The whole thing under exam timing. 3 hours 30, and no answers until the end." Then the tier rule. Secondary button "Take the exam" |
| Free, in cooldown | Three centered figures, then the tier rule with the reopen date, then "View your full results from last time" |
| Available with history | Three centered figures, the tier rule, the results link, secondary button "Take another" |
| Session in progress | "Finish your session first. It runs 3 hours 30 and can't be paused." Then the tier rule. No button |

Figures: **last score** as a percentage, **parts passed** as "3 of 5", **taken** as a
date.

**The tier rule always states itself**, on its own line opened by a 1px `ruleFaint`,
in 12 `inkMuted`:

- Free: "**Free users** get one every two weeks. Your next one opens on **5 August**."
- Pro: "**Pro users** can take as many as they want."

It is stated in every state including before the first attempt, so the cadence is
learned as a rule of the app rather than discovered as a wall.

**Vocabulary:** it is an **exam**, and you **take** it. Never "paper", never "sit".
The panel heading already carries the words "Mock exam", so no button repeats them.

### Practice rows

A `SectionHeader` "More ways to practice", a 1px `rule`, then rows. Row title in serif
15/700, subtitle in 12 `inkMuted`, trailing chevron, minimum height 44, 11px vertical
padding, closed by `ruleFaint`.

| Row | Subtitle | Empty state |
|---|---|---|
| Your mistakes | "28 you've got wrong in the last month" | "Nothing to fix yet", dimmed to 50%, no chevron |
| Choose what to practice | "One topic or one lesson, your choice of length" | never empty |

Two rows, not four. "Specific topic" and "Several topics" collapse into one, because
the picker in Section 2 takes one selection or many with the same gesture, so two
doors into it is one too many. "A lesson you've read" is not a row either: it lives
inside the picker.

**"Where you stand" is deleted.** The assessment is what the session panel says on
first open and never a standing row. A door that becomes permanently irrelevant the
moment it is used should not be permanent.

**The "Study" row is deleted too.** It navigates to a tab whose icon sits two pixels
below it, and `context.go('/study')` from here is the tab-switch case where `go` is
correct, so nothing is being fixed by keeping it. UI-003 is untouched by this spec:
the study-plan feature remains unfinished and `/plan` stays unlinked.

**MECE by intent, which is the only axis on which these can be exclusive.** *Decide
for me* is the session panel. *Test me like the real thing* is the mock. *The ones I
keep missing* is Your mistakes. *I choose* is the picker. Their underlying axes differ
(a selection rule, a set of conditions, a pool, a scope), which is exactly why sorting
them by axis fails and sorting them by intent works.

### The flagged section

A `SectionHeader` "Flagged" with the count in `bodySmall` `inkMuted`, a 1px `rule`,
then one row: **"Questions you flagged"**, subtitle "12 kept, across 4 topics. 7 of
them from your last exam". Dimmed with "Flag anything you want to come back to" and no
chevron when empty.

**The row opens a list, not a session.** Settled 28 July. It is the mock spec's review
component in its practice form: the flagged questions, grouped by subject, each expanding
in place to its choices and its notes, every pennant tappable so unflagging is one tap.
A board **"Practice these 12"** sits at the bottom and starts the session.

**Straight into a session was rejected**, though it is the cheaper build. A flag is a
judgment made weeks earlier, in a different mood, about a question the student may since
have learned. Without a list there is no way to see what accumulated and no way to prune
it, so the only exit from a flag is answering it again inside a session, which is a one
way door. The count on the row would also grow forever with nothing to spend it on.

**The practice action is at the bottom rather than the top**, because the list is the
thing being read and the session is what you do after deciding the list is right.

### Other states

| State | Treatment |
|---|---|
| Loading | `FaintBars` |
| Error | `ErrorBanner` in its `error` variant, message "Could not load your practice. Pull down to try again." **Never the exception string** |
| No exam chosen | The existing fallback, "Choose your exam" over "Pick the exam you are reviewing for." and a board "Choose exam" |

`PageScaffold` and `EmptyState` exist and are used only by `quiz_results_page.dart`.
Adopt them here, as the Study spec also requires.

---

## Section 2: The practice picker

Opened by "Choose what to practice". A pushed route, not a sheet: it has a footer that
must stay put and a list that may run to 18 topics.

### Composition

App bar with a back chevron and the word "Quiz", plus **"Clear"** in board 12/600 as a
trailing action shown only when something is selected. Title "Choose what to practice"
in `displaySmall`. Then the legend, then the index, then a fixed footer.

### The index

Subject headings in serif 15/700 closed by a 1px `rule`, then topic rows in the
subject's `ordering`.

**Topic row**, minimum height 46:

- A **15px checkbox** in the gutter, radius 3, 1.4px `inkMuted` border, filling
  `board` with a white check when selected and showing a **board dash** when partly
  selected.
- The topic name.
- **No question count.** A count of 248 is inventory, not a decision: nobody chooses
  Chemistry because of how many questions it holds, and the footer states the truth
  once a selection exists. The slot stays empty.
- A trailing **caret** with its own 44px target.

**The row splits its taps.** Tapping the row selects the whole topic. Tapping the
caret unfolds its lessons. This is the pattern the Study spec already committed to for
the pinned topic bar: "Tapping the row scrolls back to the topic. Tapping the caret
collapses it. The caret needs its own 48dp target carved out of the row."

**Lesson rows** are indented 22px, carry their own 14px checkbox, the title, and
nothing else unless unread.

### Selection is hierarchical

- Selecting a topic selects **every lesson beneath it**.
- Deselecting one lesson drops the topic checkbox to the **dash**.
- **Counting never double-adds.** A fully selected topic is **one unit** drawing on
  the topic's whole pool. A partly selected topic contributes **one unit per kept
  lesson**, and the topic itself contributes nothing.

### Read state marks the exception

**Only unread lessons are marked**, with "not read yet" in `bodySmall` `rust` in the
meta column. Lessons you have read carry nothing at all.

Three reasons this beats the alternatives, all of which were drawn and rejected:

1. **The gutter belongs to selection.** A check cannot mean "read" on a screen where a
   check also means "picked". This is why the Study map's ✓ does not carry over:
   nothing on the Study map is selectable, so the two tabs never contradict each other
   on the same screen.
2. **It annotates the exception.** Most lessons end up read, so marking those marks
   almost everything, and the marks would grow rather than shrink.
3. **It is the warning that matters.** You are about to be quizzed. "You have not read
   this" is news. "You have read this" is not.

Legend, once, beneath the title, in 11.5 `inkMuted`: **"Lessons you haven't read yet
are marked."**

Rejected: grouping lessons under "Read" and "Not read yet" kickers, because it
reorders them, and the authored lesson sequence is the only guidance the Study spec
gives about what to read first. Rejected: the date read, as six dates in a column that
change no decision.

### Topics with no questions

Dimmed to `inkMuted`, checkbox at 35% opacity, not selectable, with **"no questions
yet"** in the meta slot. Not hidden: their lessons exist, and a student who has read
them will come looking.

### The footer

Fixed above the safe area, opened by a 1px `rule`, 13px padding.

**The summary**, updating live:

```
45   questions · about 40 min
     15 from each of 3 selections
```

Value in serif 21/700 tabular. Detail in 12 `inkMuted`, with the duration in `ink`
w600. When a pool holds fewer than asked, the line appends ", 1 had fewer". With
nothing selected: an em rule and "Pick a topic or a lesson above".

**The unit control**, centered, 12px: `questions · minutes`, separated by a 1px by 11px
`rule` tick with 9px margins, the active one in `ink` w700. No pills.

**The wheel.** A horizontal scroll-snapped strip, 58px tall, items in fixed **52px**
columns so every value lands on one optical center whatever its size.

- The selected value in serif 21/700 `ink`. Its neighbours in sans 14.5 `inkMuted`.
- **A `boardTint` band, 52 by 38, behind the selected column.** No rails, no border.
  The list above the footer is nothing but hairlines, and a tint marks the choice
  without adding a fourth kind of rule to the screen.
- **Both edges fade** with a mask from transparent to opaque between 0 and 22%, and
  back between 78% and 100%, so the range dissolves instead of being cut.
- **The value commits on scroll**, not only on tap. Whatever sits inside the band is
  the value.
- Steps: **questions 3 to 50 by one. Minutes 2 to 30 by one, then 35 to 60 by five.**
- Switching units snaps to the nearest available value, so switching back and forth
  does not drift.
- Haptic feedback on each step. Disabled under reduce-motion for the scroll animation
  only; the control still functions.

**The number is per selection, never a total.** A total cannot be split at all when
five is asked across six topics, and when it can be split, something has to decide the
shares, which is a rule nobody should have to reason about. Per selection is
deterministic and the footer does the arithmetic.

**"Start"**, a full-width board button, disabled while nothing is selected.

---

## Section 3: The answer reveal

**This section covers the moment after a student commits, not the session chrome
around it.** The quiz viewer is out of scope.

### The commit

Tapping a choice submits it, as today. **There is no confidence step.** It was drawn
and rejected: the hypercorrection literature makes a good case for it, and the tap is
still a tap in a rhythm Spec 4 D4 deliberately protected. What it would have bought is
recovered less intrusively by the debrief in Section 4.

### The mark

`AnswerRow` already implements `selected`, `correct`, `incorrect` and `correctMissed`
with board ✓ and rust ✕, under a docstring calling it the spec's answer device.
`QuestionCard` passes `plain` every time. **Use the states that exist.**

- The chosen row, when right: board ✓ in the letter column, text w600.
- The chosen row, when wrong: rust ✕, text in `rust`.
- The correct row, when missed: board ✓, text w600.
- Every other row drops to 50% opacity.

### The verdict line

Opened by a 1px `rule`, 14px above. **"Correct"** or **"Not this one"** in serif
17/700, board or rust. Right-aligned on the same baseline, the next interval in 11.5
`inkMuted`: "back in 9 days", "back tomorrow".

### The notes

The explanation is set as **marginal notes**, lettered in the same 22px gutter the
answer rows use, so the note for B lines up under B.

```
A   the answer
    Only coefficients, the numbers in front of a formula, may be changed…

B   what you picked
    A coefficient counts how many molecules you have. A subscript is part of
    the molecule's identity. Changing one is arithmetic. Changing the other
    is chemistry.
```

- Each note opens with a 1px `ruleFaint` and 12px padding.
- The letter in serif 15/700 `inkMuted`.
- The kicker in 11.5 `inkMuted`, lowercase: "the answer", "what you picked".
- The body in `bodySmall` at 13.5, line height 1.6.
- Note **A** always renders. Note **B** renders only on a miss, and only for Pro.

**This treatment is deliberate and replaces a rejected one.** The first draft drew the
Pro block as a tinted panel with a colored left border and a colored label, which is
the visual signature of generated output and was rejected on sight. Marginal notes are
a print device, they reuse a grid already on the screen, and they need no new color.

### What Free sees, and what it does not say

Free renders the mark, the verdict and note A. **It says nothing about Pro.** No
locked block, no upgrade line, no shadow of the missing note. A student has just been
wrong, and an offer at that moment reads as the app charging for the thing that would
have helped.

### The content this depends on

Note B requires a **rationale per choice**, which does not exist. See Section 9.

---

## Section 4: The debrief

The screen after the last question, replacing `DoneForTodayCelebration`.

### Composition

App bar with a close ✕ only. Then:

```
Ten answered.

        7 / 10              9 min
        correct             taken

Today's session. Chemistry, Physics and Biology.

To come back to                                     3
─────────────────────────────────────────────────────
✕  Balancing an equation by changing H₂O to H₂O₂
   Chemistry · you picked B, answer was A
   You answered in 4 seconds. You usually take 21 on Chemistry.
…
You'll see all three again tomorrow.
```

- **"Ten answered."** in serif 22/700, computed from the session length. Not "Session
  complete", which is software talking about itself.
- **Two** centered figures: **correct** and **taken**. Not "spent", which frames the
  time as lost. **No streak figure**, for the same reason it was cut from the session
  panel: it is on Home and in Progress and does not need a third home. It is also the
  wrong screen for it, since a streak is a fact about the month and this page is about
  the ten questions just answered.
- **"To come back to"** as the section heading, with the count. Not "What you missed":
  these are not losses, they are scheduled returns, which is literally what the
  scheduler just did.
- Each miss: a rust ✕ in the 22px gutter, the question, then "topic · you picked B,
  answer was A" in 12 `inkMuted`.
- **The rows are a record, not navigation.** No chevrons, and nothing happens on tap.
  A "Review the misses" button was drawn and deleted: the student saw every one of them
  seconds ago, a wrong answer already derives `Rating.again` and returns tomorrow, and
  "Your mistakes" on the tab is the deliberate path when they want it.
- **"You'll see all three again tomorrow."** in 12 `inkMuted`, beneath the list, for
  both tiers. It is the most reassuring true sentence available on this screen and it
  gives the Free version a proper ending rather than stopping dead.
- **One ruled row, "Go through all 10"**, in serif 15/700 with a chevron, opened by a 1px
  `rule` beneath the return promise. Added 28 July. It opens the practice form of the
  mock's review screen, specified in `2026-07-28-mock-exam-ui-design.md` Section 6, and
  it is what keeps `quiz_results_page.dart` alive instead of deleting it.

  **This does not reopen the deleted button.** That one re-listed the misses, which the
  student had just read. This one reaches the **explanations**, which were read once
  under the momentum of a session and were otherwise unreachable afterwards. The rows
  above it stay inert; the row is the single way through.
- Footer: a single board **"Done"**.

### The inferred cause

**Pro only.** Under each miss, one italic line in 12 `inkMuted`, derived from data
already stored:

| Cause | Line | Derived from |
|---|---|---|
| Rushed | "You answered in 4 seconds. You usually take 21 on Chemistry." | `AttemptItem.responseMs` against the distribution `per_question_speed_signal.dart` already builds |
| Slipped | "You had this right on 14 July. Today you multiplied where you needed to divide." | a prior correct attempt on the same question |
| New | "It's the first time you've seen this one." | no prior attempt and no FSRS state |

**Four of the five causes need no question at all.** The fifth, misreading, is
invisible to every signal the app has, and it is the only thing the taps buy.

### The invitation

**Pro only, optional, and offered once for the whole screen rather than per row.**
Opened by a 1px `rule`:

> These are the notes Pantas could write on its own. **You're the only one who knows
> the rest.**
>
> [ Finish the notes ]

A secondary bordered button. Tapping it arms three choices under every miss:
**"I misread it"**, **"I knew this, I just slipped"**, **"I didn't know it"**, each a
14px checkbox row. Any may be left blank, and the screen says so: "2 of 3 noted. Leave
any of them blank, it costs nothing." When all three are noted: "All three noted.
Progress can use them now."

**Why it is a debrief and not a form.** The app goes first with three facts it already
knew, so the student is correcting a draft rather than filling in blanks. And it is
after the session, not inside it, because the error-log method it borrows from is a
review pass rather than a prompt between questions. Asking mid-session imports the
paperwork and loses the reflection.

**This commits Progress to consuming the tags.** Three taps that surface nowhere would
be worse than never asking.

### Voice

Contractions throughout: "you've", "it's", "you'll". The plainest correct word over
the formal one: "seen", not "encountered" or "met". **No system vocabulary**: nothing
is "booked" or "scheduled", it is "you'll see all three again tomorrow". And nothing
praises the student, which keeps this consistent with the Study spec's endings, where
warmth comes from what the app promises to do next.

---

## Section 5: Session composition and ordering

### The interleaved tail

Today's session ends with **three questions drawn from other topics' due cards**, with
seven from the named topic in a ten-question session. Proportional at other lengths.

The evidence is the strongest we found: Rohrer's classroom randomised trial scored
interleaved mathematics practice at **72% against 38%** for blocked on an unannounced
test two weeks later, d = 1.05, with the advantage growing rather than fading over the
delay. Spec 4 D1 chose blocked as the default on felt-productivity grounds, which is a
real argument that this does not overturn: the session is still named after one topic
and still feels like that topic. The tail adds the discrimination practice that
blocking cannot train.

`FsrsDueSelector` already queries across topics, so this is an ordering change rather
than new machinery.

### It is a setting, not a rule

Three orderings are exposed in Settings, the default carrying a **recommended** marker
and each carrying a one-line plain explanation:

| Setting | Behavior |
|---|---|
| Blocked | Every question from the chosen topic |
| **Interleaved tail** (default, recommended) | Seven from the topic, three from elsewhere |
| Fully mixed | No two consecutive questions from the same topic |

The storage exists: `quiz_today_interleaved` is a boolean with no UI that writes it,
so it widens to a three-way value. The Quiz tab's only reference to any of this is the
"Change how sessions are built" link in Section 1.

### Drill becomes honest

The picker's sessions must **shuffle within the pool** and **exclude anything answered
in the last 7 days**, which is what Spec 4 §4.3 specified and what was never built.
Without it the subtitle "questions you haven't seen this week" is a lie and the row
returns the same ten in the same order forever.

### Deferred, and recorded here so it is not lost

**Weighting the picker toward recently-read topics.** Today's session chooses the
largest backlog, so finishing Chemistry does not mean today's session tests Chemistry.
If just-read material should come round sooner, the fix belongs in the picker and not
in a new button. `read_then_quiz_signal.dart` already measures the behavior.

---

## Section 6: Flags

**Flag** is the Quiz tab's word for a question kept for later. **Bookmark** stays the
Study tab's word for a lesson. They are different objects and the two tabs never use
each other's word.

- Flags are **question level**, set from the reveal and from inside a mock.
- `MockSessionState.flags` is a `Set<String>` of question ids and
  `mock_attempt.flagsJson` persists it. **Those are the same concept on a different
  lifetime.** A flag set during a paper means "check before I submit", which cannot
  outlive the submission, so it stays on the attempt and **never writes to
  `question_flags_local` by itself**. The mock's review screen offers to convert them
  once, in one action, and they are gone either way. See
  `2026-07-28-mock-exam-ui-design.md` Section 5.
- So the tab's **Flagged section holds durable practice flags only**, whatever their
  origin, and it never needs to distinguish where one came from.

### The mark

A **pennant**, a triangular flag notched at the fly, on a staff. Drawn in a 24 viewBox
and rendered at 21px, stroke 1.5, round caps and joins.

- Staff, always stroked: `M6 3.2v17.6`
- Pennant: `M6 4.4h12.2L14 9l4.2 4.6H6`
- **Unset:** both stroked in `inkMuted`.
- **Set:** the staff stays stroked, the pennant fills solid in `ink`.

**It is not a ribbon and it is not board green.** The ribbon belongs to Study's lesson
bookmarks and its paths are fixed by the 2026-07-27 spec. Structurally the two are
unmistakable side by side: a staff with a shape hanging off one edge against a
rectangle with a notch cut from its bottom. Board is spent on the primary action,
progress and done checks, which is the same budget argument that kept the ribbon off
it.

**Rejected:** a plain banner, because filled it is a rectangle beside a staff and that
is close enough to the ribbon to cause a moment of doubt. A dog-ear, which is the
better paper metaphor and is already the Progress tab's folded sheet. A star, which
means favorite, and a question is flagged because it beat you.

### The control

**In the app bar of the quiz viewer, in the trailing slot, outermost.** The bar reads
**[counter] [flag]**, which is the reader's `[context] [mark]` rule with the counter
playing the part the reader's "2 of 3" plays. The flag never moves.

- **Available before and after answering**, and identically inside a mock, where
  flag-for-review already exists in Spec 5. A control that lives only on the reveal
  cannot serve a mock and cannot flag a question you have not answered yet, which is
  the case a student most wants during a timed run.
- **Flagging never submits and never advances.** This is why the control is not on the
  choices themselves.
- On first use, a toast names what happened: "Flagged. Find it in the Quiz tab.", with
  an Undo. Removing a flag toasts "Flag removed".

### Motion

**The fill sweeps from the staff outward, left to right**, over **400ms** on
`cubic-bezier(.22, 1, .36, 1)`, the settled constant. **Unsetting drains instantly**,
matching the rule that an outgoing mark does not animate. Disabled under reduce-motion,
falling back to a plain swap.

Each mark in the app now fills from the edge it belongs to, and the direction is the
reason rather than decoration: the navigation tab rises from the bottom because it sits
there, the bookmark ribbon falls from the top because it hangs there, and the pennant
unfurls from its staff.

### Storage

- Storage mirrors the Study spec's bookmark table: `question_flags_local` with
  `questionId` text PK referencing questions, `flaggedAt` datetime, `sortIndex`
  integer nullable, `syncState` text defaulting to `pending`, plus a sync mapper on
  the existing pattern.

### No cap on Free

Flags are **unlimited on both tiers**, and so are Study's bookmarks. Four reasons:

1. Spec 4 §11 commits to "no caps on free Quiz tab features", with the rationale that
   gating the daily habit loop hurts conversion more than it helps. Flagging is inside
   that loop.
2. A storage cap punishes the most engaged free users, who are the closest to paying,
   at a moment of enthusiasm.
3. The failure mode is ugly: at the cap you either block them or evict their oldest
   flags, and both read as petty.
4. It contradicts the rule this app's paywall actually follows. See Section 7.

What Pro buys instead is what the flags **mean**: patterns across them, custom
ordering, and notes.

---

## Section 7: The tier line

**Free records. Pro interprets.** This is the single rule, and it is consistent across
every surface in this spec.

| Surface | Free | Pro |
|---|---|---|
| The reveal | The mark, the verdict, note A, the interval | Plus note B, addressed to the choice you made |
| The debrief | The score, the figures, every miss, the return promise | Plus the inferred cause per miss, and the tagging |
| Either review screen | Every question, the answer, note A | Plus note B |
| Flags | Unlimited, and practice sessions from them | Plus patterns, ordering and notes |
| The picker, the session, Your mistakes | Unlimited, uncapped | Same |
| Mock exam | One every 14 days per track | Unlimited |

This is Spec 4 §11 rendered rather than revised: that table already puts "Full worked
solutions and why the others are wrong" in the Pro column and "no caps on free Quiz
tab features" in the direction notes.

**It also survives the device argument.** Because note B is precomputed and shipped as
authored content rather than generated on the phone, a Pro user on a Galaxy A15 gets
exactly what a Pro user on a flagship gets.

### The only visible paywall in the tab

The mock cooldown. It states the tier rule in every state, so the cadence is a rule of
the app rather than a wall discovered on the ninth day.

---

## Section 7.5: The quiz viewer

Added 28 July, after the sections above were approved. The screen the tab opens, around
the reveal in Section 3. **Its chrome is settled here; nothing else about the mock is.**

### The bar

Height 56, `background`. **Leading:** a ✕ at 17px, stroke 1.6, `inkMuted`.
**Trailing, in this order:** the counter, then the flag, flag outermost. This is the
reader's `[context] [mark]` rule with the counter in the context slot, so the flag never
moves.

The counter reads "4 of 10" in 12.5 `inkMuted`, tabular, with a 11px caret beside it,
and it is **tappable**.

### The rail

3px, `ruleFaint` track, `board` fill, **one continuous fill** measuring position in the
session. Deliberately ambient: it says how far and nothing else, because the grid
carries the detail and neither should do the other's job.

**Rejected:** segments colored by outcome. A running score you cannot look away from
means three rust segments at question four is a reason to quit, and the debrief exists
so that judgment arrives after the work. It would also contradict the mock, where
outcomes are hidden until the end on purpose.

### Going back

**Permitted, and read-only.** `QuizSession` already holds `questions`, `currentIndex`
and a growing `outcomes` list in answer order, so a past question renders from
`outcomes[i]` with no new storage and no resubmission.

**An answered question cannot be re-answered.** The attempt row and the FSRS update were
written the instant it was tapped. Revisiting redraws the reveal, the choices are inert,
and the footer offers a way forward rather than a way to edit.

### The question grid

The counter opens **a grid, not a list**, as a bottom sheet.

- A **list answers the wrong question.** A sentence says what a question was about. A
  navigator is scanned for what went badly and how much is left, which a grid answers at
  a glance and a list answers only by reading.
- It is also the only shape that survives a mock: 170 items is a hundred-line scroll as
  sentences and 29 rows as a grid.

**Treatment: ruled rows.** Horizontal 1px `ruleFaint` under each row, **nothing
vertical**. It sets like a printed results table and halves the rule count of a bordered
grid. Six columns in a mock, five in a quiz, cells at least 46px.

**The cell** is a stack, centered as a pair, which puts the number above the cell's
optical middle:

| Part | Spec |
|---|---|
| Caret slot | **7px, reserved in every cell**, occupied only by the current one |
| Number | Serif 15/600 in `ink`, tabular. `inkMuted` at 400 when unanswered |
| Mark slot | 11px, 4px above |

**The reserved slot is not optional.** Adding the caret to a cell that has no room for
it grows the cell, and because grid rows size to their tallest cell the whole row grows
and everything below shifts. Reserving it in all cells makes the geometry identical
everywhere, and it is what allows the caret to be a single element floating over the
grid rather than a thing belonging to a cell.

**Marks, by surface:**

| Surface | Answered | Wrong | Flagged |
|---|---|---|---|
| Quiz | board ✓ | rust ✕ | not shown |
| Mock | a 5px `amber` dot | never shown | the pennant at 12px |

**Amber, not board, for answered.** A tick in the quiz grid means you were right, which
is a judgment and earns board. Answered in a mock is not a judgment, so it must not wear
a judgment color.

**The pennant in a cell is `inkMuted`, not `ink`.** In the bar it is a control and earns
full ink when set. In a cell it is a record of something already done and must not
compete with the numbers being scanned. Same glyph, two weights, decided by whether it
can be pressed.

**Flagged and answered show both marks.** They are different axes: answered is progress,
flagged is doubt. "Answered but unsure" is the most common state in a real exam, and it
is exactly what flag-for-review exists to serve.

### The current cell

**A caret above the number**: a solid `ink` triangle, 8 by 5, in the reserved slot.

**No border, box or underline.** An underline is a horizontal rule sitting a few pixels
above another horizontal rule with a different meaning and width, which cannot be
resolved by nudging. A box centers on the cell while the number is centered as part of a
stack, so the two centers never agree.

### The caret travels

**One caret per grid, moved by transform.** Nothing is created or destroyed.

- **Within a part:** it slides to the new cell over **400ms** on
  `cubic-bezier(.22, 1, .36, 1)`.
- **Across a part boundary:** it **leaves the plane through the margin**. Out past one
  edge over 200ms on `cubic-bezier(.4, 0, 1, 1)`, then in from the opposite edge over
  300ms on the standard curve.
- **Direction follows travel.** Forward exits **right** and enters from the **left**.
  Backward reverses it. Exiting and entering on the same side reads as turning around
  and coming back.
- **Nothing scrolls.** The destination was tapped, so it is on screen by definition.
  Moving the page under someone who has just aimed at something loses them, and there is
  no case in which it is needed.
- Under reduce-motion the caret simply appears.

### Leaving

The ✕ opens a dialog over an `ink` wash at 34%, with the page settling 10px and losing a
hair of scale on the standard curve. **No blur**, per the Study spec.

> **Leave this session?**
> Every answer you've given is already saved. You can pick this up from the Quiz tab
> whenever you like.
> [ Keep going ] [ Leave ]

**"Leave", not "Quit".** The session does not end, it waits on the tab. The dialog guards
no consequence, since every answer is committed on submit, so its job is orientation
rather than confirmation.

### What the mock inherits, and what it does not

The **grid component and the flag** are shared. The mock's variant shows answered and
flagged and never an outcome, and it groups by part with a count per part.

The mock adds a **floating bar** at the bottom, which the quiz does not have: previous
leftmost, next rightmost, and between them the grid glyph, the counter and the flag.
Base gap **16px**, with **+5px on the grid side** as an optical correction, because the
grid glyph is a solid block while the pennant is open on its lower right, so equal
metric gaps read unequal.

**Why only the mock gets it:** in practice you move forward and the reveal is the event.
In a mock you move in both directions constantly and no answer is ever revealed, so
paging is the primary interaction rather than clutter. It also frees the app bar for the
clock, which must never be hunted for.

**The grid glyph** is a 3x3 of nine filled squares, 5.4px each with 1.6px gaps in a 24
viewBox, rendered at 19 to 20px.

Everything else about the mock, including its results screen, remains its own spec.

---

## Section 8: Motion and feedback

The settled constant across the app is **400ms on `cubic-bezier(.22, 1, .36, 1)`**,
inherited from the navigation bar's ink rise and reused by the Study spec. Almost
nothing in this spec should use it, and the exceptions are listed here.

### The reveal does not animate its verdict

**The graded marks apply instantly.** No transition on correctness, no delay before
the ✕ appears. A pause reads as the app deciding, and it is not deciding: the answer
was known before the tap.

**The verdict line and the notes fade in over 140ms linear, with no movement.** They
are appearing beneath content the student is still reading, and anything that
translates would shift the choices under their eye at the exact moment they are
looking for the one they picked. Opacity only.

### The picker

| Element | Motion |
|---|---|
| Checkbox fill | 120ms linear, matching the reader's armed pull handle |
| Topic unfold and fold | 220ms on the standard curve, height and opacity together |
| The wheel | Native scroll physics with snap. No custom easing, no synthetic momentum |
| The footer summary | Text swaps with no transition, because it must keep up with a scrolling wheel |

**The unfold duration is shared.** The Study map expands topics in place with the same
gesture, so both lists must use 220ms and the same curve. If one is tuned, the other
moves with it.

### The debrief

The figures and the miss list arrive with the page. **The invitation fades in 160ms
after entry, over 300ms**, so the record is read before the ask appears. This borrows
the delay pattern the Study spec uses for the bookplate, for the same reason: the page
should state its facts before it asks anything.

### The flag

The only element in this spec that uses the 400ms constant. It sweeps from the staff
outward and drains instantly, per Section 6.

### Haptics

A light selection tick on each wheel step, on each checkbox toggle, and on setting a
flag. Nothing else in this spec vibrates. **There is no haptic infrastructure in `lib/` today**, so this is a
small addition rather than a call into something existing, and it should be a single
helper rather than scattered `HapticFeedback` calls.

### Reduce-motion

Every fade becomes an instant swap. The unfold becomes an instant height change. The
wheel is untouched, because its motion is the user's own finger and removing it would
break the control rather than calm it.

---

## Section 9: Data and content work

### New storage

| Need | Shape | Notes |
|---|---|---|
| Question flags | `question_flags_local`, mirroring `lesson_bookmarks_local` | Plus a sync mapper. **Independent of** `mock_attempt.flagsJson`, which is a per-attempt working mark that never writes here on its own |
| Mistake tags | one nullable enum column on the attempt item: misread, slipped, unknown | Written only from the debrief, only on Pro |
| Ordering preference | widen `quiz_today_interleaved` from boolean to three-way | Key already exists and is already read |

### New content fields

Both are generated **once, offline, over the whole bank**, reviewed by Aedwon, and
shipped through the existing Sanity pipeline. Approximately **one dollar** for all
1,117 questions at current Flash-Lite rates.

| Field | Buys | Notes |
|---|---|---|
| A rationale per choice | Note B on the reveal, which is the whole Pro proposition on that screen | The distractors are already authored as named misconceptions, so this is writing down reasoning the author already had |
| A short label per question | The debrief's miss rows, and it fixes a shipping defect: `quiz_results_page.dart:190` lists every question by its **raw `questionId`** | Nullable. Renderers fall back to the stem clamped to two lines |

**Both must render through the shared question renderer, not a plain `Text`.** Stems
carry LaTeX and markdown that render literally today (UI-005, UI-006, UI-007), so a
clamped stem in the debrief would show a raw `$F_{net} = ma$`.

### Lesson tagging, decided and scheduled first

**Every question gains a `lessonId`**, authored across all 1,117 before this tab
ships. It is the largest single piece of work in this spec and it was chosen
deliberately over deferring, because it is not a future feature but a live defect:
the reader coda approved on 2026-07-27 hands all 17 Chemistry lessons the same five
questions today.

It unblocks, in order of value: the reader coda becoming real, lesson selection in the
picker, and pretesting before a lesson, which improves learning **even when the
pretest answers are wrong**.

### Cooldown time, and clock tampering

The mock cooldown is computed from the most recent terminal `submittedAt`, per Spec 5,
which is unaffected. What changes is where "now" and `submittedAt` come from, because
a device clock moved forward two weeks currently buys a free mock exam.

1. Store `submittedAt` as **UTC epoch milliseconds**, always.
2. When online, stamp it with **server time** and prefer that value. Spec 3 already
   syncs attempts, so the channel exists.
3. Keep a **monotonic guard**: persist the highest timestamp ever observed and never
   compute a cooldown against a "now" earlier than it. This defeats rollback outright.
4. Compare wall-clock deltas against `elapsedRealtime`, which is boot-relative and
   cannot be set. If wall time advanced far more than elapsed time with no reboot, wait
   for a server time before granting the next exam.

A determined user who stays offline can still gain one exam. That is an acceptable
loss and nothing heavier should be built for it.

### Unused today, to be consumed

- `BuildTodayQueue` and `TopicQueueRow`: pure, tested, referenced nowhere.
- `ResumeSession`, `RestartSession`: providers exist, no widget reads them.
- `AttemptItem.chosenChoiceId`: stored and synced, consumed by nothing, and it is the
  record of which misconception each student holds.
- `MockQuizTabTile`: written, tested, rendered nowhere.

---

## Section 10: Amendments to other specs

1. **Spec 4, `2026-05-17-quiz-engine-and-modes-design.md`.** D1 gains the interleaved
   tail as the default with the ordering exposed as a three-way setting. D9's "minimal
   celebration" is superseded by the debrief in Section 4. §7.1's topic-queue Quiz tab
   is superseded by Section 1. §7.2's Drill browser is superseded by the picker. §7.5's
   session screen is untouched here and remains open, since the quiz viewer is out of
   scope.
2. **Spec 5, `2026-05-17-mock-exam-design.md`.** `MockQuizTabTile` is superseded by the
   mock panel in Section 1. The cooldown gains a precise `9d 14h` figure and the tier
   rule as a permanent line. **D11 is reversed**, 28 July: the per-question review is on
   both tiers and Pro adds note B. The reasoning is in
   `2026-07-28-mock-exam-ui-design.md` Section 5, and D11 is struck through in Spec 5
   itself rather than left to read as current. Everything else stands.
3. **`2026-07-27-study-tab-and-reader-design.md`.** Its deferred item "a quiz entrance
   in Study" is **closed as no**: the reader's coda at the end of every lesson already
   is that entrance, at the only moment it is earned, and the map deliberately holds
   nothing inside an open topic. Its reader coda is unchanged but becomes correct only
   once lesson tagging lands.
4. **`2026-07-18-ui-redesign-design.md`** gains: the panel header's trailing slot is a
   count or an action, never a status word; and the marginal-note device of Section 3
   as the way an explanation attaches to a lettered option.
5. **Route table:** `/quiz/drill/:examId` and `DrillSubtopicBrowser` are deleted and
   replaced by the picker. `/mock-exam` remains a stub and is the mock viewer's problem.
   `/review` becomes the review screen, taking a session or an attempt and rendering the
   practice or mock form of the same component. `quiz_results_page.dart` is rebuilt
   behind it rather than deleted.

## Sectional papers, established 28 July

Research prompted by Aedwon's UPCAT experience, recorded here because it constrains the
mock viewer before that spec is written.

| Exam | Sections separately timed? |
|---|---|
| UPCAT | **Yes.** "You cannot return to a subtest once time is called" |
| USTET | **Yes.** Each section separately timed. Mental Ability is 80 items in 30 minutes |
| NMAT | **Yes.** Its bulletin says the timer restarts for every section |
| CSE | **No.** 170 items in one booklet over 3 hours 10 |
| ACET, DCAT, MSU-SASE | **Not published.** Aedwon is establishing these |

**`sectionalTiming` is a blueprint field**, with a per-section limit, and it is the third
content attribute of its kind after subject `kind` and the wrong-answer penalty. The
rule they share: **the exam's rules are content, not code.**

**Nothing may be defaulted for the three unknowns.** The setup screen states the rule in
plain words before the paper starts, and pacing guidance comes from the blueprint rather
than from any app-wide assumption, since USTET's 22 seconds an item against CSE's 67
would otherwise be wrong by a factor of three.

**ACET and DCAT include an essay, and DCAT a personality test.** The app has no concept
of either, so their blueprints cover the multiple-choice parts and the setup screen must
say what is not included.

**This narrows Section 7.5.** The caret's travel across a part boundary happens only in
the results review, or during a roamable paper. In a sectional paper a boundary can
never be crossed while answering, and later parts render dimmed and untappable with a
line saying when they open.

## The mock viewer, carried forward

Its UI is a separate design job and **inherits nothing from this spec**. No answer
reveal, no marginal notes, no per-question explanation, no debrief. It is time limited
and runs under exam conditions from the first item to the last, because its job is to
simulate the exam and to produce the practice-versus-pressure comparison
`test_mode_delta_signal.dart` already measures. Revealing answers mid-paper destroys
both. `2026-05-17-mock-exam-design.md` is its starting point.

## Deferred, with reasons

- **The quiz viewer**, as above. The header, the counter, the rail, quitting, moving
  between questions, and where a flag is set while answering.
- **Confidence at the point of answering.** Rejected for the tap, not for the idea.
  The debrief recovers most of the signal, and `responseMs` gives a free rough proxy.
  Calibration as a Progress figure remains attractive and unbuilt.
- **Pretesting before a lesson.** Two questions before reading, which the meta-analytic
  evidence supports even when the answers are wrong. Blocked on lesson tagging, and it
  belongs to the reader rather than to this tab.
- **Knowledge and aptitude as a content attribute.** Every exam Pantas targets mixes
  knowledge sections with aptitude sections, and FSRS scheduling is weak on the latter,
  where the item never recurs and the skill is pattern recognition. The clean shape is
  two content fields, a `kind` on each subject and a per-exam flag for whether wrong
  answers are penalised, rather than any per-exam branching in code. Needed before
  PSHS-NCE or NMAT, not before UPCAT.
- **On-device explanation generation.** Precomputed content covers the need at a
  fraction of the complexity and works on every device. Revisit only if an
  offline-first case appears.

## Open

1. **The mistake-tag vocabulary.** "I misread it", "I knew this, I just slipped", "I
   didn't know it" are settled for practice. Timed surfaces will want a fourth, "I ran
   out of time", which matters on NMAT and CSE and barely registers on untimed
   practice. Decide when the mock viewer is designed.
2. ~~Whether the flagged row splits.~~ **Closed 28 July.** It does not, because there
   is only one durable flag. A mark made during a paper expires with the paper and is
   offered once in the mock's review; anything kept becomes an ordinary practice flag
   with no record of where it came from.

3. ~~Two screens are named but never drawn.~~ **Closed 28 July.** "Your mistakes" starts
   a retake session and needs no screen. The **Flagged row opens a list**, the mock
   review component in its practice form, with "Practice these 12" at the bottom. See
   Section 1.

## A note on plan size

Too large for one implementation plan. The natural seams, in dependency order:

1. **Content and storage.** Lesson tagging across 1,117 questions, the per-choice
   rationale and short-label generation pass, the flags table and its sync mapper, the
   mistake-tag column, and the ordering preference widening. Everything else depends on
   some part of this and none of it is visible.
2. **The tab.** Panels, rows, all four day states, the mock panel and its cooldown, and
   the deletion of `DrillSubtopicBrowser`.
3. **The picker.** The index, hierarchical selection, the wheel, the live footer, and
   the drill fix that makes its promise true.
4. **The reveal.** Graded answer states, the verdict, the marginal notes, and the tier
   split.
5. **The debrief.** Figures, the miss list, the inference, the optional tagging, and the
   row into the review.
6. **The review component**, shared with the mock and reached from the debrief, the
   Flagged row and a finished mock. It is listed last because every one of its three
   entrances is built above it, and it is the piece that makes `quiz_results_page.dart`
   worth keeping.

The content work in 1 runs alongside everything and must land before 3 and 4.
