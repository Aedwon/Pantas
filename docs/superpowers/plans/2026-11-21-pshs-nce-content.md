# PSHS-NCE science, verbal and abstract: content to sell this cycle

Date: November 21, 2026. Lead: PSHS-NCE science, verbal and abstract lead (Opus 5.5), reporting to the operations manager. Policy read: `origin/main` 0172e8dfb (AGENTS.md, WORKFLOW.md, SUBAGENTS.md, orchestrator.md, process-improvement.md, manager handoff); rulings read at 3eb2bca91. Velocity row: E-128. Content branch: `content/pshs-nce-r1`, fast-forwarded to `content/cet-bite-r1` d97de9415 (prod content, Nov 20), manager-accepted.

Goal: sell PSHS-NCE this cycle (test Jan 30, 2027; go/no-go Dec 8). Aedwon, Nov 21, verbatim: "for codex maximize it bc it's expiring and im not renewing but i still have 1 reset and i'd like to use it before the expiration".

Controlling documents: bite-sized spec `docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md` (B3 pool rule); D21 and D22 rulings, `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, "Nov 21"; lane source `docs/content/pshs-nce/source.md` on the branch (disputed keys II-16, III-18).

## State found (Nov 21)

1. The lane's five new lessons were already split by the CET lane (37954745d, 608655c88) and are in prod content. No bite-sized work is left for them.
2. The 70 official sample items now map onto 118 current parts: 59 covered, 11 partial (`docs/content/pshs-nce/r2/remap.json`, Codex GPT 6.2 Sol). Partials: II-1, II-4, II-20, II-21 (single words and idioms), the seven D21 items.
3. A part shows in an exam only when it has a question tagged for that exam. Of the 112 non-dots parts, 6 have PSHS-NCE questions today (27 questions, math and figure-rule parts). Shared question files are tagged per file, not per question.
4. The 12 text-only dots questions are deleted (58be251da), D22 ruling.
5. The content exporter's exam roster (`tools/build_content_export/build_content_export.dart:21`) has no PSHS-NCE entry. No PSHS-NCE mock exists; the mock length goes to Aedwon through the manager.

## Lead rulings

- R1. New PSHS-NCE-only question files; no shared file is re-tagged. Tagging a shared file would pull every part of that old lesson into PSHS-NCE, much of it CSE or CET level, and would change live CSE and CET files. This applies the D21 condition (added files only, export diff proof) to the whole lane.
- R2. Files: `content/questions/<subject>/<topic>/<old-lesson-slug>-pshs.yaml`, `exams: [pshs-nce]`, every question with explicit `lesson:` (the part) and `keyPoint:`. Ids follow the file. Five choices, A to E, as the official sample shows.
- R3. Pool per part: every key point has a question, and the pool is the part's quiz size plus one (so a retake is not identical), counting existing PSHS-NCE questions. 112 parts: quiz sizes sum to 252; target about 430, about 400 new.
- R4. Level: questions use realistic PSHS-NCE language for a Grade 6 applicant and stay inside what the part teaches. Explanations and notes in Grade 5 English (style guide).
- R5. II-1, II-4, II-20, II-21: no lesson change. They test single words, not a method; the spelling, context-clue and idiom parts carry the method and get questions.
- R6. Abstract and spatial questions use only figure kinds the app draws; a question whose figure cannot be drawn is not written. Dots parts get no questions until D22's kind renders on staging.
- R7. No sample item or disputed key is copied or used as fact. Lessons and questions may say only that the official sample has items like this.
- R8. Models (Aedwon via manager, Nov 21): Codex GPT 6.2 Sol medium writes; Codex GPT 6.2 Sol high reads, blind-solves and fit-reads, always a separate run from the writer. Fallback for reads and solves: Gemini 4 Neon only. No Claude workers. Gemini 3.8 Flash only for verified bulk, never answer correctness.

## Work

1. Exporter roster (Codex Sol, branch `tools/pshs-nce-export-roster` from main): add PSHS-NCE to the export roster the way the other built-in exams are listed, with a failing test first, then the fix; `flutter analyze` and the exporter's tests. PR to main; merge after CI passes.
2. D21 (Fable ruling, conditions 1 to 7): 7 new standalone parts for II-10, II-13, II-14, II-16, III-10, III-12, III-15, with 2 to 3 questions each (about 20). Sol writes, Sol high reads, loop at most 3 rounds. A science part that needs a figure goes through the CET figure pipeline with existing kinds, or waits.
3. Questions for the 112 parts (R1 to R7): about 16 Sol jobs of about 25 questions, grouped by topic, each followed by the validator. Then blind solve (Sol high, about 4 jobs of 100), fit read (Sol high, about 8 jobs of 50), fix rounds, re-solve of fixed items. The lead rules on each mismatch and approves through main's approval tool with an evidence file.
4. Gates, with main's tools on the content root: validator, approval gate, lesson pool check (per exam), size and split checks, attribution, em dash 0, lesson audit for the new parts. Export before and after: CSE and CET lesson lists, pools and mocks identical (D21 condition 3).
5. D22 content, after the kind renders on staging: 15 to 20 dots questions, blind-solved from the rendered figure.
6. Mock (Aedwon, Nov 21, "go with 2"; launch log): `content/mock/pshs-nce.yaml`, four sectional tests of 60 minutes and 50 items (quantitative, verbal, science, abstract), 240 minutes in all, named and noted as a Pantas practice exam, not the official format, following the UPCAT and DCAT files. Topic weights inside a test are an even split and are never shown. Codex Sol writes it after the pools exist; the mock topic check and a fill probe on several seeds pass.
7. Pool sizing: 150 PSHS-NCE questions per test, so three attempts run before a repeat. Abstract needs about 90 more than step 3 plans (60 to 150), written to drawable kinds in separate `-pshs-2` files once the abstract files are clean, same loop. Verbal reaches about 150 with D21; science about 186. Quantitative has 62 and needs about 88 more: outside this lane until the manager names an owner.
8. Hand the root to the integrator for staging; prod content after Aedwon's "ship it". Opening PSHS-NCE for sale is a separate decision.

Each Codex run is sized to one account's 5-hour window, writes findings to a file as it goes, runs only when `codex-pick --status` shows 5-hour room, and uses `CODEX_PICK_PARALLEL=1` for parallel jobs. On exit 75: commit work in progress, tell the manager which accounts are full.

## Estimate (E-128)

Lead active about 6 h; wall about 3 days (Nov 21 to Nov 24) for steps 1 to 4 and 6; step 5 about half a day after the D22 kind lands. Codex does all writing, reading and solving. Uncertain: Sol high solve speed, and how many science parts in D21 need a figure.

## Estimate change (Nov 21, mock option 2)

Added: about 90 abstract questions (about 4 Codex jobs) and the mock file. Plus about 1.5 h of lead time; wall to about Nov 25. Quantitative +88 not counted.

## Progress

- Nov 21: branch fast-forwarded; 12 text-only dots questions deleted; re-map done (58be251da).
- Nov 21: Aedwon chose mock option 2; lanes 1 to 3, D21 lessons and the exporter fix running.
- Nov 22: PAUSED by the manager (Aedwon put the CSE public release first; Codex after the weekly reset goes to CSE first). Content branch `content/pshs-nce-r1` cdfff232e. State: 76 PSHS-NCE-only question files, 477 questions, none approved. 53 files passed blind solve and fit read; 23 are open. Of the open ones: 12 carry lead rulings (`docs/content/pshs-nce/r2/lead-rulings.md`) and wait for round 4; 4 were fixed by hand by the lead (`lead-fixed.txt`); 3 finished round 4 and are still open (excited and nervous about, reading a phase diagram, punctuation); tenses and voice has its lead-ruling fix committed but no round-4 solve. The 88 quantitative questions are all written and clean (12 files). D21: 7 parts written and closed by the lead; the three science parts need 9 drawn figures. Exporter roster fix: WIP on `tools/pshs-nce-export-roster` ecaf38861, tests not run (needs a Flutter slot). Not started: +90 abstract, the mock file, approvals, gates, the export diff proof, D22 questions. Codex: account a refuses GPT 6.2 Sol (likely a lapsed subscription; not logged in by agreement); b and c at about 90% weekly. Pipeline state and evidence: `~/.local/state/pantas/pshs-r2`; resume with `docs/content/pshs-nce/r2/run-all.sh` in the run worktree after merging the content branch.
