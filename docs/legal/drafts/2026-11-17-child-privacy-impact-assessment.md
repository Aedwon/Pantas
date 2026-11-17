# Privacy Impact Assessment: child accounts and the teen guardian flow

Draft, Nov 17, 2026. Written by an agent. No lawyer has reviewed it. Format follows NPC practice and the child-focused component in NPC Advisory 2024-03, Section 2(A) (official text not read; see the legal draft's source list). Revised after the Codex critique. The child privacy impact assessment (CPIA) must be completed before child accounts are enabled, free or paid. Paid status does not change that duty.

Controller: Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services. Data Protection Officer: the same person.

## 1. Processing description

**Child accounts (under 13).** A parent or guardian signs in with their own email, a holder sign-in with no study data. For each child they declare they are 18 or older and the child's parent or guardian, accept the Terms, and separately consent. Each child is a separate account with no email, linked to the holder on our servers. Up to 5 active children per email. The device stays signed in as the last child. "Switch Child" lists siblings by nickname with no gate. A mailed 6-digit code gates adding a child, data copy, withdraw and delete. Closing the last child deletes the holder sign-in. Web only. PSHS-NCE only, one pass per child.

**Teen flow (13 to 17).** The teen enters an age on the device. The server records an under-18 group when the teen sends a guardian request. The guardian confirms by email. A guardian page lets them allow optional usage sharing or withdraw.

**Purposes.** Exam practice, review scheduling, payment for PSHS-NCE, consent evidence, security.

**Basis.** Guardian consent (RA 10173 Sections 12(a), 13(a)); contract (12(b)); legitimate interest for security (12(f)); legal claims for consent evidence (13(f)).

## 2. Data inventory

| Data | Child account | Teen flow |
|---|---|---|
| Guardian email (holder sign-in), and name and photo if Google sign-in | Yes, no study data on the holder | Guardian name and email in the request |
| Holder ID and guardian-to-child link | Yes | No |
| Nickname | Yes, stored on our servers to list siblings | No (own profile) |
| Age information | Child label only, no exact age | Under-18 label, no exact age on server |
| Study records (answers, results, times, bookmarks) | Yes | Yes |
| Consent record | Yes, kept after deletion | Yes, kept after deletion |
| Payment records | Yes | Yes |
| Usage analytics, speed and error reports | Off | Off until guardian allows (analytics); speed and error reports on by default [FLAG] |
| Share cards, push | Off | Share cards on |
| Rate-limit and security records | Yes | Yes |

## 3. Necessity and proportionality

- No exact age, real name, school, photo or birth date is collected for a child.
- Analytics, error reports, share cards and push are off for children. The less data, the less risk.
- The consent record is the smallest set that proves a guardian agreed: account ID, protected code of the guardian email, times, document versions.
- Retention: 12 months of inactivity for child accounts. Consent evidence only while needed to defend a documented claim, ordinarily no longer than ten years after account closure. That is a necessity judgment, not a statutory period, and the item a regulator may question most.
- Alternatives considered: a child-held account with an emailed guardian link (weak, a child can type a second email) and linked accounts (more data, later delivery). Guardian-held was chosen (Decision 1).
- Rights: access, correction, deletion and complaint paths exist through "For parents" and the Data Protection Officer.

## 4. Risks

| # | Risk | Likelihood | Impact |
|---|---|---|---|
| R1 | A child ticks the guardian boxes alone, so consent is not valid | High | Medium |
| R2 | An under-13 enters an adult age and gets a normal account | Medium | Medium |
| R3 | Child study data is breached | Low | High |
| R4 | Child data goes to analytics or error reports by a missed switch | Medium | High |
| R5 | A public Wrapped page exposes a child | Low | High |
| R6 | Consent evidence is kept too long | Medium | Low |
| R7 | Inactive child accounts are not deleted (12-month job not built) | Medium | Medium |
| R8 | A forwarded receipt email lets someone else delete a child's account | Low | Low |
| R9 | Code that checks for `minor` treats `child` as unrestricted | Medium | High |
| R10 | Processors abroad mishandle data | Low | Medium |
| R11 | Child notice not understood by the child | Medium | Low |
| R12 | Missing NPC registration or a successful complaint | Low | High |
| R13 | The age step relies on a child's own permission, which the NPC says a minor cannot give (Advisory Opinion 2017-049) | Medium | High |
| R15 | A sibling opens another child's account on a shared device | High | Low |
| R16 | One guardian email is misused (several families, over the limit) | Medium | Medium |
| R17 | Cleanup deletes a child account that should stay, or leaves the holder email behind | Medium | High |
| R18 | On switch, one child's local answers upload into another child's account | Medium | High |
| R14 | A breach of child data is not notified to the NPC, guardian and child | Low | High |

## 5. Controls

- R1: two separate ticks, guardian sign-in with a verified email, a receipt email with a delete link, and terms that put responsibility on the declarant. The server writes the consent record only at acceptance.
- R2: the device stays on the guardian screen after an under-13 answer. Terms let us delete accounts found without setup. Support procedure to delete them [TO WRITE].
- R3: Google's Singapore region, access limits, breach notice to the NPC, guardian and child.
- R4, R5: server-side refusal of analytics, speed and error reports and hosted Wrapped pages for the child label, not only a hidden control. Test it.
- R6: ceiling and review rule stated in the notice. Review after legal advice.
- R7: build the job before November 2027. The notice states it now.
- R8: the delete link opens a confirm step and the code gate applies.
- R9: every check treats `child` and unknown values as restricted (R7 ruling). Add a test.
- R10: named processors, notice of transfers, backups removed within 180 days.
- R11: short child notice and a fuller child-friendly page at Grade 6 reading level, tested with 9 to 12 year olds.
- R12: before enabling child accounts, complete the CPIA, verify the controls, record residual risks and owners, and meet the NPC registration requirements that apply under the legal criteria (such as risky processing and profiling). Registration is not optional because of sale status.
- R13: not fixed. Aedwon kept the current age-step flow on Nov 11 (option A). The live texts rely on the user's permission and on Section 13(f) for the age-group record. Codex advised asking the guardian before the age step. See residual risk.
- R15: accepted. Same guardian, low-risk data, stated in the Terms and child notice.
- R16: limit of 5, support review above it, code gate on adding, email refused if it holds an adult or teen account with progress.
- R17: clean up per child account. Test that the holder email goes only with the last child and paid accounts are never treated as inactive.
- R18: clear local study data on switch. Test that uploads carry only the signed-in child's ID.
- R14: the Child Notice commits to notify the NPC, the guardian and the child within the legal deadline, in plain words for the child.
- Collection changes: email the guardian first once the app is public.

## 6. Residual risk

- R1 stays **medium**. A child can still impersonate a guardian. This cannot be removed without identity checks that would collect more data. We accept it with the safeguards above.
- R2 stays **medium**. Accepted in R11 of the decision log.
- R4 and R9 drop to **low** only after the tests pass.
- R18 stays **medium** until the switch test passes. R17 drops to **low** after its test.
- R6 stays **low to medium** until a lawyer reviews the period.
- R13 stays **medium to high**. It is the largest open risk. The flow was deliberately kept, so it needs Aedwon's continued acceptance, ideally after lawyer review.
- All other risks are **low** with controls working.

Overall: this assessment is not complete. Child accounts must not be enabled until the CPIA is finished, the controls are verified, owners are named, the NPC registration requirement is resolved, and R4, R5 and R9 tests pass. The 12-month job must exist before November 2027.

## 7. Open items

- Confirm rate-limit record retention against the build.
- Confirm the NPC texts cited (Circular 2023-04, Advisory 2024-03) at privacy.gov.ph.
- Confirm whether speed and error reports are on by default for teens (existing notice says yes). If a teen's guardian has not agreed, consider turning them off.
- Lawyer review.
- Business phone number and electronic receipt or invoice for each purchase (e-commerce disclosure).

## 8. Sign-off

Personal information controller: Aerol Dwayne Daños Balayon

Signature: ______________________  Date: ______________

Data Protection Officer opinion: ______________________

Next review: ______________ (or earlier if collection changes)
