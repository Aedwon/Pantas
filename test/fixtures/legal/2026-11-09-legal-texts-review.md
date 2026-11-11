# Legal texts for Aedwon's check: privacy batch edition

Revised November 9, 2026, on `docs/legal-texts-r1`. Policy commit: origin/main 21d7f6af5.
Not published and not built. No lawyer has reviewed this; Aedwon accepted that risk ("yeah no
way, no money"). Aedwon checks the wording only.

**Publish together with the privacy batch, not before.** These texts describe the app after the
batch in `docs/superpowers/specs/2026-11-09-privacy-batch-design.md` is built. Publishing them
earlier would make several statements false.

## What you are checking

- **A. Teen notice**, the in-app "Notice for teens", revised for the approved remedies.
- **B. Terms, "Subscriptions"**, revised for the minor checkout box and the complaint route.
- **C. Telemetry legal basis**, with the legitimate-interest assessment for your file.
- **D. Adult Privacy Policy**, new and complete, mirroring the teen notice (remedy 8).
- **E. Terms, "Use of the app" through "Changes to these Terms"**, rewritten (remedy 9).

If the wording is fine, say so. The batch puts it in the app.

## How it was made

1. Round 1 (earlier today): a Sonnet draft, a Codex GPT 6.1 Sol high critique, and a lead
   revision. The record is in `2026-11-09-r1/`.
2. Round 2 (this edition): a Sonnet draft for the remedies and texts 8 and 9, then a Codex
   GPT 6.1 Sol high critique through `codex-pick`, then a Sonnet revision on the lead's
   rulings, then lead fixes. The record is in `2026-11-09-r2/`.

## One change to what you approved

Remedy 2 described the age check as screening under legitimate interest, not consent. That
does not hold: age is sensitive information under the Data Privacy Act, and legitimate
interest (Section 12(f)) covers only ordinary information. Codex and the drafter agreed.

The fix is one line on the existing age step: "Pantas uses your birth year once, on this
device, to set your age group. We keep only the group." Choosing Continue is the permission.
The birth year is still discarded at once. The spec carries this as choice 11, and the
wording is the lead's call under written rule 4.

## What else the critique changed

- **Adult study records need specific permission,** because answers and results can count as
  education information. The setup acceptance will name study records.
- **"I'm 18 now" in Settings.** Without it, a lifelong guardian link could let a former
  guardian delete an adult's account. It also closes the Nov 2 gap of a student who turns 18
  staying marked as a minor.
- **Guardian evidence is kept ten years, not nine.** The birth-year check admits some
  12-year-olds, who can be six years from 18. Civil Code Art. 1391 then allows four more years
  to challenge a contract made as a minor. Ten years covers every admitted minor.
  - The purchase confirmation is copied into that evidence when an account is deleted.
  - The clock runs from the most recent guardian response.
- **Liability cap.** Draft v2 called its ₱1,000 a floor, but the clause did not work that way.
  The cap is now the greater of ₱1,000 or the amount paid in the last 12 months, and it
  applies only to claims the law lets Pantas limit. Statutory consumer damages, privacy
  compensation, fraud, bad faith and gross negligence are listed first as outside the cap.
- **Venue.** Draft v2 made South Cotabato courts the only venue. Codex judged that this would
  invite a fight with consumers that is not worth having. The exclusive venue now applies
  only to non-consumer civil disputes, and consumers keep the venues the law gives them.
- **Complaints.** The Terms now say the internal complaint process is exhausted after seven
  unresolved days, as the Internet Transactions Act requires.
- **Telemetry wording.** The reports have "no dedicated account ID or IP address field". Error
  text may still hold personal information. The opt-out switch works per device.
- **Inactivity wording.** Inactivity is measured from server-side sign-in and session activity,
  so a student must open Pantas while connected to keep the account.
- **New sections:** how software uses answers (review dates and study-style labels), changes to
  the notice, keeping data safe, and how long messages are kept (two years after closing).
- **Scores** are "recorded performance", not "estimates". The phrase "you are responsible for
  what happens in your account" became "activity you authorize".

Not adopted: replacing "15 calendar days" with "promptly", because pantas.study already
publishes 15 days.

---

## A. Teen notice (document `teens`)

> Publish together with the privacy batch, not before.

### Who this is for

This notice is for teens ages 13 to 17 and for their parents or guardians. Pantas is for people aged 13 and older.

If you are 18 or older, read the Privacy Policy instead.

### Who runs Pantas

Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services, a sole proprietorship. He is also the Data Protection Officer.

Address: Poblacion, Norala, South Cotabato, Philippines.

Questions about your data: dpo@pantas.study
Help or payment problems: support@pantas.study

### Why we ask your age

Before we ask for your age, this step tells you what we do with it. When you set up Pantas, we ask you to enter your correct current age in full years. We use it once, on your device, to decide whether you can use Pantas and whether a parent or guardian must consent. Based on the age you enter, Pantas blocks use if you are under 13 and requires your parent or guardian's consent if you are 13 to 17. We do not save the age you enter. Our servers never receive it. Your device keeps your age group and the version of the age check notice. If you are under 13, it keeps only a block, so Pantas stays closed to you until support clears it.

Choosing Continue means you give your specific permission for this age check. You may go back instead. Pantas requires this check before you can use it.

If you are in the under-18 group, our servers record that group when you send the guardian request. This happens before your guardian answers. We also record the age check notice version when your app sends it. We use the request record to send and check the request. We use your under-18 group to require a parent or guardian's confirmation of the current Terms for web purchases.

If your guardian declines or does not answer, we remove the request's contact details, status and age check notice version during scheduled cleanup. We keep your under-18 group until your account is updated to 18 or older, or your account is deleted. Separate guardian-answer records and guardian page links follow the periods under “How long we keep data.”

When you turn 18, open Settings and choose "I'm 18 now." Enter your current age and choose Continue. If you are 18 or older and the update succeeds, our servers record that you are 18 or older, your guardian's controls end and the guardian page links stop working.

### What we collect

- Account: an account ID, which Pantas creates even before you sign in. If you sign in with Google, we also receive your name, email address and profile photo. If you sign in with an email code, we receive your email address.
- Study records: your study settings, answers, results, study times, bookmarked lessons and flagged questions.
- Guardian request: your guardian's name and email address. We keep the request status, its dates, a partly hidden version of the email address, and protected codes made from the email address and the link. Our servers do not keep the full email address. Your guardian's full name and email address stay on your device so you can resend the request. Your device deletes them once it learns the guardian has confirmed.
- Guardian answer record: your guardian's answer, when it happened, which versions of our notices and terms were shown, and your account ID. It holds no name or email address. We add a line each time your guardian changes a permission or withdraws it.
- Payments: if someone buys Pro for your account, we keep payment references, amounts, payment status, refunds and access dates. Card and wallet details are entered on PayMongo's checkout page. For a purchase on an under-18 account, we also record that the buyer ticked the parent or guardian box, with the date, time and Terms version.
- Free trial: protected codes made from your verified sign-in details, so we can check whether a trial was already used.
- Share cards: if you choose to share a Wrapped card, we keep the card image and a public link to it. You can remove it at any time.
- Messages: emails you or your guardian send to support@pantas.study or dpo@pantas.study.
- Technical records: security and account records, such as sign-ins, payment checks and account deletions.

### How Pantas uses your answers

Software uses your answers and study timing to choose review dates and show study guidance. It also gives you a study-style label, such as the ones on share cards. These suggestions affect what Pantas recommends next. They do not decide any official exam eligibility or result.

### Optional usage sharing

Sharing starts off. Your guardian must allow it before it can turn on. After that, you can turn it off in Settings. Your guardian can also withdraw that permission on the guardian page.

If it is on, reports include the screens and features you use, your study sessions, question IDs, the answer you chose, and whether it was correct. These reports are linked to your account ID. The phone app can also send error reports.

Leaving it off does not stop you from using Pantas. Your guardian can also email dpo@pantas.study about reports already collected.

### Speed and error reports

To find slow screens and errors, the web app sends short technical reports. They include the app version, whether this is a first visit, a return visit or the first visit after an update, your browser family, your screen-size group, loading times, and error messages, counts and locations in our code. We filter common identifiers, such as email addresses, before a report is sent. Error text may still contain personal information. We do not deliberately include your answers or lesson content.

Reports have no dedicated account ID or IP address field. Sending a report uses your sign-in session, including a guest session, to check the request and to limit how many reports are sent. We exclude this function's request logs from our default log storage. Google processes connection information to deliver requests.

We keep the stored report logs for 30 days. These reports are on by default and are separate from optional usage sharing. The switch in Settings, then About, stops future reports from this browser or device. Repeat this on other devices. Email dpo@pantas.study for help, or for requests about reports already collected.

### Why a guardian confirms

If you are in the under-18 group, Pantas asks a parent or guardian to read the terms and confirm before you continue.

Opening the email link confirms nothing. The adult must tick the agreement box and choose Confirm. They can choose "I Don't Agree" instead.

The first link works once and expires after seven days. A new link replaces the old one. The first email also holds a link to the guardian page, which works once your guardian has confirmed. The confirmation screen shows the same link. The guardian page link works until you confirm you are 18, or until the account is deleted.

Anyone holding these links can use them to respond or manage permission. Keep them private. The links do not independently prove someone's identity or authority. Contact us if a link is lost, shared or misused.

### What your guardian can do

Your guardian can confirm or decline the request. Confirming does not give them a screen showing your results.

After confirming, your guardian can use the guardian page to:

- allow or withdraw optional usage sharing. It starts off.
- withdraw permission. This closes your account and deletes it, as the section on withdrawing explains.

Your guardian can also email our Data Protection Officer about your data. We may ask for information we reasonably need to check who is asking before we share information or act on instructions.

### Where your data goes

Some records stay in your browser or on your phone. On the web, your answers and study activity also go to our servers, including on Free. Our servers run in Google's Singapore region. Pro adds backup and syncing across devices.

We use these providers:

- Google (Firebase and Google Cloud): accounts, our servers, optional usage reports, and speed and error reports.
- Resend: guardian emails and sign-in codes.
- PayMongo: web payments.
- RevenueCat and the app store you use: app-store purchases and the Pro access they give.

These providers may process data outside the Philippines. We do not sell your data and we do not show ads.

### Your rights

You have the right to be informed about how your data is used. You can ask for a copy of your data, including in a common electronic format where the law allows. You can object to how it is used, ask us to fix wrong details, and ask us to stop using, block or delete data, when the law allows. You can ask for compensation where the law provides it. You can also complain to the National Privacy Commission.

Your guardian can use these rights for you while you are under 18. Send requests to dpo@pantas.study. We reply within 15 calendar days. We may ask for information we reasonably need to check who you are. If we cannot fully act on a request, we explain why.

### Withdrawing permission or deleting data

Your guardian can withdraw permission for you to use Pantas at any time. It is free. There are two ways:

- Open the guardian page link and choose "Withdraw permission."
- Email dpo@pantas.study with a message such as "I withdraw my permission for my child to use Pantas." Send it from the email address used for confirmation if you can, and include the account ID or sign-in email if you know it.

When permission is withdrawn, we disable the account, sign it out, and delete it in the same way as account deletion. We keep the guardian answer record and the record of the withdrawal, for the reasons in the next section. Pantas cannot work without a guardian's permission for study records, so the account cannot continue.

Withdrawing does not undo use of data that was lawful before. It does not cancel an app store subscription. It is not a refund request. Refunds follow the Terms.

You can delete your account yourself. Open Settings, then Account, then the delete option. For an account signed in with Google or an email code, this deletes your study records from our servers and clears Pantas data on the device you use. You may need to sign in again first. For an account that is not signed in, it clears data on your device only. To remove server records of such an account, email dpo@pantas.study.

Deleting your account removes its study records. Limited trial-use, guardian-answer, security and required accounting records may remain for the purposes and periods in the next section. Copies on your other devices stay until you clear them. Copies in our providers' backups are removed within 180 days of deletion.

### How long we keep data

- Study records and settings: while your account exists. We delete the account if you delete it, if your guardian withdraws permission, or if it has had no sign-in or study activity for 24 months. We identify inactivity from server-observed sign-in and session activity. Open Pantas while connected to keep the account active. We normally send a warning about 30 days beforehand if the account has a verified email address. An account with active paid access does not count as inactive. A guest account without an email address is deleted without a warning.
- Guardian requests and links: the first link works once and expires after seven days. Our hourly cleanup removes expired response links. It removes used, declined or replaced response links seven days after that event.

For an unanswered request, we remove the request's contact details, status and age check notice version during scheduled cleanup after the request expires. For a declined request, we remove them during scheduled cleanup seven days after the answer. Your under-18 group remains until your account is updated to 18 or older, or your account is deleted.

For a confirmed request, we remove contact details during scheduled cleanup seven days after confirmation. We keep the confirmation status, date and sharing choice while your account exists. We also keep the age check notice version if your app sent it. Guardian page links remain until the account is deleted or the links are revoked. Separate guardian-answer evidence follows the period below.
- Guardian evidence: we keep minimal guardian-response evidence while the account exists. This is the guardian answer record, the withdrawal record, and the purchase confirmation. When an account is deleted, we copy the purchase confirmation (date, time, Terms version and payment reference) into this evidence. After deletion, we normally remove it ten years after the most recent recorded guardian response. Relevant records may remain longer for a documented legal claim. We chose this period because a contract made by someone under 18 can be challenged until four years after that person turns 18.
- Free-trial codes: kept for as long as Pantas offers free trials, including after account deletion, so a trial cannot be repeated.
- Payment and accounting records: five years, counted as tax law requires from the filing deadline of the related tax return. Records may stay longer while a tax matter is unresolved.
- Our database security records: 730 days after the event.
- Optional usage reports: Google Analytics keeps event records for up to 14 months after your last activity. This is the longest setting Google allows. Google starts removing phone error reports after 90 days.
- Speed and error report logs from the web app: 30 days.
- Share cards: until you remove the card or the account is deleted.
- Messages to us: kept for up to two years after the matter closes, then deleted.

If the law requires it, or we need specific records for a legal claim, we may keep those records longer.

### Why we may use your data

- Age check: your specific permission, given at the age step (Data Privacy Act, Section 13(a)). We use your age only on your device without saving it. The device keeps only your age group and the version of the age check notice, or a block if you are under 13.
- Age-group record and guardian evidence: we rely on Section 13(f) for processing necessary to establish, exercise or defend legal claims. These include claims about whether you can legally agree to the Terms or whether your parent or guardian allowed your account or purchase. We rely on this basis before your guardian answers, including if they decline or do not answer. After your guardian confirms, we also rely on their specific permission for continued use of your age group (Section 13(a)). For related ordinary personal information needed for those legal claims, we rely on Section 12(f).
- Account and payment records: we need them to provide the service you asked for (Section 12(b)).
- Study records: your guardian's specific permission (Section 13(a)). Answers and results can relate to education.
- Optional usage sharing: your guardian's separate permission. It can be withdrawn at any time.
- Speed and error reports, security records, trial codes, and a guardian request's contact and request details: our legitimate interest in keeping Pantas working, safe and fair (Section 12(f)). We keep each to what we need.
- Accounting records: the law requires them.

### Changes to this notice

We notify you in the app, in plain language, before we change the processing described here. We also notify your guardian. If a change needs new permission, we ask before starting it.

### Payments for minors

If you are under 18, your parent or guardian must make the purchase. At checkout, they must tick the box "I am the parent or guardian and accept the Terms." Checkout does not work without it. On the web, we record the tick with the date, time and Terms version when checkout starts.

Confirming your account is not a purchase. The buyer must be allowed to use the payment method.

---

## B. Terms, "Subscriptions" (document `terms`)

> Publish together with the privacy batch, not before.

### Subscriptions

**App store purchases.** If you buy through an app store, your paid features depend on your active store subscription. Use the store account you bought with for billing, cancellation and store refund requests. Contact us about problems with Pantas itself.

**Web purchases.** On the web, you buy Pro access in advance and pay through PayMongo. Web purchases do not renew automatically. If you want more access, you buy again. A web purchase does not cancel a separate store subscription.

**Price.** The price is the amount shown in Philippine pesos on the Pro screen and at checkout when you pay. That amount is the full amount you pay. Check the plan and amount before you pay. We may change prices at any time. A change does not affect a payment you already made. Checkout shows the payment methods you can use.

**Plans.** Weekly access lasts seven days. Monthly access lasts one calendar month. Yearly access lasts one calendar year. These plans give Civil Service Pro access. Monthly and Yearly access ends on the matching date at the same time in Philippine time. If that date does not exist, it ends on the last day of that month. A Season Pass covers its named exam until the end of the last day of the exam sitting stated at checkout.

**When access starts.** We turn on access after we verify your payment with PayMongo. A plan period counts from the payment time PayMongo records, or from the end of your existing qualifying Pro access, whichever is later. A Season Pass runs from payment until its stated sitting and does not add to other passes. Returning from checkout does not confirm your payment. If you paid and Pro does not appear, email support@pantas.study with your payment details.

**Free trial.** You can get one seven-day free trial of Monthly Pro if you qualify. You qualify only if you are signed in with verified sign-in details and have not had a trial or paid Pro before. You do not enter payment details. The trial ends after seven days. It does not become a paid plan and we do not charge you. We may change or stop future trial offers. We may refuse or end a trial we reasonably suspect is being misused, for example through several accounts. Deleting your account does not give you another trial.

**Free or promotional access.** Pantas may give free access, such as a trial, a beta period or a prize, at its choice. This access lasts only for the period we state. It can end earlier if it is misused. It does not give you a right to more access and it does not start a paid plan.

**Refunds.** Under our voluntary refund policy, we refund in full:

- an extra payment for a period that has not started, such as a payment made twice; or
- a payment that never gave you the access you bought.

Email support@pantas.study within 30 days of the payment, with enough details to find it. We refund to the original payment method through PayMongo. The time the money takes to reach you depends on PayMongo and your bank.

We do not give refunds for a change of mind, or partial refunds for unused time. A period that has started, or a Season Pass whose exam date has passed, is outside this voluntary policy.

We may give other refunds as goodwill. A goodwill refund does not create a right to more refunds. If we agree to cancel a purchase with a partial refund, the remaining access is shortened in proportion to the amount refunded. A refund that the law requires for a defective service does not shorten your access.

These limits and the 30-day deadline do not limit any remedy Philippine law gives you, such as for a service that did not work as promised.

**Disputes with your bank.** If you dispute a payment with your bank or card issuer, we may suspend the access that payment gave while the dispute is open. If the payment is reversed, that access ends. If the dispute is resolved in our favor, the access returns. We may restrict an account we reasonably suspect of fraud or abuse.

**Ending Pro.** When your Pro access ends, Pro-only features stop unless another plan or pass covers the exam. You can keep using Free features. Pro backup and syncing stop while you do not have Pro. Ending Pro does not by itself delete your progress. Your data follows the storage periods in our privacy notices.

**Deleting your account.** If you delete your account, your access ends, including any time left on a plan. Deleting your account is not a refund request. The same applies if a parent or guardian withdraws permission for an under-18 account, or if we delete an account that has been inactive for 24 months. An account with active paid access is not treated as inactive.

**Students under 18.** If you are under 18, your parent or guardian must make the purchase. At checkout, the buyer must tick "I am the parent or guardian and accept the Terms." Checkout does not work without it. On the web, we record the tick with the date, time and Terms version when checkout starts. By ticking, the buyer confirms they are the parent or guardian, that they accept these Terms as the buyer, and that they are allowed to use the payment method chosen. We rely on that confirmation. If we learn that someone who is not a parent or guardian ticked the box, we may cancel the purchase, refund it and end the access.

**Complaints.** Send purchase complaints to support@pantas.study with the transaction reference and a description of the problem. If it is unresolved after seven calendar days, our internal complaint process is deemed exhausted.

---

## C. Telemetry legal basis

> Publish together with the privacy batch, not before.

### C1. The legal-basis line

> Speed and error reports (web): our legitimate interest in keeping Pantas working and fast (Data Privacy Act, Section 12(f)). The reports have no dedicated account ID or IP address field, and we filter common identifiers from error text. The switch in Settings, then About, stops future reports from that browser or device.

### C2. Legitimate-interest assessment, for your file

- **Scope.** Assess the signed-in request, the temporary account-derived rate-limit key kept in memory, Google's connection handling, and the stored report together. Treat all of it as personal-data processing.
- **Purpose.** Find slow loading steps and recurring errors on real browsers.
- **Necessity.** Record why each remaining field is needed: app version, visit type, browser family, screen-size group, timings, and error type, message, location and count. Compare with fixed error codes only, sampling, and opt-in reporting. Write down why each was rejected or accepted.
- **Balancing.** Users include teens. Weigh their expectations, how often reports are sent, and the risk that an error message holds a name, an email address, an IP address or other sensitive text. A switch improves the balance. It does not prove necessity.
- **Safeguards.** Fixed field list enforced by the server, device filtering, 30-day log retention, request-log exclusion, no use of connection data to identify anyone.
- **Objections.** The switch is local. An emailed objection gets a real assessment and help, including for reports already collected.
- **Conclusion.** Section 12(f) is defensible for minimized ordinary telemetry. It cannot cover sensitive data that ends up in an error by accident. Review whenever the fields, retention or users change.

---

## D. Adult Privacy Policy (document `privacy`)

> Publish together with the privacy batch, not before.

### Who this is for

This policy is for people aged 18 and older. If you are under 18, read the Notice for teens instead.

### Who runs Pantas

Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services, a sole proprietorship. He is also the Data Protection Officer.

Address: Poblacion, Norala, South Cotabato, Philippines.

Questions about your data: dpo@pantas.study
Help or payment problems: support@pantas.study

### Why we ask your age

Before we ask for your age, this step tells you what we do with it. When you set up Pantas, we ask you to enter your correct current age in full years. We use it once, on your device, to decide whether you can use Pantas and whether a parent or guardian must consent. Based on the age you enter, Pantas blocks use if you are under 13 and requires your parent or guardian's consent if you are 13 to 17. We do not save the age you enter. Our servers never receive it. Your device keeps your age group and the version of the age check notice. If you are under 13, it keeps only a block, so Pantas stays closed to you until support clears it.

Choosing Continue means you give your specific permission for this age check. You may go back instead. Pantas requires this check before you can use it.

### What we collect

- Account: an account ID, which Pantas creates even before you sign in. If you sign in with Google, we also receive your name, email address and profile photo. If you sign in with an email code, we receive your email address.
- Study records: your study settings, answers, results, study times, bookmarked lessons and flagged questions.
- Payments: if you buy Pro, we keep payment references, amounts, payment status, refunds and access dates. Card and wallet details are entered on PayMongo's checkout page.
- Free trial: protected codes made from your verified sign-in details, so we can check whether a trial was already used.
- Share cards: if you choose to share a Wrapped card, we keep the card image and a public link to it. You can remove it at any time.
- Messages: emails you send to support@pantas.study or dpo@pantas.study.
- Technical records: security and account records, such as sign-ins, payment checks and account deletions.

### How Pantas uses your answers

Software uses your answers and study timing to choose review dates and show study guidance. It also gives you a study-style label, such as the ones on share cards. These suggestions affect what Pantas recommends next. They do not decide any official exam eligibility or result.

### Optional usage sharing

Optional usage sharing helps us improve Pantas. It starts off. You choose whether to turn it on. It is a separate choice from setting up your account, and leaving it off does not stop you from using Pantas.

If you turn it on, reports include the screens and features you use, your study sessions, question IDs, the answer you chose, and whether it was correct. These reports are linked to your account ID. The phone app can also send error reports.

To turn it off, open Settings, then About, and use "Help improve Pantas by sharing usage data." You can also email dpo@pantas.study about reports already collected.

### Speed and error reports

To find slow screens and errors, the web app sends short technical reports. They include the app version, whether this is a first visit, a return visit or the first visit after an update, your browser family, your screen-size group, loading times, and error messages, counts and locations in our code. We filter common identifiers, such as email addresses, before a report is sent. Error text may still contain personal information. We do not deliberately include your answers or lesson content.

Reports have no dedicated account ID or IP address field. Sending a report uses your sign-in session, including a guest session, to check the request and to limit how many reports are sent. We exclude this function's request logs from our default log storage. Google processes connection information to deliver requests.

We keep the stored report logs for 30 days. These reports are on by default and are separate from optional usage sharing. The switch in Settings, then About, stops future reports from this browser or device. Repeat this on other devices. Email dpo@pantas.study for help, or for requests about reports already collected.

### Where your data goes

Some records stay in your browser or on your phone. On the web, your answers and study activity also go to our servers, including on Free. Our servers run in Google's Singapore region. Pro adds backup and syncing across devices.

We use these providers:

- Google (Firebase and Google Cloud): accounts, our servers, optional usage reports, and speed and error reports.
- Resend: sign-in codes and emails we send you.
- PayMongo: web payments.
- RevenueCat and the app store you use: app-store purchases and the Pro access they give.

These providers act for us under their own terms. They may process data outside the Philippines. We stay responsible for the data we give them. We may also share data when the law requires it, or when we need it to deal with fraud or a legal claim.

We do not sell your data. We do not show ads.

### Your rights

You have the right to be informed about how your data is used. You can ask for a copy of your data, including in a common electronic format where the law allows. You can object to how it is used, ask us to fix wrong details, and ask us to stop using, block or delete data, when the law allows. You can ask for compensation where the law provides it. You can also complain to the National Privacy Commission (privacy.gov.ph).

Send requests to dpo@pantas.study. We reply within 15 calendar days. We may ask for information we reasonably need to check who you are. If we cannot fully act on a request, we explain why.

### Withdrawing permission or deleting data

You can withdraw a permission you gave, such as optional usage sharing, at any time. Withdrawing is free. It does not undo use of data that was lawful before you withdrew. If you withdraw permission for study records, we cannot run your account and we close it.

To delete your account, open Settings, then Account, then the delete option. For an account signed in with Google or an email code, this deletes your study records from our servers and clears Pantas data on the device you use. You may need to sign in again first. For an account that is not signed in, it clears data on your device only. To remove server records of such an account, email dpo@pantas.study.

Deleting your account removes its study records. It does not cancel an app store subscription. Limited trial-use, security and required accounting records may remain for the purposes and periods in the next section. Copies on your other devices stay until you clear them. Copies in our providers' backups are removed within 180 days of deletion.

### How long we keep data

- Study records and settings: while your account exists. We delete the account if you delete it, or if it has had no sign-in or study activity for 24 months. We identify inactivity from server-observed sign-in and session activity. Open Pantas while connected to keep the account active. We normally send a warning about 30 days beforehand if the account has a verified email address. An account with active paid access does not count as inactive. A guest account without an email address is deleted without a warning.
- Free-trial codes: kept for as long as Pantas offers free trials, including after account deletion, so a trial cannot be repeated.
- Payment and accounting records: five years, counted as tax law requires from the filing deadline of the related tax return. Records may stay longer while a tax matter is unresolved.
- Our database security records: 730 days after the event.
- Optional usage reports: Google Analytics keeps event records for up to 14 months after your last activity. This is the longest setting Google allows. Google starts removing phone error reports after 90 days.
- Speed and error report logs from the web app: 30 days.
- Share cards: until you remove the card or the account is deleted.
- Messages to us: kept for up to two years after the matter closes, then deleted.

If the law requires it, or we need specific records for a legal claim, we may keep those records longer.

### Why we may use your data

- Age check: your specific permission, given at the age step (Data Privacy Act, Section 13(a)). We use your age only on your device without saving it. The device keeps only your age group and the version of the age check notice, or a block if you are under 13.
- Account and payment records: we need them to provide the service you asked for (Section 12(b)).
- Study records: your specific permission (Section 13(a)), given at setup when you accept the Terms and Privacy Policy. Answers and results can relate to education.
- Optional usage sharing: your separate permission (Sections 12(a) and 13(a)). You can withdraw it at any time.
- Speed and error reports, security records and trial codes: our legitimate interest in keeping Pantas working, safe and fair (Section 12(f)). We keep each to what we need.
- Accounting records: the law requires them (Section 12(c)).
- Messages to us: we need them to answer you.

### Keeping data safe

We use reasonable organizational, physical and technical measures to protect your data. If a breach is likely to put you at real risk, we tell you and the National Privacy Commission as the law requires.

### Changes to this policy

We notify you before we change the processing described here. If a change needs new permission, we ask before starting it.

---

## E. Terms: use of the app, limits and disputes (document `terms`)

> Publish together with the privacy batch, not before.

Replaces "Use of the app" and "Use of the app and limits of responsibility". Order in the app: Use of the app; Subscriptions; Study content and results; Changes, suspension and ending; Limits of responsibility; Intellectual property; Governing law and disputes; Changes to these Terms.

### Use of the app

Pantas is a study tool for exam practice. You may use it for your own study. You must be 13 or older. If you are under 18, a parent or guardian must agree before you continue, as the Notice for teens explains.

When you use Pantas, you agree to:

- give true information when you set up your account;
- keep your sign-in details private and tell us promptly about suspected misuse. You are responsible for activity you authorize;
- use one account for yourself and not share your sign-in;
- not copy, scrape, resell or reverse-engineer the app or its content;
- not attack, overload or try to break into the app or any account;
- not misuse trials, payments, limits or promotions; and
- follow the law.

Pantas is independent. It is not part of, approved by or connected to the Civil Service Commission or any other government office or exam body.

### Study content and results

Pantas does not guarantee a passing result, admission, a job, a license or any particular score. Exams are set by others. Check the official exam instructions, eligibility requirements, schedules and announcements.

We prepare lessons, questions and explanations with care. They can still contain mistakes or fall behind a change in an exam. The official exam source always comes first. Tell us about an error at support@pantas.study. We may correct or remove content at any time.

Scores show your recorded performance in Pantas. Progress indicators and review dates provide study guidance. They do not predict your official exam result.

Pantas is provided "as is" and "as available." We do not promise that it will run without interruption or errors, or on every device. This does not remove our duty to give you a service of the quality the law requires.

### Changes, suspension and ending

We may change, add or remove features, content and plans. We may pause the service for repairs or for reasons outside our control. We try to tell you about big changes in the app.

If we permanently end a Pro feature, or the whole service, while you have paid access, we refund the unused part of your payment.

We may suspend or close an account if you seriously break these Terms, misuse the app, put the app or other people at risk, make a payment we reasonably believe is fraudulent, or if the law requires it. We try to tell you why and let you reply first. We may act without notice if waiting would put others at risk or the law forbids notice. If you think we made a mistake, email support@pantas.study within 30 days. We will review it.

If we close your account for serious misuse, we do not refund unused paid time, unless the law requires a refund.

You can stop at any time by deleting your account.

### Limits of responsibility

We take reasonable care to run Pantas. Our responsibility follows Philippine law.

The exclusions and cap below apply only where Philippine law permits. They do not limit your statutory consumer remedies or damages. They do not limit your data privacy rights or compensation. They do not limit liability for fraud, bad faith, willful misconduct, gross negligence, death or personal injury.

For a good-faith breach of contract, recoverable damages follow Article 2201 of the Civil Code. Subject to the exceptions above, we exclude indirect or consequential loss, including lost income or lost opportunities, to the extent Philippine law permits.

For other claims arising from one event or related events, our total money liability is limited to the greater of ₱1,000 or the amount you paid Pantas for the affected account in the 12 months before the first event. This applies whether the claim is in contract, negligence or otherwise.

If a court finds part of these Terms is not allowed, the rest stays in force.

Payment providers, app stores, banks and other companies we use have their own terms and fees. We are not responsible for those terms or fees.

### Governing law and disputes

Philippine law governs these Terms and your use of Pantas.

If you have a problem, please email support@pantas.study first. We want to fix it.

Consumer proceedings may be brought in any place that applicable law and court rules allow. For other civil disputes, the parties agree to bring them only in the proper courts serving Norala, South Cotabato. You may always complain to the Department of Trade and Industry, the National Privacy Commission or any other government office.

### Changes to these Terms

We may update these Terms. We tell you in the app before a material change takes effect, at least 14 days ahead unless the law or security requires sooner. The date at the top shows the current version.

A change that makes your rights worse does not apply to access you have already paid for until that access period ends. If you do not accept a change, stop using Pantas and delete your account. If you keep using Pantas after the change takes effect, you accept it, except where the law requires your new permission.

---

## F. Risks you accept

1. **No lawyer reviewed this**, by your choice. Some citations are unconfirmed: the Internet
   Transactions Act rules (JAO 24-03) by section, and NPC Advisory 2024-03.
2. **A 13-year-old's own permission for the age check** may be challenged. The guardian's
   permission for the stored age group is the backstop.
3. **A guardian link proves no identity.** A teen with access to the guardian's inbox can use
   it. The texts say so plainly, which protects Pantas better than silence does.
4. **Adult study-record permission rests on the setup tick.** If the acceptance wording does not
   name study records, the basis fails. Build choice 12 covers this.
5. **Ten years of guardian evidence and trial codes kept while trials are offered** are Pantas's
   own periods. The NPC could call either too long. Keep access to them narrow.
6. **The liability cap and the no-refund-on-serious-misuse rule** hold only for claims the law
   lets Pantas limit. A court may cut either.
7. **A tick at checkout does not prove an adult paid.** A parent can still ask to undo a teen's
   purchase (Civil Code Art. 1390). The Terms let Pantas cancel and refund in that case.
8. **Owner duties not drafted, now tracked in the founder app's "Owner inputs" tab:**
   - the homepage business name, address and phone number, and invoices, as the Internet
     Transactions Act requires;
   - NPC registration and the signed child privacy assessment;
   - written terms with each processor;
   - a yearly clean-out of support and DPO mail older than two years.

## G. Before publishing

1. **Build the privacy batch** (spec and plan on this branch). Every statement about the
   guardian page, withdrawal, sharing, the age step, "I'm 18 now", the checkout box,
   inactivity deletion, the speed-report switch and the log exclusion depends on it.
2. **Log settings, checked Nov 9, read-only, on pantas-prod.**
   - The `_Default` bucket keeps logs for 30 days.
   - Only the built-in sinks exist, and the project has no parent organization.
   - Firestore runs in asia-southeast1 (Singapore).
   - The `reportClientTelemetry` request logs currently hold `remoteIp` and the full
     `userAgent`. The batch's exclusion removes them, so check again after deploy.
3. **Analytics retention: not readable.** The gcloud sign-in lacks the Analytics scope.
   "Up to 14 months" is Google's maximum, so the text is safe. To tighten it, open Analytics,
   then Admin, then Data retention.
4. **Backups.** "Removed within 180 days" relies on Firebase's data processing terms. If
   Firestore scheduled backups or point-in-time recovery is ever turned on, recheck the period.
5. **Version stamps.** Change them in the app and in the functions in the same release (spec
   choice 14).

## Record

- Round 1: `2026-11-09-r1/draft-v1.md`, `2026-11-09-r1/critique-v1.md`.
- Round 2: `2026-11-09-r2/draft-v2.md` (the lead's pre-critique fixes are noted on its first
  line), `2026-11-09-r2/critique-v2.md` (Codex GPT 6.1 Sol, high effort, via `codex-pick`),
  and `2026-11-09-r2/draft-v3.md` (Sonnet revision). The texts above are v3 plus the lead's
  two fixes: messages added to the teen notice, and an unverified guest-account sentence
  removed from the adult policy.
- Source checked: `origin/web/design-system-4` at 7fcfc135a; Codex read 5c960a4b, a later head.
