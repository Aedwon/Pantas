# Public-launch legal package (CSE public release)

Checklist rows: L1, L2, L7 and M10 in `docs/superpowers/plans/2026-11-22-cse-public-release-checklist.md`.
Drafted Nov 22, 2026 under process rule 5. Codex GPT 6.2 Sol High has not critiqued it yet: see `critique-prompt.md`. No lawyer reviewed it (Aedwon's Nov 9 decision, row L8). Nothing is published. No app code is changed.

Files:

- `change-summary.md`: one page for Aedwon. Start here.
- `terms.md`, `privacy-policy.md`, `teen-notice.md`: the three texts. Brackets mark facts only Aedwon has.
- `critique-prompt.md`: the exact prompt for the Codex critique.

## Standards applied

- Philippine Data Privacy Act (RA 10173) and its Implementing Rules: Sections 11 to 13 (principles, ordinary and sensitive information), 16 (rights), 18 and 19 (proportionality, retention). Source: lawphil.net and privacy.gov.ph, as read in `docs/legal/research/2026-11-11-minor-label-lawful-basis.md`.
- NPC Advisory Opinion 2017-049 (a minor cannot give valid consent alone), Advisory 2024-02 (Section 13(f) legal claims), Advisory 2024-03 (child-oriented transparency), Circular 2023-04 (consent).
- Consumer Act (RA 7394), Internet Transactions Act (RA 11967), E-Commerce Act (RA 8792), Civil Code Articles 1170 to 1172, 1327, 1390 to 1391, 2201. As used in the Oct 30 draft's notes.
- Tax record keeping: five years, as published in the live notices and `docs/legal/2026-11-09-publication-dependencies.md`. Not re-verified here: the critique prompt asks Codex to confirm.
- Writing: `agent-standards/ux-writing.md` (UXW-PLAIN, UXW-ACTIVE, UXW-TERMS), plus `AGENTS.md` voice rules (no em dashes, American spelling).
- No sheet exists in `agent-standards` for privacy or consumer law. Not written: this package cites the statutes directly. Worth adding later.

## Facts Aedwon supplies

Every item is a bracket in the texts. Nothing is invented.

1. Registered business name, exactly as on the DTI certificate. The live texts say "Pantas Online Tutorial Services". Confirm that is the registered name.
2. DTI business name registration number.
3. BIR registration: TIN, and VAT or non-VAT (percentage tax). This fills the price tax line and the receipt line in the Terms (rows M1, M8).
4. Address policy. The live texts show "Poblacion, Norala, South Cotabato". `docs/OPERATIONS.md` says no postal address by design. Choose: keep the town, or add a postal address. The Terms need an answer because the Internet Transactions Act expects a seller to show how to reach it (Codex to confirm).
5. Business phone. Supplied Nov 18 but not recorded in the repository, so it is a bracket.
6. Publication date. It becomes the version stamp (see "Publishing steps").
7. NPC registration details, if the business is registered. Leave the bracket out if not.
8. Two commitments only he can keep. The Terms promise a refund reply within 5 business days. The Privacy Policy says the business keeps tax books and receipts for five years outside the app (M10 below).

## M10: payment records versus account deletion

**What the system does today.** Deleting an account erases every payment record Pantas holds for it in the app database: the plan and refund ledger with amounts, the payment index, orders, checkout records and refund follow-ups. It keeps only:

- for an under-18 account, a copy of each guardian purchase confirmation (date, time, Terms version, reference, product; no amount, name or email);
- security log entries, 730 days;
- trial codes, with no end date.

So the published "keep payment and accounting records five years" was never true of the app database. The live Terms text also says deletion may leave "required accounting records". That wording is wrong for the app.

**Resolution in these drafts: text only, no code.** The texts now say:

- The app deletes its own account-linked payment records with the account.
- The five-year duty is met by the business's tax books, receipts and refund records, kept outside the app. These survive deletion.
- PayMongo and the bank keep their own records.

This is true as built. The tax law asks for books and receipts, not for the app database. It needs two things from Aedwon: keep a payment ledger (PayMongo reports plus refund bank references, which the refund runbook already records) and issue receipts after BIR registration.

**If he wants the app itself to keep five years:** the smallest code change. At deletion, before the erase, copy each payment's reference, product, amount, paid date and refund total into one archive collection with no account ID, with an expiry date, and add one TTL policy. About half a day with tests. A few hundred documents a year. Count it against the free tier before shipping (process rule 7). Not recommended for launch: it adds a data store that the text above makes unnecessary.

Residual risk: after deletion, Pantas cannot look up a person's payment in the app. A late refund request then depends on PayMongo's dashboard and the business ledger. The 30-day request window limits this.

## Where the app and the text disagree, or the app lacks something

- **Version stamps do not force re-acceptance (L7).** The checklist says a Terms version bump asks existing students to accept again. In code it does not. Onboarding only checks that an acceptance time exists. The stamps affect the guardian confirmation page (an old page reloads) and the under-18 checkout box. So existing adults learn of the new Terms only through the notice and email promised in Terms section 12 and the Privacy Policy "Changes" section (process rule 9). Someone must send that email, and it follows rules 6 and 8.
- **Age step copy.** The screen says "Choosing Continue means you agree to this check". The live notices said "specific permission". The new texts say "agree" and, for teens, say Continue is not the legal basis.
- **Terms promise 14 days of in-app notice before a material change.** The app has no general mechanism. A Home notice strip exists and was used for other notices. Build or reuse one per change.
- **Payment after the sitting date** refunds in full under the new Terms. The system flags that payment for a manual refund already, so the text now matches.
- **Moved or cancelled exam sittings:** no system rule. The Terms promise only a good-faith review.
- **Not built, so not in the texts:** the 730-day trial-code expiry, a protected payment archive, expiry of minimum confirmation evidence, screen counts (flag off in production), in-app data export (email only), and under-13 accounts (separate lane, E-124). If screen counts go on before launch, add the Fable-approved wording in `docs/superpowers/plans/usage-telemetry/step2-legal-draft.md` section 2 and move the stamps. If under-13 accounts ship first, merge that lane's text into these three files.
- **Settings that this repository cannot show:** Google Analytics 14-month retention, the 180-day provider backup removal, the 30-day report log retention, and Cloudflare's own request logs. The texts repeat the Nov 12 approved wording. Confirm each in the consoles before publishing.

## Publishing steps (for the integrator, L1 and L7)

1. Set the three version stamps to the publication date in both places: `guardianDocumentVersions` in the app and `GUARDIAN_DOCUMENT_VERSIONS` in the functions. Deploy together, or the guardian page refuses answers with "Reload the page".
2. Put the final texts into the in-app legal documents (the Terms title there is "Terms of Service") and as public pages on pantas.study. The site has only a beta-application privacy page today.
3. Remove every bracket first: `grep -n '\[' ` on the three texts must find none. Then run the `legal-text-drafting` check, which fails on the words "draft" and "owner note" in in-app text. It does not catch brackets.
4. Send the change email (rule 9) to existing students with an email address, and to guardians of under-18 accounts, after the self-test (rule 6).
5. Aedwon checks `change-summary.md` and signs off (L1, L2).

The change email wording and the in-app notice are not drafted here. They follow rule 8 and need their own pass.
