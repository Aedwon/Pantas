Task: plan Task 1.3 for ONE abstract reasoning file, named at the end of this brief, under plan Part 3b rulings. Inputs: docs/superpowers/verification/question-generator/ar-grouping.md (its figure contract and the table for your file) and the source file on prod content via `git show origin/content/bite-sized-cse-algebra-r1:content/questions/reasoning/spatial-abstract-reasoning/<file>.yaml`. Tests first. `flutter test test/tool/generator --no-test-assets`; run build_runner once before run_checks.

Per candidate pattern in your file's table that the report marks exact (Y) and that has figure data (skip paper-fold, no-figure and undrawable-answer singles):
1. Write the rule (tool/generator/lib/src/rules/<file>/), with a doc comment that documents its params, cosmetics and named mistakes. Register it.
2. Write its solver and mistake solvers (tool/generator/lib/src/check/solvers/<file>/) from the doc comment and the figure contract, without reading the rule's code. Add the signature canonicalizer for its figure kind if missing.
3. Write the problem type file under content/types/reasoning/spatial-abstract-reasoning/<lesson-slug>/<qt-id>.yaml with `mergedQuestions` at index 0 for its source question, and `choiceKind`. Choices carry figure data plus text when the answer is a figure; text only when it is a count, condition, order or relation.
4. Run `bin/capacity.dart` on it. Record both numbers in FINDINGS.md at once.
5. If distinct signatures reach 100 or more: generate 100 variants and run the checker until it passes. If not: do not generate a list; record the type as HELD with its two numbers. Do not widen ranges past what the figure contract allows or past "readable"; cosmetics only under Part 3b ruling 2a.
6. Skip series 0019 for now (its source note is being fixed); write its rule only if it shares one with another pattern.

Final message: per type, id, source, distinct ruleKeys, distinct signatures, status (LIST 100 / HELD), checker result; then the verification lines.

File: figure-series. You own the figure-series canonicalizer; register rules under rules/figure_series/.

Lead rulings (Nov 17 00:35 UTC), on the three blockers the first runs found. Continue from FINDINGS.md in the worktree; do not restart.
1. HELD types live in content/types-held/ with the same layout as content/types/. They carry no variant list. The checker parses them (schema and solver registration only) and never requires a list; the exporter will ignore them. A type moves to content/types/ only when it gets a list.
2. Figure solvers now receive the variant slots: fits(shown, candidate, query), where query = variant.slots (commit on the lane branch, merged into your worktree). What the stem asks (queried face, operation, direction) goes in slots and the stem template, never in figure data, so merged questions keep their exact figure maps.
3. Symmetry follows the figure as drawn, not the shape name. A form counts as reflection-symmetric only if the painter draws it with a reflection axis; the drawn parallelogram does not, so it is asymmetric, and so is blob. Ranges use only forms whose drawn symmetry the solver states in one table, and the rule doc comment lists the same table.
4. This run (series) also implements ruling 1 in the checker and CLI (content/types-held/ support, with a planted test: a held type without a list passes, a held type with an unknown rule fails). The other two runs only place files there.
