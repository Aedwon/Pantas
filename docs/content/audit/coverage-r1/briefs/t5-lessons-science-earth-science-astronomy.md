# Brief: lesson depth, Science / earth-science-astronomy (Task 5, pilot)

## Startup

You are a Codex worker on the Pantas repository. Read `AGENTS.md`,
`WORKFLOW.md`, `SUBAGENTS.md`, `docs/content/content-checklist.md`,
`docs/content/source-policy.md`, and `docs/content/lesson-style-guide.md`
from main with `git show origin/main:<path>`. No computer control or browser
automation; web search and page reading only.

## Objective

Read every lesson in the Science topic `earth-science-astronomy` and report, for UPCAT, whether
each required skill is actually taught. You read and report only. You do not
edit lessons.

## Inputs

- Lessons: `/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2/content/lessons/science/earth-science-astronomy/*.md`
  (corpus commit `765c5dc0`; read only).
- Requirements: `docs/content/audit/coverage-r1/requirements/upcat.md`,
  Science section, in this worktree.
- Provisional mapping and apparent gaps:
  `docs/content/audit/coverage-r1/outline-comparison.md`, rows for this topic.

## For each required skill in this topic

Record, with evidence (lesson slug, section heading, and a short quote under
25 words):

1. **Taught:** yes, partial, or no. Does the lesson explain the idea and how to
   use it?
2. **Worked example:** yes, no, or not needed (only where solving is involved).
3. **Prior knowledge:** is what the skill needs taught somewhere in the corpus?
   Name the lesson, or say it is missing.
4. **Depth versus requirement:** enough, thin, or unknown, given the
   requirement's evidence label. Do not invent a required depth.

Confirm or reject each apparent gap for this topic from the outline
comparison, with evidence.

## While reading

- Check hard-to-remember facts you meet against sources per the source policy.
  Write a source ledger table for every fact you check: item (lesson slug),
  claim, disposition (CONFIRMED, WRONG, UNCLEAR), source with URL, note. If a
  fact is wrong, quote it and the source.
- Note any checklist finding you notice, with its rule id (for example L17,
  B01) and the quoted text. You are not running the full checklist; separate
  checkers do that.

## Output

Write exactly one file:
`docs/content/audit/coverage-r1/topics/science-earth-science-astronomy-lessons.md` with sections:
1. Skill findings (a table: skill, evidence label, lessons, taught, worked
   example, prior knowledge, depth, evidence).
2. Apparent gaps: confirmed or rejected, with evidence.
3. Wrong or doubtful facts (or "none found").
4. Checklist findings noticed.
5. Source ledger.
6. Open questions.

Do not edit anything else. Do not commit. No em dashes. American spelling.
