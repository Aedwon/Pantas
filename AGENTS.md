# Pantas agent instructions

Applies to every model, provider, and harness working on this repository.

On every new or resumed task, retrieve the current `AGENTS.md` and `WORKFLOW.md`
from `Aedwon/Pantas` on `main`, regardless of the code branch. Read `WORKFLOW.md`
in full for collaboration, complexity,
approvals, planning, execution roles, verification, and completion permissions.
Read the current task's spec, plan, and later decisions as it directs. Dispatched
workers also read `SUBAGENTS.md` before starting. The build and content standards
below apply to every role.

For GitHub-only sessions, use `ref=main` for workflow policy and the agreed
workstream revision for the task's product specs, plans, and source. If required
policy or workstream context is unavailable, report the gap and stop dependent
work. Do not substitute provider defaults or an old policy snapshot.
Provider-named entry files only point here; they contain no separate project rules.

---

## Build, run, test

```bash
flutter run --flavor dev -t lib/main_dev.dart   # dev build, the usual one
flutter test                                     # tests live in test/
flutter analyze                                  # must be clean
dart run build_runner build --delete-conflicting-outputs   # drift and freezed
```

Entrypoints are `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`
and `lib/main.dart`. Android flavors are `dev`, `staging` and `prod`.

Analysis uses `very_good_analysis` with `strict-casts` and `strict-inference` on.
Loosely typed code fails the analyzer, so write the types.

Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand.

### Verification scope

For ordinary changes, run focused checks during implementation, then all required
checks on the completed feature. The lead owns final verification of the combined
work. Follow `SUBAGENTS.md` Part 5 for scope, evidence, and expected outcomes.
Do not repeat the entire suite after every small task. Approved release or
high-risk verification requirements still apply to the work they cover.

### Switching the running build between Free and Pro

```bash
tools/pro           # what it is set to now
tools/pro on        # Pro
tools/pro off       # Free
tools/pro toggle
tools/pro clear     # no override, the real store entitlement decides
```

**No rebuild and no restart.** It reaches the running app over the port
`flutter run` already forwards through adb, and the screen changes as you watch.
The setting is stored, so a hot restart keeps it.

**There is deliberately no control for this in the UI.** A real student must
never find one, and a debug row in Settings is a row somebody has to remember to
strip before release. The switch is a service extension registered only in a
debug build.

---

## Visual direction

**Ink and Rule is retired** (Aedwon, 1 October 2026). Do not apply it, its banned list, its
typeface rule or its color rule to new work, and do not "correct" a design toward it.

The visual direction is being defined by Aedwon in Claude Design. Until rules derived from that
design are recorded here, **this file sets no visual rules**: take every visual decision from
the approved Claude Design screens, matched 1:1 (`WORKFLOW.md`, visual checking). Do not infer
a direction from older specs, the current app, or the component kit's current look.

Specs written before 1 October 2026 keep their behavior, content, figures and Free and Pro rules.
Their visual sections (Ink and Rule, hairlines, faint bars, banned styling, typeface, color) are
superseded. Record: `docs/superpowers/decisions/2026-10-01-visual-direction-log.md`.

**Before writing a widget,** check `lib/core/ui/components/` for one that already does the job.
Reuse is for behavior and structure; its current styling is not binding.

---

## Voice, for in-app content and interface text

These rules govern the app. External marketing and website copy have separate
direction from Aedwon, who personally writes and approves website copy. Do not
apply these rules to that copy by default. See `WORKFLOW.md`.

- App interface text uses simple English and short sentences.
- **Lesson teaching content:** plain, simple English that a Grade 5 student can
  understand.
- **Quiz questions and answer choices:** realistic language for the target exam.
  This applies to Mock, normal quizzes, and in-lesson quizzes. Do not apply the
  lesson's Grade 5 language rule to those questions. Wrong choices must be
  plausible and reflect meaningful reasoning errors or misconceptions.
- **Filipino-language content** (Aedwon, 4 October 2026): lessons, quiz items,
  explanations, and wrong-choice notes that teach or test Filipino use simple
  Filipino at the same Grade 5 standard instead of English. Rules:
  `docs/content/lesson-style-guide.md` and `docs/content/question-style-guide.md`.
- **Quiz answer explanations:** plain English a Grade 5 student can understand,
  including Mock, normal quizzes, and in-lesson quizzes. Explain the reasoning
  clearly without reducing the subject's accuracy. The explanation (shown to
  Free and Pro) says only why the correct answer is correct, with the worked
  solution when solving is involved. It never discusses wrong choices.
- **Wrong-choice notes (Pro):** every wrong choice carries its own note in the same
  plain English: the mistake it catches, why it looks right, and one check to avoid
  it next time. Rules: `docs/content/question-style-guide.md`.
- **No em dashes.** Use a comma or a colon.
- **American spelling.** practice, color, behavior, analyze, gray, center, organize.
  Never practise, colour, behaviour, analyse, grey, centre, organise. This holds in
  specs and prose as well as UI strings.
- Scores are **"points"**, never "marks". `mark` already means the answer dot, the
  flag pennant and the outcome mark on a reviewed question.
- **"Questions"**, never "cards".
- No article on archetype names: "Night-Owl Sprinter", not "The Night-Owl Sprinter".
- The words FSRS, stability, retention, retrievability and algorithm never appear in
  a user-facing string.

### Maths in content

- **Write `\dfrac`, never `\frac`.** Aedwon's rule, 10 August: inline, `\frac` sets
  the numerator and denominator at script size and is too small to read on a phone.
- **The exception is a fraction inside another fraction**, which is meant to be
  smaller. Write those as `\frac`.
- The renderer promotes a top-level `\frac` to `\dfrac` for content already written,
  and leaves nested ones alone, so nothing on screen is waiting on a content sweep.
  **New content should still be written correctly** rather than relying on it.
- Maths goes between single dollars, `$x^2$`. A lone dollar stays a dollar.

---

## Never invent a figure

Every number shown to a student must be one of: measured from their own use,
published by the testing body, or the output of a named algorithm used as designed.
**Anything this project inferred on its own may not be printed as a figure.**

If a spec asks for a number and the data does not exist, say so. Do not approximate,
do not substitute a proxy, and do not fill a gap with a plausible constant. Full
statement is Section 1 of `docs/superpowers/specs/2026-07-30-progress-tab-design.md`.

---

## Verify implementation facts on the code branch

Main carries current workflow policy; its application source is not necessarily
the current engineering candidate. Historical notes about content readers, seed
generation, question tagging, blueprints, and routes are not universal branch facts.
Read the assigned branch's source and later decisions before changing those areas.
Do not restore a retired data path because an older instruction file describes it.

- **Navigation:** use `context.push` for destinations outside the tab shell.
  `context.go` strands the user with no back arrow.
