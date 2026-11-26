# Batch 8 Verification Record: Environment Management & Peace and Human Rights (47 Active Lessons)

- Date: November 27, 2026
- Branch: `content/lesson-walkthrough-cse-gi-r1` (branched from `content/lesson-walkthrough-cse-r1` `97fda158a`)
- Policy commit read: `origin/main` `6a2b2ec97` (Nov 26 Claude-limit rule, connection rule, cut-pass rule, shell-command rule, save-as-you-go rule, fresh-instance `:::check` and `:::try` ruling)
- Spec: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Pick 1a: 900 pre-tap words; Pick 2A: Show answer)
- Checks branch: `tools/walkthrough-checks-r1` (`3358aaa08`, all 11 locked Dart lesson checks)
- Scope: All 47 active Batch 8 CSE General Information lessons across 2 topics:
  - **Environment Management (25 active lessons, `ord` 1–25):** Chunks 8-1 [13] and 8-2 [12] under `content/lessons/general-information/environment-management/`.
  - **Peace and Human Rights (22 active lessons, `ord` 1–22):** Chunks 8-3 [12] and 8-4 [10] under `content/lessons/general-information/peace-and-human-rights/`.
  - All 7 retired parent files (`disaster-risk-reduction-and-management.md`, `environmental-concepts.md`, `environmental-problems-and-climate-change.md`, `species-resources-and-environmental-decisions.md`, `the-environmental-laws.md`, `human-rights-fundamentals.md`, `humanitarian-law-and-human-rights-law.md`) and all 7 question YAML files kept byte-identical to `97fda158a`.
- Preserved markers (byte-identical to `97fda158a`): all 3 active `<!-- AUDIT: ... -->` comments in Environment Management (`disaster-risk-and-readiness.md`, `solid-waste-law.md`, `source-segregation-and-waste-types.md`) and all 11 active `<!-- SOURCE AUDIT: ... -->` comments in Peace and Human Rights (`universal-rights-and-history.md` plus all 10 Chunk 8-4 lessons `ord` 13–22).

## Independent Verification & Re-Verification (All 4 Chunks)

Every lesson was verified line-by-line by independent Hydrogen verifiers that did not author the lessons against `content/reference/cse/environment-management.md`, `docs/content/verification/environment-management.md`, `content/reference/cse/peace-and-human-rights.md`, `docs/content/verification/peace-and-human-rights.md`, `HEAD` parity (`97fda158a`), primary statutory and treaty rules (RA 10121 Secs. 2–3 & 5, NDRRMC 2024 NDRP, RA 9729 / RA 10174 Sec. 8, RA 9147 Secs. 2 & 25, RA 7586 / RA 11038 E-NIPAS, RA 9003 Secs. 2–3, 20–22, 48, RA 8749 Sec. 20, RA 9275 Secs. 5, 14, 19, PD 1586 Secs. 2 & 4, Proclamation 2146, EO 192 Secs. 4, 8, 16; 1987 Constitution Article III Secs. 1–22 and Article XIII Secs. 17–18, UDHR, ICCPR Arts. 4, 5(1), 6–8, 11, 15–16, 18, 1949 Geneva Conventions Common Arts. 2–3, Third Geneva Convention Arts. 127 & 129–130, Additional Protocol I Arts. 35, 41, 48, 51–52, 57, 1925 Geneva Gas Protocol), and the 7 linked Batch 8 question YAML files:

- **Chunk 8-1 (13 lessons, Environment Management: DRRM, Climate Change, Species & Protected Areas, `ord` 1–13):** Round 1 found `0B/3M/1m` (3 quiz-stem echoes in `disaster-response-and-recovery.md`, `protected-area-management.md`, `national-climate-framework.md`; 1 minor polish in `choosing-environmental-options.md`), all fixed directly; Round 2 independent re-verification returned `VERDICT: PASS` (`0B/0M/0m`), 39 pairs / 39 citations folded, committed & pushed at `c16a4bb60`.
- **Chunk 8-2 (12 lessons, Environment Management: Environmental Laws & Waste Concepts, `ord` 14–25):** Round 1 found `0B/4M/8m` across 8 files (fresh-instance/echo fixes in `critical-area-review.md` and `solid-waste-law.md` plus minor precision/prose cleanups), all fixed directly; Round 2 independent re-verification returned `VERDICT: PASS` (`0B/0M/0m`), 34 pairs / 36 citations folded, committed & pushed at `e60ff0261`.
- **Chunk 8-3 (12 lessons, Peace & Human Rights: Human Rights Fundamentals, UDHR, Bill of Rights, CHR, `ord` 1–12):** Round 1 found `0B/7M/2m` (7 multi-limb `Wrong:` lines narrowed to one misconception each with aligned trap JSON citations across 5 lessons; 2 `:::check` blocks upgraded to fresh concrete cases in `custodial-investigation-and-bail.md` and `commission-on-human-rights.md`), all fixed directly; Round 2 independent re-verification returned `VERDICT: PASS` (`0B/0M/0m`), 35 pairs / 38 citations folded, committed & pushed at `4a1001c2f`.
- **Chunk 8-4 (10 lessons, Peace & Human Rights: HRL/IHL, Armed Conflict, ICCPR, Geneva Conventions & Attack Rules, `ord` 13–22):** Round 1 found `1B/6M/4m` (Blocker: replaced forced farm labor in `iccpr-protected-rights.md` with clear ICCPR Art. 8(2) lifelong servitude so Art. 4(2) non-derogation is legally exact; 6 Majors: refreshed duplicate/echoing examples across `hrl-and-ihl-together.md`, `iccpr-emergency-conditions.md`, `iccpr-protected-rights.md`, `people-protected-from-attack.md`, and `ihl-preparation-and-peace.md`; 4 Minors: trimmed `iccpr-protected-rights.md` to 811–814 pre-tap words, refreshed Example `#3` in `attack-rules.md`, plain-English heading in `military-targets.md`, wording cleanup in `ihl-preparation-and-peace.md`), all fixed directly; Round 2 independent re-verification returned `VERDICT: PASS` (`0B/0M/0m`), 27 pairs / 30 citations folded.

## Mechanical, Trap-Evidence, and Locked Dart Verification

- **Trap evidence (`content/walkthrough-trap-evidence-gi.json`):** Batch 8 contributes 47 lessons, 135 inline `:::pair` blocks, and 143 verbatim non-correct quiz citations matching each lesson's exact `lesson:` ID across the 7 Batch 8 YAML files (`0` errors; valid JSON, 4,357 lines; cumulative GI total across Batches 6a + 6b + 7 + 8: **170 lessons, 489 pairs, 607 citations**, 100% pair-ID parity with `489` `:::pair` tags across all 170 active GI lessons).
- **Locked Dart checks (`tools/walkthrough-checks-r1` `3358aaa08`, all 11 checks):**
  Reproducible command:
  ```bash
  cd /Users/aedwon/.t3/worktrees/Pantas/walkthrough-checks-r1 && \
    dart run tool/content/lesson_checks.dart \
      --root /Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-bb19920ca963260f/content 2>&1 \
    | grep "general-information/" \
    | grep -v "missing walkthrough-trap-evidence.json entry"
  ```
  Result: `0` violations across all 170 active GI lessons (`lesson_size_check`, `lesson_split_coverage_check`, `lesson_pool_check`, `walkthrough_trap_pair_check` structure/anchors, `walkthrough_example_connection_check`, `walkthrough_fresh_instance_check`, `walkthrough_hard_break_check`, `walkthrough_block_spacing_check`, `walkthrough_emphasis_check`, `walkthrough_fence_line_check`, `walkthrough_example_check_line_check`).
- **Sweeps & prose:** `0` em/en dashes, `0` backticks, `0` stock AI phrases, `0` `not just/only ... but`, `0` sentences > 25 words, `0` AI attribution markers in any GI file or branch commit, all pre-tap word counts inside the 150–900 Dart cap (`717`–`901` raw visible tokens excluding `:::why`/`:::answer`, all `<= 900` under `lesson_size_check.dart`).

## Checkpoint Audit Status

- **Codex GPT 6.2 Sol High Checkpoint Audit Round 1:** Queued via `codex-pick` after the post-6:42 AM Manila Codex account `b` reset window and queue order (1. Claude lesson lead's Grammar full read; 2. GI Batch 6b R3 + Batch 7 R1 + Batch 8 R1 as budget permits, strictly one Codex run at a time, no Fable fallback).
