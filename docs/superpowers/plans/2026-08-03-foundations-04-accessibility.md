# Foundations 04: make Ink and Rule survive large text

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
> **Analyzer baseline:** `flutter analyze` reports **25 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. **The number drifts as those tools change; the
> invariant is that `lib/` and `test/` outside `test/tool/` are clean.** Any issue there is
> one you introduced.


**Goal:** Make the app readable at 200% text scale, tappable at 44 by 44, labeled for a screen
reader, and never dependent on color alone, without softening the identity.

**Architecture:** No new widgets. Four rules applied across the kit in
`lib/core/ui/components/`, plus one golden-style test harness that pumps every kit component
at 1.0 and at 2.0 text scale and fails on overflow.

**Tech Stack:** Flutter, `flutter_test`. No new packages.

**Source spec:** `docs/superpowers/specs/2026-08-03-platform-foundations-design.md` Section 7.

**Required reading before task 1:** `AGENTS.md` in full, especially the Ink and Rule section.
**This plan must not resolve a conflict between accessibility and the identity by weakening
the identity.** Where the two genuinely collide, **stop and say so**: that is a decision and
decisions are recorded before code.

## Why this exists

Two files in `lib/` touch `Semantics` or text scaling. The identity is hairline rules, two
typefaces, tight vertical rhythm and meaning carried by weight, and **every one of those is a
thing that breaks under large text.** Play runs a pre-launch report on every upload that
checks tap targets, contrast and labels, and failing it is a written record on the store
dashboard that the app is inaccessible.

## Global Constraints

- **Work only inside your worktree.**
- **Generated files are never edited by hand and never committed.**
- **No new dependencies.**
- **Do not weaken the identity to pass a rule.** Rules and rhythm may stretch. Nothing that
  carries meaning may be cut, and no banned device may be introduced: no card elevation, no
  drop shadows, no large radii, no tinted callouts, no colored left-border panels, no blur, no
  shimmer.
- **Text that carries meaning is never truncated to an ellipsis.** A label may wrap; a figure
  may not be clipped.
- **Color is never the only carrier.** Severity is rust, then amber, then plain ink, and it
  must also read as a word or a position.
- **Voice** applies to every semantics label: grade-5-simple, no em dashes, American spelling.
  A screen reader reads them aloud, so they are user-facing strings.
- **Analyzer baseline is ~25 issues, all under `tools/` or `test/tool/`. `lib/` is clean and that is the invariant, not the count.**
- **No AI attribution in commits.**

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| Every unexecuted UI plan | **This plan should run late**, after the kit has stopped changing. Running it now means sweeping components that Quiz 2a, Settings 01 and Study 01 are about to replace. | Not blocking, but ordering matters |

**Read this before scheduling.** The four rules below should be **added to the Global
Constraints of the unexecuted UI plans** so new components are built correctly, and this plan
then sweeps only what predates them. That amendment is Task 1.

## File structure

| File | Responsibility |
|---|---|
| `docs/superpowers/plans/*.md` (modify) | Task 1: the four rules, added to the UI plans. |
| `test/helpers/accessibility.dart` (create) | The harness: pump at two scales, fail on overflow. |
| `lib/core/ui/components/*.dart` (modify) | Task 3: labels and tap targets. |

---

## Task 1: Put the rules where new work will read them

**Files:**
- Modify: the Global Constraints section of every unexecuted UI plan.

**This is the highest-value task in the plan and it is documentation.** A component built
correctly costs nothing; a component swept afterward costs a task.

- [ ] **Step 1: Add the four rules**

To each plan's Global Constraints, verbatim:

```markdown
- **Readable at 200% text scale.** No clipping, no overlap, and no text that
  carries meaning truncated to an ellipsis. Rules and rhythm may stretch.
- **Every tap target is at least 44 by 44**, using the pattern in
  `settings-01`: a smaller visual box inside a larger tappable one.
- **Color is never the only carrier.** Severity must also read as a word or a
  position.
- **Every control has a semantics label.** Icons especially: they have no text
  to read.
```

- [ ] **Step 2: Commit**

---

## Task 2: The harness

**Files:**
- Create: `test/helpers/accessibility.dart`
- Test: `test/core/ui/components/accessibility_test.dart` (create)

**Interfaces:**
- Produces:

```dart
/// Pumps [widget] at 1.0 and at 2.0 text scale and fails on any overflow.
Future<void> expectSurvivesTextScale(
  WidgetTester tester,
  Widget widget, {
  List<double> scales = const [1.0, 2.0],
});
```

**It fails on overflow, which Flutter reports as an exception in tests but only paints as a
yellow stripe in debug.** That difference is why this is a test and not a visual check.

- [ ] **Step 1: Write the harness and one deliberately failing case**

Prove the harness catches a `Row` of two long labels at 2.0.

- [ ] **Step 2: Run it and confirm the deliberate case fails**
- [ ] **Step 3: Remove the deliberate case, keep the harness**
- [ ] **Step 4: Run the gates and commit**

---

## Task 3: Sweep the existing kit

**Files:**
- Modify: every file in `lib/core/ui/components/` that predates this plan.
- Test: one `expectSurvivesTextScale` case per component.

Sixteen components exist today: `answer_row`, `board_button`, `confirmation_dialog`,
`empty_state`, `error_banner`, `faint_bars`, `ink_table_row`, `inline_meter`, `page_scaffold`,
`portable_text_renderer`, `progress_rule`, `question_card`, `quiz_progress_bar`,
`ruled_section`, `section_header`, `stats_band`.

**Sweep only what exists when you run.** Components created by later plans are covered by
Task 1's constraint, not by this task.

**Where a component genuinely cannot survive 200% without losing meaning, stop and say so.**
Name the component, name what breaks, and propose the options. Do not silently clamp the text
scale, which is the usual fix and is the wrong one: it overrides a choice the student made in
their own OS settings.

- [ ] **Step 1: Write a failing case per component**
- [ ] **Step 2: Run them and record which fail**

**Report the list before fixing anything.** It is the honest picture of where the identity and
the requirement collide, and Aedwon should see it.

- [ ] **Step 3: Fix what can be fixed without weakening the identity**
- [ ] **Step 4: Add semantics labels to every control**
- [ ] **Step 5: Confirm every tap target is 44 by 44**
- [ ] **Step 6: Run the full suite**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

- [ ] **Step 7: Commit**

---

## Verification, for the reviewer

- Every component in `lib/core/ui/components/` has an `expectSurvivesTextScale` case.
- `grep -rn "textScaler\|TextScaler" lib/` shows **no component clamping the student's own
  setting.**
- Every icon in the app has a semantics label. There are three, all in `ThemeControl`.
- No banned identity device was introduced. Read the diff against the Ink and Rule list.
- `flutter analyze` shows 27 issues, all under `tools/` or `test/tool/`.
- `flutter test` passes across the whole suite.
- **The visual check is Aedwon's.** Report text signals and ask him to look. Do not screenshot
  the emulator.

## Done when

- Every kit component survives 200% text scale in a test, or is on a written list of the ones
  that cannot with the reason why.
- Every control has a label, every tap target is 44 by 44, and no meaning is carried by color
  alone.
- The four rules are in the Global Constraints of every unexecuted UI plan, so this sweep
  never has to happen twice.
