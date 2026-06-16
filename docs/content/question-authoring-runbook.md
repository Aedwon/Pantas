# Question Authoring Runbook

How to take an outline lesson to an imported, reviewed question set. Format
rules live in [question-style-guide.md](question-style-guide.md); archetype
lists live in `question-blueprints/<subject>.md`.

## Steps

1. **Pick the lesson.** Find the subject/topic/lesson in
   `tools/lesson_author/outline.json`. The lesson's slug becomes the
   `subtopic` in your YAML file's path and `meta.subtopic`.
2. **Read the subject blueprint** at `docs/content/question-blueprints/<subject>.md`
   for the archetype list and difficulty ramp.
3. **Look up the topic's exams** in the table below and set `meta.exams`.
4. **Write the questions**, one archetype at a time, 2–3 variants each,
   ramped easy → exam-level, following the style guide's field rules and
   two-level voice.
5. **Validate**:
   ```bash
   dart run tools/import_questions/import_questions.dart --root content/questions
   ```
   Fix any file+id the importer names before continuing.
6. **Review and approve** in Question Studio:
   ```bash
   node "tools/question_studio/Start Question Studio.command"
   ```
   Fix flagged issues (validators, duplicate stems) in the tool, save, and
   re-run step 5 until clean. Mark every question `approved: true`.
7. **Figure-pending questions**: add a `figure: <slug>` to any question that
   needs one, then run Illustration Studio:
   ```bash
   node "tools/illustration_studio/Start Illustration Studio.command"
   ```
   It scans every `figure:` slug automatically and regenerates
   `docs/content/question-figures/worklist.tsv` — no manual worklist editing.
   Use the "Questions" group in the sidebar to connect an image to each slug.
   Figure-pending questions import as `isActive: false` until an illustration
   exists and the renderer that displays it ships (tracked separately).

## Why difficulty is authoring-only

Two different things are called "difficulty" in this app:

1. **FSRS difficulty** (`review_state.difficulty`) — a per-user, per-item
   value the spaced-repetition engine learns at runtime from how someone
   actually answers. Not authored.
2. **Authored difficulty** (the `difficulty:` key in your YAML) — does not
   exist in the `question` Sanity doctype or its Drift table. It is a
   YAML-only ordering aid: it decides `NNNN` in the question id and disciplines
   the easy→exam ramp during writing. It must **not** be added to the emitted
   Sanity doc. If the app later wants to use authored difficulty (e.g. to seed
   FSRS's cold-start anchor), that's a schema change to design separately —
   don't smuggle it in here.

## Topic → exam table

Derived from `docs/content/audit/benchmarks/*.md` (UPCAT, ACET, DLSUCET/DCAT,
USTET, DOST-SEI). These are the five university/scholarship CET benchmarks the
content audit checked against — the Civil Service Exam (CSE) side of the app
is a distinct, separately-scoped exam not covered by this pipeline's tagging;
leave `exams` to the CET codes below unless told otherwise.

Codes used in `meta.exams`: `upcat`, `acet`, `dlsucet`, `ustet`, `dost-sei`.

| Subject | Topic | Exams |
|---|---|---|
| Science | Biology | upcat, dlsucet, ustet, dost-sei |
| Science | Chemistry | upcat, dlsucet, ustet, dost-sei |
| Science | Physics | upcat, dlsucet, ustet, dost-sei |
| Science | Earth Science & Astronomy | upcat, dlsucet, ustet, dost-sei |
| Reasoning | Logical-Verbal Reasoning | acet, ustet, dost-sei |
| Reasoning | Spatial-Abstract Reasoning | acet, ustet, dost-sei |
| Reasoning | Mechanical-Technical Reasoning | dost-sei *(unconfirmed by benchmark text; kept per content-audit's DOST-SEI STEM-ceiling justification — verify per cycle)* |
| Language Proficiency | Grammar & Structure | upcat, acet, dlsucet, ustet, dost-sei |
| Language Proficiency | Vocabulary | upcat, acet, dlsucet, ustet, dost-sei |
| Language Proficiency | Language Application (standalone items only) | upcat, acet, dlsucet, ustet, dost-sei |

If a topic isn't listed here (e.g. it's out of this pipeline's scope — Reading
Comprehension, Mathematics), check the relevant `docs/content/audit/benchmarks/*.md`
file directly before guessing.

## Verifying a pilot or new subtopic renders in the app

```bash
dart run tools/import_questions/import_questions.dart --root content/questions --seed-json build/questions_seed.json
dart run tools/build_content_seed/seed_writer.dart build/questions_seed.json assets/seed/content.db
flutter run --flavor dev -t lib/main_dev.dart
```

`assets/seed/content.db` is a build artifact — revert it afterward
(`git checkout -- assets/seed/content.db` or delete it) so it never gets
committed.
