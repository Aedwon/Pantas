# Teen notice and Terms web wording: draft for review

Draft of Nov 5, 2026. Not legal advice and not published. Needs review by a Philippine lawyer. File links are relative to the repository root.

**Filled in Nov 5 from the pantas-web site (`privacy.html`, `contact.html`):** owner and DPO name, address, dpo@pantas.study, support@pantas.study and the 15 day reply. That site records that there is no NPC registration yet and the child privacy assessment is unsigned, so both remain open for the reviewer. Retention there covers beta signups, not the app, so the app's periods stay as placeholders.


**1. TEEN NOTICE**

**Notice for teens**

Updated [PLACEHOLDER: publication date]

**Who this is for**

This notice is for teens ages 13 to 17 and their parents or guardians. Pantas currently sets 13 as its minimum age. We ask for your birth year to check which age group applies. We keep the age group, not your birth year. If your birth year could mean you are still 17, we ask a guardian to confirm too. ([Age policy](lib/features/onboarding/domain/age_policy.dart), [age gate](lib/features/onboarding/presentation/onboarding_age_gate_step.dart))

**Who runs Pantas**

Pantas is run by Pantas Online Tutorial Services, a sole proprietorship. Owner: Aerol Dwayne Daños Balayon. Business address: Poblacion, Norala, South Cotabato. For questions about your data, email dpo@pantas.study. ([Launch log, November 2](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2381), [legal contact launch requirements](docs/superpowers/specs/2026-05-23-legal-ra10173-implementation-notes.md))

**What we collect**

Pantas uses an account ID even before you sign in with Google. If you sign in with Google, Pantas receives account details such as your name, email, and profile photo. ([Sign-in gateway](lib/core/auth/firebase_auth_gateway.dart))

We keep your study settings, answers, results, and study times. We also keep lessons you bookmark and questions you flag. We use these records to run your study sessions, plan reviews, and show your progress. ([Settings](lib/features/settings/data/settings_repository.dart), [study sessions](functions/src/ingestSession.ts), [bookmarks](lib/core/storage/data/tables/lesson_bookmarks_local_table.dart), [flags](lib/core/storage/data/tables/question_flags_local_table.dart))

For guardian confirmation, we ask for your guardian’s name and email. We send them an email link. Our server keeps the request status, dates, a partly hidden email address, and one-way codes for the email and link. The full name and email also stay on your device so you can resend the request. They are cleared from that device when Pantas checks a successful confirmation. ([Guardian server](functions/src/guardianConsent.ts), [guardian controller](lib/features/guardian/application/guardian_providers.dart))

If someone buys Pro for your account, we keep payment references, the amount paid, refund records, and access dates. Web payment details are entered on PayMongo’s checkout page. ([PayMongo checkout](functions/src/paymongoClient.ts), [payment records](functions/src/paymongoGrants.ts))

**Optional usage sharing**

You can choose whether to share extra usage data to help improve Pantas. This starts off. If you turn it on, reports can include which screens you use, question IDs, your answer choices, and whether those choices were correct. Reports can be linked to your account ID. The phone app also supports error reports. ([Consent settings](lib/features/settings/data/settings_repository.dart), [answer reports](lib/features/quiz/domain/use_cases/submit_answer.dart:60), [reporting](lib/core/telemetry/firebase_telemetry.dart), [account identifiers](lib/core/telemetry/crash_reporting.dart))

You can turn this off in Settings, About, under “Help improve Pantas by sharing usage data.” Turning it off does not stop the study records needed to run the app. ([About page](lib/features/settings/presentation/pages/about_page.dart), [consent controls](lib/app/telemetry_consent_controller.dart), [study records](functions/src/ingestSession.ts))

**Why a guardian confirms**

When Pantas places you in the minor age group, its setup flow asks a parent or guardian to review the terms and confirm before you continue. Opening the email link does not confirm anything. The adult must check the agreement box and choose Confirm. They can choose “I Don’t Agree” instead. ([Guardian page](lib/features/guardian/presentation/guardian_confirm_page.dart), [guardian gate](lib/features/guardian/application/guardian_providers.dart))

The link works once and expires after seven days. Sending a new link closes the old one. Keep the link private because someone who has it can answer the request. ([Guardian server](functions/src/guardianConsent.ts))

**What your guardian can do**

Your guardian can confirm or decline the request. Confirmation does not create a guardian dashboard or give them a screen showing your results. You or your guardian can contact our data protection officer about your data. ([Guardian flow](lib/features/guardian/data/guardian_gateway.dart), [guardian page](lib/features/guardian/presentation/guardian_confirm_page.dart), [contact route](lib/features/settings/presentation/pages/about_page.dart))

**Where your data goes**

Some records stay in your browser or phone. On the web, answers and study activity also go to our servers, including on Free. Pro supports additional backup and syncing across devices. ([Local study records](lib/core/storage/data/tables/quiz_sessions_table.dart), [server study records](functions/src/ingestSession.ts), [sync controls](lib/core/sync/runtime/sync_runtime_controller.dart))

Pantas uses Google Firebase for account and server services. Guardian emails go through Resend. Web payments go through PayMongo. Optional usage reports use Firebase Analytics, with Crashlytics error reporting on the phone app. ([Account services](lib/core/auth/firebase_auth_gateway.dart), [guardian email](functions/src/guardianMail.ts), [payments](functions/src/paymongoClient.ts), [optional reporting](lib/core/telemetry/firebase_telemetry.dart))

**Your rights**

You have the right to know how your data is used. You can ask for a copy, including an electronic copy where the law allows. You can ask us to fix wrong details. You can ask us to stop using or delete data when the law allows. You can also complain to the National Privacy Commission and seek compensation where the law provides it. ([Data Privacy Act, Sections 16–18](https://privacy.gov.ph/data-privacy-act/))

Send these requests to dpo@pantas.study. We reply within 15 calendar days. Data export is handled through the data protection officer. There is no working export button in the app. ([Export function](functions/src/exportData.ts))

**Withdrawing permission or deleting data**

You can withdraw permission for data uses that rely on your consent. To withdraw guardian permission, contact dpo@pantas.study. The guardian link cannot undo a confirmation. There is no separate withdrawal button in the current app. [PLACEHOLDER: approved process and effect of withdrawing guardian permission]. ([NPC consent rules, Section 13](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf), [guardian actions](functions/src/guardianConsent.ts))

If you have finished setup, you can open Settings, Account, and choose the delete option. For a Google-linked account, deletion removes the account’s server data and data on the device making the request. You may need to sign in again first. Without a Google-linked account, the delete option clears local data only. If you are waiting for guardian confirmation, contact the data protection officer for help. ([Deletion flow](lib/app/routes/settings_account_deletion.dart), [account deletion](lib/core/auth/auth_repository.dart:104), [waiting-page restrictions](lib/app/router.dart:77))

Deletion does not remove every record held by every service. Pantas keeps a one-way code from your verified sign-in details to stop the same identity from getting another free trial. Some security and transaction records also remain outside the account data that deletion removes. ([Deletion function](functions/src/deleteAccount.ts), [trial-use codes](functions/src/webTrial.ts), [security logs](functions/src/purgeOldAuditLogs.ts))

**How long we keep data**

[PLACEHOLDER: approved periods or clear deletion rules for study data, guardian requests, payment records, security records, and trial-use codes. Explain what remains after account deletion.]

**Why the law allows these uses**

[PLACEHOLDER: lawyer-approved legal basis for each use of teen and guardian data, including age checks, study records, optional reporting, payments, and trial-use codes.]

**Payments for minors**

If you are under 18, ask your parent or guardian to complete a payment using their own payment method. Confirming your account does not make a payment or approve a future charge. The checkout screen shows a guardian reminder. It does not check who is paying. ([Guardian wording](lib/features/guardian/presentation/guardian_confirm_page.dart:161), [checkout reminder](lib/features/settings/presentation/pages/pro_page.dart:685), [checkout function](functions/src/paymongoCheckout.ts))

---

**2. TERMS WEB WORDING**

**Existing text it replaces**

**Subscriptions**

> Paid features depend on your active store subscription. Manage billing through the store account used for purchase.

([Existing Terms](lib/features/legal/domain/legal_document.dart:59))

**Replacement text**

**Subscriptions**

For purchases through an app store, paid features depend on your active store subscription. Manage billing through the store account used for purchase. ([Existing Terms](lib/features/legal/domain/legal_document.dart:59))

On the web, you buy prepaid Pantas Pro access through PayMongo. Weekly, Monthly, and Yearly plans provide Civil Service Pro access for a set period. A Season Pass covers the named exam through its stated exam sitting. Web purchases do not renew automatically. You must choose to buy again. ([Products](functions/src/products.json), [access rules](functions/src/paymongoGrants.ts), [launch decision](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:175))

Prices are shown in Philippine pesos on the Pro screen and at PayMongo checkout. Review the selected plan and amount before paying. The currently approved web payment methods are cards and QR Ph. ([Price display](functions/src/webPlans.ts), [checkout amount](functions/src/paymongoClient.ts), [payment-method decision](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2060))

Weekly access lasts seven days. Monthly access lasts one calendar month. Yearly access lasts one calendar year. Monthly and Yearly periods end on the same date and time in Philippine time. If that date does not exist, they end on the last day of that month. A new period starts at the recorded payment time or after existing qualifying Pro access ends. Season Passes end at the end of the last day of their recorded exam sitting. ([Period calculation](functions/src/paymongoPolicy.ts), [stacking rules](functions/src/paymongoGrants.ts:15), [Season Pass end](functions/src/revenuecatPasses.ts:33))

Pro access is added after Pantas verifies the payment with PayMongo. Returning from checkout does not by itself confirm that access is ready. If you paid and Pro has not appeared, contact support@pantas.study. ([Payment verification](functions/src/paymongoWebhook.ts), [checkout return](lib/features/paywall/data/web_payment_gateway.dart))

Eligible signed-in accounts can start a seven-day web trial. No payment details are needed to start it. The trial does not charge you or turn into a paid plan. It is available once per account and verified sign-in identity, for accounts that have never had Pro. Deleting an account does not reset a used trial. ([Trial function](functions/src/webTrial.ts), [trial length](functions/src/grants.ts), [trial display](lib/features/settings/presentation/pages/pro_page.dart:1041))

There is no automatic web renewal to cancel. To stop buying Pro, do not make another purchase. Leaving an unpaid checkout does not create Pro access. Deleting your account ends its access and does not itself request a refund. A web purchase does not cancel a separate app store subscription. Manage that subscription through the store. ([Checkout handling](lib/features/paywall/data/web_payment_gateway.dart), [account deletion](functions/src/deleteAccount.ts), [separate store-renewal checks](functions/src/webPlans.ts))

Under our web refund policy, you may request a full refund for an extra payment whose access period has not started, such as an unused duplicate payment, or for a payment that never unlocked Pro. We do not offer partial refunds for unused time. Activated or used access is outside this policy. Season Pass refund requests after the exam date are also outside this policy. These limits do not remove any refund, price reduction, or other remedy required by Philippine law. Send payment problems to support@pantas.study. ([Refund decisions](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:675), [Consumer Act, Article 102](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/3302))

When Pro access for an exam ends, its Pro-only features stop unless another active plan or pass covers it. You can keep using Free features. Ending Pro does not itself delete your progress. Pro backup and syncing stop while you do not have Pro. ([Access calculation](lib/features/paywall/domain/entitlement.dart), [expiry wording](lib/features/settings/presentation/pages/pro_page.dart:931), [sync controls](lib/core/sync/runtime/sync_runtime_controller.dart:117))

The November 9 to 15, 2026 beta is free. Its temporary beta Pro access ends at midnight at the start of November 16, Philippine time. Beta access does not start a paid plan. PayMongo is to remain in test mode during this beta. ([Beta decision](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2136), [beta cutoff](functions/src/betaPro.ts:13))

For a student under 18, a parent or guardian should complete the payment using their own payment method. Guardian account confirmation does not authorize a charge. ([Guardian page](lib/features/guardian/presentation/guardian_confirm_page.dart:161), [checkout flow](functions/src/paymongoCheckout.ts))

---

**3. FOR THE REVIEWER**

**This is a draft that needs a Philippine lawyer’s review before publication.** The findings below come from source review. They do not verify the deployed app, working inboxes, or a real checkout.

The requested launch log is absent from this worktree. Citations use the copy in the main checkout at `/Users/aedwon/Documents/Projects/Pantas/docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`.

**Laws and guidance**

“VERIFIED” means the relevant primary-source text was retrieved. It does not mean Pantas complies.

| Law or guidance | Status and relevance |
|---|---|
| RA 10173, Data Privacy Act | **VERIFIED.** Covers transparency, lawful processing, security, access, correction, deletion, portability, and complaints. Age and education information fall within its sensitive-information definition. Counsel must assess the study records accordingly. [NPC statutory text](https://privacy.gov.ph/data-privacy-act/) |
| NPC Advisory 2024-03, Child-Oriented Transparency | **VERIFIED.** Calls for child-friendly notices, child privacy impact assessments, appropriate privacy defaults, and risk-based decisions about age checks and guardian involvement. It does not establish a general Philippine “13 means independent consent” rule. [Signed advisory](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf) |
| NPC Circular 2023-04, Guidelines on Consent | **VERIFIED.** Relevant to specific, informed consent, evidence of consent, and withdrawal. Section 13 requires withdrawal to be as easy as giving consent. [Signed circular](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf) |
| RA 7394, Consumer Act | **VERIFIED.** Relevant to sales claims and service quality. Article 102 provides remedies that include reimbursement and proportionate price reduction. The owner’s refund policy must preserve mandatory remedies. [Supreme Court statutory text](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/3302) |
| RA 8792, Electronic Commerce Act | **VERIFIED.** Recognizes electronic contracts and records. It does not remove the other requirements for a valid contract. Relevant to checkbox acceptance and evidence of the terms accepted. [Supreme Court statutory text](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/3888) |
| RA 11967, Internet Transactions Act | **VERIFIED.** Relevant provisions cover digital-service performance, disclosures, receipts, remedies, and complaints. Section 3 excludes online media content. Counsel should determine how that exclusion applies to Pantas’s combination of content and interactive services. [Supreme Court statutory text](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96902) |
| RA 6809, age of majority | **VERIFIED.** Generally sets majority at 18. Counsel should settle the guardian’s contractual role and the treatment of unauthorized purchases by minors. [Supreme Court statutory text](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/7025) |
| Internet Transactions Act implementing rules | **UNVERIFIED in full.** DTI lists the issued rules, but retrieval of the signed PDF failed. Their detailed requirements still need review. [DTI official index](https://ecommerce.dti.gov.ph/related-laws-policy-issuance/) |

**App behavior, text gaps, and decisions needed**

1. **The teen page is not available yet.** `teenNoticeReady` is false. Its guardian link is hidden, and `/legal/teens` redirects to Privacy. Publication needs the approved document and corresponding routing changes. ([Notice flag](lib/features/guardian/domain/guardian_copy.dart:16), [redirect](lib/app/router.dart:73))

2. **The guardian page overstates payment enforcement.** It says the child cannot buy Pro and only the guardian can pay. The Pro page merely shows a reminder. The checkout function does not verify guardian approval or payer identity. The owner must choose whether to change that statement or enforce the restriction. ([Guardian claim](lib/features/guardian/presentation/guardian_confirm_page.dart:161), [reminder](lib/features/settings/presentation/pages/pro_page.dart:685), [checkout](functions/src/paymongoCheckout.ts))

3. **Guardian confirmation is an email-link response, not proof of guardianship.** The server rejects the student’s own email when it knows that email. It does not verify the responder’s age or legal authority. Counsel should approve the assurance level after assessing risk. ([Guardian server](functions/src/guardianConsent.ts))

4. **The age check cannot identify exact birthdays.** A child turning 13 later in the year can pass the minimum-year check. Someone already 18 can still need guardian confirmation. Age group and the underage block are stored locally. The log also accepts that students remain marked as minors after turning 18. The owner must decide how to handle corrections, birthdays, and fresh devices. ([Age calculation](lib/features/onboarding/domain/age_policy.dart:36), [local storage](lib/core/storage/data/repos/app_preferences_repository.dart), [accepted gap](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2395))

5. **The guardian requirement is not universal server enforcement.** Unknown age groups are treated as not requiring a guardian. Existing students can therefore bypass this new setup requirement. The reviewed study and payment functions do not check guardian status. Decide whether the notice describes a setup rule or an account-wide access requirement. ([Guardian gate](lib/features/guardian/application/guardian_providers.dart), [study function](functions/src/ingestSession.ts), [checkout](functions/src/paymongoCheckout.ts))

6. **Declining does not close the account or prevent another request.** The student remains waiting and can resend or change the email. There is no guardian withdrawal action after confirmation. Decide how refusal, withdrawal, disputes between guardians, and immediate access suspension should work. The email-only withdrawal route needs review against the NPC’s ease-of-withdrawal requirement. ([Waiting page](lib/features/guardian/presentation/guardian_waiting_page.dart), [server actions](functions/src/guardianConsent.ts), [NPC Section 13](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf))

7. **Consent evidence does not identify the document accepted.** The guardian record stores status and dates. It does not record a Terms or Privacy version, the exact wording shown, or a verified guardian identity. Student policy acceptance separately uses version `1`. Decide what evidence must be recorded and when renewed acceptance is needed. ([Guardian records](functions/src/guardianConsent.ts), [student acceptance](lib/features/settings/data/settings_repository.dart))

8. **The guardian email understates existing processing.** It says Pantas has only the age group and guardian contact. The flow already uses Firebase authentication, account IDs, request records, and send counters. The email wording needs reconciliation with the notice. ([Email text](functions/src/guardianMail.ts:45), [server records](functions/src/guardianConsent.ts))

9. **The existing Privacy Policy calls usage data anonymous.** Optional reporting can carry an account identifier and question-level answer information. Teens can enable reporting without a separate guardian reporting choice. Decide the lawful basis, required guardian involvement, and accurate description. ([Existing Privacy](lib/features/legal/domain/legal_document.dart), [identifiers](lib/core/telemetry/crash_reporting.dart), [answer reporting](lib/features/quiz/domain/use_cases/submit_answer.dart:60), [consent step](lib/features/onboarding/presentation/onboarding_consent_step.dart))

10. **“Free progress stays only in this browser” is too broad.** The Backup page says this, but server study records are collected on Free too. The notice distinguishes those records from Pro syncing. The app’s Backup wording needs the same distinction. ([Backup wording](lib/features/settings/presentation/pages/backup_page.dart), [server collection](functions/src/ingestSession.ts))

11. **Deletion is not complete erasure across all systems.** The account function preserves trial-use hashes and does not remove audit logs. Guardian cleanup deletes only the latest token record, so earlier revoked token records can remain. Provider-held records and copies on other devices are not erased by this function. Approve the exceptions, lawful bases, cleanup rules, and wording before promising that everything is deleted. ([Account deletion](functions/src/deleteAccount.ts), [guardian cleanup](functions/src/guardianConsent.ts), [audit cleanup](functions/src/purgeOldAuditLogs.ts))

12. **Anonymous and waiting students need a workable deletion route.** Anonymous deletion wipes local data only. Waiting students cannot reach Account settings. The server’s anonymous-account cleanup is conditional. The owner must establish a DPO process for deleting their server-side guardian and account records. ([Deletion routing](lib/app/routes/settings_account_deletion.dart), [waiting restriction](lib/app/router.dart:77), [anonymous cleanup](functions/src/cleanupOrphanAnons.ts))

13. **Trial-use codes are not safely described as “no personal data.”** The log uses that description. The code derives persistent keyed hashes from provider identities and sometimes verified emails. They recognize a returning identity after deletion. Counsel should assess them as potentially pseudonymous personal data and approve a storage period and legal basis. ([Log description](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:1870), [actual markers](functions/src/webTrial.ts:16))

14. **Beta Pro can remove later trial eligibility.** Trial eligibility requires an empty grant history. Enabling beta Pro creates a grant, even if later switched off. Decide whether beta testers should still qualify for the paid-launch trial. Beta configuration can also end access earlier than the fixed cutoff, and the function has no November 9 start check. ([Trial eligibility](functions/src/webTrial.ts:39), [beta grants](functions/src/betaPro.ts))

15. **Free beta billing depends on deployment configuration.** Checkout is not disabled by a beta check. Webhook mode follows the configured PayMongo key. Confirm test keys and payment methods in the actual deployment before publishing the beta statements. ([Checkout](functions/src/paymongoCheckout.ts), [webhook mode](functions/src/paymongoWebhook.ts:240))

16. **Refund eligibility requires a manual decision.** The code processes completed refunds and flags some payments for follow-up. It does not provide student refund requests or enforce the owner’s eligibility policy. Define whether “activated” means the scheduled start time or actual use. Approve the evidence required, request channel, processing steps, and timing. ([Payment handling](functions/src/paymongoGrants.ts), [refund decisions](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:695))

17. **The refund policy needs legal exceptions and one clarification.** An activated service can still have defects that give rise to mandatory remedies. Also, the code flags a pass paid after its sitting ended for refund, while the log generally excludes pass refunds after the exam date. Counsel and the owner must reconcile these cases. Admin partial refunds should remain distinct from the student policy. ([Late-payment and partial-refund handling](functions/src/paymongoGrants.ts), [refund log](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:660), [Consumer Act Article 102](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/3302))

18. **Price changes and delayed activation need rules.** Payment verification compares against the current product price. An older checkout may therefore fail verification after a price change. Access periods use PayMongo’s payment time, so a confirmation delay can consume part of the period before access appears. Decide how to preserve the agreed price and remedy lost access time. ([Price verification](functions/src/paymongoWebhook.ts), [period start](functions/src/paymongoGrants.ts))

19. **Pro expiry must not promise permanent storage.** Expiry stops Pro sync without itself deleting local progress. The launch log also approves automatic upload of some edits when Pro resumes. The owner must approve cloud storage rules after expiry and explain which records continue to reach the server on Free. ([Sync behavior](lib/core/sync/runtime/sync_runtime_controller.dart), [November 5 decision](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2544))

**Other information the owner or lawyer must supply**

- Confirm the proprietor’s full legal identity, business address, DPO email, support email, and any required telephone number. Existing email constants are present, but the legal implementation notes still require production approval. ([Contact constants](lib/features/legal/domain/legal_contact.dart), [launch requirements](docs/superpowers/specs/2026-05-23-legal-ra10173-implementation-notes.md))
- Approve the legal basis and storage rules for each data category. Complete the child privacy assessment. Confirm service-provider roles, processing locations, and safeguards. The code alone does not establish these legal arrangements. ([NPC child guidance](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf))
- Establish how the DPO verifies identity and guardian authority, supplies exports, handles corrections and withdrawal, and responds to complaints. The export function currently directs users to email. ([Export function](functions/src/exportData.ts))
- Confirm tax-inclusive price disclosures, invoices or receipts, refund handling, and the complaint process. Determine the applicable Internet Transactions Act classification and review its implementing rules. A PayMongo payment record should not be presented as proof that all merchant obligations are met. ([RA 11967, Sections 20, 23–24](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96902))
- Approve document dates, versions, acceptance requirements, and publication locations. The current legal page renders local fallback documents directly. Publishing different text elsewhere will not update that page. ([Legal renderer](lib/features/legal/presentation/legal_document_page.dart))
