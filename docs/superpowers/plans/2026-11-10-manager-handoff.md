# Manager handoff (Nov 10, 2026)

The Operations Manager thread in T3 Code coordinated the sessions below and did no build work itself.
A new manager reads `AGENTS.md`, `WORKFLOW.md` and this file, then each lane's latest launch-log entry
(`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` on main).

## Queue (Aedwon approved this order on Nov 9)

1. Redesign release (`web/design-system-4`). Staging passed Aedwon's check except three fixes.
   Waiting on his picks on the "Staging Check Fixes" board: https://claude.ai/artifact/Xt3J8TYTGtMrtz9zwfEcej
   (recommended A, A, A: desktop Account buttons, "N of Y" opens the navigator with a faint arrow,
   phone Home on one line with five days). Then build, staging, his check of the three, then his
   explicit "ship it". Ship during the beta. Ship runbook: deploy functions and web together
   (guardian document versions changed). Pro group stays first in Settings (his call).
2. Guardrails (`ds4/guardrails`). Lint, gaps, golden harness done. Layer 1 (barrel import sweep)
   waits for the ship. Locking golden images waits for DS4 completion.
3. Privacy batch (`ds4/privacy-batch`, mirror `web/privacy-batch`). Server, app part 1, Codex audit
   fixes and publish texts done. Waiting on his picks: https://claude.ai/artifact/VhNW1aCxSs5sF48XMQZLAQ
   (recommended A, A). Needs the real guardian mail key on prod before shipping. Ships after the redesign.
4. DS4 completion (`ds4/completion-r1`, mirror `web/ds4-completion-r1`). Groups 1 to 3 built; fixing
   CI tests broken by intended behavior changes. Groups 4 to 6 (reader, Chart/DataTable incl. the
   shared table row-heading bug, quiz) remain. Report form builds on `ds4/guardrails`.
5. Custom exams (`ds4/custom-exam-r2`, CI mirror `web/custom-exam-r2`). Built, reviewed, CI green.
   Merge into the redesign after the ship. Row stays hidden on web.
6. CET content (`content/cet-finish-r1`). Paused, last in queue. Resume steps at the end of
   `docs/content/rewrite/cet/final-run-report.md` on that branch (Astra on 61 lessons, then figures).

Alongside: founder app spec and 20 boards wait for his approval:
spec on branch `docs/founder-app-spec`, boards https://claude.ai/artifact/8TwdfQP8rcvMrD6uopYC3k.
Build Owner Inputs tab first after approval (Balanced; Posts tab is a later spec).

## Standing items

- Beta monitor thread runs read-only every 6 hours (T3 scheduled task bound to the manager thread).
  Tester data stays in `~/Documents/Projects/Pantas-private/beta/`, never in the repo.
- SSOT keeper updates the Pantas Master SSOT Google Doc daily (scheduled task).
- PayMongo: test-mode run passed for cards; QR Ph refunds are manual (bank transfer plus the
  runbook in `docs/OPERATIONS.md`). Do not go live before the BIR COR, DTI name and PayMongo
  sole-proprietor upgrade. Two support messages for Aedwon are drafted in the PayMongo report on
  `ops/paymongo-test-r1`.
- Rules recorded on Nov 9: every manual email goes to Aedwon first; agents never ask him for legal
  text (drafted by an agent, critiqued by Codex GPT 6.1 Sol High); in-app copy under an approved
  layout is a lead call; boards need a fresh DS4 review and a render check before he sees them.
- Ideas archived in `docs/future/README.md` (flashcards, codebase gardening).

## Lessons for the next manager

- Threads often end a turn while CI runs; check them and nudge. Relay every finished result to
  Aedwon promptly (this manager missed several). The browser-journeys CI job hides failures;
  read its output lines.
- Keep local load to one build per session; Aedwon's laptop overheats with many sessions.
