# Under-13 accounts: decision log

Lane: under-13 lead, branch `spec/under-13-accounts`. Estimate row E-108 in the velocity log.
Spec: `docs/superpowers/specs/2026-11-17-under-13-accounts-design.md`.

## Context (Nov 17)

- The PSHS-NCE test is January 30, 2027. Most takers are 11 or 12. The app is 13+.
- Aedwon, Nov 17, on selling PSHS-NCE this cycle: "A", after "actually correction, PSHS-NCE can still sell".
- Aedwon, Nov 17, on starting PSHS-NCE items: "yes go start things for PSHS-NCE please, thanks though, wait for codex resets. this is true for lesson-generation related tasks and threads".
- Backlog: D7 (parent and child pairing) merged into E5 (under-13 support, trigger: PSHS-NCE is scheduled).

## Decision 1: who holds an under-13 account (Nov 17)

Options offered (lead to Aedwon):

1. Guardian holds the account (recommended). The parent signs in with their own email, says they are setting up for their child, and accepts the terms. The child uses it with a nickname. The parent buys the pass. Strongest consent. About 2 to 3 days to build.
2. The child holds the account, and the emailed guardian link extends to under-13s. Cheapest, 1 to 2 days, weakest: a child can type a second email they control.
3. Linked parent and child accounts (QR pairing). Most flexible, 5 to 7 days, puts mid-December at risk.

Aedwon's answer, relayed by the manager: "yes guardian". Choice: option 1.

## Decision 2: Fable 5.2 rulings on the delegated design (Nov 17)

The lead proposed rulings R1 to R15 (kept below as proposed). The Fable 5.2 advisor ruled at high effort. Under his delegation the ruling is final.

| # | Lead proposal (short) | Fable ruling |
|---|---|---|
| R1 | Under 13 at the age step: "Ask a parent or guardian" screen, button "I'm the parent or guardian". No permanent block | CHANGE: keep the fork. The device stays on the guardian screen after an under-13 answer, so retyping an adult age does not bypass it. Nothing goes to the server until the guardian accepts |
| R2 | Guardian declares 18+ and parent, signs in (email code or Google, required), one tick for Terms, Privacy, Child Notice | CHANGE: two ticks. Tick 1: declaration plus Terms. Tick 2: consent to the child's data processing. Bundled consent is barred by commentary on NPC Circular 2023-04 (check the official text when drafting). Wording "parent or guardian with authority over this child". Email the guardian a receipt with a delete link |
| R3 | The account is the guardian's, used by the child | ACCEPT. One child per email |
| R4 | Child accounts limited to PSHS-NCE, minimum 10 | CHANGE: no lower age limit (the input floor of 5 stays). PSHS eligibility is by grade, the only age rule found is an upper limit. The server refuses non-PSHS purchases on child accounts |
| R5 | Nickname only, exam data, progress, `child` label, consent record. No exact age | ACCEPT. Do not prefill the nickname from the guardian's Google name |
| R6 | Analytics, share cards, push off; Crashlytics on without user ID | CHANGE: Crashlytics does not run on web. Turn off the web equivalents (usage visits, speed and error reports). Block hosted Wrapped pages on the server too |
| R7 | Reuse the guardian consent record with `ageGroup: child`, `method: guardian_held` | CHANGE: only the server writes it, at acceptance. Every check that tests for `minor` today must treat `child` and unknown values as restricted |
| R8 | Account settings are the guardian controls; one line "managed by a parent or guardian" | ACCEPT. Add a "For parents" entry: Child Notice, data copy, delete. If the export does not work, route through the data protection officer |
| R9 | Child accounts always see a checkout declaration | CHANGE: show the box on every PSHS-NCE purchase, whatever the age group. Keep "and I accept the Terms" |
| R10 | No change at 13 | ACCEPT. Staying `child` is the stricter treatment |
| R11 | Self-declared adults are not detected | ACCEPT with R1's device rule. Terms say Pantas deletes under-13 accounts found without guardian setup. Support needs that procedure |
| R12 | Web only; Android listing stays 13+ | CHANGE: hide PSHS-NCE entirely on Android this cycle |
| R13 | Child Privacy Impact Assessment, internal | CHANGE: complete and sign it before sale. Cover the teen flow too |
| R14 | Same retention as other accounts | CHANGE: delete child accounts after 12 months inactive. State it in the Child Notice now. Build it before November 2027 |
| R15 | Clear stored under-13 blocks | CHANGE: reinterpret the block so those devices open on the guardian screen |

Gaps Fable added, adopted into the spec:

- An adult account that picks or switches to PSHS-NCE is asked "Is this for a child under 13?"; yes routes to guardian setup.
- Sign-in on a new device restores `child` from the server and skips the age step.
- If the guardian's email already has an account, setup refuses and asks for another email.
- The Child Notice has a legal layer for the guardian and a plain layer for the child (Advisory 2024-03). It lists sign-in identifiers, rate-limit records, payment records and processors abroad.
- Terms: the guardian is the contracting party, warrants authority and answers for the child's use.
- Consent evidence kept after deletion needs a stated period.

Items Fable said Aedwon must decide (put to him in the spec approval section with recommendations):

1. NPC registration and the signed assessment before sale (recommend file before sale).
2. Free use for child accounts (recommend keep free use).
3. Refund when a guardian deletes a paid account (recommend standard policy only, stated at checkout).
4. PSHS-NCE marketing addresses parents (recommend yes; website copy stays his).
5. Siblings need a second email this cycle (recommend accept).

Lead mistake recorded: the lead proposed a PSHS-NCE minimum age of 10 without a source. Fable rejected it.

## Decision 3: Codex GPT 6.1 Sol High critique of the legal draft (Nov 17)

Ran through `codex-pick` once accounts had 5-hour room (a: 32% room). Fourteen findings. Lead rulings:

- Adopted: 2 (guardian answers for own breach, no "child's breach"), 3 (no change-of-mind refund,
  statutory rights kept), 4 (CPIA is required before child accounts open, not a sales choice), 5
  (separate child-facing layers and a just-in-time notice), 6 (breach notice to NPC, guardian and
  child), 7 (sign-in data reaches the server before setup), 8 (retention wording, no Art. 1144
  justification), 9 (withdraw control), 10 (study guidance explained), 11 (bundled-consent claim
  softened, two ticks kept), 12 (receipt or invoice, phone number from Aedwon), 13 (one-account
  clause, sync every declaration), 14 (child wording).
- Not adopted as a flow change: 1 (the age check relies on the child's consent). Aedwon kept the
  current age-step flow on Nov 11 after the lawful-basis research. The draft states the same basis as
  the live teen notice, not consent, and the risk is listed in the spec and the assessment.

## Boards (Nov 17)

Claude Design artifact https://claude.ai/artifact/PqxcZvKQheCogaXH6LidPM, label "Reviewer fixes: system parts, no nickname". Options 1A/1B (guardian screen), 2A/2B (parent setup, error, short child notice), 3A/3B (adult PSHS-NCE question), 4A/4B (For parents, withdraw and delete confirms), 5 (exam picker on a child account). Author recommends 1A, 2A, 3A, 4B. A fresh reviewer checked each against DS4 and patterns.md. All departures were fixed, and every board rendered headless. Lead ruling: the nickname moves off the setup page to the normal name step, after the short child notice. Awaiting Aedwon's pick.

## Decision 4: Aedwon's A9 answers; Part A approved (Nov 17)

Relayed by the manager, verbatim where quoted:

1. Sign the impact assessment before child accounts open: "ok".
2. Keep free use for child accounts: "ok keep".
3. No change-of-mind refund, statutory refunds stay: "ok with reco".
4. PSHS-NCE marketing addresses parents: "yes".
5. Second child needs a second email: "no". His words: "'One email holds one child.' edge case: what about twins. we should allow multiple."
6. Business phone: "this is already in the docs". The lead searched and did not find a phone number in: the Pantas repo on origin/main (docs, lib, functions, web; phone-number patterns and the words phone, telephone, contact number, landline, Viber), the live legal text, the Nov 5 teen notice draft (it has the operator name, the sole proprietorship name and the business address, Poblacion, Norala, South Cotabato, but no phone), the local pantas-web project (all pages; the only matches were SVG coordinates on the About page), Pantas-private, Pantas-handoffs, and Pantas/build. The Master SSOT Google Doc was not searched. The placeholder stays until he points to it.
7. Legal sign-off: "sure". Given for the drafts as they stood. The multi-child changes get a Codex re-critique and a short diff summary for him before that part counts as signed.

The manager stated: "Part A is approved with these answers."

## Decision 5: Fable 5.2 ruling on several children per email (Nov 17)

Final under his delegation.

- Model (b): the guardian email is a holder Firebase user with no study data. Each child is a separate emailless Firebase user linked on the server. The child session comes from a custom token after holder sign-in. Rejected (a), several profiles in one user, because every per-uid system (progress, roadmap, scheduler, sync, entitlements, export, deletion) would need reworking.
- Both ticks are given per child at each add. Evidence is recorded per child with the holder ID and link. One receipt goes out per child.
- Switching is open between siblings with no gate. A 6-digit mailed code guards adding a child, the data copy, withdraw and delete.
- Limit: 5 active children per email.
- Each pass belongs to one child. The price for a second child is Aedwon's decision; Fable recommends full price.
- "For parents" acts per child. Closing the last child deletes the holder.
- Existing accounts: a holder adds a child; an account with progress is refused; an empty named account becomes the holder.
- Conflicts found: orphan cleanup would delete free children; switching may upload the previous account's local data (to be re-verified, and possibly an existing defect for ordinary switching); emailless tokens break the beta gate and trial check; the nickname is not on the server today.
- Effort: +4.25 to 4.5 days, for a total of 8 to 9.5.
- Legal text changes materially in the Terms child section, the Child Notice, the receipt email and the impact assessment. The tick wording is unchanged.

## Decision 6: Codex re-critique of the multi-child legal changes, and Fable's revised switching ruling (Nov 17)

Codex GPT 6.1 Sol High, through `codex-pick`, critiqued only the multi-child diff. It made seven findings.
- Items 1 and 2 (HIGH) challenged open sibling switching under Advisory 2024-03's highest-privacy default.
- Fable revised ruling 3, final: switching is off by default, per child. While off, every switch into that child needs the emailed code, with no per-device memory. The guardian opt-in "Siblings can open this account without a code" is in For parents, behind the gate, after a sharing notice. It is recorded per child. Later children start off. Effort +0.5 day, for a total of 8.5 to 10.
- Rejected: Fable's earlier open switching, superseded by the default above.
- Adopted: 3 (codes bound to holder, child and action, expire, work once, limited attempts), 4 (preserve or isolate each child's pending records before clearing), 5 (narrower last-child deletion wording), 6 (DPO route when the email is unreachable), 7 (a pass activates only for the child chosen at checkout; checkout shows child, price and dates).

## Boards after the multi-child change (Nov 18)

Same artifact, label "Final review fixes: 6A, 8, 9, notes". The new boards are 6 (Switch Child), 7 (Add a Child), 8 (code gate) and 9 (sibling access opt-in), each with A and B options. The author recommends 6B, 7A, 8A and 9A; the earlier picks were 1A, 2A, 3A and 4B. Two fresh reviews ran and every departure was fixed. All changed boards render headless.

In-app copy the lead settled under rule 4, outside the legal text: "Needs a code", "Let siblings open this account?", "Sibling access", "Turn On", "You have 5 children", "Got It", "Pick a nickname", "This sets up your first child. You can add more children later in Settings.", "These actions apply to this child only.", and the delete confirm body (the standard consequence line plus the last-child line).

Aedwon's plain summary of the legal changes since his "sure" (for his sign-off on the multi-child part):
1. Each child's account is separate. Siblings cannot open it unless the parent turns that on.
2. Codes are tied to one child and one action.
3. A parent with no email access can write to the data protection officer.
4. Closing the last child closes the parent sign-in but keeps limited records.
5. A pass covers one child, and the price is his to decide.

## Business phone (Nov 18)

Relayed by the manager: Aedwon gave the business phone as +63 968 854 2343. It is in the legal draft's contact block and the impact assessment. The SSOT listed it as an owner input still owed. The lead's earlier search was right that it was not in the repo.

## Decision 7: guardian contact on the device at sign-out (Nov 18)

This came from the Codex review of the account-switch leak fix (main 0e7502973), relayed by the manager. A guardian's name and email entered on the device survive Sign Out.

Fable 5.2 ruled, and the ruling is final:
- Erase. Sign Out, Delete Account and any account switch delete the guardian's name and email from the device. They are not kept per account.
- Ship it as a small fix, about 2 hours, before the under-13 build.

Fable's findings:
- The device stores the guardian's name and email in plain text among device settings, and the wiper skips them.
- The server keeps only a hash and a masked email.
- Only Resend needs the local copy. Without it, Resend opens the contact form.
- When app start learns of a confirmation, nothing deletes the local copy, although the notice says the device deletes it then.

Files:
- `lib/core/sync/local_state_wiper.dart`: wipe the contact, the cached guardian status and the sharing-applied flag. Keep the closed-account marker.
- `lib/features/guardian/application/guardian_providers.dart`: delete the contact wherever the device learns of the confirmation.
- Tests: `test/core/sync/local_state_wiper_test.dart` and `test/features/guardian/guardian_controller_test.dart`.

Rejected: keeping the contact per account. It would leave a third party's details in plain text on a shared device indefinitely.

The under-13 spec gains rule 4d.

## Decision 8: price for a second child (Nov 18)

Relayed by the manager: A9 item 8 decided, full price for a second child, ₱1,499 per child. No sibling price this cycle. The legal draft's price marker is resolved to this.
