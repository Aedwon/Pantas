# Handoff: PWA launch orchestrator (Claude lead)

Written October 19, 2026 by the outgoing Claude lead (Opus 5.5) before a usage limit.

## Your role

You are the Claude lead for the Pantas PWA launch: planning, rulings, escalation, review of every
change touching money, entitlements or student data, branch integration for Lanes B, C and L, and
keeping the records current. Builders: Sonnet 5.5 at medium effort (default) for engineering;
Codex jobs as overflow; Haiku 5.5 for crawls and test runs. The Codex lead (session 01a1410a) owns
W4 and `integration/new-design-r1`; do not edit its branches.

## Read first, in order

1. `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from GitHub main.
2. `docs/superpowers/plans/pwa-launch/RESUME.md` (current state of every task).
3. `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` in full (every decision with
   Aedwon's exact words).
4. `docs/superpowers/plans/2026-10-19-pwa-launch.md` and `pwa-launch/C1-C10-ruling.md`.

## In flight when this was written (check each before anything else)

| Work | Branch and worktree | How to check |
|---|---|---|
| Client content from server (C7) and Hosting config (B4), Sonnet | `web/pwa-staging-r1`, `../Pantas-wt-pwa-staging-r1` | `git -C ../Pantas-wt-pwa-staging-r1 log --oneline -3` and `status`. If a new local commit exists, review it, rerun `flutter analyze`, full `flutter test` and `flutter build web --release -t lib/main_staging.dart`, then push. If work is uncommitted and no builder is running, finish it with a new Sonnet builder. |
| Mock paper and roadmap on server (C8b, C10), Sonnet | `web/roadmap-server-r1`, `../Pantas-wt-roadmap-server-r1` | Same check. Functions suites: `cd functions && PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test`, plus `npx tsc --noEmit`. Push after review. |
| Codex lead W4 lanes (stopped October 19 at about 18:07 on a ChatGPT usage limit, reset 9:12 PM; it had taken the STATUS.md lock at 18:06 and added the PWA section at b338a3dc; the lock goes stale after 2 hours) | its own branches; log `/private/tmp/claude-501/-Users-aedwon-Documents-Projects-Pantas/f28eb86a-0152-427b-bfe9-3577dc7a8d40/scratchpad/codex-lead-run.log` | `pgrep -fl "codex exec resume"`; read `docs/superpowers/plans/new-design/STATUS.md` on main. Do not resume it again unless Aedwon asks (each resume reloads about 3 million tokens). |
| Level 4 audit | `docs/content-coverage-audit-r1` | Aedwon pastes prompts; paste server `level4/paste/paste_server.py`; state `~/.pantas-audit/level4-paste`. Keep the `status.md` STATE line starting with BLOCKED (the old autorun watcher resumes Codex on RUNNING). |

A cloud session cannot see local worktrees, local commits, the Mac's `~/.pantas-audit` state or
the Codex log. Run on this Mac if any of the above is unpushed.

## Next actions after the in-flight work lands

1. Merge `web/roadmap-server-r1` into `web/pwa-staging-r1`; rerun all suites.
2. Ask Aedwon before any deploy. Then deploy functions and Hosting to `pantas-staging`, upload
   content with `tools/upload_content` (dry run first), and give Aedwon the staging link for a
   phone check.
3. Take the Google sign-in web button change to Aedwon with the visual companion (it is a
   visible change; nothing ships without his approval).
4. When Aedwon has PayMongo test keys: store them as Functions secrets on `pantas-staging` (never
   in chat or files), register the webhook, run C5 test-mode purchases.
5. C3 web purchase gateway and Pro page wiring go through the Codex lead (W4f Task 6).
6. Level 5 paste prompts (E3) once Aedwon wants them; reuse `level4/paste` with a second list type.
7. Pro insights on the server (C10 signals refactor) needs coordination with W4b; ask the Codex lead.

## Working rules learned this session

- Update `RESUME.md` and the decision log at every checkpoint, and push working branches, so a
  cloud session can resume.
- Record every Aedwon decision with his exact words in the decision log.
- Codex jobs started from here cannot run `git fetch` or commit (sandbox); fetch first and tell
  them not to.
- Fresh worktrees need the gitignored seed files copied from `../Pantas-wt-integration-new-design-r1/assets/seed/`
  and `dart run build_runner build --delete-conflicting-outputs` before Dart tests.
- Commit messages explain why; no AI attribution lines (repository rule).
- Keep chat replies short and plain, per Aedwon's global instructions.
