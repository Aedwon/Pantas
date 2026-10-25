# Brief: Numeric and Chronological Filing

Lesson id: `lesson-clerical-ability-numeric-and-chronological-filing`
Lesson path: `content/lessons/reasoning/clerical-ability/numeric-and-chronological-filing.md`

Tagged exams: cse-subprofessional

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-clerical-ability-numeric-and-chronological-filing|L05|0`
- Rule: L05
- Fix size: medium
- Quote:
> Suppose a filing system contains codes `12.05`, `12.1`, and `12.008` and says each segment after the period is a separate **integer subcode**. Then compare the first segments (all 12), followed by subcodes 5, 1, and 8. Under that rule, `12.1` comes first.
- Problem: Example #4 is not presented as an exam-style question. It gives the comparison method and the answer directly, so the stem supplies the method instead of asking the student to apply it.
- Triage reason: Example 4 has no question or numbered solution and states the answer in the stem.

### 2. `lesson-clerical-ability-numeric-and-chronological-filing|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> Arrange: March 15, 2024; January 20, 2024; November 5, 2023; February 10, 2025.
- Problem: The date numbers are written as plain prose instead of being enclosed in inline math delimiters as required for every number in prose.
- Triage reason: Dates in the example question have numbers outside inline math.

### 3. `lesson-clerical-ability-numeric-and-chronological-filing|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> Suppose a filing system contains codes `12.05`, `12.1`, and `12.008` and says each segment after the period is a separate **integer subcode**. Then compare the first segments (all 12), followed by subcodes 5, 1, and 8. Under that rule, `12.1` comes first.
- Problem: The numeric codes use code spans instead of inline math, and the prose numbers 12, 5, 1, and 8 are also outside `$...$`, so the lesson breaks the math-notation rule.
- Triage reason: Codes use code spans and prose numbers sit outside inline math.

### 4. `lesson-clerical-ability-numeric-and-chronological-filing|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> ISO-style notation `YYYY-MM-DD` is convenient because ordinary lexicographic order matches chronological order for complete dates written in that fixed format, but it is a date notation—not a rule that every physical file must be stored oldest-first.
- Problem: This sentence is too long and uses the rare term "lexicographic" without simple wording, so the teaching prose is above the Grade 5 readability target.
- Triage reason: Sentence is long and "lexicographic" is not Grade 5 wording.

### 5. `lesson-clerical-ability-numeric-and-chronological-filing|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> Hyphenated, dotted, or segmented identifiers may be treated as numeric values, hierarchical codes, or character strings depending on the system.
- Problem: The sentence stacks several abstract terms such as "segmented identifiers," "hierarchical codes," and "character strings" instead of using very simple Grade 5 English.
- Triage reason: Stacked terms like segmented identifiers and hierarchical codes need plain wording.

### 6. `lesson-clerical-ability-numeric-and-chronological-filing|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> Write equivalent decimal places if helpful:
- Problem: Example #3 continues with bullet points and a conclusion instead of numbered solution steps with the key computations shown as display equations.
- Triage reason: Example 3 should use numbered steps; bullets and a bare conclusion do not match the format.

### 7. `lesson-clerical-ability-numeric-and-chronological-filing|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> ISO-style notation `YYYY-MM-DD` is convenient because ordinary lexicographic order matches chronological order for complete dates written in that fixed format, but it is a date notation—not a rule that every physical file must be stored oldest-first.
- Problem: The necessary term "lexicographic order" is used to explain why the date format sorts correctly, but the lesson never explains what lexicographic order means before relying on it.
- Triage reason: Lexicographic is used unexplained; drop the term and say it sorts correctly left to right.

## CSE teaching to add

### 1. `reasoning-clerical-ability#21`
- Facet: Fixed-format ISO-style date notation
- Verdict: thin
- Tier: official
- Missing ideas:
  - Explicit component identification or ordering explanation beyond the local statement.

### 2. `reasoning-clerical-ability#24`
- Facet: Character-string code ordering
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure/application for the named variant.

### 3. `reasoning-clerical-ability#25`
- Facet: Hyphenated identifiers
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure/application for the named variant.

### 4. `reasoning-clerical-ability#26`
- Facet: Terminal-digit filing method
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure/application for the named variant.

## Optional, fix only if editing that passage anyway

- `lesson-clerical-ability-numeric-and-chronological-filing|L03|0` (L03): The exam verb "Arrange" is used as an instruction before the lesson gives the required one-line explanation of what that verb asks the student to do. Reason: "Arrange" is a common word and needs no gloss.
- `lesson-clerical-ability-numeric-and-chronological-filing|L17|0` (L17): This content sits in a Speed Tricks & Shortcuts section, but the subject is Reasoning, whose required subject fit is the reduced Core Concept → Examples → Traps layout with Speed Tricks dropped. Reason: Approved ruling (Oct 25): keep Speed Tricks only if it holds a real shortcut.
- `lesson-clerical-ability-numeric-and-chronological-filing|L18|0` (L18): Reverse chronological order is a distinct direction within the learning goal, but it is only mentioned after the oldest-to-newest example instead of receiving its own worked example as required for each distinct variation. Reason: Reverse order is a one-line flip of Example 2; a separate example adds little.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
