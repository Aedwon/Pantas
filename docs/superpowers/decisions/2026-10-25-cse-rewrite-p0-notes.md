# CSE rewrite P0 notes, October 25, 2026

Plan: `docs/superpowers/plans/pwa-launch/E4-E7-cse-content-rewrite.md` (approved, balanced).

## Done
- Brief builder and 78 briefs plus `new-lessons.md` on `content/cse-rewrite-r1` (d978d5a9).
  The 7 lessons added on October 25 get CSE added to their tagged exams in the builder.
- Question typing check on the same commit. Bank scan: 8 problems, all in
  `content/questions/science/physics/light-and-optics.yaml` (not CSE): double-quoted choice text
  with a single backslash, so `\theta` and `\times` import as a tab or other control character.
  These are real display bugs; fix when that file is next edited.

## Findings
- Illustration worklist: the README's 278 is from July. Markers were cut to 59 on August 22 and
  to 7 on August 31; `worklist.tsv` was last regenerated on August 22. Today 7 markers exist in
  the corpus, 3 in the 78 CSE lessons (one Reading lesson). Aedwon's October 25 direction (many
  SVG figures per lesson where they help) reverses the August reduction for CSE lessons.
- OpenAI terms (pages read October 25: Terms of Use effective January 1, 2026; Usage Policies;
  Service Terms updated October 16, 2026; Codex and Plus help articles): no rule found limiting
  accounts per person; the terms prohibit circumventing rate limits or restrictions, so rotating
  accounts to exceed one account's limits carries a suspension risk; automated extraction of
  web chat output is prohibited, while pasting by hand and official Codex use are fine; Aedwon
  owns output for commercial use. The subagent read the pages with the built-in browser after
  plain fetches were refused, which WORKFLOW.md's computer-control rule does not allow; recorded
  as a process slip.
- Relay rules affecting the plan: scripts may not push (chat uses `git_push_current`); one
  worktree serializes relay operations (plan updated, main 2026-10-25).

## Pending for Aedwon
- Figure style choice: four samples published as a private page (Lesson Figure Styles).
- Whether to use three Plus accounts for Codex given the circumvention risk.
