# CSE rewrite status

Plan: `docs/superpowers/plans/pwa-launch/E4-E7-cse-content-rewrite.md` on main (approved October
25, balanced). Base: `content/question-qa-r2` at 765c5dc0.

## P0 preparation

| Task | State | Evidence |
|---|---|---|
| P0.1 brief builder | done | d978d5a9; 78 briefs + `new-lessons.md`; 11 tests pass |
| P0.2 mechanical fixer | done, applied | bd03b0b1; 62 tests pass; 15 dash and 52 number fixes in 22 lessons, idempotent; 36 items left for writers (`needs-review`); 27 traps without a one-line warning and 43 table rows left for writers |
| P0.3 question typing check | done | d978d5a9; 24 tests pass; 8 real problems in `science/physics/light-and-optics.yaml` (not CSE) |
| P0.4 prompt page and relay hand-in | phase 1 done (rewrite, read); pull-request hand-in added Oct 25 (see below) | `tools/content_rewrite/relay/`; 118 tests pass; 28 rewrite batches planned; GitHub check passes (736d8b47); read form rule text synced to checklist 14a218d8; tools live on this branch, not the audit branch |
| P0.5 terms check | done | main `docs/superpowers/decisions/2026-10-25-cse-rewrite-p0-notes.md` |
| P0.6 new lessons and splits | applied, not committed | Plans in `docs/content/rewrite/plans/`. Oct 25 decisions applied: 5 splits (Bill of Rights x4, environment x4 plus laws, duties x2, tenses x2), 8 new part lessons plus 4 new lessons as stubs (12 files each for lesson and questions), 41 questions moved with ids unchanged (3,215 ids before and after), 12 `outline.json` entries, `split-map.json` (99 rows) applied by the brief builder (86 briefs; row totals unchanged), 18 builder tests pass. New files hold teaching only where it was moved; the rest is `<!-- REWRITE -->`. Each new file is short of 20 questions. Open: first-part titles kept (question C), tenses Filipino part inherits all 9 exam tags (question F) |
| P0.7 illustration worklist | done | 7 markers in the corpus, 3 in CSE lessons; README count stale |
| P0.8 SVG in the app | waiting | style D approved Oct 25 (`docs/content/rewrite/figure-style/`); app code waits for engineering coordination |
| P0.9 source ledger | done | `docs/content/audit/cse-rewrite-ledger.md` (header only) |

Notes: B08 brief rows on lines the fixer changed may already be fixed; the writer checks the
line and the reader confirms. Two stray chat citation markers removed from the visual media
lesson (bd03b0b1).

## October 25: splits applied (fdcbdba3)

12 lessons added: 8 split parts and 4 new stubs; 41 questions moved with ids unchanged (3,215 ids
before and after); importer exit 0. The push check on fdcbdba3 failed as expected: the length
guard (written to catch a truncated chat rewrite) flagged the two lessons that shrank by design
(bill of rights, duties and prohibited acts). Later pushes compare with the split versions. The
`REWRITE` placeholder comments raise the AI-TELL sweep count by 1 per lesson until rewritten.
New question shortfall to 20: 14 lessons, about 240 questions in all.

## October 25: pilot run 1 (Aedwon pasting, two ChatGPT accounts)

- Rewritten and handed in: RW-001 to RW-005 (14 lessons; commits 34ecd529 to 11614784).
- Read and handed in: RD-002 (3 RA 6713 lessons), RD-004 (3 comprehension lessons).
- Not done: RW-006 (earth science) and the other read batches.
- Blocker: in some chats the ChatGPT GitHub connector refused to create the `[relay]` issue
  ("This tool call was blocked by OpenAI's safety checks"), before GitHub received it. Same
  workflow succeeded in other chats, so it is intermittent or payload-specific. The chats stopped
  as instructed and did not work around it. Do not retry around the check; the lead designs a
  path that does not carry file writes in issue bodies.
- Next: lead reviews the 14 rewrites and 6 reads after the Claude usage reset.

## October 25: pull-request hand-in (built, not yet run on GitHub)

Replaces the relay issues for rewrite and read batches. The chat commits to `cse-inbox/<batch id>` with the
GitHub connector and opens a pull request `[handin] <batch id>` into this branch. Workflow
`.github/workflows/cse-handin.yml` (check name `CSE hand-in`) runs `relay/handin_ci.py`, keeps one bot comment,
holds the pull request (label `held`) on the third rejection, and squash-merges an accepted one. The old relay
hand-in still works for manual use (`/api/prompt?id=<batch>&mode=relay`).

- Batch definitions are now files in `docs/content/rewrite/batches/<batch id>.json` (the lead commits them
  before any hand-in); the state folder keeps only the order.
- A merge by `GITHUB_TOKEN` starts no push workflow, so the hand-in workflow starts `cse-rewrite-checks.yml`
  with `workflow_dispatch` (added to that file; needs `actions: write`). The page reads that run.
- `planner.py requeue` adds a read's open findings and not-fixed brief items to a new rewrite batch.
  RW-007 (the three RA 6713 lessons) was made this way.
- Live test: commit and push this branch, then run on a throwaway branch `cse-inbox/RW-007` a hand-in with
  the three lessons (or a one-line change in a fixture batch), open the pull request, and read the Actions tab.

## October 25: pull-request hand-in live

Committed dd8365cf (319 tests pass). Live test PR #30 (`cse-inbox/RW-007`, one of three lessons):
the `CSE hand-in` check rejected it in 14 seconds, naming the two missing lessons; PR closed
unmerged. The merge path is untested until the first real batch. Branch `cse-inbox/RW-007`
was deleted with Aedwon's approval.
Requeue batch RW-007 holds the three RA 6713 lessons whose reads found Major problems.

## October 25: pilot run 2

- PR hand-in merges work: RD-001 (#31), RD-005 (#32), RW-007 (#33) merged by the workflow.
- RW-006 (earth science): the ChatGPT GitHub connector refused the lesson commit (second refusal
  for this lesson, after the relay refusal). Per the plan's fallback, Codex GPT 6.1 Sol (high,
  then low for the fix) rewrote it locally; the lead cleared the earlier relay chats' two
  rejections (backup `~/.pantas-rewrite/rejections.json.bak-rw006`), ran the hand-in: one
  rejection (ILLUS, STRUCT), Codex fixed both, accepted as 58f22421 after rebase. Codex's
  sandbox cannot commit in this worktree, so the lead runs the hand-in for Codex batches.
- RD-007 duplicated RD-006 (same lessons, same rewrite commit) and was removed unused.
  RD-008 reads RW-006.
- Oct 25: RD-003 (connector refused the first file commit) runs on Codex 6.1 Sol; RD-008
  (connector refused branch creation; same earth science lesson as before) runs on a Claude
  Sonnet reader, since Codex wrote RW-006. Empty branch `cse-inbox/RD-003` left by the chat;
  delete with Aedwon's approval. Aedwon now has three Codex accounts (a, b, c) for delegation;
  how to select each account is not yet recorded. The lead's Claude usage is near its limit, so
  the lead keeps involvement minimal.
- Codex accounts (Aedwon, Oct 25): `~/.codex` is account b (default), `~/.codex-a` and
  `~/.codex-c` are a and c; all support `gpt-6.1-sol`. Select with
  `CODEX_HOME=/Users/aedwon/.codex-a codex exec -m gpt-6.1-sol ...`; unset means b. On a usage
  limit, note the reset time and switch accounts. Engineering asks before using Sol. Aedwon
  chose this setup after the October 25 terms note about limit circumvention.
- Pilot reads complete: RD-003 (Codex reader; one L09 fix by Codex account a; 72decc37), RD-006
  (PR #34 held after three form rejections; lead fixed L19 via Codex account c and handed in
  locally, 92c5bd55; PR closed unmerged), RD-008 (Sonnet reader; 28370225). Leftover branches
  `cse-inbox/RD-003` and `cse-inbox/RD-006` await Aedwon's approval to delete.

## October 25: pilot report

- 15 lessons rewritten and read (14 via web chat, 1 via Codex; RA 6713 lessons rewritten twice).
- Brief items in latest reads: 278 fixed, 9 not fixed (all in the 3 language application lessons).
- New findings in latest reads: Blocker 2, Major 20, Minor 7. 17 of the 20 Majors and both
  Blockers are in the 3 language application lessons; L18 (example coverage) is 12 of 20 Majors.
  Single Majors (L18) in penalties and enforcement, statements of assets, number and letter
  sequences.
- Hand-in rejections were mostly form-format slips; 2 batches held, both recovered by the lead.
- ChatGPT GitHub connector refusals: at least 4 named (earth science lesson 3 times), plus
  unnamed relay refusals in run 1. Codex and Sonnet fallbacks worked.
- Time: rewrites 15:34 to 18:31, reads 15:56 to 19:03 (two accounts, part-time pasting).
- Length: the 15 lessons went from 9,965 to 20,996 words (about 1,400 per lesson, within the
  1,700 ceiling).

## Final state (October 27)

| Phase | State | Evidence |
|---|---|---|
| P1/P2 lesson rewrite and reads | done: 90 lessons (78 scope + 8 split parts + 4 new lessons); 86 clean, 4 minor-only, 0 Blocker or Major | `docs/content/audit/cse-rewrite-ledger.md` (lead rulings, final state) |
| P4 questions | done: 243 new questions (all CSE files at 20+); blind solves of 1,343 questions (1 key fixed); 94 figure questions checked (2 fixed, 11 need Aedwon's visual check); 54 files synced to rewritten lessons | `docs/content/audit/cse-blind-solve-r1.md` |
| P5 Astra audit | done: 27 findings on General Information, 26 verified and fixed | `docs/content/audit/cse-astra-audit.md`, `cse-astra-verdicts.md` |
| Roadmap inputs (E8) | done: `content/lesson-prerequisites.json` (4 required, 60 helpful), `content/question-gap-tags.json` (116 tags) | spec on main `docs/superpowers/specs/2026-10-26-prerequisite-roadmap-design.md` |
| P3 figures | resumed and done Oct 29: 94 SVGs plus 2 visual-media PNGs cover all 100 lesson markers. 28 held figures committed after two Sonnet fix rounds with Codex review (17 fixed; 2 known minor spacing gaps: visual-media 07, citizenship 01). 8 new: visual-media 03 to 09, logic-and-reasoning 01 (new brief; old 01, 02 renumbered 02, 03). Visual-media PNGs renumbered to lesson order; stale duplicate cartoon removed. All figures use Geist text and KaTeX math (approved trial); style rule updated. Checker 94/94 pass. Not yet seen in the app: renderer must resolve Geist and KaTeX families (engineering). `worklist.tsv` is stale (science now uses FIGURE specs) | `docs/content/rewrite/figure-briefs/`, figure-style rules |
| Open for Aedwon | confirm two lead rulings (penalties Section 11(c) framing; citizenship treated as English); review content; visual check of 11 figure questions; visual check of the figure gallery; build and upload (E7) | ledger |
