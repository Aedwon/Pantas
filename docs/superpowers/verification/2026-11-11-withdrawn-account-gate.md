# Withdrawn gate verification

Policy main: 38f74462da82729e1adc85663348b52db8de8f3a.
Code base: see the parent of the rules commit on web/withdrawn-gate-r1.
Only local demo-pantas-test emulators used. Node 22 and Java 21 selected from
Homebrew. npm ci reported one low-severity dependency advisory; no lock change.

## Task 1: rules

Command (from functions, after npm ci):
`firebase emulators:exec --only auth,firestore,storage --project demo-pantas-test "node --test --test-concurrency=1 test/withdrawn-account.rules.mjs"`

Before rule edits: 36 tests, 18 pass, 18 fail. Every blocked-account case failed
with `Expected request to fail, but it succeeded.` Normal accounts passed.
After edits: 36 tests, 36 pass, 0 fail (2450.863333 ms).
Raw local logs: `.dart_tool/withdrawn-gate/rules-{red,green}.log`.

Both rulesets read two distinct server-owned document paths: accountDeletions/uid
and users/uid/server/guardianConsent. A present task short-circuits refusal.
Absent or trimmed consent permits normal ownership checks. Consent exists/get
uses the same path and cached lookup; maximum two document reads, including
Storage's two-document limit. Existing sync access adds its own generation paths.
The ten-row sync batch passes, exercising repeated-check caching under the batch
access-call budget. All own reads/writes, passes/grants (including anonymous),
feedback, sync and wrapped shares use the common gate. Admin SDK bypasses rules.
