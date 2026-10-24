# CSE content rewrite, figures, question check and build (PWA plan E4 to E7)

Date: October 25, 2026. Status: draft for Aedwon's approval. Amends Lane E of
`docs/superpowers/plans/2026-10-19-pwa-launch.md` (tasks E3 to E7). Every decision it relies on
is in `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`, October 25 entries.

## Part A. For Aedwon

### What this plan does

It fixes the 78 CSE lessons, adds the CSE teaching they are missing, draws the figures they need,
checks and fixes their 1,562 questions, has a strong model attack the riskiest results, and ends
with your review and the content build. It starts when the engineering run frees the ChatGPT
accounts. Preparation that needs no ChatGPT can start now.

### What goes in

- 656 audit findings to fix (497 small, 151 medium, 8 large). 271 optional findings are fixed
  only when the passage is being edited anyway.
- 361 CSE teaching gaps: 339 go into existing lessons, 4 become new lessons (the three branches of
  government, citizenship and voting, amending the Constitution, corruption and its effects), and
  6 English lessons gain a Filipino section.
- 7 figure requests from the audit, plus the figures the rewrites add, plus 94 questions that are
  switched off until their figure exists.
- 1,562 questions in the 78 lessons' question files.

### Who does what

| Who | Work |
|---|---|
| ChatGPT web chat, GPT 6 Sol High (you paste) | Lesson rewrites, 3 or 4 lessons per chat. Full independent read of every rewritten lesson, 2 or 3 per chat. Blind solves, about 25 questions per chat. Question checks and question fix drafts. New questions where a lesson has fewer than 20. |
| Codex, GPT 6.1 Sol (limited) | Question figure data. Code-drawn lesson figures. New lesson files and their records. Anything the scripts reject twice. |
| GPT 6 Astra (once, at the end) | Adversarial review of the riskiest results and a random sample. |
| Claude lead (Claude Pro) | Scripts, rulings, lesson splits, prerequisite links, sample review, merges, acceptance. Haiku 5.5 runs bulk checks; Sonnet 5.5 takes judgment-heavy bulk work. |
| You | The pastes. Review in Lesson Author and Question Studio. Final approval. |

No model checks its own work. Every rewritten lesson gets a fresh chat's full read.

### The steps

1. **Preparation (no ChatGPT, can start now).** Scripts that build one short brief per lesson,
   make the mechanical fixes (numbers in math notation, dashes, headings), and check question
   file typing. A batch mode for the paste page: one paste holds several lessons or questions,
   and the reply is split, saved and checked per item. A check of OpenAI's terms on using three
   accounts. Outlines for the 4 new lessons and the split proposals for 6 oversized lessons.
2. **Pilot: about 3 lessons from each of the 6 subjects (about 18 lessons)** through every step:
   rewrite, checks, full read, fixes, my review, your review. It measures pastes, rejections,
   time per paste, how many findings the rewrite fixed, and new problems the rewrite introduced.
   You decide whether to continue, change the split, or stop.
3. **All lessons, topic by topic.** The writer chats take topic N while the reading chats take
   topic N minus 1. New lessons and splits go through the same steps.
4. **Figures.** For each needed figure: first an existing code-drawn figure type (Codex writes
   the data), then a ChatGPT-generated image through Illustration Studio (you export it), then an
   open-licensed image. If none fits, I decide whether a new figure type is worth building or the
   figure is dropped. A checker confirms each figure matches its text.
5. **Questions.** A 50-question calibration first. Then a blind solve of every question; a second
   chat with the key settles every answer that differs. A per-file check reads the questions
   against the rewritten lesson: wording, clues, explanations, wrong-choice notes, and whether the
   lesson teaches what is tested. Fix drafts come from web chat; scripts apply them and run the
   import check. Lessons under 20 active questions get new ones (near-duplicates allowed).
6. **Adversarial review (6 Astra, once).** Every Blocker fix, every changed answer key, every
   legal fact, every large rewrite and new lesson, plus a random 10% of everything else. Its
   error rate on the sample is reported before launch.
7. **Your review and the build.** You review lessons in Lesson Author and questions and figures
   in Question Studio, subject by subject. Your findings go back to step 3, 4 or 5. Then the
   content database is built: full for mobile, CSE only for web.

### Rules that hold throughout

- A rewrite may add CSE cases but never removes a case another tagged exam needs.
- Question ids are never renumbered or reused.
- Every changed fact gets a source row in the rewrite source ledger.
- I own the prerequisite links; writers flag new dependencies.
- Filipino spelling a model cannot confirm against the official Filipino language body (KWF) is
  listed for you.
- At a usage limit, sign-in or security prompt, the work pauses and asks you. Nothing works around
  a limit.

### Cost and what is not known

- Your pastes, estimated before the pilot: about 25 for rewrites, 30 for full reads, 65 for blind
  solves plus their disputes, 78 for question checks, and about 40 for question fixes and new
  questions. About 240 in total. The pilot replaces these estimates with measured numbers.
- Codex usage under the Plus limits for this work is unknown until the pilot.
- Four puzzle lessons have no active question today: every question needs a figure. Mental
  rotation has 6. These lessons depend on step 4 to reach 20.
- No gallery page exists for reviewing all figures at once; Lesson Author's illustration review
  and Question Studio are the review screens.

### Decisions for you

1. Approve this plan at **balanced** complexity (the level recommended on October 25; you have not
   picked one yet). Minimal drops the pilot and the per-subject measurement. Hardened adds a
   second reader for General Information legal facts, about a third more reading pastes.
2. The figure order in step 4: code-drawn first, then ChatGPT image, then open-licensed.

## Part B. Agent section

### Identity and branches

- Policy: refresh `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from main before each phase and in
  every dispatch, with the startup text from `docs/workflow/startup.md`.
- Audit inputs: `docs/content-coverage-audit-r1` (worktree `Pantas-wt-content-coverage-audit-r1`)
  at ecbfa88b or later: `level4/paste/results/triage.jsonl`, `triage.md`,
  `cse-teaching-gaps.jsonl`, `findings/`, `data/`.
- Corpus base: `content/question-qa-r2` at `765c5dc0`. Before the pilot, the lead fetches and
  confirms the base has not moved; if it has, stop and reconcile.
- Rewrite branch: `content/cse-rewrite-r1`, cut from the base, one worktree
  (`Pantas-wt-cse-rewrite-r1`). Codex workers get their own worktrees on short branches merged by
  the lead. Workers never merge.
- Status: a "CSE rewrite" section in `docs/superpowers/plans/pwa-launch/RESUME.md` (row E4 to E7)
  and a `STATUS.md` on the rewrite branch, updated at each task completion.

### P0 tasks (lead, Haiku, Sonnet; no ChatGPT)

1. **Brief builder** `tools/content_rewrite/build_briefs.py` (rewrite branch). Per lesson: its
   `real` triage rows (id, rule, quote, problem, reason, fix size), its CSE gap parts with the
   study's missing ideas, the exact rule lines each row cites from `lesson-style-guide.md` and
   `content-checklist.md`, the lesson's tagged exams, and optional `judgment` rows in a separate
   block. Output `briefs/<lesson-id>.md`. Test: every real row and every placed gap part appears
   in exactly one brief.
2. **Mechanical fixer** `tools/content_rewrite/mechanical_fix.py`: B06 em dashes, B08 numbers in
   prose to inline math, L20 heading format, L22 tables flagged (not converted). Dry run first;
   the lead reviews the full diff on 5 lessons before applying. Applied as its own commit. Marks
   the matching triage rows `fixed-by-script`.
3. **Question typing check**: extend the existing question import check (or a pre-check script
   run before it) to report bare numbers, `: ` in unquoted text, LaTeX escapes in double quotes,
   and bare booleans in choice text. When it exists, the guide's typing paragraphs shrink to one
   line pointing to it (separate guide edit, recorded).
4. **Paste page batch mode** on the audit branch, beside `LessonList` (`paste_lib.py` already
   expects a second list type). Item lists: `rewrite` (3 to 4 lessons per prompt, one topic),
   `read` (2 to 3 rewritten lessons per prompt, fresh chat, the Level 4 form per lesson), `solve`
   (about 25 questions, stem and choices only), `settle` (disputed questions with key and
   explanation), `qcheck` (one question file plus its rewritten lesson), `qfix` (YAML items).
   Reply format: one fenced block per item with a start and end marker naming the item id. The
   page splits the reply, runs each item's checks, saves accepted items, and gives a ready reply
   for rejected ones. Same safety as `server.py` (local only, host and origin checks). Rewrite
   items also pass a change guard: a script lists every changed passage and whether a brief row
   or gap part covers it; uncovered changes are flagged to the reader and the lead, not blocked.
   Tests with fixtures, as for `paste/tests`.
5. **Terms check**: OpenAI's current terms on one person running several Plus accounts and Codex
   from one machine. Record the result; a conflict is a stop condition for that usage.
6. **New lessons and splits**: outlines for the 4 new lessons (sections, examples, CSE gap parts
   covered, prerequisites, exam tags), outline and tag entries, empty question files. Split
   proposals for the 6 lessons with more than 12 added parts; a split creates new lesson ids and
   moves no question ids.
7. **Illustration worklist**: rerun `tools/audit/list_illustrations.py`; the README says 278 and
   `worklist.tsv` has 59 rows. Reconcile before step 4 counts figures.
8. **Source ledger**: `docs/content/audit/cse-rewrite-ledger.md` in the `source-policy.md` row
   format; one row per changed or added fact.

### P1 pilot

- Lessons: about 3 per subject across the 6 subjects, chosen by the lead to include at least one
  large fix, one Filipino section, one General Information lesson with the new Traps section, one
  Reasoning lesson with figures, and one lesson with Blocker fixes.
- Flow per batch: brief, rewrite paste, checks (`tools/audit/run_all.py`, import, change guard),
  fix-backs, full read paste, fix-backs, lead review of the diff against the brief, Aedwon review
  in Lesson Author.
- Measures recorded in `STATUS.md`: pastes per lesson, rejection rate, minutes per paste, share of
  brief rows fixed (checked by the reader), new findings introduced by the rewrite, Codex usage.
- Gate: Aedwon's decision. No automatic continuation.

### P2 lessons

- Order: subjects in parallel lanes, topic by topic, prerequisite topics first.
- A lesson is done when: every brief row is fixed or marked skipped with a reason; the full read
  reports no Blocker and no Major; `run_all.py` and the import pass; the change guard's flags are
  resolved; the ledger rows exist; the lead's review passes.
- A read that fails returns the lesson to a rewrite paste with the read's findings. After two
  failed rounds the lesson goes to Codex with both reads. After a Codex failure it goes on the
  lead's hold list.

### P3 figures

- Inputs: illustration triage rows, new `<!-- ILLUSTRATION -->` markers from rewrites, and the
  94 question figures.
- Question figures: Codex writes `figureSpec` for an existing kind (21 registered in
  `lib/core/ui/figures/figure_registry.dart`). The figure is checked against the stem and key by
  a fresh web chat given a rendered PNG.
- Lesson figures: code-drawn through the existing original-code batches and preview renderer
  where a kind fits; otherwise an Illustration Studio prompt that Aedwon runs in ChatGPT and
  exports; otherwise an open-licensed source recorded in `content/illustrations/sources/`.
- New figure kinds: the lead decides; Claude Sonnet builds with tests; Aedwon approves the look
  in the visual companion before it is used.

### P4 questions (replaces the Level 5 run for CSE)

- Calibration: 50 questions including hard Mathematics, Science and Filipino items, solved by a
  batched chat and one-at-a-time; report agreement before scaling.
- Blind solve: every question, about 25 per chat, no key, explanation or notes. Each mismatch goes
  to a `settle` chat with the key; if it still disagrees, to the lead.
- Mechanical question rules: scripts and the import check (content gate in `SUBAGENTS.md` Part 4:
  validator 0, emdash 0, approved 0, noexams 0; fix its unindented id count first).
- Judgment rules and practice against teaching: one `qcheck` paste per question file with its
  rewritten lesson.
- Fixes: `qfix` drafts applied by script; import check after each file. Ids never change. A
  removed question is retired, not reused.
- Shortfall: lessons under 20 active questions get new questions; near-duplicates allowed.
- Changed questions get a fresh blind solve.
- In-lesson quiz items: none exist in the 78 lessons and the style guide defines no quiz syntax
  (checked October 25), so there is nothing extra to check.

### P5 adversarial review

- 6 Astra in Codex, one run: every Blocker fix, every changed answer key, every legal fact row in
  the ledger, every large rewrite and new lesson, plus a seeded random 10% of other lessons and
  questions. Report its findings and the sample error rate. Fixes return to P2 or P4 and are
  rechecked; Astra does not run again unless Aedwon asks.

### P6 review and build

- Aedwon reviews subject by subject in Lesson Author (port 4321) and Question Studio (port 4323)
  started from the rewrite worktree. Findings go back to P2, P3 or P4.
- Build: the existing content tools (`tools/build_content_export`, `build_content_seed`,
  `build_content_package`, `verify_content_package`) for mobile (full) and web (CSE only), plus
  the content uploader dry run. The lead verifies, then merges per the integration decisions in
  force.

### What this plan supersedes

- Lane E's model split of October 19: lesson and question work moves from Codex to batched web
  chat; figure data moves from Haiku to Codex (Claude Pro has the smallest limits).
- The October 25 checker-reads-the-diff idea: replaced by a full independent read of every
  rewritten lesson (Aedwon, October 25).
- The cheaper-model-first blind solve: web chat has no practical limit, so every blind solve uses
  GPT 6 Sol High.
- Codex effort matches the fix: high for Blockers, new lessons and figures; medium otherwise.

### Stop conditions

- Policy or standards change on main during the run: stop and ask whether finished lessons need a
  recheck.
- The corpus base moved, or an unexpected change in the rewrite worktree.
- A usage limit, sign-in, or security prompt in any tool.
- The terms check finds a conflict.
- A finding that would remove another exam's needed case.
