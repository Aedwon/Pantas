# Question Style Guide

Applies to all question YAML under `content/questions/`. Companion to
[question-authoring-runbook.md](question-authoring-runbook.md) (process) and
the per-subject blueprints in `question-blueprints/` (archetypes).

## File layout

One YAML file per subtopic:

```
content/questions/<subject>/<topic>/<subtopic>.yaml
```

- `<subject>` / `<topic>` are outline slugs from `tools/lesson_author/outline.json`.
- `<subtopic>` is the outline **lesson** slug within that topic — a question's
  `subtopic` field points at the lesson that teaches it
  (`lesson-<topicSlug>-<lessonSlug>`), so the app can later say "practice this
  lesson."

## Document shape

```yaml
meta:
  subject: science
  topic: biology
  subtopic: cell-structure          # outline lesson slug
  exams: [upcat, dost-sei, ustet]   # from the runbook's topic → exam table
questions:
  - id: q-biology-cell-structure-0001
    type: identify-organelle         # archetype name from the subject blueprint
    difficulty: easy                 # easy | medium | hard | exam — authoring only
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
    approved: false                  # flipped on in Question Studio after review
    # figure: cell-diagram-01        # present => figure-pending (imports isActive:false)
    # passage: <ref>                 # reserved; unused (Reading Comprehension deferred)
```

## Field rules

- **`id`** — `q-<topicSlug>-<subtopicSlug>-NNNN`, unique across the whole
  bank. `NNNN` ascends with difficulty (easiest question gets the lowest
  number) — this is how the app's default id-ascending sort produces an
  easy→hard ramp with no schema change.
- **`type`** — one archetype name from the subject's blueprint doc. Not
  invented per-question; keep the vocabulary closed so coverage can be
  checked against the blueprint.
- **`difficulty`** — `easy | medium | hard | exam`. **Authoring-only**: it
  drives id ordering and coverage discipline. It is never written to Sanity —
  the `question` doctype has no difficulty field, and it must not gain one as
  a side effect of this pipeline. See the runbook's "Why difficulty is
  authoring-only" note if you're tempted to add it as real data.
- **`stem`** / **`explanation`** — YAML block scalars (`|`) so line breaks and
  any LaTeX (`\dfrac{1}{2}`, etc.) are preserved verbatim for future math
  content. Never inline these as flow strings.
- **`choices`** — a list of `{text, correct}`. Default to 4 choices. **Exactly
  one** choice has `correct: true` — the importer rejects zero or multiple.
  Choice order in the YAML is the display order; the importer assigns labels
  A, B, C, D… and `ordering` from that order, so put the choices in the order
  you want them shown. **Always quote a choice's `text` if it is (or starts
  with) a bare number** — e.g. `text: "18"`, not `text: 18`. Unquoted, YAML
  parses it as an integer, not a string, and the importer rejects the whole
  question with "choice N has empty text" (found the hard way authoring
  Atomic Structure's numeric-answer questions). Values like `3-`, `3+`,
  `2, 3, 1`, or `18 neutrons` are already safe because they contain a
  non-digit character that forces YAML to treat them as a string — only a
  choice that is *purely* digits needs the explicit quotes.
  **Also quote a choice's `text` if it contains a colon followed by a space**
  (`: `) anywhere in the sentence — e.g. a choice explaining "X states the
  opposite: Y" — since unquoted YAML reads `key: value` as a nested mapping
  and the importer fails with "Nested mappings are not allowed" (found
  authoring Fluid Mechanics). Wrap the whole value in double quotes
  (escaping any internal `"` as `\"`) whenever a choice reads naturally as
  "clause: clause" — it's easiest to just quote it rather than rephrase.
- **`figure`** — omit entirely for figure-free questions (the default for
  most Science, Language, and logical-verbal Reasoning items). Set to a short
  kebab-case slug (e.g. `cell-diagram-01`) when the question needs an image
  the reader can't infer from the stem alone. A present `figure` marks the
  question **figure-pending**: the importer emits it with `isActive: false`
  and the runbook step appends the slug to the question-figures worklist.
  Write the full stem text now even though the image doesn't exist yet.
- **`passage`** — reserved, unused. Do not set it; passage-based Reading
  Comprehension is out of scope for this pipeline (see the design spec,
  "Deferred to their own follow-ups").
- **`approved`** — defaults to unset/`false`. Only Question Studio should flip
  it to `true`, after the question renders correctly and passes validators.

## Two-level voice

- **Stem**: authentic UPCAT/DOST-SEI exam wording and difficulty — do not
  simplify the question itself. Ramp within a subtopic from easy to real
  exam-level.
- **Explanation**: simple Grade 4–6 English, short sentences, straight to the
  point. State *why the correct answer is right* and briefly *why the main
  distractor is wrong*. Never leave the explanation at exam-register English —
  that's the one place simplicity always wins.

## Coverage discipline

For each subtopic: enumerate every distinct archetype from the subject
blueprint, write **2–3 differently-phrased variants of each**, ramped in
difficulty. Variants must differ in scenario or framing, not just swapped
nouns/numbers — no near-duplicates. Target ~12–20 questions per subtopic.
Distractors must be plausible and mistake-based (mirror a real
misconception), never throwaway.
