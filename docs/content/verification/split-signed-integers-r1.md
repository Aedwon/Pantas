# Signed-integer split: two lessons, a retirement, four relinks and six new questions (CSE release lead r10)

Nov 28, 2026. Branch `content/cse-math-split-r1`, on `content/cse-math-2bc-r1` b3e75d128 (the root that goes live in
the 4 PM combined upload). Source: the Math lead's hand-off,
`docs/content/verification/walkthrough-work/split-pair-handoff.md` on `content/lesson-walkthrough-cse-r1` 8e80122aa;
lesson files and pictures from 07cf0289e. Manager: "it ships as one change through the release lead's question
process"; "Do it after the 4 PM combined upload, as its own upload, under the usage check."

## Changes

- Lessons (whole files, 07cf0289e): `signed-integer-operations.md` (part 2 of 4) and
  `substituting-negative-numbers.md` (part 3 of 4), with 3 pictures. Both passed Codex reads 1 and 2 of batch 2d.
- Retired: `signed-integers-and-substitution.md` gets `status: retired` and `replacedBy` with the two new ids; its
  part, partCount and ordering lines are removed, as other retired parents carry none. Body kept.
- `order-of-operations.md` (already retired): `replacedBy` now names the two new ids in place of the retired one.
  Lead's call: the lesson checks require every replacement to exist with a part, so a chained retired id fails.
- Renumbered (front matter only): Operation Priority part 1 of 4, ordering 0; Grouping part 4 of 4, ordering 3.
- `order-of-operations.yaml` (built on the live root's file, which carries the 0019 stem fix): 0003 to Substituting
  (keyPoint 2), 0008 and 0013 to Substituting (keyPoint 3), 0021 to Signed Operations (keyPoint 3); new 0022 to 0027,
  text identical to 07cf0289e.
- `content/lesson-prerequisites.json`: the retired lesson's own entry becomes two (Signed Operations requires
  Operation Priority; Substituting requires Signed Operations, both "Read the previous part first."); Grouping's
  previous part is now Substituting; the six "helpful" links that cite sign rules point to Signed Operations.
- `tools/lesson_author/outline.json`: the two new slugs follow the retired slug, as retired parents stay in the outline.
- `content/question-gap-tags.json`: the 14 tags that named the retired lesson are repointed explicitly, because the
  export resolves a retired id to its first replacement only: algebraic-expressions 0009, 0010 and 0015 (substituting
  a negative and exponent scope) to Substituting; the 11 sign-error tags (properties-of-real-numbers, real-imaginary
  numbers) to Signed Operations.

## Independent blind solve (keys hidden; choices reordered)

One Sonnet 5.5 solver, strict: 0022 -9, 0023 8, 0024 (-2)(-3)(-4) ÷ 6, 0025 12, 0026 9, 0027 -1; all match the keys,
no second defensible answer. The first brief added a reading note to 0027 that the stem does not carry; asked again
on the exact stem, the solver gave -1 under standard convention (the power binds before the leading minus) and called
the (-a)^2 reading nonstandard.

## Checks (main 9cfc90ac1 tools; root this branch)

- `approve.dart`: 0003, 0008, 0013, 0021 approved with `--moved`; 0022 to 0027 approved after the blind solve.
- `lesson_checks.dart --root`: exit 0 (before the question and prerequisite changes it failed on the chained
  replacement, 8 retired prerequisite links and the Signed Operations quiz pool).
- `import_questions` on mathematics: exit 0. New question text equals 07cf0289e byte for byte.
- Export: exit 0, no warning naming the retired lesson. Content gate on the packaged documents: pass.
- Nov 28, 2:36 PM Manila (lead r11): main's export (ddd70a307) refused the branch: gap tags
  q-algebra-algebraic-expressions-0009, 0010 and 0015 point to Substituting Negative Numbers, but Simplifying and
  Evaluating Expressions linked only to Signed Integer Operations. Added a helpful link to Substituting Negative
  Numbers (a846baa9e). Main's export: exit 0, 1,150 links and 204 tags; upload tool local run (`--out-dir`, content
  gate included): exit 0.
- Not yet uploaded: it goes up after the 4 PM combined upload, as its own run under the usage check, with a picture
  check of the 3 new pictures (light and dark, placement) on staging before prod.
