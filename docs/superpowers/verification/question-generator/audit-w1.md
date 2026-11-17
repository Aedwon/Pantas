
## Sheet-fix re-audit W1, 2026-11-17

Read-only Task 1.4 / B6 audit of the eight assigned series types. Candidate HEAD: 73bca376ac013e41e24ab4bbb6c4ad9a9163a1c1. Clean starting tree. Policy read with git show origin/main at 17f514bfb6224fa4caeb51fcc5efc2ed32da7885; ancestor check confirms 1295c1866 is included. git fetch origin main could not update FETCH_HEAD because the sandbox denies writing the shared git directory. Required policy is available at the assigned origin/main reference. Only this report is writable; findings go here instead of root FINDINGS.md under the specific assignment. No fixes, staging, commits, or UI work.

Needs the lead: matrix-ray-intersection is requested in the generic re-audit text but absent from the eight explicitly assigned folders. This worker audits the eight assigned series types; the matrix full audit remains with its assigned worker.

## Verification environment, recorded immediately

All five requested commands returned exit 1 before executing their checks. Actual common stderr (PID omitted only):

```text
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 71: /opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.<pid>: Operation not permitted
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 78: /opt/homebrew/share/flutter/bin/cache/engine.realm: Operation not permitted
```

- FAIL `flutter test test/tool/generator`: exit 1, SDK cache write denied.
- FAIL `flutter analyze tool/generator test/tool/generator`: exit 1, SDK cache write denied.
- FAIL `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: exit 1, SDK cache write denied.
- FAIL `dart run tool/checks/run_checks.dart`: exit 1, SDK cache write denied.
- FAIL `dart run tool/check_no_ai_attribution.dart`: exit 1, SDK cache write denied.

Needs the lead: rerun these checks in an environment with writable SDK cache. These are blocked command launches, not observed test or analyzer failures. `git ls-remote origin refs/heads/main` also failed: `Could not resolve host: github.com`. Current remote freshness cannot be established. Available policy meets the requested revision. Assigned prod source ref resolves locally to 88f38e698ee80448fde1a795638f794b68db4cfd; later source fixes are separately available at 646326517 and will be compared rather than silently substituted.

## Findings, appended as found

qt-spatial-abstract-reasoning-series-interleaved-count | Minor | The earlier uniquely-longest-key finding remains at reserved index 0. "Circle with three dots" has 22 characters; wrong choices have 21, 21, and 20. Generated wording follows the source style, but index 0 still provides this small length clue. | evidence: content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.variants.yaml, index 0; audit-r2.md.

qt-spatial-abstract-reasoning-series-fill-ray-dots | Minor | The earlier source-only overlap remains in the figure data: index 0 retains horizontal right rays with two and four center-row dots in shown items 2 and 4, and a right ray with five dots in freeze-ray. This is the unchanged sheet-review-opus.md Minor, not the regenerated Major example. No new screenshot or UI review was performed. | evidence: content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-fill-ray-dots.variants.yaml, index 0; sheet-review-opus.md, source index 0.

## Independent all-variant sweep

Ruby/Psych read-only evaluation, no generator/solver imports. Re-derived every shown track, key, and named-mistake figure; compared all 2,388 descriptions to the figure fields and all 1,791 notes against their shared operations, fixed horizons, and available slots. Numeric figure-operation checks passed; pedagogical judgment remains separate. Rendered every stem/explanation/note for voice/slot scans. Source maps read through git show at both refs.

```text
binary-fill: 24 variants; samples 0,2,5,7,9,12,14,16,18,21,23; intended/mistake/caption errors 0; voice hits 0; raw tasks 24; tasks without outlines 6; stored ruleKeys 6; stored signatures 24; max exact key repeats 3; longest key indexes []; legacy answerText slots []; source fidelity {"origin/content/bite-sized-cse-algebra-r1" => true, "646326517" => true}
dots-size: 80 variants; samples 0,8,16,24,32,40,47,55,63,71,79; intended/mistake/caption errors 0; voice hits 0; raw tasks 80; tasks without outlines 16; stored ruleKeys 16; stored signatures 80; max exact key repeats 2; longest key indexes []; legacy answerText slots [0]; source fidelity {"origin/content/bite-sized-cse-algebra-r1" => true, "646326517" => true}
fill-ray-dots: 100 variants; samples 0,10,20,30,40,50,59,69,79,89,99; intended/mistake/caption errors 0; voice hits 0; raw tasks 100; tasks without outlines 70; stored ruleKeys 70; stored signatures 100; max exact key repeats 2; longest key indexes []; legacy answerText slots [0]; source fidelity {"origin/content/bite-sized-cse-algebra-r1" => true, "646326517" => true}
four-tracks: 100 variants; samples 0,10,20,30,40,50,59,69,79,89,99; intended/mistake/caption errors 0; voice hits 0; raw tasks 100; tasks without outlines 78; stored ruleKeys 100; stored signatures 100; max exact key repeats 3; longest key indexes []; legacy answerText slots [0]; source fidelity {"origin/content/bite-sized-cse-algebra-r1" => true, "646326517" => true}
interleaved-count: 100 variants; samples 0,10,20,30,40,50,59,69,79,89,99; intended/mistake/caption errors 0; voice hits 0; raw tasks 100; tasks without outlines 13; stored ruleKeys 100; stored signatures 100; max exact key repeats 13; longest key indexes [0]; legacy answerText slots [0]; source fidelity {"origin/content/bite-sized-cse-algebra-r1" => false, "646326517" => true}
ray-step: 100 variants; samples 0,10,20,30,40,50,59,69,79,89,99; intended/mistake/caption errors 0; voice hits 0; raw tasks 100; tasks without outlines 47; stored ruleKeys 47; stored signatures 100; max exact key repeats 5; longest key indexes []; legacy answerText slots [0]; source fidelity {"origin/content/bite-sized-cse-algebra-r1" => true, "646326517" => true}
size-corner-ray: 48 variants; samples 0,5,9,14,19,24,28,33,38,42,47; intended/mistake/caption errors 0; voice hits 0; raw tasks 48; tasks without outlines 48; stored ruleKeys 48; stored signatures 48; max exact key repeats 2; longest key indexes []; legacy answerText slots [0]; source fidelity {"origin/content/bite-sized-cse-algebra-r1" => true, "646326517" => true}
transfer-count: 45 variants; samples 0,4,9,13,18,22,26,31,35,40,44; intended/mistake/caption errors 0; voice hits 0; raw tasks 45; tasks without outlines 9; stored ruleKeys 9; stored signatures 45; max exact key repeats 1; longest key indexes []; legacy answerText slots [0]; source fidelity {"origin/content/bite-sized-cse-algebra-r1" => true, "646326517" => true}
SUMMARY 597 variants; 2388 choices; 1791 named-mistake instances; errors 0
```

The seven unchanged sources match the assigned prod ref. Interleaved-count matches the later fixed prod root 646326517, as the plan and resync record direct, but not the stale local prod branch ref 88f38e698. Needs the lead: refresh the prod ref when networking permits; this difference is accounted for, not silently ignored. All eight fixed-root comparisons passed. All non-source choice texts use the source wording style and match the corresponding figure fields. Reserved index-0 answerText slots retain legacy numeric/compass descriptions; their meanings remain correct. These observations are independent semantic checks, not execution of the Dart checker.

qt-spatial-abstract-reasoning-series-interleaved-count | Minor | The earlier variety limit remains: 100 variants reduce to 13 displayed dot-count sequences when outlines are ignored. Generated odd tracks are only zero to one to two, or two to three to four; the fixed source alone uses one to two to three. Alternating outlines and even-track counts keep exact tasks distinct, but many repeats feel numerically identical. | evidence: content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.variants.yaml, indexes 0 through 99, including 10/79 and 30/40; audit-r2.md.

qt-spatial-abstract-reasoning-series-fill-ray-dots | Major | The accumulate-fill note implies adding the two displayed partial fills produces the fully filled distractor, but 23 variants alternate quarter and half fills. Adding those levels gives three-quarter fill, not full fill. Index 50 shows quarter, half, quarter, half; its accumulate-fill choice is full. The note says "Both partial fills are visible" and "Check the repeated levels instead of adding them", but neither it nor the shown pattern supplies the extra quarter needed for this choice. Hard-coding full in both rule and mistake solver proves agreement, not a plausible numeric error for these draws. This named mistake needs the lead's disposition; no change is made. | evidence: content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-fill-ray-dots.yaml, accumulate-fill note; matching .variants.yaml, index 50, also 6,11,16,19,25,28,33,38,46,47,62,68,71,74,75,78,81,84,86,87,88,91; tool/generator/lib/src/rules/figure_series/series.dart, keep-increasing/accumulate-fill; tool/generator/lib/src/check/solvers/figure_series/series_solver.dart, same mistake.

Needs the lead: the earlier fill-ray-dots PASS cannot be carried forward under the all-variant named-mistake check above. Its wording-style and non-source horizontal-ray fixes pass, but the quarter-plus-half accumulate-fill mismatch remains open. This finding does not stop review of the other seven types.

## Whole-task rotation/reflection and variety check

Independently normalized outlines, ray directions, fill boundaries, dot-row orientation, corner positions, edge-mark orientation, size and counts under all eight whole-task transforms. Included the shown ordered sequence, the answer and horizon, excluding distractors. Recomputed signatures from this canonical representation.

```text
binary-fill: 24/24 independently canonicalized D4 tasks; duplicate index groups []; stored-signature mismatches []
dots-size: 80/80 independently canonicalized D4 tasks; duplicate index groups []; stored-signature mismatches []
fill-ray-dots: 100/100 independently canonicalized D4 tasks; duplicate index groups []; stored-signature mismatches []
four-tracks: 100/100 independently canonicalized D4 tasks; duplicate index groups []; stored-signature mismatches []
interleaved-count: 100/100 independently canonicalized D4 tasks; duplicate index groups []; stored-signature mismatches []
ray-step: 100/100 independently canonicalized D4 tasks; duplicate index groups []; stored-signature mismatches []
size-corner-ray: 48/48 independently canonicalized D4 tasks; duplicate index groups []; stored-signature mismatches []
transfer-count: 45/45 independently canonicalized D4 tasks; duplicate index groups []; stored-signature mismatches []
597 tasks checked; 0 stored-signature mismatches.
```

The binary-fill list has six solving patterns spread over four outlines; transfer-count has nine count-pair tasks over five outlines; dots-size has sixteen size/count tasks over five outlines. These are disclosed cosmetic expansions allowed by Part 3b, not extra reasoning capacity. No duplicate solving task was disguised by changes to wrong choices. Short lists remain above the later authorized twenty-version floor recorded in resync-findings.md.

## Earlier verdicts and remaining semantic checks

Read audit-a.md, audit-b.md, reaudit-a/b/c.md, audit-r1a/b.md, audit-r2.md and fix-sheet-findings.md for prior assigned-type findings. Read the eight type definitions, the shared series rule, its literal production-source maps, the independent series solver, solver registry, signature rules, current rulings, and the three referenced source lessons. Manually inspected the eleven spread samples listed per type above, eighty-eight samples total. The all-variant sweep covers every changed choice and all shared note slots, not only those samples.

- binary-fill: prior audit-r1a PASS still holds. Alternation uniquely selects black or white; repeating the latest fill, blending black with white, and inserting a partial-fill progression are recognizable errors. The three notes name those errors, their appeal and a check. Wording now consistently uses Black/White/Half-filled/Quarter-filled. Twenty-four tasks contain only six fill/length patterns, an allowed cosmetic-variety limit.
- dots-size: prior audit-r1a PASS still holds. Counts advance by one across three shown figures while sizes alternate. Each distractor freezes size, freezes dots, or wrongly ties the count to the last occurrence of that size. The second figure always shares the requested size, so that note remains true. Current capacity is eighty, not the earlier ninety, as disclosed by the fix worker. Wording and notes remain correct on all eighty.
- fill-ray-dots: prior audit-a/reaudit-a PASS does not hold because of the new all-variant accumulate-fill Major above. Keyed fill/ray alternation and rising dot count are correct. Freeze-fill and freeze-ray notes remain true. Every non-source variant avoids horizontal rays, closing the regenerated overlap problem in the data; the known source-only Minor remains. All choices share the stem's requested dot count. Choice wording is consistent and accurate on all one hundred.
- four-tracks: prior audit-a/reaudit-a PASS still holds. Outline and size alternate, rays advance ninety degrees and edge counts rise by one. The three wrong choices preserve the wrong subset of those tracks. All notes accurately name their selected frozen features; no fixed shape or count leaks across draws. All one hundred changed caption sets agree with the figure data.
- interleaved-count: audit-a's doubling Blocker remains closed as in audit-r2. The fixed source now offers five and two as the wrong circle counts, not four. Other draws begin their odd track at zero or two, so doubling does not fit both shown odd terms. Every offered figure satisfies exactly one intended correct continuation. The fixed five in count-all-positions is correct because all variants request overall position five. All three notes remain true; the two earlier Minors remain open.
- ray-step: audit-a's early-restart Major remains closed as in reaudit-a. The restartAction slot says "the last ray again" exactly when first and last directions match, including current indexes 40,59,89. Otherwise it names the first ray. Double-turn and reverse-turn values and notes remain true. The clockwise step is constant through every shown ray. Source-style direction words match all four hundred choices.
- size-corner-ray: audit-a's non-square-corner Major remains closed as in audit-r1a. All forty-eight variants use squares, so the four named corners exist. The dot moves one corner clockwise, while sizes and ray directions alternate. Each note freezes exactly its named track and continues the other two. All captioned corner positions, sizes and rays match the data.
- transfer-count: prior audit-r1a PASS still holds. Each step adds one dot and removes one edge line; the total remains fixed. Freeze-edges, freeze-dots and restart-edge-count give the actual stated errors in every variant. The constant-total check remains valid for all nine count pairs and all five cosmetic outlines. All forty-five wording sets match their figures.

The declared lessons and key points match these skills: repeating fills, tracking turn size/direction, checking all changing features, and separating odd/even tracks. Stems use realistic exam language. Explanations use plain English and explain only the intended correct continuation. No unfilled slot, em dash, scanned British spelling, top-level fraction or changing-shape/count falsehood was found. Legacy index-0 answerText descriptions remain semantically accurate despite using the old compact style.

No additional equally simple rule selecting an offered wrong choice was established for these eight types. The added highest/lowest/leftmost/rightmost solvers are registered for figure matrices and do not change the series solver contracts. No UI or screen change is needed for this report. The matrix-ray-intersection full audit and net-adjacent-relation example are outside the eight assigned type ids and receive no verdict here.

## Needs the lead, handoff

- Resolve the fill-ray-dots accumulate-fill Major through a separately assigned fix or a recorded ruling, then rerun the affected checker, audit and blind solve. No source or note was fixed here.
- Disposition the three open Minors: two interleaved-count limits and the retained source-only horizontal-ray overlap. Source fixes use the content lane and must preserve index-0 fidelity.
- Refresh refs and run the five requested verification commands in a permitted SDK environment. All five launches failed here; no Dart/Flutter gate passed in this worktree.
- Obtain B6 blind solves, renewed ledger approvals and Aedwon's separate visual acceptance. This audit grants none of those. The fix round invalidated approvals as documented in fix-sheet-findings.md.
- The only modified file is this report. No tests, implementation, generated outputs, content/questions, dependencies, stage or commits changed. The specific read-only findings-file assignment also leaves velocity/status logs to the lead.

## Final report checks

Read-only report validation: PASS, four structured finding records, one Major and three Minors; no em dashes or trailing whitespace. `git diff --check`: exit 0. Cached diff: empty. `git status --short`: only `?? docs/superpowers/verification/question-generator/audit-w1.md`. Confirmed all shown and answer outlines are squares across all forty-eight size-corner-ray variants. For clarity, the interleaved-count observation above means only the keyed figure fits the intended continuation in every variant.

## Verdicts

PASS means no open Blocker or Major in this content audit. It does not mean the blocked SDK gates, blind solve, approval, or visual acceptance passed.

qt-spatial-abstract-reasoning-series-binary-fill | PASS
qt-spatial-abstract-reasoning-series-dots-size | PASS
qt-spatial-abstract-reasoning-series-fill-ray-dots | FAIL
qt-spatial-abstract-reasoning-series-four-tracks | PASS
qt-spatial-abstract-reasoning-series-interleaved-count | PASS
qt-spatial-abstract-reasoning-series-ray-step | PASS
qt-spatial-abstract-reasoning-series-size-corner-ray | PASS
qt-spatial-abstract-reasoning-series-transfer-count | PASS
