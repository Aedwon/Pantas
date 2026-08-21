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

### Model routing

**Codex owns the high-level work.** It triages requests, writes and checks designs,
rules on ambiguity, handles integration and merge conflicts, and runs final
verification.

**Use Gemini to conserve Codex usage when the work is already decided:**

- `gemini-3.7-flash-high` is the default implementor for settled plan steps,
  mechanical code changes, test scaffolding, content batches and seed rebuilds.
- `gemini-3.1-pro-high` handles settled work where a wrong result is expensive to
  detect, including schema migrations, sync, entitlement and verification of
  Flash work.
- Keep architecture, security-sensitive work, unresolved requirements, conflict
  rulings and final acceptance with Codex.

Before a Gemini wave, ask Aedwon how much quota remains unless he reported it
recently. `agy` cannot read the quota. State which model will run and why. Below
roughly 25% remaining, do not start a plan that may be left unfinished. Codex
must inspect every result and run the relevant checks before accepting it.

Run two Gemini implementors at a time by default when their work is independent
and isolated in separate worktrees. Use one when tasks share files, depend on
each other, or Gemini has less than roughly 25% remaining. Use three only for
short, isolated tasks when quota is plentiful.

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

Grouping is done with hairline rules and rectangles.

**One typeface, Source Sans 3, everywhere.** The serif was retired on 11 August:
Aedwon called it an eyesore, and a reader noticing the type is not reading the
lesson. `decisions/2026-08-10-typeface-log.md` has the round.

**This makes the rest of the identity carry more, not less.** Nothing about the
letterforms distinguishes this app now, so the hairline rules, the underlined
section heads, the tabular figures and the absence of tinted callouts and
rounded cards are the whole of it. His standing words: no vibe-coded AI slop.

**Colour must always carry meaning.** Board green is reserved for the single
primary action on a screen. Severity is rust, then amber, then plain ink. Never add
colour as decoration.

---

## How to talk to Aedwon

**Raised 11 August 2026, and he was blunt about it:** *"i don't like the way you
talk. you sound like a smartass compacting your sentences too much to the point
I'm just skipping them... you sound so pompous. just say it to me directly, no
side comments, no figures of speech."*

He is skipping replies because of how they are written. So this is not a style
preference, it is the difference between being read and not.

**Write the way you would say it out loud to someone sitting next to you.**

### Stop these. Real examples, all from one reply of mine.

| Wrote | Should have written |
|---|---|
| "Both landed, and both needed correcting in ways worth knowing." | "Both are done. I had to fix two things in each." |
| "rather than adapt two tests, the run had rewritten them" | "the run rewrote two tests instead of fixing them" |
| "A test that cannot fail reads as covered, which is worse than having none." | "That test passes no matter what now. It isn't checking anything." |
| "It got the copy wrong in a way that mattered." | "It got the copy wrong." |
| "which is what makes the consent lawful rather than nominal" | "that's what makes the consent legal." |

### The specific habits to drop

- **"X rather than Y."** Say what happened. If Y matters, make it its own sentence.
- **"Worth knowing", "worth noting", "worth doing".** Delete. If it were not worth
  saying you would not be saying it.
- **Ending a sentence with a twist**, a reversal or a summary judgment. Say the
  thing and stop.
- **Two ideas welded with a comma or a semicolon.** Two sentences.
- **Figures of speech, metaphors, anything clever.** No "landmine", no "moat", no
  "the window is closing".
- **Starting with a verdict** and explaining after. Say what happened first.

**A note on that third example.** My first attempt at fixing it was "The test
always passes now, so it looks covered when it isn't." **He said that was still
bad, and it was.** It ends on a twist, and "covered" is jargon. Two plain
sentences fixed it. **If a sentence has a turn in it, split it.**

### Do these instead

- **One idea per sentence.** Short sentences. Full stops are free.
- **Say the fact, then the consequence**, in that order, in separate sentences.
- **Plain words.** "before" not "prior to". "so" not "hence". "use" not "leverage".
- **Name things the way he would.** Not the class name. Not the file name.
- **When something is wrong, say it in one sentence and move on.** No build-up.

**This governs replies to him.** Specs, plans and decision logs carry more detail
because an implementor reads them, but the same plain phrasing applies there.
Commit messages too.

---

## Answer the question. Do not start working.

**Raised 11 August 2026.** When he asks a question, answer it and stop. Then ask
him what he wants done.

**Do not answer and then immediately start building.** Do not treat a question as
approval. A question is a question.

This includes questions that sound like work is implied. "What do you think of the
price?" is not "change the price". "Is the doc updated?" is not "update the doc".

**After answering, ask.** One line is enough: "Want me to do X?"

**The exception is an explicit instruction**, or a `/goal` that is still running.

---

## Read the plan and the spec before touching anything

**He has said this many times.** Before any work on a feature, read its plan and
its spec in full. Not the headings. Not a grep. The whole file.

**Why it keeps mattering:** most of my worst mistakes on this project were
describing or building something the written document already answered. The
reader inventory, the pinned exit code, the buckets that had to move with the
price. All of them were written down before I got them wrong.

**Check the decision logs too.** A later decision can supersede a spec nobody
amended, and the code can have moved past both.

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

## Landmines

Things that are not obvious from the code and have cost time:

- **Two content paths.** The app ships content from `assets/seed/v1.json` into
  `AppDatabase` via `Seeder`. The Sanity stack writes `content.db` and is read by
  `contentDatabaseProvider`. `assets/seed/content.db` is declared at line 101
  of `pubspec.yaml` and installed from `bootstrap`.
  To build the `v1.json` asset: `dart run tools/build_dev_seed/build_dev_seed.dart`
  To build the `content.db` asset: `mkdir -p build && dart run tools/build_content_export/build_content_export.dart build/export.json && dart run tools/build_content_seed/seed_writer.dart build/export.json assets/seed/content.db`
- **One blueprint exists.** `content_mock_blueprints` contains the UPCAT paper.
  The other six exams have no published blueprint.
- **Questions have no `lessonId`.** They carry `topicId` only. Anything needing
  lesson-level question data is blocked until that tagging lands.
- **Navigation:** use `context.push` for destinations outside the tab shell.
  `context.go` strands the user with no back arrow.
- **Study has no topic page.** `/study/topic/:topicId` and `LessonListPage` were
  deleted; topics expand in place on the Study map.

---

## Commits

### Default branch completion

After implementation is complete and the relevant gates pass, merge the feature
branch into local `main` by default. Do not present the branch-completion menu or
ask which option Aedwon wants. Never push unless he explicitly asks.

Do not merge when verification fails, review has unresolved findings, the work
is incomplete or exploratory, the target branch is unclear, a conflict needs a
decision, or the merge would overlap unrelated uncommitted work. Report the
specific blocker and wait.

- Explain **why**, not just what. The diff already says what.
- **No AI attribution.** Do not add `Co-Authored-By` trailers, "Generated with"
  lines, or any similar marker. **Enforced by
  `dart run tool/check_no_ai_attribution.dart`, which scans commit messages as
  well as files**, so a bad message fails the gate for everyone until history is
  rewritten. Amend before you report.
- Do not commit or push unless asked.
