# Under-13 accounts: a parent or guardian holds the account

Status: draft for Aedwon's approval of Part A. Nothing is built.
Date: November 17, 2026. Lane: under-13 lead (Opus 5.5), branch `spec/under-13-accounts`.
Policy read: `origin/main` (`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`,
`docs/workflow/process-improvement.md`).
Decision log, with his exact words and the Fable rulings: `docs/superpowers/decisions/2026-11-17-under-13-accounts-log.md`.
Legal draft: `docs/legal/drafts/2026-11-17-under-13-legal-draft.md`. Privacy impact
assessment: `docs/legal/drafts/2026-11-17-child-privacy-impact-assessment.md`.
Velocity row: E-108 (this spec). The build gets its own row.
Boards: to be built in Claude Design from the approved screens (rule 3) after Part A is approved;
listed in A6.

---

## Part A: for Aedwon

### A1. Goal

Sell the PSHS-NCE season pass this cycle (your "A", Nov 17). The test is January 30, 2027. Most
takers are 11 or 12, and Pantas is 13+ today. Target: on sale by mid-December.

### A2. Decisions you already made

- Sell PSHS-NCE this cycle: "A" (Nov 17).
- A parent or guardian holds the account for a child under 13: "yes guardian" (Nov 17).
- Design details you delegated were ruled by the Fable 5.2 advisor. The rulings are final and are
  listed in the decision log.

### A3. What a family sees

1. A child opens Pantas and enters an age under 13. The app says to ask a parent or guardian to
   set it up, with a button "I'm the parent or guardian". The phone stays on this screen, so
   typing a new age does not get around it.
2. The parent taps the button and signs in with their own email or Google. One email holds one
   child.
3. The parent ticks two boxes: first, that they are 18 or older, are the parent or guardian, and
   accept the Terms; second, that they consent to the child's data being used as the Child Notice
   says.
4. Onboarding continues as usual with a nickname, the exam, the date and study days. Only PSHS-NCE
   is available on a child account.
5. The parent gets a short receipt email with a link to delete the account.
6. Studying works as it does for everyone. Some things are off for a child account: usage
   analytics, speed and error reports, share cards, and push notifications.
7. The parent buys the ₱1,499 pass. Every PSHS-NCE purchase, from any account, shows the box "I
   am the parent or guardian ... and I accept the Terms."
8. Settings has a "For parents" entry with the Child Notice, a copy of the data, and delete.

If a parent sets up an adult account and picks PSHS-NCE, the app asks "Is this for a child under
13?" A yes goes to the parent setup.

### A4. What we keep about a child

The guardian's email, the child's nickname, exam, exam date, study days, progress, the label
"child", the consent record, and payment records. We never keep the child's exact age or birth
date. A child account is deleted after 12 months without use. This promise is in the notice now,
and the deletion job must be built before November 2027.

### A5. How it fits what exists

- The 13 to 17 emailed guardian link stays as it is.
- The under-13 block becomes the guardian screen. Phones blocked under the old rule open on it.
- Every place that treats "minor" carefully today treats "child" the same or stricter.
- Signing in on a new phone brings back the child label and skips the age question.
- PSHS-NCE is hidden on Android this cycle. The child path is web only.
- Checkout reuses the guardian box that minors see today. The server enforces it.

### A6. What gets built (balanced)

- The age step's guardian screen, the parent setup with two ticks, and the receipt email.
- Child account limits: PSHS-NCE only, the adult PSHS-NCE question, analytics, reports, share
  cards and push off, and the label restored on sign-in.
- The checkout box on every PSHS-NCE purchase, with server checks.
- The "For parents" entry, plus the new Child Notice and updated Terms and Privacy Policy in the
  app.
- PSHS-NCE hidden on Android.

Screens that need boards for your pick: the guardian screen, the parent setup, the "Is this for a
child?" question, and the "For parents" entry. The checkout box keeps its approved layout with new
text, so the lead settles that wording under rule 4.

### A7. Cost and dates

- Build: about 4 to 5 working days, including tests and a staging check. The earlier figure of 2
  to 3 days was before Fable added the gaps it found (the adult PSHS-NCE question, restoring the
  label on a new phone, server checks for every "minor" test, and hiding PSHS-NCE on Android).
- Boards: about half a day, then your pick.
- Path to mid-December, if Part A is approved this week: boards by about Nov 24, build Nov 25 to
  Dec 2, staging and your check by Dec 4, prod after your "ship it". That leaves about a week of
  slack before mid-December.
- Running cost: none new. The receipt email uses the existing mail service.

### A8. What else the sale needs (not this lane)

These are judgments with sources, not your decisions. Each one blocks the sale on its own.

- The abstract reasoning generator must ship first (`docs/pricing.md`, release requirement). Its
  app and server parts start Nov 23 (question generator log).
- PSHS-NCE content: math is being sourced, and the other subjects are not started (question
  generator log).
- The ₱1,499 pass does not exist as a product yet, and live payments on prod are unconfirmed.
- The beta gate is still on. The public launch follows the beta, which ends Nov 22.

### A9. Decisions for you

Each comes with a recommendation. If you approve Part A without comment, the recommendations hold.

1. NPC registration and a signed privacy impact assessment before the sale. Recommend: file before
   the pass goes on sale. Children's data raises the exposure. The assessment is drafted for your
   signature.
2. Free use for child accounts. Recommend: keep free use, as for everyone else. Paid-only would make
   payment a second adult check on every child account, but it cuts sign-ups.
3. Refund when a guardian deletes a paid account. Recommend: no refund beyond the standard policy,
   stated at checkout.
4. PSHS-NCE marketing speaks to parents, not children. Recommend: yes. The website copy stays yours.
5. A second child needs a second email this cycle. Recommend: accept this.
6. Legal sign-off on the final text, after the Codex critique. You check the result; you do not
   write it (rule 5).

### A10. Risks

- No lawyer reviews this text. You accepted this risk on Nov 9 (rule 5). Under-13s raise the stakes.
- A guardian's claim is self-declared. Payment, the receipt email and the low-risk data set are the
  safeguards. The NPC does not forbid self-declaration but says it may be weak for risky processing.
- A parent can still enter their own age and let a child use an adult account. The PSHS-NCE question
  and the checkout box narrow this. They do not close it.

### A11. How we will know it is done

- A family can go from the age question to a paid PSHS-NCE pass on staging, with the consent
  record, receipt email and checkout record in place.
- A child account cannot pick another exam, buy another product, turn on analytics, or share a card.
  The server refuses each, not only the screen.
- Signing in on a second phone keeps the account a child account.
- The legal texts in the app match the approved draft, with version stamps.

---

## Part B: for agents

### B1. Facts (origin/main, Nov 17; the plan re-verifies each)

- Onboarding order is welcome, age, guardian (under 18), terms, exam picker
  (`lib/features/onboarding/application/onboarding_flow.dart:8-20`). The age step asks exact age (5
  to 100) and calls `AgePolicy.forExam(null)`, so the minimum is always 13
  (`onboarding_age_gate_step.dart:56-58,212`). Under the minimum it stores a device block (`:244`)
  that survives reload.
- `AgePolicy` minimums: CSE Pro and Sub at 13, default 13 (`age_policy.dart:31-34`). No PSHS-NCE
  entry.
- The device stores only `minor` or adult and the notice version (`onboarding_age_gate_step.dart:253-259`).
  The server writes `ageGroup: 'minor'` on guardian link request (`functions/src/guardianConsent.ts:248`).
- Guardian consent for 13 to 17 is live: record at `users/{uid}/server/guardianConsent`, evidence at
  `guardianConsentEvidence/{uid}/responses` (`guardianConsent.ts:369-374`), mail through Resend
  (`guardianMail.ts`).
- Checkout: `functions/src/paymongoCheckout.ts` enforces `guardian-attestation-required` for minors
  (`:38-48`); named sign-in required (`_audit.ts:33`). The box text is in Terms
  (`legal_document.dart:374-375`). Shown in `pro_page.dart:841-844`. `functions/src/products.json`
  has no PSHS-NCE product.
- "Help improve Pantas" defaults off and is forced off for minors (`user_settings.dart:67`,
  `onboarding_consent_step.dart:86-89`).
- Live legal text: `lib/features/legal/domain/legal_document.dart` (Terms `:268-270`, `:373-382`;
  Privacy opening `:44-45`; under-13 block sentence `:62-63`; teen notice from about `:491`). Version
  stamps 2026-11-12.
- No age check on exam switching.

### B2. Rules

1. Child label. A new age group value `child`. Only the server sets it, inside the guardian setup
   callable, after both ticks are recorded. The client never writes it.
2. Restricted by default. Every existing check on `minor` (checkout attestation, analytics switch,
   guardian gating, share, any other) treats `child` and any unknown or missing-but-expected value as
   restricted. Grep for every `minor` comparison on client and server; the plan lists each one.
3. Age step fork. Age under 13 stores a device state `needsGuardianSetup` (replacing the block for
   under-13; reinterpret an existing stored under-13 block as this state). The state persists; a new
   age entry does not clear it. Only completing guardian setup or "Start over" from support clears it.
   No server call happens before acceptance.
4. Guardian setup. Requires a named sign-in (email code or Google). If the signed-in account already
   has a profile or progress, refuse with "This email already has a Pantas account. Use another
   email." Two separate ticks; both required. Do not prefill the nickname from the Google profile.
5. Consent evidence. Reuse the evidence collection with `ageGroup: child`, `method: guardian_held`,
   document versions (terms, privacy, child notice), tick text versions, and server time. Retention of
   evidence after deletion follows the legal draft's stated period.
6. Receipt email. Product-sent (not covered by rule 6's self-test). Reuse `guardianMail.ts`. Contains a
   delete link that opens the app's delete flow after sign-in. Text from the legal draft.
7. Exams. A child account may select and switch only to PSHS-NCE. The server refuses checkout for any
   non-PSHS product on a child account. The exam picker shows other exams as unavailable, "For ages 13
   and up".
8. Adult PSHS-NCE prompt. When an adult account selects or switches to PSHS-NCE, ask "Is this for a
   child under 13?" Yes: start guardian setup on this account if it has no progress; otherwise explain
   that a new email is needed. No: continue.
9. Off for child accounts, client and server: usage analytics, web speed and error reporting with user
   context, share cards and hosted Wrapped pages (server refuses), push notification registration.
10. Sign-in restore. On sign-in, read the age group from the server. `child` skips the age step and
    applies all limits.
11. Checkout box. Shown on every PSHS-NCE purchase, any age group. Server-enforced for PSHS-NCE
    products. Text from the legal draft, keeping "and I accept the Terms". Record text version and time
    as today.
12. For parents entry. In Settings for child accounts: the Child Notice, the data copy (verify the
    existing export works; if not, the entry shows the data protection officer contact), delete account.
13. Android. Hide PSHS-NCE from the exam list and switching on Android builds this cycle.
14. Legal texts. Add the Child Notice as a legal document with its own version stamp. Update Terms
    and Privacy text from the approved draft. Bump versions.
15. Inactivity deletion at 12 months for child accounts: not in this build. Track it as a dated
    backlog item, due before November 2027.

### B3. Out of scope

Linked parent and child accounts (QR), child-to-teen conversion at 13, more than one child per email,
the PSHS-NCE product itself, live payment setup, the generator, PSHS-NCE content.

### B4. Verification

- Unit tests for the age fork state, the restricted-by-default checks, and the server callable
  (refuses existing accounts, refuses missing ticks, writes evidence).
- Server tests: checkout refuses child + non-PSHS, requires the box for PSHS-NCE; Wrapped hosting
  refuses child.
- A journey in `tool/journeys/` for the family path on staging, through a test-mode PayMongo purchase.
- Visual check of each boarded screen against the picked board (Aedwon).

### B5. Privacy change process

This changes what Pantas collects and from whom. Rule 9 applies once the app is public: the build
lead flags it in the handoff, and the manager holds prod until any required notice email has gone.
Existing users are not affected (no new collection from them), so the plan confirms whether an email
is needed at all and records the answer.
