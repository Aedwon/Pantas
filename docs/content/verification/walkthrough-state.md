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

**Current state (Nov 26, 5:30 PM Manila): see `docs/superpowers/handoffs/2026-11-26-claude-lesson-lead-cse-walkthrough.md`. The table above is the previous lead's and is out of date for Batches 1, 3, 4a and 4b.**

## Claude lesson lead takeover (Nov 26, 15:31 Manila, E-198)

- Lead: Claude Opus 5.5 lesson lead (Gemini lead out of quota). Policy read: `origin/main` `650eda378`.
- Corrections to the hand-over state, found in the branch and the previous lead's files:
  - Batch 1 Math: the PASS is pre-rule (`25842f38e`). The post-rule independent verifier's result was lost with its task thread, and no post-rule re-audit ran. Math needs re-verification and a re-audit.
  - Batch 3 Grammar: the round 2 Codex audit of `a5dea5097` ran and FAILED (0 Blockers, 9 Majors, 6 Minors). Report copied to the lead's scratchpad (`gemini/batch3/codex-audit-batch3-r2.md`).
  - Filipino glosses: the round 1 audit asked for every English gloss to be removed and the previous lead stripped them in all Filipino Grammar lessons. That contradicts Aedwon's Oct 4 decision (option 1: short English gloss for a hard grammar term on first use; `docs/content/lesson-style-guide.md`, Filipino section; checklist L09). The glosses are being restored. Audit briefs must state this rule.
  - Trap evidence: `content/walkthrough-trap-evidence.json` holds 155 lessons (Math, Reasoning, Grammar, plus one Vocabulary lesson). The other 28 Vocabulary lessons' citations are not merged yet.
  - The UX lead's 4 Vocabulary import errors were already fixed in the previous lead's uncommitted edits (checkpoint `80465ebd8`). The renderer branch's parser now passes all 191 walk-through lessons.
- New check run per chunk: the renderer branch's `planWalkthrough` parser (copied from `ux/walkthrough-renderer-r1` `222010878`) over each lesson, plus the locked `lesson_checks.dart` from `tools/walkthrough-checks-r1`.
- Commits so far: `80465ebd8` (checkpoint of the previous lead's Filipino Vocabulary edits), `97fda158a` (Grammar round 2 fixes and gloss restore; independent verifier FAIL with 2 Blocker groups, fix round running), `366a3e175` (Vocabulary Filipino review).

### Audit ruling (manager, Nov 26, about 5:10 PM Manila)

- Codex accounts a and c have no subscription (Aedwon: "those accounts don't have subscriptions anymore"). Only account b exists until its weekly reset, Monday Nov 30, 6:06 AM.
- A full batch audit costs about 2% of b's weekly room (b was 86% after Grammar round 3). Spend b on Grammar and Vocabulary; start no Codex run once b reaches 90% weekly.
- After that, Math, Language Application and Reading Comprehension get a Claude Fable 5.2 high read-only audit with the same brief, committed as "Batch N audited: PASS (Fable)".
- After Monday's reset, Codex re-audits every Fable-passed batch before it goes live. Nothing goes live before the renderer lands.

Fable-passed batches waiting for a Codex re-audit: (none yet)

### Fresh-instance rule (lead, Nov 26)

The approved sample teaches "The dog barks" and checks "My sister (teach / teaches) in Cebu". Verifiers found many Quick Checks and tries that reuse the exact sentence or word Core Concept just taught (11 in Vocabulary, 15 of 16 unaudited Grammar lessons). The worker rules now require a fresh instance of a taught rule in every check and try (rule 5a), neutral example headings (5b), and rules scoped to what holds (7). Math and Reasoning passed their audits before this was checked; the manager was asked whether to sweep them.

## Previous lead's queue (Nov 26, 13:50 Manila, superseded by the takeover notes above)

1. Run Codex GPT 6.2 Sol High post-connection re-audit on Batch 2 Reasoning (`codex-audit-batch2-r3.brief.md`), then commit `Batch 2 audited: PASS`.
2. Merge Batch 3 Grammar trap evidence (52 lessons, 142 pairs, 279 citations) into `content/walkthrough-trap-evidence.json`, append Batch 3 figure worklist, write `walkthrough-batch-3-grammar.md`, run Flash mechanical sweep + locked Dart gates + Codex checkpoint audit (`Batch 3 audited: PASS`).
3. Verify post-rule CSE Math diffs (`25842f38e..HEAD`) + unedited CSE Math files with independent Hydrogen verifier, then run Codex Batch 1 post-rule re-audit (`Batch 1 audited: PASS`).
4. Repair all 19 Blockers, 61 Majors, and 25 Minors on Batch 4a Vocabulary (29 lessons, incl. 7 FIL KWF wording), merge Vocabulary trap evidence into `content/walkthrough-trap-evidence.json`, re-verify, and run Codex audit (`Batch 4a audited: PASS`).
5. Finish Batches 4b through 8 saving and pushing every chunk under the Nov 26 connection rule.
