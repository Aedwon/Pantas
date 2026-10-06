# L3 W5: release checks (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W5-release-checks.md`. Base: integration branch after every W4 family and W2's
close-out integrate and the combined checks pass. Executor: lead plus Sonnet workers for test
retargeting; independent Opus reviewer for the evidence (B7). Device steps are performed by Aedwon
from the lead's numbered instructions (WORKFLOW "Computer control").

Definitions recorded here from their sources (WORKFLOW: external context recorded in the repo):
- "E09 #22 to #28" are GitHub issues in Aedwon/Pantas: #22 custom-exam onboarding entry redirects
  back to the exam picker; #23 Quiz tab can stay on the assessment gate after the assessment;
  #24 (closed) incomplete Today quiz not offered as Resume after Leave; #25 built-in exams with no
  content crash assessment start; #26 exam-switch carry-over sheet flashes and reappears; #27 Quiz tab
  Resume count ambiguous; #28 Quiz tab keeps a stale Resume card. The rebuilt screens own the fixes
  (W4a Tasks 6 and 9, W4d Tasks 2 and 5, W4f Task 3); W5 re-tests each on the phones.
- A01 to A07, from the SSOT tab "Pantas Production Readiness Assessment": A01 production
  Firebase, Auth and sync (startup, sign-in and linking, conflict and isolation, offline to online,
  reinstall and restore); A02 production App Check and Play Integrity; A03 RevenueCat and Play
  license-test lifecycle (purchase, Pro on, restore and reinstall, cancellation and expiry, refund and
  revocation where supported, failure behavior, offering and prices); A04 physical-device smoke
  (onboarding, Home, Study, lessons, quiz and review, mock, bookmarks, Settings, Pro page, background
  and resume, offline study, protected content); A05 accessibility (TalkBack equations and focus,
  large text, theme switching), smoke; A06 notifications and device runtime (permission, exact
  alarms, reboot rescheduling, time zone, OEM), smoke; A07 privacy and account data (local and
  account deletion, telemetry consent, Firebase unavailable, content recovery after reset).
  Destructive flows on a shared device or account run one at a time.

## Task 1. Release package

After the last content change (W4e blueprints, W0 Task 4b credits, and any exam dates Aedwon
supplied per W0 Task 6), rebuild the signed content package once with
Aedwon's authorization (W0 Task 6 procedure) and record the non-secret candidate record (source SHA,
`releaseSequence`, `sourceContentSha256`, `contentSeedVersion`, `payloadSha256`, manifest and
signature SHA-256, key ids, cipher profile, schema versions) in
`release-evidence/candidate.md`. Placeholder check: `test/core/ui/placeholders_test.dart` lists no
`PlaceholderFigure`; otherwise stop (R-20 release blocker) and ask Aedwon for the values.
Checks: inside the scoped key shell, `dart run tools/verify_content_package/verify_content_package.dart
assets/seed/content.db assets/seed/content.manifest.json assets/seed/content.manifest.sig` exits 0; its `releaseSequence` is one above
the shipped package's; `flutter test test/core/ui/placeholders_test.dart` green with no
`PlaceholderFigure` listed.

## Task 2. Release end-to-end tests

Traceability: S0-43.
Restore the four kept tests from the live worktrees (or `origin/archive/pre-restart-kept-work`
`dirty/*.untracked.tgz`) into `integration_test/release/` with `support/firebase_emulator_harness.dart`
and `test/tool/release_e2e_firebase_contract_test.dart`; retarget their finders and routes to the new
screens (consent copy, reminders "Not Right Now", "Session finished.", mock "End Part", "Delete My
Data", tab names); keep `delete_local_data_e2e_test.dart` and retarget it; delete the QLP-5 rehearsal
test (campaign cut Oct 1). All paths stay inside the runner's allowed diff list
(`tools/release/e2e/runner_support.py`). Run E10 once with `tools/release/test_e2e.sh` against the
candidate on Aedwon's Android device (he connects it; the lead gives the command).

## Task 3. E11 to E14

Follow the E04 to E14 plan (on the integration branch,
`docs/superpowers/plans/2026-09-07-e04-e14-content-protection-quiz-launch-release-plan.md`) for E11
review, E12 signed AAB (production signing inputs from Aedwon), E13 artifact inspection and E14
freeze. No upload or publication without Aedwon's separate authorization. E14 needs his explicit
acceptance of the bootstrap-key residual risk.

## Task 4. CP-T5 content identity proof

Redo the CP-T5 security scenarios on the release package (fresh offline install, migration, reopen,
wrong or missing key, altered package, interrupted install, process death, key-loss recovery,
downgrade and replay, journals and temp files, backup and restore, user database preservation),
per the E09 section of the E04 to E14 plan.

## Task 5. Phone checks on Android

Aedwon runs, from numbered instructions: issues #22 to #28 regression checks, A01 to A04 and A07 in
full, A05 and A06 as smoke, and the Redmi responsiveness smoke. A03 covers the tier cases: each
Student and Civil Service plan, the Monthly trial and its absence after a lapse, a Student to Civil
Service upgrade, a pass purchase and its end date, refusal of a pass with no published sitting,
restore. Evidence per check in `release-evidence/<check>.md` (the L2 format).

## Task 6. iPhone

From the September design (`web/ios-physical-qa-enablement-r1`,
`docs/superpowers/specs/2026-09-15-ios-physical-qa-enablement-design.md`, kept by S0-49):
Traceability: S0-49, A-B5a.
1. Project setup (worker): dev and staging build configurations and schemes using the existing
   `Dev.xcconfig` and `Staging.xcconfig`, bundle ids `com.aedwon.pantas.dev` and `.staging`, iOS
   Firebase options for each flavor (generated config files from Aedwon's Firebase console; no
   `UnsupportedError` for iOS), `firebase_bootstrap.dart` choosing iOS options on iOS. Deployment
   target raised only if a dependency requires it, as the design says.
2. Aedwon's steps (numbered instructions): sign in to Xcode with his Apple ID and pick his team;
   register the iOS apps in Firebase and download their config files; pair the iPhone for wireless
   debugging (Xcode, Window, Devices and Simulators, Connect via network). Wireless pairing is
   unverified until he tries it; if it fails, stop and record.
3. Run the A04 smoke and the #22 to #28 checks on the iPhone.
Whether App Store purchases are in beta scope is Aedwon's decision, asked at the start of level 4;
until he decides, A03 runs on Android only.

## Task 7. Evidence review and SSOT

Independent Opus review of all release evidence against the exact candidate; update the SSOT tab's
5 Oct restart entry and STATUS. The release decision is Aedwon's.
