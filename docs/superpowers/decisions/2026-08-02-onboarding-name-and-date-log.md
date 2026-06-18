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

---

## 8. Students whose exam is not on the list

**He raised it, unprompted, after the spec was written:** *"i forgot to mention, what if
they're not studying for a particular exam within our list (like say CETs of other
colleges). what's your take on this? mine personally we let them select the subtopics to
be included from the whole corpus of the app. they can also name this themselves."*

**I argued against subtopic selection and lost part of it, correctly.** My three
objections: the student does not know which subtopics their CET covers, and asking them
is asking them to write the syllabus; a custom track has no blueprint so it can have no
mock; and "choose exactly what you study" is attractive enough that UPCAT students would
pick it and land in a worse product. I also noted the Quiz tab picker already is this
control, and its own spec cut a second entrance to it.

**He wanted it designed now rather than deferred**, for a reason I had not weighed:
*"the market for CETs is very ripe and huge. I'm seeing FB groups with over 500k members
and I'm salivating thinking of penetrating that market"*.

**What that changed on my side.** The market argument actually points away from a generic
bucket and toward authoring those CETs properly, because "Pantas has PUP CET" is a post
in that group and "assemble your own reviewer" is not. Which makes the **naming field the
demand queue**: four thousand students typing "PUP CET" is a ranked build order measured
from real users. The custom track is the funnel, not the destination.

**Granularity, put to him.** A: whole corpus, no choice. B: subjects, four or five
checkboxes. C: topics or subtopics, his original. **Costs:** A wastes a student's time on
a subject their exam does not cover; B is slightly wrong at the edges since two CETs may
not mean the same thing by "Science"; C asks the student to write the syllabus and
duplicates the Quiz picker.

**He chose B with an escape hatch**, and stated the principle behind it: *"okay B but can
we also just give them the option to select subtopics and lessons if they really want to?
i think i'm applying a principle here that a user will dig into the app settings if they
want to"*. Correct, and it resolves the objection rather than dodging it: onboarding asks
what they can answer, Settings holds what they might grow into.

**One rule I set and he did not have to be talked into:** narrowing filters, it never
purges. If unticking a subject destroyed progress the setting is a trap and nobody touches
it twice.

**Free and uncapped**, his call, one word: *"free, uncapped"*.

---

## 9. The mock, where I was too restrictive

**I said a custom track can never have a mock.** He pushed: *"as for the mock exams,
aren't the content derived from the selected subjects/topics?"*

**He was half right and it changed my answer.** The questions are sampled from the
subjects and that works today. The structure is what is missing: items and minutes per
section, sectional timing, penalties. That is the blueprint and it is published content.

**But the student may supply the structure themselves.** The evidentiary rule bans figures
*Pantas* inferred, not facts the student gave us. The exam date is their assertion, the
track name is their assertion, and numbers off their school's handout are the same kind of
thing. So the panel says "set one up" rather than "not available", and the mock carries no
readiness verdict.

**A hole found only by drawing it.** Screen 4 of `custom-mock-flow.html` was the first
place the cooldown was rendered for a custom track, and its absence was obvious on sight:
without it, a Free user ticks every subject, names the track anything, and farms unlimited
mocks. The 14-day rule therefore applies unchanged. Invisible in prose, obvious in a
drawing, which is the argument for drawing panels rather than describing them.

**Over-limit numbers:** cap silently, refuse at setup, or run short and confess on the
results screen. **He took the recommendation, refuse at setup**, because the number is
wrong the moment it is typed.

---

## 10. The copy was bad, and the fault was systemic

**He rejected two lines hard:** *"remove the uninspiring copy. i hate the \"Tell us\" but
where and how exactly? \"We can't look them up for you\" wow this is garbage and demeaning
and condescending. I expect better copy than that. BE INSPIRING!"*

**He was right, and it was not two lines.** Nearly every string I had written led with
what Pantas could not do. His own Quiz spec says warmth comes from what the app promises
to do next, and I had written the inverse of that rule throughout.

**"Tell us your exam and we'll look at adding it" was cut outright**, and nothing replaced
it. His question killed it: there is no where and no how, and there does not need to be,
because the name they typed is already the signal. Asking for something already taken is
worse than not asking.

**He then rewrote two lines himself and named them as the register he wants:**

> "Two numbers off your school's handout, and we'll build the paper around them." ->
> "We'll build the mock exam based on the information you provide."
>
> "You'll sit the whole thing against the clock, the way you will on the day." ->
> "You'll be timed here, and you'll eventually get used to it especially on exam day."
>
> "these are my preferences for the tone and structure"

**The register, as I read it:** plain declarative sentences, "We'll" and "You'll", say
what happens and what the student gets, no metaphor and no compression. My instinct had
been toward evocative and clipped; his is toward plain and reassuring.

**Two corrections he accepted:** "based on the information you provide" fights his own
Grade-5 rule, so it became "based on what you tell us"; and the timing line put the
getting-used-to *on* exam day rather than before it, inverting the benefit, so it became
"you'll get used to it before exam day".

**One correction he made to mine:** *"on your home screen" -> "across the app"*, applied
to the name step, where it is true, since the name is read by Home's masthead and the
Progress tab's "Your profile" heading. The countdown keeps "on your home screen" because
it is specified for Home alone. Flagged to him rather than assumed.

**The age gate line stays flat on purpose**, and this is recorded so a later reader does
not "fix" it: it is a legal notice addressed to a child, and inspiring copy there would be
manipulative.

---

## 11. The setup pickers, and a claim of mine that was wrong

**He caught an omission:** *"you didn't show me what the pickers would look like for the
questions, time, and section breakdowns."* Correct. The spec said "two ruled rows, each
opening a wheel" and never drew what they opened.

**Settled from `mock-setup-pickers.html`:** bottom sheets with a 1px rule along the top,
square corners, no shadow. Questions is one column, 10 upward in fives, because no
published paper is 117 items long. Time is **one** column of durations rather than hours
beside minutes, since two columns for a single quantity means two gestures to say "two
hours". A section is **two** labelled columns, because there the two numbers are genuinely
two quantities.

**Found only by drawing it:** once sections exist there are two sources of truth. A
student sets 120 at the top, enters sections adding to 100, and nothing can say which is
the paper. **The sections win and the top rows become their sum**, uneditable. Not
previously specified.

### The claim I got wrong

**I told him the mock viewer "has never been designed".** He pushed back: *"can't you just
reuse the same UI for every mock exam regardless of the exam selected? isn't that what
should be ideal for this case? i don't understand the issue here since (1) they've selected
the subjects and (2) from there the mock can just pull questions. the quiz also works the
same way regardless of the exam selected?"*

**He is right on both counts.** `MockSampler.sample` takes `sections` and `poolsByTopic`
and does not care where the sections came from, so a student-authored blueprint feeds the
same sampler, session page and results screen. There is no custom-specific viewer work at
all. And `mock_session_page.dart` **exists and is built**; what is true is narrower, that
`/mock-exam` is a `_Stub` at `router.dart:233`, `MockSetupPage` has no callers and
`content_mock_blueprints` has zero rows. Wiring and content, not a missing screen. I
checked the code only after he objected, which is the wrong order.

**A consequence that follows, and is now in the spec.** A custom blueprint is stored
locally and never touches `assets/seed/content.db`, the piece that is broken. **The custom
mock may be the first mock in Pantas that can actually run**, which makes it a way to
exercise the whole mock path before content delivery is fixed.

**Two UI notes from him, both adopted:** the over-limit message links to Settings rather
than only stating the fault, and the setup screen needs its app bar and back chevron,
which I had never drawn.

---

## 12. The questions ceiling

**He asked to see it:** *"i don't understand the ceiling, show me through the visual
companion"*. Plate: `questions-ceiling-options.html`. One situation drawn three ways, a
student whose exam is really 150 items having ticked only Science, which holds 60.

- **A. Cap the wheel at 60.** **Cost:** it is the only option that throws the student's
  true answer away. They know their exam is 150 items, the app has nowhere to put that,
  and Pantas never learns it either.
- **B. Accept 150, run 60, confess on the results screen.** **Cost:** a mock sells
  fidelity, and this sells it, delivers a shorter paper, and says so only after they have
  sat the whole thing.
- **C. Keep 150 on screen in rust, kill Save, link to Settings.** **Cost:** they cannot
  start any mock until they widen, not even a short one.

**I had recommended A in the terminal and reversed it while drawing.** A discards exactly
the demand signal that makes the naming field valuable, which was invisible to me until
the three sat side by side. **Revised recommendation: C.** Its cost was serious before the
Settings link existed; with one tap to the fix it is small.

**He chose C.** Verbatim: *"okay go with C"*.

**Also closed here:** *"custom should of course take the assessment"*.
`AssessmentQuestionSelector` budgets across contributing topics, so a narrowed corpus
yields fewer contributing topics and a shorter assessment. The formula working as
designed, not a special case. The spec's Open section is now empty.

**Named as the next topic, not yet designed:** *"actually after this i want to tackle exam
data migration (a lot of DOST Scholarship takers also take UPCAT and others)"*. Note that
this is not exam switching. It is two overlapping exams sharing a question corpus, and it
will pull on the custom track designed above.

---

## 13. Accepting the Terms and Privacy Policy

**He raised it:** *"shouldn't there be a checkbox on users accepting Privacy Policy and
Terms of Use or something? i'm thinking maybe do that in the welcome screen before they
can proceed"*

**The Welcome screen is the wrong place, for the reason that moved the name step.**
Welcome sits before the age gate, so acceptance taken there is taken from someone the app
has not yet established can give it.

**Settled:** a passive line under the Welcome button with both documents tappable, and the
acceptance **recorded when the student clears the age gate**. Stored with the **policy
version** alongside the timestamp, so a later release can re-prompt only those who accepted
an older document. Analytics consent stays separate in `helpImproveApp`, since bundling it
is the specific pattern regulators object to.

**Blocked on content, not code:** `docs/PRIVACY.md` is "DRAFT v0, not for publication", so
there is nothing to link to yet.

### What I got wrong

**I told him to get a lawyer, twice.** He answered: *"as for the TOU and Privacy Policy
earlier, please don't expect me to get a lawyer for this. I'm a solo founder who's starting
with no capital"*.

Fair, and the advice was not useful where he actually is. Revised position, recorded so it
is not repeated: for a **13+, Philippines-only, no-ads, subscription app** that already
avoids location, contacts and advertising identifiers, a self-drafted policy is a
reasonable place to launch from. The point where that stops being true is **under-13**,
which is already deferred. Professional review is therefore a cost attached to PSHS-NCE,
not a gate on launch.

---

## 14. Exam switching

**Put to him as two different features hiding in one word.** A: switching, one exam at a
time in sequence. B: two live exams at once, two dates, two countdowns.

**He chose A**, with the reasoning that settles the shape: *"A, to keep their focus, and
to make sure when they take mock, they have that feeling of taking that actual exam"*. A
paper assembled from two blueprints is not any exam anyone sits.

**Established from the code before designing anything**, and it shrank the problem:
`review_state_local` is keyed by `questionId` with no exam column, so FSRS scheduling
already carries across exams untouched; and `Questions.examIdsJson` is a list, so a
question already belongs to DOST and UPCAT at once. **There is nothing to copy or move.**

**The carry-over fork.** Does an attempt made under DOST count toward UPCAT's figures?
**A** yes, when the question lists the new exam. **B** no, figures start clean per exam.
**C** yes but annotated. **Costs:** A shows history on day one of a "new" exam; B hides
what the app plainly knows; C spends a line of explanation on a crowded tab.

**My recommendation was A. He improved on it:** *"can we add a prompt (and the same in
Settings) if they want to migrate or not? some users might want, some users not, and some
users might change their minds after they switch and they didn't initially say to migrate.
make the copy inspiring and intuitive"*

**Reversibility changes what the feature is.** Nothing is copied, so the choice is a filter
over a query, instantly reversible and lossless. Which also kills the word: **"migrate"
never appears in the UI**. It is engineer-speak, and it sounds irreversible and dangerous.

**The rule that fell out of writing the copy:** the choice governs the **scoreboard, not
the schedule**. If "start fresh" reset FSRS the app would re-ask hundreds of questions the
student demonstrably knows, which nobody wants including the person who tapped it. The
prompt therefore states this outright rather than letting it be discovered, because it
produces a coherent but surprising state: Progress reporting zero while today's session
serves questions not due for months.

**Third statement of one rule.** Nothing is deleted on switch, nothing is deleted when a
subject is unticked, nothing is deleted when a flag is dropped. Written in the spec as a
single principle: **Pantas filters, it does not purge.**

**One exploit closed.** A switch must not reset the mock cooldown, or a Free user
alternates exams to farm papers. The Quiz spec's "one every 14 days per track" is
corrected to **per student**, since per track is the hole.

---

## 2 August 2026: three plans written for the custom track and exam switching

- `plans/2026-08-02-custom-track-a-branch-and-scope.md`, six tasks
- `plans/2026-08-02-custom-track-b-student-built-mock.md`, five tasks
- `plans/2026-08-02-exam-switching.md`, four tasks

**The custom track spec was split in two**, on the same reasoning that split Quiz seam 2.
Plan A ships alone and is the whole feature for a student who only wants to study: name the
track, tick the subjects, and every surface works. Plan B is the mock, which needs a setup
screen, three wheels, a corpus ceiling and a locally authored blueprint, and which is useless
before A exists.

### Three decisions the spec left open and the plans make

The spec settles the experience and says nothing about storage. These follow from the code
rather than from taste, and each is recorded with its alternative.

1. **A custom track is a row in `exams`, flagged `isCustom`.** `selected_exam_id`,
   `attempts_local.examId`, `assessment_results_local.examId`, `quiz_sessions.examId` and
   `mock_attempts.examId` all key on an exam id, so a parallel "track" concept would have to
   be threaded through every one of them and a flagged exam row through none. The picker
   lists `!isCustom`. `Seeder.maybeSeed` bails when any exam row exists and never deletes, so
   a custom row is safe from reseeding.
2. **Scope is an exclusion list, not an inclusion list.** A row means hidden, no rows means
   everything, which makes "narrowing filters, it never purges" literal. An inclusion list
   would have to be written in full for every listed exam at install and would silently empty
   a track when a content update added a topic nobody had ticked.
3. **A custom track's subjects are the corpus's**, because `Subjects.examId` references an
   exam and a custom row owns none. So `scopedTopicsProvider` answers "what is in my exam"
   for both kinds of track, and every feature-side call to `topicsByExam` moves to it. That
   also delivers Section 5's requirement that narrowing is available to a listed exam too.

**One cost accepted inside decision 3, and flagged rather than hidden:** shared subjects
appear under several exams with different topic ids, so a custom track collapses them by name
and takes the id holding the most questions. Two exams' "Algebra" may differ, and the proper
fix is a corpus-level topic identity, which is a content change rather than a code one.

### The exploit the switching plan closes

`mockAvailabilityProvider` calls `lastCooldownAttempt(userId, examId)`, so **the cooldown is
per exam today**. A Free user moves DOST to UPCAT and back for a fresh paper whenever they
want one. The Quiz spec's tier table says "one every 14 days per track" and the switching spec
corrects it to per student; the plan makes the change.

**Custom track Plan B names the same hole and deliberately does not fix it**, so it is fixed
once, in the plan that owns it.

### A correction carried into the plans

The custom track spec itself corrects an earlier claim from this session, that the mock viewer
was undesigned. It is built. What is true is narrower: `/mock-exam` is a `_Stub` route,
`MockSetupPage` has no callers, and `content_mock_blueprints` holds zero rows. Plan B follows
that through to a consequence worth having: **a custom track's blueprint never passes through
`assets/seed/content.db`, which is the broken piece, so the custom mock may be the first mock
in Pantas that can actually run.**
