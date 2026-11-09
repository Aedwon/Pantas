# P6 drafter brief

Startup: you work on Aedwon/Pantas. Retrieve AGENTS.md, WORKFLOW.md and SUBAGENTS.md from origin/main with `git show origin/main:<path>` and follow them. Do not start other subagents.

Worktree: /Users/aedwon/.t3/worktrees/Pantas/content-cet-finish-r1-0bd3c4d0f0d38603 (branch content/cet-finish-r1). Read `docs/content/rewrite/cet/p6/plan.md` in full; its rules bind you.

For each lesson in your batch (listed in the task):

1. Read the lesson file in full and its question file's `meta.exams`.
2. Read the audit's candidate links for it in `docs/content/rewrite/cet/p6/audit-lesson-prerequisites.json`, and any lesson the text points to ("see the ... lesson", "the ... lesson teaches").
3. For each candidate target, open the target lesson and confirm what it teaches. Decide required, helpful or no link by the plan's rules. Required needs an idea this lesson uses but does not explain. If this lesson explains it, even briefly, the link is helpful or absent.
4. Check the exam rule for required links: every exam in this lesson's question file `meta.exams` must be in the target's. If not, use helpful and say so in the reason.
5. Gap tags: read every wrong-choice `rationale` in this lesson's question file. Tag a wrong choice only when its mistake is clearly a gap in one of this lesson's link targets (for example, a sign error in arithmetic that the order-of-operations lesson teaches). Copy the choice `text` exactly, character for character. Most choices get no tag.

Lesson ids are the `_id` line in each lesson's frontmatter. Lesson files are under `content/lessons/`, question files at the matching path under `content/questions/` with `.yaml`.

Write `docs/content/rewrite/cet/p6/draft-<batch>.json`, exactly:

```json
{
  "links": {
    "<lesson id>": [
      {"lesson": "<target id>", "strength": "required", "reason": "One sentence naming the idea this lesson uses and the target teaches."}
    ]
  },
  "gapTags": {
    "<question id>": {"<exact wrong-choice text>": "<target lesson id>"}
  }
}
```

Every lesson in the batch appears in `links`, with `[]` when it needs none. Reasons are plain English, no em dashes, American spelling.

Do not edit any content file. Do not stage or commit. Report back in under 200 words: counts of required and helpful links and gap tags, each required link in one line (lesson -> target: idea), and any case you were unsure of.
