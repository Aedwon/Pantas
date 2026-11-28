Task: return the two held abstract reasoning types to approval-ready, and re-check every type against the current prod content root. Approval itself (blind solve, audit, ledger) is the lead's; do not record approvals.

Prod content root now: `origin/content/cet-bite-r1` d97de9415 (CET release, Nov 20). It contains 646326517 and the five source fixes (6c1f9402e). Read hand-written source questions with `git show origin/content/cet-bite-r1:<path>`. Its abstract reasoning folder changed in 11 files since 646326517.

Read first: audit-w1.md (series-fill-ray-dots Major), audit-w2.md (matrix-ray-intersection Blocker), audit-r2.md, lib1-findings.md, resync-findings.md, fix-rulings.md, and the adviser rulings in the decision log (a version fails when any library rule that fits the shown figures selects a different choice; every rule an audit finds joins the checker's rule library with a test, and every type is re-checked; a type under 20 enumerated versions stays singles, Revision 1).

Part A, series-fill-ray-dots (audit-w1 Major: the accumulate-fill note is false for the 23 variants that alternate quarter and half fills; index 50 is an example).
- Lead ruling: the accumulate-fill wrong choice must be the value its named mistake actually produces from the shown levels, and its note must be true for every variant. Compute it in the rule and, independently, in the checker's mistake solver. If the computed fill is not a level the figure kind draws, or equals another choice, reject that draw. Do not hard-code "full".
- Add a planted bad-list test: a quarter and half alternation whose accumulate-fill choice is full must fail the mistake-value check.
- Keep index 0 equal to its live source (figure-series 0018 on the current root). The audit-w1 Minor on the source's right ray along the dot row is accepted; the source is a content-lane item.

Part B, matrix-ray-intersection (audit-w2 Blocker: diagonal directional selection, for example "keep the ray closest to lower-left", explains the example rows and selects an offered wrong choice; index 43 is the example).
- Add solvers to the figure rule library for directional-extreme selection in all eight directions (N, NE, E, SE, S, SW, W, NW, by projection onto the direction), with tests, including the index 43 case as a planted failing version.
- Regenerate the list, rejecting any draw where a library rule that fits the shown rows selects a different choice than the key. Report the enumerated counts: distinct ruleKeys and total signatures. If under 20, the type stays held and its questions stay singles.
- Index 0 equals its live source (figure-matrices 0009 on the current root). If the source itself fails the grown library, report it under "Needs the lead"; do not edit content/questions/.

Part C, every type: re-run the checker, including the merged-source check, for all 28 active types and the two held ones against the current root d97de9415 and the grown library. Do not change an approved type. Report each failure under "Needs the lead" with type, index and check.

Report in FINDINGS-held2.md as you go: per type, what changed, the enumerated counts, checker output, and anything for the lead.

Resume note (Nov 21, 16:16 UTC): the earlier fix stage was killed when Aedwon's Mac ran out of memory. Its partial work is committed in 2c476a159 and is in this worktree. Continue from it; do not restart. Read FINDINGS-held2.md first.
Machine cap, binding: do not run any `flutter` command (test, analyze, build, pub), `dart test`, or `build_runner`. You may run `dart run` on the checker and tool scripts (tool/generator/bin/*.dart, tool/checks/run_checks.dart, tool/check_no_ai_attribution.dart, tool/check_layering.dart) and `dart format`. Write and update tests, but do not run them; end your report with the exact Flutter test and analyze commands the lead should run.
