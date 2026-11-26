# CSE Lesson Walk-Through Rewrite State

- Branch: `content/lesson-walkthrough-cse-r1` (content base `content/cse-key-fixes-r1` `a7cc22b6b`)
- Latest policy read: `origin/main` `7b93f2dbe` (Nov 26 connection rule + save-as-you-go rule + no shell file edits)
- Checks branch: `tools/walkthrough-checks-r1` (`2aa92eb30`, pending new non-UI worked-example connection & chain-value check)
- Total active CSE lessons: 416 original -> 417 active (after splitting `signed-integers-and-substitution`)

## Batch Status

| Batch | Topic(s) | Lessons | Written | Verified | Connection Rule | Audited | Next Step |
|---|---|---:|---|---|---|---|---|
| 1 | Mathematics (Algebra, Arithmetic, Data Interp.) | 55 active | 55/55 | 55/55 (pre-rule) | Applied on Algebra & Arithmetic (`133aaae64`..`b9bf77f3b`, samples synced `434a1c9c9`); Data Interp. read & left alone | Pre-rule PASS (`25842f38e`); post-rule NOT yet verified/audited | Verify all post-rule math diffs & unedited math files with new connection check, then Codex re-audit |
| 2 | Reasoning (Clerical, Logical-Verbal, Spatial, Verbal Logic) | 47 active | 47/47 | 47/47 + 23 fixes + 37 audit fixes (pre-rule) | Complete (Chunk A `5a332de91` + Chunk B: 21 edited, 26 already connected) | Pre-rule R2 PASS (09:18); post-rule NOT yet audited | Run new connection check + locked Dart gates + Codex re-audit (with wordiness check) |
| 3 | Language Proficiency: Grammar & Structure | 52 active | 52/52 | 52/52 verified (0 Blockers, 9 Majors, 9 Minors found) | Chunk A (22 lessons + 11 fixes) done; Chunk B (30 lessons + 7 fixes) in progress | NOT yet audited | Finish Chunk B fixes + connection pass, merge trap evidence/worklist, re-verify, Codex audit |
| 4a | Language Proficiency: Vocabulary | 29 active (22 EN, 7 FIL) | 29/29 (`bc4ee889a`, `b659c421a`) | 29/29 independently verified (`11b8c0b7`: 19 Blockers, 61 Majors, 25 Minors); `spelling-rules-0012` fixed & approved (`15e8f6c0c`) | Partial (needs fixes on detached pairs & missing walk-through blocks) | NOT yet audited | Repair all 19 Blockers + 61 Majors + 25 Minors (incl. 7 FIL KWF wording), merge trap evidence into `walkthrough-trap-evidence.json`, re-verify, Codex audit |
| 4b | Language Proficiency: Language Application | 24 active (19 EN, 5 FIL) | 8/24 WIP (`clause-punctuation-checks`..`word-meaning-checks`) | 0/24 | NOT yet checked on first 8 | NOT yet audited | Finish remaining 16 lessons under connection rule, check/update first 8, merge trap evidence, verify, Codex audit |
| 5 | Reading Comprehension | 40 active (32 EN, 8 FIL) | 0/40 | 0/40 | Quiz packets ready | NOT yet audited | Rewrite under connection rule, verify, Codex audit |
| 6a | General Information: Philippine Constitution (part 1) | 38 active | 0/38 | 0/38 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |
| 6b | General Information: Philippine Constitution (part 2) | 38 active | 0/38 | 0/38 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |
| 7 | General Information: Code of Conduct RA 6713 | 47 active | 0/47 | 0/47 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |
| 8 | General Information: Environment & Peace/Human Rights | 47 active | 0/47 | 0/47 | Quiz packets ready | NOT yet audited | Rewrite under connection rule + primary-text check, verify, Codex audit |

## Current Immediate Queue (Nov 26, 13:10 Manila)

1. Save uncommitted Batch 2 (47 Reasoning), Batch 3 (52 Grammar & Structure), and partial Batch 4b (8 Language Application) as separate `WIP, not yet audited:` commits and push.
2. Add the non-UI worked-example lead-in and display-chain value check on `tools/walkthrough-checks-r1` (shown failing on the old `substituting-negative-numbers.md` sample first).
3. Redo all four samples in `docs/content/walkthrough-samples/` to the Nov 26 connection rule (no added wordiness) and send to the Operations Manager.
4. Embed the Nov 26 connection rule and verbatim target in every writer, verifier, and audit brief.
5. Verify post-rule Math edits and all 29 Vocabulary lessons (including Filipino wording check on the 7 Filipino lessons), apply Batch 3's 18 verification fixes plus the connection rule to Batches 2 and 3, then continue Batches 4b through 8 saving and pushing every chunk.
