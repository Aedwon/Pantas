# Under-13 accounts: a parent or guardian holds the account

Status: Part A approved by Aedwon on November 17, 2026, with his A9 answers (relayed by the
manager; exact words in the decision log). Amended the same day for several children per guardian
email (his answer to A9 item 5), ruled by Fable. Nothing is built; the plan is next.
Date: November 17, 2026. Lane: under-13 lead (Opus 5.5), branch `spec/under-13-accounts`.
Policy read: `origin/main` (`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`,
`docs/workflow/process-improvement.md`).
Decision log, with his exact words and the Fable rulings: `docs/superpowers/decisions/2026-11-17-under-13-accounts-log.md`.
Legal draft: `docs/legal/drafts/2026-11-17-under-13-legal-draft.md`. Privacy impact
assessment: `docs/legal/drafts/2026-11-17-child-privacy-impact-assessment.md`.
Velocity row: E-108 (this spec). The build gets its own row.
Boards: https://claude.ai/artifact/PqxcZvKQheCogaXH6LidPM (Claude Design, for your pick; listed in A6).

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
2. The parent taps the button and signs in with their own email or Google. One email can hold up
   to 5 children, such as twins or siblings. Each child gets their own account, with their own
   progress and pass, and no email of its own.
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
8. Settings has a "For parents" entry with the Child Notice, a copy of the data, and "Withdraw
   permission and close account". These act on the current child only. A 6-digit code mailed to
   the parent guards adding a child, the data copy, withdraw and delete.
9. "Switch Child" in Settings lists the children by nickname. Switching needs no code, so a sibling
   can open a sibling's account. Fable accepted this: same parent, low-risk data, and a code on every
   switch would push twins onto one shared account.

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

- Build: about 8 to 9.5 working days, including tests and a staging check. It was 4 to 5 for one
  child per email. Several children add about 4.5 days: the parent and child account link (1.5),
  the code gate (0.75), fixes to cleanup, mail, beta and trial checks (0.5), the picker and switching
  (1), and a two-child staging journey (0.75). The first 2 to 3 day figure came before Fable's gaps.
- Boards: three more (picker, add a child, code gate), then your pick.
- Path to mid-December: boards picked by about Nov 23, build Nov 24 to Dec 7, staging and your check
  by Dec 9, prod after your "ship it" around Dec 10. That leaves about 3 working days of slack.
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

Answered Nov 17: 1 "ok", 2 "ok keep", 3 "ok with reco", 4 "yes", 5 "no" (allow several children;
see A3), 6 "this is already in the docs" (not found yet; see the decision log), 7 "sure" (legal
sign-off, with the multi-child changes re-critiqued and shown to you). Item 8 is new and open.

1. Not a choice, an action for you: the law requires the child privacy impact assessment to be
   complete before child accounts open, free or paid (NPC Advisory 2024-03, per the Codex critique).
   It is drafted for your signature. NPC registration depends on legal criteria, not preference; the
   plan checks them and tells you whether to file.
2. Free use for child accounts. Recommend: keep free use, as for everyone else. Paid-only would make
   payment a second adult check on every child account, but it cuts sign-ups.
3. Refund when a guardian deletes a paid account. Recommend: no change-of-mind refund, stated at
   checkout. Refunds the law requires stay available; the Terms cannot remove them.
4. PSHS-NCE marketing speaks to parents, not children. Recommend: yes. The website copy stays yours.
5. A second child needs a second email this cycle. Recommend: accept this.
6. A business phone number. E-commerce law (RA 11967) asks sellers to publish one with their
   address and email. Recommend: give one, or confirm one already published.
7. Legal sign-off on the final text, after the Codex critique. You check the result; you do not
   write it (rule 5).
8. Open: the price for a second child. Each pass belongs to one child's account. Recommend: full
   price per child this cycle (₱1,499 each). A sibling price needs a new pricing entry and about one
   more day of build.

### A10. Risks

- No lawyer reviews this text. You accepted this risk on Nov 9 (rule 5). Under-13s raise the stakes.
- A guardian's claim is self-declared. Payment, the receipt email and the low-risk data set are the
  safeguards. The NPC does not forbid self-declaration but says it may be weak for risky processing.
- The age question runs before any guardian is involved. The basis is the one you kept on Nov 11
  (current flow, option A). Codex flags that a child cannot consent to it. The draft uses the same
  basis as the teen notice, not consent; a regulator could still question it.
- A sibling can open a sibling's account on a shared phone (accepted, A3 item 9).
- Twins sharing one browser lose streaks, bookmarks and flags at each switch, because those stay on
  the phone today. Holding them on the server is a follow-up.
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
4. Guardian setup (Fable multi-child ruling, Nov 17). Requires a named sign-in (email code or
   Google). The guardian's sign-in is a holder account with no study data; the server refuses study
   and checkout on it. Each child is a separate Firebase user with no email, linked to the holder on
   the server; the server issues the child's session by custom token after the holder signs in. A
   one-child family uses the same shape. Limit 5 active children per holder (more through support).
   Existing accounts: a holder signs in and adds a child; an adult or teen account with a profile or
   progress is refused with "This email already has a Pantas account. Use another email."; a named
   account with nothing on it becomes the holder. Both ticks are given per child at each add, and
   recorded per child with the holder ID and link. Do not prefill the nickname from the Google
   profile. The nickname is stored on the server per child for the picker.
4a. Switching. The device stays signed in as the last child. "Switch Child" lists siblings by
   nickname, no gate. Every child open or switch wipes local state first (Fable found the next
   account can upload the previous one's local answers and settings; the plan re-verifies this in
   `lib/core/auth/auth_repository.dart` and `lib/core/sync/local_state_wiper.dart`, and checks
   whether it affects ordinary account switching today).
4b. Guardian code gate. A 6-digit code mailed to the holder's email, entered inside the child's
   session, guards Add a Child, the data copy, withdraw and delete. Withdraw and delete act on that
   child only; closing the last child also deletes the holder and its email.
4c. Server fixes for emailless children: exempt linked children from `cleanupOrphanAnons.ts`; make
   the beta gate (`betaAccess.ts`) and trial check (`webTrial.ts`) handle a child token with no
   email; receipt and inactivity mail go to the holder's address.
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
    existing export works; if not, the entry shows the data protection officer contact), "Withdraw
    permission and close account" with its consequences text (free; processing stops; limited records
    kept as the notice states). A short child notice is shown before processing (Advisory 2024-03
    just-in-time layer). Each purchase issues an electronic receipt or invoice (verify PayMongo does).
13. Android. Hide PSHS-NCE from the exam list and switching on Android builds this cycle.
14. Legal texts. Add the Child Notice as a legal document with its own version stamp. Update Terms
    and Privacy text from the approved draft. Bump versions.
15. Inactivity deletion at 12 months for child accounts: not in this build. Track it as a dated
    backlog item, due before November 2027.

### B3. Out of scope

QR pairing, child-to-teen conversion at 13, more than 5 children per email without support, a sibling
price, server-held streaks, bookmarks and flags, the PSHS-NCE product itself, live payment setup, the generator, PSHS-NCE content.

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
