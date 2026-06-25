# Mock exam screens decision log

The round on the five mock surfaces the 28 July spec left undesigned. Chronological.
Later entries append; they never edit earlier ones.

---

## 4 August 2026: which of the five actually need drawing

**The round was told to answer this before drawing anything**, because the 28 July spec was
once treated as more open than it was and a round was lost to it. Checked against what already
exists rather than against the May sketches alone.

| Surface | Verdict | Why |
|---|---|---|
| **Mock history** | **Do not build** | Progress's "Your record" already carries a "Your mocks" panel, and that screen is already wholly Free and already about whether the student is improving. A separate history page is a second copy of it. The May sketch also wanted an emoji trend pill, and emoji are banned. |
| **Setup screen** | **Confirm, plus a copy pass** | The May sketch is already this app's shape: a heading, a short list of facts, one button. Two things changed under it: sectional timing is real now, so "sections at a glance" has content, and the existing copy uses banned punctuation. |
| **Strict forfeit** | **Mostly confirm** | What happens after a forfeit is already designed in the 28 July results screen. Only the moment itself was open. |
| **Section transition** | **Draw** | The only properly blank surface, and the one most likely to make a student feel cheated if handled badly. |
| **Warning overlays** | **Draw** | The May sketch uses a snackbar and a colored banner, and banners are not a device this app uses. Sectional timing also changes the meaning: five minutes left in this part is a different message from five minutes left in the paper. |

**So the round is two screens, one small pause state, a copy pass, and one thing struck**, not
five missing screens.

---

## 4 August 2026: strict mode decides whether a part can be ended early

### What was put to him on the plate

The section transition was drawn in two states: time called on the student, and the student
finishing early and asking to move on. **The open question was whether ending a part early
should be allowed at all.**

| Option | Cost |
|---|---|
| Allow it, forfeiting the unused minutes | Not what a real exam does. Removes dead time. |
| Forbid it, the part runs its clock | Matches the real exam exactly. A student who finishes with eight minutes left stares at a finished paper. |

**I recommended allowing it**, on the grounds that enforced waiting teaches nothing.

### What he decided, and it is better than either option

> "if in strict mode (remember this in Settings? i've mentioned this before somewhere) don't
> let them skip. and say so in the settings and the interface that they can't skip because
> they've enabled strict mode.
>
> if they don't have strict mode, then they can skip"

**Strict mode already exists** as a synced setting, and today it does exactly one thing: it
gates pause. **He is extending it to gate early advance as well**, which turns a single-purpose
toggle into a coherent promise: strict mode means the app behaves like the real room.

**Both my options were a single global rule. His is a rule the student already opted into**, so
neither group is patronised: whoever wants the real thing gets the real thing, and whoever does
not is not made to wait.

### What it obliges, and he named it himself

**It has to be said in two places, not one.** A restriction the student meets only when they hit
it is a bug from their side of the screen.

1. **In Settings**, where the toggle currently promises only that leaving the app submits the
   paper. That copy is now incomplete.
2. **In the paper**, at the moment the student would otherwise have moved on.

### Consequences recorded

- **With strict mode on, the early-finish confirmation does not exist.** Only the time-called
  transition remains.
- **The setup screen must state it before the paper starts**, alongside the sectional timing
  rule it already states.
- **The Settings row copy is now wrong by omission** and needs amending wherever that row is
  specified. It is not this spec's file, so it is an amendment rather than an edit here.

---

## 4 August 2026: two drawing faults he caught, in a row

**First.** The paper screen was drawn with three controls in the bottom bar when the spec names
five. The grid glyph and the flag were missing, and the app bar with its clock was left off the
screen entirely.

> "on the 3rd screen, i noticed you didn't add the other icons in the bottom navbar, there
> should be the flagging system and also the question grid. check the specs. is this intentional
> or did you make a mistake?"

**A mistake, not a choice.** All of it was already written down in Section 3 of the mock UI
spec, including the glyph's exact geometry, the 46px targets, and the optical correction that
gives the grid side five extra pixels of gap.

**Second, immediately after.**

> "actually make that all screens, you're just showing me part of the whole"

**Also right.** Every plate in this round had been a cropped fragment sized to its content, so
he was judging compositions without seeing where anything actually sat on a phone. A bar pinned
14px from the bottom means nothing when the device stops 40px below the content.

### What changed

All six surfaces are now drawn as complete 360 by 700 devices: Settings, setup, the paper mid
part, the paper at a part boundary, the early-finish confirmation, and the transition. Nothing
cropped, nothing omitted.

### The lesson, which is the same one as three times earlier today

**I drew from what I was thinking about rather than from what was written and from what a phone
actually is.** The bar's five controls were in the spec I had read an hour before. The cure both
times was to render the whole thing at real size instead of the part I was reasoning about.

**His standing instruction, now recorded so it binds every future plate:** *"render everything
down to the detail and how it would look as in a whole screen so i can see."*

---

## 4 August 2026: the time warnings, and the proctor he added

### The three options put to him

| Option | Cost |
|---|---|
| **A. A rule under the clock**, retreating the whole part, sharpening at five minutes and turning amber at one | Ambient, so no warning event ever arrives. Costs one hairline and the mock's only use of amber. |
| B. The same rule on the floating bar, his first suggestion | Competes with five controls for one glance, and sits furthest from where time is read. |
| C. Only the clock changes color | Nothing new drawn. Easiest to miss. |

**He chose A**, and then added something better than any of them.

### The proctor

> "but actually what i had in mind was a sort of toast notification (temporary, appears only a
> few seconds). what happens in real exams is that a proctor usually writes and rewrites how
> many minutes left there are (usually in multiples of 10 or 5 minutes) so i thought we could
> emulate something like that through a toast notification and a triple vibration or something
> (is that possible to spec?)"

**The insight is that a wall clock and a proctor are two different things, and the room has
both.** My ambient rule is the clock: always there, never speaks. His toast is the proctor:
silent for minutes, then says one thing. **They are not alternatives and the paper should have
both**, which is why A survives unchanged underneath it.

### What the check turned up

- **The app already floats a transient message**, in the practice quiz after each answer. So a
  toast is not a new device here. **But that one wears default system chrome**, a dark rounded
  slab belonging to no design at all. The proctor is drawn instead as the floating bar's
  sibling: same border, same radius, same shadow, sitting directly above it.
- **No haptic exists anywhere in the app yet**, so this sets a precedent.

### Answering his question directly: yes, it can be specced

- Flutter carries haptics in the framework, so **no new dependency**.
- **Three medium taps 60ms apart**, deliberately not one long buzz: a rhythm reads as a signal,
  a buzz reads as a notification.
- **It respects the phone rather than a setting of ours.** With system haptics off it is a
  silent no-op, so nothing is added to Settings and nothing has to be discovered.

**Two limits stated rather than hidden.** It is the app's first haptic, and a phone on a hard
desk buzzes audibly, which in a shared room is the opposite of unintrusive.

### Left open at the end of the round

- **The cadence.** 30, 20, 10, 5 and 1 mirrors a proctor and calls a 45 minute part five times.
  The quiet alternative is 10, 5 and 1.
- **The wording.** "20 minutes left in this part." names the part because the paper has four.
  A proctor would say "twenty minutes remaining", which reads better but risks being taken for
  the whole paper.

### Two corrections he made in the same round

1. **I had put the words "previous" and "next" beside the chevrons.** Nothing specced them. They
   are now single glyphs in their 46px targets.
2. **The closing screen's typography was wrong.** The figure and its label sat on separate lines,
   leaving a hole under the numeral, and the blank and flagged counts were dressed as serif
   headings when they are footnotes to the figure. Rebuilt: "28 of 30 answered" on one baseline,
   and the two counts demoted to a single quiet line.

### Settled, same round

> "20 10 5 1, then instead of 'in this part' use 'in this subject'"

**The 30 is dropped**, so every subject is called four times: 20, 10, 5 and 1 minutes. A subject
shorter than 20 minutes skips the first and is called three times. Four calls across a 45 minute
subject is ten seconds of screen time in total.

**"Part" becomes "subject" in the toast**, because that is the word a student actually uses for
Mathematics or Science.

### What the word change exposes, raised rather than quietly absorbed

**The rest of the mock says "part" everywhere.** "Part 1, Reading Comprehension" above every
question, "This paper runs part by part", "Part 1 is closed", "Start Part 2". With the toast
saying subject, **a student meets two names for one thing.**

**Recommended: change it everywhere**, so the paper reads "Mathematics, 45 minutes", "this
paper runs subject by subject", "Mathematics is closed", "Start Science". That also drops the
numbering, which was never earning its place: a student knows what Science is without being told
it is the third one.

**"Part" may survive in the blueprint**, which is content rather than copy and which no student
ever sees. Awaiting his call.

---

## 4 August 2026: "part" stays everywhere except the toast

I recommended unifying the vocabulary onto "subject". **He kept "part" everywhere and gave
"subject" only to the toast.**

> "keep part everywhere except the toast"

**The reading that makes it coherent, and it is better than a compromise:** "part" is the app's
**structural label** and "subject" is the **proctor's spoken word**. The line above each question
names the container; the proctor names what is inside it. Two registers doing two jobs.

**The cost stands and is recorded:** a student does meet two words for one thing. Written into
the spec so a later reader does not take it for an oversight and tidy it away.

---

## 4 August 2026: there are no radio buttons, and I drew three screens with them

> "also i'm not sure if radio buttons are used in the multiple choice. check this"

**He was right and the component says so plainly.** The answer device is a **serif choice letter
in a 22px column**, and the chosen row **fills with board tint and takes a board border at
radius 5**. There is no circle, no dot and no radio anywhere in this app.

**Three separate faults in what I drew:**

1. **Radio buttons that do not exist.** Invented wholesale.
2. **The letter repeated inside the text**, "A. 10" beside a dot, when the component already owns
   the letter and the text is just "10".
3. **I wrote in my own notes that there is no green on the paper.** There is: the chosen answer
   row is exactly where board green lives during a mock, and it was in the component the whole
   time.

**Corrected in `mock-answer-rows-corrected.html`.**

### The pattern, now five for five in two features

Every single one of today's drawing faults came from **rendering what I was picturing rather
than reading what was already written**: an old spec's vocabulary taken for the state of the
tree, scheduled mocks nothing schedules, invented weekdays, a bar missing two of its five
controls, and now an answer device that does not exist. **Each check took under a minute.**

**The rule that follows, and it belongs above the drawing rule already recorded: open the
component before drawing the component.** Not the spec that describes it, the file.

---

## 4 August 2026: the pause screen, and where pause lives

### The decision I would not make for him

**Pause had nowhere to live.** The spec put the clock **alone** in the app bar so it could never
be hunted for, and the floating bar already carries five controls. Three options were drawn:

| Option | Cost |
|---|---|
| **A. Trailing edge of the app bar** | Costs a one line amendment to "alone". The clock stays centred and unmissable, which was the actual intent. |
| B. Inside the question grid | Keeps the app bar literally clock-only, but pause is not navigation and two taps deep punishes whoever needs it most. |
| C. Tap the clock itself | Nothing new drawn and semantically neat. Undiscoverable, and a mis-tap on the element you stare at constantly is a bad failure. |

**He chose A.**

> "placement makes sense to me. keep it at the top right"

**The amendment is written into Section 3 rather than hidden**, including what "alone" was
protecting and why a trailing control does not damage it. The pause control is **absent
entirely in strict mode**, so in that mode the app bar really is clock-only.

### The design decision inside the screen

**Pausing replaces the paper completely**, which is why it is a screen and not an overlay. If
the question stayed visible behind a stopped clock, **pause would be a way to buy unlimited time
to read it**, which is precisely what a real exam has no pause in order to prevent.

It shows time left rather than elapsed, plus the answered and flagged counts so pausing doubles
as a place to see where they stand. No score, no correctness. Resume is the only green thing;
discard is rust text with no fill.

**The warning fires once per paper.** Every pause after the first goes straight through.

### A third drawing fault, caught by opening the component first

**The dialog component puts both actions side by side**, quiet left and committing right, and
carries **two confirm styles**: board green for an ordinary commitment, rust for a destructive
one. I had stacked them on two earlier plates and used green throughout.

**So ending a part early confirms in rust**, not green: it destroys the remaining time and
closes the part for good. Section 8.3's dialog was corrected.

**This is the first time today that opening the component before drawing caught the fault
before he did**, which is the rule recorded in the previous entry working as intended.

### The round is closed

All five surfaces the 28 July spec left undesigned are settled or struck. The only thing still
open in the mock spec is `sectionalTiming` for ACET, DCAT and MSU-SASE, which is Aedwon's to
establish and blocks three blueprints.

---

## 4 August 2026: the sectional timings, supplied

He closed the last open item in the mock spec.

**ACET, sectional.** Mathematics 60 items in 60 minutes, English Proficiency 75 in 50, Aptitude
and Abstract Reasoning 135 at roughly one minute per five items.

**DCAT, sectional.** Mental Ability 40 in 40, Reading Comprehension 25 in 30, Writing Skills 40
in 30, General Mathematics 45 in 50, Statistics and Probability 45 in 50, Science 50 in 30.

**MSU-SASE, not sectional.** 150 items across four subtests in one 3 hour block, so
`sectionalTiming` is false and the paper is roamable like CSE.

### Two caveats recorded rather than smoothed over

1. **ACET's aptitude time is derived, not given.** He supplied a rate; 135 items at one minute
   per five is 27 minutes, which implies about 12 seconds an item. **That is arithmetic on his
   figure, not a published total**, and it is fast even for abstract reasoning.
2. **MSU-SASE came with "apparently".** The least certain of the three.

**Both matter because the setup screen prints these to a student before they commit hours.** A
wrong duration is not cosmetic. Both are now the only entries in the spec's Open list, and both
are blocking for their own blueprint only.

---

## 4 August 2026: the plan

Written as **Mock 03**, a third plan beside the two that already exist. Mock 01 owns the
blueprint fields, setup screen, grid and floating bar; Mock 02 owns the endings; neither covers
anything settled in this round, because both predate it.

Six tasks: the part clock as pure arithmetic, the clock rule, the proctor with its haptic, the
transition screen, the pause screen with strict mode removing it, and ending a part early.

**Three prerequisites are named as stop conditions**, including the type tokens that still do
not exist in the kit and which now block three separate plans.
