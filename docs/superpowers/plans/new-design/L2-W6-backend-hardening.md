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
   `lib/` with `main` pointing at it, Node 22 in `engines` and `firebase.json` (Node 20 is
   decommissioned by Google on October 30, 2026; gate L2A-2), Admin initialization once, the W0
   exam catalog JSON included in the build, and an `npm test` that runs every
   test type (with the Firestore and Storage emulators) (`.test.mjs`, the `.ts` behavior tests, and the rules tests on the emulator). Before
   writing it, the lead asks Aedwon how the live backend was last deployed (the deployed revision
   may come from a setup not in the repository); W6 reconciles with it and does not deploy.
2. **Strict user record create rule** (CX-15): `users/{uid}` create allows only `createdAt` (and
   the fields the app writes at creation, listed from the code), so no client can plant
   server-owned fields such as a public ID or tier.
3. **Basic per-account limits** (CX-12): `recordSignInEvent` writes the sign-in audit entry at
   most once per account per hour (the rest of the function, including W3's `ensurePublicId` call,
   always runs; gate L2A-22); sync staging generations are capped per account (level 3 sets the number
   from the sync design) and sync rows reject fields outside their schema (whoever changes a synced field updates these
   rules in the same change; gate L2A-29); cleanup queries
   paginate. Budget alerts on the Firebase projects are an Aedwon step (instructions in level 3).
4. **Unfinished endpoints disabled** (CX-14, CX-17): `exportData` returns an error instead of a success-shaped placeholder (text approved by Aedwon
   Oct 6: "Data export isn't available in the app yet. Email our Data Protection Officer for a
   copy.") (Settings
   already hides export); `getProContent` (no caller in `lib/`) is removed from `index.ts` and
   deleted with its test.
5. **Working cleanup jobs** (CX-14): `cleanupOrphanAnons` (anonymous accounts whose last sign-in is
   more than 30 days ago and that have no server data, Wrapped shares included, per the auth spec;
   an active anonymous student is never deleted), `purgeOldAuditLogs` (Firestore audit entries older
   than 730 days, per the auth spec D8; gate L2A-18), `purgeOldExports` (removed if export stays
   disabled), and the Wrapped orphan-file cleanup W4g needs (files under `wrapped/{uid}/` with no share
   record after 24 hours, the `upload/` prefix included, in `functions/src/cleanupWrappedOrphans.ts`). Each paginates and logs counts.

Out of scope: webhook changes (W3 owns the webhook, including freshness and atomic handling,
CX-16); share creation and storage rules (W4g); a full data exporter (later, Aedwon's decision).

## 2. Inputs

`gates/abuse-review-1.md`; `functions/`, `firestore.rules`, `storage.rules`, `firebase.json` on
the integration branch; `specs/2026-08-03-offline-and-network-posture-design.md` (no change to
offline rules here); the privacy policy text (`lib/features/legal/domain/legal_document.dart`).

## 3. Contracts owned

| Contract | Interface |
|---|---|
| Functions package | `functions/package.json` with dependencies, `build` (tsc to `lib/`), `main: lib/index.js`, Node 22, and `test` running every test type; Admin SDK initialized in one module imported by `index.ts`. Every later functions change (W3, W4g) uses this contract and adds its tests to the same runner. |
| Server write limits | A small helper `functions/src/_limits.ts` (`allowAtMost(uid, key, max, window)` in a transaction) for W6's own limits; W3 may reuse it; W4g counts its share records itself (gate L2A-13). |
| User record create rule | `users/{uid}` create: owner only, keys limited to the listed creation fields. |

Contracts consumed: W0 exam catalog JSON (`functions/src/examCatalog.json`, included in the build).

## 4. Behavior

- Nothing the student sees changes, except that the hidden data export now returns an error if
  reached.
- Deploy policy for all backend changes (gate L2A-14): each workstream's functions and rules deploy
  after that workstream's review, with Aedwon's approval, once W6 Task 1 has landed. W6 itself
  deploys after its review the same way.
- First deploy (checked October 6): no functions have ever been deployed. The Cloud Functions API
  is off in pantas-prod, pantas-staging and pantas-dev, and Aedwon set up the rest in the Firebase
  console. So the October 30 Node 20 retirement affects nothing live, and W6's package is the first
  deploy. Before it, Aedwon enables the Cloud Functions API and confirms the projects' billing plan
  (Blaze is required for Functions); steps go in `level4-setup-steps.md`. RevenueCat's webhook URL,
  if set, points at a function that does not exist yet; W5 checks it.

## 5. Motion

None.

Aedwon's check: none visual.

## 6. Acceptance

- `npm ci && npm run build && npm test` in `functions/` exit 0, and the rules tests run on the
  emulator inside `npm test`.
- Tests per abuse case in §10.
- A deploy check against pantas-staging is an Aedwon-run step (it uses his project credentials;
  gate L2A-30); the real deploy is a separate approval.
- Independent Opus review (strategy B7: backend and security).
- Full required checks (Flutter checks unchanged).

## 7. Risks and stop conditions

- The live backend was deployed from code or settings not in the repository: stop and report the
  difference before changing the package.
- A limit would block a normal student's use (for example sync caps below real usage): stop; the
  lead sets the number from the sync design.
- Any deploy, budget setting or IAM change needs Aedwon's approval.
- Admin-only callables (W4g `takedownShare`): one server check, an `admin` custom claim that only
  Aedwon sets from the command line, plus App Check and an audit entry; a non-admin call is denied
  (tested) (gate L2A2-6). W6 owns the helper `requireAdmin` in `functions/src/_admin.ts`.

## 8. Files and directories

`functions/package.json`, `functions/package-lock.json`, `functions/tsconfig.json`,
`functions/src/index.ts`, new `functions/src/_admin.ts` and `_limits.ts`,
`functions/src/recordSignInEvent.ts`, `activateSyncGeneration.ts`, `cleanupSyncData.ts`,
`cleanupOrphanAnons.ts`, `purgeOldAuditLogs.ts`, `purgeOldExports.ts`, `exportData.ts`,
`getProContent.ts` (deleted), new `cleanupWrappedOrphans.ts`, `functions/test/`, `firebase.json`
(functions runtime only), `firestore.rules` (user record create rule and
sync row schemas only), `.gitignore` (`functions/lib/`, `functions/node_modules/`).

## 9. Order and parallelism

After W0, in parallel with W1 and W3. Task 1 (the package) lands first; W3 and W4g add functions
tests to its runner and deploy only after it. `firestore.rules`: W6 before W3, then W4g.
`recordSignInEvent.ts`: W6 (limit) before W3 Task 10 (public ID call). Executor: a non-Claude
per strategy B7 as amended October 6 (GPT-6.1 Sol High through Codex builds; GPT-6 Astra
audits; the Opus lead oversees and integrates).

## 10. Abuse cases

| ID | Finding | Abuse case | Required behavior |
|---|---|---|---|
| AC-B1 | CX-13 | Security fixes pass tests but never reach the deployed backend | The package builds and its tests run the compiled handlers; the deploy check passes; the deployed revision is recorded at W5. |
| AC-B2 | CX-15 | A new account plants server-owned fields in its user record | Create rule allows only the listed fields; test with an extra `publicId` and `tier` field fails. |
| AC-B3 | CX-12 | One account floods audit logs or sync staging, raising Pantas's bill | Limits in §1 item 3; tests at and over each limit. |
| AC-B4 | CX-14, CX-17 | A direct caller hits unfinished endpoints | `exportData` returns an error; `getProContent` no longer exists; tests. |
| AC-B5 | CX-14 | Anonymous accounts, audit logs and orphan share files pile up | Cleanup jobs delete what §1 item 5 says, in pages, with logged counts; tests on the emulator. |
