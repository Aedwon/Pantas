# Foundations 03: finish the l10n scaffolding, give feedback a destination, ask for a review once

> **How to work this plan.** Implement it task by task, in order. For each task: write the
> failing test first, run it and confirm it fails, then write the code that makes it pass. Do
> not skip a step and do not batch tasks. Steps use checkbox (`- [ ]`) syntax so progress can
> be tracked.
>
> **Required reading before Task 1:** `AGENTS.md` at the repository root, in full.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous, contradicts the spec, or looks
> wrong, **stop and say so** rather than inventing a solution. A plausible invention is more
> expensive than a question, because it looks finished.
>
> **Analyzer baseline:** `flutter analyze` reports **27 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. `lib/` is clean. Any issue under `lib/` or `test/` is
> one you introduced.


**Goal:** Close three small gaps that each look optional and each block something real: a
localization setup that is declared and unbuilt, a feedback row that points nowhere while Play
requires a support contact, and the absence of any review prompt at all.

**Architecture:** Standard Flutter ARB localization with one locale. A mail intent for
feedback, built without a new package if the platform channel suffices. A review prompt with
its own eligibility policy in the domain layer, so the "when" is testable separately from the
"how".

**Tech Stack:** Flutter, `flutter_localizations`, `intl`, `flutter_test`.

**Source spec:** `docs/superpowers/specs/2026-08-03-platform-foundations-design.md`
Sections 6 and 8.

**Decision log:** `docs/superpowers/decisions/2026-08-03-plan-audit-log.md`, round 2, where
Aedwon ruled English UI for v1 with Filipino in later versions.

**Required reading before task 1:** `AGENTS.md` in full.

## Global Constraints

- **Work only inside your worktree.**
- **Generated files are never edited by hand and never committed.** This includes the
  generated localization delegate.
- **Extract exactly one string.** The greeting. Nothing else moves into ARB in this plan.
  Extracting several hundred strings for a single locale is work with no reader and it would
  collide with every unexecuted UI plan in the queue.
- **Voice:** grade-5-simple, no em dashes, American spelling.
- **Never ask for a review at a moment of friction.** Section 8. A ranking bought that way is
  a worse deal than it looks.
- **Analyzer baseline is 27 issues, all under `tools/` or `test/tool/`. `lib/` is clean.**
- **No AI attribution in commits.**

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-02-home-03-masthead-and-band.md` | It renders the greeting. **Whichever runs second consumes the other's form.** If the masthead has landed, Task 1 repoints it; if it has not, Task 1 leaves the ARB key ready and the masthead plan uses it. | No |
| `2026-08-03-settings-06-about-and-the-pushed-pages.md` | It builds the feedback row. Task 2 gives that row its destination. | Yes, for Task 2 |

## File structure

| File | Responsibility |
|---|---|
| `l10n.yaml` (create) | The generator config. |
| `lib/l10n/app_en.arb` (create) | One key: the greeting. |
| `lib/app/app.dart` (modify) | Delegates and supported locales. |
| `lib/features/settings/presentation/feedback_intent.dart` (create) | The mail intent and its prefill. |
| `lib/features/review_prompt/domain/review_eligibility.dart` (create) | When to ask. |

---

## Task 1: The scaffolding, and one string

**Files:**
- Create: `l10n.yaml`
- Create: `lib/l10n/app_en.arb`
- Modify: `lib/app/app.dart`
- Test: `test/l10n/greeting_test.dart` (create)

**Interfaces:**
- Produces: a generated `AppLocalizations` with a single `greeting` key taking the time of day.

**Why this is built rather than struck.** The earlier recommendation was to delete
`generate: true` and the `flutter_localizations` dependency, on the reading that they were
dead weight. **Aedwon reversed it on 3 August:** Filipino is coming in later versions, and
the only non-English string today is the "Magandang [time of day]" greeting. Deleting the
scaffolding now and restoring it in v1.1 costs more than leaving it, and half-built is the
worst of the three states.

**The greeting is Filipino in an otherwise English UI, deliberately.** That is not a bug to
be normalized. Preserve it exactly.

- [ ] **Step 1: Write the failing test**

Assert the greeting resolves for each time of day and that `AppLocalizations` is reachable
from a pumped widget.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Add `l10n.yaml` and `app_en.arb`, run the generator, wire the delegates**

```bash
flutter gen-l10n
```

**Do not commit the generated output.** Confirm it is gitignored before staging.

- [ ] **Step 4: Point the greeting at it**

If `home-03-masthead-and-band` has landed, repoint its greeting. If it has not, leave the key
in place and **note in the commit message that the masthead plan must consume it**, so the
next implementor does not build a second greeting.

- [ ] **Step 5: Run the gates and commit**

---

## Task 2: Feedback goes somewhere

**Files:**
- Create: `lib/features/settings/presentation/feedback_intent.dart`
- Modify: the About page's feedback row from
  `2026-08-03-settings-06-about-and-the-pushed-pages.md`
- Test: `test/features/settings/feedback_intent_test.dart`

**Interfaces:**
- Produces: the feedback row opening the community group's URL in an external browser.

**Decided 3 August. It is a community group, not a mail composer.** Facebook is ubiquitous in
the Philippines, so a group is where students already are, and it consolidates feedback and
discussion instead of scattering both across one-to-one threads. A Discord server is the
alternative under consideration. **The row opens a URL and does not care which.**

**Nothing is collected and nothing is sent.** No build number, no device model, no prefill.
That makes this the more private of the two options and it needs no disclosure.

**The URL is Aedwon's to supply.** If it is not in `docs/OPERATIONS.md` when you reach this
task, **stop and ask.** Do not invent one, do not use a placeholder, and do not ship the row
pointing at nothing, which is the state this task exists to fix.

**This needs `url_launcher`, which is not in `pubspec.yaml`.** It is the same dependency
`2026-08-03-foundations-02-app-check-and-force-update.md` Task 3 needs for its Update button,
so **it is one decision covering both. Stop and ask** before adding it, and say that both
tasks are waiting on the same answer.

**The row names its destination.** Sending a student out of the app without saying where is
worse than not offering it.

**No form, no third-party SDK, no in-app ticketing.**

- [ ] **Step 1: Write the failing test**

Assert the row opens the configured URL externally, that it names the destination in its own
copy, and that **no student data of any kind is attached to the launch.**

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build it and wire the row**
- [ ] **Step 4: Run the gates and commit**

---

## Task 3: Ask for a review, once

**Files:**
- Create: `lib/features/review_prompt/domain/review_eligibility.dart`
- Modify: the mock results page and the debrief. **Find them with `grep -rn`.**
- Test: `test/features/review_prompt/review_eligibility_test.dart`

**Interfaces:**
- Produces:

```dart
abstract final class ReviewEligibility {
  /// Asked once, ever, and only after something went well.
  static bool shouldAsk({
    required bool hasAskedBefore,
    required bool justFinishedWell,
    required bool sawPaywallRecently,
  });
}
```

**The honest moment is after a finished mock or a completed session where the student did
well**, because that is when the question is a real one and not an interruption.

**Never after the paywall.** `sawPaywallRecently` exists to make that a compile-time argument
rather than a thing someone remembers.

**Never on launch, never after a failure, never twice.**

**The prompt itself needs a package (`in_app_review`) that is not in `pubspec.yaml`.** The
Global Constraints of most plans in this repo forbid adding one. **Stop and ask** before
adding it. This task's domain policy is useful on its own and is written first deliberately,
so the decision about the package is separate from the decision about the behavior.

- [ ] **Step 1: Write the failing test**

Assert: never twice; never when the paywall was seen recently; never on a poor result; yes
after a good mock; yes after a good session.

- [ ] **Step 2: Run it and confirm it fails**
- [ ] **Step 3: Build the policy**
- [ ] **Step 4: Run the full suite and commit**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

---

## Verification, for the reviewer

- `flutter gen-l10n` succeeds and the generated file is **not** staged.
- `find . -name '*.arb' -not -path './build/*'` returns exactly one file.
- The feedback row opens a mail intent to a real address, and the prefill contains no student
  data.
- `ReviewEligibility` returns false for every path except the two good ones.
- `flutter analyze` shows 27 issues, all under `tools/` or `test/tool/`.
- `flutter test` passes across the whole suite.

## Done when

- The scaffolding is finished rather than half-built, and the first Filipino string in v1.1
  has somewhere to go.
- The feedback row reaches a person.
- The app knows when it would be honest to ask for a review, whether or not the package to ask
  with has been approved.
