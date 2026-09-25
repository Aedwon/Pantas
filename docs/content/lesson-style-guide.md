# Lesson Style Guide

Distilled from Aedwon's hand-reviewed lessons (see
`content/lessons/mathematics/`). Every generated lesson must follow this.
When in doubt, imitate `arithmetic-number-sense/order-of-operations.md`.

## Voice

- Very simple English a Grade 5 student can read. Short sentences. No
  filler, no long introductions. Every sentence teaches something.
- Explain exam verbs in one line the first time they appear:
  `"Evaluate" means find the final number answer.`
- Friendly-tutor analogies are welcome in Core Concept (building a house,
  twins holding hands), one per lesson at most.
- Example questions use authentic exam wording and difficulty. Solutions
  return to simple English.
- In-lesson quizzes follow the quiz rules: realistic target-exam language and
  plausible wrong choices based on reasoning errors or misconceptions. The Grade 5
  benchmark governs the teaching prose, not these questions.
- Mention CETs when it motivates: why the topic is tested, what the trick
  usually is. Vary how you say it — do not open every trap with
  "Test-makers often…".

## Emphasis and de-AI rules

These keep lessons from reading as machine-written. Apply everywhere.

- **Never use ALL-CAPS for emphasis** (`the WHOLE paragraph`, `build
  PROTEINS`). Use **bold** for a key term the first time it is defined,
  and *italics* rarely for light stress. Capitalize only real acronyms
  (DNA, ATP, GCF) and proper nouns.
- **Target words in a question are bold**, and the prompt says "the word
  in bold" (never "the underlined word" — markdown cannot underline).
- **Em dashes:** at most one per paragraph, and only for a genuine
  mid-sentence aside — never as a rhythm device or in place of a colon.
- **Avoid stock AI phrasing:** "it's important to note", "delve",
  "crucial", "plays a vital role", "furthermore/moreover", and the
  "not just X but Y" construction.
- **Vary sentence openings and rhythm.** Do not start three sentences in a
  row the same way; mix short and medium sentences instead of a uniform
  staccato.
- **Vary the summary.** The frontmatter `summary` should describe the
  lesson plainly; do not begin every lesson with "This lesson teaches
  you…".

## Section structure

```
## Core Concept
## Mnemonics & Memory Aids     ← OPTIONAL, see below
## Examples
## Speed Tricks & Shortcuts
## Traps to Watch For
```

- Exactly these titles ("Core Concept", not "The Core Concept";
  "Examples", not "Worked Examples").
- Mnemonics & Memory Aids is included ONLY when a genuinely known or
  natural mnemonic exists (PEMDAS sentences, SOH-CAH-TOA). If a mnemonic
  would sound forced or invented-for-the-sake-of-it, DROP the whole
  section. Do not fabricate cringe acronyms.
- An extra topical `##` section is allowed when the topic really needs it
  (e.g. "When to List Multiples" in divisibility rules) — sparingly.
- Sub-topics from the outline's required sections become `###` headings
  inside the appropriate section (usually Core Concept or Examples).

### Per-subject section fit

The five sections above were derived from Mathematics. The app renders
section titles generically, so other subjects may adapt them:

- **Mathematics:** keep the five sections. Every formula used in a
  solution must first appear in **Core Concept** — never introduce a
  formula for the first time inside an example.
- **Science (conceptual: biology, earth science):** "Speed Tricks &
  Shortcuts" may be titled **"Exam Strategies"** when the content is
  test strategy, not calculation. A **"Key Terms"** section is allowed
  for term-dense lessons (taxonomy, cell biology, genetics).
- **Science (quantitative: physics, parts of chemistry):** keep "Speed
  Tricks & Shortcuts"; the formula-in-Core-Concept rule applies here too.
- **Language Proficiency:** "Speed Tricks & Shortcuts" may be titled
  **"Common Confusions"** or **"Usage Notes"**.
- **Reading Comprehension:** "Speed Tricks & Shortcuts" may be titled
  **"Reading Strategies"**.
- **Reasoning:** use a reduced layout — **Core Concept → Examples →
  Traps to Watch For** — and drop Speed Tricks/Mnemonics, which rarely
  apply. Every example is figure-driven (see Illustration placeholders).

## Examples section

- Each example: `### #N: Short Descriptive Title` (e.g.
  `### #2: Nested Grouping Symbols`).
- 3–6 examples, ramping easiest → real UPCAT/DOST level. Exhaustive in
  COVERAGE (one example per distinct scenario/variation), never
  near-duplicates.
- Body: question sentence with inline math, then `**Solution:**` on its
  own line, then numbered steps (`1.`, `2.` markdown list), with each
  key computation as a `$$ ... $$` display line between/after steps.
- Keep each display equation narrow enough for a phone screen.

## Traps section

- Each trap: `### #N: Short Title`, then a blockquote one-line warning,
  then a short paragraph explaining the trick and the wrong answer the
  test-makers plant.

## Math notation

- ALWAYS `\dfrac`, never `\frac`.
- Every number in prose is wrapped in inline math, even isolated ones:
  `the $2$ in $3^2$`, `The correct answer is $25$.` Same for operators
  referenced in prose: `plus ($+$)`.
- Inline math `$...$`; display math `$$...$$` on its own line.
- Never `\( \)`, `\[ \]`, or code fences for math. `\cancel{}` is allowed.

## Formatting rules

- Allowed: `##`/`###` headings, paragraphs (1–3 short sentences), bold for
  key terms, italics sparingly, blockquotes, bullet lists (sparingly) and
  numbered lists (solution steps), inline/display LaTeX.
- NEVER: tables, links, code blocks, horizontal rules, images (until the
  image pipeline exists).

## Illustration placeholders

Wherever a figure, diagram, or picture would genuinely help learning
(geometry figures, graphs, cell diagrams, figure-series patterns, gear
setups), insert an HTML comment at the exact spot the image belongs:

```
<!-- ILLUSTRATION: labeled right triangle with legs 3 and 4, hypotenuse x -->
```

- One line, specific enough that an artist could draw it without reading
  the whole lesson.
- Invisible in the app and the preview; greppable later with
  `grep -rn "ILLUSTRATION:" content/lessons`.
- Put a placeholder in **every example whose question depends on a figure**,
  not just one per lesson. A figure-based example needs its own placeholder
  in its own block.
- Usually the surrounding text must still teach without the image (describe
  the figure in words) — the illustration upgrades the lesson.
- **Load-bearing exception:** in Reasoning (figure series, grouping,
  matrices, paper folding, mental rotation, gears, pulleys, levers) and in
  Reading Comprehension's visual-media lesson, the figure *is* the
  question. There the placeholder is required and the prose cannot fully
  substitute for the image; still describe enough that the example is not
  a blank.

## Frontmatter

Exactly this shape (strings JSON-double-quoted, order preserved):

```
---
_id: "lesson-<topicSlug>-<lessonSlug>"
title: "<Title from outline>"
summary: "<one plain sentence naming what the lesson covers>"
subject: "subject-<subjectSlug>"
topic: "topic-<topicSlug>"
estimatedMinutes: <8–15>
isActive: true
---
```

Slugs and titles come from `tools/lesson_author/outline.json` — never
invent them.
