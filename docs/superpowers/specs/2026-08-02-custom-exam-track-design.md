# The custom exam track, and the mock a student builds themselves

**Date:** 2 August 2026
**Status:** Approved by Aedwon, validated against live mockups in
`.superpowers/brainstorm/14027-1785616129/content/`
**Decision log:** `docs/superpowers/decisions/2026-08-02-onboarding-name-and-date-log.md`
**Amends:** `2026-08-02-onboarding-name-and-date-design.md`,
`2026-07-28-quiz-tab-design.md` Section 1, `2026-07-26-home-and-navigation-design.md`
**Depends on:** the onboarding spec above for the flow it branches out of

---

## Problem

Pantas serves six exams. A large number of students are sitting something else: the
entrance test of a college Pantas has never heard of, a board review, the LTO written
exam. Today the picker has no answer for them and the app is unusable.

The content is not the obstacle. Mathematics, Science, Language Proficiency, Reading
Comprehension and Reasoning are shared across nearly every exam Pantas targets, so a
student sitting an unlisted CET can study almost everything already authored. What is
missing is a way to say so.

## The strategic point, recorded because it shapes the design

The growth play is **adding those exams properly**, with blueprints. "Pantas has PUP CET"
is a post in a group with half a million members. "Pantas lets you assemble your own
reviewer" is not.

Which makes the naming field the most valuable part of this feature. **When four thousand
students name their track "PUP CET", that is a demand queue ranked by real users**, and
each exam promoted out of it converts those students to a better experience. The custom
track is the long tail and the funnel, not the destination.

**Nothing asks the student to submit their exam.** An earlier draft put "Tell us your
exam and we'll look at adding it" on the mock panel. It was cut: it promises an action
with no route, and the name they already typed is the signal. Asking for something
already taken is worse than not asking.

## Scope

The picker entry, the two branch screens, what the track scopes, the Settings screen that
edits it, the mock panel's state for a custom track, and the setup screen behind it.

**Out of scope:** the mock viewer itself, which remains its own design job. This spec
specifies the setup screen and the panel around it, not the paper.

---

## Section 1: Free, uncapped

A custom track is the only way an entire category of student can use Pantas at all.
Gating it would mean those students cannot try the app before paying, which contradicts
the positioning outright.

Pro sells what it sells everywhere else: the explanations, the interpretation, the
patterns. See Section 6 for the one place the tier line still bites.

---

## Section 2: The way in

The exam picker gains one row, **below a full-width 1px `rule`**, set apart from the exam
list:

> My exam isn't on this list                                              ›

**A chevron, not a selection state.** It opens a branch rather than choosing a row, and
it must not read as a seventh exam. It never participates in the picker's selection or
enables its Continue button.

---

## Section 3: The branch, two screens

**Two screens, not one.** A combined screen was drawn and rejected for a concrete reason:
tapping the name field raises the keyboard, which covers the subject list beneath it, so
the student types blind and only sees what they were meant to read after dismissing it.

### Screen one, the name

> **What are you studying for?**
> Give it a name you'll recognize. "PUP CET", "Nursing board".
>
> [ ruled text field ]
>
> [ Continue ]

Required. It is the track's identity everywhere the exam short name would otherwise
appear, and it is the demand signal.

### Screen two, the subjects

> **What does it cover?**
> Tick the subjects your exam covers. You can choose exact topics later in Settings.
>
> [ subject checkboxes ]
>
> [ Continue ]

**Subjects, not topics.** Four or five checkboxes, drawn from the corpus rather than from
any exam. This is the only level a student can answer honestly on day one, because it is
the level their school publishes: CETs are advertised by subject. Topic-level selection
was rejected here because it asks the student to write the syllabus, and because the Quiz
tab's picker already does it later and better, once they have an opinion.

**Every subject arrives ticked.** Doing nothing is a valid answer, which is what makes
the question cheap enough to ask during onboarding at all.

### Where the branch rejoins

Back into the main flow at the exam date step, then the name step. So the custom path is
six steps and the listed path is four. This is why the Welcome copy says "a few" rather
than a number.

---

## Section 4: What the track scopes, and the rule that makes it safe

The ticked subjects filter the corpus everywhere the selected exam would: today's
session, the Study map, the practice picker, and what Progress counts as coverage.

**Narrowing filters. It never purges.**

A student who unticks Science in March and ticks it again in June gets everything back:
their attempts, their FSRS state, their read lessons. Nothing is deleted at any point.

**This rule is load-bearing, not a nicety.** If narrowing destroyed progress the setting
becomes a trap, and nobody would touch it a second time. It is also the reason the
setting can be offered freely rather than hidden behind a warning.

---

## Section 5: Settings, "What's included"

> **What's included**
> Unticking something hides it. Nothing you've done is deleted.
>
> **Mathematics**
>   ☑ Algebra
>   ☑ Geometry
>   ☐ Trigonometry
> **Science**
>   ☑ Chemistry

**This is the Quiz tab picker's index**, from `2026-07-28-quiz-tab-design.md` Section 2:
subject headings, topic rows, hierarchical selection, the dash for partial. It must be
**lifted into `lib/core/ui/`** to be reused here, the same move Task 3 of the onboarding
polish plan makes for the exam row, and for the same layering reason: `features/settings/`
cannot import `features/quiz/`.

**Two objects, not one, and they must not be confused:**

| Object | Question | Lifetime | Where |
|---|---|---|---|
| Session scope | what do I practice right now | one session | the Quiz tab picker |
| Track scope | what is in my exam at all | until changed | this screen |

Available to every track, not only custom ones. A student sitting UPCAT who has already
passed one subject has the same reason to narrow.

---

## Section 6: The mock

### A custom track can have a mock, and the reason is the evidentiary rule

The questions are sampled from the ticked subjects, which works today. The **structure**
is what Pantas does not have: items per section, minutes per section, whether sections
are separately timed, whether wrong answers are penalised. That is the blueprint, and it
is published by the testing body. The Quiz spec states the principle: the exam's rules
are content, not code. It matters by a factor of three, since USTET runs at 22 seconds an
item and CSE at 67.

**But the student may supply the structure themselves.** The evidentiary rule bans
figures Pantas inferred, not facts the student gave us. The exam date is their assertion.
The track name is their assertion. Numbers read off their school's handout are the same
kind of thing.

So the custom mock is honest, and it carries no readiness verdict and no comparison
against a real paper's difficulty mix, because those still need something published.

### The panel, nothing set up

> **Mock exam**
> You can build your own mock exam. Tell us how many questions and how long it runs, and
> we'll set it up for you.
>
> [ Set one up ]

A secondary button. No cooldown count, because nothing has been taken.

### The setup screen

> **Set up your mock**
> We'll build the mock exam based on what you tell us.
>
> Questions                          120  ›
> Time                            2h 00m  ›
> ─────────────────────────────────────────
> I know the section breakdown            ›
>
> You'll be timed here, and you'll get used to it before exam day.
>
> [ Save ]

**Two ruled rows, each opening a wheel.** Not two inline wheels, which would fight for
one screen, and not typed fields, which invite nonsense and raise a keyboard over
everything. The rows match the Settings idiom already in the app.

**Without a breakdown it is one continuous paper**, sampled evenly across the ticked
subjects. `BlueprintSection._readWeights` already distributes evenly when weights are
absent, so this is the existing sampler doing what it already does.

**The breakdown is collapsed by default.** Opened, it gives one row per ticked subject
taking items and minutes, plus a single toggle for whether sections are timed separately.
Most students never open it. The ones who can fill it in have the handout in front of
them.

### When the numbers exceed the corpus

**Refuse at setup, and say why.** If the ticked subjects hold 60 questions and the
student asks for 200:

> You've picked subjects with 60 questions. Try 60 or fewer.

Capping silently was rejected: the student asked for 200 and would get 60 with no
explanation. Running short and confessing on the results screen was rejected too: they
find out after spending the time. The number is wrong the moment it is typed, and that is
the cheapest moment to say so. It also points at the fix, which is widening the subjects.

### The panel, once set up

> **Mock exam**                                                      13d 4h
> 120 questions, 2 hours. You set this up.
> ─────────────────────────────────────────
> **Free users** get one every two weeks. Your next one opens on **15 August**.
>
> Change the setup

Figures, states and the tier line otherwise follow `2026-07-28-quiz-tab-design.md`
Section 1 unchanged. "Change the setup" is a board text action, so the numbers are never
locked in.

### The tier rule applies unchanged, and this is not optional

**A custom mock is still a mock.** Same corpus, same sampler, same paper. If custom
tracks skipped the cooldown, any Free user could tick every subject, name the track
anything at all, and take unlimited mock exams. That is a hole straight through the Pro
proposition.

So the 14-day cooldown applies to custom tracks exactly as it applies to listed exams,
and the panel states it in every state.

---

## Section 7: Home, and everything else

**Home is unchanged.** The masthead greets by the student's name, the countdown counts to
the student's date, and both come from the same fields any other track uses. The track
name replaces the exam short name.

The countdown is the student's own assertion about their own exam, so it carries the same
standing as any other date they entered. Precision follows
`2026-08-02-onboarding-name-and-date-design.md` Section 4.

---

## Section 8: Amendments to other specs

1. **`2026-08-02-onboarding-name-and-date-design.md`.** The picker gains the branch row,
   the flow gains two conditional steps, and the Welcome copy says "a few" rather than a
   count.
2. **`2026-07-28-quiz-tab-design.md` Section 1.** The mock panel gains a fifth state, for
   a custom track with no mock set up, and a sixth for one that has been set up. Its
   picker index (Section 2) must be lifted into `lib/core/ui/` so Settings can reuse it.
3. **`2026-07-26-home-and-navigation-design.md`.** Where the exam short name is rendered,
   a custom track renders its name instead.
4. **Blueprints.** A custom track's blueprint is student-authored and carries a
   provenance of exactly that, distinct from the "student reports" provenance the
   Progress spec defines for crowdsourced figures about a real exam.

---

## Deferred, with reasons

- **The mock viewer for a custom paper.** The setup screen is specified here; the paper
  it produces is the mock viewer's job and that spec is unwritten.
- **The wrong-answer penalty.** A content attribute in the Quiz spec's deferred list.
  Most CETs do not penalise, and asking a student about it at setup buys little.
- **Promoting a custom track to a real exam.** When Pantas authors PUP CET properly,
  students already on a custom track named "PUP CET" should be offered the real one. The
  matching is fuzzy, the migration is not designed, and it is worth its own pass once the
  first promotion actually happens.

## Open

1. **Whether a custom track may take the assessment.** The assessment budgets questions
   across contributing topics and produces the starting point everything else is built
   on. It should work unchanged on a narrowed corpus, but it has not been checked against
   one.

## Verification

- The picker's branch row never enables the picker's Continue button.
- Unticking a subject hides its content and deletes nothing, verified by re-ticking.
- A custom mock is refused at setup when the requested count exceeds the corpus.
- A Free user on a custom track cannot take two mocks inside 14 days.
- No string in this spec leads with what Pantas cannot do.
