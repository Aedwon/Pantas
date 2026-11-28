# Brief: blind pre-check and recompute, R1 pilot (E-216, step 3)

One verifier does both jobs in one pass. You did not write these lessons. You never fix anything; you report.

Startup: retrieve `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from current GitHub main (`git show origin/main:<file>`) and
follow them. Lead's policy commit `3bffd9286`. Plan: `git show origin/main:docs/superpowers/plans/2026-11-28-walkthrough-reasoning-cse.md`,
sections 2 and 4. Format reference: `git show origin/content/lesson-walkthrough-cse-r1:docs/content/verification/walkthrough-work/pilot-precheck-brief.md`
(its format notes and output formats apply; its severities are replaced below).

Worktree (read only, except your findings file):
`/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-cse-math-finish-55955c9731459ccd/7ab66a46-209f-4182-80b0-634771f1bda3/scratchpad/reasoning`.
Run `git log --oneline -1` there and name the commit in your findings file.

Lessons (4), under `content/lessons/reasoning/logical-verbal-reasoning/`: `sequence-moves.md`,
`sequence-positions-and-operations.md`, `sequence-letter-patterns.md`, `sequence-earlier-terms.md`. They have no pictures.

## Steps

1. **Blind solve.** For each `:::check` and `:::try`, read only the lesson text above it, with its `:::answer` covered.
   Solve it yourself. Then compare with the key. Ask: can the answer be copied from a visible line above? Is it the only
   choice that fits? Is there a second defensible answer (another simple rule that fits every shown term and gives a
   different next term)?
2. **Recompute** every number, letter position and term in the lesson: Core Concept lines, pairs, Why blocks, examples,
   answers, checklist lines. Any mismatch is a finding.
3. **Rules.** List every sentence with every, always, never, only, all, any, none, whenever, must, or a bare "X means Y".
   For each, try one counterexample a CSE series question could show. Report only the ones that fail.
4. **Chains.** Each example shows each difference, ratio or letter move and ends at the term asked for.
5. **Repeats.** Flag an example, check or try that uses the same numbers or letters as another instance in the same
   lesson (a reused instance).

## Severities (manager rulings, Nov 28; these replace the pilot brief's)

- **Blocker:** a wrong or ambiguous key; a false rule; or an answer that can be copied (printed in a visible line above
  it, or the only choice that fits the visible text). Nothing else is a Blocker.
- **Major:** a check or try whose answer has the same form as the example or pair directly above with only values
  swapped (same-kind practice with new values is allowed; a transplantable answer pattern is not); a reused instance; a
  rule true only for the cases shown but stated generally; a chain that stops short; a lead-in that does not name what
  is found.
- **Minor:** wording, notation.

## Hard rules

- Write only your findings file, with the Write tool:
  `docs/content/verification/walkthrough-work/reasoning-r1-precheck-findings.md` in the worktree. No other file.
- Bash only for plain read-only commands and git show/log/status. No redirection, heredocs or scripts.
- Do not commit. Do not start subagents. If you hit a usage limit, stop and report.

## Findings format

`Severity | file:line | item | what is wrong (with your own solve or recompute) | suggested fix`, then a per-lesson count
line, then a verdict line: PASS (0 Blockers) or FAIL.

## Report (under 200 words)

Verdict, Blockers and Majors per lesson, the findings file path, and your own blind answers for the 4 checks and 4 tries.
