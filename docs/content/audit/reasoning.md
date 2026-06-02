# Reasoning — Audit Findings

Lessons read: 13 across logical-verbal-reasoning (4),
spatial-abstract-reasoning (5), mechanical-technical-reasoning (5). This
subject carries the audit's most severe illustration problem.

## Illustration gaps — the figure IS the question (top priority)

### REAS-SPA-001 [important, highest priority] spatial-abstract lessons: every example needs its figure and has none
Evidence: all five spatial-abstract lessons (`figure-series.md`,
`figure-grouping.md`, `figure-matrices.md`, `paper-folding-and-cutting.md`,
`mental-rotation-3d-visualization.md`) carry exactly one placeholder, and
it sits in Core Concept (e.g. `figure-grouping.md:22`, before the Examples
at line 26). All 20 example questions — "which figure is the odd one
out?", "what comes next in the series?", "complete the matrix" — describe
their figures in prose and have no placeholder.
Why this is worse than a geometry diagram: non-verbal reasoning trains
visual pattern recognition. A prose description of the shapes both spoils
the puzzle and fails to build the skill the CET/DOST-SEI abstract-reasoning
section tests. Here the image is genuinely load-bearing, contradicting the
style guide's assumption that art is only an upgrade.
Fix: add one placeholder per example (20 total), each specifying the exact
figures and the answer options. Prioritize this alongside
`visual-media.md`.

### REAS-MEC-001 [important, high priority] mechanical-technical lessons: same pattern
Evidence: all five mechanical lessons (`gear-rotations.md`,
`pulleys-and-levers.md`, `springs-and-weights.md`, `fluid-pressure.md`,
`structural-stability.md`) have one Core Concept placeholder and 20 example
questions with none. Gear-train direction, pulley setups, lever balance,
and tipping-point questions need the mechanism drawn.
Fix: add one placeholder per example (20 total).

The prose currently describes each setup well enough to limp through, so
these are "important," not "blocker" — but the lessons are half-taught
until the figures exist.

## Coverage vs benchmarks
Complete and well-aligned with the DOST-SEI Abstract / Non-Verbal Reasoning
section and mechanical-reasoning item types. logical-verbal covers
syllogisms, word analogies, number/letter sequences, and truth tables;
spatial-abstract covers series, grouping, matrices, paper folding, and
mental rotation; mechanical covers gears, pulleys/levers, springs, fluid
pressure, and structural stability. No missing tested reasoning type.

logical-verbal-reasoning lessons are text-based and their single
placeholder each is adequate; the sweep correctly did not flag them.

## Template fit — proposal for Reasoning
The five-section template is a poor fit here:
- REAS-TMPL-001 [important] Reasoning lessons teach a *method* applied to a
  figure, not a concept plus computation. "Speed Tricks & Shortcuts" and
  "Mnemonics" rarely apply. A better shape for this subject:
  **Core Concept → Worked Examples (each with its figure) → Common Traps**,
  optionally a **Method / Steps** block. Recommend the style guide sanction
  a reduced three-section layout for reasoning lessons rather than forcing
  the math five.
- Because examples are figure-driven, the style guide's "text must teach
  without the image" rule cannot fully hold for this subject; note the
  documented exception.

## Dismissed sweep lines
None. Every reasoning sweep line is a real illustration gap promoted above;
no false positives in this subject.
