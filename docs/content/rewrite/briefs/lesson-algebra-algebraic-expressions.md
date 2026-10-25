# Brief: Algebraic Expressions (Translation, Simplification, Evaluation)

Lesson id: `lesson-algebra-algebraic-expressions`
Lesson path: `content/lessons/mathematics/algebra/algebraic-expressions.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-algebra-algebraic-expressions|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> > **is means equals. Of means multiply. Per means divide.**
- Problem: The learning goal broadly includes translating verbal relationships, and the lesson explicitly teaches "of" and "per" as distinct translation patterns, but the Examples section gives no worked example for either pattern. Distinct taught translation cases therefore lack the required worked coverage.
- Triage reason: The lesson teaches of and per as translation keywords but no example translates either one.

### 2. `lesson-algebra-algebraic-expressions|B01|1`
- Rule: B01
- Fix size: small
- Quote:
> The sum of three consecutive even integers is $S$. Express the largest integer in terms of $S$.
- Problem: The heading makes a specific UPCAT-scope claim for this problem family. The official UPCAT page confirms a Mathematics subtest but does not confirm that consecutive-even-integer setup as UPCAT content, so the hard-to-remember exam claim remains unconfirmed and should be left out. Source checked: https://upcat.up.edu.ph/
- Triage reason: Claim about another exam's content is unconfirmed; remove or make it general.

### 3. `lesson-algebra-algebraic-expressions|B01|2`
- Rule: B01
- Fix size: small
- Quote:
> Exams like the DOST-SEI will give you scary expressions with big numbers to plug in.
- Problem: This is a specific claim about DOST-SEI exam content and style. The official DOST-SEI scholarship helpdesk material checked does not confirm this pattern, so the claim is unconfirmed and should be left out. Source checked: https://helpdesk.sei.dost.gov.ph/faqs
- Triage reason: Claim about DOST-SEI style is unconfirmed; remove or make it general.

### 4. `lesson-algebra-algebraic-expressions|B01|3`
- Rule: B01
- Fix size: small
- Quote:
> Then, put $x = 2$ into the letters in choices A, B, C, and D. The choice that gives your matching answer is correct.
- Problem: One test value cannot prove that a translated expression is uniquely correct. Different answer choices can coincide at $x = 2$; for example, $x + 2$ and $2x$ both give $4$. The shortcut needs a collision check or additional test value.
- Triage reason: One test value can match two choices (x+2 and 2x at x=2); add a second value or collision check.

### 5. `lesson-algebra-algebraic-expressions|L03|0`
- Rule: L03
- Fix size: small
- Quote:
> The sum of three consecutive even integers is $S$. Express the largest integer in terms of $S$.
- Problem: The exam verb "Express" appears here without the required one-line explanation on its first use. The lesson explains translate, simplify, and evaluate, but not express.
- Triage reason: Express first appears in Example #4 and is never explained.

### 6. `lesson-algebra-algebraic-expressions|L22a|0`
- Rule: L22a
- Fix size: small
- Quote:
> Always look to simplify *before* you plug in numbers. Exams like the DOST-SEI will give you scary expressions with big numbers to plug in. Do not plug them in right away. If you factor or simplify the letters first, the math becomes very easy.
- Problem: This teaching paragraph has four sentences, exceeding the required one-to-three short sentences per paragraph.
- Triage reason: The paragraph has four sentences; the limit is three.

### 7. `lesson-algebra-algebraic-expressions|L22a|1`
- Rule: L22a
- Fix size: small
- Quote:
> If a multiple-choice question asks you to translate a word problem into letters, plug in a real number! Make up a simple number, like $x = 2$. Solve the word problem in your head using the number $2$. Then, put $x = 2$ into the letters in choices A, B, C, and D. The choice that gives your matching answer is correct.
- Problem: This teaching paragraph has five sentences, exceeding the required one-to-three short sentences per paragraph.
- Triage reason: The paragraph runs five or more sentences; split it.

### 8. `lesson-algebra-algebraic-expressions|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> If you factor or simplify the letters first, the math becomes very easy.
- Problem: The lesson tells students to "factor" but never explains what factoring means, and no prerequisite lesson supplies that meaning.
- Triage reason: Factor is used in advice to students but never explained anywhere in the lesson.

### 9. `lesson-algebra-algebraic-expressions|L27|1`
- Rule: L27
- Fix size: small
- Quote:
> Then, put $x = 2$ into the letters in choices A, B, C, and D. The choice that gives your matching answer is correct.
- Problem: The substitution shortcut omits the condition that one chosen value can make two different expressions coincide. Students need to check for ties and use another value when more than one choice matches.
- Triage reason: The test-a-number shortcut ignores that two choices can match, so students need a second test value.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-algebra-algebraic-expressions|B01|0` (B01): The statement "is means equals" is too absolute and is contradicted later by the lesson itself: "$5$ is less than $x$" becomes $5 < x$, not an equation. The keyword needs a condition instead of being stated as a universal fact. Reason: Trap #1 already contrasts 'less than' with 'is less than'; a condition on the rule line is optional.
- `lesson-algebra-algebraic-expressions|L17|0` (L17): The worked example uses the distributive rule before any distributive formula is introduced in Core Concept. For a mathematics lesson, a formula used in a solution must first appear in Core Concept. Reason: Distribution is explained inline in the solution step; thin Core Concept but students are not left without it.
- `lesson-algebra-algebraic-expressions|L17|1` (L17): The consecutive-even-integer model $x, x + 2, x + 4$ is introduced for the first time inside the worked example instead of being established in Core Concept before the example uses it. Reason: The x, x+2, x+4 model is a setup step explained in the solution, not a formula.
- `lesson-algebra-algebraic-expressions|L19|0` (L19): Example #1 keeps its key result only in inline math. The solution steps are numbered, but the required key computation or final expression is not shown as a display equation. Reason: A one-line translation answer in inline math is acceptable; no step is skipped.
- `lesson-algebra-algebraic-expressions|L25|0` (L25): The meaning of "consecutive even integers" is needed to understand the question, but it is not explained before this first use and there is no prerequisite lesson. The explanation that they differ by $2$ comes only inside the solution. Reason: Consecutive even integers is expected knowledge and the solution explains the step of 2.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L22a | Paragraphs are one to three short sentences; bullet lists are sparing | Minor | Scan paragraphs | LSG: Formatting rules |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
