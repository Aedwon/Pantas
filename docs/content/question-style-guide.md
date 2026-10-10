# Question Style Guide

Applies to all question YAML under `content/questions/`. Companion to
[question-authoring-runbook.md](question-authoring-runbook.md) (process) and
the per-subject blueprints in `question-blueprints/` (archetypes).

Facts are sourced per [source-policy.md](source-policy.md). Format follows the
target exam's entry in [exam-format-profiles.md](exam-format-profiles.md).
Before submitting, check every question against
[content-checklist.md](content-checklist.md); a question passes only with no
blocker and no major finding.

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
        rationale: |
          This mixes up making food with using it. Mitochondria release energy
          from food the cell already has, so they sound like the "energy"
          answer. Check: ask whether the part makes food or burns it.
      - text: Ribosome
        rationale: |
          This mixes up making food with making proteins. Ribosomes are found
          in every cell and "build" things, so they seem like a food maker.
          Check: photosynthesis needs light, so look for the part with a
          green pigment.
      - text: Golgi apparatus
        rationale: |
          This mixes up making food with packing and shipping it. The Golgi
          handles materials the cell has made, so it sounds busy with food.
          Check: ask which part captures light; only that one makes food.
    explanation: |
      Chloroplasts hold chlorophyll, the green pigment that captures light.
      The plant uses that light energy to make its own food, which is
      photosynthesis.
    approved: false                  # flipped on in Question Studio after review
    # figure: cell-diagram-01        # present => figure-pending (imports isActive:false)
    # passage: <ref>                 # reserved; unused (Reading Comprehension deferred)
```

## Field rules

- **`id`** — `q-<topicSlug>-<subtopicSlug>-NNNN`, unique across the whole
  bank. `NNNN` ascends with difficulty (easiest question gets the lowest
  number) — this is how the app's default id-ascending sort produces an
  easy→hard ramp with no schema change.
  **Never renumber or reuse an existing id**: student history is keyed by it.
  Questions added to an existing file take the next unused numbers, even if
  that breaks the easy-to-hard order.
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
  Use 5 choices instead when the target exam's format profile shows 5.
  Choice order in the YAML is the display order; the importer assigns labels
  A, B, C, D… and `ordering` from that order, so put the choices in the order
  you want them shown. The app shuffles choices per question when it shows
  them, so a choice must never depend on its position or letter: no "All of
  the above", "None of the above", "Both A and B", or text that names another
  choice by letter. When the target exam's format profile shows it uses that
  style, write "None of these" or "All of these" instead, which read correctly
  in any position (Aedwon, 4 October 2026). **Always quote a choice's `text` if it is (or starts
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
  **If the same choice also contains a LaTeX backslash** (`\times`, `\div`,
  etc.), a double-quoted YAML scalar treats `\d`, `\t`, and similar as escape
  sequences, not literal backslash-letter pairs, and the importer fails with
  "Unknown escape character" (found authoring Pulleys and Levers). Either
  double every backslash (`\\times`) inside the quoted string, or — simpler —
  rephrase the sentence to remove the colon-space so quoting isn't needed at
  all (e.g. "Setup A: $100 \div 4$" → "Setup A gives $100 \div 4$").
  **Also quote a choice's `text` if it is bare `True`, `False`, `Yes`, `No`,
  `On`, or `Off` (in any casing)** — e.g. `text: "True"`, not `text: True`.
  Unquoted, YAML parses these as booleans, not strings, and the importer
  rejects the question with "choice N has empty text" (found authoring Truth
  Tables and Propositional Logic, where several choices are literally the
  word "True" or "False"). This bites any topic with yes/no or true/false
  answer choices, not just Reasoning.
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

- Applies to **Mock, normal quizzes, and in-lesson quizzes**. Lesson teaching
  content's Grade 5 language benchmark does not apply to quiz questions.
- **Question and answer choices**: authentic target-exam wording and difficulty; do not
  simplify the question itself. Ramp within a subtopic from easy to real
  exam-level.
- **Wrong answer choices**: plausible alternatives based on meaningful reasoning
  errors or misconceptions. Do not use obviously unrelated or throwaway answers.
- **Explanation** (shown to Free and Pro): plain English a Grade 5 student can
  understand (simple Filipino for Filipino-language items), short sentences, straight to the point. It says only *why the
  correct answer is correct*. When the item involves solving or working out,
  show the solution step by step. It never mentions or rules out a wrong
  choice: that is the job of the wrong-choice notes, which are Pro. Explain
  difficult terms plainly without reducing accuracy.
- **Wrong-choice note** (`rationale`, Pro): **required on every wrong choice.**
  Same plain English as the explanation, two or three short sentences, in this
  order:
  1. **The mistake** it catches, named specifically (for a computed choice,
     the exact slip that produces this number).
  2. **Why it looks right**: what makes a student pick it.
  3. **One check** the student can use next time to avoid it.

  Write it so it reads correctly in two places: addressed to a student who
  picked this choice, and listed for a student who answered correctly and
  asked why the other choices are wrong. So describe the choice and the
  mistake ("This adds instead of multiplying..."), not the student ("You
  picked..."). Never restate the full solution; the explanation already
  shows it. The correct choice has no note.

How the app uses them (decision log `2026-10-01-question-explanations-log.md`):
Free and Pro both see the explanation. Pro, after a wrong answer, sees the
explanation first, then the note for the choice they picked, and on request
the notes for every other wrong choice. Pro, after a correct answer, can ask
for the notes on every wrong choice.

## Exam format profiles

"Authentic target-exam wording" is checked against the target exam's entry in
[exam-format-profiles.md](exam-format-profiles.md): choices per item, item
types, wording style, and negative stems. Where an entry is unknown, DepEd
conventions apply (four or five similar choices, one main idea per stem, a
complete stem) and the gap is reported. A profile never overrides
correctness, the shuffle-safe choice rule above, or the voice rules.

Use a negative stem ("NOT", "EXCEPT") only when the profile shows the exam uses
one, and put the negative word in bold.

## Problem information and expected knowledge

Provide the problem-specific facts, values, conditions, and referenced
material needed for a determinate answer. Include necessary units and state
rounding or approximation requirements when they affect the answer. A
referenced passage, figure, table, or marked word must be available with the
question when it is shown to the student.

Do not supply formulas, definitions, or solution methods that students are
expected to know or select. Use taught content and source-backed exam
requirements to identify that expected knowledge. Include a formula only when
the target exam supplies it or recalling it is outside the skill being tested.
Record the reason for that exception in the audit or authoring records.

For example, a simple-interest question supplies the principal, annual rate,
duration, and interest type. It does not supply the simple-interest formula
when recalling or selecting that formula is part of the tested skill.

This distinction applies to question stems, including worked-example stems
inside lessons. It does not prevent lesson teaching or answer solutions from
explaining formulas and methods. During the coverage audit, Level 4 checks
worked-example stems; Level 5 checks in-lesson quizzes and the question bank.

## No answer-giving clues

A student who does not know the content should not be able to find the answer
from the wording alone.

- The correct answer is not the longest, most detailed, or most qualified
  choice by habit. Vary which choice is longest across a set.
- Every choice fits the stem grammatically. No choice can be ruled out by
  grammar, article agreement, singular or plural, or tense alone.
- Choices share a similar form and length: all numbers, all phrases, or all
  sentences, built the same way.
- The stem does not repeat a distinctive word that appears only in the correct
  choice.
- No question gives away the answer to another question in the same set.
- The app shuffles choices, so where the correct answer sits needs no rule.

## Blind solve

Someone other than the author answers each question without seeing the key,
the explanation, or the notes. If their answer differs from the key, the
question is treated as wrong or ambiguous until it is fixed and solved blind
again. An author cannot satisfy this check alone.

## Filipino-language items

Items that test Filipino grammar, vocabulary, or reading are written in
Filipino: stem, choices, explanation, and wrong-choice notes. The stem and
choices use realistic exam Filipino. The explanation and notes use simple
Filipino held to the lesson guide's Grade 5 standard, with the same structure
as English ones. Spelling and usage follow the lesson guide's Filipino section.

## Coverage discipline

For each subtopic: enumerate every distinct archetype from the subject
blueprint, write **2–3 differently-phrased variants of each**, ramped in
difficulty. Variants must differ in scenario or framing, not just swapped
nouns/numbers — no near-duplicates. **At least 20 active questions per
lesson** (Aedwon, 1 October 2026); figure-pending questions do not count
toward the 20. Distractors must be plausible and mistake-based (mirror a real
misconception), never throwaway, and never a second defensible answer.
