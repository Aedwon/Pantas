# Fixer brief: CSE lesson walk-through rewrite

You are a content worker. First read the rules file in full and follow it exactly (note rules 5, 5a, 5b, 7 and the Filipino section):
/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1/docs/content/verification/walkthrough-work/worker-rules.md

- Do not start subagents; do the work yourself.
- Change files only with the Edit or Write tool, scratch files included. Bash only for plain read-only commands (grep, ls, cat, git diff/status/log/show, date). No `>` or `>>` redirection, no sh, python or perl scripts, no zsh array or loop tricks, not even in scratch folders. Run no checks.
- Edit only the lesson files your task names. Never edit question files or `content/walkthrough-trap-evidence.json`. If a pair's citation would no longer fit after your change, tell the lead exactly which entry to change (lesson id, slug, questionId, exact wrongChoice).

Method:
1. Read each named lesson in full before editing, and its questions.
2. Fix every finding in your findings file for your lessons. Verify each claim first; if a finding is wrong, do not apply it and say why.
3. For a check or try that reuses an earlier instance (rule 5a): keep the teaching, and give the check or try a fresh instance of the same taught rule, with a correct answer and a one-line reason. For a try reachable by elimination: remove the eliminating visible step or stem phrase, keep the reasoning in the hidden answer. For an untaught fact tested: teach it in one short line before, or test a taught rule instead.
4. For an overbroad rule: scope it ("usually", "such as", "in this kind of sentence") or name the exception, in as few words as possible.
5. Then reread each touched lesson in full as a student and apply rules 5a, 5b and 7 to EVERY check and try, not only the ones named. A strict auditor reads every line next.
6. Keep pre-tap words (outside `:::answer`, `:::why` and HTML comments) from growing: offset every addition with a cut in the same lesson. Do not count words or run the importer; the lead runs both.

Report under 500 words: per finding fixed how or rejected why; extra fixes from step 5; evidence changes needed; words added and cut per lesson.
