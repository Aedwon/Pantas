# Hand-off: the signed-integer split (Math batch 2d), for the release lead's question process

Date: November 28, 2026. From: walk-through Math lead (E-206). Lesson branch `content/lesson-walkthrough-cse-r1` at
`07cf0289e` (lesson files) and this file's commit (the change list). Live root at the time of writing:
`content/cse-math-qfix-2b-r2` `34f3c7e24`. Ruling: manager, Nov 28 ("it ships as one change through the release lead's
question process").

Status: both lessons passed Codex reads 1 and 2 of batch 2d as lessons (0 Blockers in read 2; Majors fixed once and checked
by the lead). The question lines and data files below were not part of those reads.

## 1. Lesson files to copy (whole files, from `07cf0289e`)

- `content/lessons/mathematics/arithmetic-number-sense/signed-integer-operations.md` (`_id`
  `lesson-arithmetic-number-sense-signed-integer-operations`, part 2 of 4, ordering 1)
- `content/lessons/mathematics/arithmetic-number-sense/substituting-negative-numbers.md` (`_id`
  `lesson-arithmetic-number-sense-substituting-negative-numbers`, part 3 of 4, ordering 2)
- `content/illustrations/mathematics/arithmetic-number-sense/signed-integer-operations/01-number-line-absolute-value-of-negative-six.svg`
- `content/illustrations/mathematics/arithmetic-number-sense/signed-integer-operations/02-walk-seven-left-then-four-right-stops-at-negative-three.svg`
- `content/illustrations/mathematics/arithmetic-number-sense/substituting-negative-numbers/01-exponent-reaches-parenthesized-negative-three-or-only-three.svg`

The trap evidence for both lessons is already in the live root's `content/walkthrough-trap-evidence.json` (identical to the
branch's).

## 2. Retirement (same convention as `order-of-operations.md` on the root)

- `content/lessons/mathematics/arithmetic-number-sense/signed-integers-and-substitution.md`: add `status: retired` and
  `replacedBy:` with `lesson-arithmetic-number-sense-signed-integer-operations` and
  `lesson-arithmetic-number-sense-substituting-negative-numbers`. Keep the body.
- `content/lessons/mathematics/arithmetic-number-sense/order-of-operations.md` (already retired): its `replacedBy` lists
  `lesson-arithmetic-number-sense-signed-integers-and-substitution`; replace that entry with the two new ids, or keep it if
  the export resolves chains (the export's warnings show it resolves retired ids). Release lead's call.

## 3. Renumbering of the topic to 4 parts

| Lesson | Live now | After the split |
| --- | --- | --- |
| operation-priority-and-left-to-right | part 1, partCount 3, ordering 1 | part 1, partCount 4, ordering 0 |
| signed-integers-and-substitution | part 2, partCount 3, ordering 2 | retired |
| signed-integer-operations | (new) | part 2, partCount 4, ordering 1 |
| substituting-negative-numbers | (new) | part 3, partCount 4, ordering 2 |
| grouping-and-fraction-bars | part 3, partCount 3, ordering 3 | part 4, partCount 4, ordering 3 |

Only the front matter changes in Operation Priority and Grouping; their bodies stay as handed off in batch 2b. The
"after" values are the ones the branch had at `5d1a6ddb9`.

## 4. Question changes in `content/questions/mathematics/arithmetic-number-sense/order-of-operations.yaml`

Build these on the live root's version of the file, never the branch copy (the branch copy predates the 0019 stem fix).

Relink 4 existing questions (lesson and keyPoint):

| Question | Lesson now | Lesson after | keyPoint now | keyPoint after |
| --- | --- | --- | --- | --- |
| order-of-operations-0003 | signed-integers-and-substitution | substituting-negative-numbers | 2 | 2 |
| order-of-operations-0008 | signed-integers-and-substitution | substituting-negative-numbers | 2 | 3 |
| order-of-operations-0013 | signed-integers-and-substitution | substituting-negative-numbers | 2 | 3 |
| order-of-operations-0021 | signed-integers-and-substitution | signed-integer-operations | 1 | 3 |

Add 6 new questions (full text in the branch file at `07cf0289e`): 0022, 0023, 0024 (signed-integer-operations, keyPoints
1, 1, 2), 0025 (signed-integer-operations, keyPoint 3), 0026, 0027 (substituting-negative-numbers, keyPoints 1, 2). They
carry `approved: true` from the Nov 26 Batch 1 writer (`25842f38e`), but they are not in the live
`content/question-ledger/approved.json`. Treat them as unapproved: they need the question process (blind solve and the
approval tool) before they ship.

## 5. Other files that name the old lesson on the live root

- `content/question-ledger/approved.json`: 4 entries (lines 2508, 2538, 2568, 2616) with `lesson` set to the old id. These
  are likely the 4 relinked questions; update with the relink.
- `content/lesson-prerequisites.json`: 8 references (lines 51, 2617, 2626, 2726, 2745, 2757, 2802, 2814), both as a lesson
  with prerequisites and as a prerequisite of others. Each needs the new id that teaches that skill: signed operations for
  sign rules, substituting for substitution and exponent scope.
- `content/question-gap-tags.json`: about 15 gap tags point at the old id. The export already resolves retired ids, so these
  can stay, or be repointed. Release lead's call.
- `tools/lesson_author/outline.json` line 24: the outline still lists `signed-integers-and-substitution`; update it to the
  two new slugs.

## 6. Checks to run after the change

Main's `build_content_export.dart` and `tool/content/lesson_checks.dart --root` on the changed root (the trap-pair and
split-coverage checks cover the relinks), the SVG check, and the question validator and content gate the question process
uses. The Math lead's own export of the 10 other 2d lessons passed on the live root at `07cf0289e`; the split has not been
exported, because it needs the changes above.
