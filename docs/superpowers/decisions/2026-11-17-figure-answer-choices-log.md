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
