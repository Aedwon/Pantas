# Server withdrawal re-check corrections

Scope: Nov 12 bounded server assignment on `web/withdrawn-gate-r1`.
Policy: main `c7c6b3a790953f4348fd2bbf011ff95637cc6549`.
Starting candidate: `3670ee1f8`. No Flutter edits, push, deployment, or Firebase project access.
All service tests used local `demo-pantas-test` emulators.

## Changes and acceptance

- Must 1: replace the completed `accountDeletions/{uid}` task with exactly
  `closedUntil` and `nextRetryAt`. The document ID is the UID; the marker contains
  no names, addresses, deletion reasons, or other personal data. Retain it for
  two hours from completed Auth deletion, exceeding the one-hour ID-token
  lifetime even for a token minted immediately before deletion. Existing
  Firestore/Storage rules and the shared callable check already deny any document
  at this path, with the same two-document lookup budget. The existing daily
  inactivity cleanup removes expired markers transactionally through its bounded
  retry queue; expiry is a minimum retention, not a promise of immediate removal.
  No TTL configuration or project changes required.
- Must 3: check the Wrapped owner's account through the same shared check before
  either HTML or image delivery. Refuse withdrawn consent, pending deletion, and
  completed closure. Set `Cache-Control: no-store` on every response. Previously
  cached images cannot be recalled; their former five-minute cache lifetime
  must elapse. No deployment or cache invalidation was performed.
- Must 4: check the resolved sign-in target before Google linking or either
  custom token. A closed target different from the caller gets a plain refusal,
  without the signal that would close the caller's active anonymous session.
- Must 2, authorized subset: delete `betaFeedback/{uid}/` Storage objects before
  Auth deletion. Preserve neighboring user prefixes. Previously issued URLs stop
  returning the deleted attachment; URL generation remains unchanged.

## Failing-first evidence

Production changes were made only after these failures were observed:

1. `node --test --test-name-pattern='closed target' test/google-sign-in.test.mjs test/sign-in-code.test.mjs`:
   four tests failed with `Missing expected rejection`, zero passed. Each flow
   tested an active anonymous caller against both withdrawn consent and a
   deletion marker on the resolved target.
2. Focused demo-emulator run of `withdrawn-account.emulator.mjs` and
   `wrapped-access.emulator.mjs`: 151 tests, 139 passed, 12 failed. Missing closure
   marker returned undefined; feedback URL still returned 200; all six Wrapped
   owner/state/resource combinations served the private card or share metadata;
   live responses lacked `no-store`. Original-token upload returned 200 and the
   callable reached input validation instead of the shared refusal.
3. The initial root replay used an invalid root schema and was corrected before
   production edits. Re-run with an original named-user ID token and a valid
   `createdAt` server transform: both root recreation and upload returned 200
   instead of 403. Callable replay reached input validation. All three child
   checks failed, as did their parent test (four tests, zero passed).

Raw local logs: `/tmp/withdrawn-target-red.log`,
`/tmp/withdrawn-emulator-red.log`, `/tmp/withdrawn-replay-red.log`.

## Verification history

- First full run: 585/585 unit tests passed. Combined emulator/rules run:
  780/783 passed. Two old inactivity assertions expected task removal; updated
  them to exact closure markers. The feedback test expected 404, but other
  suites' installed rules returned 403 for the removed private object. Accept
  either refusal while independently requiring Admin object absence and neighbor
  preservation. Its pre-deletion download still must return 200.
- Next full attempt: App Check's local HTTP test returned incomplete JSON;
  584/585 unit tests passed. Immediate isolated retry passed 7/7. No production
  code was changed for that intermittent failure.
- Independent read-only review found no correctness/security issues, including
  a follow-up review of the final test assertions.
- Repository checks: all nine checks passed with their existing documented
  exceptions. Attribution check passed. `git diff --check` passed.

Final complete test results are recorded below.

- Final `npm test` (build, unit, demo-emulator/rules): exit 0;
  585/585 unit tests and 783/783 combined emulator/rules tests; zero skips.
  Log: `/tmp/withdrawn-final-retry.log`.
- Verified source/test/rules patch SHA-256 (excluding this record):
  `3173813c86f95b4f5107d78dc617207268f5123d6bcaa6d8731a508aea718f0c`.
- Standalone rules command: `firebase emulators:exec --only auth,firestore,storage
  --project demo-pantas-test "node --test --test-concurrency=1 test/*.rules.mjs"`:
  exit 0, 131/131 passed, zero skips. These 131 also belong to the 783 combined
  tests above. Log: `/tmp/withdrawn-rules-final.log`.
