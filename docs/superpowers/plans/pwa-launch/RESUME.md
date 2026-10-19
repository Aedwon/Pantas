# PWA launch: resume point

Updated at every checkpoint by the Claude lead. A new session (local or cloud) starts here, after
reading `AGENTS.md`, `WORKFLOW.md` and `SUBAGENTS.md` from main.

Controlling records: spec `docs/superpowers/specs/2026-10-19-pwa-launch-design.md`, plan
`docs/superpowers/plans/2026-10-19-pwa-launch.md`, ruling `pwa-launch/C1-C10-ruling.md`, decision log
`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` (read the log in full; it has every
decision and its exact wording).

## State at October 19, 2026 (last checkpoint)

| Task | State | Where |
|---|---|---|
| B1 web inventory | done | `evidence/B1-web-inventory.md` |
| B2, B3 web platform and seams | in progress (Codex Sol, local only); encrypted web database blocked, second pass running | branch `web/pwa-foundation-r1` (not pushed yet) |
| Firebase web apps | created in all 3 projects; config not yet in the options files | decision log, "Firebase web apps created" |
| C1 and C10 ruling | done | `pwa-launch/C1-C10-ruling.md` |
| C2, C4, C6 payment functions | in progress (Sonnet 5.5) | branch `web/paymongo-r1` (not pushed yet) |
| C10 roadmap server spike | in progress (Sonnet 5.5) | branch `web/roadmap-server-spike-r1` (not pushed yet) |
| E1 CSE scope | done: 71 lessons | `evidence/E1-cse-scope.*` |
| E1b copy-prompt page | done | `docs/content-coverage-audit-r1` at 439603ca, `level4/paste/` |
| E2 Level 4, E3 Level 5 | Level 4 ready for Aedwon's pastes; Level 5 prompts not built | audit branch |
| Lane A (W4) | Codex lead; handoff ready to paste | `pwa-launch/handoff-codex-lead.md` |
| PayMongo account | Aedwon creating it | none |

## What a cloud session can and cannot do

- It sees only pushed branches. The lead pushes each working branch at every checkpoint, marked
  "checkpoint" in the commit message when unfinished.
- It does not see this Mac's local state: generated seed files (`assets/seed/content.*`, gitignored;
  rebuild with `dart run tools/build_content_package/build_content_package.dart`, see its usage line),
  the Level 4 paste run state in `~/.pantas-audit/level4-paste`, or the Codex CLI.
- Flutter may be missing in a cloud environment; server work under `functions/` needs only Node.
- Never push the W4c source after `7223e931` (see the restart log).

## Next actions

1. Review the B2/B3 second pass; decide the encrypted web database path with Aedwon if blocked.
2. Put the Firebase web configs into `lib/firebase_options_*.dart` on `web/pwa-foundation-r1`.
3. Review the payment functions and the roadmap spike; push both branches.
4. Take the Google sign-in web button change to Aedwon with the visual companion.
