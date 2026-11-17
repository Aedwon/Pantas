# Privacy Impact Assessment: child accounts and the teen guardian flow

Draft, Nov 17, 2026. Agent-written, no lawyer review. Follows NPC Advisory 2024-03, Section 2(A) (see the legal draft's sources). Revised after the Codex critique. The child privacy impact assessment (CPIA) must be completed before child accounts are enabled, free or paid. Paid status does not change that duty.

Controller and Data Protection Officer: Aerol Dwayne Daños Balayon.

## 1. Processing description

**Child accounts (under 13).** A parent or guardian signs in with their own email, declares they are 18 or older and the child's parent or guardian, accepts the Terms, and separately consents to the child's data processing. The child then studies for PSHS-NCE under a nickname. The account is the guardian's. One child per email. Web only. Child accounts buy only PSHS-NCE.

**Teen flow (13 to 17).** The teen enters an age on the device. The server records an under-18 group when the teen sends a guardian request. The guardian confirms by email. A guardian page lets them allow optional usage sharing or withdraw.

**Basis.** Guardian consent (RA 10173 Sections 12(a), 13(a)); contract (12(b)); legitimate interest for security (12(f)); legal claims for consent evidence (13(f)).

## 2. Data inventory

| Data | Child account | Teen flow |
|---|---|---|
| Guardian email, and name and photo if Google sign-in | Yes | Guardian name and email in the request |
| Nickname | Yes, guardian chooses | No (own profile) |
| Age information | Child label only, no exact age | Under-18 label, no exact age on server |
| Study records (answers, results, times, bookmarks) | Yes | Yes |
| Consent record | Yes, kept after deletion | Yes, kept after deletion |
| Payment records | Yes | Yes |
| Usage analytics, speed and error reports | Off | Off until guardian allows (analytics); speed and error reports on by default [FLAG] |
| Share cards, push | Off | Share cards on |
| Rate-limit and security records | Yes | Yes |

## 3. Necessity and proportionality

- No exact age, real name, school, photo or birth date is collected for a child. Analytics, error reports, share cards and push are off.
- The consent record is the smallest set that proves a guardian agreed: account ID, protected code of the guardian email, times, document versions.
- Retention: 12 months of inactivity for child accounts. Consent evidence only while needed to defend a documented claim, ordinarily no longer than ten years after account closure. That is a necessity judgment, not a statutory period, and the item a regulator may question most.
- Alternatives (child-held account, linked accounts) were weaker or slower. Guardian-held was chosen.

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
| R9 | Code that checks for `minor` treats `child` as unrestricted | Medium | High |
| R11 | Child notice not understood by the child | Medium | Low |
| R12 | Missing NPC registration or a successful complaint | Low | High |
| R13 | The age step relies on a child's own permission, which the NPC says a minor cannot give (Advisory Opinion 2017-049) | Medium | High |
| R14 | A breach of child data is not notified to the NPC, guardian and child | Low | High |

## 5. Controls

- R1: two separate ticks, guardian sign-in with a verified email, a receipt email with a delete link, and terms that put responsibility on the declarant. The server writes the consent record only at acceptance.
- R2: the device stays on the guardian screen after an under-13 answer. Terms let us delete accounts found without setup. Support procedure to delete them [TO WRITE].
- R3: Google's Singapore region, access limits, breach notice to the NPC, guardian and child.
- R4, R5: server-side refusal of analytics, speed and error reports and hosted Wrapped pages for the child label, not only a hidden control. Test it.
- R6: ceiling and review rule stated in the notice. Review after legal advice.
- R7: build the job before November 2027. The notice states it now.
- R9: every check treats `child` and unknown values as restricted (R7 ruling). Add a test.
- R11: short child notice and a fuller child-friendly page at Grade 6 reading level, tested with 9 to 12 year olds.
- R12: before enabling child accounts, complete the CPIA, verify the controls, record residual risks and owners, and meet the NPC registration requirements that apply under the legal criteria (such as risky processing and profiling). Registration is not optional because of sale status.
- R13: not fixed. Aedwon kept the current age-step flow on Nov 11 (option A). The live texts rely on the user's permission and on Section 13(f) for the age-group record. Codex advised asking the guardian before the age step. See residual risk.
- R14: the Child Notice commits to notify the NPC, the guardian and the child within the legal deadline, in plain words for the child.
- Collection changes: email the guardian first once the app is public.

## 6. Residual risk

- R1 stays **medium**. A child can still impersonate a guardian. This cannot be removed without identity checks that would collect more data. We accept it with the safeguards above.
- R2 stays **medium**. Accepted in R11 of the decision log.
- R4 and R9 drop to **low** only after the tests pass.
- R13 stays **medium to high**. It is the largest open risk. The flow was deliberately kept, so it needs Aedwon's continued acceptance, ideally after lawyer review.
- All other risks are **low** with controls working.

Overall: this assessment is not complete. Child accounts must not be enabled until the CPIA is finished, the controls are verified, owners are named, the NPC registration requirement is resolved, and R4, R5 and R9 tests pass. The 12-month job must exist before November 2027.

## 7. Open items

- Confirm rate-limit retention against the build.
- Recheck the NPC texts cited.
- Confirm whether speed and error reports are on by default for teens (existing notice says yes). If a teen's guardian has not agreed, consider turning them off.
- Lawyer review.
- Business phone and purchase receipts (e-commerce disclosure).

## 8. Sign-off

Personal information controller: Aerol Dwayne Daños Balayon

Signature: ______________________  Date: ______________

Next review: ______________
