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

Audits: audit-a.md and audit-b.md (first pass, 30 types), reaudit-a.md (12 types after fixes), reaudit-b.md (5 types not reached in the first pass), reaudit-c.md (ray-turn and dot-sum, both then held). Fix records: fix-a-findings.md, fix-b-findings.md, fix-c-findings.md. Lead rulings: plans/2026-11-17-question-generator-briefs/fix-rulings.md.

## Final state and approval (Nov 17, 09:20 UTC)

Blind solves 1 to 3 ran on lists that the audit fixes later regenerated. Blind solve 4 (blind-solve-4/) ran on the final lists: 75 of 75 match across the 15 types active then. Two of those 15 were held afterward.

| Type (qt-spatial-abstract-reasoning-) | Checker | Blind solve 4 | Audit verdict (file) |
|---|---|---|---|
| series-fill-ray-dots | pass | 5 of 5 | PASS (reaudit-a) |
| series-four-tracks | pass | 5 of 5 | PASS (reaudit-a) |
| series-ray-step | pass | 5 of 5 | PASS (reaudit-a) |
| group-dot-count | pass | 5 of 5 | PASS (reaudit-a) |
| group-dot-parity | pass | 5 of 5 | PASS (reaudit-a) |
| group-polygon-replacement | pass | 5 of 5 | PASS, Minor accepted (reaudit-a) |
| matrix-form-ray | pass | 5 of 5 | PASS (reaudit-a) |
| matrix-outline-latin | pass | 5 of 5 | PASS (reaudit-a) |
| matrix-size-dots | pass | 5 of 5 | PASS (reaudit-a) |
| matrix-size-transfer | pass | 5 of 5 | PASS (reaudit-a) |
| matrix-ray-union | pass | 5 of 5 | PASS (reaudit-b) |
| matrix-sized-ray-union | pass | 5 of 5 | PASS (reaudit-b) |
| matrix-corner-reflection | pass | 5 of 5 | PASS, Minor accepted (reaudit-b) |

The lead approves these 13 types in the ledger with this file as evidence. The fourth check, Aedwon's figure sheets, gates the first prod release only (spec B6).
