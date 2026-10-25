# Brief: Word Problems (Age, Motion, Work, Mixture, Coin, and Digit Problems)

Lesson id: `lesson-algebra-word-problems`
Lesson path: `content/lessons/mathematics/algebra/word-problems.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, pupcet, upcat

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-algebra-word-problems|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> For motion problems, add the speeds when moving apart or toward each other, and subtract the speeds when one chases the other.
- Problem: The lesson names moving toward each other and chase motion as distinct motion cases, but only opposite-direction separation has a worked example. Those named variations are therefore not covered by worked examples.
- Triage reason: Toward and chase cases are taught in Speed Tricks but only the apart case is worked.

### 2. `lesson-algebra-word-problems|B01|0`
- Rule: B01
- Fix size: small
- Quote:
> CETs use these six costumes over and over.
- Problem: This is an unconfirmed exam-scope claim. The packet's Level 3 record says the named word-problem scope is official for CSE, while coverage of these exact families and depth is unknown or weak elsewhere.
- Triage reason: Unconfirmed claim about exam question families; soften.

### 3. `lesson-algebra-word-problems|B01|1`
- Rule: B01
- Fix size: small
- Quote:
> The unasked value is always in the choices.
- Problem: This universal claim about answer choices is not verified. The Level 3 record explicitly says claims that the unasked value always appears in the choices are not verified exam facts.
- Triage reason: Absolute claim about answer choices is not a verified exam fact; soften.

### 4. `lesson-algebra-word-problems|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Time is the reciprocal of the rate.
- Problem: The word "reciprocal" is advanced for the Grade 5 teaching-language standard and is used without a simple explanation in that sentence.
- Triage reason: Reciprocal is a hard word; say flip the fraction, or one divided by the rate.

### 5. `lesson-algebra-word-problems|L27|0`
- Rule: L27
- Fix size: small
- Quote:
> For work problems with two workers, use this shortcut formula: time together equals the product of the times over the sum of the times.
- Problem: The shortcut is stated for any two-worker work problem without saying it assumes fixed positive rates, both workers doing the same job, and both contributing together for the modeled interval.
- Triage reason: The product-over-sum formula needs its conditions: same job, both working together, steady rates.

### 6. `lesson-algebra-word-problems|L27|1`
- Rule: L27
- Fix size: small
- Quote:
> For motion problems, add the speeds when moving apart or toward each other, and subtract the speeds when one chases the other.
- Problem: The relative-speed shortcut does not state the constant-rate and compatible-direction conditions under which this add-or-subtract rule is valid.
- Triage reason: The add-or-subtract speed rule needs the condition of steady speeds along the same straight path.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-algebra-word-problems|L03|0` (L03): The exam command verb "Find" is used in the digit-problem prompt without the required one-line explanation on first use. Reason: Find is plain English and needs no exam-verb definition.
- `lesson-algebra-word-problems|L05|0` (L05): The worked solutions are required to return to simple teaching language, but this solution introduces the unexplained technical word "reciprocal" instead. Reason: Same sentence as the L02 finding; the one fix covers it.
- `lesson-algebra-word-problems|L17|0` (L17): The work example first introduces the relationship time = 1/rate inside the worked solution. Core Concept teaches rate = 1/time and adding rates, but it does not state the inverse time relationship before the example uses it. Reason: Core Concept gives rate as one over time; the inverse is a trivial step and the L02 fix states it.
- `lesson-algebra-word-problems|L19|0` (L19): This setup is part of the worked solution but appears before the numbered list, so the solution does not keep every solution step in numbered steps. Reason: Defining the variable before the numbered list is normal and every step is still shown.
- `lesson-algebra-word-problems|L19|1` (L19): The key computation for the requested answer is kept inline instead of being placed on its own display-equation line as required for worked solutions. Reason: The final multiplication is trivial and shown inline in a numbered step.
- `lesson-algebra-word-problems|L21|0` (L21): This display chains several fractions across one line and is too wide for the phone-screen constraint; it should be split into narrower display steps. Reason: The line is about the width of a phone screen and splits cleanly only at a cost to clarity.
- `lesson-algebra-word-problems|L25|0` (L25): The necessary term "reciprocal" is used to justify the work calculation before its meaning is explained, and there is no prerequisite lesson supplying that explanation. Reason: Same sentence as the L02 finding; the one fix covers it.
- `lesson-algebra-word-problems|L25|1` (L25): The solution silently converts 20% to 0.20 and 50% to 0.50 without explaining percent-to-decimal conversion, and the packet identifies no prerequisite lesson for it. Reason: Percent to decimal is covered in the sibling fractions lesson and is basic arithmetic.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L21 | Display equations fit a phone screen | Minor | Look for long display lines | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
