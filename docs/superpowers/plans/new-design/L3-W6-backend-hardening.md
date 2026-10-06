# L3 W6: backend hardening (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 20749d30.
Level 2 plan: `L2-W6-backend-hardening.md` (level 2 abuse gate passed at review 7). Base:
integration branch after W0 integrates. Executor: one worker, own worktree (strategy B7 as amended
Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; the Opus lead reviews and accepts every
rules and data change). Runs in parallel with W1 and W3; Task 1 lands first, because W3 and W4g
build on it.

Facts (Oct 6): `functions/package.json` has only `engines: node 20` and `test: node --test
test/*.test.mjs`; `firebase.json` deploys the `functions` folder with `runtime: nodejs20`;
`functions/src/index.ts` exports twelve functions; sources import `firebase-admin/*` and
`firebase-functions/*` with no Admin initialization; `functions/test/` holds `.test.mjs` files (source-text checks),
one `.ts` behavior test, one `.rules.mjs` file and `sync-generation.policy.mjs` (which imports
`./.compiled/`, never built today); the Cloud Functions API is off in all three projects (nothing
has been deployed).

Every task: failing test first, confirm the failure reason, smallest change, task checks, commit
with a why message. No deploy in any task; Task 7 lists the deploy steps for Aedwon's approval.

## Task 1. Deployable package and full test runner (AC-B1)

Traceability: X-13.
1. `functions/package.json`: dependencies `firebase-admin` and `firebase-functions` (current
   majors that support Node 22; record versions), dev dependencies `typescript`, `firebase-tools`
   (record the version), the emulator test helpers already used by the rules tests; scripts
   `build` (`tsc`), `test` (`npm run build && node --test test/*.test.mjs test/*.behavior.test.mjs
   && firebase emulators:exec --only auth,firestore,storage --project demo-pantas-test "node --test
   test/*.rules.mjs test/*.emulator.test.mjs"`). Behavior tests import the built `lib/` modules, not
   `src/` (L3X-1): convert `revenuecat-webhook.behavior.test.ts` to
   `revenuecat-webhook.behavior.test.mjs` importing `../lib/revenuecatPolicy.js`, and rename
   `sync-generation.policy.mjs` to `sync-generation.behavior.test.mjs` importing
   `../lib/syncGenerationPolicy.js`. Prerequisite for the check: Java (the emulators need it); `main:
   lib/index.js`; `engines: node 22`. Commit `package-lock.json`.
2. `firebase.json`: functions `runtime: nodejs22`; add a `predeploy` that runs `npm --prefix
   functions run build`.
3. New `functions/src/_admin.ts`: `initializeApp()` once; `index.ts` imports it first; also
   `requireAdmin(request)` (an `admin == true` custom claim, App Check, an audit entry; throws
   `permission-denied` otherwise).
4. The build includes `functions/src/examCatalog.json` (W0), with a test that the built `lib/`
   contains it; W3 Task 4 adds `products.json` the same way (L3X-14).
5. `.gitignore`: `functions/lib/`, `functions/node_modules/`.
Test first: a deliberately failing assertion in each test type fails `npm test`, then is removed;
a non-admin call to a stub admin callable is denied.
Checks: `npm ci && npm run build && npm test` in `functions/` exit 0 (Node 22 and Java installed;
emulators start inside `npm test`).

## Task 2. Strict user record create rule (AC-B2)

Traceability: X-15.
List every field the app and `recordSignInEvent` write when creating `users/{uid}` (search `lib/`
and `functions/src/`), then limit `allow create` to exactly those keys with `createdAt ==
request.time`. Test first (rules): a create with an extra `publicId` or `tier` is denied; the real
creation payloads are allowed.
Checks: `npm test` in `functions/` green.

## Task 3. Per-account limits (AC-B3)

Traceability: X-12.
New `functions/src/_limits.ts` with `allowAtMost(uid, key, max, windowMs)` (a transaction on
`users/{uid}/limits/{key}`). Apply: `recordSignInEvent` writes its audit entry at most once per hour
(the rest of the function always runs); `activateSyncGeneration` caps staging generations per
account at the number the sync design allows (read it from
`docs/superpowers/specs/2026-05-16-user-data-sync-coordinator-design.md`; if it states none, stop
and ask the lead). `firestore.rules`: sync rows accept only their schema fields (list them from
`lib/core/sync/`); a comment in the rules says a synced field change updates these rules in the same
change. Cleanup queries paginate (500 per page).
Tests: at and over each limit; an extra field on a sync row is denied; the real sync payloads pass.
Checks: `npm test` in `functions/` green; `flutter test test/core/sync` green.

## Task 3b. Early integration of Tasks 1 to 3 (L3X-3)

After Tasks 1 to 3: GPT-6 Astra audit and the Opus lead's review of that slice; the lead integrates
it into the integration branch so W3 and W4g can build on it. Deploys stay in Task 7. Checks: the
slice's checks green on the integration branch.

## Task 4. Disable unfinished endpoints (AC-B4)

Traceability: X-14, X-17.
`exportData` throws `failed-precondition` with the approved text "Data export isn't available in
the app yet. Email our Data Protection Officer for a copy." Delete `getProContent.ts`, its export in
`index.ts` and `test/pro-content.test.mjs`.
Tests: `exportData` returns the error; `index.ts` no longer exports `getProContent`.
Checks: `npm test` in `functions/` green; `flutter test test/tool/settings_release_guard_test.dart`
green.

## Task 5. Cleanup jobs (AC-B5)

Traceability: X-14.
- `cleanupOrphanAnons`: delete anonymous Auth users whose last sign-in is more than 30 days ago and
  that have no `users/{uid}` data and no Wrapped shares (per the auth spec); never an active one.
- `purgeOldAuditLogs`: delete Firestore audit entries older than 730 days (auth spec D8).
- `purgeOldExports`: remove the function and its export (export stays disabled).
- New `cleanupWrappedOrphans`: delete files under `wrapped/{uid}/` (the `upload/` prefix included)
  with no share record after 24 hours.
Each runs in pages and logs counts. Tests on the emulators: an active anonymous user is kept; an
orphan is deleted; a 729-day audit entry is kept and a 731-day one deleted; an orphan file is
deleted and a shared file kept.
Checks: `npm test` in `functions/` green.

## Task 6. Live console rules snapshot (before any deploy)

The lead, not the worker, with Aedwon's approval to read: export the live Firestore and Storage
rules of pantas-staging and pantas-prod (`firebase firestore:rules` equivalents or the console
copy Aedwon provides), save them under `evidence/W6-live-rules/`, and diff them with the
repository's. Any difference goes to Aedwon before Task 7.
Checks: the diff is recorded in `evidence/W6.md`.

## Task 7. Deploy steps (each with Aedwon's approval)

Aedwon first, from `level4-setup-steps.md`: enable the Cloud Functions API and confirm the Blaze
plan on pantas-staging, then pantas-prod, and set budget alerts (setup steps Part 4d). Then, after
the review: deploy W6's functions and rules to
pantas-staging; smoke-check each function; then pantas-prod. W3 and W4g deploy their own changes
the same way after their reviews (strategy B7 deploy policy).
Checks: each deploy's output and the deployed revision recorded in `evidence/W6.md`.

## Task 8. Full checks, audit, review, integration

All required checks plus `npm ci && npm run build && npm test` in `functions/`; evidence in
`evidence/W6.md`; GPT-6 Astra audit; the Opus lead's independent review and acceptance; lead
integrates.
