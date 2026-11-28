# Figure answer choices: implementation plan

Spec: `docs/superpowers/specs/2026-11-18-figure-answer-choices-design.md` (Part A approved
Nov 18, scope Minimal). Decision log: `docs/superpowers/decisions/2026-11-17-figure-answer-choices-log.md`.
Boards: https://claude.ai/artifact/1ceeLDYSix7tSyP6fUSFv2 version 6, Option 2 only.
Policy: origin/main 7da59dda4 or later. Claude workers only (UI). Base: origin/main.

## Phase 1: drawing fixes and the numbered row (E-117), ships alone

Branch `fix/figure-painters-r1` from origin/main. One worker, one worktree.

| File | Change |
|---|---|
| `lib/core/ui/figures/figure_series_figure.dart` | dot row clear of every line angle in use |
| `lib/core/ui/figures/figure_matrix_figure.dart` | dot radius and spacing fit the cell's form and size; wrap to two rows if needed |
| `lib/core/ui/figures/shape_row_figure.dart` | position numbers 1 to N under the shapes, figure font, figure ink |
| `test/core/ui/figures/*_test.dart` | geometry tests below, written first |
| one offscreen sheet per painter (light and dark) | for Aedwon's check; path reported, not committed if generated |

Geometry tests (fail first on the current painters):
1. Series: every form, dots 0 to 5, line angles 0 to 315 in 45 steps, each line in `lines`:
   no dot centre within dot radius + 1px of any line segment. Series 0018 data reproduced.
2. Matrix: every form at every size with 1 to 5 dots: gap between dots >= one dot diameter,
   gap from outline >= one dot radius; matrices 0008 data reproduced.
3. Shape row: N labels drawn, centred under each shape, inside the canvas, not overlapping
   shapes, for N = 3 to 5. Semantics label of the figure unchanged.
Checks: focused tests, `flutter analyze`, format, layering, attribution,
`dart run tool/checks/run_checks.dart`. Stop if a figure's data must change.

## Phase 2: figure choice tiles (E-118)

Branch `feat/figure-choice-tiles-r1` from origin/main. Starts after the generator lead names
the app field carrying per-choice figures (asked Nov 18); until then the input is a nullable
item map per choice plus the question's figure kind.

1. Single-item painters: draw one item of figure-series, figure-matrix, shape-row (and
   cube-net, paper-fold where the item shape exists) at tile size, reusing the painters.
2. `FigureChoiceTile` group, phone and web, states per O2_States; semantics per spec Part B.
3. Surface switch: tiles when every choice has a drawable figure, rows otherwise; odd-one-out
   flag hides the question figure. Surfaces: quiz page and viewer, mock session and review,
   assessment (phone and web), in-lesson quiz, review lists.
4. Goldens: one sheet per surface, phone (360 and 390) and wide, light and dark.
5. Widget tests: names and suffixes, roving focus, scoped letter keys, aria-disabled after
   reveal, fallback to rows.
6. Independent Claude reviewer: component use and the look against the O2 boards.

## Integration

The lead reviews each result, runs the full check set on the combined branch, pushes, and
asks the DS4 release candidate lane (the integrator) to merge and deploy to staging. Prod
waits for Aedwon's "ship it".
