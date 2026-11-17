# Abstract reasoning types: approval evidence

Lane branch gen/question-generator-r1 at 6d13e9bf5. Plan Task 1.4. One section per approval check (spec B6).

## Checker

`dart run tool/generator/bin/check.dart`: exit 0 on 15 active types (5 figure series, 10 figure grouping) and the held types. `flutter test test/tool/generator --no-test-assets`: 137 passed.

## Blind solve (Nov 17, 01:40 UTC)

- Solver: Sonnet 5.5 subagent (Anthropic; the types were written by Codex GPT 6.1 Sol, OpenAI). It read only the sheet and the figure contract section of ar-grouping.md, with no key.
- Sample: 5 variants per type: index 0 and 4 seeded random picks (seed 20261117), choices shuffled per variant. Sheet, key, answers and the sheet script: blind-solve-1/.
- Result: 75 of 75 match the key. 0 unsure, 0 second answers, 0 text mismatches. All 15 types pass this check.

## Blind solve 2 (Nov 17, 03:45 UTC): mental rotation

- Same method and solver vendor; sheet, key and answers in blind-solve-2/.
- Types: net-adjacent-relation, net-opposite-hard. Result: 10 of 10 match. 0 unsure, 0 second answers, 0 text mismatches.
- Solver note for the audit: in net-adjacent-relation the choice "They meet only at one corner" can never be correct for two faces of a cube, so it may be a filler distractor. The audit must say whether it names a real mistake.

## Blind solve 3 (Nov 17, 04:20 UTC): figure matrices

- Same method and solver vendor; sheet, key and answers in blind-solve-3/.
- 13 types, 65 variants. Result: 65 of 65 match. 0 unsure, 0 second answers, 0 text mismatches.

Blind solve total: 30 types, 150 variants, 150 match.

## Codex GPT 6.1 Sol high audit

Pending (Codex windows).

## Ledger approval

Pending (Task 1.4 ledger extension).
