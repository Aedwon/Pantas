# Brief: counting check, pilot (Task 4)

You are a Codex checker on the Pantas repository. Read `AGENTS.md` from main
with `git show origin/main:AGENTS.md`. No computer control or browser use.
Work only with files in this worktree.

Inputs: `docs/content/audit/coverage-r1/inventory.md` (Science section only),
`docs/content/audit/coverage-r1/outline-comparison.md`, and
`docs/content/audit/coverage-r1/requirements/upcat.md` (Science section only).

Check, and report each problem with the exact text:

1. Every Science lesson slug in the inventory is covered by the provisional
   tags, and the count is 51.
2. Every lesson slug named in `outline-comparison.md` exists in the inventory's
   Science section. List any that do not.
3. Every Science topic or skill line in `requirements/upcat.md` labeled
   curriculum or weak appears in the mapping table as matched, partial, or a
   gap. List any line with no row.
4. No row says "Matched" while naming no lesson.

Write exactly one file: `docs/content/audit/coverage-r1/counting-check.md`, with
a section per check and a last line `RESULT: PASS` or `RESULT: FLAGS <count>`.
Do not edit anything else. Do not commit. No em dashes.
