# CSE Lesson Walk-Through Rewrite State

- Branch: `content/lesson-walkthrough-cse-r1` (content base `content/cse-key-fixes-r1` `a7cc22b6b`)
- Latest policy read: `origin/main` `7b93f2dbe` (Nov 26 connection rule + save-as-you-go rule + no shell file edits)
- Checks branch: `tools/walkthrough-checks-r1` (`b7209bcc6`: new `walkthrough_example_connection_check.dart` + 4 redone samples; 156/156 tests & 21/21 sweeps green)
- Total active CSE lessons: 416 original -> 417 active (after splitting `signed-integers-and-substitution`)

## Batch Status

| Batch | Topic(s) | Lessons | Written | Verified | Connection Rule | Audited | Next Step |
|---|---|---:|---|---|---|---|---|
| 1 | Mathematics (Algebra, Arithmetic, Data Interp.) | 55 active | 55/55 | 55/55 (pre-rule) | Applied on Algebra & Arithmetic (`133aaae64`..`b9bf77f3b`, samples synced `434a1c9c9`); Data Interp. read & left alone | Pre-rule PASS (`25842f38e`); post-rule NOT yet verified/audited | Verify all post-rule math diffs & unedited math files with new connection check, then Codex re-audit |
| 2 | Reasoning (Clerical, Logical-Verbal, Spatial, Verbal Logic) | 47 active | 47/47 | 47/47 + 23 fixes + 37 audit fixes (pre-rule) | Complete (`5a332de91`, `38a4335c7`); 0 violations on new connection check | Pre-rule R2 PASS; post-rule Codex re-audit running | Close Batch 2 Codex post-rule PASS (`Batch 2 audited: PASS`) |
| 3 | Language Proficiency: Grammar & Structure | 52 active | 52/52 | 52/52 verified + all 18 fixes applied | Complete (Chunk A `2c39b5ea1` + Chunk B: 19 edited, 33 already connected) | NOT yet audited | Merge Batch 3 trap evidence & figure worklist, run Flash sweep + locked Dart gates + Codex audit |
| 4a | Language Proficiency: Vocabulary | 29 active (22 EN, 7 FIL) | 29/29 (`bc4ee889a`, `b659c421a`) | 29/29 independently verified (`11b8c0b7`: 19 Blockers, 61 Majors, 25 Minors); `spelling-rules-0012` fixed & approved (`15e8f6c0c`) | Partial (needs fixes on detached pairs & missing walk-through blocks) | NOT yet audited | Repair all 19 Blockers + 61 Majors + 25 Minors (incl. 7 FIL KWF wording), merge trap evidence into `walkthrough-trap-evidence.json`, re-verify, Codex audit |
| 4b | Language Proficiency: Language Application | 24 active (19 EN, 5 FIL) | 8/24 WIP (`clause-punctuation-checks`..`word-meaning-checks`) | 0/24 | NOT yet checked on first 8 | NOT yet audited | Finish remaining 16 lessons under connection rule, check/update first 8, merge trap evidence, verify, Codex audit |
| 5 | Reading Comprehension | 40 active (32 EN, 8 FIL) | 0/40 | 0/40 | Quiz packets ready | NOT yet audited | Rewrite under connection rule, verify, Codex audit |
| 6a | General Information: Philippine Constitution (part 1) | 38 active | 0/38 | 0/38 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |
| 6b | General Information: Philippine Constitution (part 2) | 38 active | 0/38 | 0/38 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |
| 7 | General Information: Code of Conduct RA 6713 | 47 active | 0/47 | 0/47 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |
| 8 | General Information: Environment & Peace/Human Rights | 47 active | 0/47 | 0/47 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |

## Current Immediate Queue (Nov 26, 13:50 Manila)

1. Run Codex GPT 6.2 Sol High post-connection re-audit on Batch 2 Reasoning (`codex-audit-batch2-r3.brief.md`), then commit `Batch 2 audited: PASS`.
2. Merge Batch 3 Grammar trap evidence (52 lessons, 141 pairs, 279 citations) into `content/walkthrough-trap-evidence.json`, append Batch 3 figure worklist, write `walkthrough-batch-3-grammar.md`, run Flash mechanical sweep + locked Dart gates + Codex checkpoint audit (`Batch 3 audited: PASS`).
3. Apply Manager ruling on the non-CSE CET Algebra/Arithmetic files modified by stopgap commits (`133aaae64`..`b9bf77f3b`), verify post-rule CSE Math diffs + unedited Math files, and run Codex Batch 1 post-rule re-audit (`Batch 1 audited: PASS`).
4. Repair all 19 Blockers, 61 Majors, and 25 Minors on Batch 4a Vocabulary (29 lessons, incl. 7 FIL KWF wording), merge Vocabulary trap evidence into `content/walkthrough-trap-evidence.json`, re-verify, and run Codex audit (`Batch 4a audited: PASS`).
5. Finish Batches 4b through 8 saving and pushing every chunk under the Nov 26 connection rule.
