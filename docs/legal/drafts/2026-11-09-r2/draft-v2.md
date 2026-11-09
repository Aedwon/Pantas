> Lead fixes before critique (Nov 9): no follow-up guardian email (the manage link is in the first email and on the confirmation screen, per the batch spec); ten years, not nine, for guardian answer records, because the birth-year check admits some 12-year-olds; Firestore confirmed in asia-southeast1 (Singapore).

# Legal texts, draft v2: teen notice, Terms, telemetry basis, adult Privacy Policy, Terms "Use of the app"

Drafted November 9, 2026. Policy commit: origin/main 21d7f6af5. Source read: `origin/web/design-system-4`.
No lawyer has reviewed this. Application code was not changed.

**Publish together with the privacy batch, not before.** Every text below describes the app as it
will exist after the privacy batch is built (the approved remedies 2 to 5, 7 and 9). If any
build item in an "Assumes" list is not delivered, the matching sentence becomes false and must be
removed or changed before publishing.

Citation rule: a citation I read this session carries no mark. A citation I could
not read is marked "(unverified)". Read this session: Data Privacy Act (RA 10173) Secs. 3(l), 11(e),
12(f), 13, 16 on lawphil; Consumer Act (RA 7394) Arts. 97 to 106 on lawphil; Civil Code Arts. 1171,
1172, 1306, 1308, 1391, 1399, 2201 on lawphil. Everything else is from memory or a secondary
summary and is marked.

Contents: A teen notice. B Terms "Subscriptions". C telemetry basis. D adult Privacy Policy.
E Terms "Use of the app and limits of responsibility". F risks that remain.

---

## A. Teen notice (document `teens`)

> Publish together with the privacy batch, not before.

Replaces the 13 sections in the reviewed Part A. Each `###` heading is one section in the app.
Order: who, what, why, choices, rights, keeping.

### Who this is for

This notice is for teens ages 13 to 17 and for their parents or guardians. Pantas is for people aged 13 and older.

If you are 18 or older, read the Privacy Policy instead.

### Who runs Pantas

Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services, a sole proprietorship. He is also the Data Protection Officer.

Address: Poblacion, Norala, South Cotabato, Philippines.

Questions about your data: dpo@pantas.study
Help or payment problems: support@pantas.study

### Why we ask your age

When you set up Pantas, we ask for your birth year. We use it once, on your device, to work out your age group: under 18, or 18 and older. We then throw the birth year away. Our servers never receive it.

We keep only the age group. If you are in the under-18 group, we also record that on our servers with your guardian's request, so we know a guardian must agree.

We do not ask for your permission for this check. We cannot let anyone in without it, because a parent or guardian must agree for anyone under 18. You cannot turn this check off.

### What we collect

- Account: an account ID, which Pantas creates even before you sign in. If you sign in with Google, we also receive your name, email address and profile photo. If you sign in with an email code, we receive your email address.
- Study records: your study settings, answers, results, study times, bookmarked lessons and flagged questions. We use your answers and study times to choose your review dates and show your progress.
- Guardian request: your guardian's name and email address. We keep the request status, its dates, a partly hidden version of the email address, and protected codes made from the email address and the link. Your guardian's full name and email address also stay on your device so you can resend the request. Your device deletes them once it learns the guardian has confirmed.
- Guardian answer record: your guardian's answer, when it happened, which versions of our notices and terms were shown, and your account ID. It holds no name or email address. If your guardian later withdraws permission, we record that too.
- Payments: if someone buys Pro for your account, we keep payment references, amounts, payment status, refunds and access dates. Card and wallet details are entered on PayMongo's checkout page. For a purchase on an under-18 account, we also record that the buyer ticked the parent or guardian box, with the date, time and Terms version.
- Free trial: protected codes made from your verified sign-in details, so we can check whether a trial was already used.
- Share cards: if you choose to share a Wrapped card, we keep the card image and a public link to it. You can remove it at any time.
- Technical records: security and account records, such as sign-ins, payment checks and account deletions.

### Optional usage sharing

Optional usage sharing helps us improve Pantas. It is off on every under-18 account. You cannot turn it on yourself. Only your guardian can turn it on, as a separate choice on the guardian page. Your guardian can turn it off again at any time.

If it is on, reports include the screens and features you use, your study sessions, question IDs, the answer you chose, and whether it was correct. These reports are linked to your account ID. The phone app can also send error reports.

Leaving it off does not stop you from using Pantas. Your guardian can also email dpo@pantas.study about reports already collected.

### Speed and error reports

To find slow screens and errors, the web app sends short technical reports. They include the app version, whether this is a first visit, a return visit or the first visit after an update, your browser family, your screen-size group, loading times, and error messages, counts and locations in our code. We remove common personal details, such as email addresses, before a report is sent. We do not deliberately include your answers or lesson content.

The stored report does not contain your account ID or your IP address. Sending a report uses your sign-in session, including a guest session, to check the request and to limit how many reports are sent. We tell Google not to store its connection log entries for these reports. Those entries would hold your IP address and full browser details. Google still handles that information to deliver the request, as any website does.

We keep the stored report logs for 30 days. These reports are on by default and are separate from optional usage sharing. To turn them off, open Settings, then About, and use the speed and error reports switch next to usage sharing. You can also object by emailing dpo@pantas.study.

### Why a guardian confirms

If you are in the under-18 group, Pantas asks a parent or guardian to read the terms and confirm before you continue.

Opening the email link confirms nothing. The adult must tick the agreement box and choose Confirm. They can choose "I Don't Agree" instead.

The first link works once and expires after seven days. A new link replaces the old one. The first email also holds a link to the guardian page, which works once your guardian has confirmed. The confirmation screen shows the same link. The guardian page link works for as long as your account exists.

Keep these links private. We treat anyone who uses a link as your guardian.

### What your guardian can do

Your guardian can confirm or decline the request. Confirming does not give them a screen showing your results.

After confirming, your guardian can use the guardian page to:

- turn optional usage sharing on or off. It starts off.
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

You can also withdraw optional usage sharing alone. Your guardian turns it off on the guardian page. Your account stays open.

You can delete your account yourself. Open Settings, then Account, then the delete option. For an account signed in with Google or an email code, this deletes your study records from our servers and clears Pantas data on the device you use. You may need to sign in again first. For an account that is not signed in, it clears data on your device only. To remove server records of such an account, email dpo@pantas.study.

Deleting your account removes its study records. Limited trial-use, guardian-answer, security and required accounting records may remain for the purposes and periods in the next section. Copies on your other devices stay until you clear them. Copies held in our providers' backups can take longer to disappear.

### How long we keep data

- Study records and settings: while your account exists. We delete the account if you delete it, if your guardian withdraws permission, or if it has no sign-in or study activity for 24 months. About 30 days before, we send a warning email to the account's email address. Any activity cancels the deletion. An account with active paid access does not count as inactive. A guest account without an email address is deleted without a warning.
- Guardian requests and links: the first link stops working after seven days. Our hourly cleanup then deletes expired requests and links. A used, declined or replaced link is deleted seven days after that event. The guardian page link lasts as long as the account exists and is deleted with it.
- Guardian answer record, the withdrawal record and the purchase confirmation: kept while the account exists. After the account is deleted, we keep them until ten years after your guardian's answer. We keep them to show that a guardian agreed and to answer any claim. A contract made by someone under 18 can be challenged until four years after that person turns 18.
- Free-trial codes: kept for as long as Pantas offers free trials, including after account deletion, so a trial cannot be repeated.
- Payment and accounting records: five years, counted as tax law requires from the filing deadline of the related tax return. Records may stay longer while a tax matter is unresolved.
- Our database security records: 730 days after the event.
- Optional usage reports: Google Analytics keeps event records for up to 14 months after your last activity. Google starts removing phone error reports after 90 days.
- Speed and error report logs from the web app: 30 days.
- Share cards: until you remove the card or the account is deleted.

If the law requires it, or we need specific records for a legal claim, we may keep those records longer.

### Why we may use your data

- Age check: necessary screening that runs on your device. We rely on our legitimate interest in keeping young users safe and making sure the right adult agrees (Data Privacy Act, Section 12(f)). We keep the under-18 age group, and the guardian's answer, as evidence under Section 13(f), which covers establishing and defending legal claims. This is not a consent request.
- Account, study and payment records: we need them to provide the service you asked for (Section 12(b)). Study results can relate to education, so we also rely on your guardian's specific permission (Section 13(a)).
- Optional usage sharing: your guardian's separate permission. It can be withdrawn at any time.
- Speed and error reports, security records, guardian requests and trial codes: our legitimate interest in keeping Pantas working, safe and fair. We keep each to what we need.
- Accounting records: the law requires them.

### Payments for minors

If you are under 18, your parent or guardian must make the purchase. At checkout, they must tick the box "I am the parent or guardian and accept the Terms." Checkout does not work without it. We record the confirmation with the date, time and Terms version.

Confirming your account is not a purchase. The buyer must be allowed to use the payment method.

### Drafter notes for A

Basis and where it leans toward Pantas:

- **Age check, framing (the key legal issue).** Age is sensitive personal information (DPA Sec. 3(l)(1)). Sec. 12(f) is a Sec. 12 ground for ordinary information. It does not supply a Sec. 13 exception. NPC Circular 2023-07 is said to say the same (unverified). A text that says "age check under 12(f)" and stops would be an incomplete legal statement. So the text layers three things, each true:
  1. The check runs on the device. The birth year never reaches Pantas servers and is not saved. Source: `onboarding_age_gate_step.dart:139-181` (year held in memory, outcome decided locally, `setAgeGroup` writes to local device storage) and `app_preferences_repository.dart:80` ("Only the group is kept, never the birth year"). For an adult, no age data reaches Pantas at all. For an under-18, only the label `minor` reaches the server, written by the server itself when the guardian request is created (`guardianConsent.ts:189`).
  2. Sec. 12(f) for the screening step, as approved, because the information handled is a number the user chooses to enter and the aim is child protection and contract capacity.
  3. Sec. 13(f) for the stored under-18 label and the guardian answer record, as evidence to establish or defend claims (Civil Code Art. 1391: annulment of a minor's contract within four years after guardianship ceases; Art. 1399). Sec. 11(e) separately allows retention "for the establishment, exercise or defense of legal claims".
  4. Backstop: the guardian's specific permission under Sec. 13(a). Sec. 3(b) lets a lawful representative give consent. This covers everything stored after the guardian confirms.
- **Strength, honestly.** Adult path (nothing stored by Pantas, device only): fairly strong in practice. Legal weakness: whether on-device processing by an app Pantas designs is outside the Act is not settled (unverified). Under-18 label: moderate on 13(f) alone, because 13(f) is usually read as tied to an actual or anticipated claim. It becomes strong with the guardian's 13(a) permission as backstop. Weakest point: the birth year is processed before any guardian is involved, and later consent cannot cure that. Practical enforcement risk is low because nothing is kept. I rejected a Sec. 13(b) "child protection duty" framing. I know of no Philippine law that requires a private study app to check age. RA 7610, RA 11930 and NPC Advisory 2024-03 do not create that duty (unverified). Citing 13(b) would be a false claim.
- **Why a text that says "not consent".** It tells the truth about the design (no checkbox for the check), and it avoids an invalid consent that a 13-year-old cannot give alone (Circular 2023-04, unverified). The fallback to guardian permission is stated separately so the notice does not rest on "not consent" alone.
- **Optional usage sharing for under-18.** Reports hold answers and correctness linked to the account ID, which can be education information (Sec. 3(l)(2)). A separate guardian-only switch gives Sec. 13(a) consent via Sec. 3(b), and avoids bundling (Circular 2023-04, unverified section numbers). Source of what reports hold: `submit_answer.dart` (per the review file, not re-read here).
- **Speed and error reports.** Fields match `clientTelemetry.ts:13-40` (version, visit, browser family, mobile flag, viewport group, timings, errors with type, message, stack, count). The report log line holds no uid (`clientTelemetry.ts:7-11`). Rate limiting keys on a SHA-256 of the uid held in memory (`clientTelemetry.ts:106-137`). The sign-in session is used to authenticate (`clientTelemetry.ts` with `enforceAppCheck` import, line 4). The wording "Google still handles that information" keeps the text true even with the log exclusion, because the request still passes through Google's systems.
- **Guardian page and long-lived link.** "We treat anyone who uses a link as your guardian" states reliance. It is lawful because it claims no proof of identity, and it gives Pantas an apparent-authority position. The risk is real: a teen with access to the guardian's inbox can use the link. This is in the risk list.
- **Guardian email held until follow-up.** Today the server holds only an HMAC and a masked address (`guardianConsent.ts:61, 70, 189`). A follow-up email after confirmation needs the address. The text commits to deleting it after the send or at expiry. This is a build assumption.
- **Guardian answer record.** Fields: `documentVersions`, `noticeWordingVersion`, `action`, `agreed`, `decidedAt`, stored under the uid and kept on deletion (`guardianConsent.ts:288-294`). "Holds no name or email" is true there.
- **Retention (a), 24 months.** Basis: Sec. 11(e) (no longer than necessary). Supports study across exam cycles; the warning email gives the data subject a chance to object. Leans toward Pantas by choosing a long period and exempting paid access. Existing job: empty guest accounts are already deleted after 30 days (`cleanupOrphanAnons.ts:7-62`). The 24-month rule covers guest accounts that hold data.
- **Retention (b), nine years.** Basis: Sec. 11(e) legal claims; Sec. 13(f); Civil Code Art. 1391 (four years from the end of guardianship) plus up to five years to age 18. **Defect:** the age check admits a person whose birth year is 13 years back, who can be 12 until later that year (`age_policy.dart:36-41`). That person can be almost six years from 18, so the true window is about ten years. Nine years leaves a gap of up to one year for that group. Recommend ten years. The text keeps nine, as approved, and the stated reason names only the four-year rule, which stays true.
- **Retention (c), trial codes.** Sec. 11(e) "legitimate business purposes". Kept while trials exist is a defined end event, but weaker than a fixed date. Keyed hashes remain personal information if someone can re-derive them. Circular 2023-07 balancing applies (unverified). Source: `deleteAccount.ts:54` (the hash set deliberately survives).
- **Five-year accounting, 730-day security, 14-month Analytics, 90-day Crashlytics, 30-day logs.** Unchanged from the reviewed text. The 730 days match `purgeOldAuditLogs.ts:9`. The accounting wording follows the review file (NIRC Sec. 235 as amended by RA 11976, unverified).
- **Checkout box.** The confirmation is a representation by the buyer. Pantas can rely on it in good faith. If a teen ticks it falsely, the purchase stays voidable (Civil Code Arts. 1390, 1399), so the notice does not promise Pantas a binding sale. It only says what is recorded.
- **Share cards.** Source: `firebase_wrapped_share_host.dart:35-50`, `deleteAccount.ts:58-65`. Earlier drafts missed them. They are a public link.
- **Support address.** App code has `contact@pantas.study` in `legal_contact.dart:28` and `support@pantas.study` in sign-in code (`sign_in_parts.dart:27`). The texts use support@. Align the code.

**Assumes the build delivers:**
1. Age screen: birth year used only on the device, never sent, never stored (already true).
2. Optional usage sharing is off on under-18 accounts, has no teen control, and has a guardian-only switch.
3. Guardian page link in the first email and on the confirmation screen (no follow-up email; the server never stores the guardian's email), valid while the account exists, with switch and "Withdraw permission."
4. Withdraw: disables, signs out, deletes like account deletion; keeps the answer record and a withdrawal record.
5. (Dropped by the lead: no follow-up email, so the server keeps no full guardian email.)
6. 24-month inactivity job with a 30-day warning email, paid-access exemption, no warning for guests without email.
7. Guardian answer record, withdrawal and checkout confirmation kept until ten years after the answer, after deletion.
8. Checkout box and server record; server refuses checkout without it.
9. Settings switch for speed and error reports; log exclusion filter in place on `reportClientTelemetry` request logs.
10. The sign-in hint "if your birth year might mean you are 17" stays true: the app treats a year that could mean 17 as under 18 (`age_policy.dart:36-41`).

---

## B. Terms, "Subscriptions" (document `terms`)

> Publish together with the privacy batch, not before.

Same structure as the reviewed Part B. Changes are marked in the notes.

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

We may give other refunds as goodwill. A goodwill refund does not create a right to more refunds. If we agree to cancel a purchase with a partial refund, the remaining access is shortened in proportion to the amount refunded.

These limits and the 30-day deadline do not limit any remedy Philippine law gives you, such as for a service that did not work as promised.

**Disputes with your bank.** If you dispute a payment with your bank or card issuer, we may suspend the access that payment gave while the dispute is open. If the payment is reversed, that access ends. If the dispute is resolved in our favor, the access returns. We may restrict an account we reasonably suspect of fraud or abuse.

**Ending Pro.** When your Pro access ends, Pro-only features stop unless another plan or pass covers the exam. You can keep using Free features. Pro backup and syncing stop while you do not have Pro. Ending Pro does not by itself delete your progress. Your data follows the storage periods in our privacy notices.

**Deleting your account.** If you delete your account, your access ends, including any time left on a plan. Deleting your account is not a refund request. The same applies if a parent or guardian withdraws permission for an under-18 account, or if we delete an account that has stayed unused for 24 months. An account with active paid access is not treated as unused.

**Students under 18.** If you are under 18, your parent or guardian must make the purchase. At checkout, the buyer must tick "I am the parent or guardian and accept the Terms." Checkout does not work without it. We record the confirmation with the date, time and Terms version. By ticking, the buyer confirms they are the parent or guardian, that they accept these Terms as the buyer, and that they are allowed to use the payment method chosen. We rely on that confirmation. If we learn that someone who is not a parent or guardian ticked the box, we may cancel the purchase, refund it and end the access.

**Complaints.** Send purchase complaints to support@pantas.study.

### Drafter notes for B

- **Refund structure.** Kept as in the review file: a voluntary policy, plus one saving line. The law does not require otherwise. Consumer Act Art. 102 gives the consumer a proportionate price reduction, re-performance or refund for poor service quality. Art. 106 prohibits clauses that reduce or exempt liability. The saving line plus the word "voluntary" keeps the limits from reading as an exemption. Source of the Arts.: lawphil RA 7394, read this session.
- **Price, "full amount you pay".** New. Meets the duty to show the complete payable price (RA 11967 Sec. 23 and JAO 24-03 Sec. 34, both unverified). It is true only if PayMongo fees are not added at checkout. Assumption below.
- **Access start, plans, trial, promo, bank disputes, ending Pro.** Unchanged from the reviewed text, which the lead already checked against source (`PayMongo` code reviewed by the lead; not re-read here).
- **Deleting your account, extended.** Adds guardian withdrawal and the 24-month deletion so users are told access ends. Leans toward Pantas by treating them as no refund request. It is lawful because the saving line and Art. 106 still preserve statutory remedies. If a person loses paid access through no fault of their own, the paid-access exemption means the 24-month job never reaches them. Withdrawal by a guardian ends paid time; a minor's right to annul (Civil Code Art. 1390) is not touched.
- **Students under 18.** Replaces "must make the purchase and accepts these Terms as the buyer". The checkbox gives record evidence of an adult's assent (RA 8792 Sec. 16, unverified). It cannot prove the ticker is an adult. Leans toward Pantas: reliance statement, plus a right to cancel and refund if the box was falsely ticked. That right is lawful because it cancels with a refund, so it works as rescission with restitution (Civil Code Art. 1385, unverified). If a minor's purchase is annulled, restitution is limited to actual benefit (Art. 1399, read this session). That favors Pantas less than a full refund, so no text promises more than the law gives.
- **Invoice or receipt sentence.** The law does not require one in the Terms. Receipts and invoices are a tax duty (NIRC Sec. 237, unverified) and a merchant duty under the Internet Transactions Act. Neither makes the Terms carry a sentence. I left no placeholder. The business phone, website footer facts and invoice details stay with the owner.
- **Complaint process.** Unchanged; the seven-day exhaustion statement stays out, as decided. Risk 6 in the review file stands.

**Assumes the build delivers:** the checkout box and server record (item 8 above); the 24-month job with the paid exemption; checkout shows the final payable amount with no extra fee added after the price shown; guardian withdrawal ends access.

---

## C. Telemetry legal basis

> Publish together with the privacy batch, not before.

### C1. The legal-basis line

Goes in the teen notice section "Why we may use your data" (already in Part A) and in the Privacy Policy (Part D).

> Speed and error reports (web): our legitimate interest in keeping Pantas working and fast (Data Privacy Act, Section 12(f)). The reports hold only the technical details we need to find and fix problems. You can turn them off in Settings, then About.

### C2. Legitimate-interest assessment, for your file (updated)

NPC Circular 2023-07 expects a written assessment before relying on Sec. 12(f) (unverified).

- **Purpose.** Find slow loading steps and recurring errors on real browsers. Web errors were recorded nowhere before.
- **Necessity.** Opt-in only was rejected: the spec found too few reports would arrive. The data is small: no account ID in the stored line, browser family, screen-size group, error text filtered on the device, fixed fields enforced by the server (`clientTelemetry.ts:75-104`), in-memory rate limit, nothing in the app database, 30-day log retention.
- **Balancing.** Ordinary technical data. Users include teens. The fields reveal nothing about age or ability. Remaining risk: a name or free text inside an error message (`MAX_MESSAGE = 300`, line 24). Safeguards now stronger than in the review file: a switch to turn the reports off; a log exclusion filter that drops Google's connection log entries (IP address, full browser string); the report's own line holds no IP.
- **Objections.** Now honored: the person turns the reports off in Settings. An emailed objection is answered by pointing to the switch or by suppressing the device if the owner can. This closes review risk 7 for future reports.
- **Conclusion.** Sec. 12(f) is defensible. Review when fields, retention or users change.

**Assumes the build delivers:** the Settings switch (on by default, Settings, About, next to usage sharing) stops sending on that device; the exclusion filter exists on pantas-prod and covers `reportClientTelemetry`. Check both after the build. Reports already logged stay until the 30 days end.

---

## D. Adult Privacy Policy (document `privacy`)

> Publish together with the privacy batch, not before.

Replaces the three-section stub. It mirrors Part A section by section with adult wording. DPA Sec. 16(b) and IRR Sec. 34 items are mapped in the notes after the text.

### Who this is for

This policy is for people aged 18 and older. If you are under 18, read the Notice for teens instead. It explains how we handle data for under-18 accounts.

### Who runs Pantas

Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services, a sole proprietorship. He is also the Data Protection Officer.

Address: Poblacion, Norala, South Cotabato, Philippines.

Questions about your data: dpo@pantas.study
Help or payment problems: support@pantas.study

### Why we ask your age

When you set up Pantas, we ask for your birth year. We use it once, on your device, to work out whether you are 18 or older. We then throw the birth year away. Our servers never receive it. Your device keeps only the age group "18 and older." People who are younger are sent through a different setup that needs a parent or guardian.

We do not ask for your permission for this check. It is necessary screening, and we cannot let anyone in without it. You cannot turn it off.

### What we collect

- Account: an account ID, which Pantas creates even before you sign in. If you sign in with Google, we also receive your name, email address and profile photo. If you sign in with an email code, we receive your email address.
- Study records: your study settings, answers, results, study times, bookmarked lessons and flagged questions. We use your answers and study times to choose your review dates and show your progress. This choice is made by our software, without a person reviewing it.
- Payments: if you buy Pro, we keep payment references, amounts, payment status, refunds and access dates. Card and wallet details are entered on PayMongo's checkout page.
- Free trial: protected codes made from your verified sign-in details, so we can check whether a trial was already used.
- Share cards: if you choose to share a Wrapped card, we keep the card image and a public link to it. You can remove it at any time.
- Messages: emails you send to support@pantas.study or dpo@pantas.study.
- Technical records: security and account records, such as sign-ins, payment checks and account deletions.

### Optional usage sharing

Optional usage sharing helps us improve Pantas. It starts off. You choose whether to turn it on. Turning it on is a separate choice from setting up your account, and leaving it off does not stop you from using Pantas.

If you turn it on, reports include the screens and features you use, your study sessions, question IDs, the answer you chose, and whether it was correct. These reports are linked to your account ID. The phone app can also send error reports.

To turn it off, open Settings, then About, and use "Help improve Pantas by sharing usage data." You can also email dpo@pantas.study about reports already collected.

### Speed and error reports

To find slow screens and errors, the web app sends short technical reports. They include the app version, whether this is a first visit, a return visit or the first visit after an update, your browser family, your screen-size group, loading times, and error messages, counts and locations in our code. We remove common personal details, such as email addresses, before a report is sent. We do not deliberately include your answers or lesson content.

The stored report does not contain your account ID or your IP address. Sending a report uses your sign-in session, including a guest session, to check the request and to limit how many reports are sent. We tell Google not to store its connection log entries for these reports. Those entries would hold your IP address and full browser details. Google still handles that information to deliver the request, as any website does.

We keep the stored report logs for 30 days. These reports are on by default and are separate from optional usage sharing. To turn them off, open Settings, then About, and use the speed and error reports switch next to usage sharing. You can also object by emailing dpo@pantas.study.

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

You can withdraw a permission you gave, such as optional usage sharing, at any time. Withdrawing is free. It does not undo use of data that was lawful before you withdrew.

To delete your account, open Settings, then Account, then the delete option. For an account signed in with Google or an email code, this deletes your study records from our servers and clears Pantas data on the device you use. You may need to sign in again first. For an account that is not signed in, it clears data on your device only. To remove server records of such an account, email dpo@pantas.study.

Deleting your account removes its study records. It does not cancel an app store subscription. Limited trial-use, security and required accounting records may remain for the purposes and periods in the next section. Copies on your other devices stay until you clear them. Copies held in our providers' backups can take longer to disappear.

### How long we keep data

- Study records and settings: while your account exists. We delete the account if you delete it, or if it has no sign-in or study activity for 24 months. About 30 days before, we send a warning email to the account's email address. Any activity cancels the deletion. An account with active paid access does not count as inactive. A guest account without an email address is deleted without a warning. An empty guest account is deleted after 30 days without use.
- Free-trial codes: kept for as long as Pantas offers free trials, including after account deletion, so a trial cannot be repeated.
- Payment and accounting records: five years, counted as tax law requires from the filing deadline of the related tax return. Records may stay longer while a tax matter is unresolved.
- Our database security records: 730 days after the event.
- Optional usage reports: Google Analytics keeps event records for up to 14 months after your last activity. Google starts removing phone error reports after 90 days.
- Speed and error report logs from the web app: 30 days.
- Share cards: until you remove the card or the account is deleted.
- Messages to us: while we handle your request and any follow-up or claim, and no longer than needed.

If the law requires it, or we need specific records for a legal claim, we may keep those records longer.

### Why we may use your data

- Age check: necessary screening that runs on your device. We rely on our legitimate interest in keeping young users safe and making sure the right adult agrees (Data Privacy Act, Section 12(f)). We keep no age record on our servers for adults. This is not a consent request.
- Account, study and payment records: we need them to provide the service you asked for (Section 12(b)). We treat practice answers as ordinary personal information.
- Optional usage sharing: your separate permission (Section 12(a)). You can withdraw it at any time.
- Speed and error reports, security records and trial codes: our legitimate interest in keeping Pantas working, safe and fair (Section 12(f)). We keep each to what we need.
- Accounting records: the law requires them (Section 12(c)).
- Messages to us: we need them to answer you.

### Keeping data safe

We use reasonable organizational, physical and technical measures to protect your data. If a breach is likely to put you at real risk, we tell you and the National Privacy Commission as the law requires.

### Changes to this policy

We tell you in the app before a material change takes effect. The date at the top shows the current version.

### Drafter notes for D

Coverage of DPA Sec. 16(b) and IRR Sec. 34(a) (the list of items a notice must give; Sec. 16(b) read this session, IRR numbering unverified):

1. Description of personal data: "What we collect".
2. Purposes: "What we collect", "Why we ask your age", "Why we may use your data".
3. Scope and method of processing: "What we collect" (study records, review dates by software), "Where your data goes", "Speed and error reports".
4. Recipients: "Where your data goes".
5. Methods of automated access: the review dates are chosen by software; stated in "What we collect". No other automated access.
6. Identity and contact of the controller: "Who runs Pantas".
7. Storage period: "How long we keep data".
8. Rights, including complaint to the NPC: "Your rights".
Added from IRR Sec. 34(a): changes to the notice need prior notification ("Changes to this policy"; unverified).

Section by section mapping to Part A: Who this is for; Who runs Pantas; Why we ask your age; What we collect; Optional usage sharing; Speed and error reports; Where your data goes; Your rights; Withdrawing or deleting; How long; Why we may use your data. Left out on purpose: the guardian sections and "Payments for minors". Only the first section says under-18 users see the teen notice. Added for adults only: "Keeping data safe" (Sec. 20 duty and breach notice, unverified details) and "Changes to this policy".

Basis, per clause, and leaning:

- **Adult age check.** Same analysis as Part A. For adults the position is strongest: Pantas stores nothing. The flag "adult" sits on the device (`app_preferences_repository.dart:80-83`; `onboarding_age_gate_step.dart:169-172`). The text says "we keep no age record on our servers for adults". I confirmed that no server code stores an adult label (only `ageGroup: 'minor'` at `guardianConsent.ts:189, 347`).
- **Study records basis.** The adult text uses Sec. 12(b) and calls practice answers ordinary personal information. This leans toward Pantas and is lawful only if practice answers are not "education" information under Sec. 3(l)(2). The Act speaks of information "about an individual's health, education". Practice scores in a self-study app are not school records, so the position is arguable. I rate it moderate. The risk is an NPC view that learning performance is education information. Fallback: the "I agree to the Terms of Service and Privacy Policy" box at setup (`onboarding_consent_step.dart:165-180`) is a bundled agreement and does not count as Sec. 13(a) consent. A stronger fallback would be a short specific line on that screen. That is a recommended build, not assumed.
- **Optional usage sharing for adults.** Sec. 12(a) consent. Reports include answers and correctness, which may reveal learning performance, so Sec. 13(a) also applies. The existing checkbox is separate, unticked by default (`onboarding_consent_step.dart:150-159`, `48-60`). That is specific and unbundled. The text cites Sec. 12(a) only; add "and Section 13(a)" if you want to cover the education-information reading. I left it out to avoid conceding that answers are education information in the same policy that says they are ordinary. It is a judgment call.
- **Retention.** Basis Sec. 11(e). The messages line uses an end event, not a date, because no mailbox cleanup exists. A fixed period (for example two years after closing) is stronger under IRR Sec. 34(a) but needs a real cleanup. Owner decision.
- **Empty guest accounts, 30 days.** `cleanupOrphanAnons.ts:30-60`: no linked provider or email, last sign-in over 30 days, no `users/{uid}` document, only `server` and `limits` data, no entitlement, trial or share. "Empty guest account" is a fair short form.
- **Providers and region.** Functions run in `asia-southeast1` (Singapore): `deleteAccount.ts:15`, `purgeOldAuditLogs.ts:6`. I did not find the Firestore location in `firebase.json`; if the database is elsewhere, "Singapore" must change (unverified).
- **Cross-border.** Allowed with accountability (Sec. 21; IRR outsourcing rules, unverified). The text does not claim consent. See risks for the processor contracts.
- **"We do not sell your data. We do not show ads."** From the existing stub. I found no ad SDK in `pubspec.yaml`. Keep only while true.
- **Sharing "when the law requires it or for a legal claim".** Sec. 13(f) ("when provided to government or public authority") covers that; read this session.
- **Complaint to NPC.** Sec. 16 and IRR Sec. 34 (complaint right). Website only is given because I could not confirm the NPC's current address.

**Assumes the build delivers:** the Settings switch and log exclusion (Part C); the 24-month job with warnings; nothing else new for adults. If the owner does not want to run a mailbox cleanup, replace the "Messages" retention line with a fixed period.

---

## E. Terms: "Use of the app and limits of responsibility" (document `terms`)

> Publish together with the privacy batch, not before.

Replaces two current sections: "Use of the app" (two sentences) and "Use of the app and limits of responsibility". Splitting into the sections below keeps each readable on a phone. "Subscriptions" and "Intellectual property" stay as they are. Suggested order in the app: Use of the app; Subscriptions; Study content and results; Changes, suspension and ending; Limits of responsibility; Intellectual property; Governing law and disputes; Changes to these Terms.

### Use of the app

Pantas is a study tool for exam practice. You may use it for your own study. You must be 13 or older. If you are under 18, a parent or guardian must agree first, as the Notice for teens explains.

When you use Pantas, you agree to:

- give true information when you set up your account;
- keep your sign-in safe. You are responsible for what happens in your account;
- use one account for yourself and not share your sign-in;
- not copy, scrape, resell or reverse-engineer the app or its content;
- not attack, overload or try to break into the app or any account;
- not misuse trials, payments, limits or promotions; and
- follow the law.

Pantas is independent. It is not part of, approved by or connected to the Civil Service Commission or any other government office or exam body.

### Study content and results

Pantas does not guarantee a passing result, admission, a job, a license or any particular score. Exams are set by others. Check the official exam instructions, eligibility requirements, schedules and announcements.

We prepare lessons, questions and explanations with care. They can still contain mistakes or fall behind a change in an exam. The official exam source always comes first. Tell us about an error at support@pantas.study. We may correct or remove content at any time.

Your scores, progress and review dates are estimates to help you study. They do not predict your exam result.

Pantas is provided "as is" and "as available." We do not promise that it will run without interruption or errors, or on every device. This does not remove our duty to give you a service of the quality the law requires.

### Changes, suspension and ending

We may change, add or remove features, content and plans. We may pause the service for repairs or for reasons outside our control. We try to tell you about big changes in the app.

If we permanently end a Pro feature, or the whole service, while you have paid access, we refund the unused part of your payment.

We may suspend or close an account if you seriously break these Terms, misuse the app, put the app or other people at risk, make a payment we reasonably believe is fraudulent, or if the law requires it. We try to tell you why and let you reply first. We may act without notice if waiting would put others at risk or the law forbids notice. If you think we made a mistake, email support@pantas.study within 30 days. We will review it.

If we close your account for serious misuse, we do not refund unused paid time, unless the law requires a refund.

You can stop at any time by deleting your account.

### Limits of responsibility

We take reasonable care to run Pantas. Our responsibility follows Philippine law.

If we breach these Terms in good faith, we are responsible only for loss that was a natural and probable result of the breach and that both of us could reasonably have foreseen when you signed up. Losses such as a missed exam slot, a lost job, lost income, extra fees or a lost chance are not losses we could foresee. They depend on many things we do not control, so we do not cover them.

For any claim about the service, our total responsibility is limited to the amount you paid Pantas in the 12 months before the event that caused the claim. If you paid nothing, it is limited to ₱1,000.

These limits do not apply to, and do not reduce:

- fraud, bad faith, willful misconduct or gross negligence;
- death or physical injury;
- your rights under the Consumer Act, such as a proportionate price reduction, re-performance or a refund for a defective or poor service;
- your rights and compensation under the Data Privacy Act; and
- any responsibility that the law does not allow us to limit.

If a court finds part of these Terms is not allowed, the rest stays in force.

Payment providers, app stores, banks and other companies we use have their own terms and fees. We are not responsible for those terms or fees.

### Governing law and disputes

Philippine law governs these Terms and your use of Pantas.

If you have a problem, please email support@pantas.study first. We want to fix it.

Court cases between you and Pantas about these Terms go to the proper courts of South Cotabato, Philippines, and no other court. This does not limit your right to complain to the Department of Trade and Industry, the National Privacy Commission or any other government office. It does not limit your right to file a small claims case where the law lets you. If a law gives you a place to sue that an agreement cannot change, that law applies.

### Changes to these Terms

We may update these Terms. We tell you in the app before a material change takes effect, at least 14 days ahead unless the law or security requires sooner. The date at the top shows the current version.

A change that makes your rights worse does not apply to access you have already paid for until that access period ends. If you do not accept a change, stop using Pantas and delete your account. If you keep using Pantas after the change takes effect, you accept it.

### Drafter notes for E

- **No result guarantee; study tool; scores as estimates.** Keeps the reviewed wording and adds that scores do not predict results. Defends against misrepresentation claims (Consumer Act deceptive-sales rules, article numbers unverified). Marketing must match: do not advertise a pass rate.
- **Accuracy disclaimer; "as is".** Contract freedom (Civil Code Art. 1306, read this session) allows a disclaimer. It cannot remove the supplier's duty for service quality: Consumer Act Art. 99 (liability for defective services "independently of fault"), Art. 102 (service quality imperfection: price reduction, re-performance, refund), Art. 105 (legal guarantee of adequacy applies without any written instrument), Art. 106 (clauses reducing or exempting liability are prohibited). All read this session. The sentence "This does not remove our duty..." is therefore needed. Leans toward Pantas inside that limit.
- **Service changes, suspension, termination.** Art. 1308: validity or compliance cannot be left to the will of one party (read this session). A free right to end paid service without refund would be attacked under it. So the draft gives a pro-rata refund when Pantas ends paid access. Leans toward Pantas elsewhere: wide right to change or pause, suspend for abuse, act without notice for safety. Forfeiting unused time on a serious-abuse closure is arguably a penalty a court may reduce (Civil Code Art. 1229, unverified). I kept it, limited to "serious misuse" and "unless the law requires a refund". Rate: moderate. The 30-day review line helps against an abuse-of-rights claim (Civil Code Arts. 19 to 21, unverified).
- **Limits of responsibility.**
  - Good-faith breach: Art. 2201 limits damages to natural and probable consequences foreseen or foreseeable at the time the obligation was made; for fraud and bad faith, all damages (read this session). Lost exam slots or jobs are plausibly outside that for an ordinary study-app subscription. Moral damages in contract need fraud or bad faith (Art. 2220, partly read, rest unverified). Strong, because it restates the default rule.
  - Cap equal to 12 months of payments. Philippine courts generally enforce reasonable contractual limits on liability if freely agreed and not contrary to law or public policy (Civil Code Art. 1306; cases on carriers' limits, for example Ong Yiu v. CA and Sea-Land v. IAC, unverified). Courts can regulate liability from negligence (Art. 1172, read this session: "Responsibility arising from negligence ... is also demandable", the rest of the article on court regulation is unverified). Standard-form contracts are valid but read against the drafter. Enforceability: **likely enforceable for ordinary, good-faith, non-defect money claims; not enforceable** against fraud and bad faith (Art. 1171: responsibility for fraud is demandable in all obligations; a waiver of future fraud is void), against service-defect liability (Arts. 99, 102, 106), or against Data Privacy Act damages (Sec. 16(f) read this session; waiver contrary to public policy, Civil Code Art. 6, unverified). The draft carves all of these out, so the cap cannot be struck down as a blanket exemption.
  - **₱1,000 floor.** A cap of zero for free users would read as a total exemption, which Art. 106 prohibits and a court could refuse. A small floor makes the clause easier to enforce. It is my choice; Aedwon may change the amount.
  - Gross negligence carve-out: courts often treat gross negligence like bad faith for limits (unverified). Including it costs little and protects the rest.
  - Third parties: "not responsible for those terms or fees" is limited to terms and fees, not outages. Art. 106 makes all responsible parties jointly liable, so a broader disclaimer would fail.
  - Severability: Civil Code Art. 1420 allows separating illegal terms of a divisible contract (unverified).
  - **Indemnity clause omitted** on purpose: it adds little over Arts. 1170 to 1172, and it is weak against minors and consumers.
- **Governing law, venue.** Philippine law is the only sensible choice. Venue: Rules of Court Rule 4 Sec. 4 allows a written exclusive-venue agreement if it uses restrictive words such as "and no other court" (unverified). Most favorable lawful choice: the courts of South Cotabato (I did not name Koronadal City or a branch because I could not confirm which court sits for Norala). Override risk: *Sweet Lines v. Teves*, G.R. No. L-37750 (May 19, 1978), voided a one-city venue clause on a ticket as against public policy for ordinary passengers; the Court later narrowed it for clauses people had a real chance to read, *Pilipino Telephone v. Tecson*, G.R. No. 156966 (2004) (secondary summaries only, unverified). A far-away venue for a student in, say, Luzon invites that attack. The carve-outs (DTI, NPC, small claims, non-waivable law) protect the clause and keep the court choice for ordinary cases. Small claims venue and DTI consumer complaint venue follow their own rules (unverified). Barangay conciliation applies only if both sides live in the same city or municipality (Local Government Code Sec. 408, unverified). "Please email first" is a request, not a condition precedent, so it cannot be used to bar a lawful complaint. No arbitration clause: unattractive for small consumer claims and gains little.
- **Changes to Terms.** Unilateral change is attackable under Art. 1308. The draft limits that by notice, a 14-day lead and protection of already paid periods. The in-app re-acceptance mechanism exists (`settings_repository.dart:52-55`, "currentPolicyVersion ... re-prompt").
- **Beta wording.** The old Nov 9 to 15 beta sentence is not repeated; the "Free or promotional access" paragraph in Part B covers it.
- **"Pantas is independent."** True only if you have no CSC or other agency tie. Confirm.

**Assumes the build delivers / the owner confirms:** an in-app notice that can warn of Terms changes at least 14 days ahead; the owner can run the 30-day mistake review by email; no CSC or agency tie; the ₱1,000 floor amount is acceptable.

---

## F. Risks that remain after the remedies

Replaces review Part D.

1. **No lawyer reviewed any of this.** Citations marked "(unverified)" may be wrong. A clause can still fail in a dispute.
2. **The birth year is processed before any guardian is involved.** The device-only design makes the exposure small. The legal position on the stored `minor` label rests on 13(f) and the guardian's later permission. See Part A notes. Nothing the notice says can cure this fully.
3. **The guardian link is a bearer link that lasts as long as the account.** Anyone with the email, including a teen who can read the guardian's inbox, can turn on usage sharing or withdraw permission. A guardian "confirmation" is an email click and proves no identity or authority. Accepted risk. Mitigation to consider: an email-code step for withdrawal.
4. **Guardian answer record: nine years can fall short.** A person admitted at "13" by birth year can be 12 and almost six years from 18, so the true limit is about ten years. Recommend ten years.
5. **Indefinite-by-event retention.** Trial codes (while trials exist) have no date. The NPC may call that storage longer than necessary. Accounts with data are covered by the 24-month rule, but only once the job runs.
6. **Adult study records as "ordinary" data.** If the NPC treats learning performance as education information (Sec. 3(l)(2)), the adult basis needs consent under Sec. 13(a). The setup agreement box is bundled and may not count. A specific line is recommended (see Part D notes).
7. **Purchases by minors.** The checkbox is a representation, not proof. A parent can still ask to annul a teen's purchase (Civil Code Art. 1390). Expect refunds in those cases. Restitution is limited to actual benefit (Art. 1399).
8. **Online-seller duties** (Internet Transactions Act and its rules, unverified): business name, physical address, phone and email on the website, invoices, and a complaint route. The owner provides these. DTI exposure once paid sales start. Whether the Terms must state them was not confirmed; none was drafted.
9. **Registration and paperwork.** If Pantas processes sensitive personal information of 1,000 or more people (age and education may count), NPC Circular 2022-04 Sec. 5 requires registering the data processing system and the DPO (confirmed from secondary summaries only). Also needed and not covered here: written contracts with each processor (Google, Resend, PayMongo, RevenueCat), a privacy impact assessment and a privacy manual (IRR requirements, unverified).
10. **Backups.** No period is given for provider backups. The text says only that copies "can take longer." Firebase states about 180 days for authentication data (secondary, from the earlier built text). Firestore backups and recovery settings on pantas-prod were not checked.
11. **Support address mismatch.** `legal_contact.dart` says contact@pantas.study. The texts say support@pantas.study.
12. **Firestore location not verified.** "Singapore" in the data section is confirmed only for the functions.
13. **Liability cap and forfeiture.** The 12-month cap is likely enforceable for ordinary claims only. Forfeiting unused time after a serious-misuse closure may be reduced by a court.
14. **Venue.** A South Cotabato venue may be struck down for far-away consumers (*Sweet Lines*). The carve-outs reduce but do not remove this.
15. **Always-on speed reports, reduced.** Objection now has a switch. The connection-log exclusion removes the IP and full browser string from storage. An unfiltered name inside an error message remains possible.
16. **Messages mailbox.** The adult policy promises "no longer than needed". No cleanup exists. Set a real rule.
17. **Wrapped share cards.** A public link. Teen cards are public too. The card holds an archetype label only (`firebase_wrapped_share_host.dart:35-41`), which is low risk.
