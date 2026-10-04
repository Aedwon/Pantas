# Brief: UPCAT source check (Task 3, pilot)

## Startup

You are a Codex checker on the Pantas repository. Read `AGENTS.md` and
`SUBAGENTS.md` from main with `git show origin/main:<file>`. Do not use
computer control or browser automation. Use web search and page reading only.

## Objective

Check that every source cited in
`docs/content/audit/coverage-r1/requirements/upcat.md` says what the file
claims, and that each confidence label is right. You check; you do not add
requirements, rewrite the file, or research new topics.

## Rules for labels

From `docs/content/source-policy.md` on main: **official** means the exam
organizer's own material (for UPCAT, University of the Philippines pages or
documents). **Strong secondary** means a reputable source that quotes or
describes official material. Unofficial reviewers, forums, and
document-sharing uploads are **weak**.

## Steps

1. Open every numbered source. Record whether it loads.
2. For every line in the file that cites a source, confirm the cited source
   supports that exact claim and confidence.
3. Check each source's label against the rules above.

## Output

Write exactly one file:
`docs/content/audit/coverage-r1/source-checks/upcat.md`. Do not commit.

- A table: source number, loads (yes/no), label correct (yes/no), corrected
  label if wrong, note.
- A table of claim problems: the claim as written, cited source, problem
  (not supported, overstated, wrong label), and what the source actually says
  in under 25 words.
- A last line: `RESULT: PASS` if there are no problems, otherwise
  `RESULT: FLAGS` with the count.

No em dashes. American spelling. Write nothing else.
