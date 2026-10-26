# Access hardening r1 evidence

Assignment: audit findings 1 and 2 only. Base `417078bf8015e50b6b78b0e5026204d680534aaf`, branch `web/access-hardening-r1`.
Policy read with `git show origin/main:<file>` at `64e5757674ccca9eb42e1b63d22df84f788de470`: AGENTS.md, WORKFLOW.md, SUBAGENTS.md. No fetch or pull.
Controlling product records: origin/main C1-C10-ruling.md, docs/pricing.md, and 2026-10-19-pwa-launch-log.md. The lead brief defines the bounded fix and checks.

## Finding 1

Implemented current server coverage checks using the existing `mockCoverage` reader, which combines RevenueCat facts, native pass records and web grants. Question-set exam tags map to the catalog's exam IDs. Paid notes require coverage for at least one exam tagged on that set. Unknown exams receive free fields. Subscription tier inclusion follows the existing coverage helper. Token claims and their 24-hour extension do not grant content access. Each item's version suffix follows its own coverage, including paid-to-free cache transitions.

Tests cover Professional versus Subprofessional, unrelated Student and Licensure content, unknown exams, revoked grants, exact expiry, future starts, cached paid versions, Civil Service subscription inclusion of Student exams, native passes and revocation, and RevenueCat subscription revocation and expiry.

Failing-first command (before implementation):

```sh
cd functions && npm run build
PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npx firebase emulators:exec --config ../firebase.access-test.json --only auth,firestore,storage --project demo-pantas-test 'node --test test/content-access.emulator.mjs'
```

Observed assertion:

```text
actual: [ true, true, true, true, true ],
expected: [ true, false, false, false, false ],
```

The regression failed on the first exam-isolation assertion. Later assertions were exercised after the fix.

## Finding 2

Rules require `wrapped/<authenticated owner>/<share ID>.png` at creation and a valid share ID. Existing update rules still allow only revocation. The HTTP reader validates the owner path segment and derives the object path from ownerUid and the URL's validated share ID. It never uses storagePath. Existing records containing forged paths therefore cannot select another object.

Failing-first command (before share implementation):

```sh
cd functions
PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npx firebase emulators:exec --config ../firebase.access-test.json --only auth,firestore,storage --project demo-pantas-test 'node --test --test-concurrency=1 test/wrapped-access.rules.mjs test/wrapped-access.emulator.mjs'
```

Observed output:

```text
✖ share reader ignores forged stored paths and refuses invalid owners and revoked shares
'SECRET' !== 'OWN'
✖ share paths bind the owner and share id; only revocation can change
Error: Expected request to fail, but it succeeded.
ℹ tests 2
ℹ pass 0
ℹ fail 2
```

The reader test uses real emulator Firestore and Storage through the exported HTTP handler. Rules tests reject both another owner's path and another share's path. They also check valid creation, blocked path updates and allowed revocation.

## Verification environment and limits

`functions/node_modules` was missing. Ran `cd functions && npm ci` before tests. Result: 811 packages installed. npm reported 19 existing dependency vulnerabilities (6 moderate, 13 high). No dependency or lockfile changes.

Runtime: Node v26.10.0, npm 11.19.1, OpenJDK 21. npm warned that the package declares Node 22. No deploy, commit, merge or push. No other worktree touched. Independent acceptance remains with the lead.

Isolated emulator ports: Auth 19091, Firestore 18081, Storage 19191, hub 14441, logging 14501; UI disabled. The full npm test command uses firebase.json, so its emulator configuration was temporarily replaced for that command and restored afterward. No emulator configuration change is part of the patch. The CLI warned another suite uses the same demo project; this run used distinct service ports.

The focused post-fix run exposed an inconsistent test fixture introduced while changing an unknown exam tag to UPCAT. Fixed the fixture's catalog ID and assertions before the full run. No unrelated test failure was encountered.

No Dart changed. Flutter, Dart formatting, layering and server Dart rebuild checks are outside this patch's required scope. The attribution check ran as required. No live service or device behavior was verified. No product question remains.

## Verified source identity

SHA-256 of implementation and tests (evidence excluded):

```text
5d90a717e6ebb2acc3f74067158b28a8cda3d6d177fe115628e5998610ec8f16  firestore.rules
00a94f06c2d26035da57a1604a6a5d09b013513dd4f5667473f3a1c1a406abd6  functions/src/content.ts
b0af7299bea980d78c1ae0d177ac21d0578778eea8b2ad0c1ef127c43d32fc60  functions/src/renderWrappedPage.ts
0965e2d5a5b908183ce1746890472487e958bf795cfb953f51e07773acd94751  functions/test/server-pro.emulator.mjs
e77c2de1e5fdf83b2442710f1c0ebac40b3ef88605c83a557963ede955b07922  functions/test/content-access.emulator.mjs
00bebf61b27de34db0256a734a7a9bda280600e70ce88bde740a16959db66539  functions/test/wrapped-access.emulator.mjs
c2493553f12ca8f27e4d94807a6dc69de441de16bf75077a51dd6fc51cb25e57  functions/test/wrapped-access.rules.mjs
```

## Final gate output

Required command:

```sh
cd functions && npx tsc --noEmit && PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
```

TypeScript exited 0 with no output. The first full run passed both suites (196 plain, 248 emulator), but the CLI exited 2 afterward because its update checker could not write under the sandbox's read-only config directory. Repeated the same checks with `XDG_CONFIG_HOME=/private/tmp/pantas-access-cli-config` for both commands. That run exited 0. The production source and tests were unchanged between runs. Actual final summaries, first plain then emulator:

```text
ℹ tests 196
ℹ pass 196
ℹ fail 0
ℹ skipped 0
ℹ tests 248
ℹ pass 248
ℹ fail 0
ℹ skipped 0
✔  Script exited successfully (code 0)
```

```text
$ dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

`git diff --check`: exit 0, no output.

Final `git status --short`:

```text
 M firestore.rules
 M functions/src/content.ts
 M functions/src/renderWrappedPage.ts
 M functions/test/server-pro.emulator.mjs
?? docs/superpowers/plans/pwa-launch/evidence/access-hardening-r1.md
?? functions/test/content-access.emulator.mjs
?? functions/test/wrapped-access.emulator.mjs
?? functions/test/wrapped-access.rules.mjs
```

Files match the assigned content reader, share rules/reader, affected existing test fixtures, new regression tests and requested evidence. No additional product change. Both findings implemented and locally tested; lead review and commit remain pending.
