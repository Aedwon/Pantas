# Figure answer choices: decision log

Lane: figure answer choices UI lead (Opus 5.5). Velocity row E-106.
Context: `2026-11-17-question-generator-log.md`, question 5 (figure choices, in a second
spec with boards). Part of the PSHS-NCE sale gate.

## November 17, 2026: inputs from the generator lane

- Each version stores every choice as figure data plus a text description.
- Figure kinds today: figure-series, figure-matrix, shape-row, paper-fold, cube-net.
- Update (generator build lead, under a Fable adviser ruling of Nov 16): each problem type
  declares a choice kind, and every choice in one question uses it. "figure": figure data
  plus text description. "text": text only, for counts, conditions, orders and relations.
  Five hand-written singles keep text choices because today's figure kinds cannot draw
  their answers: figure series 0002, 0005, 0007, 0008 and figure matrices 0002. Format:
  `docs/superpowers/plans/2026-11-17-question-generator.md` Parts 3 and 3b, branch
  `gen/question-generator-r1`.

## November 17, 2026: visible text under figure choices

Question 1: should students see the text description under each figure choice?

- A. Figure only, with its letter (recommended). The text goes only to screen readers.
  Matches the real exams. No extra cost.
- B. Figure plus the text under it. The text can give the answer away, since a student
  can solve in words without reading the figures. Each choice gets taller, so four fit
  less well on a phone.

Aedwon's answer, relayed by the operations manager, exact words: "go with reco"

Decision: A. A figure choice shows the figure and its letter only. The text description
is the screen reader label and is never shown.

## November 17, 2026: boards built and reviewed

Canvas: "Figure Answer Choices", https://claude.ai/artifact/1ceeLDYSix7tSyP6fUSFv2 (version 3).
Built by a Claude worker (Sonnet 5.5) from DS4 (Pantas design system) and the approved
boards QV_Figure, QV_Answer, W_Question, W_QRight, W_QMiss. Three options: 1 figure in the
answer row, 2 two-by-two tiles, 3 answer strip. Phone and wide web light, one dark phone, and
a states board each (rest, selected, focus, right, wrong, review, five choices).

An independent reviewer (Claude, did not draw the boards) found 10 departures: copy not from
approved boards, header names, unequal chrome and frame sizes between options, an unsourced
"like the printed exam" claim, the wrong-pick badge losing its letter, dimming that cannot
show on a figure, focus claimed on phone, and incomplete accessibility notes. All fixed in
version 3. Every board rendered headlessly; the browser was closed.

Lead rulings made in the fix (under D191 delegation, not asked of Aedwon):

- Figures are never dimmed. Dimming lowers figure contrast, and the figure must stay
  readable in review. Other choices keep the rest look; only the badge ring changes. Right
  and wrong are shown by ring, tint and icon.
- Every choice keeps its letter in every state. Right and wrong marks sit at the cell's
  top-right corner (options 2 and 3). Option 1 on the phone keeps DS4's check inside the
  badge for the right answer.
- Keyboard focus is drawn on wide only.
- The sample question is a figure-series item drawn as board scaffolding, the same in all
  three options. The approved boards' stem and gear figure cannot carry figure choices.

## November 18, 2026: layout pick

Question 2: which layout for figure answer choices? Option 1 figure in the answer row (least
new design, small figures, scroll to compare); Option 2 two-by-two tiles (recommended: largest
figures on a phone, all four visible; one new tile design); Option 3 answer strip (most
compact, about 80px figures on a phone).

Aedwon's answer, relayed by the operations manager, exact words: "i pick option 2 2x2 tiles"

Decision: Option 2.

## November 18, 2026: live figure issues routed to this lane

The operations manager routed three issues from the generator's sheet review: shape rows
show no position numbers though choices read "Figure 1" to "Figure 5"; series 0018's
right-pointing ray lies along the dot row; matrices 0008's dots crowd in the small triangle.

Lead rulings (under D191 delegation):

- Series 0018 and matrices 0008: painter fixes only, no content edits, so the generator's
  version 0 sync holds (it compares data, not pixels; generator lead confirmed).
- Shape rows: the painter draws position numbers under shapes now. At the screen release,
  group-boundary, group-dot-parity and group-side-double-dots become figure choices with the
  shapes as the tiles and no question figure; their live sources convert in the same release
  through the content approval gate. group-dot-count keeps the numbered row and text choices
  (5 shapes, 4 choices, 30 of 100 rows repeat a shape; generator lead's measurement at
  72251e72d). Held group-line-count and group-center-cuts use the new form on return.
  Generator lead's cost: one Codex run plus re-approval of the three lists, Phase 2 window.
- The no-figure odd-one-out layout is not on the picked boards, so it was drawn
  (O2_OddOneOut_Phone and _Wide, canvas version 6) for Aedwon's check at spec approval.

Spec written: `docs/superpowers/specs/2026-11-18-figure-answer-choices-design.md`.
