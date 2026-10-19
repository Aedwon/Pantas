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
| B2, B3 web platform and seams | checkpoint: web build compiles; every phone-only part split; encrypted browser study database (ChaCha20 shim, Node probes only, browser untested); Firebase web config filled. Content install on web stopped by design (C7 replaces it). Full suite 3,971/3,971 pass (lead run) | branch `web/pwa-foundation-r1` at edfd988b (pushed) |
| Firebase web apps | created and configured in the options files | `web/pwa-foundation-r1` |
| C1 and C10 ruling | done | `pwa-launch/C1-C10-ruling.md` |
| C2, C4, C6 payment functions | built and lead-reviewed, with proportional partial refunds; plain 110/110, emulator 142/142 (Java 21: `PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH`), tsc clean. Not run against live PayMongo; some refund details UNCONFIRMED (`functions/PAYMONGO.md`) | branch `web/paymongo-r1` at caf2142e (pushed) |
| C10 roadmap server spike | done: works; Node output matches Dart byte for byte on 10 scenarios; 33 KB gzip; about 1 ms per call. Not run on Node 20 (only Node 26 local) | branch `web/roadmap-server-spike-r1` at 75690df3 (pushed), `spike/roadmap_js/README.md` |
| C7, C8, C9 server parts | built and lead-verified: `getContent`, content uploader (dry run 158 lessons, 157 sets), `startMock`/`submitMock`, `ingestSession`, rules; plain 116/116, emulator 157/157. Open: abandoned-mock rule (Aedwon), Free answer visibility after a mock not enforced yet, one unexplained flaky passes test, `ratio-and-proportion.yaml` fails YAML parse | branch `web/server-pro-r1` at e7c27574 (pushed) |
| Staging branch (C7 client, B4 config) | in progress (Sonnet 5.5): app loads lessons from `getContent` with stale-while-revalidate cache; hosting target; no deploy | branch `web/pwa-staging-r1` (merge of pwa-foundation and server-pro, pushed at 737d471a) |
| C8b mock paper, C10 roadmap on server | in progress (Sonnet 5.5): compiled Dart sampler and roadmap from lib paths, no lib edits | branch `web/roadmap-server-r1` from server-pro (not pushed yet) |
| E1 CSE scope | done: 71 lessons | `evidence/E1-cse-scope.*` |
| E1b copy-prompt page | done | `docs/content-coverage-audit-r1` at 439603ca, `level4/paste/` |
| E2 Level 4, E3 Level 5 | Level 4 running: Aedwon pasting (prompt allows web search for B01 since 622a7e35); Level 5 prompts not built | audit branch |
| Lane A (W4) | Codex lead accepted the handoff (plan-only reply, Oct 19); continued by Claude on Aedwon's request (Oct 19, headless, full access as in its own sessions; log on this Mac only). Lanes: W4c audit then W4b; W4e then W4d | Codex session 01a1410a |
| PayMongo account | Aedwon creating it | none |

Orchestrator handoff (start here if you are the new Claude lead): `pwa-launch/handoff-orchestrator.md`.

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
