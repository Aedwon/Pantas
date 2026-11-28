# Task 1.3: figure-grouping shape-row worker

Policy: origin/main `1b87305dcf54e5edb4952fc35b66b4e64d68f00f`, descendant of required `1295c1866`. `git fetch origin main` failed because FETCH_HEAD is outside the writable sandbox. `git ls-remote origin refs/heads/main` independently returned that same commit, confirming origin/main is current. No escalation is available. `codex-pick --status` reports available room on all three accounts. Initial worktree status was clean.

## Needs the lead

- STOP before implementation: `ar-grouping.md` row 0002 (`qt-group-outline-symmetry`) requires three reflection-symmetric outlines selected from all eight non-blob shape-row forms. Those eight include `parallelogram`. The assigned branch painter in `lib/core/ui/figures/shape_row_figure.dart` draws a slanted, unequal-sided parallelogram, which has no reflection axis. A row containing that shape plus the blob would have two asymmetric outlines. The report range and actual geometry disagree. Please rule whether the allowed symmetric forms exclude parallelogram (seven forms). No range, report, plan, source content, or UI was changed. The brief explicitly requires stopping on such disagreement, so remaining implementation is not started.

## Source grouping recovered before stop

Inputs: production `origin/content/bite-sized-cse-algebra-r1:content/questions/reasoning/spatial-abstract-reasoning/figure-grouping.yaml` and `docs/superpowers/verification/question-generator/ar-grouping.md`.

- Shape-row candidates: 0001 side-count-easy; 0002 outline-symmetry; 0003 center-cuts; 0004 dot-count; 0005 boundary; 0006/0008 side-count-medium (only proposed merge, preserving both source profiles and fixed indexes); 0009 line-count; 0010 specific-rule (text choices); 0012 region-parity; 0013 side-parity; 0015 dot-parity; 0017 polygon-replacement; 0018 side-double-dots. All other candidates are singleton types with source at index 0 under the brief, subject to exact reproduction and capacity.
- Figure-series sources 0007, 0011, 0014, 0016, 0019, 0020 wait for the series owner and were not touched.
- 0021 has no figure data and stays a single.
- No capacity measurement was run, so no distinct ruleKey/signature counts or LIST/HELD status are claimed.

## Verification at stop

- flutter test test/tool/generator --no-test-assets: NOT RUN, stopped before tests or implementation.
- flutter analyze tool/generator test/tool/generator: NOT RUN, same stop.
- dart format --output=none --set-exit-if-changed tool/generator test/tool/generator: NOT RUN, same stop.
- dart run build_runner build --delete-conflicting-outputs: NOT RUN, same stop.
- dart run tool/checks/run_checks.dart: NOT RUN, same stop.
- dart run tool/check_no_ai_attribution.dart: NOT RUN, same stop.

Only FINDINGS.md was created. No files staged or committed. No generated files, content questions, or UI changed.

## Review follow-up, November 17

- Review reports no corrective findings; none rejected. The existing Needs the lead symmetry blocker remains unresolved in the decision log. Implementation remains stopped under the explicit brief.
- Policy reconfirmed at origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f using git ls-remote. Fetch remains sandbox-blocked outside this worktree. Source HEAD e944000ce7f58506afaff53ca6ae7b8334315780; tracked staged and unstaged diffs empty. Only FINDINGS.md is untracked.
- Running the requested verification independently of blocked implementation; no type capacity or checker result can be claimed without types.

- PASS `flutter test test/tool/generator --no-test-assets` (exit 0): `00:09 +81: All tests passed!`
- PASS `flutter analyze tool/generator test/tool/generator` (exit 0): `No issues found! (ran in 7.3s)`
- PASS `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator` (exit 0): `Formatted 24 files (0 changed) in 0.06 seconds.`
- PASS `dart run tool/check_no_ai_attribution.dart` (exit 0): `check_no_ai_attribution: OK`
- PASS `dart run build_runner build --delete-conflicting-outputs` (exit 0): `Built with build_runner/aot in 32s; wrote 4763 outputs.` The tool warns that `--delete-conflicting-outputs` is removed and ignored. No generated file was hand-edited.
- PASS `dart run tool/checks/run_checks.dart` (exit 0), after build_runner: final output `OK    legal-text-drafting`. Existing accepted exceptions are printed by the gate. Full temporary log: `/tmp/t13-grouping-checks.log`.
- After code generation, tracked staged and unstaged diffs remain empty; `git status --short` shows only `?? FINDINGS.md`.
- FAIL `flutter test test/tool/generator` (exit 1): `No file or variants found for asset: assets/seed/content.db.` followed by `Error: Failed to build asset bundle`. The brief's required `--no-test-assets` invocation passes all 81 tests. No protected package was regenerated to resolve this unrelated asset prerequisite.
- Repository gate detail: `no content/types/ directory; generated types skipped`, then `OK    generated-types`. Gate success does not prove any grouping type or list.

### Needs the lead, follow-up

- Original symmetry ruling still required. No implementation, capacity counts, LIST/HELD classification, or per-type checker result exists. All listed shape-row candidates remain blocked, rather than classified HELD without measurement.
- Exact default test invocation also needs the missing seed asset supplied through its authorized package workflow. No source fix or review finding was rejected. Only FINDINGS.md changed; nothing staged or committed.

## Resumption with lead rulings, November 17

- Policy reconfirmed: `git ls-remote origin refs/heads/main` returns `1b87305dcf54e5edb4952fc35b66b4e64d68f00f`, matching origin/main. Fetch still cannot write FETCH_HEAD outside the sandbox. Read current main AGENTS.md, WORKFLOW.md, SUBAGENTS.md, and process-improvement.md. Worktree HEAD is `e9479cf27628ae94531955445f36437c0bc82360`.
- The current brief resolves the original symmetry blocker: square, rectangle, rhombus, triangle, circle, pentagon, and hexagon have drawn reflection axes; parallelogram and blob do not. The query-slot interface is present. No original symmetry ruling remains pending.
- HELD checker support has not landed here. The series brief explicitly assigns that implementation to the series worker, so this worker must not edit shared checker files for it. This is a pending integration dependency, not a new request to the lead.

### Needs the lead: positional figure choices versus duplicate figure values

- Source `q-spatial-abstract-reasoning-figure-grouping-0009` on the required production ref shows three identical `{form: circle, lines: 2}` figures and one `{form: circle, lines: 1}`. Its wrong choices are “The leftmost circle”, “Second circle from the left”, and “Third circle from the left”. The requested figure-choice representation gives all three wrong answers identical figure data. `checkVariants` compares figure maps alone for duplicate choice values (`tool/generator/lib/src/check/check.dart`, choices check), so this exact source cannot pass as a figure-choice type. Different text descriptions do not distinguish those values.
- The report calls this candidate exact Y and the brief requires building it. The available shape-row contract has no selection index, highlight, or label field. Adding one would invent unsupported figure semantics. Changing the source or reducing its wrong choices would violate exact reproduction.
- Please rule whether positional selections such as these are text `relation`/`order` choices, or supply an approved selection-identity representation and checker contract. The brief names count, condition, order, and relation text choices but does not explicitly classify positional odd-one-out selections. This worker does not choose that product interpretation.
- STOP before rule/type/test implementation under the brief's explicit disagreement rule. All 13 shape-row candidate types remain unmeasured, not HELD. No capacity numbers or checker passes are claimed. No content, UI, generated file, stage, or commit changed.

### Resumption verification, current unmodified code candidate

- PASS `flutter test test/tool/generator --no-test-assets`: `00:05 +81: All tests passed!` Log: `/tmp/t13-grouping-resume-tests.log`.
- PASS `flutter analyze tool/generator test/tool/generator` (exit 0): `No issues found! (ran in 4.8s)`.
- PASS `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator` (exit 0): `Formatted 24 files (0 changed) in 0.03 seconds.`
- PASS `dart run tool/check_no_ai_attribution.dart` (exit 0): `check_no_ai_attribution: OK`.
- PASS `dart run build_runner build --delete-conflicting-outputs` (exit 0): `Built with build_runner/aot in 8s; wrote 26 outputs.` Log: `/tmp/t13-grouping-resume-build.log`. No hand edits to generated files; tracked status unchanged.
- Required test command uses `--no-test-assets` as instructed in this dispatch. Default asset-bundling test was not rerun; its earlier missing-content.db failure remains recorded above.
- PASS `dart run tool/checks/run_checks.dart` (exit 0), after build_runner: final summary `OK    legal-text-drafting`; `no content/types/ directory; generated types skipped`, `OK    generated-types`. Log: `/tmp/t13-grouping-resume-checks.log`. This is baseline gate evidence, not type verification.

### Per-candidate disposition at resumption stop

IDs below use prefix `qt-spatial-abstract-reasoning-`; source suffixes use `q-spatial-abstract-reasoning-figure-grouping-`. For every row, distinct ruleKeys = NOT MEASURED, distinct signatures = NOT MEASURED, status = BLOCKED (neither LIST 100 nor HELD), checker = NOT RUN. HELD is reserved for measured capacity below 100.

| Type suffix | Source suffixes |
| --- | --- |
| group-side-count-easy | 0001 |
| group-outline-symmetry | 0002 |
| group-center-cuts | 0003 |
| group-dot-count | 0004 |
| group-boundary | 0005 |
| group-side-count-medium | 0006, 0008 |
| group-line-count | 0009 |
| group-specific-rule | 0010 |
| group-region-parity | 0012 |
| group-side-parity | 0013 |
| group-dot-parity | 0015 |
| group-polygon-replacement | 0017 |
| group-side-double-dots | 0018 |

Only FINDINGS.md changed. No implementation tests, rules, solvers, canonicalizer, types or lists were written. No files staged or committed. Implementation and per-type verification remain undone pending the positional-choice ruling. Series-kind sources remain outside this worker's scope.

## Corrective review resumption, November 17

- No review findings were rejected. The review correctly identifies absent implementation and the unresolved positional-choice blocker. The three supplied lead rulings resolve HELD location, query slots, and drawn symmetry, but do not classify positional selections or authorize duplicate figure values. Under the explicit stop-on-disagreement brief, Task 1.3 remains stopped. No rule, solver, canonicalizer, type, list, or capacity result is claimed.
- Policy origin/main is `1b87305dcf54e5edb4952fc35b66b4e64d68f00f`, confirmed current with `git ls-remote origin refs/heads/main` and a descendant of `1295c1866`. Fetch cannot write the external git metadata FETCH_HEAD. Read policy with git show as instructed.
- Needs the lead: rule whether source 0009's positional selections use text choices, or provide an approved selection identity contract. No supplied ruling resolves this prior blocker. Remaining candidates retain the per-candidate BLOCKED disposition above, with both capacity numbers unmeasured and checker not run.
- Fresh requested verification follows. These commands verify the baseline tooling, not an implemented grouping feature.

- Fresh FAIL `flutter test test/tool/generator` (exit 1): `No file or variants found for asset: assets/seed/content.db.` / `Error: Failed to build asset bundle`. Log: `/tmp/t13-grouping-review-default-test.log`. Protected content was not regenerated.
- Fresh PASS `flutter test test/tool/generator --no-test-assets` (exit 0): `00:04 +81: All tests passed!`. Log: `/tmp/t13-grouping-review-tests.log`.
- Fresh PASS format (exit 0): `Formatted 24 files (0 changed) in 0.03 seconds.`
- Fresh PASS attribution (exit 0): `check_no_ai_attribution: OK`.
- Fresh PASS `flutter analyze tool/generator test/tool/generator` (exit 0): `No issues found! (ran in 3.3s)`.
- Fresh PASS `dart run build_runner build --delete-conflicting-outputs` (exit 0): `Built with build_runner/aot in 2s; wrote 0 outputs.` Log: `/tmp/t13-grouping-review-build.log`.
- Fresh PASS `dart run tool/checks/run_checks.dart` (exit 0), after build_runner: `OK    legal-text-drafting`. Full log: `/tmp/t13-grouping-review-checks.log`. Generated-types reports no content/types directory and skips generated types. This is no evidence of grouping type correctness.
- Final status: only untracked FINDINGS.md changed; tracked staged and unstaged diffs remain empty. No finding rejected. Task 1.3 implementation, per-type capacity, lists and checker results remain undone pending the positional-choice ruling. No UI, question content, dependency, staging or commit change.

## Implementation resumption after final lead rulings

- Policy 1b87305dcf54e5edb4952fc35b66b4e64d68f00f remains current by ls-remote. Fetch is sandbox-blocked at external FETCH_HEAD. Rulings 5 and 6 resolve positional choices and HELD integration. All earlier blockers are resolved.
- Recovered grouping remains the 13 shape-row types above. All odd-row selections use text positions, including named-outline source choices; replacement uses figure choices and the specific-rule uses text conditions. Source wording remains literal at reserved indexes.
- RED confirmed: 14 grouping tests fail because all 13 rules/solvers and the shape-row canonicalizer are absent. Baseline existing tests were not altered.
- Rule documentation now states the drawn symmetry table and named selection predicates. Solvers are implemented first from that contract and production figures, before generation code.

- Capacity `qt-spatial-abstract-reasoning-group-boundary`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 506
distinct signatures: 506
100 reachable: yes
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-outline-symmetry`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 54
distinct signatures: 54
100 reachable: no
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-polygon-replacement`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 1603
distinct signatures: 1603
100 reachable: yes
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-side-count-easy`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 216
distinct signatures: 216
100 reachable: yes
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-side-count-medium`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 336
distinct signatures: 336
100 reachable: yes
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-side-parity`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 120
distinct signatures: 120
100 reachable: yes
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-center-cuts`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 318
distinct signatures: 318
100 reachable: yes
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-dot-count`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 1998
distinct signatures: 1998
100 reachable: yes
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-dot-parity`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 1974
distinct signatures: 1974
100 reachable: yes
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-line-count`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 40
distinct signatures: 40
100 reachable: no
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-region-parity`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 12
distinct signatures: 12
100 reachable: no
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-side-double-dots`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 1692
distinct signatures: 1692
100 reachable: yes
Running build hooks...Running build hooks...```

- Capacity `qt-spatial-abstract-reasoning-group-specific-rule`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 183
distinct signatures: 183
100 reachable: yes
Running build hooks...Running build hooks...```
- Generate qt-spatial-abstract-reasoning-group-boundary: exit 0; Running build hooks...Running build hooks...
- qt-spatial-abstract-reasoning-group-outline-symmetry: HELD, no list.
- Generate qt-spatial-abstract-reasoning-group-polygon-replacement: exit 0; Running build hooks...Running build hooks...
- Generate qt-spatial-abstract-reasoning-group-side-count-easy: exit 0; Running build hooks...Running build hooks...
- Generate qt-spatial-abstract-reasoning-group-side-count-medium: exit 0; Running build hooks...Running build hooks...
- Generate qt-spatial-abstract-reasoning-group-side-parity: exit 0; Running build hooks...Running build hooks...
- Generate qt-spatial-abstract-reasoning-group-center-cuts: exit 0; Running build hooks...Running build hooks...
- Generate qt-spatial-abstract-reasoning-group-dot-count: exit 0; Running build hooks...Running build hooks...
- Generate qt-spatial-abstract-reasoning-group-dot-parity: exit 0; Running build hooks...Running build hooks...
- qt-spatial-abstract-reasoning-group-line-count: HELD, no list.
- qt-spatial-abstract-reasoning-group-region-parity: HELD, no list.
- Generate qt-spatial-abstract-reasoning-group-side-double-dots: exit 0; Running build hooks...Running build hooks...
- Generate qt-spatial-abstract-reasoning-group-specific-rule: exit 0; Running build hooks...Running build hooks...
- GREEN: all 14 source/canonicalization tests pass, including both reserved medium sources. Initial multi-source test caught a placeholder stored signature; generation now stores the actual canonical signature before returning. No core generator change was needed.
- Capacity measurements are sampled exact distinct counts at ceiling 2000, not proofs of exhaustive capacity. HELD source-derived mistake constraints explain symmetry 54, line count 40, region parity 12. No range was widened.
- First complete checker run: `dart run tool/generator/bin/check.dart` exit 0. All ten generated 100-lists and all three HELD schemas/solver registrations pass. HELD does not claim a list check. Added full-row extrema regression coverage before correcting a discovered mistake-selection edge case.
- New RED: full-row extrema tests fail for center-cuts, dot-parity and side-double-dots. Previously a named maximum/minimum could select the next remaining figure after excluding the correct answer. Both implementations now require the actual full-row extremum and reject draws where no wrong target exists. Previous lists and capacity evidence for these three types are invalidated and will be regenerated/recounted.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-boundary`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 506
distinct signatures: 506
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-polygon-replacement`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 1603
distinct signatures: 1603
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-side-count-easy`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 216
distinct signatures: 216
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-side-count-medium`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 336
distinct signatures: 336
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-side-parity`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 120
distinct signatures: 120
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-center-cuts`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 142
distinct signatures: 142
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-dot-count`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 1998
distinct signatures: 1998
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-dot-parity`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 1966
distinct signatures: 1966
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-side-double-dots`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 1445
distinct signatures: 1445
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-specific-rule`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 183
distinct signatures: 183
100 reachable: yes
Running build hooks...Running build hooks...```
- Refreshed LIST 100 generation: exit 0.

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-outline-symmetry`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 54
distinct signatures: 54
100 reachable: no
Running build hooks...Running build hooks...```

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-line-count`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 40
distinct signatures: 40
100 reachable: no
Running build hooks...Running build hooks...```

- REFRESHED capacity `qt-spatial-abstract-reasoning-group-region-parity`, seed 20261117, ceiling 2000, exit 0:
```
distinct ruleKeys: 12
distinct signatures: 12
100 reachable: no
Running build hooks...Running build hooks...```
- New RED: source-derived positional-mistake tests fail for medium side count and line count. Their first/center/last mistakes now select actual source positions 1/2/4 rather than the first remaining position. Invalid draws are rejected. Recounting these two types and regenerating the medium list is required.

- FINAL capacity qt-spatial-abstract-reasoning-group-side-count-medium (ceiling 2000, seed 20261117), exit 0:
```
distinct ruleKeys: 298
distinct signatures: 298
100 reachable: yes
Running build hooks...Running build hooks...```

- FINAL capacity qt-spatial-abstract-reasoning-group-line-count (ceiling 2000, seed 20261117), exit 0:
```
distinct ruleKeys: 40
distinct signatures: 40
100 reachable: no
Running build hooks...Running build hooks...```
- GREEN: 14 grouping tests pass after both fixes. Tests cover all source profiles, source text and figure exactness, mirrored row signatures, unsupported figure fields, full-row extrema, and literal positional mistakes.
- Generalized new type notes where generated outlines differ from the reserved source. Notes retain the mistake, its appeal, and one check, without claiming a fixed source shape in a changed row. Source question files are untouched.
- Full-suite integration found two existing series wording tests assumed every registered type had series `items` and figure choices. New text-position shape-row types correctly lack those fields. Scoped only those two series-specific tests to series rules; the shared longest-correct-choice test still covers all types. This necessary test integration is outside the new grouping test file, within the assigned generator test directory. No production series code changed.

## Final Task 1.3 shape-row handoff

All earlier Needs the lead blockers are resolved by the current brief. No new product decision is pending. All type ids below have prefix `qt-spatial-abstract-reasoning-group-`; all source ids have prefix `q-spatial-abstract-reasoning-figure-grouping-`. Capacity uses seed 20261117 and ceiling 2000. The two numbers are measured distinct ruleKeys and measured distinct signatures after deduplication, not an extrapolated capacity.

| Type suffix | Sources (fixed indexes) | ruleKeys | Signatures | Status | Checker |
| --- | --- | ---: | ---: | --- | --- |
| side-count-easy | 0001 (0) | 216 | 216 | LIST 100 | PASS |
| outline-symmetry | 0002 (0) | 54 | 54 | HELD | PASS schema/registration; no list |
| center-cuts | 0003 (0) | 142 | 142 | LIST 100 | PASS |
| dot-count | 0004 (0) | 1998 | 1998 | LIST 100 | PASS |
| boundary | 0005 (0) | 506 | 506 | LIST 100 | PASS |
| side-count-medium | 0006 (0), 0008 (1) | 298 | 298 | LIST 100 | PASS |
| line-count | 0009 (0) | 40 | 40 | HELD | PASS schema/registration; no list |
| specific-rule | 0010 (0) | 183 | 183 | LIST 100 | PASS |
| region-parity | 0012 (0) | 12 | 12 | HELD | PASS schema/registration; no list |
| side-parity | 0013 (0) | 120 | 120 | LIST 100 | PASS |
| dot-parity | 0015 (0) | 1966 | 1966 | LIST 100 | PASS |
| polygon-replacement | 0017 (0) | 1603 | 1603 | LIST 100 | PASS |
| side-double-dots | 0018 (0) | 1445 | 1445 | LIST 100 | PASS |

10 lists contain exactly 1,000 variants total. Largest grouping Free-size proxy is polygon-replacement: 89,776 bytes, below 200,000. No list exists for the three HELD types. All reserved-source variants, including HELD source draws, pass independent correctness and exact source reproduction in the grouping tests. HELD integration checks only schema and solver registration, as ruled.

### Final gate evidence

- PASS `flutter test test/tool/generator --no-test-assets`, exit 0: `00:29 +118: All tests passed!` Log `/tmp/grouping-final-tests2.log`.
- PASS `flutter analyze tool/generator test/tool/generator`, exit 0: `No issues found! (ran in 3.8s)` Log `/tmp/grouping-final-analyze.log`.
- PASS `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`, exit 0: `Formatted 37 files (0 changed) in 0.07 seconds.`
- PASS `dart run build_runner build --delete-conflicting-outputs`, exit 0: `Built with build_runner/aot in 8s; wrote 72 outputs.` Log `/tmp/grouping-final-build.log`. No generated file was hand-edited. This preceded run_checks.
- PASS `dart run tool/checks/run_checks.dart`, exit 0: `OK    generated-types` through final `OK    legal-text-drafting`. Log `/tmp/grouping-final-checks.log`. Existing accepted exceptions are printed by the gate; none was added.
- PASS `dart run tool/check_no_ai_attribution.dart`, exit 0: `check_no_ai_attribution: OK`.
- PASS `git diff --check`, exit 0. No staged changes, commits, source-content edits, UI changes, dependencies, or app changes.

Task 1.3 is implemented for the assigned 13 shape-row patterns. The six figure-series sources remain with the series owner; 0021 remains an unfigured single. Blind solves, independent audit, approval, and visual sheets are later lead-owned tasks and were not performed. Default asset-bundling tests were not rerun in this resumption; the dispatch explicitly selected --no-test-assets, and the prior missing seed asset finding remains in history above.

### Files touched in this resumption

- `FINDINGS.md`
- `content/types-held/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-outline-symmetry.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-line-count.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-region-parity.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-boundary.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-boundary.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-polygon-replacement.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-polygon-replacement.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-easy.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-easy.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-medium.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-count-medium.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-parity.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-side-parity.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-center-cuts.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-center-cuts.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-dot-count.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-dot-count.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-dot-parity.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-dot-parity.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-side-double-dots.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-side-double-dots.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule/qt-spatial-abstract-reasoning-group-specific-rule.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule/qt-spatial-abstract-reasoning-group-specific-rule.yaml`
- `test/tool/generator/grouping_rules_test.dart`
- `test/tool/generator/series_wording_test.dart`
- `tool/generator/lib/src/check/shape_row_signature.dart`
- `tool/generator/lib/src/check/signature.dart`
- `tool/generator/lib/src/check/solvers/figure_grouping/grouping_solver.dart`
- `tool/generator/lib/src/check/solvers/solver.dart`
- `tool/generator/lib/src/rules/figure_grouping/grouping.dart`
- `tool/generator/lib/src/rules/figure_grouping/sources.dart`
- `tool/generator/lib/src/rules/rule.dart`

## Review correction resumption
- Current policy origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f matches ls-remote. Fetch blocked at external FETCH_HEAD; cached policy is current. Preserving all existing uncommitted implementation.
- Confirmed both note findings and the solver direction defect. Boolean patterns currently accept an inverted majority contrary to their documented contracts. Adding regression coverage before fixes. No finding rejected.
- RED: new note regression and seven Boolean direction regressions fail on the reviewed implementation (8 failures). Flutter cache access works in this run.
- Fixed both shared note templates with wording valid for every generated row. Reserved source profiles and variant lists are unchanged.
- Fixed the common Boolean singleton solver to require three true properties and one false property. Regression cases cover valid and inverted rows at every answer position for all seven affected patterns.
- GREEN: flutter test test/tool/generator --no-test-assets, exit 0: `00:32 +126: All tests passed!` (/tmp/grouping-review-tests.log).
- PASS analyze after correcting eight trailing-comma lint findings in new tests: `No issues found! (ran in 3.6s)` (/tmp/grouping-review-analyze-final.log).
- PASS format: `Formatted 37 files (0 changed) in 0.05 seconds.` PASS git diff --check.
- PASS build_runner, exit 0: `Built with build_runner/aot in 8s; wrote 38 outputs.` No generated files were hand-edited; git status shows no new tracked generated changes.
- PASS run_checks after build_runner, exit 0: `OK    generated-types` through `OK    legal-text-drafting` (/tmp/grouping-review-checks.log).
- PASS attribution, exit 0: `check_no_ai_attribution: OK`.
- Additional exact `flutter test test/tool/generator` attempt, exit 1 before tests: `No file or variants found for asset: assets/seed/content.db.` / `Error: Failed to build asset bundle`. This existing asset gap remains for the lead; the brief's authorized --no-test-assets suite passes. No protected package was regenerated.
- This correction touches only FINDINGS.md, grouping_rules_test.dart, grouping_solver.dart, and the side-count-medium/side-parity type templates. All prior uncommitted work preserved, nothing staged or committed. All three review findings accepted and corrected.
