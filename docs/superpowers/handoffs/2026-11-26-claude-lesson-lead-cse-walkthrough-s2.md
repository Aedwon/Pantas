# Handoff: CSE lesson walk-through rewrite, Claude lesson lead session 2 (E-198)

Date: November 26, 2026, 5:25 to 8:40 PM Manila. Lead: Claude Opus 5.5 lesson lead. Policy read: `origin/main` `a5888282f` at start; later main commits `2defb1756` (shell-write rule, repeat) and the completion-notice entry were read. Branch `content/lesson-walkthrough-cse-r1`, head `988a312d6`. Checks branch `tools/walkthrough-checks-r1`, head `d68e902fc`. Reason for handoff: about 3 hours and a long thread; the Claude 5-hour limit also stopped one worker at about 8 PM. Read the session 1 handoff (`2026-11-26-claude-lesson-lead-cse-walkthrough.md`) first: its controlling documents, his words and method still apply.

## What changed this session

1. Found that the round 4 Codex run had written more than the saved partial file: 52 findings on the 20 later English Grammar lessons and 50 on 20 Vocabulary lessons, in scratch files the session 1 handoff missed. Both saved in `docs/content/verification/walkthrough-work/` (`codex-grammar-r4-part-b.md`, `codex-vocab-r1-partial.md`).
2. Grammar (52): every round 4 finding fixed; the 19 English lessons fixed again after a strict sweep; two independent verifier rounds plus a diff verification, all findings fixed (`grammar-r4-verifier-findings.md`, `fil-vocab-verifier-findings.md`, `diff-verifier-findings.md`). Parser 207/207, `lesson_checks.dart` 0 violations outside Language Application, no lesson grew.
3. Grammar round 5 Codex audit at `44d38877f`: **FAIL, 42 Blockers, 52 Majors, 1 Minor** (`codex-grammar-r5.md`; 26 reopened from round 4). Not fixed yet.
4. Vocabulary (29): all 50 Codex findings fixed, 9 unaudited lessons sweep-fixed, two verifier rounds, all findings fixed, word counts at or below `fabe161e7`. Not audited. Trap evidence: two notes corrected, a `soft-g` pair added.
5. Fresh-instance check: `tool/checks/walkthrough_fresh_instance_check.dart` (+ test, wired into `lesson_checks.dart` and `run_checks.dart`), `d68e902fc`, shown failing first; tuned from 43 flags to 3 (all real). It is narrow (7-word runs, long math); it misses reused number sets such as `a=12`. Reading sweeps remain the real control.
6. Math (55): fresh-instance sweep, 25 lessons changed; independent re-solve of every changed item: all correct; one reused root fixed. Approved-sample lessons untouched.
7. Reasoning (47): fresh-instance sweep, about 35 lessons changed; two independent solves: PASS after small fixes.
8. Language Application: the 11 English lessons fixed for `la-en11-verifier-findings.md` plus extra problems (not re-verified). The worker on the 5 Filipino and 8 earlier English lessons stopped at the Claude limit after editing 7 files (5 Filipino, `clause-punctuation-checks`, `modal-meaning-checks`); its edits pass the parser and are committed; it wrote no citations file.
9. Worker rules: workers now run no checks and no shell writes (a worker sat 40 minutes on an approval prompt for a redirected word-count script; my brief caused it). `worker-rules.md`, `fixer-brief.md`, `verifier-brief.md`, `writer-brief.md` updated. The lead runs the parser (`walkthrough-work/importer/run.dart` + the renderer's `walkthrough_markdown.dart`, copy in the session scratchpad), word counts and `lesson_checks.dart` (through `flutter-locked.sh`, from the checks worktree, `--root <this worktree>/content`).

## The open problem: Grammar does not converge under Codex

Each Codex round on Grammar finds a new layer (round 4 about 100 findings, round 5 95). Round 5's classes, in order of count:
- a Quick Check placed under a heading that names the category it asks for (complex, compound, finite, possibility, sentence type);
- chains and Checks ending at a label, letter or fragment instead of the finished sentence, and Checks that repeat the step above;
- open rewrite tries that accept several answers (Codex wants a fixed slot or complete options);
- rules still stated as universal (comma after an opening clause, *will* always future, nearest-noun agreement, *ang* marks every subject);
- reopened round 4 items where the fix covered one line but not the checklist or pair note that repeats the rule.

Lead's recommendation for the next session (not yet put to the manager as a ruling):
1. Fix by pattern, not by finding: give each fixer a set of lessons and the five classes above as a checklist to apply to every check, try, chain, pair note, shortcut and checklist line, plus the round 5 rows for its lessons. A rule fixed in the core must be fixed in its pair note, Speed Tricks and checklist in the same pass.
2. Then a Fable 5.2 high read-only audit with `codex-grammar-r5.brief.md` (Fable costs no Codex). Repeat fix and Fable until it passes. Spend the last Codex room (b at 96% weekly, about 1 to 2 audits, resets Monday Nov 30, 6:06 AM) only on a final confirmation.
3. Apply the same five classes to Vocabulary, Language Application, Math and Reasoning before their audits; the heading-named check pattern was found in Vocabulary and Filipino Grammar too and fixed there once.

## Open items for the manager or Aedwon

- Approved sample `discounted-prices`: its Example 2 try uses the same 20% then 10% pair as the core's 1,000-peso example, and its Check states 28%, which the core already states. It is his approved sample; not changed.
- Twelve spatial Reasoning tries reuse the core's figure because a new instance needs a new hand-made figure (list in the Reasoning R2 commit `801fa7644` message and the session log). They need figure worklist rows.
- Quiz stem `parts-of-speech.yaml:485` uses *pagkakakilanlan* (identity) where a concrete object fits; the lesson now uses *susi*. Question files are outside this lane.
- `baybay-ng-hiram-na-salita`: the check uses *kuwerdas*, confirmed only in web dictionaries, not KWF print.
- E-198 velocity row is still not on main (session 1 handoff noted it). Timer at 4 h 54 min active at 8:35 PM; it was not paused during the Claude limit stop.

## Next actions, in order

1. Language Application: finish the 13 lessons the stopped worker had (5 Filipino verify, 8 earlier English sweep and citation extraction to `walkthrough-work/la-evidence-13.json`); re-verify the 11 English; merge `la-evidence-en11.json`, `la-evidence-fil5.json` and the new file into `content/walkthrough-trap-evidence.json` with the Edit tool; run the checks.
2. Grammar: pattern fix pass on all 52 with the round 5 rows; verify; Fable audit; repeat to PASS.
3. Vocabulary: pattern pass; Fable audit.
4. Math and Reasoning: pattern pass; Fable audits (Math post-rule).
5. Reading Comprehension: write in chunks with `writer-brief.md`.
6. After Monday 6:06 AM: Codex re-audits of every Fable-passed batch, one at a time.
