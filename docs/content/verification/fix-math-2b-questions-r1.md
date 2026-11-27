# Two live question stems scoped so only the key is true (CSE release lead r10)

Nov 28, 2026. Branch `content/cse-math-qfix-2b-r1`, on `content/cse-math-2a-r1` 54f2b1ada. Source: the Math
batch 2b Codex read 1 (`docs/content/verification/walkthrough-work/codex-math-2b-r1.md` on
`content/lesson-walkthrough-cse-r1` 4786eb99a), two Blockers. Manager: "order-of-operations.yaml,
question 0019: its keyed "left to right" rule is false for stacked powers ... First check whether a
student following the key would be marked wrong on the live question" and "word-problems.yaml, question
0022: it never says the cyclists start at the same time ... Fix the stem only."

## Wrong-key check (0019)

Not a wrong key. The stem asks which rule is valid; a student who follows the lesson picks the keyed
"Evaluate equal-priority operations from left to right." and is marked right. The other three choices are
false for ordinary arithmetic. The defect: with powers allowed, the keyed rule fails on a power tower
(2^3^2 = 2^9 = 512, not 64), so the keyed rule was stated wider than it is true.

## Changes (stems only; every choice, note and explanation unchanged, so trap citations are unaffected)

| Question | Before | After |
|---|---|---|
| q-arithmetic-number-sense-order-of-operations-0019 | Which rule is valid when evaluating an expression with no grouping symbols? | Which rule is valid when evaluating an expression that uses only addition, subtraction, multiplication and division, with no grouping symbols? |
| q-algebra-word-problems-0022 | Two cyclists start $42$ km apart and ride toward each other ... | Two cyclists start at the same time, $42$ km apart, and ride toward each other ... |

The finding suggested narrowing the keyed choice of 0019 instead. Scoping the stem gives the same truth with
no change to any choice, so cited choice texts stay byte-identical and the key does not become the longest
choice.

## Independent blind solve (key, explanation and notes hidden; choices reordered; told to be strict)

| Question | Blind solve | Key | Second defensible answer | Verdict |
|---|---|---|---|---|
| order-of-operations-0019 | Evaluate equal-priority operations from left to right | same | none (each other rule broken by a worked counterexample) | AGREE |
| word-problems-0022 | 18 km | 18 km | none | AGREE |
