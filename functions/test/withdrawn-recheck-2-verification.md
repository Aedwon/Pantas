# Withdrawal second-round server corrections

Policy: main c7c6b3a790953f4348fd2bbf011ff95637cc6549.
Scope: the Nov 12 lead rulings for Must 1 and Must 3, on web/withdrawn-gate-r1.
Estimate: 20 minutes. No push, deployment, Firebase project access, or lib/ edits.
The user's server-only restriction keeps this record, plan, and correction log here.

## Approved outcome and plan

1. Write regressions for permanent UID closure and custom-token resurrection:
   mint before withdrawal, delete, redeem, run scheduled cleanup beyond two hours,
   refresh, and require Firestore, Storage, and callable refusal.
2. Observe failures before replacing completion data with an empty document:
   the document ID is the sole UID tombstone. Remove expiry and cleanup. Preserve
   compatibility with previous expiring markers by converting them to permanent ones.
3. Write and observe failing Wrapped create/update tests with download-token
   metadata. Deny that metadata in Storage rules. Inspect app/server consumers.
4. Update superseded assertions, run npm test and standalone rules tests locally
   with demo-pantas-test, review the diff independently, then commit locally.

Assigned files: functions/src/deleteUserData.ts, functions/src/purgeInactiveAccounts.ts,
firestore.rules, storage.rules, functions/test/withdrawn-account.emulator.mjs,
functions/test/inactivity.emulator.mjs, functions/test/guardian-manage.emulator.mjs,
functions/test/wrapped-access.emulator.mjs, functions/test/wrapped-access.rules.mjs,
functions/test/wrapped-download-token.probe.mjs,
and this verification record.

## Correction log

Exact lead ruling: "make the closure marker for a withdrawn or deleted uid permanent"
and "Wrapped card uploads may not carry download-token metadata".
The prior ID-token-only regression missed custom-token sessions that recreate the UID.
The renderer regression missed direct bearer downloads. New executable regressions
must fail on both previous behaviors before production edits.

Accepted limit: Wrapped download tokens issued before this change remain usable until
object deletion, as with feedback attachments. This change cannot recall bearer URLs.

## Ruling: Must 3 blocked by the actual Storage request boundary

The proposed Storage guard was tried only after create/update regressions failed.
It did not fix either regression. Both SDK operations still succeeded with
`firebaseStorageDownloadTokens` set, despite the metadata-key prohibition.
Installed firebase-tools 15.32.1 `lib/emulator/storage/metadata.js` extracts that
field into downloadTokens and deletes it from customMetadata before
asRulesResource() constructs the rule input, on both create and update.
`lib/emulator/storage/apis/firebase.js` additionally supplies a default token to
ordinary Firebase uploads. Thus rejecting visible custom metadata cannot enforce
this requirement in the installed emulator. No Firebase project was consulted.
Production enforcement has NOT been established. The ineffective guard was removed.

The executable failing acceptance diagnostic is preserved separately as
`test/wrapped-download-token.probe.mjs`, excluded from the ordinary test glob
because the requirement remains blocked, not because it passed. Explicit command:

```
npx firebase emulators:exec --only auth,firestore,storage --project demo-pantas-test "node --test test/wrapped-download-token.probe.mjs"
```

A wider upload change needs a lead ruling: prevent direct SDK uploads and use an
owner-checked server upload that writes token-free objects, with corresponding
client changes. That conflicts with this assignment's fixed server-only scope.
No endpoint, trigger, dependency, client change, or project setting was added.

Consumer inspection: FirebaseWrappedShareHost.publish uses putData with only
contentType and never calls getDownloadURL. Wrapped sharing uses the renderer URL;
renderWrappedPage checks assertAccountActive before its Admin object download.
No Wrapped download URL consumer needs switching. Other download URL references
belong to account exports or feedback attachments, outside this requirement.

## Failing-first evidence

- /tmp/withdrawn-r2-red-confirmed.log: 8 tests, 0 pass, 8 fail. The UID-only marker
  retained expiry fields; refreshed resurrected UID got HTTP 200 instead of 403
  for Firestore and Storage; callable reached "Bad session id" validation rather
  than account-closed; legacy cleanup removed the marker; both token-metadata
  operations succeeded. Includes parent failure for the three resurrection checks.
- /tmp/withdrawn-r2-green-fixed.log: 159 tests, 157 pass, 2 fail. All closure and
  resurrection regressions pass. The only failures are the blocked token upload
  and metadata update tests, even WITH the proposed guard.
- The first custom-token test used an unavailable localId response field. That
  harness error was corrected to verify the returned ID token, and all meaningful
  failing evidence above was observed before production edits.
- Independent read-only review confirmed the metadata stripping and automatic
  token generation, and found no guard within the unchanged direct SDK contract.

## Independent review correction

The reviewer found a second tombstone-removal path: inactivity cancellation
could use the queried task's stale reason after concurrent completion wrote {}.
Added "inactivity cancellation cannot remove a tombstone completed after its
retry query". Its first real-emulator run failed with undefined instead of {}:
/tmp/withdrawn-r2-full.log, unit 585/585, combined 788/789. This run overlapped
test-file updates and is historical failure evidence only, not final acceptance.
Changed cancellation to compare the fresh pending reason and destructive state,
and delete only in the same Firestore transaction. No stale reason fallback.

## Final verification

- Final `npm test`: exit 0. Build passed; unit tests 585/585; combined emulator
  and rules tests 789/789; zero failures, cancellations, or skips.
  Log: /tmp/withdrawn-r2-final.log. This final run used the complete fixed source
  and unchanged ordinary test inputs throughout.
- `dart run tool/checks/run_checks.dart`: exit 0, all nine checks passed with the
  existing printed accepted exceptions. Log: /tmp/withdrawn-r2-repo-checks.log.
- `dart run tool/check_no_ai_attribution.dart`: exit 0,
  `check_no_ai_attribution: OK`. Log: /tmp/withdrawn-r2-attribution.log.
- `git diff --check`: exit 0.
- Final source changes are limited to the permanent closure fix, transactional
  inactivity cancellation, updated expectations, and rule comments. Must 3 has
  NO claimed implementation or passing acceptance result.
- Standalone rules command: exit 0, 131/131 passed, zero failures or skips.
  Log: /tmp/withdrawn-r2-rules-final.log. These tests also belong to the combined
  count above, and do not include the explicitly blocked diagnostic.

Completion status: Must 1 implemented and verified locally, including the review
race correction. Must 3 blocked with executable failing evidence and no effective
guard claimed. No push, integration, deployment, project change, or lib/ edit.
The wider upload design and any production verification remain with the lead.
- Separate blocked diagnostic: exit 1, 2 tests, 0 pass, 2 fail, both with
  "Expected request to fail, but it succeeded." This is not included in the
  passing npm/rules counts. Log: /tmp/withdrawn-r2-token-blocked.log.
- Implementation timer `withdrawn-recheck-2`: wall and active 7 min 40 s,
  from `python3 tool/velocity/timer.py withdrawn-recheck-2 stop`. Policy retrieval
  and initial investigation preceded this timer; this is not a total-session time.
