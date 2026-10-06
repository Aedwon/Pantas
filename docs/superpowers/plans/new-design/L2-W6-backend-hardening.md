# L2 W6: backend hardening

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 38ef4a64.
Parent: strategy B2 (W6 added October 6 after abuse review 1), B4. Depends on: W0.
Source: `gates/abuse-review-1.md` (findings CX-12 to CX-17, lead's verdict).
Traceability rows: every row with workstream `W6` (X-12 to X-15, X-17).

## 1. Purpose and scope

Make the Firebase backend deployable, testable and hard to abuse, so the payment (W3) and sharing
(W4g) fixes can ship and nothing unfinished is exposed.

In scope:
1. **Deployable Functions package** (CX-13). Today `functions/package.json` lists no dependencies,
   no build script and no entry point; `firebase.json` deploys the `functions` source folder;
   `index.ts` exports twelve functions; no source initializes the Admin SDK. W6 adds the
   dependencies the sources import (`firebase-admin`, `firebase-functions`), a TypeScript build to
   `lib/` with `main` pointing at it, Admin initialization once, and an `npm test` that runs every
   test type (`.test.mjs`, the `.ts` behavior tests, and the rules tests on the emulator). Before
   writing it, the lead asks Aedwon how the live backend was last deployed (the deployed revision
   may come from a setup not in the repository); W6 reconciles with it and does not deploy.
2. **Strict user record create rule** (CX-15): `users/{uid}` create allows only `createdAt` (and
   the fields the app writes at creation, listed from the code), so no client can plant
   server-owned fields such as a public ID or tier.
3. **Basic per-account limits** (CX-12): `recordSignInEvent` writes at most one audit entry per
   account per hour; sync staging generations are capped per account (level 3 sets the number
   from the sync design) and sync rows reject fields outside their schema; cleanup queries
   paginate. Budget alerts on the Firebase projects are an Aedwon step (instructions in level 3).
4. **Unfinished endpoints disabled** (CX-14, CX-17): `exportData` returns a clear "not available,
   contact the Data Protection Officer" error instead of a success-shaped placeholder (Settings
   already hides export); `getProContent` (no caller in `lib/`) is removed from `index.ts` and
   deleted with its test.
5. **Working cleanup jobs** (CX-14): `cleanupOrphanAnons` (anonymous accounts with no data after
   30 days), `purgeOldAuditLogs` (audit entries older than the retention the privacy policy states,
   or 1 year if it states none, recorded for Aedwon), `purgeOldExports` (removed if export stays
   disabled), and the Wrapped orphan-file cleanup W4g needs (files with no share record after 24
   hours). Each paginates and logs counts.

Out of scope: webhook changes (W3 owns the webhook, including freshness and atomic handling,
CX-16); share creation and storage rules (W4g); a full data exporter (later, Aedwon's decision).

## 2. Inputs

`gates/abuse-review-1.md`; `functions/`, `firestore.rules`, `storage.rules`, `firebase.json` on
the integration branch; `specs/2026-08-03-offline-and-network-posture-design.md` (no change to
offline rules here); the privacy policy text (`lib/features/legal/domain/legal_document.dart`).

## 3. Contracts owned

| Contract | Interface |
|---|---|
| Functions package | `functions/package.json` with dependencies, `build` (tsc to `lib/`), `main: lib/index.js`, Node 20, and `test` running every test type; Admin SDK initialized in one module imported by `index.ts`. Every later functions change (W3, W4g) uses this contract and adds its tests to the same runner. |
| Server write limits | A small helper `functions/src/_limits.ts` (`allowOncePer(uid, key, window)` in a transaction) that W3 and W4g reuse for their own limits. |
| User record create rule | `users/{uid}` create: owner only, keys limited to the listed creation fields. |

## 4. Behavior

- Nothing the student sees changes, except that the hidden data export now returns an error if
  reached.
- No deploy happens in W6. Deploys of functions and rules wait for Aedwon's approval, after W3 and
  W4g land their changes, as one reviewed release of the backend.

## 5. Motion

None.

## 6. Acceptance

- `npm ci && npm run build && npm test` in `functions/` exit 0, and the rules tests run on the
  emulator inside `npm test`.
- Tests per abuse case in §10.
- `firebase deploy --only functions,firestore:rules,storage --project pantas-staging --dry-run` (or
  the closest available check) succeeds; the real deploy is a separate approval.
- Independent Opus review (strategy B7: backend and security).
- Full required checks (Flutter checks unchanged).

## 7. Risks and stop conditions

- The live backend was deployed from code or settings not in the repository: stop and report the
  difference before changing the package.
- A limit would block a normal student's use (for example sync caps below real usage): stop; the
  lead sets the number from the sync design.
- Any deploy, budget setting or IAM change needs Aedwon's approval.

## 8. Files and directories

`functions/package.json`, `functions/package-lock.json`, `functions/tsconfig.json`,
`functions/src/index.ts`, new `functions/src/_admin.ts` and `_limits.ts`,
`functions/src/recordSignInEvent.ts`, `activateSyncGeneration.ts`, `cleanupSyncData.ts`,
`cleanupOrphanAnons.ts`, `purgeOldAuditLogs.ts`, `purgeOldExports.ts`, `exportData.ts`,
`getProContent.ts` (deleted), `functions/test/`, `firestore.rules` (user record create rule and
sync row schemas only), `.gitignore` (`functions/lib/`, `functions/node_modules/`).

## 9. Order and parallelism

After W0, in parallel with W1 and W3. Task 1 (the package) lands first; W3 and W4g add functions
tests to its runner and deploy only after it. `firestore.rules`: W6 before W3, then W4g.
`recordSignInEvent.ts`: W6 (limit) before W3 Task 10 (public ID call). Executor: a non-Claude
worker is allowed (Codex, per Aedwon's Oct 6 cost goal) for Tasks other than the review; the
independent review is Opus.

## 10. Abuse cases

| ID | Finding | Abuse case | Required behavior |
|---|---|---|---|
| AC-B1 | CX-13 | Security fixes pass tests but never reach the deployed backend | The package builds and its tests run the compiled handlers; the deploy check passes; the deployed revision is recorded at W5. |
| AC-B2 | CX-15 | A new account plants server-owned fields in its user record | Create rule allows only the listed fields; test with an extra `publicId` and `tier` field fails. |
| AC-B3 | CX-12 | One account floods audit logs or sync staging, raising Pantas's bill | Limits in §1 item 3; tests at and over each limit. |
| AC-B4 | CX-14, CX-17 | A direct caller hits unfinished endpoints | `exportData` returns an error; `getProContent` no longer exists; tests. |
| AC-B5 | CX-14 | Anonymous accounts, audit logs and orphan share files pile up | Cleanup jobs delete what §1 item 5 says, in pages, with logged counts; tests on the emulator. |
