# Static Question Content Pipeline — Design

Date: 2026-07-20
Status: Approved (conversation with Aedwon)

## Purpose

Author, review, and import a static question bank for the self-contained CET
subjects, mirroring the lessons content pipeline. The quiz bank today is thin
relative to lesson coverage; this fills it with exam-grade questions that carry
explanations.

Questions are a Sanity `question` doctype baked into the offline seed
(`assets/seed/content.db`) at build time via `tools/build_content_seed/`. This
pipeline produces reviewable YAML source, converts it to Sanity NDJSON, and
gives a local review tool — the questions' analog of `lesson_author` +
`import_lessons` + `illustration_studio`.

## Scope

**In scope — authored now:**

- **Science** — Biology, Chemistry, Physics, Earth Science & Astronomy
  (all topics, including diagram-heavy subtopics as figure-pending; see Figures).
- **Reasoning** — Logical-Verbal (fully shippable); Spatial-Abstract and
  Mechanical-Technical (authored now as figure-pending).
- **Language Proficiency** — Grammar & Structure, Vocabulary, and standalone
  Language Application items (single-stem only; cloze/passage items deferred).

**Deferred to their own follow-ups (flagged, not built here):**

- Passage-based **Reading Comprehension** and cloze Language items — need a
  passage doctype + quiz-session grouping (runtime/schema work). The YAML format
  reserves a `passage:` field so they slot in later without reformatting.
- The quiz **renderer upgrade** ("E") — the quiz UI flattens Portable Text to a
  plain string (`question_repo.dart:_plainText`) and renders it with a bare
  `Text` widget (`question_card.dart`), so math and images do not render.
  Figure-pending and math questions cannot display correctly until this lands.
- The **templated math engine** ("D", the dynamic-quiz idea) — its own spec.

**Explicitly not doing:** no schema change for difficulty (authoring-only,
below); no changes to the quiz runtime, session sampling, or FSRS.

## Content model & taxonomy

Structure stays anchored to `tools/lesson_author/outline.json`:
**subject → topic → lesson**.

| Outline level | Sanity concept | Question field |
|---|---|---|
| subject | `subject` | (via topic) |
| topic   | `topic`   | `topic` ref → `topic-<topicSlug>` |
| lesson  | `lesson`  | `subtopic` → `lesson-<topicSlug>-<lessonSlug>` |

- A question's `subtopic` points at its **lesson id**, linking questions to the
  lesson that teaches them (enables "practice this lesson" later). The schema's
  `subtopicId` is a nullable string, so no schema change is needed.
- **Question IDs:** `q-<topicSlug>-<subtopicSlug>-NNNN`, numbered in difficulty
  order. The app's `QuestionRepo.byTopic` sorts by id ascending, so id order
  surfaces an easy→hard ramp with no schema change.
- **ID convention is shared** with the (still-unbuilt) `import_lessons`
  (`subject-<slug>`, `topic-<slug>`, `lesson-<topicSlug>-<lessonSlug>` per the
  2026-07-16 lesson-author spec). The importer derives these via a small shared
  id-helper both importers use; both read `outline.json`.
- **Exam tags** are derived per subtopic from `docs/content/audit/` benchmarks
  (UPCAT, ACET, DLSUCET/DCAT, USTET, DOST-SEI, CSE). The runbook maps each topic
  to its exams; the author never tags questions by hand. Tags become `examIds`
  refs (`exam-<code>`) at import.

## One file per subtopic — YAML format

Path: `content/questions/<subject>/<topic>/<subtopic>.yaml`

```yaml
meta:
  subject: science
  topic: biology
  subtopic: cell-structure          # outline lesson slug
  exams: [upcat, dost-sei, ustet]   # from audit benchmarks
questions:
  - id: q-biology-cell-structure-0001
    type: identify-organelle        # question-type archetype (per-subject blueprint)
    difficulty: easy                 # authoring-only metadata (not stored in Sanity)
    stem: |
      Which organelle is the site of photosynthesis in a plant cell?
    choices:
      - text: Chloroplast
        correct: true
      - text: Mitochondrion
      - text: Ribosome
      - text: Golgi apparatus
    explanation: |
      Chloroplasts hold chlorophyll, the green pigment that captures light to
      make food. Mitochondria release energy but do not make food.
    approved: false                  # flipped in the review tool
    # figure: cell-diagram-01        # reserved; present => figure-pending (imports isActive:false)
    # passage: <ref>                 # reserved; unused now (RC deferred)
```

**Format rules (importer-enforced):**

- Exactly one choice has `correct: true`.
- 4 choices by default; importer assigns labels A–D and `ordering` from list
  order.
- `stem` and `explanation` are block scalars (`|`) so LaTeX and line breaks are
  preserved verbatim (future math).
- `difficulty ∈ {easy, medium, hard, exam}` — used for id ordering and coverage
  discipline only; never written to Sanity.
- `id` unique across the whole bank; `NNNN` ascends with difficulty.

## Difficulty — authoring-only

Two things share the name "difficulty"; only one is real in the shipped system:

1. **FSRS difficulty** (`review_state.difficulty`, 1.0–10.0) — a per-user,
   per-item value the spaced-repetition engine *learns* at runtime. Read by the
   metrics "difficulty calibration" signal. Not authored.
2. **Authored difficulty** — does not exist in the schema. The `question`
   doctype/table has no difficulty column.

Decision: keep authored difficulty as **YAML-only metadata**. It drives the
easy→hard id ramp during authoring; it never reaches Sanity or the app as data.
A real stored field (to seed FSRS's cold-start anchor `w[4]`, or offer
easy-first sessions) is a possible future enhancement, not built here.

## Figures — author now, ship later

Figure-dependent questions need (a) an image in the stem and (b) the renderer
upgrade ("E") to display it. We author their **text now** and defer display:

- A question with a `figure: <illustration-slug>` is **figure-pending**.
- The importer brings figure-pending questions in as **`isActive: false`** —
  present in Sanity, not served — until the image exists, the renderer lands,
  and the author flips them active.
- Each `figure:` slug is appended to a new **`docs/content/question-figures/worklist.tsv`**
  (sibling to the lesson illustration `worklist.tsv`). The **existing**
  Illustration Studio already normalizes and moves any PNG into
  `content/illustrations/`; pointing it at this second worklist later needs no
  studio changes now.
- Inherently figure-dependent subtopics (spatial-abstract & mechanical
  reasoning, diagram Science) are authored this way; logical-verbal reasoning,
  most Science, and Language stay figure-free and ship immediately.

## Per-subject question-type blueprints (the bespoke layer)

Each subject gets a blueprint doc under `docs/content/question-blueprints/`
listing its archetypes and difficulty ramp, so generation is systematic yet
subject-specific. Initial archetype sets:

- **Science:** identify/define, structure↔function match, cause-effect,
  classify, predict-outcome, compare-contrast, process-ordering,
  simple-quantitative (physics/chem). Ramp: recall → understanding →
  application → analysis.
- **Reasoning (logical-verbal):** analogies, syllogisms, assumption/conclusion,
  number & letter series, odd-one-out, statement-inference.
- **Reasoning (spatial-abstract, mechanical):** figure series, figure analogy,
  odd-figure, pulley/lever/gear reasoning — all figure-pending.
- **Language (grammar):** error-identification, correct-usage, subject-verb
  agreement, tense, punctuation, pronoun. **(vocabulary):** synonym, antonym,
  word-in-context, confusing-words, word analogy.

**Voice (two-level rule, from content-voice):** the **stem** stays at authentic
UPCAT/DOST exam difficulty and wording; the **explanation** drops to simple
Grade 4–6 English. Explanations state *why the answer is correct* and briefly
*why the main distractor is wrong*. Distractors are plausible and mistake-based,
never throwaway.

## Coverage model

Per subtopic: enumerate every distinct question-type from the blueprint, write
**2–3 differently-phrased variants of each**, ramped in difficulty →
~12–20 questions/subtopic. No near-duplicates; variants differ in scenario or
framing, not just numbers.

## Components to build

### `tools/import_questions/`

YAML → Sanity `question` NDJSON, mirroring the planned `import_lessons`.

- Reads `content/questions/**/*.yaml` and `outline.json`.
- Validates each question (one-correct, non-empty fields, choice count, unique
  id, known type/difficulty); fails loudly with file + question id.
- Converts `stem`/`explanation` to Portable Text blocks; assigns choice
  `_key`/`label`/`ordering`; resolves `topic`/`subtopic`/`examIds` via the
  shared id-helper.
- Figure-pending questions emitted with `isActive: false`.
- Emits NDJSON for `sanity dataset import`, plus a **fixture smoke-test path**
  that writes to a local JSON (no Sanity), reusing the `seed_writer` fixture
  pattern.

### `tools/question_studio/` — review/QA tool

Local web tool (dependency-free Node server + single-page `public/index.html`),
same shape as `lesson_author` (port to be assigned, e.g. 4323).

- `GET /api/tree` — subject → topic → subtopic tree with per-file counts and
  approved/pending/figure-pending indicators.
- `GET /api/subtopic?id=` — parsed YAML for rendering.
- `POST /api/question` — light inline edits (stem/choice/explanation text,
  approved flag) written back to the YAML, preserving formatting.
- Renders each question as it will appear: **correct answer highlighted**,
  explanation, type, difficulty, exam tags, figure/passage badges.
- **Live validators:** exactly one correct, no empty fields, choice count,
  near-duplicate stem flag (within subtopic).
- Per-question **approved** toggle; a subtopic is "ready" when all its
  non-figure-pending questions are approved and valid.

### Docs produced

- `docs/content/question-style-guide.md`
- `docs/content/question-authoring-runbook.md` (incl. topic→exam tag map)
- `docs/content/question-blueprints/<subject>.md`
- `docs/content/question-figures/worklist.tsv`
- `tools/question_studio/prompt_template.md`

## Pilot (prove-it-first, before mass generation)

1. Generate **Biology → Cell Structure** as a full YAML subtopic set
   (~12–20 questions across its archetypes, figure-free).
2. Review in `question_studio`; fix validators/rendering.
3. Run `import_questions` to the fixture path, then into the dev dataset;
   verify real questions render in the running app (emulator `pantas_pixel`,
   `flutter run --flavor dev -t lib/main_dev.dart`).
4. Fix any format/import/id issues, update the runbook, **then** mass-generate
   the remaining subtopics.

## Testing

- Dart golden test: YAML → NDJSON for the pilot subtopic (stable Portable Text
  shape, choice labels/ordering, figure→`isActive:false`).
- Validator unit tests: one-correct enforcement, empty-field rejection,
  duplicate-id detection.
- Tool: a small JS check for the validator functions.
- Reuse the existing `test/fixtures/sanity/` seed pattern; confirm imported
  questions hydrate through `QuestionRepo` unchanged.

## Out of scope / follow-up specs

- **E — quiz renderer upgrade:** render Portable Text (marks, math via
  `flutter_math_fork`, images) in the quiz UI. Prerequisite for math and
  figure questions to display. Reuse the lesson renderer.
- **RC passage model:** passage doctype + question grouping in quiz sessions;
  unblocks Reading Comprehension and cloze Language.
- **D — templated math engine:** dynamic parameterized math questions.
- **Stored difficulty field:** if the app starts using authored difficulty.
