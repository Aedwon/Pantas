# Task 1.4 read-only audit, round 1c

Candidate: `96190a3e2db0941daf394adc8d7297020bc7d5a1`. Policy: local `origin/main` at `17f514bfb6224fa4caeb51fcc5efc2ed32da7885`, verified descendant of `1295c1866`. Source questions: requested `origin/content/bite-sized-cse-algebra-r1` at `88f38e698ee80448fde1a795638f794b68db4cfd`. Revision 1 and adviser rulings read on origin/main. Only this findings file may be written; no fixes, staging, or commits.

## Needs the lead

- Policy refresh limitation: `git fetch origin main` failed before contacting origin because the sandbox denies writes to the shared Git directory's `FETCH_HEAD`. The explicitly requested local origin/main files are readable and meet the minimum policy revision; their remote freshness cannot be confirmed here. Audit proceeds against that identified revision.

## Findings

## Verification limitation, recorded before substantive auditing

All five requested commands were attempted first. Each exited 1 before its checks started. Common output:

```text
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 71: /opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.<pid>: Operation not permitted
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 78: /opt/homebrew/share/flutter/bin/cache/engine.realm: Operation not permitted
```

- `flutter test test/tool/generator`: exit 1, stamp pid 12015.
- `flutter analyze tool/generator test/tool/generator`: exit 1, stamp pid 12011.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: exit 1, stamp pid 12004.
- `dart run tool/checks/run_checks.dart`: exit 1, stamp pid 12030.
- `dart run tool/check_no_ai_attribution.dart`: exit 1, stamp pid 12009.

Needs the lead: obtain executable gate evidence in an environment allowed to initialize the SDK cache. These failures do not establish a code defect and do not block the remaining read-only audit.

qt-spatial-abstract-reasoning-net-nonadjacent | Major | Named mistakes lose their geometric premise under the shared nearest-face fallback. At index 5 the queried A is (0,1), but flat-top-neighbor selects C=(1,1), below A; sideways-fold-separates selects diagonal B=(1,0); lower-neighbor selects E=(2,2), not a direct lower neighbor. All three generated notes use the same generic side-face warning, so they do not state the specific named slip or explain these choices. The rule and solver validate the same fallback selection instead of the named misconception. | evidence: content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-nonadjacent.variants.yaml, indexes 5; tool/generator/lib/src/rules/mental_rotation/nets.dart, _wrong/_note; tool/generator/lib/src/check/solvers/mental_rotation/net_solver.dart, wrongFaces.

qt-spatial-abstract-reasoning-net-opposite-easy | Major | Generated mistakes no longer consistently name the selected faces. At index 20, queried E=(2,2), left-arm-is-top selects C=(1,1), a diagonal cell; stop-at-lower-neighbor selects F=(3,1), also diagonal. At index 5, profile 1 queries C=(1,1) in a bent net with no four-square straight strip, yet still names pick-next-strip-side and pick-branch-support. Generated notes replace the three specific errors with the same generic side-face warning. This repeats the fallback defect previously found for opposite-hard, now in this active type. | evidence: content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-opposite-easy.variants.yaml, indexes 5,20; tool/generator/lib/src/rules/mental_rotation/nets.dart, _wrong/_note; tool/generator/lib/src/check/solvers/mental_rotation/net_solver.dart, wrongFaces.

qt-spatial-abstract-reasoning-net-opposite-medium | Major | flat-column-ends-opposite does not always select a column end, or even a face in the queried column. At index 15, query E=(2,2), and the named choice is D=(2,1), the immediate left neighbor. No other cell is in E's column, so the rule falls back to nearest graph distance. Its note is the same generic side-face warning as the other two mistakes and never supplies a column-end misconception. | evidence: content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-opposite-medium.variants.yaml, indexes 15; tool/generator/lib/src/rules/mental_rotation/nets.dart, _wrong/_note; tool/generator/lib/src/check/solvers/mental_rotation/net_solver.dart, wrongFaces.

qt-spatial-abstract-reasoning-net-top-and-shadow | Major | The generated note falsely calls nonneighbor faces a flat neighbor, and uses one generic note for all three different errors. At index 41 the bottom is F=(3,1); rectangle choice E=(2,2) is diagonal and diamond choice B=(0,1) is three cells away. Both notes say "The flat neighbor looks like a top face." For the rectangle, "stops at a side face or uses a slanted outline" also fails to name the stated unequal-side error. The generator and solver allow nearest-face fallbacks without preserving the direct-neighbor premise of the source mistakes. | evidence: content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-top-and-shadow.variants.yaml, indexes 41; tool/generator/lib/src/rules/mental_rotation/nets.dart, _wrong/_note; tool/generator/lib/src/check/solvers/mental_rotation/net_solver.dart, wrongFaces.

## Independent whole-list inspection

Python standard-library inspection read the committed JSON variant rows, with no generator/solver import. A separate 3D folding calculation checked every key; D4 comparison normalized cells, queried faces and answer coordinates while ignoring labels and wrong choices. The requested prod YAML was decoded read-only with Ruby YAML.

```text
adjacent-relation: 25 variants, 25 stored ruleKeys, 25 independent D4 tasks, 11 raw layouts, key/geometry/voice errors=[], source=[(0, {'figure': True, 'stem': True, 'explanation': True, 'key': True, 'choices': True, 'notes': True})]
nonadjacent: 52 variants, 52 stored ruleKeys, 52 independent D4 tasks, 12 raw layouts, key/geometry/voice errors=[], source=[(0, {'figure': True, 'stem': True, 'explanation': True, 'key': True, 'choices': True, 'notes': True})]
opposite-easy: 52 variants, 52 stored ruleKeys, 52 independent D4 tasks, 12 raw layouts, key/geometry/voice errors=[], source=[(0, {'figure': True, 'stem': True, 'explanation': True, 'key': True, 'choices': True, 'notes': True}), (1, {'figure': True, 'stem': True, 'explanation': True, 'key': True, 'choices': True, 'notes': True})]
opposite-medium: 52 variants, 52 stored ruleKeys, 52 independent D4 tasks, 11 raw layouts, key/geometry/voice errors=[], source=[(0, {'figure': True, 'stem': True, 'explanation': True, 'key': True, 'choices': True, 'notes': True})]
three-at-corner: 64 variants, 64 stored ruleKeys, 64 independent D4 tasks, 12 raw layouts, key/geometry/voice errors=[], source=[(0, {'figure': True, 'stem': True, 'explanation': True, 'key': True, 'choices': True, 'notes': True})]
top-and-shadow: 52 variants, 52 stored ruleKeys, 52 independent D4 tasks, 12 raw layouts, key/geometry/voice errors=[], source=[(0, {'figure': True, 'stem': True, 'explanation': True, 'key': True, 'choices': True, 'notes': True})]
validity-test: 24 variants, 24 stored ruleKeys, 24 independent D4 tasks, 24 raw layouts, key/geometry/voice errors=[], source=[(0, {'figure': True, 'stem': True, 'explanation': True, 'key': True, 'choices': True, 'notes': True})]
```

These are supplemental read-only checks, not substitutes for the blocked Dart gates.

Correction to net-opposite-easy index-5 evidence above: B, C, D, E form a four-square vertical strip. The earlier statement that there is no straight strip is incorrect. The relevant defect is that queried C is an internal strip cell, rather than the end-closing branch face queried by source profile 1. pick-branch-support selects A, which is not a strip support for the opposite end-closing face. The independent index-20 directional counterexample remains unchanged and establishes the Major.

qt-spatial-abstract-reasoning-net-validity-test | Minor | All 24 versions ask the same general test-selection question with exactly the same four choices and key. The particular net never changes which test is valid, so a student can answer the entire list without folding or inspecting a figure. The 24 different invalid hexominoes are real figure variety, but supply little practice variety for this wording. This is a documented limitation, not a complaint about the permitted list size. | evidence: content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-validity-test.variants.yaml, indexes 0,2,5,7,9,12,14,16,18,21,23, and whole-list comparison 0..23; tool/generator/lib/src/rules/mental_rotation/nets.dart, _stem/_answer validity-test branches.

qt-spatial-abstract-reasoning-net-opposite-easy | Minor | Difficulty separation and variety overlap: 47 of its 52 raw figure/query/correct-answer tasks also occur in opposite-medium. For example, easy index 36 and medium index 28 show the identical net, query C, and key F, changing the distractor selection. Both generated stems simply ask which face is opposite the queried face, so these are the same solving tasks despite separate easy and medium ids. No within-type duplicate is alleged. | evidence: content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-opposite-easy.variants.yaml, index 36; content/types/reasoning/spatial-abstract-reasoning/folding-and-checking-cube-nets/qt-spatial-abstract-reasoning-net-opposite-medium.variants.yaml, index 28; whole-list raw cell/query/key comparison.

## Additional scope of named-mistake defects

Independent coordinate comparison, without using either fallback implementation:

- Nonadjacent: 25/52 flat-top-neighbor selections are not the upper neighbor; 39/52 sideways-fold-separates selections are not the right neighbor; 45/52 lower-neighbor selections are not the lower neighbor. These names come from the specific geometric slips in the preserved source. Their generic generated note does not supply a replacement specific mistake.
- Opposite-easy: left-arm-is-top selects a non-left-neighbor at 23 indexes, including 20; stop-at-lower-neighbor selects a non-lower-neighbor at 21 indexes, including 20. These counts include only choices carrying those ids, not the other profile's choices.
- Opposite-medium: flat-column-ends-opposite selects a different column at indexes 3,10,15,23,25,34,35,37,44,47,50.
- Top-and-shadow: 69 generated wrong-choice notes call a non-edge-neighbor the flat neighbor, including both nonsquare choices at index 41.

## Previous finding closure and known lead

The audit-b adjacent-relation Major is CLOSED in its reported form: all 25 queried pairs now have absolute row and column differences of one, so they touch only at a corner while flat. The generator and solver both enforce that premise. Current indexes 9 and 24, as well as index 0, satisfy it; the old index 39 no longer exists in the 25-item list.

The corner-only choice remains impossible for two complete faces of a cube, but it now consistently represents preserving the flat net's corner-only contact. That is a specific, plausible misconception, rather than filler. The overlap choice confuses bringing faces together with placing them on the same face, and the opposite choice preserves flat separation. All three notes state the error, its appeal, and a check. No open Major remains for this type.

The other audit-b net Major concerns opposite-hard, which is outside these seven types and remains held. No closure is claimed for it here. The reaudit files add no other earlier finding on these seven types. The four active-type Majors above are newly confirmed instances of lost geometric premises.

## Coverage, wording, and variety assessment

Read all seven complete type files, all variant rows structurally, the complete shared rule `tool/generator/lib/src/rules/mental_rotation/nets.dart`, the complete independent solver `tool/generator/lib/src/check/solvers/mental_rotation/net_solver.dart`, solver registration, cube-net signature implementation, relevant existing tests, prior audit/fix records, and the prod source questions and Folding and Checking Cube Nets lesson. The existing figure parser was read only to confirm that cell coordinates are row/column pairs and text labels address the displayed cells. No UI review or change was performed.

Detailed samples include index 0 plus ten spread indexes for every type:

- Adjacent-relation (25): 0,2,5,7,10,12,14,17,19,22,24.
- Nonadjacent (52): 0,5,10,15,20,26,31,36,41,46,51.
- Opposite-easy (52): 0,5,10,15,20,26,31,36,41,46,51, plus reserved index 1 and counterexamples.
- Opposite-medium (52): 0,5,10,15,20,26,31,36,41,46,51, plus overlap index 28.
- Three-at-corner (64): 0,6,13,19,25,32,38,44,50,57,63.
- Top-and-shadow (52): 0,5,10,15,20,26,31,36,41,46,51, plus index 1.
- Validity-test (24): 0,2,5,7,9,12,14,16,18,21,23.

All 321 variants have one correct physical cube answer among their choices. The net relation and corner questions are constrained by actual cube geometry rather than inferred visual sequence patterns; no simpler competing rule selects another geometrically valid offered answer. For three-at-corner, every correct triple uses three distinct unoriented face axes, and every wrong triple includes an opposite pair. Overlooking an opposite pair is a plausible common mistake; the generic note states that mistake and a pair-check. No open Major was established for that type. For validity-test, count alone, connectedness alone, and symmetry alone are plausible insufficient tests; following all folds is the only sufficient offered test.

All eight reserved versions, including opposite-easy indexes 0 and 1, exactly match their requested prod source: figure, stem, explanation, correct text, wrong-choice text set, and notes. No source content was edited. Explanations use simple English, discuss the correct rule only, and match the shown data. Outside the named-mistake findings, no false fixed number, shape, direction, unfilled slot, em dash, American-spelling violation, fraction markup issue, or text/figure mismatch was found. No correct choice is uniquely longest in any variant.

Each list contains its stated number of distinct student tasks under independent whole-task rotation, reflection, translation and label-renaming normalization. Wrong choices did not add capacity. Adjacent-relation varies the net and queried diagonal pair; three-at-corner varies the net and selected corner; opposite and nonadjacent tasks vary the net and reference face. These provide meaningful within-type geometry variety for their actual list sizes. The top-and-shadow list varies its folding problem, although the shadow always remains a square under the unchanged light conditions. The validity-test repetition and easy/medium overlap are recorded as Minors above. No finding is based merely on a list being shorter than 100.

## Handoff and remaining work

Task 1.4 audit of the assigned seven types is complete. Four Majors remain open, one each for nonadjacent, opposite-easy, opposite-medium, and top-and-shadow. Two Minors document validity-test repetition and easy/medium overlap. The prior adjacency Major is closed. The lead must route fixes separately, obtain executable gate evidence, and repeat affected checker/blind-solve/audit steps before approval. This audit makes no fix, ledger approval, blind-solve claim, release recommendation, or visual acceptance claim.

All five required commands failed to execute their checks, exit 1, because SDK cache initialization attempted writes outside the sandbox. Exact startup output and per-command results are above. There are no test/analyzer/formatter/checker summary lines to report. No staged changes or commits were made. The only writable file used is `docs/superpowers/verification/question-generator/audit-r1c.md`; the initial worktree was clean.

## Per-type verdicts

PASS means no open Blocker or Major in this audit. It does not mean executable gates or content approval passed.

qt-spatial-abstract-reasoning-net-adjacent-relation | PASS
qt-spatial-abstract-reasoning-net-nonadjacent | FAIL
qt-spatial-abstract-reasoning-net-opposite-easy | FAIL
qt-spatial-abstract-reasoning-net-opposite-medium | FAIL
qt-spatial-abstract-reasoning-net-three-at-corner | PASS
qt-spatial-abstract-reasoning-net-top-and-shadow | FAIL
qt-spatial-abstract-reasoning-net-validity-test | PASS
