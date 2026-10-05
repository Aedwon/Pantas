# Archive: pre-restart kept work

Created October 5, 2026, for the engineering restart (stage 0, decisions 43 to 51 in
`docs/superpowers/plans/new-design/stage0-decisions.md` on main). Decision record:
`docs/superpowers/decisions/2026-10-05-engineering-restart-log.md`.

Everything removed in that cleanup is recoverable from here.

- `discarded-branches.bundle`: every commit of the deleted branches and the three dropped stashes
  that is not already in `integration/new-design-r1` or `main`. Restore one branch with
  `git fetch discarded-branches.bundle refs/heads/<name>:refs/heads/<name>` (or
  `refs/remotes/origin/<name>` for origin-only branches; stashes are `refs/archive/stash0..2`).
- `deleted-refs.txt`: each deleted branch with its local and origin tip SHA.
- `stashes.txt`: the stash list before dropping.
- `dirty/`: uncommitted work from worktrees, as `<worktree>.tracked.diff` (apply on the head
  below) and `<worktree>.untracked.tgz` with its file list.

Kept work is also copied here for safety; its worktrees were not removed: the four release
end-to-end test worktrees and the inline math accessibility checks.

Worktree heads at snapshot:
- Pantas-wt-beta-final-verification-r1: 21f40b68b00effb78e2ff919eeb6cab5a7347a62
- Pantas-wt-web-e04-content-protection-r1: 8d556f6a6e80a94b4e72e2b4ccb1d0a01fa09921
- Pantas-wt-qlp5-physical-r1: 9f7a2da1af9a516144067995beec5d2ed7a45f78
- Pantas-wt-android-release-swiftpm-r1: 3561a7de1f8a519e0773166bf42bfdc9bbfb1965
- Pantas-wt-rc-be-verify-r2: e9f9ad6537d1573642e5d0e763cf858d01862aae
- lesson-illus-w4verify: 9704a1bd8d75a7c9a1bd9a0c22fee8235b3c2183
- m7: 33f678c3a97c2d8e8cb345034c985b79f0dc464a
- Pantas-wt-a11y-inline-math-sentence-r1: b58639aae753f361e7bf98e8223ab0f310e2d7dd
- Pantas-wt-web-release-e2e-firebase-r1 and -mock-r1: 5e69e73f6cdc1e6ec447736cc0a10d808e7889bc
- Pantas-wt-web-release-e2e-quiz-delete-r1: a8c98f6a33d16c956714a95f526a88ec4fdaa9fe
- Pantas-wt-web-release-e2e-shipping-r1: 6080897422db0aa3314ac4143c76d8f0fb96df9a
