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
- Example QUESTIONS use authentic exam wording and difficulty. Solutions
  return to simple English.
- Mention CETs when it motivates: why test-makers love this topic, what
  they try to trick.

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

## Frontmatter

Exactly this shape (strings JSON-double-quoted, order preserved):

```
---
_id: "lesson-<topicSlug>-<lessonSlug>"
title: "<Title from outline>"
summary: "This lesson teaches you <one simple sentence>."
subject: "subject-<subjectSlug>"
topic: "topic-<topicSlug>"
estimatedMinutes: <8–15>
isActive: true
---
```

Slugs and titles come from `tools/lesson_author/outline.json` — never
invent them.
