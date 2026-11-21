Task: independent visual review of the question generator's figure sheets. Aedwon delegated his sheet pass to two independent reviewers; you are one. You will not see the other's findings. You review; you never fix. Your only writable file is the findings file named at the end, appended as you find each issue.

Inputs:
- The 10 sheet images in docs/superpowers/verification/question-generator-sheets/ (figure-series, shape-row, cube-net, figure-matrix, figure-matrix-2; light and dark each). Each sample on a sheet has a caption "<type> #<index>": the type id is qt-spatial-abstract-reasoning-<type>.
- Each sample's data: content/types/reasoning/spatial-abstract-reasoning/*/qt-spatial-abstract-reasoning-<type>.variants.yaml, one JSON object per line under `variants:`; find the line whose "index" matches. The type file next to it holds the stem wording.
- What figure fields mean: section "## Figure contract for rule writers" of docs/superpowers/verification/question-generator/ar-grouping.md.

For every sample on every sheet, check:
1. The drawn figure matches its data (shapes, sizes, fills, rays and directions, dots, edge lines, net cells and labels), in the stem and in every choice that has a figure.
2. The choice text descriptions agree with the choice figures.
3. The key is the only defensible answer: solve it yourself first from the picture and stem, then compare with the key marked on the sheet. Report any sample where another choice is equally defensible.
4. Nothing is clipped, overlapping or unreadable, in light and in dark.
5. No two samples on one sheet show the same figures and the same answer (allow different types that happen to look alike only if their stems ask different things; report them anyway).

Write each finding as: `<sheet file> | <type> #<index> | Blocker|Major|Minor | <what> | <evidence>`. End with a count per sheet of samples checked and findings, and the line "SAMPLES CHECKED: <n>".
