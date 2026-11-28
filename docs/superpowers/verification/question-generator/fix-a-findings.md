# R1 and audit A corrections, November 17

- Policy: origin/main 2bd4a95172704b228c5cc6e00a67a5597d2536a4, verified against `git ls-remote origin refs/heads/main`; descends from 1295c1866. Fetch cannot update external FETCH_HEAD, but remote and local main agree. Initial working tree clean.
- R1 root cause: series, matrix, net and generic canonicalizers include all choices; shape rows preserve row order except reversal. Distractor changes and row permutations therefore inflate measured capacity. Series ruleKey also includes distractor-only extraForm.
- Scope: shared R1, audit A series/grouping corrections and R5. No UI, source questions, net rules or matrix rules will change. Existing lists require tool regeneration after signature changes.
- Verification prerequisite: exact `flutter test test/tool/generator` fails before tests because assets/seed/content.db is absent. Generator tests do not consume app assets, so focused runs use `--no-test-assets`; no protected package is regenerated.
- R1 planted tests fail on the original implementation for distractor-only changes, unordered grouping rows, distractor-only ruleKey slots and capacity inflation. Updated all figure canonicalizers to use the correct answer only, preserving per-kind task query data; grouping rows use a marked unordered multiset. Grouping ruleKey parameter rows are sorted independently in generator and solver.
- R1: all seven planted regression tests now pass. They cover distractor-independent signatures for series/matrix/net/grouping, correct-answer identity, arbitrary grouping permutations, extraForm exclusion and capacity deduplication.
- Audit A: added failing tests for the interleaved doubling ambiguity, non-square corner walks, inaccurate ray restart notes, generated position-only medium distractors, tied maximum counts, repeated hexagon cues and the incorrect regular-polygon wording. Fixes retain literal source data and choice text.

## Needs the lead

- Prod grouping 0006 itself uses three identical pentagons and three position-only distractors. Distinct feature mistakes cannot reproduce that source. Keep its reserved draw exact, exclude that profile from new draws, and hold the medium type. Route source correction to the content lane. Other work continues.
- Prod series 0017 admits additive and doubling continuations. The independent library now includes doubling count tracks; the source must be held and routed to the content lane per R2.

- R5 measured series-corner-edge-count: 8 ruleKeys, 40 task signatures in 2000 draws (seed 20261117).
- R5 measured series-dots-size: 18 ruleKeys, 90 task signatures in 2000 draws (seed 20261117).
- R5 measured series-outline-triple: 12 ruleKeys, 12 task signatures in 2000 draws (seed 20261117).
- R5 measured series-size-fill: 2 ruleKeys, 10 task signatures in 2000 draws (seed 20261117).
- R5 measured series-transfer-count: 9 ruleKeys, 45 task signatures in 2000 draws (seed 20261117).
- R5 measured series-binary-fill: 6 ruleKeys, 24 task signatures in 2000 draws (seed 20261117).
- R5 measured series-double-fill: 5 ruleKeys, 5 task signatures in 2000 draws (seed 20261117).
- R5 measured series-two-fill-steps: 3 ruleKeys, 12 task signatures in 2000 draws (seed 20261117).
- R5 measured series-arrow-alternation: 4 ruleKeys, 14 task signatures in 2000 draws (seed 20261117).
- R5 measured series-two-arrow-turns: 4 ruleKeys, 14 task signatures in 2000 draws (seed 20261117).
- R5 measured net-all-opposites: 7 ruleKeys, 7 task signatures in 2000 draws (seed 20261117).
- R5 measured net-nonadjacent: 67 ruleKeys, 52 task signatures in 2000 draws (seed 20261117).
- R5 measured net-opposite-easy: 133 ruleKeys, 52 task signatures in 2000 draws (seed 20261117).
- R5 measured net-opposite-medium: 66 ruleKeys, 52 task signatures in 2000 draws (seed 20261117).
- R5 measured net-overlap-medium: 8 ruleKeys, 4 task signatures in 2000 draws (seed 20261117).
- R5 measured net-strip-first-overlap: 1 ruleKeys, 1 task signatures in 2000 draws (seed 20261117).
- R5 measured net-three-at-corner: 89 ruleKeys, 64 task signatures in 2000 draws (seed 20261117).
- R5 measured net-top-and-shadow: 67 ruleKeys, 52 task signatures in 2000 draws (seed 20261117).
- R5 measured net-validity-test: 25 ruleKeys, 24 task signatures in 2000 draws (seed 20261117).
- R5 measured group-outline-symmetry: 5 ruleKeys, 5 task signatures in 2000 draws (seed 20261117).
- R5 measured group-line-count: 20 ruleKeys, 20 task signatures in 2000 draws (seed 20261117).
- R5 measured group-region-parity: 1 ruleKeys, 1 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-fill-union: 12 ruleKeys, 24 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-corner-grid: 6 ruleKeys, 28 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-size-columns: 80 ruleKeys, 10 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-size-fill: 12 ruleKeys, 40 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-arrow-column: 6 ruleKeys, 30 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-growing-turn: 16 ruleKeys, 80 task signatures in 2000 draws (seed 20261117).
- R5 measured series-fill-ray-dots: 288 ruleKeys, 995 task signatures in 2000 draws (seed 20261117).
- R5 measured series-four-tracks: 1424 ruleKeys, 1424 task signatures in 2000 draws (seed 20261117).
- R5 measured series-interleaved-count: 240 ruleKeys, 240 task signatures in 2000 draws (seed 20261117).
- Held series-interleaved-count: source defect recorded under Needs the lead. Removed its obsolete active list.
- R5 measured series-size-corner-ray: 192 ruleKeys, 48 task signatures in 2000 draws (seed 20261117).
- Held series-size-corner-ray: fewer than 100 measured signatures. Removed its obsolete active list.
- R5 measured series-ray-step: 56 ruleKeys, 196 task signatures in 2000 draws (seed 20261117).
- R5 measured net-adjacent-relation: 132 ruleKeys, 104 task signatures in 2000 draws (seed 20261117).
- R5 measured net-opposite-hard: 325 ruleKeys, 249 task signatures in 2000 draws (seed 20261117).
- R5 measured group-boundary: 42 ruleKeys, 42 task signatures in 2000 draws (seed 20261117).
- Held group-boundary: fewer than 100 measured signatures. Removed its obsolete active list.
- R5 measured group-polygon-replacement: 539 ruleKeys, 539 task signatures in 2000 draws (seed 20261117).
- R5 measured group-side-count-easy: 12 ruleKeys, 12 task signatures in 2000 draws (seed 20261117).
- Held group-side-count-easy: fewer than 100 measured signatures. Removed its obsolete active list.
- R5 measured group-side-count-medium: 13 ruleKeys, 13 task signatures in 2000 draws (seed 20261117).
- Held group-side-count-medium: fewer than 100 measured signatures. Removed its obsolete active list.
- R5 measured group-side-parity: 12 ruleKeys, 12 task signatures in 2000 draws (seed 20261117).
- Held group-side-parity: fewer than 100 measured signatures. Removed its obsolete active list.
- R5 measured group-center-cuts: 21 ruleKeys, 21 task signatures in 2000 draws (seed 20261117).
- Held group-center-cuts: fewer than 100 measured signatures. Removed its obsolete active list.
- R5 measured group-dot-count: 1869 ruleKeys, 1869 task signatures in 2000 draws (seed 20261117).
- R5 measured group-dot-parity: 1435 ruleKeys, 1435 task signatures in 2000 draws (seed 20261117).
- R5 measured group-side-double-dots: 68 ruleKeys, 68 task signatures in 2000 draws (seed 20261117).
- Held group-side-double-dots: fewer than 100 measured signatures. Removed its obsolete active list.
- R5 measured matrix-dot-sum: 491 ruleKeys, 1380 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-ray-union: 1964 ruleKeys, 1964 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-sized-ray-union: 112 ruleKeys, 549 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-ray-intersection: 2000 ruleKeys, 2000 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-binary-fill-row: 240 ruleKeys, 32 task signatures in 2000 draws (seed 20261117).- Shared R1 also exposes matrix-binary-fill-row capacity: 32 task signatures, below 100. Its attempted clean regeneration stops at index 32 with 1,000 duplicate draws. This is a shared-signature consequence, not a matrix rule change. Hold it rather than retain its invalid inflated list. Matrix/net rules remain untouched.
- Local minor fixes: easy side-count and boundary draws now reject repeated identical outlines, and dot-parity requires one hexagon so its named cue distinguishes that choice. The polygon-replacement type intentionally retains three real curved-boundary mistakes; its shown row plus replacement has more than 100 distinct tasks, measured below. Changing that question's reasoning demand requires a lead decision, so no new rule was invented.

- R5 measured matrix-binary-fill-row: 240 ruleKeys, 32 task signatures in 2000 draws (seed 20261117).
- Held matrix-binary-fill-row: fewer than 100 measured signatures. Removed its obsolete active list.
- R5 measured matrix-form-ray: 1609 ruleKeys, 1329 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-outline-latin: 622 ruleKeys, 356 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-size-dots: 24 ruleKeys, 120 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-size-latin: 311 ruleKeys, 72 task signatures in 2000 draws (seed 20261117).
- Held matrix-size-latin: fewer than 100 measured signatures. Removed its obsolete active list.
- R5 measured matrix-size-transfer: 160 ruleKeys, 738 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-corner-reflection: 144 ruleKeys, 144 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-corner-step: 120 ruleKeys, 120 task signatures in 2000 draws (seed 20261117).
- R5 measured matrix-ray-turn: 1409 ruleKeys, 1409 task signatures in 2000 draws (seed 20261117).
- R5 measured group-specific-rule: 45 ruleKeys, 45 task signatures in 2000 draws (seed 20261117).
- Held group-specific-rule: fewer than 100 measured signatures. Removed its obsolete active list.- R5: all series, grouping, matrix and net types measured at the same 2,000-draw ceiling and seed. Active lists regenerated with the revised signature, preserving reserved source data and choice text. Eight audit-A types were held for insufficient measured capacity; interleaved-count was held for source ambiguity, nine held total. Shared R1 also forces holding matrix-size-latin (72), alongside binary-fill-row (32); no matrix/net rule changed.
- Audit minor disposition: specific-rule's low variety is held (45 signatures), side-parity (12), center-cuts (21), and easy side-count (12). Polygon-replacement retains its three named curved-boundary errors because all remain true; improving how much of the row students must inspect changes the rule and is deferred to the lead.
- Added independent doubling solvers for every additive series count track, including the held interleaved source. New non-source interleaved draws reject initial odd count 1, so no wrong choice completes the competing doubling rule. Remeasurement supersedes its earlier count: 161 ruleKeys and 161 signatures in 2,000 draws; index 0 still intentionally fails correctness and remains held.
- Follow-up R1 planted test shows number-only signatures must include the correct value as well as the shown number slots. The shared math signature now includes that value with exact-rational normalization. No math production types exist here.
- Fresh worktree prerequisite: run_checks initially could not compile because generated Question/Choice parts were absent. Running the repository's build_runner command creates ignored generated files; none is hand-edited or staged.
- R1 metadata follow-up: planted tests also fail on matrix extraForm and net profile in stored ruleKeys. Added a shared taskRuleKey hashing boundary used by generation, checking and capacity. It excludes matrix/series extraForm and net distractor profile without editing their rules or solvers. Regenerating matrix/net metadata and remeasuring their keys below; signature counts are unchanged.

- R1 final matrix/net measurement net-all-opposites: 7 ruleKeys, 7 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-nonadjacent: 67 ruleKeys, 52 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-opposite-easy: 67 ruleKeys, 52 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-opposite-medium: 66 ruleKeys, 52 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-overlap-medium: 8 ruleKeys, 4 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-strip-first-overlap: 1 ruleKeys, 1 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-three-at-corner: 89 ruleKeys, 64 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-top-and-shadow: 67 ruleKeys, 52 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-validity-test: 25 ruleKeys, 24 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-fill-union: 12 ruleKeys, 24 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-binary-fill-row: 60 ruleKeys, 32 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-corner-grid: 6 ruleKeys, 28 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-size-columns: 20 ruleKeys, 10 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-size-fill: 12 ruleKeys, 40 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-size-latin: 90 ruleKeys, 72 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-arrow-column: 6 ruleKeys, 30 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-growing-turn: 16 ruleKeys, 80 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-adjacent-relation: 132 ruleKeys, 104 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement net-opposite-hard: 325 ruleKeys, 249 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-dot-sum: 491 ruleKeys, 1380 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-ray-union: 1964 ruleKeys, 1964 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-sized-ray-union: 112 ruleKeys, 549 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-ray-intersection: 2000 ruleKeys, 2000 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-form-ray: 1609 ruleKeys, 1329 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-outline-latin: 356 ruleKeys, 356 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-size-dots: 24 ruleKeys, 120 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-size-transfer: 160 ruleKeys, 738 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-corner-reflection: 144 ruleKeys, 144 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-corner-step: 120 ruleKeys, 120 task signatures in 2000 draws (seed 20261117).
- R1 final matrix/net measurement matrix-ray-turn: 1409 ruleKeys, 1409 task signatures in 2000 draws (seed 20261117).- Final verification caught the net rule's direct-draw metadata hash still using the old parameters, although generated lists already used the shared hash. Ten direct-draw solver tests failed on ruleKey mismatch. Routed that single metadata assignment through taskRuleKey too. No net generation, rule, note, geometry or solver behavior changed; regenerated bytes remain identical.


## Consolidated final capacity

Measured draws, not theoretical estimates. Seed 20261117, ceiling 2,000 per type. Later values below supersede earlier measurements.

| Type rule | Rule keys | Task signatures | Disposition |
|---|---:|---:|---|
| group-boundary | 42 | 42 | held |
| group-center-cuts | 21 | 21 | held |
| group-dot-count | 1869 | 1869 | active |
| group-dot-parity | 1435 | 1435 | active |
| group-line-count | 20 | 20 | held |
| group-outline-symmetry | 5 | 5 | held |
| group-polygon-replacement | 539 | 539 | active |
| group-region-parity | 1 | 1 | held |
| group-side-count-easy | 12 | 12 | held |
| group-side-count-medium | 13 | 13 | held |
| group-side-double-dots | 68 | 68 | held |
| group-side-parity | 12 | 12 | held |
| group-specific-rule | 45 | 45 | held |
| matrix-arrow-column | 6 | 30 | held |
| matrix-binary-fill-row | 60 | 32 | held |
| matrix-corner-grid | 6 | 28 | held |
| matrix-corner-reflection | 144 | 144 | active |
| matrix-corner-step | 120 | 120 | active |
| matrix-dot-sum | 491 | 1380 | active |
| matrix-fill-union | 12 | 24 | held |
| matrix-form-ray | 1609 | 1329 | active |
| matrix-growing-turn | 16 | 80 | held |
| matrix-outline-latin | 356 | 356 | active |
| matrix-ray-intersection | 2000 | 2000 | active |
| matrix-ray-turn | 1409 | 1409 | active |
| matrix-ray-union | 1964 | 1964 | active |
| matrix-size-columns | 20 | 10 | held |
| matrix-size-dots | 24 | 120 | active |
| matrix-size-fill | 12 | 40 | held |
| matrix-size-latin | 90 | 72 | held |
| matrix-size-transfer | 160 | 738 | active |
| matrix-sized-ray-union | 112 | 549 | active |
| net-adjacent-relation | 132 | 104 | active |
| net-all-opposites | 7 | 7 | held |
| net-nonadjacent | 67 | 52 | held |
| net-opposite-easy | 67 | 52 | held |
| net-opposite-hard | 325 | 249 | active |
| net-opposite-medium | 66 | 52 | held |
| net-overlap-medium | 8 | 4 | held |
| net-strip-first-overlap | 1 | 1 | held |
| net-three-at-corner | 89 | 64 | held |
| net-top-and-shadow | 67 | 52 | held |
| net-validity-test | 25 | 24 | held |
| series-arrow-alternation | 4 | 14 | held |
| series-binary-fill | 6 | 24 | held |
| series-corner-edge-count | 8 | 40 | held |
| series-dots-size | 18 | 90 | held |
| series-double-fill | 5 | 5 | held |
| series-fill-ray-dots | 288 | 995 | active |
| series-four-tracks | 1424 | 1424 | active |
| series-interleaved-count | 161 | 161 | held |
| series-outline-triple | 12 | 12 | held |
| series-ray-step | 56 | 196 | active |
| series-size-corner-ray | 192 | 48 | held |
| series-size-fill | 2 | 10 | held |
| series-transfer-count | 9 | 45 | held |
| series-two-arrow-turns | 4 | 14 | held |
| series-two-fill-steps | 3 | 12 | held |

## Candidate identity and scope

- Base: 1ec5b91014321e9b00c3ae92042e92486568a534. Prod source: 88f38e698ee80448fde1a795638f794b68db4cfd. All source questions were read through git show/readSourceQuestions at that ref.
- Regeneration used measureCapacity, generateVariants(count: 100), and writeVariantList from a temporary batch runner in this worktree. The runner was removed after its outputs were written. No variants were hand-edited.
- No UI, source question, dependency, matrix rule or net behavior changes. The sole net source edit routes its metadata hash through the shared R1 function. No staging or commits.

## Files touched

```text
 M content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-fill-ray-dots.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-four-tracks.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.yaml
 D content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-size-corner-ray.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-size-corner-ray.yaml
 M content/types/reasoning/spatial-abstract-reasoning/figure-turns-and-positions/qt-spatial-abstract-reasoning-series-ray-step.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/figure-turns-and-positions/qt-spatial-abstract-reasoning-series-ray-step.yaml
 M content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-adjacent-relation.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-opposite-hard.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-boundary.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-boundary.yaml
 M content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-polygon-replacement.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-easy.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-easy.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-medium.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-medium.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-parity.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-parity.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-center-cuts.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-center-cuts.yaml
 M content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-dot-count.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-dot-parity.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-side-double-dots.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-side-double-dots.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-ray-union.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-sized-ray-union.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-binary-fill-row.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-binary-fill-row.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-form-ray.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-outline-latin.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-dots.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-latin.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-latin.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-transfer.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-corner-reflection.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-corner-step.variants.yaml
 M content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-ray-turn.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule/qt-spatial-abstract-reasoning-group-specific-rule.variants.yaml
 D content/types/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule/qt-spatial-abstract-reasoning-group-specific-rule.yaml
 M test/tool/generator/cube_net_signature_test.dart
 M test/tool/generator/grouping_rules_test.dart
 M test/tool/generator/series_rules_test.dart
 M tool/generator/lib/src/capacity.dart
 M tool/generator/lib/src/check/check.dart
 M tool/generator/lib/src/check/cube_net_signature.dart
 M tool/generator/lib/src/check/matrix_signature.dart
 M tool/generator/lib/src/check/series_signature.dart
 M tool/generator/lib/src/check/shape_row_signature.dart
 M tool/generator/lib/src/check/signature.dart
 M tool/generator/lib/src/check/solvers/figure_grouping/grouping_solver.dart
 M tool/generator/lib/src/check/solvers/figure_series/series_solver.dart
 M tool/generator/lib/src/check/solvers/solver.dart
 M tool/generator/lib/src/generate.dart
 M tool/generator/lib/src/rules/figure_grouping/grouping.dart
 M tool/generator/lib/src/rules/figure_series/series.dart
 M tool/generator/lib/src/rules/mental_rotation/nets.dart
?? FINDINGS.md
?? content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-size-corner-ray.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-boundary.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-easy.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-medium.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-parity.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-center-cuts.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-side-double-dots.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-binary-fill-row.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-latin.yaml
?? content/types-held/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule/
?? test/tool/generator/audit_a_regression_test.dart
?? test/tool/generator/task_signature_test.dart
?? tool/generator/lib/src/rule_key.dart
```

## Verification evidence

- Tests first: planted failures observed for R1 distractor signatures, grouping permutation, extraForm/profile ruleKeys, capacity deduplication, correct numeric answer, doubling source ambiguity, generated doubling draws, non-square corners, the independent corner solver, ray notes, generated positional mistakes, tied maxima, repeated hexagon cues, duplicate-outline diagnoses and regular-polygon wording. Fixes pass their regressions.
- `flutter test test/tool/generator`: FAIL before tests, `No file or variants found for asset: assets/seed/content.db.` / `Error: Failed to build asset bundle`. No protected package was rebuilt.
- `flutter test --no-test-assets test/tool/generator`: PASS, `02:20 +201: All tests passed!`, exit 0. Includes reserved production-source comparisons for every merged type, including held types. The ambiguous interleaved source intentionally fails correctness while retaining exact source data and choices.
- `flutter analyze tool/generator test/tool/generator`: PASS, `No issues found! (ran in 3.6s)`, exit 0.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: PASS, `Formatted 53 files (0 changed) in 0.33 seconds.`, exit 0.
- `dart run tool/check_no_ai_attribution.dart`: PASS, `check_no_ai_attribution: OK`, exit 0.
- `git diff --check`: PASS, exit 0. `git diff --cached --name-only`: empty. No changes under lib/, content/questions/, or dependency manifests.

## Remaining lead work

- Route source series 0017 and grouping 0006 to the content lane. Both source defects remain held; no source question was edited.
- Nine audit-A types are held total: eight below 100 signatures, plus the ambiguous interleaved source. Shared R1 additionally holds matrix-binary-fill-row and matrix-size-latin below 100. Their rules were not widened.
- Polygon-replacement's fixed three curved distractors remain a minor limitation. All three mistakes are meaningful and true; changing the reasoning demand needs the lead.
- Independent approval, blind solves, source content approval and release remain the lead's work. This worker has staged and committed nothing.

Implementation fingerprint (SHA-256 of sorted changed paths and bytes, including untracked files and deletion markers; excludes this findings file): `e38966dfe6c517e631ae1ed8b9264cbd583cf49cff46ded7c37579ca52418b03`.
- `dart run tool/checks/run_checks.dart`: PASS, exit 0. Actual output includes `OK    generated-types`, `OK    content-approval`, and every registered check through `OK    legal-text-drafting`. All 1,900 active variants pass the independent checker at the final implementation fingerprint.

## Verification follow-up, November 17

- Review supplied no findings, so no implementation fix is requested or rejected. Existing uncommitted work is preserved.
- Startup refreshed policy at origin/main 2bd4a95172704b228c5cc6e00a67a5597d2536a4. Fetch cannot write the external FETCH_HEAD; git ls-remote confirms remote main equals the local policy ref. Required verification is being rerun in this sandbox.
- Fresh results: exact flutter test command exits 1 before tests: `No file or variants found for asset: assets/seed/content.db.` / `Error: Failed to build asset bundle`. This differs from the reviewer's SDK write blocker. No seed is fabricated or regenerated.
- Fresh analyze: PASS, exit 0, `No issues found! (ran in 4.7s)`. Format: PASS, exit 0, `Formatted 53 files (0 changed) in 0.07 seconds.` Attribution: PASS, exit 0, `check_no_ai_attribution: OK`.
- Fresh repository checks: PASS, exit 0. Actual summary lines: `OK    generated-types`, `OK    content-approval`, and all registered checks through `OK    legal-text-drafting`. Existing accepted exceptions were printed by the checker. `git diff --check` passes; index remains empty.
- Supplemental generator tests: `flutter test --no-test-assets test/tool/generator` PASS, exit 0, `01:24 +201: All tests passed!`. Includes production-source reproduction checks and planted R1/audit A regressions. This supplemental pass does not convert the exact asset-dependent command into a pass.
- Follow-up touched only FINDINGS.md. No implementation edits, rejected findings, staging, commits, UI changes, source question changes, or regenerated assets. Exact test command remains blocked by the absent pinned seed; lead source-content and approval work listed above remains unchanged.
