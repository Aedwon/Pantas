# Reasoning Question Generation — Content Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to work this plan subtopic-by-subtopic. Each manifest row below is one unit of work with its own test cycle (validate → review → approve → commit); treat each as a step.

**Goal:** Author, validate, review, and commit the question YAML for every remaining Reasoning subtopic (14 files across Logical-Verbal, Spatial-Abstract, and Mechanical-Technical Reasoning), using the already-built static question pipeline.

**Architecture:** No code changes. Content-production run against the existing, tested pipeline: `tools/import_questions/` (validates + converts YAML → Sanity docs) and `tools/question_studio/` (review/approve UI). One YAML file per subtopic, ~12–20 questions each, following the Reasoning blueprint's archetypes.

**Tech Stack:** YAML content files; Dart CLI for validation; Node review tool. No Flutter/Dart code is written in this plan.

## Global Constraints

- Scope is **Reasoning only** (Logical-Verbal, Spatial-Abstract, Mechanical-Technical). Do not touch Science, Language Proficiency, Mathematics, or Reading Comprehension — those are separate plans/out of scope.
- Do not modify `tools/import_questions/` or `tools/question_studio/` code. If you find a genuine bug, stop, write a regression test reproducing it (mirror `test/tool/import_questions/cli_test.dart`), fix it minimally, then continue.
- One YAML file per subtopic at `content/questions/reasoning/<topic>/<subtopic>.yaml`. Never combine or split subtopics across files.
- Exactly one choice per question has `correct: true`. 4 choices by default.
- **Quote any choice `text` that is purely digits** — e.g. `text: "162"`, not `text: 162`. Unquoted, YAML parses it as an integer and the importer rejects the question with "choice N has empty text." This bites constantly in `number-letter-series` questions. Values with any non-digit character (`2, 3, 1`) are already safe.
- **Quote any choice `text` that is bare `True`, `False`, `Yes`, `No`, `On`, or `Off`** (any casing) — e.g. `text: "True"`, not `text: True`. Unquoted, YAML parses these as booleans, not strings, and the importer rejects the question the same way. This bites `truth-table-evaluation` questions constantly, since many correct/distractor choices are literally the word "True" or "False."
- `stem` and `explanation` are YAML block scalars (`|`).
- **Two-level voice:** `stem` at authentic exam difficulty; `explanation` in simple Grade 4–6 English, stating why the answer is right and briefly why the main distractor is wrong.
- **`difficulty` is authoring-only** (`easy | medium | hard | exam`) — never written to the Sanity doc, no schema field for it.
- **`id` pattern:** `q-<topicSlug>-<subtopicSlug>-NNNN`, unique across the whole bank, ascending with difficulty.
- **Figures — read this carefully, it differs by topic:**
  - **Logical-Verbal Reasoning is figure-free.** Never add a `figure:` field here.
  - **Spatial-Abstract Reasoning and Mechanical-Technical Reasoning are figure-pending for every question.** Per the content audit (`docs/content/audit/reasoning.md`), the figure IS the question in these two topics — a prose description both spoils the puzzle and fails to test the visual skill. **Every single question** in these two topics' YAML files must carry a `figure: <kebab-case-slug>` field, and get a row in `docs/content/question-figures/worklist.tsv`. Write the full stem/choices/explanation text now even though the image doesn't exist yet — the importer will emit these as `isActive: false` until an image + the renderer upgrade ship (a separate, deferred piece of work).
  - When writing a figure-pending stem, describe the figure precisely enough that whoever illustrates it later (a human, from the worklist) can draw exactly what the question needs — e.g. "Figure shows a 3-gear train: Gear A (10 teeth) meshes with Gear B (20 teeth), which meshes with Gear C (10 teeth). Gear A turns clockwise." Do not describe the *answer* in the stem, only the setup.
- **Ground every question in the existing lesson content** at `content/lessons/reasoning/<topic>/<subtopic>.md` — reuse its terminology and worked-example style. Do not invent facts not supportable by the lesson or basic accurate logic/mechanics/geometry.
- Coverage per subtopic: every blueprint archetype that fits × 2–3 variants, ramped single-step → two-step → timed multi-step, landing around **12–20 questions**. No near-duplicates.
- No AI/Claude attribution in any commit message.

## Required reading (read once, before starting row 1)

- `docs/content/question-style-guide.md` — full YAML field rules.
- `docs/content/question-authoring-runbook.md` — process + topic→exam tag table (already applied below).
- `docs/content/question-blueprints/reasoning.md` — all archetypes (Logical-Verbal: analogy, syllogism, assumption-conclusion, number-letter-series, odd-one-out, statement-inference, truth-table-evaluation; Spatial-Abstract: figure-series, figure-analogy, odd-figure, figure-matrix, paper-folding, mental-rotation; Mechanical-Technical: gear-direction, pulley-lever, spring-weight, fluid-pressure, structural-stability) with a worked example each. Reuse these archetype names in each question's `type:` field.
- `content/questions/science/biology/cell-biology.yaml` — a complete, already-approved reference example of the target shape and quality bar (note: figure-free, since Biology doesn't need it; your Spatial-Abstract/Mechanical files will additionally carry `figure:` on every question).

## The Generation Procedure (apply to every row in the manifest below)

- [ ] **Step 1: Read the source lesson**

Open `content/lessons/reasoning/<topic>/<subtopic>.md` (path given in the manifest row). Note its worked examples and any "Traps to Watch For" section.

- [ ] **Step 2: Pick archetypes and plan the question list**

From `question-blueprints/reasoning.md`, list which archetypes for this topic genuinely fit this subtopic. For Logical-Verbal, most of the 7 archetypes are general-purpose — pick 2–4 that suit this lesson's specific skill (e.g. `number-and-letter-sequences` lesson → mostly `number-letter-series`, but a couple of `odd-one-out` or `statement-inference` variants add welcome variety). For Spatial-Abstract and Mechanical-Technical, each lesson maps almost 1:1 to one archetype (e.g. `gear-rotations` lesson → `gear-direction` archetype) — vary the mechanism/setup across the 2–3 variants per difficulty tier instead of varying archetype. Plan for 12–20 questions total, ramped single-step → two-step → timed multi-step.

- [ ] **Step 3: Write the YAML file**

Create `content/questions/reasoning/<topic>/<subtopic>.yaml` (exact path in the manifest):

```yaml
meta:
  subject: reasoning
  topic: <topic slug>
  subtopic: <subtopic slug>
  exams: [<exam codes from this topic's manifest section>]
questions:
  - id: q-<topic slug>-<subtopic slug>-0001
    type: <archetype name>
    difficulty: easy
    figure: <slug>   # OMIT for logical-verbal-reasoning; REQUIRED for the other two topics
    stem: |
      ...
    choices:
      - text: ...
        correct: true
      - text: ...
      - text: ...
      - text: ...
    explanation: |
      ...
  # ... more questions, ids ascending, difficulty ramping
```

Leave `approved:` unset — Question Studio sets it.

- [ ] **Step 4: If figure-pending, log every slug on the worklist**

For Spatial-Abstract and Mechanical-Technical files: append one row per question to `docs/content/question-figures/worklist.tsv` (tab-separated, matching its existing header `slug	subject	topic	subtopic	question_id	status`), e.g. `figure-series-01	reasoning	spatial-abstract-reasoning	figure-series	q-spatial-abstract-reasoning-figure-series-0001	pending`.

- [ ] **Step 5: Validate**

Run: `dart run tools/import_questions/import_questions.dart --root content/questions`

Expected: exit code 0. Fix any named file/question id and rerun before moving on.

- [ ] **Step 6: Review and approve in Question Studio**

Run: `node tools/question_studio/server.mjs` (or `tools/question_studio/Start Question Studio.command`), open http://localhost:4323, find `reasoning / <topic> / <subtopic>`. Confirm no validator errors, no duplicate-stem warnings, correct choice matches intent, and (for the two figure-pending topics) every question shows its figure badge. Fix inline, approve every question, Save, stop the server.

- [ ] **Step 7: Re-validate**

Run Step 5's command again: exit code 0.

- [ ] **Step 8: Commit**

```bash
git add content/questions/reasoning/<topic>/<subtopic>.yaml docs/content/question-figures/worklist.tsv
git commit -m "content: <Subtopic Title> questions"
```

(Include the worklist file in the commit only if it changed.)

- [ ] **Step 9: Check off the row**

Mark the manifest row below `- [x]` and move to the next row.

## Definition of Done (per subtopic)

- [ ] File exists at the exact manifest path.
- [ ] 12–20 questions.
- [ ] Every Spatial-Abstract/Mechanical-Technical question has a `figure:` field and a matching worklist row; every Logical-Verbal question has none.
- [ ] `dart run tools/import_questions/import_questions.dart --root content/questions` exits 0.
- [ ] Question Studio shows zero validator errors and zero duplicate-stem flags.
- [ ] Every question's `approved: true`.
- [ ] Committed; working tree clean except the next subtopic in progress.

## Manifest — Logical & Verbal Reasoning (topic slug: `logical-verbal-reasoning`)

Exams for all rows: `[acet, ustet, dost-sei]`. Figure-free — never add `figure:` in this topic.

| Done | Subtopic slug | Title | File path |
|---|---|---|---|
| [x] | `syllogisms-and-deductive-logic` | Syllogisms and Deductive Logic | `content/questions/reasoning/logical-verbal-reasoning/syllogisms-and-deductive-logic.yaml` |
| [x] | `word-analogies` | Word Analogies (Single and Double Analogies) | `content/questions/reasoning/logical-verbal-reasoning/word-analogies.yaml` |
| [x] | `number-and-letter-sequences` | Number and Letter Sequences | `content/questions/reasoning/logical-verbal-reasoning/number-and-letter-sequences.yaml` |
| [x] | `truth-tables-propositional-logic` | Truth Tables and Propositional Logic | `content/questions/reasoning/logical-verbal-reasoning/truth-tables-propositional-logic.yaml` |

## Manifest — Spatial & Abstract (Non-Verbal) Reasoning (topic slug: `spatial-abstract-reasoning`)

Exams for all rows: `[acet, ustet, dost-sei]`. **Every question in every file below requires a `figure:` field and a worklist row.**

| Done | Subtopic slug | Title | Primary archetype | File path |
|---|---|---|---|---|
| [x] | `figure-series` | Figure Series (Predicting the Next Shape in a Pattern) | `figure-series` | `content/questions/reasoning/spatial-abstract-reasoning/figure-series.yaml` |
| [ ] | `figure-grouping` | Figure Grouping (Identifying the Odd-One-Out) | `odd-figure` | `content/questions/reasoning/spatial-abstract-reasoning/figure-grouping.yaml` |
| [ ] | `figure-matrices` | Figure Matrices (Completing a 2x2 or 3x3 Grid of Shapes) | `figure-matrix` | `content/questions/reasoning/spatial-abstract-reasoning/figure-matrices.yaml` |
| [ ] | `paper-folding-and-cutting` | Paper Folding and Cutting Rules | `paper-folding` | `content/questions/reasoning/spatial-abstract-reasoning/paper-folding-and-cutting.yaml` |
| [ ] | `mental-rotation-3d-visualization` | Mental Rotation and 3D Visualization (Unfolding Cubes, Shadow Casting) | `mental-rotation` | `content/questions/reasoning/spatial-abstract-reasoning/mental-rotation-3d-visualization.yaml` |

## Manifest — Mechanical & Technical Reasoning (topic slug: `mechanical-technical-reasoning`)

Exams for all rows: `[dost-sei]` (unconfirmed by any university-CET benchmark text; kept per the content audit's DOST-SEI justification — see the runbook's topic→exam table note). **Every question in every file below requires a `figure:` field and a worklist row.**

| Done | Subtopic slug | Title | Primary archetype | File path |
|---|---|---|---|---|
| [ ] | `gear-rotations` | Gear Rotations (Predicting Clockwise vs. Counter-Clockwise Movement) | `gear-direction` | `content/questions/reasoning/mechanical-technical-reasoning/gear-rotations.yaml` |
| [ ] | `pulleys-and-levers` | Pulleys and Levers (Mechanical Advantage, Balance, Fulcrums) | `pulley-lever` | `content/questions/reasoning/mechanical-technical-reasoning/pulleys-and-levers.yaml` |
| [ ] | `springs-and-weights` | Springs and Weights | `spring-weight` | `content/questions/reasoning/mechanical-technical-reasoning/springs-and-weights.yaml` |
| [ ] | `fluid-pressure` | Fluid Pressure in Pipes and Containers | `fluid-pressure` | `content/questions/reasoning/mechanical-technical-reasoning/fluid-pressure.yaml` |
| [ ] | `structural-stability` | Structural Stability and Center of Gravity | `structural-stability` | `content/questions/reasoning/mechanical-technical-reasoning/structural-stability.yaml` |

## Suggested order

Start with **Logical-Verbal Reasoning** (smallest, figure-free, no worklist bookkeeping — fastest to build confidence with the pipeline), then Spatial-Abstract, then Mechanical-Technical. Commit after every subtopic; do not batch commits.

## Self-Review

**Spec coverage:** all 14 remaining Reasoning lessons from `tools/lesson_author/outline.json` have a manifest row with an exact path. ✓
**Placeholder scan:** no TBD/TODO; exact commands throughout. ✓
**Consistency:** exam tags match the runbook table; archetype names match the (now-complete) reasoning blueprint, including the new `truth-table-evaluation` archetype added for the one lesson that previously had no match. ✓
