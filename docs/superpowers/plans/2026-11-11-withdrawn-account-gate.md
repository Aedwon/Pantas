# Withdrawn account gate implementation plan

Use executing-plans and test-driven-development. Policy: main
38f74462da82729e1adc85663348b52db8de8f3a. Spec:
`docs/superpowers/specs/2026-11-11-withdrawn-account-gate.md`.

Only this worktree and branch. No Firebase project access or push. Existing
privacy merge is present. This is one bounded worker assignment; no concurrent
writers or collision with the lead's integration. Estimate: 90–120 minutes local.

1. Rules: add `functions/test/withdrawn-account.rules.mjs`, prove normal access
   works and withdrawn/deletion-pending access wrongly succeeds. Amend
   `firestore.rules` and `storage.rules` through common ownership checks, including
   passes, grants and wrapped shares. Two distinct server-owned document paths;
   missing consent remains allowed. Exercise Storage with actual cross-service
   rules, reads/writes/deletes, sync batches, anonymous and named ownership.
2. Callables: add `functions/test/withdrawn-account.emulator.mjs`, exercising all
   deployed own-account callable handlers against real emulator records, plus
   successful ingest and Admin cleanup. Prove missing refusal first. Create
   `functions/src/_accountAccess.ts` with shared `assertAccountActive` and a guarded
   onCall wrapper, use it in every own-account callable source in functions/src.
   Keep token-authorized guardian calls independent of the student's gate. Give
   refusals `{reason: 'account-closed'}` and permission-denied. Keep internal Admin
   deletion and scheduled jobs unguarded. Preserve sendLink/markAdult transaction
   checks and add the structured reason there too.
3. App: test JSON withdrawal and gate/controller reaction before implementation.
   Files: `lib/core/platform/account_access.dart` and existing callable gateway
   files under core/auth, core/sync/firestore, core/telemetry, core/content/remote,
   features/home/data, features/mock_exam/data, features/paywall/data,
   features/guardian/data; guardian domain/application/presentation files;
   `lib/app/app.dart`, `lib/app/router.dart`, `lib/app/routes/guardian_routes.dart`.
   Carry structured refusals through a shared callable wrapper, bound to the
   request uid. A shared closure signal holds the existing end state before
   sign-out, ignores stale responses for another identity, and cannot fall back
   to cached confirmation. Watch guardian status on startup and active refresh.
   Tests under `test/features/guardian`, `test/core/platform` and `test/app`.
4. Verify npm test, format, analyze lib test, relevant Flutter folders one job at
   a time; layering, attribution and regression checks. Preserve red/green logs
   and counts in `docs/superpowers/verification/2026-11-11-withdrawn-account-gate.md`.
   Review diff; commit plain messages. Lead performs separate review, hosted CI,
   integration and publication. Update launch log and the E-036 velocity row.

Review focus: absent consent/status; task surviving consent deletion; stale Pro
and anonymous tokens; guardian manage retry; late response after account switch;
closed state despite failed sign-out; offline cache and already-cleared minors.
Each is covered by the rules, callable or Dart tests in its owning step.
