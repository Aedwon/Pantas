# Teen notice and Terms web wording: draft

Draft of Nov 5, 2026, not published. The owner chose to proceed without a lawyer for now; no lawyer has reviewed this. Written to favor the business within lawful bounds. File links are relative to the repository root.

# Teen notice and Terms web wording: draft for review

Prepared November 5, 2026. Publication date: **November 9, 2026**, the beta start. Not published. No lawyer has reviewed this draft.

The storage periods below are choices made for this draft, except where a law or provider rule is identified. They are not claims that unfinished deletion processes already work. Owner notes identify the changes needed before publishing the corresponding commitments.

File links remain relative to the repository root. Application behavior was checked in `/Users/aedwon/Documents/Projects/Pantas-wt-vc-fixes-r1`, on `web/visual-check-fixes-r1`, because the main checkout does not contain the requested guardian and web-trial files. The guardian and account-deletion files match the staging worktree. Trial eligibility differs, as explained below. Source review does not verify deployment, working inboxes, or production settings.

The owner’s identity, address, contact details, and 15-calendar-day reply commitment follow `pantas-web/privacy.html`. That notice covers beta applications. Its application-storage periods do not govern app accounts.

---

**1. TEEN NOTICE**

**Notice for teens**

Updated November 9, 2026.

**Who this is for**

This notice is for teens ages 13 to 17 and their parents or guardians. Pantas currently sets 13 as its minimum age.

We ask for your birth year to check which age group applies. We keep the age group, not a saved birth-year record. If your birth year could mean you are still 17, we ask a guardian to confirm too. A birth-year check cannot establish your exact birthday. ([Age policy](lib/features/onboarding/domain/age_policy.dart), [age gate](lib/features/onboarding/presentation/onboarding_age_gate_step.dart))

Thirteen is Pantas’s access rule. It is not a Philippine rule that everyone aged 13 can independently consent to every use of personal data. ([NPC child guidance](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf))

**Who runs Pantas**

Pantas is operated by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services, a sole proprietorship. He is also the Data Protection Officer.

Business address: Poblacion, Norala, South Cotabato, Philippines.

For questions about your data, email **dpo@pantas.study**. For general help or payment problems, email **support@pantas.study**. ([Launch log, November 2](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2381), [legal contact launch requirements](docs/superpowers/specs/2026-05-23-legal-ra10173-implementation-notes.md), [contact constants](lib/features/legal/domain/legal_contact.dart))

**What we collect**

Pantas uses an account ID even before you sign in with Google. If you sign in with Google, Pantas receives account details such as your name, email, and profile photo. ([Sign-in gateway](lib/core/auth/firebase_auth_gateway.dart))

We keep your study settings, answers, results, and study times. We also keep lessons you bookmark and questions you flag. We use these records to run your study sessions, plan reviews, and show your progress. ([Settings](lib/features/settings/data/settings_repository.dart), [study sessions](functions/src/ingestSession.ts), [bookmarks](lib/core/storage/data/tables/lesson_bookmarks_local_table.dart), [flags](lib/core/storage/data/tables/question_flags_local_table.dart))

For guardian confirmation, we ask for your guardian’s name and email. We send them an email link. Our server keeps the request status, dates, a partly hidden email address, and keyed codes for the email and link. These codes protect the original values, but they are not necessarily anonymous.

The full guardian name and email also stay on your device so you can resend the request. They are cleared from that device when Pantas checks a successful confirmation. ([Guardian server](functions/src/guardianConsent.ts), [guardian controller](lib/features/guardian/application/guardian_providers.dart))

If someone buys Pro for your account, we keep payment references, the amount paid, refund records, and access dates. Web payment details are entered on PayMongo’s checkout page. ([PayMongo checkout](functions/src/paymongoClient.ts), [payment records](functions/src/paymongoGrants.ts))

**Optional usage sharing**

You can choose whether to share extra usage data to help improve Pantas. This starts off.

If you turn it on, reports can include which screens you use, question IDs, your answer choices, and whether those choices were correct. Reports can be linked to your account ID. The phone app also supports error reports. These reports should not be described as anonymous. ([Consent settings](lib/features/settings/data/settings_repository.dart), [answer reports](lib/features/quiz/domain/use_cases/submit_answer.dart:60), [reporting](lib/core/telemetry/firebase_telemetry.dart), [account identifiers](lib/core/telemetry/crash_reporting.dart))

You can turn sharing off in Settings, About, under “Help improve Pantas by sharing usage data.” Turning it off does not stop the study records needed to run the app. You can also email dpo@pantas.study about reports already collected. ([About page](lib/features/settings/presentation/pages/about_page.dart), [consent controls](lib/app/telemetry_consent_controller.dart), [study records](functions/src/ingestSession.ts))

**Owner note:** For minors, keep optional reporting disabled until the necessary separate, informed consent can be obtained and recorded. General guardian confirmation must not silently authorize optional answer-level reporting.

**Why a guardian confirms**

When Pantas places you in the minor age group, its setup flow asks a parent or guardian to review the terms and confirm before you continue.

Opening the email link does not confirm anything. The adult must check the agreement box and choose Confirm. They can choose “I Don’t Agree” instead. ([Guardian page](lib/features/guardian/presentation/guardian_confirm_page.dart), [guardian gate](lib/features/guardian/application/guardian_providers.dart))

The link works once and expires after seven days. Sending a new link closes the old one. Keep the link private because someone who has it can answer the request. ([Guardian server](functions/src/guardianConsent.ts))

This is an email confirmation process. It does not independently prove the responder’s age or legal authority.

**What your guardian can do**

Your guardian can confirm or decline the request. Confirmation does not create a guardian dashboard or give them a screen showing your results.

You or your guardian can contact our Data Protection Officer about your data. We check a representative’s authority before disclosing private information or acting on their instructions. Your privacy rights still belong to you. ([Guardian flow](lib/features/guardian/data/guardian_gateway.dart), [guardian page](lib/features/guardian/presentation/guardian_confirm_page.dart), [contact route](lib/features/settings/presentation/pages/about_page.dart))

**Where your data goes**

Some records stay in your browser or phone. On the web, answers and study activity also go to our servers, including on Free. Pro supports additional backup and syncing across devices. ([Local study records](lib/core/storage/data/tables/quiz_sessions_table.dart), [server study records](functions/src/ingestSession.ts), [sync controls](lib/core/sync/runtime/sync_runtime_controller.dart))

Pantas uses Google Firebase for account and server services. Guardian emails go through Resend. Web payments go through PayMongo. Optional usage reports use Firebase Analytics, with Crashlytics error reporting on the phone app. ([Account services](lib/core/auth/firebase_auth_gateway.dart), [guardian email](functions/src/guardianMail.ts), [payments](functions/src/paymongoClient.ts), [optional reporting](lib/core/telemetry/firebase_telemetry.dart))

These providers may process information outside the Philippines. Pantas remains responsible for the information it entrusts to service providers. A server’s location does not establish where every provider record or recovery copy is kept. ([Data Privacy Act, Section 21](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/50253))

**Your rights**

You have the right to know how your data is used. You can ask for a copy, including an electronic copy where the law allows. You can ask us to fix wrong details. You can object to processing and ask us to stop using, block, or delete data when the law allows. You can also complain to the National Privacy Commission and seek compensation where the law provides it. ([Data Privacy Act, Sections 16–18](https://privacy.gov.ph/data-privacy-act/))

Send these requests to **dpo@pantas.study**. We reply within **15 calendar days**. Our reply may explain necessary identity checks, progress, or a justified limitation. This is a reply commitment, not a promise that every request will be completed within that period.

Data export is handled through the Data Protection Officer. There is no working export button in the app. ([Export function](functions/src/exportData.ts))

**Withdrawing permission or deleting data**

You can withdraw permission for data uses that rely on consent.

A guardian can withdraw permission for the child’s account by emailing **dpo@pantas.study**. A simple message is enough:

> I withdraw my permission for my child to use Pantas. Please stop the account’s consent-based processing.

If possible, send it from the email address used for confirmation. Include the child’s sign-in email or account ID if you know it. If you do not know those details, tell us and we will help locate the request. You do not need the old confirmation link, a Pantas login, a paid plan, or a special form.

We do not charge for withdrawal. We ask only for information reasonably needed to locate the account and check your authority. Do not send an identification document unless we explain why it is necessary.

After reasonably verifying the request, we stop the processing that depends on the withdrawn permission without undue delay. Withdrawing permission for the core study service means we must close the child’s account and remove its study data, unless a separate lawful reason requires specific records to remain. Withdrawing only optional usage sharing does not close the account.

Withdrawal does not undo processing that was lawful before withdrawal. It does not automatically request a refund or cancel a separate app store subscription. Any refund or other remedy required by law remains available.

We reply within **15 calendar days**. We do not treat that period as permission to continue consent-based processing unnecessarily.

The guardian link cannot undo a confirmation. There is no separate withdrawal button in the current app. The email route requires manual action by the owner. ([NPC consent rules, Section 13](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf), [guardian actions](functions/src/guardianConsent.ts))

If you have finished setup, you can open Settings, Account, and choose the delete option. For a Google-linked account, the deletion process removes the account’s server study data and clears local user data on the device making the request. You may need to sign in again first.

Without a Google-linked account, the delete option clears local data only. If you are waiting for guardian confirmation, or need server records removed from an anonymous account, contact dpo@pantas.study. ([Deletion flow](lib/app/routes/settings_account_deletion.dart), [account deletion](lib/core/auth/auth_repository.dart:104), [waiting-page restrictions](lib/app/router.dart:77))

Account deletion does not erase every record held by every service. Trial-use codes, security records, and records required for tax or a specific legal claim can have separate storage rules. Copies on other devices also require separate attention. ([Deletion function](functions/src/deleteAccount.ts), [trial-use codes](functions/src/webTrial.ts), [security logs](functions/src/purgeOldAuditLogs.ts))

**Owner process for withdrawal, available without a new app feature**

1. Monitor the DPO inbox. Accept plain-language requests without requiring the student to enter Account settings.
2. Match the request to the account and guardian record. Use the original correspondence and only necessary additional checks. Possession of an email address alone does not settle a genuine guardianship dispute.
3. For withdrawal of core permission, use authorized Firebase administrative access to disable the account and revoke sessions while completing deletion. These steps do not remotely erase local data or guarantee that every existing session stops instantly.
4. Perform administrative deletion across the same account-data locations covered by the account-deletion function. Also find older guardian token records by account ID, handle anonymous accounts, and request provider-side deletion where applicable. Preserve only justified exceptions.
5. Tell the requester what was stopped, what was deleted, what remains, its legal basis, and its deletion date. Give instructions for clearing copies on their devices.
6. Keep the minimum evidence of the request and action. If the student is now an adult, establish their current instructions and the former guardian’s authority before acting.

Do not merely change `confirmed` to `declined`: the current server functions do not consistently enforce guardian status, and the device can remember a prior confirmation. The current decline flow also permits another request. ([Guardian controller](lib/features/guardian/application/guardian_providers.dart), [waiting page](lib/features/guardian/presentation/guardian_waiting_page.dart), [anonymous cleanup](functions/src/cleanupOrphanAnons.ts))

**Withdrawal interface change needed:** Add a withdrawal action to the guardian web interface, with effort comparable to giving confirmation. It must remain accessible after the original link expires and must not require the child’s login. Section 13 favors using the same service interface and permits manual handling, but email-only handling should not be represented as established compliance with its ease-of-withdrawal requirement.

**How long we keep data**

The following schedule sets when records become due for deletion. Earlier deletion applies when consent is withdrawn and no other lawful basis permits keeping them.

Except for the tax rule and identified provider rules, these are Pantas’s chosen limits. They are not statutory minimums or permission to keep unnecessary information.

| Category | Storage period and reason |
|---|---|
| **Study data and account settings** | Keep while the account is being used. Make server study data due for deletion after **24 consecutive months without user-initiated app activity**, or earlier when the account is deleted or core consent is withdrawn. This supports study across exam cycles while limiting abandoned-account storage. Pro expiry alone does not start deletion. Local copies remain until cleared through the app, browser, or device; server deletion cannot erase an offline device. |
| **Guardian requests and confirmation links** | An unanswered request and its contact-linked records become due for deletion when its **seven-day response window ends**. Used, declined, or replaced link records become due for deletion **seven days after that event**. These brief periods allow delivery troubleshooting and response checks. Keep minimum confirmation evidence while permission is relied on, then for **730 days after the last processing covered by that permission**, solely to demonstrate and resolve questions about permission. Do not retain study answers as consent evidence. |
| **Payment and accounting records** | Keep necessary books, invoices, receipts, refund records, and supporting transaction records for **five years**, counted from the day after the applicable return-filing deadline, or from the actual filing date if filed late, for the taxable year when the last entry was made in the books. Keep relevant records longer where a pending tax protest, tax-credit or refund claim, or another applicable legal duty requires it. This is the tax-preservation rule, not five years from the purchase date. Unpaid checkout coordination records become due for deletion **30 days after the checkout is confirmed closed or expired**, unless needed for a documented payment dispute. |
| **Security records** | Account and payment audit records become due for deletion **730 days after the event**. This supports investigation of account access, deletion, payment verification, and recurring abuse without keeping a permanent activity history. Ordinary rate-limit counters become due **seven days after their enforcement window ends**. Payment-event duplicate-detection records become due after **30 days**. Keep additional incident evidence only under a documented legal or investigation need. |
| **Trial-use codes** | Keep the keyed identity code and minimum trial-use fact for **730 days from the first trial grant**, including after account deletion. Do not restart that period when the person signs in, is recognized again, or deletes an account. This provides a bounded repeat-trial check across exam cycles without keeping a lifelong identity marker. Delete earlier if the trial program permanently ends and the code has no remaining justified purpose. |
| **Optional usage and error reports** | Set identifiable Analytics user and event data to **two calendar months**, with identifier renewal on new activity turned off. Google performs expiry cleanup monthly. Crashlytics keeps crash data and associated identifiers for **90 days before beginning removal** from live and backup systems. These periods support recent usage analysis and fault diagnosis. A valid deletion request can require earlier action. Aggregate reports are outside these limits only where they no longer identify a person. |

The payment period follows **Tax Code Section 235, as amended by RA 11976 Section 33**, and **BIR Revenue Regulations 7-2024, Section 4**. The regulation includes invoices, receipts, vouchers, returns, and other supporting source documents. Account deletion does not remove this duty. ([RA 11976](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96948), [BIR RR 7-2024](https://bir-cdn.bir.gov.ph/BIR/pdf/RR%20No.%207-%202024.pdf))

The optional-reporting periods require the stated configuration. They are not verified production settings. Google distinguishes identifiable data from standard aggregate reports. ([Analytics storage controls](https://support.google.com/analytics/answer/7667196?hl=en), [Firebase processing and deletion information](https://firebase.google.com/support/privacy))

A specific legal obligation or the establishment, exercise, or defense of a legal claim can justify keeping relevant records longer. This does not justify keeping the whole account indefinitely. Record the reason, restrict access, review the need, and delete when it ends. ([NPC guidance on Section 13(f)](https://privacy.gov.ph/wp-content/uploads/2024/08/NPC-Advisory-No.-2024-02-Personal-Data-Processing-Based-on-Section-13-f.pdf))

Provider recovery copies can take longer to disappear. For example, Firebase states that authentication data is removed from live and backup systems within 180 days after the customer initiates user deletion. That is not a general 180-day storage period for every Pantas record. Pantas must also apply deletion instructions to processors and prevent restored copies from becoming active again.

**Changes needed to implement this schedule**

- **Study data:** There is no general 24-month inactivity purge in the reviewed code. Add a reliable user-activity date and cleanup process covering server study records, derived records, and Pro backups. The existing anonymous cleanup uses a conditional 30-day rule and skips some accounts. It does not implement this schedule. ([Study ingestion](functions/src/ingestSession.ts), [anonymous cleanup](functions/src/cleanupOrphanAnons.ts))

- **Guardian data:** Link expiry currently changes whether a link works; it does not delete the records. There is no complete scheduled cleanup for expired requests, old tokens, or guardian send counters. Account deletion removes only the latest referenced token. Add cleanup for all relevant tokens and counters, local contact expiry, and a separate minimum consent-evidence record. The current account deletion would otherwise erase that evidence with the account. ([Guardian records and cleanup](functions/src/guardianConsent.ts))

- **Payment data:** The current deletion function deletes the account’s grant ledger and account-linked PayMongo payment, order, checkout, and follow-up records. It does not first preserve a verified statutory accounting archive. Establish that archive before deleting accounting source records. Keep only necessary purchaser and transaction details there, with restricted access and the correct filing-based expiry. A PayMongo dashboard is not, by itself, proof that Pantas has met its bookkeeping duties. ([Account deletion](functions/src/deleteAccount.ts), [payment ledger](functions/src/paymongoGrants.ts))

- **Security data:** The audit job already deletes `audit_logs` older than 730 days in daily batches. Confirm deployment and successful runs. It does not establish deletion for every operational log, counter, or other security collection. Configure those separately. Payment-event records have 30-day expiry fields, but the presence of a field does not prove the corresponding database expiry policy is enabled. ([Audit cleanup](functions/src/purgeOldAuditLogs.ts), [payment events](functions/src/paymongoGrants.ts))

- **Other deletion markers:** Account deletion also creates public-ID retirement records. Remove the account-linked owner hash **30 days after successful deletion**, once the deletion-race protection is no longer needed. Retain a bare number reservation only if needed to prevent reassignment, and do not call it anonymous unless its remaining links have actually been removed. ([Public-ID retirement](functions/src/publicId.ts))

- **Trial-use codes:** Current identity markers contain `used: true`, have no expiry, and deliberately survive account deletion. Add an original-use date, a fixed expiry, and cleanup. The deletion routine must preserve an existing date instead of restarting it. Backfill dates from reliable trial or audit records; do not invent dates for older markers. Delete unneeded markers whose age cannot be established. These are pseudonymous records, despite the earlier description of them as containing no personal data. ([Earlier description](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:1870), [actual markers](functions/src/webTrial.ts:16))

- **Optional reporting and correspondence:** Verify the Analytics settings, provider deletion routes, and any exported copies. Delete ordinary support and privacy correspondence **90 days after resolution**, except for the minimum consent evidence or records subject to a documented legal hold.

Until these controls exist, the current code can keep some records beyond this schedule and delete some accounting records too soon. This draft must not be published as evidence that those gaps have already been fixed.

**Why the law allows these uses**

Philippine law treats information about age and education as sensitive personal information. Pantas should therefore treat age groups and identifiable learning results cautiously, even where they are not formal school records. Keeping only an age group or a keyed identity code does not automatically remove privacy protection. ([Data Privacy Act, Section 3](https://privacy.gov.ph/data-privacy-act/))

For ordinary personal information, Section 12 provides grounds including contract, legal obligation, legitimate interest, and consent. Sensitive information needs an applicable Section 13 exception. A contract or a legitimate business interest alone does not supply that exception. ([Data Privacy Act, Sections 12–13](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/50253), [NPC legitimate-interest rules](https://privacy.gov.ph/wp-content/uploads/2024/01/NPC-Circular-No.-2023-07_Guidelines-on-Legitimate-Interest_13-December-2023.pdf))

The following are the bases selected for this draft. They require the corresponding safeguards and valid consent where specified.

| Use | Legal basis and limit |
|---|---|
| **Age checks** | **Specific prior consent under Section 13(a)** for age information, with Section 12(a) covering associated ordinary information. Obtain consent from a lawful representative where required. Checking age is Pantas’s safeguard, not a general legal obligation requiring this particular birth-year collection. |
| **Study records and account operation** | **Contract under Section 12(b)** for ordinary information necessary to provide the requested service. **Specific consent under Section 13(a)** for identifiable education information. Guardian authorization must cover the necessary study uses for a minor. |
| **Optional usage and error reporting** | **Consent under Section 12(a)**, plus **Section 13(a)** where reports reveal age, answers, or learning performance. Keep this choice separate from core service permission. Refusal must not remove Free or purchased study access. |
| **Payments** | **Contract under Section 12(b)** for the adult purchaser’s necessary transaction information. **Legal obligation under Section 12(c)** for required accounting records. **Section 13(b)** applies only to sensitive information whose processing is actually authorized by the relevant law or regulation with its required safeguards. Child-linked study or access information still needs its own Section 13 basis. |
| **Trial-use codes** | **Legitimate interest under Section 12(f)** can support a strictly limited ordinary identity marker used to prevent repeat trials, subject to a documented assessment. Because a teen-linked marker may also reveal use of an educational service, this draft requires **specific Section 13(a) consent** for that potentially sensitive context. If that consent is withdrawn, remove the sensitive marker unless a separate Section 13 exception actually applies. |
| **Guardian data** | **Legitimate interest under Section 12(f)** for a minimal invitation to the adult contact supplied by the student, subject to necessity and balancing. **Consent under Section 12(a)** for the guardian’s confirmation response. The linked child age and study information requires **Section 13(a)** authorization; the adult-contact basis does not authorize all child processing. |
| **Security and compliance evidence** | **Section 12(f)** for necessary ordinary security records, and **Section 12(c)** where a specific legal duty requires processing. Sensitive evidence needs a corresponding Section 13 exception, such as **Section 13(b)** for an applicable regulatory duty or **Section 13(f)** for necessary legal-claim evidence. Security is not a blanket exception. |

A legitimate-interest assessment must document the purpose, necessity, less intrusive alternatives, and balance against the person’s rights. Children’s interests require particular care. This assessment has not been established merely by choosing that basis in a notice. ([NPC Circular 2023-07](https://privacy.gov.ph/wp-content/uploads/2024/01/NPC-Circular-No.-2023-07_Guidelines-on-Legitimate-Interest_13-December-2023.pdf))

Minimum consent evidence may be kept to meet the obligation to demonstrate permission. Any sensitive portion retained under Section 13(b) must actually fall within the applicable regulatory requirement and safeguards. Section 13(f) can support necessary evidence for establishing or defending a legal claim, but not a general archive kept because a dispute is theoretically possible. ([NPC consent rules, Section 12](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf), [NPC legal-claims guidance](https://privacy.gov.ph/wp-content/uploads/2024/08/NPC-Advisory-No.-2024-02-Personal-Data-Processing-Based-on-Section-13-f.pdf))

**Owner note on consent:** A privacy notice does not itself obtain consent. The existing general acceptance and guardian checkbox do not yet demonstrate all the purpose-specific permissions described here. The current flow processes the birth year before guardian confirmation and permits a teen to enable reporting without a separate guardian reporting choice. Resolve prior authorization for the age check, separate optional reporting consent, and record the notice version, purposes, time, and affirmative action. Do not describe later confirmation as retroactively authorizing earlier processing. ([Student acceptance](lib/features/settings/data/settings_repository.dart), [consent step](lib/features/onboarding/presentation/onboarding_consent_step.dart), [guardian evidence](functions/src/guardianConsent.ts))

**Payments for minors**

If you are under 18, ask your parent or guardian to complete a payment using their own payment method.

Confirming your account does not make a payment or approve a future charge. The checkout screen shows a guardian reminder. It does not check who is paying. ([Guardian wording](lib/features/guardian/presentation/guardian_confirm_page.dart:161), [checkout reminder](lib/features/settings/presentation/pages/pro_page.dart:685), [checkout function](functions/src/paymongoCheckout.ts))

---

**2. TERMS WEB WORDING**

Publication date: November 9, 2026.

**Existing text it replaces**

**Subscriptions**

> Paid features depend on your active store subscription. Manage billing through the store account used for purchase.

([Existing Terms](lib/features/legal/domain/legal_document.dart:59))

**Replacement text**

**Subscriptions**

For purchases through an app store, paid features depend on your active store subscription. Manage billing through the store account used for purchase. ([Existing Terms](lib/features/legal/domain/legal_document.dart:59))

On the web, you buy prepaid Pantas Pro access through PayMongo. Weekly, Monthly, and Yearly plans provide Civil Service Pro access for a set period. A Season Pass covers the named exam through its stated exam sitting.

Web purchases do not renew automatically. You must choose to buy again. ([Products](functions/src/products.json), [access rules](functions/src/paymongoGrants.ts), [launch decision](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:175))

Prices are shown in Philippine pesos on the Pro screen and at PayMongo checkout. Review the selected plan and amount before paying. The currently approved web payment methods are cards and QR Ph. ([Price display](functions/src/webPlans.ts), [checkout amount](functions/src/paymongoClient.ts), [payment-method decision](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2060))

Weekly access lasts seven days. Monthly access lasts one calendar month. Yearly access lasts one calendar year. Monthly and Yearly periods end on the corresponding calendar date at the same time in Philippine time. If that date does not exist, they end on the last day of that month.

A new period starts at the recorded payment time or after existing qualifying Pro access ends. Season Passes end at the end of the last day of their recorded exam sitting. ([Period calculation](functions/src/paymongoPolicy.ts), [stacking rules](functions/src/paymongoGrants.ts:15), [Season Pass end](functions/src/revenuecatPasses.ts:33))

Pro access is added after Pantas verifies the payment with PayMongo. Returning from checkout does not by itself confirm that access is ready. If you paid and Pro has not appeared, contact support@pantas.study. ([Payment verification](functions/src/paymongoWebhook.ts), [checkout return](lib/features/paywall/data/web_payment_gateway.dart))

Eligible signed-in accounts can start a seven-day web trial. No payment details are needed to start it. The trial does not charge you or turn into a paid plan.

The trial is limited to one per account and verified sign-in identity. Prior paid Pro, a subscription, a pass, or another qualifying grant can make an account ineligible. Temporary beta Pro alone does not use up the later trial.

Deleting an account does not entitle you to another trial or immediately remove its trial-use code. The teen notice explains the code’s storage period. ([Trial function](functions/src/webTrial.ts), [trial length](functions/src/grants.ts), [trial display](lib/features/settings/presentation/pages/pro_page.dart:1041))

There is no automatic web renewal to cancel. To stop buying Pro, do not make another purchase. Leaving an unpaid checkout does not create Pro access.

Deleting your account ends its access and does not itself request a refund. A web purchase does not cancel a separate app store subscription. Manage that subscription through the store. ([Checkout handling](lib/features/paywall/data/web_payment_gateway.dart), [account deletion](functions/src/deleteAccount.ts), [separate store-renewal checks](functions/src/webPlans.ts))

Under our voluntary web refund policy, you may request a full refund for an extra payment whose access period has not started, such as an unused duplicate payment, or for a payment that never unlocked Pro.

We do not offer partial refunds merely because you choose not to use the remaining time. Access whose period has started or has been used is outside this voluntary policy. Season Pass requests made after the exam date are also outside the voluntary policy.

These limits do not remove any refund, reperformance, price reduction, compensation, or other remedy required by Philippine law. They do not exclude a remedy for defective service or a payment for access Pantas could not provide. Send payment problems to support@pantas.study. ([Refund decisions](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:675), [Consumer Act, Article 102](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/3302))

When Pro access for an exam ends, its Pro-only features stop unless another active plan or pass covers it. You can keep using Free features.

Ending Pro does not itself delete your progress. Pro backup and syncing stop while you do not have Pro. Necessary server study records can still be collected on Free. Data remains subject to the storage rules in the privacy notice. ([Access calculation](lib/features/paywall/domain/entitlement.dart), [expiry wording](lib/features/settings/presentation/pages/pro_page.dart:931), [sync controls](lib/core/sync/runtime/sync_runtime_controller.dart:117))

The November 9 to 15, 2026 beta is free. Its temporary beta Pro access ends at midnight at the start of November 16, Philippine time. Beta access does not start a paid plan. ([Beta decision](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2136), [beta cutoff](functions/src/betaPro.ts:13))

For a student under 18, a parent or guardian should complete the payment using their own payment method. Guardian account confirmation does not authorize a charge. Checkout does not verify the payer’s age or guardianship. ([Guardian page](lib/features/guardian/presentation/guardian_confirm_page.dart:161), [checkout flow](functions/src/paymongoCheckout.ts))

**Use of the app and limits of responsibility**

Pantas is a study tool. It does not guarantee a passing result, admission, employment, a license, or any particular score. Check official exam instructions, eligibility requirements, schedules, and announcements.

Pantas does not promise uninterrupted or error-free operation. This does not remove its duty to provide services with the quality and care required by law.

For an ordinary contractual breach committed in good faith, recoverable damages follow Philippine law, including its rules on causation, proof, and reasonably foreseeable loss. Pantas does not accept responsibility for losses that the law does not attribute to its acts or omissions.

Nothing in these terms excludes or limits responsibility for fraud, bad faith, willful misconduct, gross negligence, or any liability that cannot lawfully be excluded or limited. Mandatory service-quality remedies, privacy rights, statutory damages, and complaint rights remain available. ([Civil Code, Articles 1170–1174 and 2199–2201](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/53360), [Consumer Act, Articles 102 and 105–106](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/3302))

**Owner note:** This wording uses legal limits on recoverable loss. It does not impose a zero-liability rule for Free users or a blanket cap equal to fees paid. Consumer Act Articles 105–106 restrict contractual attempts to avoid or reduce liability for covered service defects.

**Related app wording replacements**

**Guardian confirmation page**

File: [lib/features/guardian/presentation/guardian_confirm_page.dart](lib/features/guardian/presentation/guardian_confirm_page.dart)

Current displayed text:

> Pantas keeps your child's answers and study progress to run the app. Your child can't buy Pro. Only you can, from your own payment method.

Replace with:

> Pantas keeps your child's answers and study progress to run the app. If your child wants Pro, they should ask a parent or guardian to pay using their own payment method. Confirming here does not authorize a charge. Checkout does not check who is paying.

The existing checkout reminder can remain:

> Ask your parent or guardian to complete this payment

It is a request, not an enforced payment restriction. ([Reminder](lib/features/settings/presentation/pages/pro_page.dart:685), [checkout](functions/src/paymongoCheckout.ts))

**Backup page**

File: [lib/features/settings/presentation/pages/backup_page.dart](lib/features/settings/presentation/pages/backup_page.dart)

Current displayed Free text:

> Your progress stays in this browser only. With Pro, it's backed up and syncs across your devices.

Replace with:

> Your browser saves data on this device. Pantas also keeps answers and study activity on its servers, including on Free. Pro adds backup and syncing across your devices.

This distinguishes server study processing from the additional Pro backup service. ([Server collection](functions/src/ingestSession.ts), [sync controls](lib/core/sync/runtime/sync_runtime_controller.dart))

**App behavior, text gaps, and changes needed before publication**

- **Publish the actual documents.** `teenNoticeReady` is false, the guardian link is hidden, and `/legal/teens` redirects to Privacy. The current legal renderer uses the short local fallback documents. Update the rendered documents and their versions together. Correct the fallback’s description of optional usage data as anonymous. ([Notice flag](lib/features/guardian/domain/guardian_copy.dart:16), [redirect](lib/app/router.dart:73), [fallback text](lib/features/legal/domain/legal_document.dart), [legal renderer](lib/features/legal/presentation/legal_document_page.dart))

- **Complete the consent flow and evidence.** Record the specific information shown and the action taken. The current guardian record lacks a document version and distinct optional-reporting permission. Existing students with an unknown age group are not universally blocked, and study and checkout functions do not consistently enforce guardian status. A published notice cannot repair those controls by itself. ([Guardian gate](lib/features/guardian/application/guardian_providers.dart), [guardian records](functions/src/guardianConsent.ts), [study function](functions/src/ingestSession.ts))

- **Correct the guardian email.** It currently says, “So far we have only their age group, and your name and email.” Authentication IDs, request records, and send counters already exist. Remove the word “only” and describe the account and confirmation records accurately. ([Email text](functions/src/guardianMail.ts:45))

- **Handle age corrections and adulthood.** Birth-year checks can admit someone who has not yet turned 13 and can classify someone already 18 as a minor. The group and block are local. The accepted birthday limitation does not justify continuing to treat an adult’s former guardian as having authority. Provide a DPO correction route and an appropriate transition to the student’s own consent. ([Age calculation](lib/features/onboarding/domain/age_policy.dart:36), [local storage](lib/core/storage/data/repos/app_preferences_repository.dart), [accepted gap](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2395))

- **Carry the beta-trial fix into the release candidate.** The reviewed fixes worktree excludes beta-only grants from trial disqualification. The staging trial file differs. Verify the selected release revision rather than repeating the earlier finding that beta always consumes the trial. The two-year marker purge also means permanent technical detection of every returning identity must not be promised. ([Eligibility implementation](functions/src/webTrial.ts:39), [beta grants](functions/src/betaPro.ts))

- **Verify free beta billing.** PayMongo must remain in test mode during the free beta. Checkout has no general beta prohibition, and beta access can end earlier if its configuration does. Confirm the deployed keys, methods, and beta cutoff before publishing the beta statements. ([Webhook mode](functions/src/paymongoWebhook.ts:240), [beta controls](functions/src/betaPro.ts))

- **Operate refunds manually and preserve required remedies.** The code handles payment and refund events, but it does not decide every customer request. For the voluntary policy, treat “started” as the recorded access-period start and “used” as actual use. Neither excludes a mandatory remedy. Reconcile late-paid passes that could not provide access, verify duplicate payments, and preserve the price agreed at checkout. Current verification against the current product price can cause problems after a price change. Payment-confirmation delays also need a remedy where they deprive the buyer of promised access. ([Refund scope](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:695), [partial-refund handling](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:660), [payment handling](functions/src/paymongoGrants.ts), [verification](functions/src/paymongoWebhook.ts))

- **Explain Pro lapse accurately.** Expiry stops Pro syncing without itself deleting progress. Some edits made while Pro is inactive can upload automatically when Pro resumes, depending on their account and sync state. Do not promise that all such edits remain permanently local. ([Sync behavior](lib/core/sync/runtime/sync_runtime_controller.dart), [November 5 decision](docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2544))

**Laws and guidance**

The primary sources support the statutory distinctions used above. They do not establish that the deployed app complies.

Electronic acceptance can have legal effect, but it does not remove contractual-capacity or evidence requirements. Philippine majority generally begins at 18. Guardian confirmation must not be presented as proof that every later purchase by the child is authorized. ([Electronic Commerce Act](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/3888), [RA 6809](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/7025))

The Internet Transactions Act addresses applicable online transaction disclosures, performance, receipts, remedies, and complaints. Its Section 3 excludes online media content. Pantas should not assume that this excludes its entire interactive service. The implementing rules were not verified in full for this draft. ([Internet Transactions Act](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96902), [DTI official index](https://ecommerce.dti.gov.ph/related-laws-policy-issuance/))

**Other information the owner must establish**

Confirm that the published business identity and contact details are accurate and that both inboxes are monitored. Establish a working procedure for access, export, correction, withdrawal, deletion, and complaints. Confirm processor agreements, overseas processing safeguards, recovery-copy handling, tax registration, and lawful invoicing before the corresponding processing or paid sales begin.

---

**3. RISKS THE OWNER IS ACCEPTING WITHOUT A LAWYER**

1. **Sensitive child data may be processed without adequate prior consent or proof.** Age checks occur before guardian confirmation, the guardian’s authority is not independently verified, and optional reporting lacks a separate guardian choice. Close this by documenting the child-risk assessment, obtaining valid purpose-specific authorization before affected processing, and recording sufficient evidence.

2. **There is no NPC registration, and the child privacy assessment is unsigned.** A small sole proprietorship is not automatically exempt. Risky processing and automated profiling can trigger registration requirements independently of headcount. Close this by resolving and completing required DPO and processing-system registration, completing and signing off the assessment, and implementing its safeguards before teen launch. ([NPC registration rules](https://privacy.gov.ph/wp-content/uploads/2023/05/Circular-2022-04.pdf), [child privacy guidance](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf))

3. **Withdrawal and storage commitments exceed current controls.** Email requires reliable manual action; some records remain indefinitely, while accounting records can be erased too soon. Close this with the DPO procedure, a comparable guardian withdrawal interface, complete deletion coverage, scheduled cleanup, and a protected statutory accounting archive.

4. **Minor purchases, refunds, and online-sales duties remain legally consequential.** Checkout does not verify the payer, and a strict voluntary refund policy cannot override mandatory remedies. Close this with accurate disclosures, tested payment and refund procedures, compliant invoices, and focused Philippine legal review when affordable.

5. **Provider handling and contractual enforceability remain partly unverified.** Source code cannot prove processor safeguards, recovery-copy deletion, or that a court will enforce particular terms. Close this with provider and configuration records, end-to-end privacy-request checks, and later professional review. These terms do not remove the proprietor’s liabilities imposed by law.
