# Onboarding: the name and exam date steps, decision log

Started 2 August 2026. Appended as we go. Later entries never edit earlier ones; when a
decision is reversed, the old entry stays and the new one says it reverses it.

---

## 1. Which onboarding work to do first

**Put to him.** Onboarding is two separate bodies of work and he had picked the topic
without picking the body.

- **A. Execute the 25 July polish plan.** 13 tasks, already written to the file: the two
  age-gate defects, the Settings exam switcher, the two dead Settings rows, the rename
  to Pantas, a rhythm pass, a doc reconciliation. **Cost:** it is repair, not design, and
  its Task 6 wires the Exam date Settings row, which is the same field B captures. Doing
  it first means reopening those files when B lands.
- **B. Design the name and exam date step** the Home spec requires. **Cost:** a design
  round and a plan before anything is built. Until it ships, `examDate` is null for
  every user and Home's countdown cannot render for anyone.

**My recommendation:** B first, then fold it into the 25 July plan so one execution pass
covers both.

**He chose B.** Verbatim: *"let's do the new screens"*.

**What I got wrong:** the first time I put this fork to him I wrote it in shorthand and
he could not act on it. Verbatim: *"i don't quite understand the options. can you word it
with more context and much simpler"*. The options had not changed; the wording had been
too compressed to decide from. Worth remembering: a fork is not presented until it is
presented in plain words.

---

## 2. The router will not allow a step after the exam picker

**Found in the code, not recalled.** `router.dart:63` redirects away from `/onboarding`
the instant an exam is selected. The Home spec asks for the name and date step to land
after the picker, so the ask arrives once the student has invested. As written, that step
would be yanked off screen mid-render.

**Put to him.**

- **1. An "onboarding finished" flag.** A device preference the last step writes; the
  redirect waits for it. **Cost:** one new preference key and one line of router logic.
  Also fixes the fact that onboarding has no notion of being complete today, only of the
  exam being chosen.
- **2. Move the step before the picker.** **Cost:** free in code, but contradicts the
  Home spec's reasoning, and asks a stranger their name before they have chosen anything.
- **3. Hold the exam choice in memory** and write it only at the end. **Cost:** no new
  key, but the picker stops saving as you tap, so closing the app on the last screen
  loses the exam already picked.

**My recommendation:** option 1.

**Not answered directly.** He asked to see the existing screens first. Verbatim: *"can
you show me with a visual companion first? show me all the existing screens. then i'll
let you know my decision"*. The question is superseded by entry 4, which reorders the
flow such that nothing sits after the picker at all.

---

## 3. The age gate, and whether it is necessary

**He asked, unprompted:** *"also question, is this necessary? this is an educational app
after all. isn't the play store/app store rating enough? because i also plan to expand to
PSHS-NCE and of course those are Grade 6 students."*

**Answered: no, the store rating is not enough.** A store age rating describes whether
the content is suitable. It grants nothing about collecting personal data from a child.
Pantas collects a name, sends analytics and syncs to Firebase, so it is in the
data-collection question, not the content one. `docs/PRIVACY.md` Section 8 already
publishes "not directed to children under 13" and names the birth-year gate as the
mechanism, so the gate is load-bearing for a published commitment.

**PSHS-NCE breaks that position outright.** Grade 6 students are 11 and 12.

**Settled for launch:** keep the 13+ gate, stay Philippines-only, and treat under-13
support as its own project.

**Adopted at no cost:** build the age gate as a **fork with a named destination** rather
than a dead end, so the under-13 branch is a stub to fill in later rather than a wall to
tear down.

**His proposal for the under-13 route**, captured in full at
`docs/future/2026-08-02-parent-child-pairing-and-consent.md`: pair two devices by QR,
child's device scanned, parent's device scanning. **My assessment:** the QR is the right
tool for linking and is not consent, because proximity proves neither adulthood nor
guardianship. The gap closes with a real parent account plus the subscription purchase
as the verification, which Pantas already owns through RevenueCat. He agreed it is a
future spec: *"although I have to say, it can be a future spec. right now I don't have
the content for the pSHS-NCE but it is in my roadmap for this app"*.

---

## 4. The order of the steps

**His first proposal**, after seeing the existing screens:

> "- after welcome, it should be the exam picker immediately
> - then the date for the exam (add a skip button or idk button)
> - then the what should we call you (add a skip button here)
> - then the age picker."

So: Welcome, exam picker, exam date, name, age gate.

**I pushed back on the age gate being last.** A 12-year-old would type their name, the
app would store it, and only then would it discover it was not allowed to ask. That is
exactly what the gate exists to prevent and what the privacy policy promises does not
happen. The exam and the date are preferences and carry no such problem; the name is the
one that does.

**I proposed:** Welcome, exam picker, exam date, age gate, name. A compromise that kept
the friction off the front while putting the gate in front of the only personal field.

**He went further than the compromise and reversed his own first proposal.** Verbatim:

> "you're right that the age should be the first thing they enter to immediately filter
> out."

**Settled order:** **Welcome, age gate, exam picker, exam date, name.**

**Consequence, and it retires entry 2.** With the picker no longer last, nothing sits
after it, so the router redirect at `router.dart:63` is no longer in the way and the
"onboarding finished" flag is not needed for this reason. Whether it is still worth
having for its own sake is a separate question, not yet asked.

**Two things settled alongside the order:**

- **Both new steps are skippable.** He asked for a skip on the date and a skip on the
  name. On the date I proposed **"I don't know yet"** over "Skip", because most students
  genuinely have not been given a date, which makes it a true answer rather than a
  refusal. Not yet confirmed.
- **This splits the Home spec's single screen into two.** `2026-07-26-home-and-navigation-design.md`
  Section 2 put name and date on one step to avoid a fifth screen. He chose five. The
  Home spec needs an amendment noting it.

---

## 5. Welcome copy, and an explanation on the age gate

**He raised both**, having noticed the Welcome screen sets a false expectation now that
the picker is no longer next:

> "can we improve the copy of the Welcome screen then? I chose the exam picker after it
> because it's worded that way, so logically the user would think next screen is they
> pick an exam. maybe say something like Welcome to Pantas or something? then the age
> (add an explanation why we need to determine age, make it concise but intelligible for
> kids), then the exam, exam date, name"

**He is right, and the current copy is worse than he says.** The shipped Welcome reads
"Build your study plan" over "Pick your exam, we'll guide what to study first", which
promises the picker outright. It also contains an em dash, the one character banned by
name in `AGENTS.md`.

**Welcome, first round.** Three options: a bare greeting; a greeting plus what Pantas is;
a warmer "Let's get you set up". All three carried "Four quick questions", which is true
of the settled order: age, exam, date, name. He chose the second shape but rejected its
noun. Verbatim:

> "B but maybe not entrance exams only because there's CSE and after there will be NMAT,
> and soon other licensure exams, even LTO written exam is on my roadmap"

**What I got wrong:** I wrote "Philippine entrance exams" while the app already ships
CSE, which is an eligibility exam and not an entrance exam. The copy was wrong on the
day I proposed it, not merely wrong about the roadmap.

**Welcome, second round.** Three replacements for the noun phrase: "Philippine exams";
"entrance, eligibility and licensure exams"; "the exams you need to pass". **Costs:** the
first is vague; the second is a mouthful, is not Grade-5 simple, and still seats LTO
awkwardly under "licensure"; the third makes a bigger promise than a reviewer can keep.

**He chose the first.** Verbatim: *"A, then let's design the screens"*.

**Settled Welcome copy:**

> **Welcome to Pantas**
> Your reviewer for Philippine exams. Four quick questions first.
> [ Get started ]

It never needs rewriting as the roadmap grows, which is the property he was actually
asking for.

**Age gate explanation.** Three options: "Apps like this have age rules. We only keep the
year, not your full birthday."; a version leading with rules about who can use Pantas; a
version leading with keeping Pantas "safe for your age". **My recommendation and his
choice: the first.** The third was the weakest: "safe for your age" sounds protective but
is vague, and the real reason is rules, not safety.

**Settled age gate copy:**

> **Quick check**
> When were you born?
> Apps like this have age rules. We only keep the year, not your full birthday.

The em dash in the shipped Welcome copy dies with this change.

---

## 6. The router problem is not retired after all

**Correcting entry 4.** I wrote there that reordering the flow retired entry 2, on the
grounds that nothing sits after the exam picker any more. That is wrong. The settled
order puts **two** steps after the picker, the date and the name, where the old flow had
none.

`router.dart:63` reads `if (passed && !needsSelection && atOnboarding)` and redirects to
`/home`. The exam picker writes `selectedExamId`, which clears `needsSelection`, so the
redirect fires the moment the student taps Continue on step 3 and the date and name
screens never render at all.

**So entry 2's option 1 is required, and is now load-bearing for two screens rather than
one.** An explicit "onboarding finished" flag, written by the last step, with the
redirect waiting on it instead of inferring completion from the exam selection.

---

## 7. The exam date control

**He asked to decide this visually.** Verbatim: *"please let me see and choose with the
visual companion instead"*. Plate: `exam-date-control-options.html`, the same screen and
the same copy three times with three controls, plus the name screen so the flow's landing
point was visible rather than described.

- **A. Native `showDatePicker`.** A Material calendar modal. **Cost:** rounded 28px
  corners, a drop shadow and a raised surface, three devices banned by name in
  `AGENTS.md`, and it is the only screen in the flow that covers itself with a dialog.
  Drawn accurately on the plate for exactly that reason: it reads worse than it argues.
- **B. Month and year wheel.** Matches the age gate two screens earlier. **Cost:** the
  countdown reads to the month, so Home says "October 2026" rather than a number of days.
- **C. Day, month and year wheels.** Exact countdown, same wheel family as the age gate.
  **Cost:** three columns on a small screen, and it asks for a day many students have not
  been told.

**My recommendation was B. He chose C**, and immediately found the thing B was protecting
against. Verbatim:

> "i'll go with C but is there a way to disable the day if they don't know? or at least
> default to a blank day"

**He is right and this is better than either option I drew.** A dash above day 1 gives
the wheel three honest answers: an exact date, a month with no day, or "I don't know yet"
for nothing at all. B's compromise becomes a state inside C rather than a ceiling on the
whole control.

**The consequence, and it is the evidentiary rule.** At month precision Home may not
print a day countdown: "42 days" derived from a month is a figure built on an assumption
the app made, which Section 1 of the Progress spec bans outright. At month precision Home
names the month instead.

**Storage, settled:** not a raw `DateTime`. `UserSettings.examDate` becomes a small type
carrying its own precision, so a caller physically cannot read a day off a month-precision
value. A flag beside the date gets forgotten by a future reader; a type that refuses to
hand over a day cannot be. `settings.exam_date` keeps `YYYY-MM-DD` with the 1st written
when only a month is known, and a new `settings.exam_date_precision` holds `day` or
`month`.

**He approved.** Verbatim: *"proceed"*.

**Two surfaces this amends**, both recorded before the spec was written:

1. `2026-07-26-home-and-navigation-design.md` gains a month-precision countdown state
   alongside the no-date state it already has.
2. The Settings exam date row, wired by Task 6 of `2026-07-25-onboarding-polish.md`, must
   offer the same three answers or the two surfaces will disagree.
