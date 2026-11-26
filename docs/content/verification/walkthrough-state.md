# CSE Lesson Walk-Through Rewrite State

- Branch: `content/lesson-walkthrough-cse-r1` (content base `content/cse-key-fixes-r1` `a7cc22b6b`)
- Latest policy read: `origin/main` `7b93f2dbe` (Nov 26 connection rule + save-as-you-go rule + no shell file edits)
- Checks branch: `tools/walkthrough-checks-r1` (`b7209bcc6`: new `walkthrough_example_connection_check.dart` + 4 redone samples; 156/156 tests & 21/21 sweeps green)
- Total active CSE lessons: 416 original -> 417 active (after splitting `signed-integers-and-substitution`)

## Batch Status

| Batch | Topic(s) | Lessons | Written | Verified | Connection Rule | Audited | Next Step |
|---|---|---:|---|---|---|---|---|
| 1 | Mathematics (Algebra, Arithmetic, Data Interp.) | 55 active | 55/55 | 55/55 (pre-rule) | Applied on 25 CSE Algebra & Arithmetic files (`133aaae64`..`b9bf77f3b`, samples synced `434a1c9c9`); 41 non-CSE CET + 20 retired parents reverted to `25842f38e` per Manager ruling | Pre-rule PASS (`25842f38e`); post-rule NOT yet verified/audited | Verify all post-rule CSE math diffs & unedited math files, then Codex re-audit |
| 2 | Reasoning (Clerical, Logical-Verbal, Spatial, Verbal Logic) | 47 active | 47/47 | 47/47 + 23 fixes + 37 audit fixes + 30 connection-audit fixes | Complete (`5a332de91`, `38a4335c7`, `333e4dd43`; net `-207` tokens, 0 violations) | **PASS** (post-connection R4 PASS) | Complete (`Batch 2 audited: PASS`) |
| 3 | Language Proficiency: Grammar & Structure | 52 active (38 EN, 14 FIL) | 52/52 | 52/52 verified + all 18 fixes + Flash sweep PASS + all 3 Dart gates PASS | Complete (`2c39b5ea1`, `c615d6553`, `257b7042c`; net `-116` tokens, 0 non-sample growth) | Checkpoint audit running | Close Batch 3 Codex audit (`Batch 3 audited: PASS`) |
| 4a | Language Proficiency: Vocabulary | 29 active (22 EN, 7 FIL) | 29/29 (`bc4ee889a`, `b659c421a`) | 29/29 independently verified (`11b8c0b7`); `spelling-rules-0012` fixed & approved (`15e8f6c0c`); Chunk 1 (11 EN) repaired (`77f5b9a1a`) | Chunk 1 done; Chunk 2 (11 EN) in flight | NOT yet audited | Finish Chunk 2 (11 EN) + Chunk 3 (7 FIL KWF), merge trap evidence into `walkthrough-trap-evidence.json`, re-verify, Codex audit |
| 4b | Language Proficiency: Language Application | 24 active (19 EN, 5 FIL) | 8/24 WIP (`clause-punctuation-checks`..`word-meaning-checks`) | 0/24 | NOT yet checked on first 8 | NOT yet audited | Finish remaining 16 lessons under connection rule, check/update first 8, merge trap evidence, verify, Codex audit |
| 5 | Reading Comprehension | 40 active (32 EN, 8 FIL) | 0/40 | 0/40 | Quiz packets ready | NOT yet audited | Rewrite under connection rule, verify, Codex audit |
| 6a | General Information: Philippine Constitution (part 1) | 38 active | 0/38 | 0/38 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |
| 6b | General Information: Philippine Constitution (part 2) | 38 active | 0/38 | 0/38 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |
| 7 | General Information: Code of Conduct RA 6713 | 47 active | 0/47 | 0/47 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |
| 8 | General Information: Environment & Peace/Human Rights | 47 active | 0/47 | 0/47 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |

## Current Immediate Queue (Nov 26, 13:50 Manila)

1. Run Codex GPT 6.2 Sol High post-connection re-audit on Batch 2 Reasoning (`codex-audit-batch2-r3.brief.md`), then commit `Batch 2 audited: PASS`.
2. Merge Batch 3 Grammar trap evidence (52 lessons, 142 pairs, 279 citations) into `content/walkthrough-trap-evidence.json`, append Batch 3 figure worklist, write `walkthrough-batch-3-grammar.md`, run Flash mechanical sweep + locked Dart gates + Codex checkpoint audit (`Batch 3 audited: PASS`).
3. Verify post-rule CSE Math diffs (`25842f38e..HEAD`) + unedited CSE Math files with independent Hydrogen verifier, then run Codex Batch 1 post-rule re-audit (`Batch 1 audited: PASS`).
4. Repair all 19 Blockers, 61 Majors, and 25 Minors on Batch 4a Vocabulary (29 lessons, incl. 7 FIL KWF wording), merge Vocabulary trap evidence into `content/walkthrough-trap-evidence.json`, re-verify, and run Codex audit (`Batch 4a audited: PASS`).
5. Finish Batches 4b through 8 saving and pushing every chunk under the Nov 26 connection rule.
