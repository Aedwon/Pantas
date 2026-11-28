# Brief: fix R3 Codex read 1 once (E-216, step 5)

Startup: retrieve `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from GitHub main (`git show origin/main:<file>`) and follow
them. Lead's policy commit `3bffd9286`. Worktree: this one (branch `content/walkthrough-reasoning-r1`). Hard rules: as in
`reasoning-r1-slim-brief.md` (Edit or Write only; read-only Bash and git; no commits; no subagents).

Findings: `docs/content/verification/walkthrough-work/codex-reasoning-r3-read1.md` (1 Blocker, 22 Majors, 6 Minors).

## What to fix

1. The Blocker (`whole-number-and-decimal-filing.md:64`) exactly as Codex suggests, then re-sort every list in that lesson.
2. Every Major, applying the suggested fix or a smaller one that removes the problem. These classes come up most:
   - One numbered step that makes two comparisons in sequence: split it into two numbered steps.
   - Checklist lines that drop the condition the rule depends on: start the line with the condition ("If the task puts
     the suffix last, ..."). Keep each line short: condition, move, result.
   - Demos that list an order without the deciding place or unit: add the one comparison that names it.
   - Examples reusing a quiz question's exact values (`whole-number-and-decimal-filing.md:88`, `year-first-and-stated-date-formats.md:50`):
     use fresh values of the same kind; keep the cited wrong choice only in the pair.
   - `integer-subcode-filing.md:106`: never put "<" between two dotted codes; compare the parts ("second subcodes 2 < 15")
     and say "files before" for whole codes.
3. Two evidence rows, in `content/walkthrough-trap-evidence.json` only: drop the `numeric-and-chronological-filing-0002`
   citation from the month-before-year pair (keep 0017), and drop the `12/01/2025` citation from the left-to-right
   slash-date pair (keep 0018's `01/03/2025`). Edit only those two entries, with the Edit tool. Each pair keeps at least
   one citation.
4. Minors: skip, unless a Major fix already touches that line.

Do not re-flag or change (lead rulings): parallel values on one display line; a closing sentence naming the answer; a stem
that states its rule.

Words: each lesson stays at or under 900 before a tap and grows by at most 20 words.

## Checks (as in the R1 brief, for the nine `clerical-ability/` files)

1. `lesson_checks.dart --root ...`: no line for these nine files.
2. Parser: `failing: 0`. `wc.dart`: each at or under 900.

## Report (under 300 words)

Per finding: fixed (one phrase) or not fixed with the reason. Words before and after per lesson. Pasted check lines.
