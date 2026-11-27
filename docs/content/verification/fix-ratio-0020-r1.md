# Ratio question 0020: the wrong choice now matches the mistake its note names (CSE release lead r10)

Nov 28, 2026. Branch `content/cse-mixture-fixes-r1`, on 44de8b5a6 (the content root live on prod).
Source: Math batch 2a Codex read (`docs/content/verification/walkthrough-work/codex-math-2a-r1.md` on
`content/lesson-walkthrough-cse-r1`), Blocker: "the rationale for 33 meters says to add both ratio
numbers to the 21-meter difference. The stated mistake yields 4 + 7 + 21 = 32, not 33. The correct key
of 77 meters is sound." Manager: "Fix it through the question process, together with the two mixture
questions."

## Change

- q-arithmetic-number-sense-ratio-and-proportion-0020: wrong choice "$33$ meters" becomes "$32$ meters".
  Stem, key (77 meters), the other choices, every note and the explanation unchanged.
- `content/walkthrough-trap-evidence.json`: the lesson partitive-proportion-and-differences cites this
  choice under "add-parts-to-amount"; its `wrongChoice` now reads "$32$ meters" to match. That lesson is
  not live yet (walk-through Math batch 2); its copy of the evidence on `content/lesson-walkthrough-cse-r1`
  needs the same change.

## Independent blind solve (key, explanation and notes hidden; choices reordered)

One Sonnet 5.5 solver: 77 meters (one part 21 / 3 = 7; total 11 x 7); no second defensible answer. It
named 49 and 28 as the single pieces and could not name the mistake behind 32. The note names it: adding
the ratio numbers to the difference, 4 + 7 + 21 = 32, the lesson's "add parts to the amount" trap.
Before the fix, 33 matched no mistake at all.
