# Privacy batch plan

Spec: `docs/superpowers/specs/2026-11-09-privacy-batch-design.md` (Part 2 holds the settled
design; this plan does not repeat it). Base: `web/design-system-4` after the redesign release
and the bug fixes merge. Start the batch from that integration head on a new branch
`web/privacy-batch-r1`. The manager starts it. One batch lead integrates the work.
Every worker gets the startup instruction from `docs/workflow/startup.md`.

Stop conditions: a source fact in the spec's Part 2 no longer holds on the base; a board is
not approved; the real guardian mail key is missing at the prod step. Report and stop that
task only.

## Tasks

### T1. Deletion core (functions)
- Files: `functions/src/deleteAccount.ts`, new `functions/src/deleteUserData.ts`, tests.
- Move the deletion body into `deleteUserData(db, auth, uid, reason)`. It writes
  `guardianConsentEvidence/{uid}` `{accountDeletedAt, reason}` and copies checkout
  attestations into the evidence (spec choice 1) before deleting the tree.
  The callable keeps its recent-sign-in check and calls the core.
- Verify: the existing deleteAccount tests pass unchanged, and a new test asserts the
  evidence marker and that responses survive.

### T2. Guardian manage (functions, then app)
- Files: `functions/src/guardianConsent.ts`, `functions/src/guardianMail.ts`,
  `functions/src/index.ts`, `lib/features/guardian/**`, `lib/app/routes/guardian_routes.dart`.
- Server: manage tokens (spec choice 2), `readManage`, `setGuardianSharing`,
  `withdrawGuardian` (choice 3), `allowSharing` on answer and `sharingAllowed` in
  `getStatus` (choice 4), and the purge skips manage rows.
- Email: add the manage link under the confirm link.
- App: the confirm page gets an unticked "Allow optional usage sharing" checkbox, separate
  from the agreement box; after confirming, a "Manage permission" button. A new route,
  `/guardian/manage`, opens signed out like `/guardian`. Its layout follows the approved
  board. Build the page only after the board is approved.
- Verify: emulator tests from the spec's list; widget tests for the checkbox, the button
  and each manage-page state.

### T3. Minor sharing gate (app)
- Files: `lib/app/telemetry_consent_controller.dart`, `lib/features/settings/**`, the guardian
  providers.
- Choice 4 behavior on the device. The Settings switch is disabled with its caption until
  `sharingAllowed` is true.
- Verify: unit tests for the off, allowed and revoked cases, plus one widget test of the switch.

### T4. Inactivity and evidence purge (functions)
- Files: new `functions/src/purgeInactiveAccounts.ts`, `functions/src/index.ts`, the mail
  template, tests.
- Choices 5 and 6, scheduled daily at 04:00 Singapore time, with a cap of 200 deletions per
  run.
- Verify: emulator tests with fixed clocks at 22, 23 and 24 months, a paid skip, a refreshed
  account skip, an email-less anonymous account, and evidence at ten years.

### T5. Minor checkout (app, then functions)
- Files: `lib/features/settings/presentation/pages/pro_page.dart`,
  `lib/features/paywall/data/web_payment_gateway.dart`, `functions/src/paymongoCheckout.ts`.
- Choice 7. The checkbox label is exactly "I am the parent or guardian and accept the
  Terms." Build the UI only after its board is approved.
- Verify: a widget test that the button is disabled until ticked; emulator tests that a
  minor without the attestation is refused, a minor with it is accepted and recorded, and
  an adult is unaffected.

### T6. Speed-report switch (app)
- Files: `lib/features/settings/data/settings_repository.dart`, the About page,
  `lib/core/telemetry/client_report.dart`.
- Choice 8. The switch label is "Send speed and error reports", on by default.
- Verify: a unit test that the reporter sends nothing when off and drops its queue; a widget
  test of the row.

### T6b. Age step, setup acceptance, "I'm 18 now" (app and functions)
- Files: `lib/features/onboarding/presentation/onboarding_age_gate_step.dart`, the consent
  step, `lib/features/settings/**`, `functions/src/guardianConsent.ts` (new `markAdult`).
- Spec choices 11, 12 and 13.
- Verify: widget tests for the age-step line and the Settings row's visibility; emulator
  tests for `markAdult` (token revocation, single use, adult caller refused).

### T7. Legal texts and versions (app and functions)
- Files: `lib/features/legal/domain/legal_document.dart`, `functions/src/guardianConsent.ts`.
- Paste the final wording from `docs/legal/drafts/2026-11-09-legal-texts-review.md`, then
  bump the three version stamps to the publish date (choice 10). Change `supportEmail` in
  `lib/features/legal/domain/legal_contact.dart` from contact@ to support@pantas.study.
- Verify: a test that the app and functions version maps are equal; an existing legal page
  test; a text diff against the review file shows no change.

### T8. Deploy (lead, with Aedwon's approval)
- Staging first: deploy the functions and the web app, add the log exclusion (choice 9), and
  check with `gcloud logging read` that no new request entries appear. Run the browser
  journey, then hand to Aedwon for the visual pass.
- Prod: only after the founder app shows the guardian mail key and sender as provided.
  Repeat the exclusion and the check.

## Final verification (batch lead)

`dart run tool/checks/run_checks.dart`; `flutter analyze`; the touched Flutter tests
locally; the full Flutter, functions unit and emulator suites and the browser journeys on
hosted Actions. Record the results, the head SHA and anything unverified in the launch log
before reporting.
