# Privacy batch: guardian controls, retention end dates, minor checkout, report opt-out (Nov 9, 2026)

Status: remedies approved by Aedwon on Nov 9, 2026 (launch log, "Legal risk remedies approved").
Routine choices below were settled by the lead under that approval. Not built. The batch
builds after the redesign release and the bug fixes merge; the manager starts it.
Workstream base: `web/design-system-4` at 7fcfc135a (read for this spec). Policy: main at 21d7f6af5.
Legal texts that describe this batch: `docs/legal/drafts/2026-11-09-legal-texts-review.md`
(revised for this batch). They publish together with this batch, never before.

---

## Part 1: Plain language

### What Aedwon approved

His words, Nov 9: "1. yeah no way, no money. / 2. ok / 3. ok / 4. ok / 5. ok / 6. ok, but set
up things so it's easier for me to notify you once these things are available / 7. okay /
8. you do this / 9. ok / you can start things as needed in sequence if there are
dependencies, considering other already listed ongoing work". Then, on the owner inputs:
"founder app only. you're underestimating your speed of completing things. you should be
able to finish the things you've listed in a week i bet".

This batch builds remedies 2, 3, 4, 5 and 7. Remedies 8 and 9 are text only and are in the
review file. Remedy 6 lives in the founder app's "Owner inputs" tab.

### What changes for students and guardians

1. **Optional usage sharing for under-18 accounts.** It stays off, and the student cannot
   turn it on. The guardian page gets a separate, unticked choice: "Allow optional usage
   sharing". If the guardian ticks it, sharing turns on for that student, who can still turn
   it off. If the guardian later turns it off, it goes off.
2. **The guardian can manage and withdraw at any time.** After confirming, the guardian gets
   a "Manage permission" link: on the confirmation screen and in the original email. The
   link keeps working while the account exists. The manage page has the sharing switch and
   a "Withdraw permission" button. Withdrawing asks once to confirm, then closes the
   student's account: it signs the student out and deletes the account the same way the
   delete button does. The guardian's answers stay as evidence.
3. **Inactive accounts are deleted after 24 months.** An account with no sign-in or app use
   for 24 months is deleted. Thirty days before, the account's email gets a warning; any use
   cancels the deletion. Accounts with paid access still running are never counted as
   inactive. Guest accounts with no email are deleted without a warning.
4. **Guardian answer records have an end date.** They are kept while the account exists,
   and after deletion until nine years after the guardian's answer. Reason: a student under
   18 can be up to five years from turning 18. Civil Code Art. 1391 then gives four years from
   reaching 18 to undo a contract made as a minor. Nine years covers that window for every
   minor. Trial-use codes stay as they are, because they are keyed hashes.
5. **Checkout on an under-18 account needs an adult's confirmation.** The Pro page shows a
   checkbox: "I am the parent or guardian and accept the Terms." The buy button stays
   disabled until it is ticked. The server refuses checkout without it and records when it
   was ticked and which Terms version was shown. It replaces the line "Ask your parent or
   guardian to complete this payment".
6. **Students can turn off speed and error reports.** Settings, About, gets a switch "Send
   speed and error reports", on by default, under the usage sharing switch. Turning it off
   stops the web app from sending them.
7. **No IP addresses in the speed and error report logs.** A Cloud Logging exclusion drops
   Google's connection log entries for the report function on staging and prod. Those entries
   are what hold the IP address and the full browser string. The report's own log line never
   held either.
8. **The legal texts go live with the batch:** the teen notice, the full adult Privacy Policy,
   and the Terms "Subscriptions" and "Use of the app" sections. Guardians who confirmed
   before stay tied to the version they saw. New confirmations record the new version.

### What it costs

- Build: about one working day of agent time, including tests, then one staging check.
  This follows Aedwon's note that agents finish faster than estimated.
- Running cost: about zero. Two daily scheduled jobs and a few emails a month. The log
  exclusion lowers log volume.
- Two Cloud changes need approval when deployed: the log exclusion and the new scheduled
  jobs. Deploys already need his approval.

### What needs Aedwon

- **A board before building the two new screens:** the guardian manage page and the minor
  checkout checkbox. They are built in Claude Design from the approved guardian and Pro
  screens (written rule 3). The Settings switch and the extra guardian checkbox reuse
  existing rows and need no board. The wording is the lead's call (written rule 4).
- **Owner inputs this batch depends on.** The founder app's "Owner inputs" tab carries them:
  1. **The real guardian mail key** (`GUARDIAN_MAIL_API_KEY` on pantas-prod). Today it is a
     placeholder, so no guardian or warning email can go out from prod. This blocks items
     2 and 3.
  2. **The sender address for warning and manage emails.** The default is the guardian mail
     sender (`GUARDIAN_MAIL_FROM`). He confirms it is a monitored address.
  3. **A monitored dpo@pantas.study inbox.** Withdrawal by email stays a second route. Replies
     to warning emails go there.
  4. **Not blocking, but related:** NPC registration and the signed child privacy assessment.
     The batch reduces the risks they cover, but it does not replace them.

### How completion is judged

- Every behavior in "What changes" works on staging, with tests at the seams listed in
  Part 2.
- The legal texts in the app match the review file word for word, and the version stamps
  changed in the app and the functions together.
- The staging request logs for the report function show no new entries after the exclusion.
- Aedwon's visual pass on the two new screens, as for any UI.

### Not in this batch

- An accounting archive. Account deletion removes the app's own payment index, so automatic
  deletion makes this matter more. The five-year records stay the owner's books and the
  PayMongo exports. Risk recorded in the review file.
- A guardian dashboard of results. No business email or phone on the website: that is his copy.

---

## Part 2: For agents

### Facts this design rests on (design-system-4 at 7fcfc135a)

- The server knows an account is a minor only from `users/{uid}/server/guardianConsent`
  (`ageGroup: 'minor'`, written at the first `sendLink`, `guardianConsent.ts` line 189). The
  age group on the device is in `app_preferences_repository.dart` (`age_group`).
- Guardian links: hashed in `guardianTokens/{hash}`, seven days, one use. `answerRequest`
  (lines 249 to 297) writes the evidence to `guardianConsentEvidence/{uid}/responses/{hash}`,
  outside the user tree. `deleteGuardianRecords` removes tokens by uid. `purgeGuardianRecords`
  runs hourly.
- The guardian's name and email live only on the student's device. The server has the email
  only during `sendLink`. Any email to the guardian after that is impossible, so the manage
  link must be minted at send time or returned at confirmation.
- Optional sharing: `TelemetryConsentController` (`lib/app/telemetry_consent_controller.dart`)
  and the settings repository. The web speed reporter (`lib/core/telemetry/client_report.dart`)
  ignores this consent by design (option A).
- Deletion: `deleteAccount.ts` (callable, needs a recent sign-in). The anonymous cleanup is
  `cleanupOrphanAnons.ts` (scheduled).
- Checkout: `createPaymongoCheckout` in `paymongoCheckout.ts`. The minor line is on
  `pro_page.dart` around line 697.

### Design choices settled by the lead

1. **Shared deletion core.** Extract the body of `deleteAccount` into
   `deleteUserData(db, auth, uid, reason)`, used by the callable, the withdrawal and the
   inactivity job. Before the user tree is deleted, it writes
   `guardianConsentEvidence/{uid}` `{accountDeletedAt, reason}` (merge). The callable keeps
   its recent-sign-in check, and the server-side callers skip it.
2. **Manage tokens.** `sendLink` mints two tokens: the confirm token (as today) and a manage
   token stored at `guardianTokens/{hash}` `{kind: 'manage', uid, state: 'open'}`, with no
   expiry. The email carries both links: "Confirm" and "Manage permission (after you
   confirm)". A new `sendLink` revokes earlier manage tokens for that uid. `answerRequest` on
   confirm also mints a fresh manage token and returns its plain value once, for the page's
   "Manage permission" button. `deleteGuardianRecords` already removes all tokens by uid.
   `purgeGuardianRecords` must skip `kind: 'manage'` rows with no `expiresAt`.
3. **Manage callables.** `readManage(token)` returns `{status, sharingAllowed}` only when the
   consent status is `confirmed`. `setGuardianSharing(token, allowed)` updates the consent
   doc's `sharingAllowed` and appends an evidence response
   `{action: 'sharing_on' | 'sharing_off', decidedAt}`. `withdrawGuardian(token)` appends
   `{action: 'withdraw'}`, sets the consent status to `withdrawn`, disables the Auth user,
   revokes refresh tokens, then calls `deleteUserData(uid, 'guardian_withdrawal')`. All use the
   existing visitor rate limit and App Check.
4. **Sharing on confirm.** The confirm page sends `allowSharing: boolean` (default false). It
   is stored as `sharingAllowed` on the consent doc and in the evidence. `getStatus` returns
   `sharingAllowed`. On a minor device: if `sharingAllowed` is false, analytics stay off and
   the Settings switch is disabled with the caption "Your parent or guardian can turn this
   on."; if it is true, sharing turns on once (a local flag records that the guardian grant
   was applied) and the student may turn it off.
5. **Inactivity.** A daily job, `purgeInactiveAccounts`, pages through Auth users with
   `listUsers`. Activity is the later of `metadata.lastSignInTime` and
   `metadata.lastRefreshTime`. Token refresh happens whenever the app is used, so no new
   write path is needed. An account is skipped when its entitlement claims show Pro access
   running (`proUntil > now` or an active pass). At 23 months (24 months minus 30 days), the
   job sends one warning to a verified email and records `users/{uid}/server/inactivity`
   `{warnedAt}`. At 24 months, if there was still no activity after `warnedAt`, it calls
   `deleteUserData(uid, 'inactive_24_months')`. Anonymous users with no email are deleted at
   24 months without a warning. The warning text is the lead's call: plain, one action
   ("Open Pantas to keep your account"). Batch cap: 200 deletions per run.
6. **Evidence purge.** Add to the daily job: delete `guardianConsentEvidence/{uid}` and its
   responses when `accountDeletedAt` exists and the newest response's `decidedAt` is more
   than nine years ago (3,288 days, counted as 9 x 365 + 3).
7. **Minor checkout.** On `pro_page.dart`, when `ageGroup == 'minor'`, show a DS4 checkbox with
   the exact label "I am the parent or guardian and accept the Terms." in place of the
   ask-guardian line. The buy button is disabled until it is ticked. The client sends
   `guardianAttestation: {termsVersion}`. `createPaymongoCheckout` checks for
   `users/{uid}/server/guardianConsent.ageGroup == 'minor'`. If so, it requires the
   attestation with the current Terms version, or it returns `failed-precondition`. It stores
   `{attestedAt, termsVersion}` on the checkout record. The server check is the control; the
   device age group only drives the UI.
8. **Report opt-out.** A local setting `speedReportsEnabled` (default true) is added to the
   settings repository, with a Settings, About switch "Send speed and error reports". Then
   `client_report.dart` checks it before queueing or sending, and drops queued reports when
   it is turned off.
9. **Log exclusion.** On pantas-staging and pantas-prod, add an exclusion on the `_Default`
   sink named `drop-telemetry-request-logs`, with the filter
   `resource.type="cloud_run_revision" AND resource.labels.service_name="reportclienttelemetry" AND log_id("run.googleapis.com/requests")`.
   Command, run at deploy with approval:
   `gcloud logging sinks update _Default --project=<p> --add-exclusion=name=drop-telemetry-request-logs,filter='<filter>'`.
   Verify with a `gcloud logging read` that returns no new entries.
10. **Legal texts and versions.** Replace the `teens`, `privacy` and `terms` documents in
    `legal_document.dart` with the review file's final wording. Bump `guardianDocumentVersions`
    and `GUARDIAN_DOCUMENT_VERSIONS` plus `GUARDIAN_NOTICE_WORDING_VERSION` to the publish date
    in the same commit. The Terms version also feeds the checkout attestation.

### Tests at the seams

- Functions (emulator): manage token minted, revoked on resend, rejected after deletion;
  withdrawal disables the user, deletes the tree and keeps the evidence plus
  `accountDeletedAt`; sharing on and off recorded; the inactivity job warns at 23 months,
  skips paid and recently refreshed accounts, deletes at 24 months, deletes email-less
  anonymous users without mail; the evidence purge deletes only after deletion plus nine
  years; checkout refuses a minor without the attestation and accepts one with it; the
  purge skips manage tokens.
- Flutter: the minor Settings switch is disabled until the guardian allows sharing; the
  checkout button is disabled until the checkbox is ticked; the speed-report switch stops
  the reporter; the guardian confirm page sends `allowSharing`; the manage page shows its
  states.
- Browser journey: a guardian confirms with sharing, opens manage, withdraws, and the
  student's session ends.
- Existing checks: `dart run tool/checks/run_checks.dart`, and the functions unit and
  emulator suites on hosted Actions.

### Order

1. Deletion core and evidence marker.
2. Guardian manage tokens, callables, confirm-page sharing choice, then the manage page
   after its board.
3. Minor sharing gate on the device.
4. Inactivity job and evidence purge.
5. Minor checkout checkbox after its board, then the server check.
6. Speed-report switch.
7. Legal texts and version bumps.
8. Staging deploy and the log exclusion, after approval; then prod with the real mail key.

Tasks 1 to 2 are sequential, tasks 3 to 6 are independent after task 1, and task 7 is last.
