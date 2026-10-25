# Brief: Sequencing of Events

Lesson id: `lesson-comprehension-skills-sequencing-of-events`
Lesson path: `content/lessons/reading-comprehension/comprehension-skills/sequencing-of-events.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-comprehension-skills-sequencing-of-events|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> | Random labels (A, B, C, D) | Earliest event | 1 (First) |
> | Random labels (A, B, C, D) | Second event | 2 (Second) |
> | Random labels (A, B, C, D) | Third event | 3 (Third) |
> | Random labels (A, B, C, D) | Latest event | 4 (Fourth) |
- Problem: The numerals 1, 2, 3, and 4 appear as ordinary prose text instead of being wrapped in inline math as required by the math-notation rule.
- Triage reason: Bare numerals sit in a table, and tables are banned; removing the table fixes it.

### 2. `lesson-comprehension-skills-sequencing-of-events|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> **Sequencing** questions ask you to identify the correct order in which events happened. This sounds simple, but passages frequently describe events out of chronological order: through flashbacks, foreshadowing, or simply mentioning a later consequence before circling back to explain its cause.
- Problem: This opening uses long, dense wording and several uncommon terms such as "chronological," "flashbacks," "foreshadowing," and "consequence," making the teaching prose harder than the required Grade 5 level.
- Triage reason: Words like chronological, flashbacks and foreshadowing are unexplained; simplify or define.

### 3. `lesson-comprehension-skills-sequencing-of-events|L22a|0`
- Rule: L22a
- Fix size: small
- Quote:
> **Sequencing** questions ask you to identify the correct order in which events happened. This sounds simple, but passages frequently describe events out of chronological order: through flashbacks, foreshadowing, or simply mentioning a later consequence before circling back to explain its cause.
- Problem: The second sentence is substantially longer than the short-sentence formatting standard, packing several separate ideas into one sentence.
- Triage reason: The second sentence packs several ideas; split it into short sentences.

## CSE teaching to add

### 1. `reading-comprehension-comprehension-skills#72`
- Facet: Filipino: temporal/causal connectors and informational-event sequence
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Filipino chronological reconstruction and language-specific connector use.

## Optional, fix only if editing that passage anyway

- `lesson-comprehension-skills-sequencing-of-events|L03|0` (L03): The exam command verb "Order" is used without the required one-line explanation of what the student must do. Reason: "Order" here is an everyday word, not an exam verb needing a gloss.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L22a | Paragraphs are one to three short sentences; bullet lists are sparing | Minor | Scan paragraphs | LSG: Formatting rules |
