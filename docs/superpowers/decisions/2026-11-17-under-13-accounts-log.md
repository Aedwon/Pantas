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
