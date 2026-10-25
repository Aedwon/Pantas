# Brief: Figure Matrices (Completing a 2x2 or 3x3 Grid of Shapes)

Lesson id: `lesson-spatial-abstract-reasoning-figure-matrices`
Lesson path: `content/lessons/reasoning/spatial-abstract-reasoning/figure-matrices.md`

Tagged exams: acet, dcat, sm-foundation, cse-professional

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-spatial-abstract-reasoning-figure-matrices|L02|0`
- Rule: L02
- Fix size: medium
- Quote:
> 2. Apply the same row pattern to the bottom row: starting with a square, rotating it $90°$ gives a square that looks the same as an unrotated square (since a square has rotational symmetry every $90°$), but if the square has some distinguishing mark (like a dot in one corner), that mark would move to the next corner.
- Problem: This is a long multi-clause sentence with nested parenthetical ideas and the technical term 'rotational symmetry.' It is not the short, very simple Grade 5 teaching prose required by the rule.
- Triage reason: Step 2 is long and jargon-heavy, and a plain square rotated is unchanged, so the answer is not determinate.

### 2. `lesson-spatial-abstract-reasoning-figure-matrices|B01|0`
- Rule: B01
- Fix size: small
- Quote:
> Most matrices use one of these three approaches, so working through them in order is an efficient default strategy.
- Problem: The claim that most figure matrices fit these three approaches is unconfirmed by the packet. The Level 3 record explicitly says the covered 2x2/3x3 cases are not a full or current matrix taxonomy.
- Triage reason: 'Most matrices use these three approaches' is an unsourced claim about exam items; soften.

### 3. `lesson-spatial-abstract-reasoning-figure-matrices|B01|1`
- Rule: B01
- Fix size: small
- Quote:
> **For $3 \times 3$ matrices specifically, always check whether the third item in a row or column is a combination of the first two**, since this pattern type appears frequently and is easy to miss if you're only looking for simple step-by-step progressions.
- Problem: The statement that this combination pattern appears frequently is an unconfirmed frequency claim. The packet provides no source or complete taxonomy that establishes how often this pattern occurs.
- Triage reason: 'Appears frequently' is an unsourced frequency claim; keep the check, drop the frequency.

### 4. `lesson-spatial-abstract-reasoning-figure-matrices|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> A $3 \times 3$ matrix's rows show an increasing number of dots inside a circle: row 1 has circles with $1$, $2$, $3$ dots; row 2 has circles with $2$, $3$, $4$ dots; row 3 has circles with $3$, $4$, and (blank). How many dots should the blank cell have?
- Problem: The numerals in 'row 1,' 'row 2,' and 'row 3' are numbers in prose but are not wrapped in inline math delimiters.
- Triage reason: Row 1, row 2 and row 3 are numbers in prose outside inline math.

### 5. `lesson-spatial-abstract-reasoning-figure-matrices|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> 2. Confirm this same increase applies to row 3: $3 \to 4 \to \, ?$, continuing the "+1" pattern.
- Problem: The numeral in 'row 3' and the quoted '+1' are numbers or operators in prose outside inline math, violating the lesson math-notation rule.
- Triage reason: Row 3 and the +1 pattern in prose are not wrapped in inline math.

### 6. `lesson-spatial-abstract-reasoning-figure-matrices|L18|0`
- Rule: L18
- Fix size: small
- Quote:
> A useful additional check for $3 \times 3$ matrices: sometimes the third figure in a row (or column) is some combination of the first two (like the union or overlap of their features), rather than following a simple step-by-step progression.
- Problem: The lesson introduces overlap as a distinct combination case, but no worked example demonstrates an overlap/intersection rule. Only union/superposition is worked, so the examples do not cover every distinct combination scenario the lesson itself introduces.
- Triage reason: Overlap is named as a combination rule but only union is worked; define combination as union or add one example.

### 7. `lesson-spatial-abstract-reasoning-figure-matrices|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> A useful additional check for $3 \times 3$ matrices: sometimes the third figure in a row (or column) is some combination of the first two (like the union or overlap of their features), rather than following a simple step-by-step progression.
- Problem: The terms 'union' and 'overlap' are introduced as different feature-combination possibilities without being defined before their meanings are needed. The packet lists no prerequisite lesson that supplies those meanings.
- Triage reason: Union and overlap are used with no meaning given; one plain sentence defining combine fixes it.

### 8. `lesson-spatial-abstract-reasoning-figure-matrices|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> > The third figure in a row or column is sometimes the overlap or combination of the first two, rather than a simple next-step continuation.
- Problem: Overlap is named as a matrix rule, but the lesson never explains how an overlap/intersection rule works or which features it retains. The only worked combination example teaches union/superposition instead.
- Triage reason: Overlap is named but never explained or worked, while only union is shown.

### 9. `lesson-spatial-abstract-reasoning-figure-matrices|lead-add|0`
- Rule: lead-added
- Fix size: small
- Quote:
(no quote)
- Problem: Example 1 is not determinate: a rotated plain square looks unchanged, so the rotation rule cannot be seen. Use a figure with a marked side.
- Triage reason: Found during triage; not in the audit read.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-spatial-abstract-reasoning-figure-matrices|B08|2` (B08): The numeral in 'Example 3' appears in prose outside inline math, contrary to the rule that every number in prose must be inside $...$. Reason: Example 3 is a label reference; wrapping the number is mechanical and helps no student.
- `lesson-spatial-abstract-reasoning-figure-matrices|B08|3` (B08): The numeral in 'Example 1' appears in prose outside inline math, contrary to the rule that every number in prose must be inside $...$. Reason: Example 1 is a label reference; wrapping the number is mechanical and helps no student.
- `lesson-spatial-abstract-reasoning-figure-matrices|L17|0` (L17): Reasoning lessons are required to use the reduced Core Concept → Examples → Traps layout and drop Speed Tricks. This teaching appears inside an extra Speed Tricks & Shortcuts section, so the subject section fit is not followed. Reason: The check-combination advice is a usable shortcut, but it also makes an unsourced frequency claim.
- `lesson-spatial-abstract-reasoning-figure-matrices|L19|0` (L19): The key numerical progression is kept inside the prose as inline math. L19 requires key computations in worked solutions to be shown as display equations between or after numbered steps. Reason: A short side result such as the dot count may stay inline; a display line adds little.
- `lesson-spatial-abstract-reasoning-figure-matrices|L22a|0` (L22a): This paragraph contains a long, clause-heavy second sentence rather than short sentences. It breaks the formatting rule that paragraphs use one to three short sentences. Reason: The second sentence is long but understandable; shortening is a small gain.
- `lesson-spatial-abstract-reasoning-figure-matrices|L27|0` (L27): The lesson names union and overlap as alternative combination rules but gives no condition for deciding when one applies instead of the other. Students therefore lack the applicability rule needed to choose the correct combination. Reason: Students infer the combination from the complete row; a stated condition would help little.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L22a | Paragraphs are one to three short sentences; bullet lists are sparing | Minor | Scan paragraphs | LSG: Formatting rules |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
