# Brief: Truth Tables and Propositional Logic

Lesson id: `lesson-logical-verbal-reasoning-truth-tables-propositional-logic`
Lesson path: `content/lessons/reasoning/logical-verbal-reasoning/truth-tables-propositional-logic.md`

Tagged exams: acet, cse-professional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-logical-verbal-reasoning-truth-tables-propositional-logic|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> If $P$ is false and $Q$ is true, what is the truth value of "$P \lor Q$"?
- Problem: The examples move from the AND truth table directly to OR and conditional evaluation without any worked negation example, leaving a distinct taught connective without worked-example coverage.
- Triage reason: Negation is taught but has no worked example.

### 2. `lesson-logical-verbal-reasoning-truth-tables-propositional-logic|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> This reflects the idea that a conditional promise is only broken when the condition happens ($P$ is true) but the promised result does not ($Q$ is false); if the condition never happens, the promise cannot be broken.
- Problem: This teaching sentence is long and clause-heavy for the Grade 5 readability standard. It should be split into shorter sentences with one idea at a time.
- Triage reason: Promise sentence is long; split into short sentences.

### 3. `lesson-logical-verbal-reasoning-truth-tables-propositional-logic|L03|1`
- Rule: L03
- Fix size: small
- Quote:
> If $P$ is true, $Q$ is false, and $R$ is true, evaluate "$(P \land Q) \lor R$."
- Problem: The exam verb "evaluate" is used without the required one-line explanation of what the verb means.
- Triage reason: "Evaluate" is the guide's own example of a verb to explain on first use.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-logical-verbal-reasoning-truth-tables-propositional-logic|L03|0` (L03): The exam verb "Build" is used in the first worked question without the required one-line explanation of what the verb asks the student to do. Reason: "Build the table" is plain enough without a gloss.
- `lesson-logical-verbal-reasoning-truth-tables-propositional-logic|L04|0` (L04): This adds an order-of-operations analogy outside Core Concept after the lesson already used the conditional-promise analogy in Core Concept, exceeding the one-analogy limit. Reason: Order-of-operations remark is a brief comparison, not a second friendly analogy.
- `lesson-logical-verbal-reasoning-truth-tables-propositional-logic|L13|0` (L13): The connective names are written in ALL CAPS for emphasis in a user-facing table. They are ordinary words, not acronyms or proper nouns, so this breaks the emphasis rule. Reason: AND, OR, NOT are standard logic names in column headers, not emphasis.
- `lesson-logical-verbal-reasoning-truth-tables-propositional-logic|L17|0` (L17): This content appears under a Speed Tricks & Shortcuts section, but the subject-fit rule for Reasoning requires the reduced Core Concept → Examples → Traps layout and says to drop Speed Tricks. Reason: Approved ruling (Oct 25): keep Speed Tricks only if it holds a real shortcut.
- `lesson-logical-verbal-reasoning-truth-tables-propositional-logic|L19|0` (L19): The solution uses a numbered step, but the key computation stays inline. Rule L19 requires key computations in worked solutions to be shown as display equations. Reason: Short inline evaluation is clear; display equations add little.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L04 | At most one analogy, in Core Concept | Minor | Count analogies | LSG: Voice |
| L13 | No ALL-CAPS emphasis; bold for first definitions; italics rare | Minor | Scan for capitals and emphasis | LSG: Emphasis and de-AI rules |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
