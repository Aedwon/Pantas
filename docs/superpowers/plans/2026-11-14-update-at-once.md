# Update at safe points

Approved spec: Aedwon's bounded job in this task, November 14, 2026.
Policy: origin/main 9b449c022becf81e2e7ad15d9fcaf42061183879.
Estimate: 25 minutes. Execute inline, independent final review.

1. Test a fake-bridge coordinator before implementation: Home, unsafe routes,
   session completion, writes in flight, version throttle, failures, native.
2. Add conditional JS bridge and native no-op in core/platform/app_update.
3. Add an awaited AppDatabase durability barrier. Track whole transactions and
   local sync enqueue operations, then execute a plain statement to flush browser
   storage. Never wait for network or clear storage.
4. Wire router delegate changes, all router navigator overlays, app resume and
   periodic checks. Home is startup's safe point. Quiz results and lesson endings
   are safe only after writes finish. Recheck safety after asynchronous waits.
   Lesson ending inside the reader signals completion without changing its UI.
5. Format changed Dart files; run requested analysis, design and layering checks,
   coordinator/storage and affected routing/session tests, one Flutter job at a time.
   Review diff independently, fix findings, record evidence and commit locally.

Review focus: route changes during waits; nested navigator dialogs; repeated
version detection; failed apply; late local outbox enqueue. No UI, push, deploy,
Firebase operations, new dependency or storage reset.

Implementation decisions within approved scope:
- Inline sheets/dialogs use portals and stacks rather than PopupRoute. Register
  visibility in PantasSheet, HomeWebOverlay, WebSideDrawer and CenteredDialog
  lifecycle hooks. Their rendering, wording and layout stay unchanged.
- JS activation may await worker readiness. Capture browser input and hold the
  safe route through that await, release on failure. No new visible UI.
- Register the reader ending after its frame rebuild starts the final position
  save, so the durability barrier includes that save.
- The full approved scope is preserved in
  `docs/superpowers/specs/2026-11-14-update-at-once-app.md`.

All five implementation steps completed locally. Independent review findings
were corrected and reviewed again with no remaining findings. Evidence:
`docs/superpowers/verification/2026-11-14-update-at-once-app.md`.
Integration and live deployment proof are outside this assignment.

## Final scale-back ruling, November 14

Supersedes the versioned-build plan. Policy: origin/main
14bc67a994d95d2fa353c7b04715b56da7f2609f. Bounded estimate: 25 minutes.
Restore production worker, hosting, index, bootstrap, Drift URLs, deploy scripts,
CI wiring and their original tests from main. Keep the coordinator, durability
barrier, safe points and successful-reload-only attempt accounting.
Write failing Node tests against main's PWA helper before adding a small bridge.
Reuse registerWorker's stamped identity; add pantasBuildVersion to version.json
without changing worker behavior or layout. Normalize that field out of the
build hash so repeated stamping remains stable. Check with no-store plus
registration.update, background visibility/five-minute checks, no automatic reload.
Dart apply calls the synchronous reload bridge and no-ops when absent.
Verify Node suites, changed Dart format, analyze lib test, app_update tests,
design lint, layering, repository checks and exact restored-file equality.
Local commit only; no push, deployment, Firebase access or UI change.
