Task: the first step of plan Task 1.3, for all five abstract reasoning files, as one read-only analysis. Write no code. Your only output file is docs/superpowers/verification/question-generator/ar-grouping.md, appended as you go.

Read each file on prod content: `git show origin/content/bite-sized-cse-algebra-r1:content/questions/reasoning/spatial-abstract-reasoning/<file>.yaml` for figure-series, figure-matrices, figure-grouping, paper-folding-and-cutting, mental-rotation-3d-visualization.

First, document the figure data each kind accepts (figure-series, figure-matrix, shape-row, paper-fold, cube-net), from the parsers and widgets in lib/core/ui/figures/ (field names, allowed values, limits). Keep it short: the rule writers need it.

Then per file:
1. Group the questions by pattern (the rule a solver would apply). For each group: a proposed problem type id (qt-...), lesson, key point, difficulty, the rule in one sentence, its parameters and ranges, the named mistakes (from the hand-written wrong choices), which question ids merge, and whether the rule can reproduce each exactly (stem wording, figure data, correct choice, the set of wrong choices). A question the rule cannot reproduce exactly stays a single.
2. List the singles and why (no figure data, one-off pattern, text-only, would need a new figure kind).
3. Estimate how many distinct variants each type can make within its ranges before signatures repeat (rotations and mirror images count as repeats). Flag any type that cannot reach 100, which is the plan's start size.
4. Flag any question whose key looks wrong or that has a second defensible answer, with the reason.

Be concrete and brief. Do not invent figure fields the widgets do not accept.
