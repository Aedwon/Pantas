# Legal texts R1, draft v1

Policy commit read: origin/main d8eab55e4 (AGENTS.md, WORKFLOW.md, SUBAGENTS.md). Source read from origin/web/design-system-4 (ds4). No app code touched, nothing committed.

**Not a lawyer's work.** I am not a lawyer and no lawyer reviewed this. Statute and article numbers marked "(unverified)" came from memory or from the brief and were not confirmed against an official text in this pass. Web fetches of ITA commentary were blocked (403), so ITA section numbers are unverified. Confirmed by search: NPC Circular 2023-07 is the Guidelines on Legitimate Interest, dated 13 Dec 2023 (its effective date differs between sources: 14 Jan 2024 vs 13 Apr 2024).

Conventions. Wording blocks are ready to paste. A heading line `### Heading` is one LegalSection. Paragraph breaks inside a body are blank lines. Bullet lines inside a body are plain lines starting with "- ", which the app renders as text; if the renderer does not support lists, join them as sentences.

Two cross-cutting points that shaped every text:

1. **Truthful at publication date.** Several retention periods (24 months) cannot be breached until Nov 2028 at the earliest, because Pantas launched Nov 2026. A promise about a period that has not yet elapsed is true when published. The owner must build the purge jobs before the first account reaches that age (listed in the gaps).
2. **The guardian confirmation page is code, not text I can change.** It says "Confirming here does not authorize a charge. Checkout does not check who is paying" (ds4 `guardian_confirm_page.dart` lines 161-162). No Terms wording can safely contradict a sentence guardians read when they agree. See Terms gaps.

---

# PART 1. TEEN NOTICE (document `teens`)

## 1(a). Final wording

Heading mapping against the current app (31 sections become 13): kept "Who this is for", "Who runs Pantas", "What we collect", "Optional usage sharing", "Speed and error reports", "Why a guardian confirms", "What your guardian can do", "Where your data goes", "Your rights"; "Withdrawing permission or deleting data" kept; "How long we keep data" now one section holding the eight former retention sections; "Why the law allows these uses" now one section holding the eight former basis sections (drafting language removed); "Payments for minors" kept. Updated date: set to the publication date (currently 2026-11-09, which also drives `guardianDocumentVersions`; see gaps).

### Who this is for

This notice is for teens ages 13 to 17 and for their parents or guardians. Pantas is for people aged 13 and older.

When you set up Pantas, we ask for your birth year. We use it to work out your age group, and we keep the age group, not your birth year. If you are under 18, or might be, a parent or guardian must confirm before you continue.

### Who runs Pantas

Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services, a sole proprietorship. He is also the Data Protection Officer.

Address: Poblacion, Norala, South Cotabato, Philippines.

Questions about your data: dpo@pantas.study
Help or payment problems: support@pantas.study

### What we collect

- Account: an account ID, which Pantas creates even before you sign in. If you sign in with Google, we also receive your name, email address and profile photo. If you sign in with an email code, we receive your email address.
- Study records: your study settings, answers, results, study times, bookmarked lessons and flagged questions. We use them to run your study sessions, plan your reviews and show your progress.
- Guardian confirmation: your guardian's name and email address. We keep the request status, its dates, a partly hidden version of the email address, and scrambled codes made from the email address and the link. Your guardian's full name and email address also stay on your device so you can resend the request. Your device deletes them when it learns the guardian has confirmed.
- Payments: if someone buys Pro for your account, we keep payment references, the amount, refund records and access dates. Card and wallet details are entered on PayMongo's page. We do not receive them.
- Free trial: a scrambled code made from your sign-in identity, so we can offer one trial per person.
- Technical records: security and account records, such as sign-ins, payment checks and account deletions.

### Optional usage sharing

You choose whether to share extra usage data to help improve Pantas. It starts off.

If you turn it on, we collect which screens and features you use and study events such as starting or finishing a session. These reports are linked to your account ID. The phone app can also send error reports.

To turn it off, open Settings, then About, and use "Help improve Pantas by sharing usage data." Turning it off does not stop the study records Pantas needs to work. You can also email dpo@pantas.study about reports already collected.

### Speed and error reports

To find slow screens and errors, the web app sends short technical reports. They show how long loading steps took, your browser type, whether you use a phone, tablet or large screen, and cleaned error details. They do not include your account ID, your answers or lesson content. We cannot link a report to you.

Google's server logs may also record the technical details of the connection, such as an IP address. We do not use these details to identify you. Google deletes the reports after 30 days.

This does not depend on your usage-sharing choice. It is on for everyone who uses the web app. Our reason is in "Why we may use your data" below.

### Why a guardian confirms

If you are in the under-18 group, Pantas asks a parent or guardian to read the terms and confirm before you continue.

Opening the email link confirms nothing. The adult must tick the agreement box and choose Confirm. They can choose "I Don't Agree" instead.

The link works once and expires after seven days. A new link replaces the old one. Keep the link private, because anyone who has it can answer the request.

### What your guardian can do

Your guardian can confirm or decline the request. Confirming does not give them a screen showing your results.

You or your guardian can contact our Data Protection Officer about your data. We may ask for proof of who is asking before we share information or act on instructions.

### Where your data goes

Some records stay in your browser or on your phone. On the web, your answers and study activity also go to our servers, including on Free. Pro adds backup and syncing across devices.

We use these providers:

- Google (Firebase and Google Cloud): accounts, our servers, optional usage reports, and speed and error reports.
- Resend: guardian emails and sign-in codes.
- PayMongo: web payments.

These providers may process data outside the Philippines.

### Your rights

You have the right to be informed about how your data is used. You can ask for a copy of your data, object to how it is used, ask us to fix wrong details, and ask us to stop using, block or delete data, when the law allows. You can ask for compensation where the law provides it. You can also complain to the National Privacy Commission.

Send requests to dpo@pantas.study. We reply within 15 calendar days. Our reply may ask you to prove who you are, give a progress update, or explain why we cannot fully act on a request.

To get a copy of your data, email the Data Protection Officer.

### Withdrawing permission or deleting data

You can withdraw a permission you gave, such as optional usage sharing, at any time.

To withdraw your permission for a child to use Pantas, a parent or guardian emails dpo@pantas.study with a message such as: "I withdraw my permission for my child to use Pantas." Send it from the email address used for confirmation if you can. Include the child's sign-in email or account ID if you know it. If you do not, tell us and we will help find the account. There is no charge.

We may ask for information we reasonably need to find the account and check who you are. After we check, we stop the use of data that depended on the withdrawn permission. Because Pantas cannot work without the core study permission, withdrawing it means we close the account and delete its study data, except records we must keep by law or need to handle a legal claim.

Withdrawing does not undo use of data that was lawful before you withdrew. It does not cancel a store subscription. A refund is handled under the Terms.

You can also delete your account yourself. Open Settings, then Account, then the delete option. For an account signed in with Google or an email code, this deletes your study data from our servers and clears Pantas data on the device you use. You may need to sign in again first. For an account that is not signed in, it clears data on your device only. If you need server records of such an account removed, email dpo@pantas.study.

Deleting your account does not remove everything. Trial codes, security records and payment records follow the periods in the next section. Copies on your other devices and backup copies held by our providers can take longer to disappear.

### How long we keep data

- Study records and settings: until you delete your account. If you do not use Pantas for 24 months, we delete your study data from our servers. Copies on your own devices stay until you clear them.
- Guardian requests and links: an unanswered request and its contact details are deleted when the seven-day window ends. A used, declined or replaced link is deleted seven days later. After a confirmation, we keep only the fact that it happened, the age group and the date, for as long as the account exists.
- Payment and accounting records: five years, as tax rules require. PayMongo keeps its own transaction records under its own rules.
- Security and account records: 730 days after the event.
- Free-trial codes: 24 months from the first trial. We keep the code even if you delete your account, so the trial cannot be repeated.
- Optional usage reports: Google Analytics keeps them for no more than 14 months. Phone error reports are kept for 90 days.
- Speed and error reports from the web app: 30 days.

If the law requires it, or we need records for a legal claim, we may keep specific records longer. A valid deletion request can shorten these periods.

### Why we may use your data

- To run Pantas for you (your account, study records and payments): this is needed to provide the service you asked for.
- For your age group and study records: you give your birth year and study information, and if you are under 18 your parent or guardian confirms. This is the permission we rely on for age and education information.
- For optional usage sharing: your choice, or your guardian's if you are under 18. You can change it at any time.
- For speed and error reports, security records, the guardian email and the trial code: our legitimate interests in keeping Pantas working, safe and fair. We keep each of these to the minimum we need.
- For payment and tax records: the law requires them.

### Payments for minors

If you are under 18, ask your parent or guardian to pay, or to allow you to use their payment method. The person whose payment method is used is responsible for the payment. See the Terms for the refund rules.

## 1(b). Drafter notes

Legal bases (all DPA citations are to RA 10173 sections; sub-letters only where I am confident):

- **Who/what/why/basis/recipients/retention/rights/DPO/complaint**: the right to be informed (DPA Sec. 16, IRR Sec. 34) and the transparency principle (Sec. 11(a)). All items kept. NPC child-oriented transparency advisory: number not verified in this pass; its content (plain language, child-readable) is why the notice stays short-sentence.
- **Dropped sentence "Thirteen is Pantas's access rule. It is not a Philippine rule that everyone aged 13 can independently consent."** It volunteers a legal doubt. The notice is not false without it, because the notice still says a guardian confirms for under-18s. Lawful to omit: disclosure duties are about the processing, not the drafter's legal analysis.
- **Dropped "A birth-year check cannot establish your exact birthday", "does not independently prove the responder's age or legal authority", "no guardian dashboard", "no working export button", "the email route requires manual action by the owner", "Do not retain study answers as consent evidence"** and the other limitation lists. None is a required disclosure. They gave critics admissions that Pantas's age and guardian checks are weak. The honest, non-admitting replacement is neutral description. I kept "Confirming does not give them a screen showing your results" because it answers the obvious question about what a guardian sees (and is true: no guardian dashboard in `lib/features/guardian/`).
- **Dropped "Pantas remains responsible for the information it entrusts to providers."** The duty exists anyway (Sec. 21(a): the controller is accountable for data transferred to a third party, domestic or overseas). Stating it adds nothing the law does not already impose.
- **Overseas providers named**: Google, Resend, PayMongo. Disclosure of recipients, including overseas, is required (IRR Sec. 34(a)). Functions run in `asia-southeast1` (Singapore): `clientTelemetry.ts` line 166. Firestore location not verified, so I say only "may process data outside the Philippines".
- **Retention section.** Retention must be "no longer than necessary" (Sec. 11(e)) and disclosed. Periods and what is built today:
  - Study data, 24 months inactivity: **not built** (see gaps). True at publication; first possible breach Nov 2028.
  - Guardian links and unanswered requests: **built and verified**. `guardianConsent.ts` `purgeGuardianRecords` lines 318-365, scheduled hourly lines 367-370: open link deleted at `expiresAt`; used/revoked link at event + 7 days (`GUARDIAN_WINDOW_MS`, line 28); pending request deleted at `expiresAt`; confirmed request is cut down to `{status, ageGroup, decidedAt}` seven days after decision (lines 344-347); declined deleted seven days after decision (line 349).
  - **Confirmed-request minimum record**: it is never purged by that job. It lives under `users/{uid}/server/guardianConsent` and `deleteAccount.ts` line 47 `recursiveDelete(userRef)` removes it with the account. So the text says "as long as the account exists". The earlier draft's "730 days after last processing" was not built and is dropped. Trade-off for the owner: after an account is deleted there is no consent proof left. If a dispute is a concern, you would build a retained, scrambled consent receipt (gap G7). I did not promise it.
  - Payment records, five years: tax-preservation rule carried over from the earlier draft (Tax Code Sec. 235 as amended by RA 11976; BIR RR 7-2024). I did not re-verify that citation. The wording says "five years, as tax rules require" without a count start date, so it is not false if the exact count differs. **Fact conflict to note**: `deleteAccount.ts` lines 50-53 delete Pantas's own payment index rows on account deletion. So "we keep payment and accounting records" is true only if the owner keeps his own bookkeeping (PayMongo dashboard exports, books). I word it as records "as tax rules require", which is a duty to the owner, not a statement that the app database holds them. See gap G6.
  - Security/audit 730 days: **built and verified**, `purgeOldAuditLogs.ts` line 9 (730 days), daily at 03:30 Singapore time.
  - Trial codes 24 months: **not built, and not buildable as the data exists**. `webTrial.ts` line 105 writes `{used: true}` with no timestamp; `deleteAccount.ts` line 54 says the codes deliberately survive deletion. No purge job. First possible breach Nov 2028, and existing codes need a date field. See G3.
  - Analytics "no more than 14 months": safe wording because 14 months is Google's maximum for event data and the owner's setting is not visible to me. If the owner sets 2 months in the Firebase console (a setting, no code), change the text to "two months", which is more protective and the earlier draft's claim.
  - Crashlytics 90 days: Google's published default (not verified in this pass; widely documented).
  - Web speed and error reports 30 days: Cloud Logging `_Default` bucket default is 30 days (Google default, not verified here). Must confirm the project bucket retention is not changed (G5). The telemetry spec also says 30 days (spec line 63).
  - Sign-in code challenges: `signInCode.ts` stores `purgeAt` two hours after send and `expiresAt` ten minutes (lines 34, 135, 212); not disclosed since brief records, but the notice now mentions email-code sign-in and Resend delivering codes.
- **"Why we may use your data."** Replaces eight drafting-language sections.
  - Contract (Sec. 12(b)) for ordinary data needed to deliver the requested service.
  - Age is sensitive personal information (Sec. 3(l)); so is education. Sec. 13(a) needs consent that is specific and informed. NPC Circular 2023-04 sets consent standards (freely given, specific, informed, evidenced). The student's entry plus the guardian's confirmation is the evidence. The wording "the permission we rely on for age and education information" describes the basis without arguing that study answers are or are not "education" information (the earlier draft's hedging). This is the broadest safe position: consent covers it either way.
  - Legitimate interest (Sec. 12(f); NPC Circular 2023-07) for security records, guardian email, trial code, speed reports. For trial code: the earlier draft also required 13(a) consent for the teen-linked marker. I dropped that: the marker is a keyed hash of a sign-in identity plus "used: true". It reveals no age or education and cannot be reversed without the secret key (`webTrial.ts` lines 15, 50). Ordinary PI, so Sec. 12(f) alone. Risk accepted: an assessor might call "use of an educational service" education information. The consent already collected at setup for study records is general enough to cover it if challenged.
  - Legal obligation (Sec. 12(c)) for tax records.
- **Withdrawal section.** Consent can be withdrawn (Sec. 16; Circular 2023-04). Wording reduced to what the law requires: a way to withdraw, no charge, a plain consequence. I kept "close the account and delete study data", because a consent-based service cannot lawfully continue after core consent is withdrawn; stating it avoids a false implication that the service continues. Dropped the 15-day statement here (it remains in Your rights). Dropped the copied admissions about missing buttons.
- **"15 calendar days"**: the DPA and IRR set no 15-day period that I verified; it is a voluntary commitment carried from the owner's public site (`pantas-web/privacy.html`, not found on this branch; carried from the earlier draft). Kept for consistency with what is published. Softened with what the reply may contain.
- **Deletion.** Facts verified in `deleteAccount.ts`: requires a named (non-anonymous) user (line 24), a sign-in within 5 minutes (lines 27-35), deletes Firestore user tree (47), payment index rows (50-53), hosted cards (58-65), the Auth identity last (69). Does not delete trial markers (54), audit records (the event is written, line 44), Resend or PayMongo copies.
- **Email-code sign-in.** The earlier notice mentions Google only. Source supports email-code sign-in (`webTrial.ts` lines 30-36, `signInCode.ts`). Added. This is a factual correction.
- **Resend**: also sends sign-in codes (`signInCode.ts` line 12 imports `mailerFor`). The earlier notice says Resend is for guardian emails only. Corrected.
- **Birth year not stored**: `age_policy.dart` evaluates a birth year; grep of ds4 `lib` found no persistence of a birth year. The age group is stored on device (`app_preferences_repository.dart` lines 81-83, `age_group`), and the server stores `ageGroup: 'minor'` on a confirmed request (`guardianConsent.ts` line 347). So "we keep the age group, not your birth year" is verified for the device and for the guardian record. The ds4 code path for the onboarding submit was not read to the end; I verified by grep only.
- **Age rule**: 13 minimum; a birth year that could mean 17 or 18 counts as a minor (`age_policy.dart` lines 36-42). The text says "under 18, or might be", which matches.
- **Guardian device copy cleared on confirmed**: `guardian_providers.dart` lines 86-90 (`refresh()` calls `clearGuardianContact()` when the status is confirmed). Text now says "when it learns the guardian has confirmed", which matches (the clear happens on refresh, not at the instant of confirmation).
- **Optional usage content**: I could not verify what events the optional Analytics path sends in ds4. `firebase_telemetry.dart` line 52 logs whatever event it is given; I found no call sites with question IDs or answers. The spec (telemetry design, T5) says study events carry only exam ID, kind and counts. The earlier notice said "question IDs, your answer choices, and whether those were correct". I replaced it with the spec's narrower description. If the analytics path does send question IDs or answers, the text understates and must be restored. **Unverified.**
- **Speed reports**: see Part 3.

## 1(c). Build gaps for the notice to be true

- **G1. 24-month study-data purge.** Need a last-active timestamp and a daily job that deletes the study tree of accounts idle 24 months (mirror `cleanupOrphanAnons.ts`, which today handles only anonymous accounts with no Firestore data after 30 days). Deadline: before the oldest account reaches 24 months (earliest account creation date; not checked). Until built, the sentence is true but not yet exercised.
- **G3. Trial-code purge.** Add `usedAt` to `trialUsedIdentities` documents (currently `{used: true}`, `webTrial.ts` line 105; `deleteAccount.ts` line 41 also writes `{used: true}`) and a daily purge at 24 months. Existing markers have no date; stamp them with the migration date. Deadline Nov 2028.
- **G5. Confirm the Cloud Logging bucket retention** is the 30-day default for the production project, and that no log sink exports reports elsewhere. Also decide the Analytics retention setting (2 months recommended) in the Firebase console.
- **G6. Bookkeeping.** The five-year payment record must exist somewhere the owner controls (PayMongo exports or books), because the app deletes its own payment index on account deletion.
- **G7. Optional: consent receipt.** If the owner wants proof of consent after account deletion, a scrambled receipt would need building. Not promised in the text.
- **G8. Version stamps.** `GUARDIAN_DOCUMENT_VERSIONS` in `guardianConsent.ts` lines 32-35 and `guardianDocumentVersions` in `legal_document.dart` name the document versions guardians agree to. A new text needs a new version stamp, in both places, in the same release. Existing confirmations stay tied to the older version. Materially different wording (for example, the corrected recipient list) does not need guardians to reconfirm in my view, but that is an owner call.

---

# PART 2. TERMS, "Subscriptions" section (document `terms`)

## 2(a). Final wording

Replaces the whole current "Subscriptions" body. Heading unchanged.

### Subscriptions

**App store purchases.** If you buy through an app store, your paid features depend on your active store subscription. The store handles billing, cancellation and refunds under its own rules. Manage them in the store account you used.

**Web purchases.** On the web, you buy Pro access in advance and pay through PayMongo. Web purchases do not renew automatically. If you want more access, you buy again. A web purchase does not cancel a separate store subscription.

**Price.** The price is the amount shown in Philippine pesos on the Pro screen and at checkout when you pay. Check the plan and amount before you pay. We may change prices at any time. A change does not affect a payment you already made. We show the payment methods that are available at checkout.

**Plans.** Weekly access lasts seven days. Monthly access lasts one calendar month. Yearly access lasts one calendar year. These plans give Civil Service Pro access. A Season Pass covers its named exam until the last day of the exam sitting stated at checkout. Monthly and Yearly access ends on the matching date at the same time in Philippine time. If that date does not exist, it ends on the last day of that month.

**When access starts.** Access starts after PayMongo confirms your payment to us, or after your existing Pro access ends, whichever is later. Returning from checkout does not confirm your payment. If you paid and Pro does not appear, email support@pantas.study with your payment details.

**Free trial.** Accounts that qualify can get one seven-day free trial of Monthly Pro. You must be signed in. You do not enter payment details. The trial ends after seven days. It does not become a paid plan and we do not charge you. We decide who qualifies. We may refuse or end a trial if we reasonably believe it is being misused, for example by opening several accounts. Deleting your account does not give you another trial.

**Free or promotional access.** Pantas may give free access, such as a trial or a beta period, at its choice. This access lasts only for the period we state. It can end earlier if it is misused. It does not give you a right to more access and it does not start a paid plan.

**Refunds.** A payment is final once the access it bought has started. We refund a payment in full only in these two cases:

- You paid twice for a period that has not started. We refund the extra payment.
- You paid, and the payment did not unlock Pro.

Email support@pantas.study within 30 days of the payment and include the payment details. We refund to the original payment method through PayMongo. The time it takes to reach you depends on PayMongo and your bank.

We do not refund unused time, part of a period, a change of mind, or access that was available to you and that you did not use. We do not refund a Season Pass after the exam date, unless the payment did not unlock Pro. A student cannot ask for a partial refund.

We may, at our choice, give a full or partial refund in other cases. A partial refund shortens your access in proportion to the amount refunded. A refund we give at our choice does not create a right to another refund.

**Disputes with your bank.** If you dispute or reverse a payment with your bank or card issuer, we end all the access that payment gave, for the whole period. We may also suspend the account.

**Ending Pro.** When your Pro access ends, Pro-only features stop unless another plan or pass covers the exam. You can keep using Free features. Pro backup and syncing stop while you do not have Pro. Ending Pro does not delete your progress.

**Deleting your account.** If you delete your account, your access ends, including any time left on a plan. Deleting your account is not a refund request.

**Students under 18.** If you are under 18, ask your parent or guardian to pay, or to allow you to use their payment method. The person whose payment method is used is responsible for the payment. By paying, you confirm that you are allowed to use that payment method.

**Your legal rights.** This section does not limit any right you have under Philippine law that cannot be waived.

## 2(b). Drafter notes

Facts verified in source (ds4 unless noted):

- Web prepaid through PayMongo, no auto-renewal: `paymongoPolicy.ts` line 5 `Prepaid` type, products with `prepaid` lengths in `products.json`; no renewal path in web code. Payment methods `['card','qrph']` default, `paymongoCheckout.ts` lines 18-19, overridable by env `PAYMONGO_PAYMENT_METHODS`. Text says "the payment methods that are available at checkout", so a method change needs no Terms change.
- Prices vs `docs/pricing.md` (the only valid source): Civil Service ₱49 weekly, ₱149 monthly, ₱1,199 yearly, ₱499 pass. `products.json` web prices match: weekly 49, monthly 149, yearly 1199, pass 499 (`pantas_pass_cse_pro` and `_sub` both 499). The Pro page shows the amounts (`pro_page.dart` uses `priceString` from `listWebPlans`).
- Periods: weekly 7 days, monthly one calendar month, yearly one year, in Philippine time (`paymongoPolicy.ts` lines 26-37, which clamps to the last day of a short month per the earlier text). Season pass ends `lastDay T23:59:59.999+08:00` (`revenuecatPasses.ts` line 34).
- Access start: grant created by the PayMongo webhook after verification (`paymongoGrants.ts`; `paymongoWebhook.ts`). Later grants queue behind earlier ones ("existing Pro access ends" - behavior confirmed by `replanBehind` in `paymongoGrants.ts` lines 55-120; I did not read each branch).
- Trial: `webTrial.ts`: tier Civil Service (line 101), `TRIAL_DAYS = 7` (`grants.ts` line 32), refused for anonymous (line 69, 44), only for accounts that never had paid Pro (`neverHadPro`, lines 57-65), one per verified sign-in identity (lines 18-51), no payment details (no payment path), no conversion (a grant with fixed `endsAt`, line 102). Marker survives deletion (`deleteAccount.ts` line 54). The Pro page offers it on the Monthly package only when `trialEligible` (`pro_page.dart` lines 604-607; I read the condition lines only, not the full flow). Rate limit 5 per hour per account is an engineering detail, omitted.
- Beta: `BETA_CUTOFF = 2026-11-16T00:00:00+08:00` (`betaPro.ts` line 15). Beta Pro grants do not use up a trial (`webTrial.ts` line 60 comment and logic). I **omit** that fact. It favors the student, no law requires saying it, and the Terms say "we decide who qualifies".
- Refund mechanics in code: duplicate-not-started periods and unlock failures exist as `unusedDuplicate`, `paidAfterSitting`, `bornRevoked` outcomes (`paymongoGrants.ts` line 123); a refund or a dispute event revokes or shortens the grant (`paymongoWebhook.ts` line 19 `REVOKING`: `refund.succeeded`, `payment.refunded`, `payment.refund.updated`, `dispute.created`); partial refunds shorten proportionally (`applyRefund`, lines 39-50; owner's decision 19 Oct, launch log lines 660-690); a dispute revokes the whole grant (`revokePaymongoPayment` with `dispute: true`, `paymongoWebhook.ts` line 178). **Caution**: the code also has `resolvePaymongoDispute` with `won` (lines 55-61); it appears a dispute won by Pantas restores the grant. The text says "we end all the access that payment gave", which describes the first reaction and does not promise permanence; a win is not contradicted.
- The owner's refund decisions (launch log lines 660-715): option 1, students cannot request partial refunds, passes not refunded after the exam date, admin-only proportional partial refund. All reflected.

Legal reasoning and where the text leans, clause by clause:

- **Refer to checkout for price, not print prices.** Favorable: a price change needs no Terms change and no new version stamp for guardians (G8). Lawful as long as the price is clearly displayed before payment. The Internet Transactions Act (RA 11967) and its IRR require online merchants to give clear, accurate pre-purchase information including price (section numbers unverified; blocked fetches). The Pro screen and checkout already show the amount, so the duty is met outside the Terms. Consumer Act (RA 7394) Art. 50-52 concerns deceptive and unfair sales acts (numbering from the brief, unverified): a price shown at checkout that you charge is not deceptive. "We may change prices at any time" is lawful because it affects only future purchases.
- **Refunds only for errors.** Philippine law gives refund/repair/price-reduction remedies mainly for defective goods or services (Consumer Act on warranties and services, Arts. 99-106 per the brief, unverified in this pass; Civil Code Arts. 1170 and 1191 on breach, 1170 on liability for delay and breach). A change-of-mind refund is not a statutory right for a service already delivered. The ITA IRR adds consumer redress rights for online purchases but, as I recall, not a no-reason cooling-off right for digital services already supplied (unverified; flag for check). Stating "final once access has started" is lawful if the saving clause keeps non-waivable remedies. Favorable ingredients: 30-day claim window, "student cannot ask for a partial refund", "no refund for unused time", pass after exam date, discretionary refund creates no precedent.
- **30-day window.** A voluntary-policy deadline. Risk: if a payment never unlocked Pro, the statutory remedy (Civil Code 1191 rescission; 1170) is not time-limited to 30 days, and the saving clause preserves it. The window only limits the voluntary route. Lawful; modest risk.
- **Discretionary refunds.** Business may refuse or grant at will; an exercise of discretion does not create a duty (Civil Code Art. 1306, freedom to stipulate; no estoppel from a stated "at our choice" clause).
- **Chargeback revokes the whole grant.** Contract term; lawful (Art. 1306). It reflects the code (`dispute.created` revokes). I added "We may also suspend the account": lawful as a contract right to protect against fraud; no suspension feature is built (G10 below), so the sentence is only a reserved right.
- **Account deletion ends access without refund.** Lawful; the user chooses it.
- **Minors.** Exposure: a contract with a minor is voidable (Civil Code Arts. 1327(1), 1390(1)); the incapacitated party need only restore what benefited them (Art. 1399), and the other party must restore too unless the minor's benefit applies (Art. 1425-1427 area; I could not confirm 1426-1427 text, flagged). **Favorable lawful position, in the notes only**: (i) an educational service may qualify as a "necessary" for which a minor must pay a reasonable price (Civil Code Art. 1489 with Family Code support provisions that include education; unverified, check); (ii) on the web the payer is the card or wallet holder, normally an adult, who is the contracting party and bound (PayMongo card ownership), not the minor; (iii) ratification or no action within the period of the annulment action (Art. 1391, four years from the end of minority) leaves the contract valid until annulled. The text therefore states who pays and who is responsible, and does not mention the minor's right to annul. Voluntarily telling a minor "you can undo this" is not a duty. **Limit**: I cannot lawfully write "a minor waives the right to annul" because it is void (Art. 1409(1) contrary to law; Art. 1306), and a clause that tries it would look overreaching to a regulator. The clause "By paying, you confirm that you are allowed to use that payment method" is a representation that supports a later estoppel argument (Art. 1431).
- **Free or promotional access.** Replaces the dated beta paragraph. Beta clause removed from the Terms: it expires Nov 16, ages badly, and the beta-specific facts (cutoff) are better stated in the in-app beta notice, which I was not asked to draft. The new paragraph covers trials, beta and giveaways in one line, favors the business (access is revocable gift-like grace, no continuing right), and is lawful because it creates no price-bearing promise. Check that giveaway winners (manual RevenueCat grants; `docs/pricing.md` "Not yet settled") are also covered: yes, "free or promotional access".
- **Dropped sentences that admit or promise**: "These limits do not remove any refund, reperformance, price reduction, compensation, or other remedy required by Philippine law. They do not exclude a remedy for defective service..." replaced by one short saving clause. The long list advertised each statutory remedy to the student. The short clause is enough to avoid voidness (Art. 1409; Consumer Act on waiver of rights, Art. numbers per brief unverified). Also dropped: "Guardian account confirmation does not authorize a charge. Checkout does not verify the payer's age or guardianship" (an admission; see gap G9 because the guardian page itself says it), "Necessary server study records can still be collected on Free" (a privacy point already in the notice), "Leaving an unpaid checkout does not create Pro access" and the "no automatic renewal to cancel" paragraph (covered by "do not renew automatically").
- **Ambiguity risk**: contracts of adhesion are read against the drafter (Civil Code Art. 1377 for obscure terms; Ong Yu v. Court of Appeals line of cases, citation not verified). I used one term for each thing: "payment", "access", "period", "refund". "Final" is defined by "once the access it bought has started". "Within 30 days of the payment" is a date, not a feeling. "Unused time" is separated from "duplicate not started" by those two bullet cases.
- **Access starts**: the phrase "whichever is later" matches `replanBehind` queue behavior.
- **Authority conflict**: `docs/TERMS.md` exists on this branch and the launch log says the refund policy goes there and on pantas.study (log line 695-696). I did not read it. Owner check: keep it consistent with this wording.

## 2(c). Build gaps for the Terms to be true

- **G9. Guardian confirmation page copy.** It currently says "Confirming here does not authorize a charge. Checkout does not check who is paying." The Terms say the payer is responsible and a minor should pay only with a parent-approved method. These are consistent, but the page text keeps the earlier concession alive. Recommended code change (owner decision; frozen now): replace with "Your child should pay only with a payment method you own or allow them to use. The person whose payment method is used is responsible for the payment." Optional; the Terms are safe without it, but I would not rely on the Terms to bind a guardian who read the opposite on the page.
- **G10. Account suspension.** "We may suspend the account" is a reserved right; no feature is built. Fine as is. Do not describe it as an existing process.
- **G11. Refund admin tool.** The launch log parks the admin lookup tool for duplicate and non-unlocking payments until after launch (log lines 700-712). The text promises a full refund for those two cases within 30 days. Until the tool exists the owner verifies by hand in the PayMongo dashboard. If volume grows, the promise outruns the tool.
- **G12. Store-side refunds.** Text refers to store rules; no code needed.
- **Checks outside the code**: confirm `docs/TERMS.md` and any pantas.study refund page match this section (launch log line 695-696).

---

# PART 3. Legal basis for web "Speed and error reports", and Privacy Policy section

## 3(a). Final wording

### 3.1 The basis line (teen notice, section "Why we may use your data", and the Privacy Policy)

Already inside the Part 1 bullet list. Standalone form, if the owner wants a single line:

> Legitimate interests (Section 12(f) of the Data Privacy Act): keeping Pantas working and fast. These reports are not linked to your account and carry no account ID, answers or lesson content. Google's server logs may record connection details such as an IP address with each report. We do not use them to identify you.

Differences from the current line "...The reports carry no account identity, answers, or learning performance.": adds the Google connection-log caveat (needed for truth, see notes), drops "Legitimate interests under Section 12(f), to" legalese.

### 3.2 Privacy Policy new section (adults)

Add as the fourth LegalSection of document `privacy`, after "What we never do", before "Your rights":

### Speed and error reports

To find slow screens and errors, the web app sends short technical reports. They show how long loading steps took, your browser type, whether you use a phone, tablet or large screen, and cleaned error details. They do not include your account ID, your answers or lesson content. We cannot link a report to you.

Google's server logs may also record the technical details of the connection, such as an IP address. We do not use these details to identify you. Google deletes the reports after 30 days.

These reports are sent for everyone who uses the web app, whether or not you share extra usage data. Our legal basis is our legitimate interest in keeping Pantas working and fast (Section 12(f) of the Data Privacy Act).

Also add one sentence to the Privacy Policy stub's data-recipients section when that is written (see 3(c)): "Speed and error reports from the web app go to Google Cloud logs."

## 3(b). Drafter notes, facts, and the legitimate-interest assessment

### What is actually sent and logged (verified)

- Payload fields: `v`, `build`, `visit` (first/return/after_deploy), `browser` (family only: chrome/safari/firefox/edge/samsung/other), `mobile` (boolean), `viewport` (phone/tablet/wide), `timings` (name + ms, up to 40), `errors` (type, cleaned message up to 300 chars, up to 8 stack frames, count). `functions/src/clientTelemetry.ts` lines 13-40; built in `client_report.dart` lines 389-411. The validator rejects any other key (`record()` lines 46-52), so extra fields cannot reach the log.
- The browser family is derived on the device; the full user-agent string is not in the payload (`client_report.dart` lines 138-151, 225-231). The error message is cleaned of emails, URL queries, long tokens and 6+ digit runs (lines 80-110). Names or free text inside an error message are **not** cleaned. Low risk because it is an exception message, but not zero.
- The application log line is `{kind: 'client_telemetry', ...report}` only (`clientTelemetry.ts` line 162). No uid. The `fn_timing` line has function name, ms, cold flag, outcome, no uid (`_timed.ts` lines 38-40).
- The call needs a signed-in (including anonymous) Firebase user and App Check (`clientTelemetry.ts` lines 159, 166). The uid is used only for a per-instance rate limit, hashed with SHA-256, kept in memory (lines 106-137).
- **IP address and user agent: not in the application log line, but very likely in Google's platform request log.** Callable functions v2 run on Cloud Run, and Cloud Run writes a request log entry per call. The Cloud Logging `httpRequest` record has fields `remoteIp` and `userAgent` (schema confirmed by search; that Cloud Run populates them for 2nd-gen functions I know from experience and did not confirm in Google's Cloud Run documentation in this pass). The application log line and the request entry share a trace ID, so someone with log access could join a report to an IP and a full user agent. **Verify**: in Logs Explorer for the production project, open one `reportClientTelemetry` request entry and look for `httpRequest.remoteIp`. That takes about two minutes.
- Authorization header (the Firebase ID token and uid) is not written to the request log by default (my understanding; not verified).
- The `consumeAppCheckToken` is not set on this function (line 166), so App Check tokens are not single-use here; irrelevant to privacy.

### Is it personal information?

- DPA Sec. 3(g): personal information is information from which identity is apparent, or can be reasonably and directly ascertained by the entity, or which put together with other information would directly and certainly identify an individual.
- Report content on its own (timings, browser family, viewport class, error text) does not identify anyone and Pantas cannot link it to a person: strong argument that it is not personal information.
- The Google connection metadata (IP, full user agent) is different. Pantas does not need it and does not read it, but an IP combined with the anonymous Firebase session or a signed-in user's timing could in principle single someone out. The NPC has not, to my knowledge, ruled an IP address is or is not personal information in a case I can cite; I could not verify. So the safe stance, used in the text, is: do not claim "no personal data". State what is true (not linked to account, no ID/answers/content) and disclose the IP caveat.
- **Why the favorable angle holds in both outcomes**: if it is not personal information, the DPA basis is moot and the disclosure is just good practice. If it is, Sec. 12(f) covers ordinary personal information (no sensitive data: no age, no education, no answers, so no Sec. 13 basis is needed). Disclosing the IP point costs nothing legally and removes the one way the line could be called false, which is itself a violation (Sec. 11(a) transparency; accuracy). I did not remove "browser type" even though the full UA stays in Google's log, because the app-level statement is accurate and the caveat follows.

### Legitimate-interest assessment (for the owner's file)

Framework: NPC Circular 2023-07 (purpose, necessity and balancing tests, documented; effective date differs by source, see top). Section 12(f): processing is necessary for the legitimate interests pursued by the controller, except where overridden by the fundamental rights and freedoms of the data subject. Hold this as a dated record and review it every 12 months.

**Assessment of "Speed and error reports", web app, all users**
Date: 2026-11-09 (set on adoption). Owner and assessor: Aerol Dwayne D. Balayon. No lawyer review.

1. **Purpose test.** The interest is a working, fast service: finding slow startup steps and recurring errors on real users' browsers, which the owner cannot see otherwise (web errors were recorded nowhere before; telemetry design spec line 59). The interest is real, lawful and stated in advance (the notice). It also serves users, who benefit from fixes.
2. **Necessity test.** Could the aim be met with less? Alternatives: (a) collect only from users who opt in to usage sharing: tested in the spec as option B; it yields too few reports because sharing starts off and the tester base is about 20 (spec lines 69-72), so the aim is not met; (b) test only on the owner's devices: does not reflect users' networks and phones; (c) collect nothing: no fix signal. Data minimization applied: no account ID, no answers, no question or lesson content; browser family not full user agent; viewport class not pixel size; error text cleaned of emails, tokens, URL queries and long digit runs; at most 40 timings and 10 errors per report; about one to three reports per app open; rate-limited; not stored in Firestore; logs deleted at 30 days. Necessary and proportionate.
3. **Balancing test.** Nature of the data: ordinary technical data, no sensitive information. Reasonable expectations: users of a web app expect performance telemetry, and the notice discloses it. Impact: very low; no profile, no decisions about a person, no sharing beyond Google as processor, no marketing. Vulnerability: users include teens aged 13 to 17. The data reveals nothing about age, school or ability, so the added risk from age is small; the report contents are the same for adults and teens. Residual risk: Google connection logs hold the IP; mitigated by 30-day deletion and no use for identification. Safeguards: validator allow-list, cleaning on the device, short retention, the notice. Right to object: preserved in the general rights text; because reports carry no account ID, Pantas cannot find one person's reports. Individual objection cannot be performed, so the objection right is limited in practice. IRR Sec. 34 (right to object) excepts processing necessary for a service or legal obligation; I did not verify the wording. 
4. **Conclusion.** Interest not overridden; Sec. 12(f) applies. Re-run the assessment if the payload gains any field (the validator rejects extra keys, which forces a code change first), if the retention changes, or if sensitive data could enter an error message.
5. **Decision on opt-out.** None built. The owner chose always on. A one-switch opt-out (a local setting that skips the report) would strengthen this assessment; it is the first mitigation to add if the NPC or a user pushes back.

### Where the section should sit

- Today it lives only in the teen notice (`legal_document.dart`, teens). Adults using the web app are not told. Add it to the Privacy Policy (3.2). Keep a short copy in the teen notice (done, Part 1). Do not put it in the Terms.
- **The Privacy Policy stub is not enough on its own.** It has three short sections, and omits things the DPA expects a privacy notice to carry: identity and contact of the controller and DPO, purposes, legal basis, recipients including overseas providers, retention, and the NPC complaint right (Sec. 16; IRR Sec. 34). I was asked to draft only the telemetry section. Adults get a thinner notice than teens. That is a real gap; recommend a follow-up task to draft a full Privacy Policy by reusing Part 1 sections with adult wording. The Privacy Policy also states "With your permission, extra usage reports can be linked to your account ID", consistent with Part 1.

## 3(c). Build gaps for the telemetry wording to be true

- **G4. Verify the Google request-log fields** (two-minute check described above) and the 30-day bucket retention (G5). If request logs hold no IP (unexpected), the caveat sentence can be removed.
- **G13. Optional**: a user-controlled opt-out for speed reports (see LIA step 5).
- **G14. Privacy Policy full draft** (follow-up task), including the sentence "Speed and error reports from the web app go to Google Cloud logs."
- **Phone app**: the web reporter only starts on web (`client_report.dart` lines 218-222). The text says "web app", which is accurate.

---

# RISKS THE OWNER ACCEPTS

1. No lawyer reviewed any of this. Statute citations marked unverified may be wrong; the structure of the clauses does not depend on the exact numbers, but the Consumer Act and ITA points should be checked before relying on them in a dispute.
2. **Minor purchases are voidable.** A parent can ask to undo a purchase made by a teen. The Terms put payment responsibility on the payer but cannot waive the right (a waiver would be void, Art. 1409/1306). Expect to refund some such claims or lose them before the DTI or a court.
3. **The "final once access starts" refund rule is a voluntary policy.** Consumers keep non-waivable statutory remedies for defective or undelivered service. A DTI complaint on a change-of-mind refund is likely to be resolved on the merits, not on the clause.
4. **Cut disclosures.** The wording no longer volunteers limits of the age check, guardian identity checks, or the missing export button. If the NPC finds a required disclosure missing, the absent sentence is the exposure. I judge none of the cut sentences is required.
5. **Guardian page conflict.** Until the guardian confirmation page copy is changed (G9), guardians are told confirming does not authorize a charge.
6. **Trial-code consent.** Relying on Sec. 12(f) alone for the teen-linked trial code (earlier draft required Sec. 13(a)) assumes it is ordinary information, not "education" information.
7. **Telemetry always on.** No per-user opt-out. If Google's request log holds IP addresses (probable), it is arguably personal information processed without consent, justified by Sec. 12(f). The assessment supports it; the NPC has not ruled on this fact pattern as far as I know.
8. **Retention promises with no job built yet** (24-month study purge, 24-month trial-code purge). True today; false from Nov 2028 if not built. Calendar the build.
9. **Analytics "no more than 14 months"** is looser than the earlier "two months". Set the console to two months and tighten the text if you can.
10. **Payment records.** The text relies on the owner's own books for the five-year duty because the app deletes its payment index on account deletion.
11. **The "Use of the app and limits of responsibility" section was not rewritten.** It still contains "This does not remove its duty..." concessions. Recommend a follow-up pass. Not in this task's scope.
12. **Document version stamps.** New text requires bumping the version in both the app and the functions in the same release (G8); forgetting it makes guardians' recorded agreement point at the old text.
