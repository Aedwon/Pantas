# Prod beta configuration R1

Policy: `origin/main` 6fe0445090c0a43786cb1f1d4c059ed5e74d4aef.
Source base: ddd9acadd40d89297824240ae89aef0251f1ba88, branch
`web/prod-config-r1`, with the uncommitted files listed below.
Assignment: October 30 prod configuration dispatch, tasks 1 through 4.
Later decision read: origin/main launch log, "2026-10-30 Beta: dates, project, free Pro switch".
The launch spec and plan were absent on this candidate; read both from origin/main.
The explicit dispatch controls the narrower implementation scope.

## Changes

- `.firebaserc`: prod alias and app-only target; site ID placeholder.
- `lib/app/firebase_bootstrap.dart`: select existing web options on web instead
  of always passing Android options. Existing prod entry point/config already match
  the supplied prod web app ID. No generated Firebase options were edited.
- `test/app/firebase_bootstrap_test.dart`: exercise all web flavor options and
  assert the supplied prod identity.
- `firestore.rules`: explicit recursive denial for betaApplications.
- `functions/test/beta-applications.rules.mjs`: four client types, get/list,
  collection-group query, create/update/delete, and nested documents.
- `docs/deploy-prod.md`: ordered Aedwon-only deployment instructions.
- This evidence file: local results for the lead's review.

Rules inspection: every client allow is scoped under users or wrapped_shares.
No allow matches betaApplications. The recursive catch-all also denies access.
Server credentials bypass client rules; no Worker code or credentials were accessed.

## Verification, October 30, 2026

No fetch, branch change, commit, push, deploy, live application request, or secret
read was performed. npm ci used the package registry. Tests used demo-pantas-test
and local emulators. Ports 8080, 9099, and 9199 had no listeners before each run;
no processes were killed. Node v26.10.0, npm 11.19.1; the project requires Node 22.
The install reported 21 vulnerabilities (7 moderate, 14 high). No dependencies changed.

`npm test` (functions), final run with CI=true and update check disabled:

```text
ℹ tests 225
ℹ pass 225
ℹ fail 0
...
✔ betaApplications denies all client access: owner-like
✔ betaApplications denies all client access: other
✔ betaApplications denies all client access: anonymous
✔ betaApplications denies all client access: signed-out
...
ℹ tests 325
ℹ pass 325
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
✔ Script exited successfully (code 0)
...
Error: An unexpected error has occurred.
```

Overall npm exit: **2**, after emulator shutdown, despite both test runners
exiting successfully. The earlier run without the new test also passed its test
runners but exited 1 with an update-check/config-directory warning. The final CLI
failure is unresolved. The lead must rerun with supported Node 22 before acceptance.
Raw final log for this local session: `/tmp/prod-config-functions-test-r2.log`.

The first Flutter attempts found missing ignored generated files and
`assets/seed/lesson_links.json`. Generated local code with
`dart run build_runner build --delete-conflicting-outputs` (exit 0), and generated
only the missing lesson-link build asset with
`dart run tools/build_content_export/build_content_export.dart /tmp/prod-config-export.json --assets-out assets/seed`
(exit 0). This branch supplied 0 links and 0 tags. No pinned content package was
regenerated. Export warned of two unrelated oversized lesson images. Generated
files and the temporary export are excluded from the patch.
The initial regression-test run was blocked by the missing asset, so no successful
red-phase result is claimed.

Final checks:

```text
flutter analyze --no-pub
No issues found! (ran in 12.5s)

flutter test --no-pub test/app/firebase_bootstrap_test.dart test/tool/firebase_config_layout_test.dart test/core/platform/app_check_test.dart
00:00 +21: All tests passed!

dart format --output=none --set-exit-if-changed lib/app/firebase_bootstrap.dart test/app/firebase_bootstrap_test.dart
Formatted 2 files (0 changed) in 0.01 seconds.

dart run tool/check_layering.dart
check_layering: OK

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK

flutter build web --release --no-pub -t lib/main_prod.dart
Compiling lib/main_prod.dart for the Web... 38.1s
✓ Built build/web
```

Those commands exited 0. Build warns about absent CupertinoIcons font and recommends
Wasm testing. No App Check key was supplied. This proves compilation only: the
artifact intentionally fails closed at release startup and must not be deployed.
`git diff --check` and Node syntax check for the added rules test passed.
No full Flutter suite, deployed smoke test, real App Check attestation, content
upload, independent review, or visual acceptance was performed. Lead owns acceptance
and any shared status update; no locked status file was edited.

## Inputs still required

Aedwon: confirmed prod Hosting site ID, prod public App Check site key, billing,
Auth/App Check console setup, test PayMongo secrets and webhook, exact DNS records.
Lead: approved CSE-only root/export and content revision, independent review,
Node 22 verification, and release authorization. The separate beta Pro switch
must be accepted before the promised beta behavior is advertised as complete.
