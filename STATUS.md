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
- RD-006 and RD-007 are duplicates (same lessons, same rewrite commit); use RD-006 only.
  RD-008 reads RW-006.
