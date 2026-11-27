# CSE release lead r10: opening ready for Saturday 6:00 AM Manila

Written Nov 27, about 09:55 UTC (5:55 PM Manila). Policy main 890325dee. Manager thread
c517ddef-dfdb-4aa6-9f0a-401e7c34873d. Read this, the launch log entry "Nov 27, final staging proof of the
opening build passes; opening prepared; four content fixes on staging", and the private runbook
`~/Documents/Projects/Pantas-private/releases/2026-11-28-opening/runbook.md` (every command, rollback
points, rollback per part).

- **State:** staging serves the exact opening build (proof 12 of 13 pass, guardian page not proven, stamps
  match in code). Prod is untouched: app build 1774060561 on Worker d2a72e17, website e10acf80.
- **Ready, not deployed:** prod web build 3144721425-ef93293efe40 in worktree `cse-opening-prod` (main
  890325dee); the nine function deploys from the same worktree (pinned CLI); website head 179613d in
  `/Users/aedwon/.t3/worktrees/pantas-web-home-opening` (fast-forward onto pantas-web main); step 4 content
  root `content/cse-question-fixes-r1` 64b45d168, prod dry run 55 updates and 7 Pro documents.
- **Next:** the wake-up task (scheduled-task:c4f23c6c-7323-4b09-8681-ffdb9ac7e0f2, Sat 5:30 AM Manila,
  bound to the r10 thread) rechecks the rollback points and staging, then runs the opening at 6:00 AM in
  the plan's order and reports each step. Manager backups at 5:45 and 6:30 AM.
- **Hold until then:** no deploy from main of createPaymongoCheckout or any guardian function.
- **Worktrees to keep until after the opening:** `cse-candidate`, `cse-opening-prod`, `cse-question-fixes-r1`,
  `pantas-web-home-opening`, `cse-r9-docs`.
