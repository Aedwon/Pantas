# Quiz tab: decision log

**Covers:** 27 to 28 July 2026, the Quiz tab, answer reveal, session debrief and
practice picker design sessions.
**Spec produced:** `../specs/2026-07-28-quiz-tab-design.md`
**Mockups:** `.superpowers/brainstorm/80560-1785139437/content/` and
`.superpowers/brainstorm/73916-1785087646/content/` (both gitignored)

## What this document is, and why it exists

The spec states the settled design. It does not state **what was rejected, why, what
was tried first, or what Aedwon actually said**. Those details were living only in the
visual companion's event log, which is disposable, so they are written down here.

Every selection in the companion is recorded as a `user-event` line in
`<session>/state/server.log`, including the option chosen, the state of every toggle,
and the full text of any note. This log is reconstructed from those lines, so the
quoted comments are verbatim and the click counts are exact.

**Standing practice from now on:** after every companion round, the decision, the
rejected alternatives with their stated costs, and Aedwon's verbatim comments get
appended here before the conversation moves on.

### How to read the counts

Each plate records how many events it produced. An event fires on every toggle change
and on every keystroke in a note box, so the count is a rough measure of how long a
plate was worked, not of indecision. Where the exploration path matters it is called
out explicitly.

---

## Plate 1: The shape of the tab

**File:** `quiz-tab-shape.html` · 16 events · 27 July

**Question asked:** what does the Quiz tab open with?

| Option | Presented as | Stated cost |
|---|---|---|
| Shipped | Reference only: exam name, one button, three rows | Ignores every count; starts a session with no topic |
| A. The topic queue | Every topic ordered by backlog, largest marked "start here" | Starts the daily habit with a decision every day; on first open every number is fiction; no room for streak or Resume |
| B. One session, one button | The engine picks, the tab states figures only | Hides the personalization entirely; a student who knows their weakness cannot act on it |
| C. Head and index | A two-figure head with a primary action, full index beneath | Two entrances to the same action; longest screen of the three |

**Explored:** A, B, C, back to B, C, C, A, the shipped tab, then C twice. Ten
switches, ending on C after checking it against the shipped tab.

**Decided:** C.

**Superseded four plates later.** C was a topic list with a head, and the whole
family was replaced once the tab's real charter surfaced. Recorded because the
reasoning that killed it matters: all three options were the same shape.

---

## Plate 2: Four ways to open a hub

**File:** `quiz-tab-configurations.html` · 127 events · 27 July

**What changed between plates:** Spec 5 says in as many words that the Quiz tab is the
**assessment hub**, and specifies `MockQuizTabTile` as living on it "alongside Today's
Session, Drill, Retake". None of plate 1's options contained a mock at all, which is
why they all felt small.

| Option | Presented as | Stated cost |
|---|---|---|
| D. The hub | Each way of being tested as an object with its own state | Configuration disappears inside whatever you tap; five panels is a lot of boxes |
| E. The request slip | One fill-in-the-blank sentence, with saved slips beneath | A mock is not a quiz you compose; the diagnostic has nowhere to live |
| E+D | The slip as head, the hub beneath | The first open is a blank form asking a beginner an unanswerable question |
| F. Modes as a shelf | Practice, Exam conditions, Survival, Mistakes, Mock | Asks "in what manner" first, which nobody thinks; three screens to start a quiz |

**Explored:** 123 of 127 events on D. The slip's live blanks were never touched: only
one slip value appears in the entire log, the default.

**Decided:** D, the hub.

> "i like the format of the hub best, it cleanly isolates the main CTAs and lists the
> other options after it. it lets the user be mindless in the first part, and if they'd
> like to tinker more they have the options as well."

**Also raised on this plate, and answered later:**

- The mock's free-tier limit must be honoured. Confirmed against Spec 5 as **1 per 14
  days per track**, not weekly.
- "Your mistakes" needs its mechanism stated. Answered: exam-wide, last **30 days**,
  capped at **50**, newest first, from `StartRetake`.
- Drill may be redundant with the main action. **Confirmed redundant in a worse way
  than suspected**: `StartDrill` returns the first N questions of a topic in database
  order, identically every time.
- "Where you stand" may be redundant. **Agreed and deleted**: the assessment is a
  first-open state, not a standing row.
- The rows must be MECE. Answered: they cannot be exclusive by axis, because a
  selection rule, a set of conditions, a pool and a scope are four different axes. They
  are made exclusive **by intent** instead.

---

## Plate 3: The answer reveal

**File:** `quiz-answer-reveal.html` · 72 events · 27 July

Built with a real question from the bank, `q-chemistry-chemical-reactions-0009`, chosen
because its distractors are authored as named misconceptions.

| Decision | Options | Chosen | Events |
|---|---|---|---|
| What the reveal shows | The mark only / add the explanation / add why yours was wrong | **Add why yours was wrong** | 61 of 72 |
| Before committing | Ask how sure / tap to commit | **Tap to commit** | 60 of 72, after trying confidence 12 times |
| After a miss | Ask what happened / say nothing | **Ask what happened** | 71 of 72 |

**Confidence was tried and rejected.** The case for it was the hypercorrection effect:
errors held with high confidence are corrected better when feedback is prompt, and a
"you were sure and wrong" queue is a review list nothing else can produce. It lost on
friction, and Spec 4 D4 had already refused an extra tap for the same reason.

> "won't asking them a list of options to what happened just add to more cognitive load
> hence more friction? i could be wrong, but maybe it's worth exploring a more intuitive
> way to measure what it has to without using that particular form. be creative about
> it"

**This comment moved the error log out of the session entirely**, which turned out to
match the practice it was borrowed from: a GMAT or JEE error log is a review pass after
the fact, not a prompt between questions.

Also raised: gate "why your answer was wrong" to paid. Confirmed as **already the
written commitment**, Spec 4 §11, which puts "why the others are wrong" in the Pro
column.

---

## Plate 4: Tier and debrief

**File:** `quiz-tier-and-debrief.html` · 64 events · 27 July

| Decision | Options | Chosen |
|---|---|---|
| The reveal on Free | Silent about Pro / name what Pro adds / Pro | **Free, silent** |
| The debrief | Summary only / state what it inferred / inferred plus an optional invitation | **Inferred plus the invitation** |

**Free silent won on one argument:** a student has just been wrong, and an upgrade line
at that moment reads as the app charging for the thing that would have helped.

**Two problems raised on this plate:**

> "there are two secondary CTAs. are they the same? if so that's redundant."

They were not the same: one armed the tagging, the other re-opened the missed
questions. **"Review the misses" was deleted** rather than reconciled, because the
student saw every one of them seconds ago, the scheduler already returns them tomorrow,
and "Your mistakes" is the deliberate path. The rows became a record with no chevrons.

> "please change the UI on the Pro explanation, it has elements of AI-creation. refer
> back to your primary instructions that I do not like the appearance of clearly AI-made
> elements (they have patterns to it)."

The Pro block had been drawn as a **coloured 2px left border with a tinted label**,
which is the visual signature of LLM markdown and generated templates. Replaced with
**lettered marginal notes** that reuse the answer rows' 22px gutter, so the note for B
sits under B. Recorded as a standing rule in memory.

---

## Plate 5: Debrief wording and tier visibility

**File:** `quiz-debrief-v2.html` · 11 events · 27 July

Three phrasings for the invitation, all saying the same thing, differing in what they
flatter:

| Wording | Body | Why it lost or won |
|---|---|---|
| **Finish the notes** | "These are the notes Pantas could write on its own. You're the only one who knows the rest." | **Chosen.** Carries the marginal-note device from the reveal into the ending, so the two screens are visibly one object |
| Tell it what you were thinking | "Pantas can see your timing and your history. It can't see what you were thinking." | Clearest, but "it" is a voice the rest of the copy does not use |
| Show me the pattern | "Two more sessions like this and Pantas can tell you whether you are losing marks to gaps or to hurry." | Most motivating, and the most dangerous: it writes a cheque Progress must cash in those exact words |

**Tier resolved on this plate:** the debrief itself is **Free**, the diagnosis is
**Pro**. The rejected middle option was tagging on Free with patterns on Pro, which
asks a free user for three taps and shows them nothing.

**Copy pass that followed**, all of it from direct instruction:

| Was | Now | Reason given |
|---|---|---|
| Session complete | Ten answered. | Software talking about itself |
| What you missed | To come back to | These are scheduled returns, not losses |
| First time you have met this one | It's the first time you've seen this one | "met" is wrong for a question; "seen" beats "encountered" for the reading level |
| spent, streak | taken, running | "Spent" frames the time as gone |
| All three are already booked to come back tomorrow | You'll see all three again tomorrow | "Booked" is scheduler vocabulary |
| you have, it cannot, did not | you've, it can't, didn't | Instructed: contract for naturalness |

---

## Plate 6: The five terminal decisions

**File:** `quiz-decisions.html` · 54 events · 27 July

Built because the decisions were hard to judge as prose. Each was drawn: session
composition as strips of ten cells, drill as three identical rows labelled Monday,
Wednesday and Saturday, the content fields as a before and after of the results row,
lesson tagging as seventeen marks fanning into one set of five.

| Decision | Chosen | Rejected |
|---|---|---|
| Session ordering | **Interleaved tail**, seven from the topic and three from elsewhere | Blocked; fully mixed |
| Drill | **Fix it**: shuffle and skip the last 7 days | Cut the row; re-aim it at lessons |
| Content pass | **Both fields** | Rationales only; neither |
| Lesson tagging | **Author it now, before the tab ships** | Ship first and tag later (my suggestion, overruled); drop lesson-scoped quizzing |
| A quiz door in Study | **No** | A row inside an open topic (my suggestion, overruled); a section header action |

> "i think it would be best to make interleaved default setting, then the user can
> change this in the settings with interleaved having a recommended badge/indicator and
> short explanation to each option. i am thinking they might prefer other options so
> let's not lock to only one."

**Recorded to memory for the Settings session.** `quiz_today_interleaved` already
exists as a boolean that no UI writes, so it widens to three values.

> "on decision 5, isn't there a 'quiz yourself on this topic' option on every lesson
> end? correct me if I'm wrong."

**Correct, with one refinement:** the Study spec's coda is per **lesson**, not per
topic, and appears at the end of all 141. That is why the map needs no door, and it is
a better reason than the one I had given. It also made lesson tagging load-bearing:
that coda is live today and hands every Chemistry lesson the same five questions.

---

## Plate 7: The tab assembled

**File:** `quiz-tab-assembled.html` · 280 events · 27 July

The largest single round of corrections in the project. **Four of the items were things
I had invented and stated as fact.**

| Raised | Verdict |
|---|---|
| Is the assessment really 10 questions? | **No.** `AssessmentQuestionSelector` caps at 35 and takes up to 3 per contributing topic: 21 today with 7 topics, 18 once all 18 are authored |
| Placer or assessment? | **Assessment.** Three shipped strings say so, and Spec 5's copy rules ban "diagnostic" by name |
| Why is the mock locked for a new user? | **It is not.** Spec 5: "Free no-prior → available". The lock was invented |
| Can a mock stand in for the assessment? | Partly. Spec 5 D4 is summative only on purpose, because a mock would dump 80 to 120 wrong answers into the review queue. But it produces per-section accuracy and top-3 weak topics, so a completed mock can satisfy the assessment without feeding the scheduler |
| "10 questions" and "not yet" look forced | **Agreed and deleted.** In this identity the top right of a section is an action in board 12/600 or a count in 12px muted tabular. A status word is neither |
| practise | **British.** Zero instances in the repo against seventeen of "practice" |
| "More ways to practice" then "Practice a topic" | **Agreed.** Became "Specific topic" |
| Centre the figures, drop the streak, "duration" not "about" | All applied. Home already centres its stats band |
| The composition copy is too verbose | Reduced to one tabular line plus a link into the setting |
| "in 9 days" is imprecise | Became **9d 14h**, so an alarm can be set |
| State the tier rule on its own line | Applied to both tiers, in every state |
| "sit" the paper | Became "take" |
| "Pick up where you left off" | Became **Resume** |
| What does "Start over" do? | **It replays the same ten questions.** `RestartSession` creates a new row with identical question ids while the answers already given stay recorded, so six questions get answered twice and feed the scheduler twice. Replaced with **Discard** |

> "why is the copy so terrible im crying"

**Also discovered here:** the per-option note boxes had never worked. Clicking one
bubbled to the option row, which repainted and destroyed focus, which is why every
comment until this point had gone in the single box at the bottom. Fixed with a guard
on the click handler and recorded to memory as a plate-construction rule.

---

## Plate 8: The tab corrected

**File:** `quiz-tab-v2.html` · 182 events · 28 July

**Decided:** four rows plus a Saved section, then immediately refined by comment to
**three rows plus Flagged**.

> "i picked the 4 rows and saved, but honestly i think the 'A lesson you've read' is a
> bit redundant with 'Specific topic'. what I'm thinking instead is that we integrate
> this 'lessons you've read' as just an indicator when inside selecting specific topic."

> "in hindsight, it might be better to just use the word Flag instead of save or
> bookmark so that it's sort of distinct from the mechanism of the Study tab."

**The Flag naming settled a real collision.** The Study spec had avoided "flag" for
lessons because `MockSessionState.flags` had taken the word. That was right for lessons
and wrong as an inference for questions: mock flags **are** question flags, so they
merge into the feature instead of colliding with it. Study keeps Bookmarks, Quiz uses
Flagged.

**Three further corrections:**

- "paper" became **exam**, and "Free" became **Free users**.
- The "new" markers were annotations for the reviewer and read as release notes.
  Deleted.
- "See your last paper" became "View your full results from last time".

**Two questions answered in the terminal rather than drawn:**

> "are these absolute time? it might be prone to abuse if we use system time"

A real hole: the cooldown is computed from `submittedAt`, and moving the device clock
forward two weeks buys a free exam. The answer written into the spec is four layered
measures: UTC epoch storage, server time when online, a monotonic guard against
rollback, and an `elapsedRealtime` cross-check for forward jumps. A user who stays
offline can still gain one exam, which is an acceptable loss.

> "do you think we should set some other limits for the Free version? I'm thinking like
> limiting the number of flagged questions?"

**Advised against, and accepted.** Spec 4 §11 commits to no caps on free Quiz tab
features; a storage cap punishes the most engaged free users at a moment of enthusiasm;
the failure mode is either blocking them or evicting their oldest flags, both of which
read as petty; and it contradicts the rule the paywall actually follows, **Free
records, Pro interprets**. What Pro buys instead is what the flags mean.

> "'Discard this session' is an action so shouldn't it be green? im not sure though"

Drawn both ways on the next plate. My argument for muted was that the panel already
spends its green on Resume. **Overruled: board green**, on the consistency argument,
83 events to 6.

---

## Plate 9: The Quiz glyph, reopened

**File:** `quiz-glyph-v2.html` · 5 events · 28 July

**Context:** an earlier session had already run an eleven-candidate gallery
(`.superpowers/brainstorm/72587-1784988095/content/quiz-gallery.html`) and settled on
**S2, a single shaded bubble**. It kept looking wrong.

**Two causes, one mine.** Every plate I had drawn used a plain disc that fills solid,
not the approved shaded bubble. And the deeper reason it still felt off after
correction: Home is a house, Study is an open book, Progress is a folded sheet with a
rising line, and each is an object with internal structure. A circle has none, so at
23px it reads as a placeholder.

| Candidate | Outcome |
|---|---|
| S2, single shaded bubble | The prior decision, drawn correctly for the first time. Not chosen |
| Two options, one shaded | Not chosen |
| **S1, three options and rules** | **Chosen.** Previously rejected as busy; fixed by shading only the middle bubble instead of all three |
| An answer row, four bubbles horizontal | My suggestion. Not chosen |
| T1, serif question mark in a circle | Not chosen. It says "help", not "quiz" |

> "looks natural"

---

## Plate 10: The picker, first draft

**File:** `quiz-tab-v3.html` and `quiz-picker.html` · 89 and 35 events · 28 July

**No decision was recorded on `quiz-picker.html`.** Its final logged state is an
artefact of exploration, not a choice:

> "i'm not gonna select or comment there because my thoughts are mixed"

**Four problems raised, all upheld:**

1. A check mark means "read" and "selected" at once. **The gutter was given to
   selection**, and read moved into the text.
2. The length control was forced, with predetermined values.
3. "Quiz all of Chemistry" sat awkwardly in the middle of the lessons. **The row was
   split**: tapping the row takes the topic, tapping the caret unfolds it. This matches
   a pattern the Study spec had already committed to for its pinned bar.
4. There was no live total. **A counting footer was added.**

---

## Plate 11: Read marks, counts and the length control

**File:** `quiz-picker-v2.html` · 33 events · 28 July

| Decision | Options | Chosen |
|---|---|---|
| Read is shown by | Mark only the unread / group under two kickers / the date read | **Mark only the unread** |
| The topic row shows | How much you read / how you score there / nothing / the question count | **Nothing at all** |
| Length control | A printed ruler / a wheel / a stepper | **A wheel** |

**The question count was dropped on argument:** 248 is inventory, not a decision.
Nobody chooses Chemistry because of how many questions it holds, and the footer states
the truth once a selection exists. The empty state survives, because six Mathematics
topics genuinely cannot be quizzed and hiding them would be worse.

**Grouping was rejected for a specific reason:** it reorders the lessons, and the
authored sequence is the only guidance the Study spec gives about what to read first.

**The ruler was my suggestion and lost.** Its argument was identity: a ruled scale with
ticks is a printing instrument where a drum picker is an operating system part. The
wheel won on intuitiveness.

---

## Plate 12: The picker rebuilt

**File:** `quiz-picker-v3.html` · 53 events · 28 July

**Three corrections, all mine:**

1. **Per topic, not total.** Stated once already and misread by me as an argument
   against it.

   > "make the number they select be number of questions per topic, because what if
   > they select 5 and choose more than 5 topics? crazy right"

   A total of 5 across six selected topics cannot be split at all, and where it can,
   something has to decide the shares. Per selection is deterministic and the footer
   does the arithmetic.

2. **Hierarchical selection.** Selecting a topic now ticks every lesson beneath it, and
   unticking one drops the box to a dash. The counting rule that stops the double-add:
   a fully selected topic is one unit on the topic pool, a partly selected topic
   contributes only the lessons kept.

3. **The wheel now commits on scroll**, not only on tap. The snapping had been
   cosmetic.

**Centre marker:** a **board-tinted band**, 49 events to 2, over two rails and register
ticks. The list above it is nothing but hairlines and a tint marks the choice without
adding a fourth kind of rule.

**Final three adjustments, by instruction:**

- Minutes step by one to 30, then **by five to 60**. Questions unchanged at one step
  from 3 to 50.
- "per topic" removed from the unit row, since the summary states it.
- Switching units snaps to the nearest available value so it does not drift.

---

## Plate 13: The flag, its home and its glyph

**File:** `quiz-flag.html` · 31 events · 28 July

Scoped by instruction to two questions only: where the flag lives, and what it looks
like. The rest of the quiz viewer stays for its own session.

**Constraints stated before drawing**, all of them inherited rather than invented:

- It must work **before an answer and after one**, because flag-for-review in a mock is
  pre-answer by definition and practice flagging is mostly post-answer. One word, one
  behaviour.
- **It cannot be a ribbon.** Study owns that shape for lesson bookmarks.
- **It cannot be board green**, on the same budget argument the Study spec used to keep
  the ribbon off it.
- **It must never submit or advance**, which ruled out putting it on the choices before
  anything was drawn.

| Placement | Events | Outcome |
|---|---|---|
| **The app bar, outermost** | 25 | **Chosen.** The only placement that works before answering, after answering and inside a mock. Inherits the reader's `[context] [mark]` rule, with the counter in the context slot |
| In the bar and named on the reveal | 4 | Two controls for one state |
| On the reveal only | 1 | Cannot serve a mock, cannot flag an unanswered question |
| Press and hold | 1 | Needs a hint line, which is the chrome it was avoiding |

| Glyph | Events | Outcome |
|---|---|---|
| **Pennant** | 18 | **Chosen.** Literally the word, structurally unlike the ribbon, and the staff fixes its left edge so it does not appear to shift between states |
| Banner | 11 | Given a serious look. Filled, it is a rectangle beside a staff, which is close enough to the ribbon to cause a moment of doubt |
| Dog-ear | 1 | The better paper metaphor, and already the Progress tab's folded sheet |
| Star | 1 | Means favourite. A question is flagged because it beat you |

> "maybe like the bookmark, the fill up should come from left to right at the same
> velocity/duration"

**Adopted, and it completes a pattern.** Every mark in the app now fills from the edge
it belongs to, at 400ms on the settled curve, draining instantly when unset. The
navigation tab rises from the bottom because it sits there. The bookmark ribbon falls
from the top because it hangs there. The pennant unfurls from its staff. The direction
is the reason rather than decoration.

**Spec updated the same day:** Section 6 gains the mark's paths, the control's
placement and the motion, and the Scope section's quiz-viewer carve-out gains an
explicit exception for it, since the Flagged section on the tab would otherwise specify
a list that nothing could add to.

---

## Plate 14: The spec review

**File:** `quiz-spec-review.html` · 28 July

Nine decisions from the spec, each drawn beside its statement, with a confirm or flag
control per item. **All nine confirmed, none flagged.** Two notes followed.

> "the Today's session and mock panel should be enclosed like how Home tab is"

**No change needed.** The spec already specifies both as ruled panels, a 1px `rule`
border with square corners, explicitly per the Home spec's device. What lost the
enclosure was the review page itself, which drew the panel contents and the rows inside
one shared box as a rendering shortcut.

**Clarified on the same point:** only the two panels are ruled. **"More ways to
practice" and "Flagged" stay plain ruled lists**, not boxes. This is a deliberate
departure from Home, which encloses all four of its blocks, and it keeps the tab's
hierarchy legible: two objects with state get edges, two lists do not.

> "remove the streak figure"

**Applied.** The debrief drops from three figures to **two, correct and taken**. Same
reason the streak was cut from the session panel on plate 7: it is on Home and in
Progress and does not need a third home. There is a second reason particular to this
screen, recorded in the spec: a streak is a fact about the month, and the debrief is
about the ten questions just answered.

---

## Decisions taken in conversation rather than on a plate

Recorded here because they are absent from every mockup.

| Decision | Where it came from |
|---|---|
| The mock viewer is a separate design job inheriting nothing: no reveal, no notes, no debrief, timed throughout | Direct instruction, 27 July |
| The quiz viewer is out of scope for this spec | Direct instruction, 28 July |
| The interleaved tail becomes a three-way Settings option, not a locked default | Comment on plate 6 |
| Free tier caps on flags and bookmarks: none | Advice requested and accepted, plate 8 |
| Cooldown clock hardening: four layered measures | Question raised on plate 8 |
| Mock cadence is 14 days, not weekly | Aedwon corrected himself after I flagged the discrepancy with Spec 5 |
| "Weight the picker toward recently-read topics" is deferred, not dropped | Raised by me as a gap, withdrawn on Aedwon's argument that today's session already is the path after reading |

**One suggestion of mine withdrawn in full.** I proposed adding a quiz offer to the
topic closing page, on the grounds that finishing a topic is a good moment to be
tested. Withdrawn: today's session is the designed path, reachable from Home and the
Quiz tab, and the lesson coda has already made the same offer once per lesson on the
way. The closing page has one action on purpose.

---

## Research that shaped decisions

Cited here so the spec's claims can be traced.

| Claim | Source |
|---|---|
| Interleaved maths practice scored 72% against 38% two weeks later, d = 1.05, and the gap grows with delay | Rohrer's classroom randomised trial |
| High-confidence errors are corrected better with prompt specific feedback, but return unless a test follows | Hypercorrection literature |
| Pretesting improves later learning even when the pretest answers are wrong | Prequestion effect meta-analysis |
| Students systematically overpredict their performance, worst in mathematics | Calibration research |
| Good distractors are diagnostic: the wrong answer names the misconception | Distractor development literature |
| Categorised error logs are the standard method in serious exam prep | GMAT, JEE and SAT coaching practice |

---

## Backfill still owed

The event log also contains **fourteen earlier plates** from the Home, Study and reader
sessions, listed below with their final selections. Those specs exist, but no decision
log does, so the same detail is missing for them. Worth backfilling if the Study or
Home work is ever reopened.

`reader-header`, `reader-header-v2`, `reader-header-v3`, `reader-motion-v3`,
`topic-sheet`, `plan-lifecycle`, `home-full`, `home-fixes`, `home-panel-load`,
`weakest-alt`, `quiz-anchor`, `quiz-anchor-v2`, `c-details`, `row-affordance`.
