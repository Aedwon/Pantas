# Telemetry 02: the consent step, item analytics, and taps

**Plan, 11 August 2026.** Amends `2026-08-03-foundations-01-observability.md`,
which built eleven events and a consent gate. **It does not replace it**: the gate,
the facade and the error boundary all stand.

**Why this exists.** Aedwon asked for two things the earlier spec deliberately
excluded: which buttons get pressed, and how questions perform, including which
wrong answer was chosen. The second contradicts a property rule that was written
on purpose, so it is amended here in the open rather than widened quietly.

---

## What is true today, measured rather than remembered

- **All eleven events emit.** They reach nothing only because no Firebase project
  exists.
- **Consent defaults to false**, and the gate hands back a no-op implementation
  until a student turns it on. Nothing is sent before that.
- **There is no Terms acceptance anywhere.** The legal documents are readable from
  About and routable at `/legal/terms`, but **no step asks and no flag records it.**
  An earlier handoff listed Terms acceptance as merged. It is not.
- **Onboarding is five steps:** welcome, age gate, picker, exam date, name.
- **An answer becomes an outcome in exactly one place**,
  `submit_answer.dart`, which is why Task 2 is cheap.

---

## Global constraints

- **Never run `flutter test` with no arguments, `flutter analyze`, or
  `dart run build_runner`.** Run the single test file you are writing.
- **No em dashes. American spelling.**
- **One event name per kind of thing, never one per instance.** Analytics allows
  500 distinct names per project and they cannot be deleted. An event name with an
  id inside it is how that budget is destroyed.
- **Tasks 1 and 2 are for the beta. Task 3 is explicitly deferrable**, and the plan
  says so at the top of it.

---

## Task 1: The consent step, after the age gate

**Files:**
- Create: `lib/features/onboarding/presentation/onboarding_consent_step.dart`
- Modify: `lib/features/onboarding/presentation/onboarding_page.dart`
- Modify: `lib/features/settings/data/settings_repository.dart`
- Modify: `lib/features/settings/domain/user_settings.dart`
- Test: `test/features/onboarding/presentation/onboarding_consent_step_test.dart`

**Two ticks, and they are not the same kind of thing.**

| Tick | Required | Default | Blocks Continue |
|---|---|---|---|
| "I agree to the Terms of Service and Privacy Policy" | Yes | Off | **Yes** |
| "Help improve Pantas by sharing anonymous usage data" | **No** | **Off** | **No** |

**Why the second must not block, and must not start ticked.** Consent under RA
10173 has to be freely given and specific. **A pre-ticked box is not consent, and
consent that is a condition of using the app is not consent either.** If the
second tick gates Continue, or arrives already on, the legal basis for every event
collected afterwards is gone. This is the whole reason the two are separate rather
than one "I agree to everything".

**Why it comes after the age gate, not before.** Aedwon asked for the very first
screen. **Put it third instead**, immediately after the age gate: asking a
thirteen-year-old to accept terms and then blocking them for being under age
collects an agreement from someone who was never eligible to give one. Order
becomes: welcome, age gate, **consent**, picker, exam date, name.

**Both document titles are tappable** and open the existing legal routes,
`/legal/terms` and `/legal/privacy`. A student must be able to read what they are
agreeing to without leaving the flow and losing their place.

**Steps:**

- [ ] **Step 1: Write the failing test.** Assert: Continue is disabled until the
  terms tick is on; Continue is enabled with the terms tick alone; the usage tick
  starts off; turning the usage tick on writes the existing
  `settings.help_improve_app` value; leaving it off writes false; tapping either
  document title navigates.
- [ ] **Step 2: Run it and confirm it fails.**
- [ ] **Step 3: Add `acceptedTermsAt` to the settings repository and
  `UserSettings`**, a nullable timestamp. **A boolean is not enough**: the date of
  acceptance is what evidences consent when the terms later change.
- [ ] **Step 4: Build the step and insert it into the flow.**
- [ ] **Step 5: Run the file and commit.**

**Do not reuse the age gate's layout wholesale.** Read
`onboarding_age_gate_step.dart` first for the rhythm, then follow the components in
`lib/core/ui/components/`. No tinted callout panels; this project uses print
devices.

---

## Task 2: `question_answered`, which is item analytics and not a profile

**Files:**
- Modify: `lib/core/telemetry/telemetry.dart`
- Modify: `lib/features/quiz/domain/use_cases/submit_answer.dart`
- Test: `test/core/telemetry/question_answered_test.dart`

**The amendment, stated plainly.** The earlier spec forbade any event carrying "a
student's answer" or "a score". **That rule is narrowed, not deleted:**

**Now allowed**, because they describe the question rather than the person:

- `question_id`, the question's identifier
- `is_correct`, a bool
- `chosen_label`, the letter of the choice picked, from the closed set A to F
- `origin`, which mode the question was answered in

**Still forbidden, and still enforced by a throw:**

- Any question or answer **text**
- A student's **name, email or any free text**
- Any **aggregate score** for a student, their accuracy, their streak, their rank

**Why this line and not another.** "Sixty percent of students choose B on this
question" is a fact about a question, and it is the single most useful content
signal available: it finds the question with a misleading distractor, the one
nobody gets right because it is wrong, and the one everybody gets right because it
is trivial. **None of that requires knowing who anyone is**, and Analytics is
device-scoped rather than identity-scoped in any case. What stays banned is the
shape that builds a picture of a person.

**One call site.** An answer becomes an `AnswerOutcome` in exactly one place. Emit
there, so a new quiz mode cannot forget to.

**One event name**, `question_answered`, with the question id as a **parameter**.
Never `question_answered_q_math_001`.

**Steps:**

- [ ] **Step 1: Write the failing test.** Assert the event fires once per answer
  with the four properties; that a text property throws; and that **nothing is
  emitted when consent is off**, which is the gate doing its job and is worth
  asserting here rather than assuming.
- [ ] **Step 2: Run it and confirm it fails.**
- [ ] **Step 3: Widen `assertPropertiesAllowed` to permit the four**, and update
  its doc comment to state the new line, including what is still banned.
- [ ] **Step 4: Emit at the single call site.**
- [ ] **Step 5: Run the file and commit.**

---

## Task 3: `element_tapped`, and this one can wait

**Deferrable. If the beta is close, stop after Task 2 and say so.** Nothing else
depends on this, and `tab_opened` already answers the question this was reaching
for, which is which surfaces are dead.

**Files:**
- Modify: `lib/core/telemetry/telemetry.dart`
- Modify: between five and ten call sites, chosen as below
- Test: `test/core/telemetry/element_tapped_test.dart`

**One event, `element_tapped`, carrying `element_id` from a closed set.** Not one
event per button.

**Instrument these and nothing else**, because a tap event on every button is how
a 500-name budget and a reviewer's patience both go:

1. Start a quiz, from Home and from the Quiz tab, distinguished by `element_id`
2. Start a mock
3. The paywall's subscribe button
4. Open a lesson from the study map
5. The bookmark ribbon

**Steps:**

- [ ] **Step 1: Write the failing test** for the closed set and one call site.
- [ ] **Step 2: Run it and confirm it fails.**
- [ ] **Step 3: Add the event and the closed set.**
- [ ] **Step 4: Emit at the five sites.**
- [ ] **Step 5: Run the file and commit.**

---

## Done when

- A student cannot pass onboarding without accepting the terms, and **can** pass
  it without agreeing to usage data.
- The acceptance timestamp is stored.
- Every answered question emits one event carrying its id, correctness and the
  chosen letter, and none carrying text or a student's score.
- **Nothing at all is emitted while consent is off.**
- The gate command passes:

```bash
flutter test test/features/onboarding/ test/core/telemetry/ test/features/quiz/
```

---

## What this plan does not do

- **It does not link BigQuery.** That is console work, it is free, and it is not
  retroactive, so it wants doing on the day the project is created rather than
  when this ships.
- **It does not decide the consent copy's wording.** The table above is intent,
  not final text, and the second line in particular is a promise a student will
  read literally.
