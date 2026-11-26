# Batch 6a Verification Record: Philippine Constitution Article III (Bill of Rights)

- Date: November 26, 2026
- Branch: `content/lesson-walkthrough-cse-gi-r1` (branched from `content/lesson-walkthrough-cse-r1` `97fda158a`)
- Policy commit read: `origin/main` `345d20ba1` (Nov 26 connection rule, cut-pass rule, file-edit rule, save-as-you-go rule, fresh-instance Quick Check rule)
- Spec: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Pick 1a: 900 pre-tap words; Pick 2A: Show answer)
- Checks branch: `tools/walkthrough-checks-r1` (`b8640b532`)
- Scope: All 35 active Article III Bill of Rights CSE lessons under `content/lessons/general-information/philippine-constitution/` (`ord` 1-35 across Chunks 6a-1 [13], 6a-2 [11], 6a-3 [11]). All 4 retired Article III parent files (`bill-of-rights.md`, `bill-of-rights-property-courts-and-custody.md`, `bill-of-rights-the-accused-and-the-trial.md`, `bill-of-rights-punishment-detention-and-limits-on-laws.md`) and all question YAML files kept byte-identical to `97fda158a`.

## Independent Verification & Re-Verification (All 3 Chunks)

Every lesson was checked line-by-line by independent verifiers that did not author the lessons against `content/reference/cse/1987-constitution.md`, `docs/content/verification/philippine-constitution.md`, the 1987 Constitution Article III text, Rules of Court (Rules 102, 113, 117, 119, 126), RA 7438, RA 9346, Act 4103, and the 4 Article III question YAML files:

- **Chunk 6a-1 (13 active lessons, ord 1-13):** Round 1 found 0 Blockers, 36 Majors (quiz-stem echoing, grab-bag `Wrong:` lines, 2 dropped `HEAD` nuances, 7 missing Core Concept scenarios, `Answer:` in `:::try`, missing blank lines before lists), 7 Minors. All fixed; Round 2 independent re-verification returned `VERDICT: PASS` (0 Blockers, 0 Majors, 2 Minors fixed directly in `bill-of-rights-information-and-association.md` and `bill-of-rights-detention-and-punishment.md`). 6 Quick Checks refreshed in `9e8aa445a` to enforce the fresh-instance Quick Check rule.
- **Chunk 6a-2 (11 active lessons, ord 14-24):** Round 1 found 0 Blockers, 7 Majors, 7 Minors. All 14 fixed directly; Round 2 independent re-verification returned `VERDICT: PASS` (`0 Blockers, 0 Majors, 0 Minors`).
- **Chunk 6a-3 (11 active lessons, ord 25-35):** Round 1 found 1 Blocker (`"lifelong confinement"` blurring *reclusion perpetua* vs *life imprisonment* in `bill-of-rights-replacement-penalties-and-parole.md`), 4 Majors, 6 Minors. All 11 findings plus 2 Quick Check fresh-instance updates fixed directly; Round 2 independent re-verification returned `VERDICT: PASS` (`0 Blockers, 0 Majors, 0 Minors`).
- **Trap evidence (`content/walkthrough-trap-evidence-gi.json`):** 35 lessons, 98 inline `:::pair` blocks, 149 verbatim non-correct quiz citations verified 1-to-1 against matching `lesson:` IDs across the 4 Article III YAML files (`0` errors; trimmed 7 secondary citations when narrowing multi-error `Wrong:` lines in Fable R1 remediation).
- **Pre-tap word counts & structure:** All 35 lessons within `707` to `837` pre-tap words by the locked size check (which strips `{#anchor}` tags; well under the 900 cap), `0` sentences over 25 words, `0` em/en dashes, `0` backticks, `0` stock AI phrases, `0` `not just/only ... but`, `0` unwrapped digits, `0` Dart `lesson_checks.dart` violations (including `walkthrough_emphasis_check` and `walkthrough_fresh_instance_check`), byte-identical frontmatter, `keyPoints`, and `SOURCE AUDIT` comments.

## Checkpoint Audit Status

- **Fable Checkpoint Audit Round 1 (`claudeAgent / claude-fable-5-2`, effort `high`, read-only on `b9e275ad2`):** `VERDICT: FAIL` (`Blockers: 0, Majors: 26, Minors: 19`).
  - Majors 1–5 (legal precision, RA 9346 Section 3 `"by reason of the Act"` qualifier, Section 20 separate-crime trap, Section 18(2) pair direction): all 5 fixed.
  - Majors 6–23 (fresh-instance `:::check` and `:::try` ruling across 18 lessons): all 18 fixed so every `:::check` and `:::try` tests a fresh concrete instance.
  - Majors 24–25 (Core scenario / Example #3 quiz-stem echoing in `religion-abode-and-travel.md` and `habeas-corpus-suspension.md`): both replaced with fresh scenarios.
  - Major 26 & Minor 8 (7 multi-error `Wrong:` lines): all 7 narrowed to one coherent misconception per pair with aligned `walkthrough-trap-evidence-gi.json` citations.
  - Minors 1–7 and 9–19 (Rule 126 Sec. 5 writing attribution, fresh instances/non-echoing examples, public-welfare qualifier, stale Part 4 pointers, Core result lines, Grade 5 wording, `Article VII, Section $18$` citation, treachery gloss, sentence splits `<= 25` words, removing unsourced writ mentions, exact word-count range): all 19 fixed.
- **Fable Checkpoint Audit Round 2 (`claudeAgent / claude-fable-5-2`, effort `high`, read-only on `190aa5d77`):** `VERDICT: FAIL` (`Blockers: 0, Majors: 2, Minors: 14`).
  - Major 1 (`bill-of-rights-replacement-penalties-and-parole.md`): narrowed Core to penalty choice alone; rewrote Example #3 around a good-conduct parole claim without revealing the result before `:::try`.
  - Major 2 & Minor 6 (`bill-of-rights-fines-and-prison-punishment.md`): replaced Core with a concrete pending heinous-crime bill; rewrote Check #2 to test the heinous-crime condition on a minor offense and split the 26-word sentence.
  - Minors 1–5 (fresh-instance checks/try beyond noun swaps in `religion-abode-and-travel.md`, `accused-charge-and-defense.md`, `backward-penal-laws-and-legislative-punishment.md`, `requested-dismissals-and-acquittals.md`, `political-beliefs-and-forced-service.md`): all 5 rewritten with distinct elements/scenarios.
  - Minors 7–14 (court reads charge at arraignment, waiver pair placement, third poll-tax case line, spoken+written Core case, pair-note bridges, arrest-warrant records result line, singular writ heading, exact locked-check word range `707`–`837` and `0` sentences over 25 words): all 8 fixed, plus 3 nested bold+italic emphasis hits flagged by `walkthrough_emphasis_check` in `bill-of-rights-prohibited-laws.md` and `habeas-corpus-suspension.md`.
- **Fable Checkpoint Audit Round 3 (`claudeAgent / claude-fable-5-2`, effort `high`, read-only on `bb381ff32`):** **`VERDICT: PASS` (`Blockers: 0, Majors: 0, Minors: 2`)**.
  - All 2 Round 2 Majors, all 14 Round 2 Minors, and all 3 nested-emphasis fixes verified closed with `0` regressions (`707`–`837` pre-tap words, `0` sentences over 25 words, 35 lessons / 98 pairs / 149 citations / `0` errors).
  - Both Round 3 polish Minors (`bill-of-rights-religion-abode-and-travel.md:34` civil-vs-political phrasing and `bill-of-rights-search-and-arrest-warrants.md:70` plain-English wording) fixed directly in the pass commit. Codex re-audit scheduled after Monday's weekly reset.
