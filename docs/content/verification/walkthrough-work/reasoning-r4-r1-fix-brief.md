# Brief: fix R4 Codex read 1 once (E-216, step 5)

Startup: retrieve `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from GitHub main (`git show origin/main:<file>`) and follow
them. Lead's policy commit `3bffd9286`. Worktree: this one. Hard rules and check commands: as in
`reasoning-r1-slim-brief.md` (Edit or Write only; read-only Bash and git with plain arguments; no commits; no subagents).

Findings: `docs/content/verification/walkthrough-work/codex-reasoning-r4-read1.md` (5 Blockers, 11 Majors, 5 Minors), for
the four lessons under `content/lessons/reasoning/verbal-logic/`.

## What to fix

1. All 5 Blockers, using Codex's suggested fix or a smaller one that removes the problem. After each, re-derive every
   verdict in that lesson that depends on the changed line (pairs, checklist lines, examples, the check and the try).
   - A pair's Wrong line must still show its cited wrong choice (`content/walkthrough-trap-evidence.json`, which you do not
     edit). If a fix changes a pair's passage, keep the cited wrong choice and its error.
2. All 11 Majors, the same way. Where an example's try answer starts with the key but its reasoning ends on rejecting a
   wrong choice, reorder so the reasoning ends at the key.
3. Minors: skip, unless a Blocker or Major fix touches that line.

Do not re-flag or change (lead rulings): a pair may reproduce its cited quiz case; a same-kind example with a new passage
is allowed.

Words: each lesson stays at or under 900 before a tap and grows by at most 25 words.

## Report (under 300 words)

Per finding: fixed (one phrase) or not, with the reason. Words after, per lesson. Pasted check lines (lesson checks grep for
your four files; parser).
