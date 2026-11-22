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

1. Registered business name, exactly as on the DTI certificate. The live texts say "Pantas Online Tutorial Services". Confirm that is the registered name.
2. DTI business name registration number.
3. BIR registration: TIN, VAT or non-VAT (percentage tax), and the tax statement for the price line (Terms, "Price"). Also the BIR proof of registration the law requires him to display.
4. Full place of business, as on the registration. "Poblacion, Norala, South Cotabato" names a barangay and town, not a place of business. The critique says a Terms page alone is not enough: the seller details also belong on the homepage (decision D3).
5. Business phone. Supplied Nov 18 but not recorded in the repository, so it is a bracket.
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

## Publishing steps (for the integrator, L1 and L7)

1. Set the three version stamps to the publication date in both places: `guardianDocumentVersions` in the app and `GUARDIAN_DOCUMENT_VERSIONS` in the functions. Deploy together, or the guardian page refuses answers with "Reload the page".
2. Put the final texts into the in-app legal documents (the Terms title there is "Terms of Service") and as public pages on pantas.study. The site has only a beta-application privacy page today.
3. Remove every bracket first: `grep -n '\[' ` on the three texts must find none. Brackets include the retention periods, the invoice sentence and the legal-hold note. Then run the `legal-text-drafting` check, which fails on the words "draft" and "owner note" in in-app text. It does not catch brackets.
4. Send the change email (rule 9) to existing students with an email address, and to guardians of under-18 accounts, after the self-test (rule 6).
5. Aedwon checks `change-summary.md` and signs off (L1, L2).

The change email wording and the in-app notice are not drafted here. They follow rule 8 and need their own pass.
