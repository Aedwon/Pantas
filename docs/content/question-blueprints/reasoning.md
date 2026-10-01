# Reasoning — Question Blueprint

> **Explanations and wrong-choice notes follow `../question-style-guide.md` (1 October 2026).**
> The explanation gives only why the correct answer is correct, with the solution when there is
> working. Every wrong choice carries a `rationale` note: the mistake, why it looks right, one
> check. The examples below omit the notes for brevity and predate this rule; where an example
> explanation discusses a wrong choice or names a choice by position, the style guide wins.


Applies to Logical-Verbal, Spatial-Abstract, and Mechanical-Technical
Reasoning. Follow [question-style-guide.md](../question-style-guide.md) for
format and voice.

## Difficulty ramp

single-step → two-step → timed multi-step. Reasoning items don't ramp by
recalled fact but by how many inference steps or how much abstraction the
item demands.

## Logical-Verbal Reasoning archetypes (figure-free)

### `analogy`
Complete a word-relationship pair.

```yaml
stem: |
  Bird is to Nest as Bee is to ___.
choices:
  - text: Hive
    correct: true
  - text: Flower
  - text: Honey
  - text: Wing
explanation: |
  A bird lives in a nest. A bee lives in a hive. Both words name where the
  animal lives.
```

### `syllogism`
Given two premises, pick the conclusion that must follow.

```yaml
stem: |
  All squares are rectangles. All rectangles have four sides.
  What must be true?
choices:
  - text: All squares have four sides.
    correct: true
  - text: All rectangles are squares.
  - text: Some four-sided shapes are not rectangles.
  - text: No squares have four sides.
explanation: |
  If every square is a rectangle, and every rectangle has four sides, then
  every square must also have four sides.
```

### `assumption-conclusion`
Given a short argument, pick its hidden assumption or its valid conclusion.

```yaml
stem: |
  "Maria studies every night, so she will pass the exam." This argument
  assumes that
choices:
  - text: studying every night is enough to guarantee passing.
    correct: true
  - text: Maria dislikes studying.
  - text: the exam is difficult.
  - text: Maria has never failed an exam before.
explanation: |
  The argument jumps from "she studies" to "she will pass" — it only works
  if studying every night is enough on its own to guarantee a pass.
```

### `number-letter-series`
Find the next term or the missing term in a sequence.

```yaml
stem: |
  What comes next? 2, 6, 18, 54, ___
choices:
  - text: "162"
    correct: true
  - text: "108"
  - text: "216"
  - text: "72"
explanation: |
  Each number is multiplied by 3 to get the next one. $54 \times 3 = 162$.
```

### `odd-one-out`
Pick the word/item that does not share the relationship the others share.

```yaml
stem: |
  Which word does not belong with the others?
choices:
  - text: Guitar
  - text: Violin
  - text: Flute
    correct: true
  - text: Cello
explanation: |
  Guitar, violin, and cello are string instruments. Flute is a wind
  instrument — it does not belong.
```

### `statement-inference`
Given a short passage or set of statements, pick what can (or cannot) be
validly inferred.

```yaml
stem: |
  "All the students in Room 5 passed the test. Liza is in Room 5."
  Which statement must be true?
choices:
  - text: Liza passed the test.
    correct: true
  - text: Liza is the best student in Room 5.
  - text: Every student in the school passed.
  - text: Liza does not like tests.
explanation: |
  If every student in Room 5 passed, and Liza is one of them, then Liza
  passed too.
```

### `truth-table-evaluation`
Given a compound statement (AND/OR/NOT/IF-THEN) and truth values for its
parts, evaluate whether the statement is true or false, or pick the row of a
truth table that matches a given condition.

```yaml
stem: |
  P is true. Q is false. What is the truth value of "P AND Q"?
choices:
  - text: False
    correct: true
  - text: True
  - text: Cannot be determined
  - text: Both true and false
explanation: |
  "AND" is only true when both parts are true. Since Q is false, "P AND Q"
  is false, no matter what P is.
```

## Spatial-Abstract Reasoning archetypes (figure-pending — see note below)

- `figure-series` — what comes next in a sequence of figures.
- `figure-analogy` — figure A is to figure B as figure C is to ___.
- `odd-figure` — pick the figure that does not share the others' pattern.
- `figure-matrix` — complete a 3×3 grid of figures.
- `paper-folding` — predict the result of folding/cutting/unfolding paper.
- `mental-rotation` — identify a rotated version of a 3D object.

These archetypes are **inherently figure-dependent**: per the content audit
(`docs/content/audit/reasoning.md`), the figure IS the question — a prose
description both spoils the puzzle and fails to test the visual skill.
Author the stem, choices, and explanation in full, with a `figure:` slug on
every question (see the style guide). Do not attempt to describe the figure
in words as a substitute.

## Mechanical-Technical Reasoning archetypes (figure-pending)

- `gear-direction` — given one gear's rotation, find another's in a train.
- `pulley-lever` — mechanical-advantage / balance-point reasoning.
- `spring-weight` — compare spring stretch/force across setups.
- `fluid-pressure` — compare pressure/level across connected containers.
- `structural-stability` — pick the more stable of two structures.

Same rule as Spatial-Abstract: always attach a `figure:` slug. The mechanism
must be drawn to be answerable; write the full question now.
