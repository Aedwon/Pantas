# AGENTS.md

For any model implementing work in this repository. If you are acting as the design
partner, read `CLAUDE.md` as well: it governs how design decisions get made, and
this file governs how they get built.

**If you were dispatched as a subagent, read `SUBAGENTS.md` first.** It is the
contract for a dispatched run: isolation, the task loop, the verification protocol
with its expected values, when to stop, and what to report. It covers content
authoring as well as code. This file is the standards it enforces.

---

## The division of labour

Specs and implementation plans are written before implementation starts. They live
in `docs/superpowers/specs/` and `docs/superpowers/plans/`, with the reasoning
behind them in `docs/superpowers/decisions/`.

**Follow the plan. Do not redesign.** If a step is ambiguous, contradicts the spec,
or looks wrong, **stop and say so** rather than inventing a solution. A plausible
invention is more expensive than a question, because it looks finished.

**Do not edit the spec or the plan while implementing.** If they need to change,
that is a decision, and decisions are recorded before code changes.

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

---

## Before writing a widget

**Check `lib/core/ui/components/` first.** The kit already has the row, band,
meter, section header, ruled section, progress rule, error banner and empty state
types. Adding a near-duplicate is the most common avoidable defect in this
codebase.

---

## Visual identity: Ink and Rule

The app looks like well-set print on paper. **Banned by name**, because they read
as generic and have been rejected repeatedly:

- Card elevation and drop shadows
- Large corner radii
- Tinted callout boxes
- Coloured left-border panels
- Blur, lock icons, shimmer loading

Grouping is done with hairline rules and rectangles. Two typefaces only: a serif
for headings and figures, a sans for body and data rows.

**Colour must always carry meaning.** Board green is reserved for the single
primary action on a screen. Severity is rust, then amber, then plain ink. Never add
colour as decoration.

---

## Voice, for every user-facing string

- Grade-5-simple English. Short sentences.
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

---

## Never invent a figure

Every number shown to a student must be one of: measured from their own use,
published by the testing body, or the output of a named algorithm used as designed.
**Anything this project inferred on its own may not be printed as a figure.**

If a spec asks for a number and the data does not exist, say so. Do not approximate,
do not substitute a proxy, and do not fill a gap with a plausible constant. Full
statement is Section 1 of `docs/superpowers/specs/2026-07-30-progress-tab-design.md`.

---

## Landmines

Things that are not obvious from the code and have cost time:

- **Two content paths.** The app ships content from `assets/seed/v1.json` into
  `AppDatabase` via `Seeder`. The Sanity stack writes `content.db` and is read by
  `contentDatabaseProvider`, but `assets/seed/content.db` is **not declared in
  `pubspec.yaml`** and `SeedInstaller` **has no callers**, so nothing installs it.
  Anything reading `content.db` gets an empty database today.
- **No blueprints exist.** `content_mock_blueprints` has zero rows, so
  `mockBlueprintsProvider` is empty and mock exams cannot run.
- **Questions have no `lessonId`.** They carry `topicId` only. Anything needing
  lesson-level question data is blocked until that tagging lands.
- **Navigation:** use `context.push` for destinations outside the tab shell.
  `context.go` strands the user with no back arrow.
- **Study has no topic page.** `/study/topic/:topicId` and `LessonListPage` were
  deleted; topics expand in place on the Study map.

---

## Commits

- Explain **why**, not just what. The diff already says what.
- **No AI attribution.** Do not add `Co-Authored-By` trailers, "Generated with"
  lines, or any similar marker.
- Do not commit or push unless asked.
