# Task 1.4 audit R2, fixed ray intersection and interleaved count

Read-only audit of candidate a608aa1a508a3742cb6e8f35a71a829dea5d4002 (clean at startup). Policy read with git show origin/main at 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, a descendant of required 1295c1866. Only this report is writable; no fixes, test authoring, staging, commits, UI changes, or approvals. Estimated audit time: 30 minutes. The lead owns other logs and acceptance. R1 through R6 apply; later resync authorization permits lists of at least 20.

## Needs the lead

- Source-ref freshness gap: local origin/content/bite-sized-cse-algebra-r1 still resolves to 88f38e698ee80448fde1a795638f794b68db4cfd, while this assignment and resync-findings.md explicitly pin the fixed source to 64632651777ca0d9359cd5e4937581c744c838a0. The fixed commit is locally available. Audit compares both refs and uses the explicitly assigned fixed commit for closure judgments. Remote freshness cannot be confirmed: git ls-remote origin fails with `Could not resolve host: github.com`. No refs are changed under this read-only assignment.

## Findings and evidence (append as found)

- Verification limitation: `flutter test test/tool/generator` exited 1 before tests ran. SDK wrapper cannot write `/opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.<pid>` or `engine.realm` (`Operation not permitted`). No test PASS is claimed; executable verification is separate from the content audit.

qt-spatial-abstract-reasoning-matrix-ray-intersection | Blocker | The earlier highest-ray example is excluded, but equally simple lowest-ray, rightmost-ray, and leftmost-ray rules still produce an offered wrong answer. Index 2: the completed row has inputs S+NE and S+NW and output S, consistent with keeping the lowest ray. Target inputs W+NW and W+SW then give SW (second-exclusive), while the key is W. The same lowest-ray rule fits every displayed completed row. Index 12 similarly admits rightmost-ray, and index 8 admits leftmost-ray. Independent enumeration found 9 lowest-ray, 9 rightmost-ray, and 10 leftmost-ray counterexamples among the 100 variants; highest-ray counterexamples are now 0. The generator rejects only highest-ray, and the matrix solver exposes only highestRay for this family. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection.variants.yaml, indexes 2, 8, 12; tool/generator/lib/src/rules/figure_matrices/matrices.dart:539; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart:81.

- Remaining requested verification commands also exited 1 before execution, with the same SDK cache permission errors: `flutter analyze tool/generator test/tool/generator`; `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`; `dart run tool/checks/run_checks.dart`; `dart run tool/check_no_ai_attribution.dart`. No suite, analyzer, formatter, repository-check, or attribution PASS is claimed. No cache permissions, dependencies, assets, or generated files were changed to bypass this.

qt-spatial-abstract-reasoning-series-interleaved-count | Minor | Numeric variety is narrow: all 100 variants contain only 13 distinct shown dot-count sequences after outline names are removed. The 99 generated variants use only two odd tracks, 0,1 then 2, or 2,3 then 4; the fixed source is the sole 1,2 then 3 track. For example, indexes 19 and 69 both show counts 2,3,3,3, and indexes 39,49,89 show 2,1,3,1. Changes of alternating outlines and even-track counts keep exact tasks distinct, as the plan permits, but practice will often feel the same. This is a variety limitation, not an R1 duplicate or R6 failure. | evidence: content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.variants.yaml, indexes 0 through 99, especially 19,39,49,69,89; tool/generator/lib/src/rules/figure_series/series.dart:124 and :185.

qt-spatial-abstract-reasoning-series-interleaved-count | Minor | The fixed source key is the uniquely longest choice: "Circle with three dots" is 22 characters; each wrong choice is 21. This conflicts with SUBAGENTS.md's per-question longest-key rule, although the one-character difference is a weak clue and does not recur in the generated variants. The literal faithfully reproduces the approved fixed source, so any wording correction belongs to the content lane first. | evidence: content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.variants.yaml, index 0; content/questions/reasoning/spatial-abstract-reasoning/figure-series.yaml at 646326517, question q-spatial-abstract-reasoning-figure-series-0017.

- Independent Ruby/Psych read-only sweep: 200 variants, 0 intended-key, named-mistake, duplicate-choice-figure, sampled-description-generation, rendered-slot, or scanned voice errors. Both reserved index-0 variants exactly match fixed root 646326517 for shown figure data, stem, choice texts/correctness, lesson, and key point. This is an independent semantic sweep, not a Dart checker PASS.
- Historical closure: audit-a.md's doubling alternative no longer selects any offered wrong choice in the 100 interleaved variants. Fixed index 0 no longer offers circle-with-four-dots; generated draws omit initial odd count 1. reaudit-b.md's highest-ray alternative likewise selects no offered wrong choice in the 100 ray-intersection variants. Its broader directional-extreme ambiguity remains open as recorded above.

- Correction to the longest-key finding: the three wrong-choice lengths are 21, 21, and 20 characters, respectively, not all 21. The key remains uniquely longest at 22; the finding and severity stand.

## Audit coverage

- Manually read both active type definitions and variants 0,9,19,29,39,49,59,69,79,89,99. Also read each associated rule, literal source, independent solver and solver registry, R1 through R6, previous findings, resync record, and both source lessons at fixed root 646326517. Read the source questions through git show at both the assigned prod branch ref and the fixed commit, never from the worktree content/questions files.
- Both types fit their declared lesson and key point: separating odd/even positions for series key point 2, shared input features for matrix key point 1. Stems use realistic exam language. Explanations use simple English and explain only the intended answer. Every displayed description in the 11-item spread sample agrees with its figure, and the automatic description comparison covered all non-source choices. No em dash, scanned British spelling, top-level fraction, unfilled slot, or false fixed count/shape was found.
- Matrix mistakes independently re-derived for all 100 variants: keep the union, copy the adjacent second input, select its exclusive ray. Each represents a plausible feature-selection or copying error and each shared note names the mistake, why it looks right, and a check. However, the exclusive-ray choice is defensibly correct under the competing cardinal-extreme rules on the reported variants.
- Series mistakes independently re-derived for all 100 variants: repeat the last even-position figure, use five dots for the fifth overall position, repeat the last odd-position count. The four-item horizon is fixed, so the fixed five in the position-count note stays true. All three notes name plausible errors, explain the appeal, and give a check. None depends on a changing outline or number.
- Variety: ray intersection has 100 distinct shown tasks even after removing outline names. Both lists have 100 distinct raw task-plus-answer records, 100 stored signatures and 100 stored ruleKeys. Stored hashes were counted, not independently recomputed. Exact answer-figure multiplicities peak at 9/100 for matrix and 13/100 for series, consistent with R6. The series count-only variety limitation is recorded above. Full capacity enumeration is outside this audit.
- Cardinal-extreme collision indexes, independently enumerated by selecting the unique most extreme ray from the union of each row's inputs: highest []; lowest [2,4,15,33,47,51,68,71,92]; rightmost [12,28,29,54,60,61,70,71,99]; leftmost [8,16,37,45,50,74,75,84,89,96]. Tied extremes were excluded.
- This content audit does not replace the independent blind solve, executable checker, ledger approval, or Aedwon's visual acceptance. The cube-net example is outside the two assigned types. No fixes or new tests were authored under the read-only assignment.

## Verification commands, actual results

All five commands returned exit 1 before their checks ran:

```text
FAIL flutter test test/tool/generator
FAIL flutter analyze tool/generator test/tool/generator
FAIL dart format --output=none --set-exit-if-changed tool/generator test/tool/generator
FAIL dart run tool/checks/run_checks.dart
FAIL dart run tool/check_no_ai_attribution.dart
```

Representative actual stderr (same paths and messages for all five; temporary process id differs):

```text
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 71: /opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.80462: Operation not permitted
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 78: /opt/homebrew/share/flutter/bin/cache/engine.realm: Operation not permitted
```

The independent Ruby audit completed with exit 0: 200 variants checked, 0 intended-key/mistake/description/voice errors; both source-fidelity comparisons passed. This establishes only the stated checks, and the cardinal-extreme counterexamples remain a Blocker.

`git diff --check`: exit 0. `git diff --cached --name-only`: empty. `git status --short`: only this new report. No code, tests, content, generated files, dependencies, index, or commits changed.

## Needs the lead, remaining work

- Ray intersection still needs a ruling and a separately assigned fix or hold for the directional-extreme ambiguity. The highest-ray case alone is closed; the broader earlier Blocker is not. Add any accepted competing operations to the independent checker before re-audit.
- Review the two series Minor findings. The uniquely longest index-0 wording comes from the fixed source and must be resolved through the content lane if changed.
- Confirm live refs when network access is available and rerun the five requested commands where the SDK cache is writable. Fresh Dart/Flutter results are unavailable here.
- Obtain subsequent blind-solve evidence and approvals separately. An audit PASS below means no open Blocker or Major in this review, not completion of the B6 approval sequence.

## Verdicts

qt-spatial-abstract-reasoning-matrix-ray-intersection | FAIL

qt-spatial-abstract-reasoning-series-interleaved-count | PASS (two open Minor findings)
