# Legal texts for Aedwon's check: teen notice, Terms Subscriptions, telemetry legal basis

Prepared November 9, 2026, on `docs/legal-texts-r1`. Policy commit: origin/main d8eab55e4.
Not published and not built. No lawyer has reviewed this. Aedwon checks the wording only.

Standing rule (Aedwon, Nov 9): agents write legal text, Codex GPT 6.1 Sol at high effort
critiques it, and Aedwon only checks the result. Recorded as written rule 4 in
`docs/workflow/process-improvement.md`.

## What you are checking

1. **Teen notice**, the in-app document "Notice for teens".
2. **Terms, "Subscriptions"**, the in-app Terms of Service section for web purchases.
3. **Telemetry legal basis**, one line for the always-on web speed and error reports, plus
   the same section for the adult Privacy Policy, which never mentioned them.

Read the wording in parts A, B and C. Part D lists the risks you accept. Part E lists what
must be built or checked before publishing. If the wording is fine, say so and an agent puts
it in the app.

## Where each text already existed

All three already existed. They were not missing; they kept coming back to you as open items.

- The Nov 5 draft, `docs/legal/drafts/2026-11-05-teen-notice-and-terms-web.md`, holds the
  teen notice and the Terms web wording.
- That draft is built, almost word for word, into the app on `web/design-system-4`
  (`lib/features/legal/domain/legal_document.dart`, documents `teens` and `terms`). The teen
  notice link is switched on there (`teenNoticeReady = true`).
- The telemetry legal-basis line is also built there: "Legitimate interests under Section
  12(f), to keep the app working and fast..."
- The pantas-web project (all branches) has only the beta-application privacy notice and a
  child privacy assessment draft. It has no teen notice, Terms, or telemetry text.

Problems with the built text, which is why it was rewritten rather than reused:

- The built teen notice shows drafting notes to users, for example "this draft requires
  specific Section 13(a) consent" and "should not be described as anonymous".
- It volunteers weaknesses no law requires it to state, for example that the guardian check
  does not prove identity and that withdrawal "requires manual action by the owner".
- The telemetry section appears only in the teen notice. The adult Privacy Policy is a
  three-section stub, so adults are never told about the reports.

## How it was made

1. A Sonnet subagent rewrote all three texts from the built text, checked against the app
   source on `web/design-system-4`, with the angle "favorable to Pantas as far as Philippine
   law allows" (draft: `2026-11-09-r1/draft-v1.md`).
2. Codex GPT 6.1 Sol at high effort critiqued every clause: enforceable or not, where it can
   lean further, what is void or risky (critique: `2026-11-09-r1/critique-v1.md`).
3. The lead verified the critique's factual claims in source, then revised. The final wording
   is below.

---

## A. Teen notice (document `teens`)

Replaces all 31 current sections with these 13. Each `###` heading is one section in the app.

### Who this is for

This notice is for teens ages 13 to 17 and for their parents or guardians. Pantas is for people aged 13 and older.

When you set up Pantas, we ask for your birth year to work out your age group. We do not save your birth year as a lasting record. We save the age group. If you are under 18, or might be, a parent or guardian must confirm before you continue.

### Who runs Pantas

Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services, a sole proprietorship. He is also the Data Protection Officer.

Address: Poblacion, Norala, South Cotabato, Philippines.

Questions about your data: dpo@pantas.study
Help or payment problems: support@pantas.study

### What we collect

- Account: an account ID, which Pantas creates even before you sign in. If you sign in with Google, we also receive your name, email address and profile photo. If you sign in with an email code, we receive your email address.
- Study records: your study settings, answers, results, study times, bookmarked lessons and flagged questions. We use your answers and study times to choose your review dates and show your progress.
- Guardian confirmation: your guardian's name and email address. We keep the request status, its dates, a partly hidden version of the email address, and protected codes made from the email address and the link. Your guardian's full name and email address also stay on your device so you can resend the request. Your device deletes them once it learns the guardian has confirmed.
- Guardian answer: a record of your guardian's answer, when it happened, and which versions of our notices and terms were shown.
- Payments: if someone buys Pro for your account, we keep payment references, amounts, payment status, refunds and access dates. Payment details such as card numbers are entered on PayMongo's checkout page.
- Free trial: protected codes made from your verified sign-in details, so we can check whether a trial was already used.
- Technical records: security and account records, such as sign-ins, payment checks and account deletions.

### Optional usage sharing

You choose whether to share extra usage data to help improve Pantas. It starts off. Turning it on is a separate choice from setting up your account, and leaving it off does not stop you from using Pantas.

If you turn it on, reports include the screens and features you use, your study sessions, question IDs, the answer you chose, and whether it was correct. These reports are linked to your account ID. The phone app can also send error reports.

To turn it off, open Settings, then About, and use "Help improve Pantas by sharing usage data." You can also email dpo@pantas.study about reports already collected.

### Speed and error reports

To find slow screens and errors, the web app sends short technical reports. They include the app version, whether this is a first visit, a return visit or the first visit after an update, your browser family, your screen-size group, loading times, and error messages, counts and locations in our code. We remove common personal details, such as email addresses, before a report is sent. We do not deliberately include your answers or lesson content.

The stored report does not contain your account ID. Sending it uses your sign-in session, including a guest session, to check the request and to limit how many reports are sent. Google's connection logs may also record your IP address and browser details. Combined with other information, these can sometimes identify a person. We do not use them to identify you.

We keep these report logs for 30 days. These reports are on for everyone who uses the web app and are separate from optional usage sharing. You can object by emailing dpo@pantas.study.

### Why a guardian confirms

If you are in the under-18 group, Pantas asks a parent or guardian to read the terms and confirm before you continue.

Opening the email link confirms nothing. The adult must tick the agreement box and choose Confirm. They can choose "I Don't Agree" instead.

The link works once and expires after seven days. A new link replaces the old one. Keep the link private, because anyone who has it can answer the request.

### What your guardian can do

Your guardian can confirm or decline the request. Confirming does not give them a screen showing your results.

You or your guardian can contact our Data Protection Officer about your data. We may ask for information we reasonably need to check who is asking before we share information or act on instructions.

### Where your data goes

Some records stay in your browser or on your phone. On the web, your answers and study activity also go to our servers, including on Free. Pro adds backup and syncing across devices.

We use these providers:

- Google (Firebase and Google Cloud): accounts, our servers, optional usage reports, and speed and error reports.
- Resend: guardian emails and sign-in codes.
- PayMongo: web payments.
- RevenueCat and the app store you use: app-store purchases and the Pro access they give.

These providers may process data outside the Philippines.

### Your rights

You have the right to be informed about how your data is used. You can ask for a copy of your data, including in a common electronic format where the law allows. You can object to how it is used, ask us to fix wrong details, and ask us to stop using, block or delete data, when the law allows. You can ask for compensation where the law provides it. You can also complain to the National Privacy Commission.

Send requests to dpo@pantas.study. We reply within 15 calendar days. We may ask for information we reasonably need to check who you are. If we cannot fully act on a request, we explain why.

### Withdrawing permission or deleting data

You can withdraw a permission you gave, such as optional usage sharing, at any time. Withdrawing is free.

To withdraw permission for a child to use Pantas, a parent or guardian emails dpo@pantas.study with a message such as: "I withdraw my permission for my child to use Pantas." Send it from the email address used for confirmation if you can. Include the child's sign-in email or account ID if you know it. If you do not, tell us and we will help find the account.

After we check the request, we stop the use of data that depended on that permission. Pantas cannot work without permission for study records, so withdrawing it means we close the account and delete its study records. We keep only the records described below that have another lawful reason.

Withdrawing does not undo use of data that was lawful before you withdrew. It does not cancel an app store subscription. Refunds follow the Terms.

You can also delete your account yourself. Open Settings, then Account, then the delete option. For an account signed in with Google or an email code, this deletes your study records from our servers and clears Pantas data on the device you use. You may need to sign in again first. For an account that is not signed in, it clears data on your device only. To remove server records of such an account, email dpo@pantas.study.

Deleting your account removes its study records. Limited trial-use, guardian-answer, security and required accounting records may remain for the purposes and periods in the next section. Copies on your other devices stay until you clear them.

### How long we keep data

- Study records and settings: while your account exists. They are deleted when you delete your account or when the account is closed after a withdrawal.
- Guardian requests and links: a link stops working after seven days. Our hourly cleanup then deletes expired requests and links. A used, declined or replaced link is deleted seven days after that event.
- Guardian answer record: kept after account deletion, for as long as we may need it to show that permission was given.
- Free-trial codes: kept for as long as we offer free trials, including after account deletion, so a trial cannot be repeated.
- Payment and accounting records: five years, counted as tax law requires from the filing deadline of the related tax return. Records may stay longer while a tax matter is unresolved.
- Our database security records: 730 days after the event.
- Optional usage reports: Google Analytics keeps event records for up to 14 months after your last activity. Google starts removing phone error reports after 90 days.
- Speed and error report logs from the web app: 30 days.

If the law requires it, or we need specific records for a legal claim, we may keep those records longer.

### Why we may use your data

- Account, study and payment records: we need them to provide the service you asked for.
- Age group and study records: we rely on your specific permission, and for a student under 18, the confirmation of a parent or guardian. This covers age and education information.
- Optional usage sharing: your separate permission. You can withdraw it at any time.
- Speed and error reports, security records, guardian requests and trial codes: our legitimate interest in keeping Pantas working, safe and fair. We keep each to what we need.
- Accounting records: the law requires them.

### Payments for minors

If you are under 18, your parent or guardian must make the purchase. They accept the Terms as the buyer and must be allowed to use the payment method. Confirming your account is not a purchase.

---

## B. Terms, "Subscriptions" (document `terms`)

Replaces the whole current "Subscriptions" body. The heading stays.

### Subscriptions

**App store purchases.** If you buy through an app store, your paid features depend on your active store subscription. Use the store account you bought with for billing, cancellation and store refund requests. Contact us about problems with Pantas itself.

**Web purchases.** On the web, you buy Pro access in advance and pay through PayMongo. Web purchases do not renew automatically. If you want more access, you buy again. A web purchase does not cancel a separate store subscription.

**Price.** The price is the amount shown in Philippine pesos on the Pro screen and at checkout when you pay. Check the plan and amount before you pay. We may change prices at any time. A change does not affect a payment you already made. Checkout shows the payment methods you can use.

**Plans.** Weekly access lasts seven days. Monthly access lasts one calendar month. Yearly access lasts one calendar year. These plans give Civil Service Pro access. Monthly and Yearly access ends on the matching date at the same time in Philippine time. If that date does not exist, it ends on the last day of that month. A Season Pass covers its named exam until the end of the last day of the exam sitting stated at checkout.

**When access starts.** We turn on access after we verify your payment with PayMongo. A plan period counts from the payment time PayMongo records, or from the end of your existing qualifying Pro access, whichever is later. A Season Pass runs from payment until its stated sitting and does not add to other passes. Returning from checkout does not confirm your payment. If you paid and Pro does not appear, email support@pantas.study with your payment details.

**Free trial.** You can get one seven-day free trial of Monthly Pro if you qualify. You qualify only if you are signed in with verified sign-in details and have not had a trial or paid Pro before. You do not enter payment details. The trial ends after seven days. It does not become a paid plan and we do not charge you. We may change or stop future trial offers. We may refuse or end a trial we reasonably suspect is being misused, for example through several accounts. Deleting your account does not give you another trial.

**Free or promotional access.** Pantas may give free access, such as a trial, a beta period or a prize, at its choice. This access lasts only for the period we state. It can end earlier if it is misused. It does not give you a right to more access and it does not start a paid plan.

**Refunds.** Under our voluntary refund policy, we refund in full:

- an extra payment for a period that has not started, such as a payment made twice; or
- a payment that never gave you the access you bought.

Email support@pantas.study within 30 days of the payment, with enough details to find it. We refund to the original payment method through PayMongo. The time the money takes to reach you depends on PayMongo and your bank.

We do not give refunds for a change of mind, or partial refunds for unused time. A period that has started, or a Season Pass whose exam date has passed, is outside this voluntary policy.

We may give other refunds as goodwill. A goodwill refund does not create a right to more refunds. If we agree to cancel a purchase with a partial refund, the remaining access is shortened in proportion to the amount refunded.

These limits and the 30-day deadline do not limit any remedy Philippine law gives you, such as for a service that did not work as promised.

**Disputes with your bank.** If you dispute a payment with your bank or card issuer, we may suspend the access that payment gave while the dispute is open. If the payment is reversed, that access ends. If the dispute is resolved in our favor, the access returns. We may restrict an account we reasonably suspect of fraud or abuse.

**Ending Pro.** When your Pro access ends, Pro-only features stop unless another plan or pass covers the exam. You can keep using Free features. Pro backup and syncing stop while you do not have Pro. Ending Pro does not by itself delete your progress. Your data follows the storage periods in our privacy notices.

**Deleting your account.** If you delete your account, your access ends, including any time left on a plan. Deleting your account is not a refund request.

**Students under 18.** If you are under 18, your parent or guardian must make the purchase and accepts these Terms as the buyer. The buyer must be allowed to use the payment method chosen.

**Complaints.** Send purchase complaints to support@pantas.study.

---

## C. Telemetry legal basis

### C1. The legal-basis line

Goes in the teen notice section "Why we may use your data" (already inside Part A) and in the
Privacy Policy section below. Replaces the current "Speed and error reports (web)" section.
Standalone form:

> Speed and error reports (web): our legitimate interest in keeping Pantas working and fast (Data Privacy Act, Section 12(f)). The reports hold only the technical details we need to find and fix problems.

### C2. Privacy Policy section for adults (document `privacy`)

Add as a new section after "What we never do" and before "Your rights".

### Speed and error reports

To find slow screens and errors, the web app sends short technical reports. They include the app version, whether this is a first visit, a return visit or the first visit after an update, your browser family, your screen-size group, loading times, and error messages, counts and locations in our code. We remove common personal details, such as email addresses, before a report is sent. We do not deliberately include your answers or lesson content.

The stored report does not contain your account ID. Sending it uses your sign-in session, including a guest session, to check the request and to limit how many reports are sent. Google's connection logs may also record your IP address and browser details. Combined with other information, these can sometimes identify a person. We do not use them to identify you.

We keep these report logs for 30 days. The reports are on for everyone who uses the web app and are separate from optional usage sharing. Our legal basis is our legitimate interest in keeping Pantas working and fast (Data Privacy Act, Section 12(f)). You can object by emailing dpo@pantas.study.

### C3. Legitimate-interest assessment, for your file

NPC Circular 2023-07 expects a written assessment before relying on Section 12(f). This is
the record. Review it when the reports, the retention, or the users change.

- **Purpose.** Find slow loading steps and recurring errors on real users' browsers. Web
  errors were recorded nowhere before this. Fixes benefit users.
- **Necessity.** Opt-in only was tried as option B in the telemetry spec and rejected: sharing
  starts off, so too few reports would arrive. Data is kept small: no account ID, browser
  family instead of the full browser string, screen-size group instead of pixels, error text
  filtered on the device, a fixed list of fields that the server enforces, rate limits,
  nothing stored in the app database, 30-day log retention.
- **Balancing.** Ordinary technical data. Users include teens aged 13 to 17, but the report
  fields reveal nothing about age, school or ability. Remaining risks: an unfiltered name or
  free text inside an error message, and IP addresses in Google's connection logs, which a
  person with log access could join to a report. Safeguards: the field allow-list, device
  filtering, 30-day retention, and no use of connection logs to identify anyone.
- **Objections.** An objection arrives by email. There is no switch to stop one person's
  reports today, so the owner cannot yet honor an objection for future reports. Part E lists
  the fix.
- **Conclusion.** Section 12(f) is defensible for this processing once the Part E checks pass.

---

## What changed after the Codex critique

The critique called draft v1 "not ready to publish" and gave 50 findings. The lead verified
the factual ones in source before accepting them.

Corrected because the source contradicted draft v1:

- **Optional usage sharing.** Draft v1 said it sends screens and session events only. The app
  also sends question IDs, the chosen answer and whether it was correct, linked to the
  account ID (`submit_answer.dart`). Restored in Part A. Leaving it out would make the consent
  invalid.
- **Guardian answer record.** Draft v1 said it is deleted with the account. The app keeps it in
  a separate record that survives deletion (`guardianConsent.ts`, `guardianConsentEvidence`).
  Now disclosed.
- **Telemetry anonymity.** Draft v1 said "We cannot link a report to you." Sending a report
  uses the sign-in session, and a hash of the account ID sets the rate limit. Replaced with
  what is true.
- **Telemetry fields.** Added the app version, visit type, error counts and code locations.
- **Access start.** Draft v1 said access starts when PayMongo confirms. A plan period counts
  from PayMongo's recorded payment time. Passes run on their own. Corrected.
- **Providers.** RevenueCat added for app-store purchases.

Changed because the clause was void, misleading, or likely to be read against Pantas:

- **Refunds.** Draft v1 said "A payment is final once access started" and "A student cannot ask
  for a partial refund." The Consumer Act allows a price reduction for a defective service and
  bars clauses that exclude that liability. Firm wording that sounds absolute can be read
  against Pantas. The same limits now sit under "voluntary refund policy", and one sentence
  keeps the legal remedies. Your decisions still apply: refunds for errors only, no partial
  refunds on request, no pass refunds after the exam.
- **Goodwill partial refunds.** These still shorten access. That now applies only to an agreed
  cancellation, not to a refund the law requires for a defect.
- **Bank disputes.** Draft v1 ended all access and allowed suspending the whole account for any
  dispute. Punishing a good-faith dispute is out of proportion and may itself breach the
  contract. Now: access is suspended while the dispute is open, ends if the payment is
  reversed, and returns if Pantas wins. The code already restores access after a win.
- **Minors.** Draft v1 said "the person whose payment method is used is responsible." That
  does not bind an adult who never agreed. Now the parent or guardian must make the purchase
  and accepts the Terms as the buyer. A contract made directly with a 13 to 17 year old can be
  annulled, and no clause can waive that.
- **Trial.** "We decide who qualifies" was replaced with the actual rule, plus the right to
  change future offers. An advertised offer cannot be refused at will.
- **Retention promises.** Draft v1 promised a 24-month inactivity purge and a 24-month
  trial-code purge. Neither exists, and trial codes carry no date, so neither promise can be
  kept. Both now state periods the app already meets: study records while the account exists,
  and trial codes while trials are offered. Both periods are longer, which favors Pantas.
- **Analytics and phone error reports.** Draft v1 said "no more than 14 months" and "90 days".
  Now "up to 14 months after your last activity" and "starts removing after 90 days", which
  match how Google actually works.
- **Legal bases.** Draft v1 described the guardian's general confirmation as the permission for
  optional sharing. A general agreement cannot cover a separate optional use. Optional
  sharing is now described as its own permission.

Critique points not adopted, and why:

- **"Replace 15 calendar days with promptly."** Not adopted. pantas.study already publishes 15
  calendar days, and two different promises would conflict. You can drop it on both later.
- **"Withdraw through the confirmation page."** Not adopted. That route does not exist, and
  the notice must not describe it. The email route stays. The gap is risk 3.
- **"State that the internal complaint process ends after seven days."** Not adopted. The
  critique cites the Internet Transactions Act rules for it, but the lead could not confirm
  that those rules require Terms to say it. Saying it would only send buyers to the DTI
  sooner. The complaint email stays. Risk 6.

---

## D. Risks you accept

1. **No lawyer reviewed this.** The critique corrected several citations in draft v1, and some
   remain unconfirmed (Part E, check 6). A clause can still fail in a dispute.
2. **Teen consent is weaker than the notice implies.** The app reads the birth year before any
   guardian confirms. The confirmation page has no separate choice for optional sharing, so a
   teen can turn it on alone. The notice cannot fix this. Exposure: an NPC complaint that
   consent for sensitive data was not valid.
3. **Withdrawal is by email only.** Consent takes a checkbox and a button. NPC rules say
   withdrawal should be about as easy, so email only may not meet that.
4. **Indefinite retention.** Study records of abandoned accounts, trial codes and guardian
   answer records have no end date. This is lawful only while there is a real need. The NPC
   could call it storage longer than necessary.
5. **Purchases for minors.** Checkout does not check who pays, and it does not record an adult
   accepting the Terms. A parent can still ask to undo a teen's purchase. Expect to refund
   such cases.
6. **Online-seller duties.** The Internet Transactions Act requires your business name,
   physical address, phone number and email on the website's homepage, plus invoices for
   sales and a complaint route. Website copy is yours to write, so none of this was drafted.
   Exposure: DTI enforcement once paid sales start.
7. **Always-on telemetry.** Google's connection logs probably hold IP addresses. The
   legitimate-interest assessment supports the reports. However, no per-person way to stop
   them exists yet, so an objection cannot be honored for future reports.
8. **The adult Privacy Policy is still a stub.** Adding the telemetry section does not give
   adults the full notice the Data Privacy Act expects: who runs Pantas, purposes, bases,
   recipients, retention and rights. Teens get the full notice and adults do not.
9. **Not rewritten:** the Terms section "Use of the app and limits of responsibility" still
   carries the cautious Nov 5 wording. It was outside this task.

---

## E. Before publishing: builds and checks

Not done here. The application code was not changed. Each item is a separate task.

1. **Check the Google log settings (two minutes, needs `gcloud` or the Cloud console).**
   Confirm the `_Default` log bucket on pantas-prod keeps logs for 30 days, that no log sink
   copies them elsewhere, and whether `reportClientTelemetry` request logs hold
   `httpRequest.remoteIp`. If retention differs, change "30 days" in A and C2.
2. **Set Analytics retention** in the Firebase console. If it is set to 2 months, change "up to
   14 months" to "up to 2 months".
3. **Put the texts in the app** on `web/design-system-4`: the `teens`, `terms` and `privacy`
   documents in `lib/features/legal/domain/legal_document.dart`. Change the version date in
   `guardianDocumentVersions` and in `GUARDIAN_DOCUMENT_VERSIONS`
   (`functions/src/guardianConsent.ts`) in the same release.
4. **Recommended builds to shrink the risks**, in this order: an opt-out switch for speed
   reports (risk 7); a separate optional-sharing choice on the guardian page (risk 2); a
   withdraw button on the guardian page (risk 3); adult acceptance of the Terms at checkout
   (risk 5); end dates for the guardian answer record and trial codes (risk 4).
5. **Bookkeeping.** Account deletion removes the app's own payment index. Keep the five-year
   accounting records outside the app, for example in PayMongo exports and your books.
6. **Unconfirmed citations** to check if a dispute arises: the Internet Transactions Act and its
   rules (section numbers), Consumer Act Arts. 102 and 105 to 106, and NPC Advisory 2024-03 on
   child-oriented transparency.

## Record

- Draft v1 (Sonnet subagent): `docs/legal/drafts/2026-11-09-r1/draft-v1.md`
- Critique (Codex GPT 6.1 Sol, high effort, via `codex-pick`, account b):
  `docs/legal/drafts/2026-11-09-r1/critique-v1.md`
- Source checked: `origin/web/design-system-4` at 89559a2e2 and 7fcfc135a. The two heads do
  not differ in the legal, guardian, telemetry, quiz or functions files.
