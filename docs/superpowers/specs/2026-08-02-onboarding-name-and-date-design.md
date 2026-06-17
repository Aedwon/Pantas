# Onboarding: the order, the name and the exam date

**Date:** 2 August 2026
**Status:** Approved by Aedwon, validated against live mockups in
`.superpowers/brainstorm/14027-1785616129/content/`
**Decision log:** `docs/superpowers/decisions/2026-08-02-onboarding-name-and-date-log.md`
**Amends:** `2026-07-26-home-and-navigation-design.md` Section 2,
`2026-05-16-onboarding-exam-selection-design.md`
**Depends on:** nothing. Everything here is buildable today.

---

## Problem

Home cannot render its masthead or its countdown, for anyone, because the app never asks
for the two fields they need. `UserSettings.examDate` and
`DriftSettingsRepository.updateExamDate` exist and validate, but **nothing in the app
writes to them**: onboarding never touches `examDate` and the Settings row is unwired.
There is no name field at all.

Onboarding is also ordered wrongly for what it is about to become. The Welcome screen
promises the exam picker in its own copy, and the picker is the last step, so the router
treats a saved exam as proof that onboarding is over.

## Scope

The order of the five onboarding steps, the copy on the two existing screens that the
reorder breaks, the two new screens, and the completion flag the reorder requires.

**Out of scope:** the 13 repairs in `2026-07-25-onboarding-polish.md`, which stand
unchanged and which this spec is designed to be folded into. Under-13 support, recorded
at `docs/future/2026-08-02-parent-child-pairing-and-consent.md`.

---

## Section 1: The order

**Welcome, age gate, exam picker, exam date, name.**

The age gate moves to the front. It was proposed last, on the reasonable grounds that
friction belongs away from the opening, and reversed for one reason: the gate must stand
in front of the only personal field. A 12-year-old would otherwise type a name, the app
would store it, and only then discover it was not allowed to ask. `docs/PRIVACY.md`
Section 8 publishes the opposite promise.

The exam and the exam date are preferences and carry no such problem. The name is the one
that does, and it is now last.

**Both new steps are skippable.** Neither blocks the flow and neither is required for the
app to function.

---

## Section 2: Welcome, recopied

The shipped screen reads "Build your study plan" over "Pick your exam, we'll guide what
to study first", which promises the picker outright. It also carries an em dash, the one
character banned by name in `AGENTS.md`.

> **Welcome to Pantas**
> Your reviewer for Philippine exams. We'll ask a few quick questions to set you up.
>
> [ Get started ]

**"Philippine exams", not "entrance exams".** The app already ships CSE, which is an
eligibility exam, and the roadmap holds NMAT, licensure exams and the LTO written exam.
The phrase never needs rewriting as that list grows, which is the property being bought.

**"A few", not a count.** An earlier draft read "Four quick questions", which was true of
the main path and false on the custom track branch, where it is six.
`2026-08-02-custom-exam-track-design.md` adds that branch. No duration is stated either,
because a duration would be a figure the app invented.

Layout is unchanged: `displaySmall` headline, `bodyLarge` `inkMuted` subline, one primary
`BoardButton`, the existing `Spacer` above and below.

---

## Section 3: The age gate, recopied and reshaped

Copy gains one line under the existing question. Headline and question are unchanged.

> **Quick check**
> When were you born?
> We need your age to follow the rules for apps like this. We'll only keep the year, not
> your full birthday.
>
> [ wheel ]
> [ Continue ]

The second sentence answers the question a child actually has, which is what the app is
doing with the answer. A version leading with keeping Pantas "safe for your age" was
drawn and cut: it sounds protective while saying nothing, and the real reason is rules.

**This line stays flat on purpose.** It is a legal notice addressed to a child. Every
other string in the app leads with what Pantas will do next; making this one inspiring
would be manipulative.

### The blocked state becomes a fork, not a wall

Today `_buildBlocked` is a dead end with one button back to the wheel. It becomes a
branch with a named destination, even though that destination currently says only that
Pantas is not available yet.

**This is free now and expensive later.** Under-13 support is a compliance project, not a
setting, and when it arrives it fills in a branch rather than reopening the flow. The
reasoning and the proposed consent mechanism are at
`docs/future/2026-08-02-parent-child-pairing-and-consent.md`.

**13+ and Philippines-only stand for launch.**

### Accepting the Terms and the Privacy Policy

**A passive line beneath the Welcome button**, both documents tappable:

> By continuing, you agree to our **Terms** and **Privacy Policy**.

**The acceptance is recorded when the student clears the age gate**, not on Welcome.
Welcome sits before the gate, so acceptance taken there is taken from someone the app has
not yet established can give it, which is the same ordering problem that moved the name
step to the end.

**Stored with the policy version, not only a timestamp.** Two account preference keys:
`settings.policy_accepted_at` and `settings.policy_version`. The version is what allows a
later release to re-prompt only the students who accepted an older document, which will be
needed the first time the policy changes. A timestamp alone cannot answer that question.

**Analytics consent stays separate**, in the existing `helpImproveApp` preference.
Bundling it into a blanket acceptance is the specific pattern regulators object to, and
it is already correctly separated today.

**Blocked on content, not on code.** `docs/PRIVACY.md` is headed "DRAFT v0, not yet
legally reviewed. Not for publication." The screens can be built against it, but the links
cannot ship until there is something to link to.

---

## Section 4: The exam date

The fourth step. Skippable.

> **When is your exam?**
> We'll count down the days on your home screen.
>
> [ day | month | year wheels ]
>
> [ Continue ]
> I don't know yet

### The control

**Three inline wheels**, day, month and year, in the same family as the age gate two
screens earlier. A native `showDatePicker` was drawn and rejected: it brings a 28px
radius, a drop shadow and a raised surface, three devices banned by name, and it is the
only screen in the flow that would cover itself with a dialog.

**The day column carries a dash above 1.** Resting on the dash means the day is unset.
This was Aedwon's addition and it is better than either option originally drawn, because
it turns a ceiling on the whole control into a state inside it.

So the screen offers **three honest answers**:

| Answer | How it is given | Stored |
|---|---|---|
| An exact date | all three wheels set | `2026-10-12`, precision `day` |
| A month, no day | day resting on the dash | `2026-10-01`, precision `month` |
| Nothing | "I don't know yet" | nothing written |

The existing `updateExamDate` refuses anything earlier than tomorrow, so the wheels must
not offer a past date. At month precision the check is against the month, not the 1st,
so the current month remains selectable while it still has days left in it.

**"I don't know yet", not "Skip".** Most students have genuinely not been given a date.
It is a true answer rather than a refusal. It sits beneath the primary button as a board
text action, the slot "Discard this session" occupies on the Quiz tab.

### Precision is carried by the type, not by a flag beside it

`UserSettings.examDate` stops being a `DateTime?`. It becomes a small value type carrying
its own precision, so **a caller physically cannot read a day off a month-precision
value**.

A boolean beside the date would work exactly until the first reader forgets to check it,
and the failure is silent and prints a wrong number to a student. A type that refuses to
hand over a day cannot fail that way.

Storage stays two account preference keys:

- `settings.exam_date`, `YYYY-MM-DD`, with the 1st written when only a month is known.
- `settings.exam_date_precision`, holding `day` or `month`. Absent means no date.

### What Home may print

**This is the evidentiary rule, not a copy preference.**

| Precision | Home's countdown line |
|---|---|
| `day` | "42 days to UPCAT" |
| `month` | "Your exam is in October 2026" |
| none | the exam short name alone |

A day count derived from a month is a figure produced by a measurement and an assumption,
which Section 1 of `2026-07-30-progress-tab-design.md` bans outright. The month state is
not a degraded countdown. It is the true statement available.

---

## Section 5: The name

The fifth and last step. Skippable.

> **What should we call you?**
> We'll use this to greet you across the app. A nickname is fine.
>
> [ ruled text field ]
>
> [ Done ]
> Skip

**"Across the app", not "on your home screen".** The name is read in two places: Home's
masthead and the "Your profile" heading of `2026-07-30-progress-tab-design.md`. The
countdown line in Section 4 keeps "on your home screen" because it is specified for Home
alone.

**A hairline-ruled field**, not a filled Material box: a 1px `rule` beneath the text, page
gutter to page gutter.

**No prefill from `AuthUser.displayName`.** The name is chosen, not assumed, and
signed-out users are the majority during onboarding. This is unchanged from the Home spec.

**"A nickname is fine" is doing work.** It tells the student this is not an identity
field, which is both true and the reason the field is safe to have at all.

**"Done", not "Continue"**, because nothing follows it.

Storage: one new account preference key, `settings.name`, and a matching field on
`UserSettings`. Empty and absent are the same state.

### The no-name state

Unchanged from the Home spec: an "Add your name" invitation in the masthead slot that
taps through to set it. Self-healing, no migration prompt, and it covers every existing
install as well as anyone who skips.

---

## Section 6: Onboarding gains a completion flag

**Required by the reorder.** `router.dart:63` reads
`if (passed && !needsSelection && atOnboarding)` and redirects to `/home`. The exam picker
writes `selectedExamId`, which clears `needsSelection`, so under the new order the
redirect fires on step 3 and **the date and name screens never render at all**.

- A new device preference, `onboarding_complete`, written by the last step on both
  "Done" and "Skip".
- The redirect waits on that flag instead of inferring completion from the exam
  selection.

**Device-scoped, not account-scoped**, matching `passed_age_gate` and `selected_exam_id`,
which are both device preferences today.

**This is worth having on its own terms.** Onboarding currently has no notion of being
finished, only of an exam being chosen, which is why a step could not be added after the
picker without breaking it.

---

## Section 7: Amendments to other specs

1. **`2026-07-26-home-and-navigation-design.md` Section 2.** Name and exam date were
   specified as two fields on **one** step after the picker, to avoid a fifth screen.
   They become **two steps**, and the picker is no longer the step they follow. Its
   countdown line gains the month-precision state in Section 4.
2. **`2026-05-16-onboarding-exam-selection-design.md`.** The flow is five steps, and the
   picker is third rather than last.
3. **`2026-07-25-onboarding-polish.md` Task 6**, which wires the Settings exam date row,
   must offer the same three answers as Section 4 or the two surfaces will disagree.
4. **`docs/PRIVACY.md` Section 8** is unchanged and remains accurate. The gate moves
   earlier in the flow, which strengthens it.

---

## Deferred, with reasons

- **Published exam dates as content.** The real answer to "when is your exam" is a list
  of the actual dates for the chosen exam, which would make the wheel unnecessary for
  most students. Pantas does not have that content, and inventing dates is out. Worth
  revisiting when blueprints are authored, since it is the same research trip.
- **Under-13 support**, at `docs/future/2026-08-02-parent-child-pairing-and-consent.md`.
- **Prefilling the name from a signed-in account.** Rejected above, and not worth
  revisiting unless sign-in moves before onboarding.

## Open

1. **Whether the exam date step should offer the month of a known exam season.** UPCAT
   and USTET run in predictable windows. Naming one would be helpful and would also be a
   figure the app asserted, so it stays shut until the dates are content.

## Verification

- Onboarding renders five steps in the order in Section 1.
- The exam picker no longer ends onboarding; the name step does.
- A month-precision date never produces a day count anywhere in the app.
- No em dash survives in any onboarding string.
