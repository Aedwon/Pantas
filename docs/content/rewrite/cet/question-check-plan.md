# CET question check (spec P5): plan

Controlling spec: `docs/superpowers/specs/2026-11-03-cet-content-design.md` on main, P5, B4 and "Revision after the pilot" (Sol blind-solves questions). Complexity: Balanced, as approved in the spec. Written November 5, 2026.

## Scope

- 142 question files carry a CET tag (UPCAT, ACET, DCAT or USTET): 2,735 questions.
- 820 of them sit in files that also carry CSE tags. The CSE run blind-solved those on October 26 (`docs/content/audit/cse-blind-solve-r1.md`, commit 975d2564f). A question is skipped only if its stem, choices and key are byte-identical to the version solved then. Every other question is solved.
- Expected solve set: about 1,900 to 2,000 questions. Q0 reports the exact count.

## Roles

- Lead (Opus 5.5): orchestration only. Dispatches, validates outputs mechanically, rules on disputes, logs rulings. Does not write questions, tools or packets.
- Codex GPT 6.1 Sol, through `codex-pick` only: blind solves and lesson-fit reads. `codex-pick` picks the account with the most room on each call and fails over on a limit, so all three accounts are used without manual assignment.
- Sonnet 5.5: tooling and question fixes.
- Haiku 5.5: counts, merges and mechanical checks.
- Opus 5.5 subagent: second solver on disagreements (different vendor from Sol).
- At most 3 agents or Codex jobs at once (machine limit). No builds, flutter or test suites.

## Steps

**Q0. Tooling (Sonnet).** In `tools/content_rewrite/question_check/`:
- `build_packets.py`: per file, write a solve packet outside the repo (scratch folder) with stems, passages and choices only. No key, explanation, wrong-choice notes or file path. Choices shuffled per question with a recorded seed, so the key position gives nothing away. Skip the CSE-solved identical questions and list them.
- `merge_solves.py`: map the solver's shuffled answers back, compare with keys, write `docs/content/rewrite/cet/questions/solves/<file-id>.json` and a mismatch list.
- `build_fit_packets.py`: per file, the lesson text plus the full question file, for the lesson-fit read.
- Reuse the CSE loader in `tools/audit/sweep_questions.py`. Acceptance: Haiku runs all three on two files and checks no key text leaks into a solve packet.

**Q1. Pilot (3 files, one per subject type: a math file, a science file, a reading or language file).** Sol solves from an empty folder with no repository access, as the CSE control did. Measure quota used per 100 questions on each account (`codex-pick --status` before and after) and the mismatch rate. The lead projects total quota from this before Q2. If the projection exceeds the room left before the November 11 weekly reset, report it and run in reset order rather than switching tools.

**Q2. Blind solve, all files.** Batches of a few files per Codex job, 3 jobs at a time. Sol effort: low for language and reading, medium for math and science (a single low-effort solver agreed easily on CSE; science and math carry the most risk here). Each job returns one answer and a confidence per question.

**Q3. Disagreements.** For each mismatch or low-confidence answer, an Opus subagent solves the same shuffled packet blind. If Opus agrees with the key, the key stands. If both solvers disagree with the key, or Opus and Sol disagree with each other, the lead settles it from a primary source and logs it. Every changed key goes on the Astra list (P8).

**Q4. Lesson-fit read (Sol).** Per file, against its lesson: stem wording and realistic exam language, clues that give away the answer, explanation at Grade 5 that explains only the correct answer, wrong-choice notes (mistake, why it looks right, one check), skills the lesson does not teach, Filipino rules, `\dfrac`, no em dashes, American spelling. Output: findings JSON with verbatim quotes and severity (Blocker, Major, Minor), same format as the lesson reads. The lead rejects any finding whose quote is not verbatim or that breaks a lead ruling. Minor findings are not chased.

**Q5. Fix (Sonnet).** For Blocker and Major findings and changed keys: fix the question or set it inactive. If a file falls under 20 active questions, add questions to reach 20. Keep question ids; new ids continue the file's sequence. Run `check_question_typing.py` and the import check until they pass.

**Q6. Re-check (Sol).** Sol blind-solves every new or changed question and re-reads the fixed findings. At most 2 fix rounds; after that the question is set inactive and listed for the review package.

## Records

- Per-file results under `docs/content/rewrite/cet/questions/` (solves, fit reads, fixes).
- Rulings, rejections and lead errors in `final-run-rulings.md`.
- A "CET question check" line in `STATUS.md` after each batch, with counts.
- On `codex-pick` exit 75 (all accounts full): log the soonest reset in `STATUS.md`, commit, push, wait. Do not move the step to another tool.
- Commit and push after each batch.

## Done when

- Every question in scope has a key confirmed by a blind solve, or by the lead from a source.
- Every file has a lesson-fit read with no open Blocker or Major.
- Every CET file has at least 20 active questions.
- Typing and import checks pass.
- The Astra list (changed keys, new questions) is ready for P8.

## Risks

- Codex quota is the bottleneck. Each account shows about 82% weekly room today; the pilot measures real cost.
- Engineering may need Codex. Per B4, yield and resume after.
- Shared CSE files: a fix to a question that CSE also uses changes approved CSE text. Such fixes wait for Aedwon unless they are wrong keys, which B4 says to report.
