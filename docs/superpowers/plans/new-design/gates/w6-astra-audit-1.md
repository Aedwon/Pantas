Reviewed `13e4f830..7c1d339e` on `web/new-design-w6-r1`. Policy revision: `65f29cae548292b8dad95ef7023372c39a357b98`. Read both W6 plans, October 7 rulings, and traceability rows.

The tests pass, but I would not accept this slice yet.

### Blocker

1. [cleanupOrphanAnons.ts:8](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w6-r1/functions/src/cleanupOrphanAnons.ts:8): **Active anonymous accounts can be deleted.** The job checks last sign-in, not recent token refresh activity. The client retains anonymous sessions without signing in again. A daily user with an old login and no cloud records qualifies for deletion. Firebase distinguishes these timestamps in its [metadata documentation](https://firebase.google.com/docs/reference/admin/node/firebase-admin.auth.usermetadata).

   Fix: consider recent refresh activity in both eligibility checks. Test an old login with a recent refresh. The existing “active” fixture tests only a recent login.

### Major

2. [sync_runtime_controller.dart:343](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w6-r1/lib/core/sync/runtime/sync_runtime_controller.dart:343): **The staging cooldown can strand legitimate sync.** A local change during initial upload triggers an immediate replacement generation. The five-minute limit denies it. The controller reports failure but schedules no retry. Manual retry only flushes an engine that has not started.

   Fix: retry bootstrap after the cooldown, canceling on account changes. Test denial followed by recovery without restarting. The changed test proves marker retention, not Task 3’s promised later retry.

3. [cleanupWrappedOrphans.ts:26](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w6-r1/functions/src/cleanupWrappedOrphans.ts:26): **Cleanup can delete a newly published file.** Between listing, checking shares, and deletion, publication can replace the object or create its share. Deletion has no object-generation precondition or publication coordination.

   Fix: condition deletion on the listed object generation and coordinate cleanup with publication. Add replacement and publication race tests.

4. [cleanupSyncData.ts:136](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w6-r1/functions/src/cleanupSyncData.ts:136): **Cleanup can delete an active generation.** Activation can commit after eligibility reads but before recursive deletion. The active pointer then references deleted data.

   This defect predates the slice but affects deployment readiness. Fix: transactionally claim deletion while checking the pointer and status. Activation and row writes must reject claimed generations. Test this interleaving.

5. [cleanupSyncData.ts:70](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w6-r1/functions/src/cleanupSyncData.ts:70): **Cleanup can delete a restored row.** A client can restore a tombstone after the query. The unconditional delete still removes it.

   This also predates the slice. Fix: use snapshot update-time preconditions or transactional rechecks. Test restoration between query and deletion.

### Minor

6. [firestore-sync-rules.rules.mjs:188](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w6-r1/functions/test/firestore-sync-rules.rules.mjs:188) and line 314: **Negative tests can pass for the wrong reason.** Active-generation and extra-field tests omit the required limits write. They remain denied even when the constraints they claim to test break.

   Fix: supply an otherwise-valid coupled batch, then change only the tested field.

7. [cleanupOrphanAnons.ts:22](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w6-r1/functions/src/cleanupOrphanAnons.ts:22) and [cleanupWrappedOrphans.ts:15](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w6-r1/functions/src/cleanupWrappedOrphans.ts:15): **Pagination does not bound invocation work.** Both scan the entire population sequentially. At sufficient volume, repeated timeouts can continually restart before reaching later records.

   Fix: persist continuation with a work budget, or establish and verify an operating bound.

8. [package-lock.json:6181](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w6-r1/functions/package-lock.json:6181): **Runtime dependencies still have audit findings.** Current audit reports 16 dependency findings: 12 high and four moderate. Production-only audit reports two moderate findings through `gaxios` and `uuid`. The high findings are development-only. I did not establish runtime exploitability.

   Fix: resolve compatible dependency updates or record a specific acceptance decision. Avoid blindly applying forced downgrades.

### Clean areas and evidence

- No staging-limit bypass, cross-account access, server-field injection, or client counter tampering found.
- Row allowlists match current mapper fields. Payload and tombstone tests cover all ten collections.
- Admin claim checks, App Check presence, and transactional sign-in limits are sound.
- Disabled export returns the approved error. Removed endpoints are absent.
- Audit retention and 500-record pagination work. Required sync indexes exist.
- Node 22 configuration, predeploy build, catalog copy, and package entry are correct. Node 22 is [supported](https://firebase.google.com/docs/functions/manage-functions).
- Installed versions: Admin `14.5.0`, Functions `7.4.0`, CLI `15.32.1`, TypeScript `7.0.2`.

`npm test` exited 0: 52 plain tests and 49 emulator tests passed. These tests do not establish safety for the races above.

No source edits, Git writes, deploys, or real-project commands. The worktree remains clean. Live configuration, deployment, and Flutter checks were not independently verified.