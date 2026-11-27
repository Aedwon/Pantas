# Figure-marker worker brief (session 5, Nov 27, E-198)

Lead: Claude lesson lead. Policy read: `origin/main` `3fd9fdf0e`. Manager ruling with two conditions (Nov 27, about 3:10 PM).

Why: main's content export (`tools/build_content_export/build_content_export.dart`) stops with "Missing asset-map entry" at any `<!-- ILLUSTRATION: ... -->` marker that has no drawn figure in `content/illustrations/<subject>/<topic>/<lesson>/`. The walk-through rewrites added such markers. The export ignores other HTML comments.

Hard limits: read `docs/content/verification/walkthrough-work/worker-rules.md`, section "Hard limits", and follow it. Edit only with the Edit tool. No scripts, no `sed`, no redirection. Do not start subagents. No git commands that write. Never edit question files. Touch only the files listed below and the worklist file.

## Task

1. For every marker line listed below, change only the opening `<!-- ILLUSTRATION:` to `<!-- FIGURE WANTED:`. Keep the rest of the line, including the description and the closing `-->`, exactly as it is. The line stays one line, so line numbers do not move. Do not touch any other `ILLUSTRATION` marker: the ones not listed have drawn figures and must stay.
2. In each file you changed, read the whole lesson and list every sentence that points at the hidden figure ("the number line below", "see the figure", "in the picture", "the diagram shows", "look at the drawing", "above", "below" used for a figure, and the like). Do not reword them; the lead does that. Report file:line and the sentence.
3. Make sure every hidden marker is on `docs/content/walkthrough-figure-worklist.md`. Many are already there (Batch 1 Mathematics). For each hidden marker not yet on it, append an entry under a new heading `## Hidden by the export fix (Nov 27)`, in the same shape as the existing entries: file path, the section heading it sits under (`## ...` -> `### ...`), then the full marker line as it now reads. Do not edit existing entries.

## Lines to change (file:line, line numbers at `c51d5be13`)

Mathematics:
- content/lessons/mathematics/arithmetic-number-sense/signed-integer-operations.md:22 and :67
- content/lessons/mathematics/arithmetic-number-sense/adding-and-multiplying-fractions.md:21
- content/lessons/mathematics/arithmetic-number-sense/least-common-multiple.md:64
- content/lessons/mathematics/arithmetic-number-sense/substituting-negative-numbers.md:42
- content/lessons/mathematics/arithmetic-number-sense/infinite-geometric-series.md:21
- content/lessons/mathematics/arithmetic-number-sense/percentage-base-and-fraction-division.md:23
- content/lessons/mathematics/arithmetic-number-sense/multiplying-and-dividing-decimals.md:73
- content/lessons/mathematics/arithmetic-number-sense/compound-interest.md:33
- content/lessons/mathematics/arithmetic-number-sense/prime-factors-and-powers.md:49
- content/lessons/mathematics/arithmetic-number-sense/arithmetic-sequence-terms.md:27
- content/lessons/mathematics/arithmetic-number-sense/odd-and-even-position-patterns.md:22
- content/lessons/mathematics/arithmetic-number-sense/successive-percentages-and-increases.md:70
- content/lessons/mathematics/arithmetic-number-sense/partitive-proportion-and-differences.md:23
- content/lessons/mathematics/arithmetic-number-sense/commission-and-sales-tax.md:45
- content/lessons/mathematics/arithmetic-number-sense/inverse-proportion-and-remaining-work.md:73
- content/lessons/mathematics/arithmetic-number-sense/discounted-prices.md:71
- content/lessons/mathematics/arithmetic-number-sense/divisibility-by-seven-and-eleven.md:56
- content/lessons/mathematics/arithmetic-number-sense/markup-on-cost.md:25
- content/lessons/mathematics/data-interpretation/inverse-proportion-and-ratio-parts.md:67
- content/lessons/mathematics/data-interpretation/percentage-change.md:43
- content/lessons/mathematics/algebra/motion-meeting-and-separation.md:58
- content/lessons/mathematics/algebra/mixture-word-problems.md:50
- content/lessons/mathematics/algebra/motion-chase-problems.md:26

Reasoning:
- content/lessons/reasoning/spatial-abstract-reasoning/parallel-light-and-solid-shadows.md:22 and :99
- content/lessons/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets.md:123
- content/lessons/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule.md:96
- content/lessons/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details.md:114
- content/lessons/reasoning/spatial-abstract-reasoning/turning-solids-without-mirror-flips.md:23 and :99
- content/lessons/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features.md:93
- content/lessons/reasoning/spatial-abstract-reasoning/uneven-folds-and-cut-layers.md:103
- content/lessons/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry.md:58
- content/lessons/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts.md:111
- content/lessons/reasoning/spatial-abstract-reasoning/cuts-at-two-fold-lines.md:46 and :96
- content/lessons/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features.md:51 and :106
- content/lessons/reasoning/spatial-abstract-reasoning/figure-turns-and-positions.md:23 and :149
- content/lessons/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules.md:96
- content/lessons/reasoning/spatial-abstract-reasoning/figure-counts-and-fills.md:41 and :129
- content/lessons/reasoning/spatial-abstract-reasoning/unfolding-cuts-across-a-fold.md:50 and :92
- content/lessons/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns.md:46
- content/lessons/reasoning/logical-verbal-reasoning/deductive-group-arguments.md:29

Language Application:
- content/lessons/language-proficiency/language-application/subject-and-verb-checks.md:22
- content/lessons/language-proficiency/language-application/phrases-and-sentence-types.md:51
- content/lessons/language-proficiency/language-application/past-time-checks.md:52

Grammar and Structure (all in content/lessons/language-proficiency/grammar-and-structure/):
- finding-subjects-and-matching-verbs.md:68
- commas-in-lists-and-joined-clauses.md:51
- pokus-at-papel-ng-paksa.md:39
- complex-and-compound-complex-sentences.md:28
- hugnayan-langkapan-at-ayos-ng-salaysay.md:44
- independent-and-dependent-clauses.md:64
- semicolons-and-comma-splices.md:53
- parallel-pairs-and-comparisons.md:53
- relative-clauses-and-main-thoughts.md:44
- capital-letters-in-names-titles-and-quotes.md:35
- pang-uri-at-pang-abay.md:43
- misplaced-modifiers-and-clear-meaning.md:25
- mga-pahiwatig-ng-oras.md:64
- changing-voice-and-get-passives.md:21
- agreement-with-joined-subjects.md:44
- commas-with-openings-and-extra-information.md:48
- keeping-needed-repetition.md:23
- qualified-negatives-and-near-negatives.md:26
- pangalan-kilos-at-pandiwari.md:62
- matching-forms-in-lists.md:27
- dangling-modifiers-and-their-subjects.md:25
- pang-ukol-pangatnig-at-pandamdam.md:43
- payak-at-tambalang-pangungusap.md:46
- present-perfect-links-to-now.md:48
- mga-anyo-ng-panghalip-panao.md:63
- joining-words-phrases-and-clauses.md:51
- ugnayan-ng-pandiwa-at-paksa.md:46
- aspekto-at-paksa-sa-filipino.md:26
- shared-words-in-parallel-lists.md:30
- past-perfect-earlier-completion.md:24

If a listed line is not an `ILLUSTRATION` marker when you open the file, do not guess: report it.

Do not touch `content/lessons/mathematics/data-interpretation/chart-scales-and-differences.md` (its marker has a drawn figure) or any Reading Comprehension lesson (writers are editing those).

## Report (short)

Number of markers changed (expected 80: Mathematics 23, Reasoning 24, Language Application 3, Grammar 30), any listed line that was not a marker, the pointing sentences (file:line and text), and the worklist entries added (count). Files touched.
