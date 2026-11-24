# Public-launch legal package (CSE public release)

Checklist rows: L1, L2, L7 and M10 in `docs/superpowers/plans/2026-11-22-cse-public-release-checklist.md`.
Drafted Nov 22, 2026 under process rule 5. Codex GPT 6.2 Sol High critiqued it the same day (round 1): the full output is `critique-2026-11-22-sol-high.md`, the prompt is `critique-prompt.md`. An agent applied every wording finding (see `change-summary.md`). Findings that need the app or server to behave differently are under "Needs a product or code decision" below. No lawyer reviewed it (Aedwon's Nov 9 decision, row L8). Nothing is published. No app code is changed.

Files:

- `change-summary.md`: one page for Aedwon. Start here.
- `terms.md`, `privacy-policy.md`, `teen-notice.md`: the three texts. Brackets mark facts only Aedwon has.
- `critique-prompt.md`: the exact prompt for the Codex critique.
- `critique-2026-11-22-sol-high.md`: the critique, unedited.

## Standards applied

- Philippine Data Privacy Act (RA 10173) and its Implementing Rules: Sections 11 to 13 (principles, ordinary and sensitive information), 16 (rights), 18 and 19 (proportionality, retention). Source: lawphil.net and privacy.gov.ph, as read in `docs/legal/research/2026-11-11-minor-label-lawful-basis.md`.
- NPC Advisory Opinion 2017-049 (a minor cannot give valid consent alone), Advisory 2024-02 (Section 13(f) legal claims), Advisory 2024-03 (child-oriented transparency), Circular 2023-04 (consent).
- Consumer Act (RA 7394), Internet Transactions Act (RA 11967), E-Commerce Act (RA 8792), Civil Code Articles 1170 to 1172, 1327, 1390 to 1391, 2201. As used in the Oct 30 draft's notes.
- Tax record keeping: five years from the day after the filing deadline, or from the actual filing date if the return was late (RA 11976, amended NIRC Section 235; BIR RR 7-2024 Section 4(A)). Confirmed by the Sol High critique, which cites both.
- Internet Transactions Act (RA 11967 Sections 20, 23 to 25), the DTI and DICT joint order on online businesses (JAO 24-03), and NPC Circulars 2022-04 and 2023-07: added after the critique. Sources are cited in the critique file.
- Writing: `agent-standards/ux-writing.md` (UXW-PLAIN, UXW-ACTIVE, UXW-TERMS), plus `AGENTS.md` voice rules (no em dashes, American spelling).
- No sheet exists in `agent-standards` for privacy or consumer law. Not written: this package cites the statutes directly. Worth adding later.

## Facts Aedwon supplies

Every item is a bracket in the texts or a claim only he can confirm. Nothing is invented.

1. Done (Nov 24): registered business name "Pantas Online Tutorial Services", from the DTI certificate.
2. Done: DTI Business Name No. 8567107.
3. Done: BIR registration read from the Certificate of Registration. He is not VAT-registered and uses the 8% income tax option, so the Terms say the price has no VAT in it. Watch: if gross sales pass the VAT threshold and he registers, that sentence and the price line must change. The TIN is not in any text (see the TIN note below). The BIR Registration Seal Badge is optional for now (step 0a).
4. Done: place of business 19 Manuel Roxas St., Poblacion, Norala, South Cotabato 9508, Philippines (the BIR registered address). The critique says a Terms page alone is not enough: the seller details also belong on the homepage (decision D3).
5. Done: business phone +63 968 854 2343 (supplied Nov 18).
6. Publication date. It becomes the version stamp (see "Publishing steps").
7. NPC registration: whether the business must register. The critique says age-based access decisions and the study-style label may meet the registration test even for a sole proprietor. Confirm the classification, register if required, and add the seal after it is issued. Leave the bracket out only if not required.
8. Commitments only he can keep: the refund reply within [5] business days; five years of tax books, sales invoices, receipts and refund evidence outside the app (the Privacy Policy now says the business keeps these); a working mailbox for dpo@pantas.study and support@pantas.study.
9. Practice claims only he can confirm before publishing: "We do not sell your data"; he is the Data Protection Officer; the Google Analytics retention setting (the texts say 14 months in a bracket); the 30-day report log setting and that the report function's request logs are excluded from default log storage; Cloudflare's own request logs; the Singapore database region.
10. Whether the Pantas sales invoice sentence in the Terms can be published (it needs the invoice workflow, decision D3), and the message retention period for the Privacy Policy and the Notice for teens (bracket).
11. Whether PayMongo QR Ph is live for the launch account, and whether QR Ph refunds work there (decision D4). The texts keep card and QR Ph conditional ("may include").

## M10: payment records versus account deletion

**What the system does today.** Deleting an account erases the ordinary account-linked payment records Pantas holds in the app database: the plan and refund ledger, the payment index, orders, checkout records and refund follow-ups. It does not erase everything keyed to a payment. The critique found these can survive deletion:

- for an under-18 account, a copy of each guardian purchase declaration (date, time, Terms version, reference, product; no amount, name or email);
- payment audit and event-deduplication records, and some refund and dispute records keyed to the payment ID;
- detached native pass records (a hashed receipt reference and the public exam-date bounds);
- a permanent record keyed to the former account ID that stops it reopening, and security log entries (730 days);
- trial codes, with no end date.

The earlier version of this README listed only three of these. The texts now say limited payment-keyed records remain. The code does not export anything to a tax archive.

**Resolution in these drafts: text only, no code.** The texts say:

- The app removes its main account-linked payment records when deletion finishes, and keeps limited records for security, verifying past transactions, guardian evidence and legal duties.
- The five-year duty is met by the business's tax books, sales invoices, receipts and refund records, kept outside the app. These survive deletion.
- PayMongo and the bank keep their own records.

The critique warns this is only true if the business really holds those records. A dashboard screenshot or a ledger total is not enough: the source documents must exist. See decision D8.

## Where the app and the text disagree, or the app lacks something

- **Version stamps do not force re-acceptance (L7).** The checklist says a Terms version bump asks existing students to accept again. In code it does not. Onboarding only checks that an acceptance time exists. The stamps affect the guardian confirmation page (an old page reloads) and the under-18 checkout box. So existing adults learn of the new Terms only through the notice and email promised in Terms section 12 and the Privacy Policy "Changes" section (process rule 9). Someone must send that email, and it follows rules 6 and 8.
- **Age step copy.** The screen says "Choosing Continue means you agree to this check". The live notices said "specific permission". The new texts say "agree" and, for teens, say Continue is not the legal basis. The critique also wants the screen's first paragraph to match the notice wording. That is a screen change (decision D1).
- **Terms promise 14 days of in-app notice before a material change, and acceptance of a change that makes the user's position worse.** The app has no general mechanism for either. A Home notice strip exists and was used for other notices. See decision D5.
- **Payment after the sitting date** refunds in full under the new Terms. The system flags that payment for a manual refund already, so the text now matches.
- **Moved or canceled exam sittings:** the code can map a pass to a formally updated sitting, so the Terms say a pass "may follow the new sitting". A cancellation with no replacement has no system rule. The Terms promise a good-faith review and say legal remedies apply.
- **Screen counts are on in production.** The first version of these drafts said the flag was off. The launch log records production builds with `SCREEN_COUNTS=true` (for example Nov 20). Both notices now describe the counts, using the approved wording in `docs/superpowers/plans/usage-telemetry/step2-legal-draft.md` section 2, and add the purpose to the legitimate-interest line. Move the version stamps with this release, as that file's section 2c says.
- **Not built, so not promised in the texts:** the 730-day trial-code expiry (D7), a protected payment archive (D8), expiry of minimum confirmation evidence, a legal-hold exception for guardian evidence, in-app data export (email only), and under-13 accounts (separate lane, E-124). If under-13 accounts ship first, merge that lane's text into these three files.
- **Settings that this repository cannot show:** Google Analytics retention, the 30-day report log retention, the exclusion of the report function's request logs, and Cloudflare's own request logs. The texts no longer state the 180-day provider backup removal. Confirm each remaining setting in the consoles before publishing.

## Needs a product or code decision

Each entry is something the critique found that text cannot fix. No code is changed. Sizes are estimates for one agent lane with tests, and each build needs the free-tier check (process rule 7). Entries D1 to D3 matter most.

### D1. Under-18 flag kept before and after guardian permission (the critique's biggest risk)

**Finding.** When a teen sends a guardian request, the server records the account as under 18 before anyone answers. It keeps that record after a decline or no answer, because checkout uses it. The age is sensitive information. Section 13(f) (legal claims) covers specific evidence about capacity or authorization better than routine checkout control. A later guardian confirmation cannot authorize the earlier write. The texts now say this plainly and rest on Section 13(f) and Section 12(f), the strongest honest position. The legal risk is not removed.

**Options.**
- A. Keep as built, with the new text. No work. The risk stays.
- B. Delete the under-18 flag when a request expires or is declined, and require the adult purchase declaration on every web purchase (D2 option C), so checkout no longer needs the flag. About 1 day: cleanup job, checkout check, tests. The flag still exists while a request is pending.
- C. Change the flow so the server learns the age only after the guardian confirms. The first invitation is age-neutral and any adult can buy. About 3 to 5 days: onboarding, guardian function, device state, checkout and tests, plus a design board for the screen change.

**Recommendation.** B before launch, with D2 option C. Consider C after launch if the risk matters more than the work.

### D2. Guardian purchase box proves less than the text can say

**Finding.** The web server checks the declaration only when it already holds the under-18 flag. It does not prove who ticked the box or that they may use the payment method. The native paywall box is on the device only and leaves no server record. The box says nothing about authority over the payment method. The texts now say the buyer must be a parent or guardian buying in their own name, and that we may ask for proof.

**Options.**
- A. Text only, as drafted. No work.
- B. Add the payment-method statement to the existing box and record it. About 0.5 day: web copy, function check, tests.
- C. Ask every web buyer, of any age, to declare they are an adult buying in their own name with a payment method they may use, and record it. About 1 day. Pairs with D1 option B. Native purchases stay under the store's rules.

**Recommendation.** C.

### D3. Seller disclosures, invoices and what the buyer sees before paying

**Finding.** The law expects the seller's name, a full place of business, phone and email on the homepage, not only in the Terms. The buyer should see the plan, coverage, total price and the refund and complaint policy before going to PayMongo. The Pro screen shows the plan, price and, for a pass, the sitting end date. It does not show or link the refund and complaint policy. Pantas must also issue invoices for web sales. PayMongo's receipt is not a Pantas invoice.

**Options.**
- A. Aedwon supplies the facts (README list). Invoices by hand from the PayMongo dashboard and the BIR process. No code.
- B. Add a link to the refund section and the seller details beside the Pay button, and the seller details in the website footer. About 0.5 day in the app and 0.25 day on the website.
- C. B plus an automatic invoice email on each paid event. About 2 to 3 days, and it needs the BIR invoice format settled first.

**Recommendation.** B at launch, with manual invoices (A). Build C when volume makes manual invoices a burden. The Terms invoice sentence stays in brackets until the workflow exists.

### D4. Refunds: statutory remedies and goodwill refunds are handled the same way

**Finding.** The refund code treats every refund alike. A full refund revokes the grant and a partial refund shortens it in proportion. A legal remedy such as a price reduction may need access to continue. The manual QR Ph refund runbook records a test-mode refusal and a bank transfer process. Nobody has checked on the live merchant account that QR Ph refunds are refused or that an e-wallet payout works. The runbook starts from the payment index, which account deletion removes.

**Options.**
- A. Keep the code. Handle a statutory case by hand and never use the manual refund command on it. No work.
- B. Add a "keeps access" option to the manual refund command. About 0.5 day with tests.
- C. Check QR Ph refund behavior on the live account and update the runbook to find a payment by PayMongo reference when the index is gone. About 0.25 day, no code.

**Recommendation.** A and C now. Build B when the first statutory case arrives. The texts now name bank transfer only and say access after a partial refund follows the law.

### D5. Accepting changes to the Terms, and telling users of privacy changes

**Finding.** A new Terms version does not make existing adults accept again. The app has no 14-day notice scheduler. Process rule 9 asks for an email to the user and, for a teen, the guardian. The guardian's full email is not kept after confirmation, so a guardian email is usually impossible. The Terms now promise 14 days of notice and acceptance of any change that makes the user's position worse. Material changes to an existing contract need real assent, and silent continued use is weak evidence for them.

**Options.**
- A. Run each change by hand: a Home notice and the rule 9 email, no acceptance screen. No work now. Build B before the first change that makes users' position worse.
- B. Build a re-acceptance screen keyed to the Terms version, with the guardian path for teens. About 2 to 3 days.
- C. B plus a scheduler that holds a change for 14 days. About 4 to 5 days.
- D. Keep the guardian's email for change notices, disclosed and encrypted. About 1 to 2 days, and it adds personal data the app does not hold today.

**Recommendation.** A for launch. B before any worsening change. Not D: it adds data to meet a promise. Instead, Aedwon amends rule 9 for teen accounts so the teen's in-app notice plus the teen's own email counts. The Notice for teens now says the guardian is emailed "when we still hold a way to reach them". That wording is his call.

### D6. Setup consent for study records, and what the critique left alone

**Finding.** One tick at setup covers the Terms, the Privacy Policy and keeping study records. The label does name study records, which helps. A separate, identified permission is stronger for education data. For a teen, the guardian gives this permission on the confirmation page. An adult has no control to withdraw study-records permission short of deleting the account. The critique judged two other points fine and they need no change: optional usage sharing is a separate choice that starts off, and the guardian page does not show the teen's results.

**Options.**
- A. Keep one tick. The text now says "we ask for your permission" and names the records. No work.
- B. Split the row into two: the Terms, and study-records permission. About 0.5 day, plus a Claude Design board because it changes a screen.
- C. B plus a separate tick on the guardian confirmation page. About 1 day in all.

**Recommendation.** A for launch. B in the first release after.

### D7. Free-trial codes never expire

**Finding.** The trial marker stores only that the trial was used, with no date. The code cannot enforce an end date. Keeping a protected marker forever for a low-value offer is the weakest retention claim in the package. The texts now say the code has no scheduled expiry and give an objection route.

**Options.**
- A. Keep. No work. The text is accurate.
- B. Store a date on each new marker and delete markers after a set period, for example 730 days. Old markers take the deploy date. About 0.5 day with a cleanup job and tests.

**Recommendation.** B, with Aedwon choosing the period, before launch. It is cheap and makes Section 12(f) easier to defend.

### D8. Payment records after deletion, and the business's own records

**Finding.** See "M10" above. The text now relies on the business keeping real books, invoices, receipts and refund evidence outside the app. The app keeps no tax archive. Guardian evidence has no legal-hold exception, so the texts no longer promise one.

**Options.**
- A. Text only, and Aedwon keeps the ledger and documents from PayMongo reports and bank references. No code.
- B. Copy each payment's reference, product, amount, paid date and refund total into an archive with no account ID and an expiry date at deletion. About 0.5 day with tests and one TTL policy.
- C. A plus a written procedure that can find a payment by PayMongo reference after deletion. About 0.25 day, no code.

**Recommendation.** A and C. B only if the business cannot hold the records itself.

## Nov 23 pass: checkout declaration, seller line, question reports

Rulings: `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, section "Nov 22, legal package D1 to D8" (D2, D3). The D1 to D8 entries above are the Nov 22 options. The rulings decide them. Critique: `critique-2026-11-23-sol-high.md`, prompt `critique-prompt-2026-11-23.md`.

### Final checkout declaration (D2)

A required tick beside the Pay button. "Terms and refund policy" links to the Terms (section 5 is the refund policy).

- Adult (buyer buys for their own account): "I'm 18+, authorized to use the payment method, and accept the Terms and refund policy."
- Guardian (the server holds a confirmed guardian for the account): "I'm 18+ and buying for this student as their parent or legal guardian. I'm authorized to use the payment method and accept the Terms and refund policy."

### Seller line (D3)

Beside the Pay button: "Sold by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services · 19 Manuel Roxas St., Poblacion, Norala, South Cotabato 9508, Philippines · +63 968 854 2343 · support@pantas.study"

Website footer (homepage): "Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services · 19 Manuel Roxas St., Poblacion, Norala, South Cotabato 9508, Philippines · +63 968 854 2343 · support@pantas.study"

The brackets are facts only Aedwon has (checklist L3). Neither line ships with a bracket in it.

### Data Protection Officer export procedure

No procedure file exists, and the in-app export is a stub (`exportData` always answers that export is not available). Exports go through dpo@pantas.study. Steps for the Data Protection Officer:

1. Verify who is asking, and the address the file goes to. For an under-18 account, also verify that the requester is the student or the student's current guardian. Accept a request from a teen in plain terms.
2. Find the account ID.
3. Collect, as one file, what the app holds for that account ID: study records and settings; payment records (plan, orders, refund entries and the checkout declaration); the guardian answer record for a teen; share cards; **question reports** (the `questionReports` collection, where `accountId` equals the account ID: message, question, question version, exam, build, time); and the emails in the support and privacy mailboxes about the person. Include the counts of reports, and anything Pantas still holds after account closure that is in scope. Also give the sources, uses and recipients of the data (Section 16(c)).
4. Redact other people's data and secrets, case by case.
5. Send the file securely to the verified address and log the date. Reply within 30 working days of the request or the documents needed to verify it. For a complex or numerous request, the NPC allows 15 more working days if we say why.

Question reports are stored text the student wrote, so they belong in every export where they are still held. They are in the Privacy Policy and the Notice for teens.

### Critique of this pass (round 2) and what was applied

Sol High: 5 must-fix, 1 should-fix, 1 nit, plus a list of sentences that are true only once the app ships (below). All wording findings are applied. Round 2 text in the files reflects them. Changes from the Fable draft: the adult checkbox is now "I'm 18+, authorized to use the payment method, and accept the Terms and refund policy." and the guardian one now says "buying for this student" and "authorized". The seller line names the proprietor. The age statement now rests on Section 13(f) as well as 12(b) and 12(f), because age is sensitive information. The proof-of-authority and cancel sentence in the Terms no longer reads as discretion over a legal refund. The QR Ph payment sentence is fixed. The question report text names the report counts and drops "only what the report holds". The warning against personal details moves to the report form.

**Sentences that are true only once T10 and the report build ship.** Sol High checked the checkout code at `cc0029392` and found these not yet true: a tick on every web purchase, the new wording and a link, recording the tick for adults, the seller line beside Pay, and the footer line. The texts describe the ruled launch state. Do not publish them before the app does what they say.

### Needs a product or code decision (round 2)

Text cannot fix these. Each needs a ruling. None is built.

1. **Guardian approval tied to the specific order (the biggest risk).** The tick comes from the student's own session, so it proves what that session submitted, not that a guardian bought. Sol High's fix is a guardian approval of the order through a verified guardian channel. This reopens D2 option C for minors. The ruled launch (tick plus record) stays as drafted. Decide whether a guardian-approved order is built before or after launch.
2. **Which declarations survive deletion.** The deletion code copies a purchase declaration into the ten-year guardian evidence, selecting by timestamp alone. When adult checkout writes the same field, adult declarations would be kept too. The copy must select the guardian version only, and the copy also holds the product. The texts say guardian declarations only. Needs a code change (D2 build).
3. **Shorter life for abandoned checkout attempts, and the exact declaration wording stored.** Keep the wording version with the record, so the shown text can be proved later. Small code change in the D2 build.
4. **Question report retention.** No ruling sets a period and the report build has no expiry. Sol High would defend up to 90 days from receipt, sooner when the review ends. Needs a ruling on the period and a TTL on the report time, per D7's pattern. Until then the notices keep a bracket and the report text cannot publish.
5. **Report form copy.** Add beside Send: "We use your report to fix questions. Leave out names and private details. See how we use reports." This is a UI string, so it goes to Claude workers with the rest of the report form.
6. **Checkout page.** The buyer must be able to open the Terms without ticking the box. The Terms link goes to the refund section if practical. Add a "Payment help" link to the support address.
7. **The ten-year guardian evidence period.** Sol High notes Civil Code Article 1391 sets a four-year challenge window and does not prescribe ten years of storage for every guardian response. The period is outside this pass, which left it as drafted. Raise it with D1's text pass.
8. **D1 text pass not done here.** D1 deletes the under-18 record when a request fails. The Teen Notice paragraphs on the flag ("We keep the under-18 group...", the retention bullets, the basis bullet) still describe the old behavior. Another pass must rewrite them. This pass did not change them.

## Nov 23 round 3: rulings R1 to R7 applied

Texts changed: the Notice for teens (flag paragraphs, guardian evidence, report period, payments), the Privacy Policy (report period, deletion, checkout record) and the Terms (guardian-denied refund, wording version). Codex Sol High critiqued the changed passages (`critique-2026-11-23b-sol-high.md`, prompt `critique-prompt-2026-11-23b.md`). It gave 5 must-fix, 3 should-fix and 1 nit, plus 3 items that conflict with a ruling. Every wording finding is applied except where noted below.

**Civil Code.** Sol High held all four: Article 1108 (prescription runs against minors who have a guardian), Article 1144 (ten years, written contract, from accrual), Article 1146 (four years, injury to rights) and Article 1391 (four years to annul, from when guardianship ceases for a minor). It adds that none of them sets a records-retention period, that Article 1144 runs from accrual and not from the newest record, and that Article 1146 does not prove a decline-only record needs exactly four years. The texts now say the periods "answer legal claims" and use "schedule for deletion".

### Needs a product or code decision (round 3)

1. **The sensitive flag before a guardian confirms (the biggest risk, again).** Sol High says Section 13(f) does not support recording the under-18 group for routine routing, and wording cannot fix it. The text no longer claims 13(f) for the open request. It uses 12(f) for contact details, 13(a) after permission and 13(f) only for the guardian's answer record. D1 rules that the open request is needed to get permission. Decide whether a basis for the open-request flag is enough as ruled, or whether the flag should not be written before confirmation.
2. **"Within 90 days of receipt" and the TTL.** Firestore deletes expired documents usually within a day and promises no maximum. The ruled text keeps the exact words and the 85-day expiry covers the delay. Sol High would say "scheduled to expire 90 days after receipt, deletion can take longer". Not applied, because the ruling fixes the words.
3. **"Only declarations made by a parent or guardian."** The tick cannot prove who ticked. The texts now say the copy is made where the buyer "said they are" a parent or legal guardian. The ruling's selection by recorded kind is unchanged.
4. **A binding preservation order.** The cleanup cannot honor one, and no wording cures it. The ruling removes the legal-hold bracket. The general sentence now limits its longer-keeping exception to records other than guardian evidence and question reports.
5. **Checkout claims before the build.** The texts say a tick is required on every web purchase, the wording version is recorded and the Terms open without ticking. The checked-out code does not do these yet (D2 build). Publish only after it ships.
6. **Refund route for a guardian-denied purchase.** PayMongo's refund route can be closed for a payment (cards have a 60-day window in its refund table, and its table lists QR Ph as not refundable through the API; a separate QR Ph page describes a dashboard refund). The texts state no QR Ph window. Pantas must be able to refund by a transfer by hand to the payer when PayMongo's route is closed.

## Publish gate for claims that need a build (ruling H5)

The texts publish in the same prod release as the behavior they describe, or after it, never before. Check each row live on prod and log the check in the launch log before step 2 below. If a build slips, rewrite that sentence to the built state and have Sol High critique it again, or wait.

| Claim in the texts | Build that makes it true |
|---|---|
| A tick on every web purchase; declaration, time, Terms version and wording version recorded; the Terms open without ticking; the seller line | D2, D3, R2, R5 (PR #90) |
| Only guardian declarations copied at deletion; ten years and four years for evidence, and four years from the deletion date for sharing permission records | R2, R6 (PR #90), with the Nov 24 round 5 sharing-change code |
| A failed request is deleted whole; a decline is deleted at once; its guardian page links go with it | D1 with H1 |
| Reports deleted within 90 days of receipt | R3 (PR #86) with H2 |
| The trial code period (the texts say "no scheduled expiry" until it ships) | D7 |
| A refund route when PayMongo's route is closed | H6 |
| Seller details in the website footer | D3 |
| An account that no guardian confirmed leaves no evidence row when it says it is 18; for a confirmed account, the date of that statement joins the guardian evidence (the three evidence lists, the "When you turn 18" paragraph) | The became_adult change (Fable Nov 24), checked live on prod |


## Publishing steps (for the integrator, L1 and L7)

0a. BIR seal badge: optional while RMC 113-2026 suspends the requirement. If the suspension is lifted before publishing, it becomes a gate.
0. Texts publish with or after the D1, D2, D3 and D7 builds, and each claim is checked live on prod first (table above).
1. Set the three version stamps to the publication date in both places: `guardianDocumentVersions` in the app and `GUARDIAN_DOCUMENT_VERSIONS` in the functions. Deploy together, or the guardian page refuses answers with "Reload the page".
2. Put the final texts into the in-app legal documents (the Terms title there is "Terms of Service") and as public pages on pantas.study. The site has only a beta-application privacy page today.
3. Remove every bracket first: `grep -n '\[' ` on the three texts must find none. Brackets include the retention periods, the invoice sentence and the legal-hold note. Then run the `legal-text-drafting` check, which fails on the words "draft" and "owner note" in in-app text. It does not catch brackets.
4. Send the change email (rule 9) to existing students with an email address, and to guardians of under-18 accounts, after the self-test (rule 6).
5. Aedwon checks `change-summary.md` and signs off (L1, L2).

The change email wording and the in-app notice are not drafted here. They follow rule 8 and need their own pass.

## Nov 23 round 3, Fable rulings H1 to H6 applied

H1: a decline deletes the request record at once, with its guardian page links. H3: confirmed, the texts say the buyer "said they are" a guardian. H4: both notices allow one exception, a copy made by hand under a binding order, and never pause cleanup. H5: the table above. H6: the Terms refund route covers any closed original route. Open for round 4: the basis for the open request (Section 13(b) with Advisory Opinion 2017-049, against 13(f)) and RA 10175 Section 13 for the H4 sentence.

## Nov 23 round 4: Sol High on the open-request basis and the court-order sentence

Critique: `critique-2026-11-23c-sol-high.md` (prompt in the run, two questions only).

**Applied (wording).** The Teen Notice basis bullet and the "Why we ask your age" paragraph claim no Section 13 basis for the open flag. They state its purpose and deletion plainly. Section 12(f) covers contact details, Section 13(a) the uses a guardian approves, and Section 13(f) only the separate answer record. "Court or authority" is now "a court or another authority with legal power to issue the order". The line "Choosing Continue means you agree to this check" is now "Tap Continue to run the age check", so it does not read as consent. Advisory Opinion 2017-049 concerns a teacher searching a student's phone. It is not a guardian-permission rule, and Section 13(b) does not fit.

### Needs a product or code decision (round 4)

1. **The flag before a guardian answers has no Section 13 basis.** Sol High's verdict: claim none. This is the risk Aedwon accepted on Nov 11, and H1 keeps it. The notice now claims no more than the purpose. Sol High's biggest risk is Section 25 exposure for unauthorized processing even when the request is deleted on time. Only guardian-first sign-up removes it.
2. **The binding-order sentence conflicts with the H4 ruling.** Sol High says RA 10175 Section 13 requires preserving data integrity, so a hand copy may not satisfy an order that needs the live record, and cleanup must not delete it. It also notes a preservation duty can exist without an order (six months for traffic data and subscriber information, six months from an order for content data). It would replace the exception with "We may keep specific records beyond these periods when the law requires it, including under a binding order." H4 fixes the copy-by-hand wording, so it is kept. The runbook step "legal advice before the next cleanup run" is the cover.

## Nov 24 round 5: the became-adult date and permission changes (Fable Nov 24)

Critique: `critique-2026-11-24-sol-high.md`. All wording findings applied: the "When you turn 18" paragraph says "we rely on what you tell us" and no longer says the server records that you are 18; the three evidence lists use one wording and name sharing changes plainly; the basis bullet claims Section 13(f) for the whole evidence, including the date and time of the adult statement. Sol High's verdict: Section 13(f) is defensible for the single timestamp on a guardian-confirmed account. The decision on whether "the guardian's answers" covers sharing changes: it did not, so all three lists now name them. The period sentences are unchanged.

### Needs a product or code decision (round 5)

1. **Closed (Fable Nov 24, round 5 ruling).** Sharing permission records are deleted 1,461 days after the account's deletion date and never count as the newest record. The Teen Notice "Guardian evidence" bullet says so.

## Nov 24 round 6: sharing-record period (Fable round 5 ruling)

Critique: `critique-2026-11-24b-sol-high.md`, the new sentences only. Wording findings applied: the notice no longer assigns users a filing deadline, says "your guardian's permission for optional usage sharing ends when we delete your account" instead of "no sharing can happen", and says the skipped records are only for the other evidence, with the guardian's confirmation still counting.

**Article 1146 against Article 1144(2).** Sol High: Article 1146(1) is the better reading for damages from injury to a privacy right, and four years is defensible. Article 1144(2) (ten years, obligation created by law) stays credible if a claim is framed directly under Data Privacy Act Section 16(f). It found no Philippine court or NPC ruling that decides this. **Act No. 3326** governs criminal prescription only and leaves the civil answer unchanged. For Data Privacy Act offenses it gives 12 years (Sections 25(b), 26(b), 28 and 33) or 8 years (the other offenses in Sections 25 to 32). Under Section 11(e), the abstract chance of a prosecution does not justify keeping records. The ruling already rejects that reasoning.

### Needs a product or code decision (round 6)

1. **A timely claim can outlast the schedule.** Sol High's biggest risk: Pantas could delete evidence of a sharing permission while a claim about that use is still timely, because the deletion schedule and the legal deadline run independently, and a claim can start years before the deletion date. The ruling accepts this. The date counts from deletion, which adds a buffer. No change made.
2. **Day count against calendar years.** "1,461 days (four years)" can differ from four calendar years by a day. The ruling fixes the day count. No change made.

## Nov 24: business facts filled

Filled from the private facts file (DTI and BIR certificates): registered name, DTI Business Name No. 8567107, the place of business, and the price tax statement. Business phone filled too (+63 968 854 2343, supplied Nov 18). Still brackets, which only Aedwon can fill: publication date, NPC registration, plus the practice claims in the "Facts Aedwon supplies" list.

**TIN note.** No text carries the TIN. RA 11967 Section 23(f)(1) (read on lawphil) requires an e-retailer to publish the business name, the address of the place of business, and a mobile or landline number plus a valid email. It does not mention a TIN. I could not cite a BIR rule or JAO 24-03 provision that requires a TIN on the website or in the Terms, and I did not read the JAO in full. BIR invoice rules do require a TIN on invoices (from memory, not verified here). Put the TIN on the sales invoice when the invoice process exists. Do not commit it to the public repo.

**Phone.** RA 11967 Section 23(f)(1) requires a mobile or landline number on the homepage. The number is filled in the texts. The website footer and the app build input must show the same number.
