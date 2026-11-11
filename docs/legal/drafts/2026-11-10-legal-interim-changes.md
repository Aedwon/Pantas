# What changed in the in-app legal texts (interim, ships with the redesign)

Branch `ds4/legal-interim`, from `web/design-system-4` at b51a93c30. Read this before the
staging check. These texts describe the app as it is today. The privacy batch will replace
them later with the fuller version (`docs/legal-texts-r1`).

Process: lead draft from the round 1 and round 2 texts, then a Codex GPT 6.1 Sol high review
for accuracy against today's code (14 corrections, all applied), then this build. No lawyer
reviewed it.

## Notice for teens (rewritten)

- **Removed:** every drafting note shown to users, such as "this draft requires specific
  Section 13(a) consent" and "should not be described as anonymous". Also removed: the
  storage-rule tables, legal section numbers, and lists of what the app does not do. The
  notice goes from 27 sections to 16.
- **Added, because the app does these and the old notice did not say so:**
  - email-code sign-in, and Resend sending the sign-in codes;
  - RevenueCat for app-store purchases;
  - servers in Google's Singapore region;
  - how software uses answers (review dates, study-style labels);
  - Wrapped share cards and their share records;
  - messages sent to us;
  - Google's logs recording IP addresses for speed and error reports;
  - the guardian answer record, which stays after account deletion.
- **Corrected:**
  - Optional sharing sends question IDs, the chosen answer and whether it was correct.
  - Account deletion removes Pantas's own payment records.
  - Trial codes have no set end date.
  - Analytics follows the account's retention setting.
  - The 180-day backup removal covers sign-in data only.
  - A student waiting for a guardian deletes by email.
- **Withdrawal:** by email to dpo@pantas.study only. No button is described.
- **Not mentioned, because not built:** a guardian manage page, a withdraw button, an
  inactivity purge, a speed-report off switch, an under-18 checkout box, "I'm 18 now".

## Privacy Policy (new full text)

- It was a three-line stub. It is now 14 sections for adults, mirroring the teen notice:
  who runs Pantas, the age check, what is collected, how answers are used, optional sharing,
  speed and error reports, providers, rights, deletion, storage periods, legal reasons,
  safety, and changes.

## Terms of Service: "Subscriptions" only

- **Trial:** "The free trial is on Monthly only." Weekly, Yearly and Season Passes have no
  trial. It runs seven days, needs no payment details, and never becomes a paid plan.
- **Beta:** the dated "November 9 to 15 beta" paragraph is replaced by one general paragraph
  on free or promotional access.
- **Refunds:** the same rules as before (duplicates and payments that never unlocked Pro,
  within 30 days; no refunds for a change of mind or unused time), now labeled a voluntary
  policy with one line keeping legal remedies. The partial-refund sentence now matches the
  code: it shortens the access and can end it at once.
- **Bank disputes:** access is suspended while a dispute is open, and ends if the payment is
  reversed. If Pantas wins, the suspension lifts and the original end date stands.
- **Under 18:** a parent or guardian should buy with their own payment method and accepts the
  Terms as the buyer. Pantas may cancel and refund a purchase made without their agreement.
- **New:** a complaint line (support@pantas.study; the internal process ends after seven
  unresolved days). The price shown at checkout is the full amount.
- **Unchanged:** every other Terms section.

## Versions and dates

- The "Updated" date on all three documents changes to November 10, 2026.
- The guardian document versions change to 2026-11-10 in the app and in the functions.
  **Deploy the functions together with the web app.** Otherwise the guardian page refuses
  confirmations with "Reload the page to review the current terms."

## Check added

- `legal-text-drafting` (in `tool/checks/`) fails if any in-app legal text contains "draft" or
  "Section 13(a)". It failed on the old teen notice and passes on this text.

## Left as is

- `docs/TERMS.md` and `docs/PRIVACY.md` still carry old v0 drafts, including a Yearly trial
  and old prices. They are marked "Not for publication", and nothing in the app or on the
  site shows them.
