## Must-fix

**1. The open under-18 flag has no clear Section 13 basis.**

> “We use the open request only to ask your guardian and record the answer.”

- **Section 13(b).** The strongest argument is that a short-lived flag lets Pantas ask for guardian permission. But Section 13(b) requires a law or regulation that provides for the processing, guarantees protection, and permits it without consent. Advisory Opinion 2017-049 concerns a teacher searching a student’s phone. It says the minor cannot give valid consent in that case. It neither imposes a general guardian-permission rule nor authorizes Pantas to record age before permission. The NPC’s later age-assurance guidance expressly requires a lawful basis. [Data Privacy Act §13](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html) · [NPC Opinion 2017-049, p. 2](https://privacy.gov.ph/wp-content/uploads/2022/01/NPC_AdvisoryOpinionNo._2017-049.pdf#page=2) · [NPC Advisory 2024-03, p. 3](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf#page=3)
- **Section 13(f).** A separate, limited answer record can support a legal claim about whether and when Pantas had permission, where keeping that record is necessary. The open flag serves an operational purpose. The possibility of a later dispute does not establish that the flag is necessary for a claim. [NPC Advisory 2024-02, §§2–4](https://privacy.gov.ph/wp-content/uploads/2024/08/NPC-Advisory-No.-2024-02-Personal-Data-Processing-Based-on-Section-13-f.pdf)
- **Other grounds.** Section 13(a) requires specific consent before processing. A guardian’s later confirmation can cover approved uses from that point forward. An account-linked age bracket is still information about age. The seven-day limit reduces exposure but supplies no basis. Section 12(f) can cover ordinary contact details if its conditions are met. Sections 13(c)–(e) cover life and health, qualifying public organizations, and medical treatment. [Data Privacy Act §§3, 12–13](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html) · [NPC Guidelines on Consent, §12](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf)

**Replace the basis bullet with**

> **Under-18 group record and guardian evidence.** While your request is open, we use your age group only to ask your guardian and record their answer. We use ordinary contact details to send and protect the request (Section 12(f)). If your guardian gives permission, we use your age group for the purposes they approve from then on (Section 13(a)). We keep a separate, limited record of their answer, including a decline, as needed for legal claims about permission (Section 13(f)).

**Replace the server-record paragraph under “Why we ask your age” with**

> When you send a guardian request, our servers record your age group before your guardian answers. Your exact age stays on your device. We use the open request only to ask your guardian and record their answer. We delete the whole request if it expires after seven days or when we record a decline. We keep the guardian’s answer separately.

**2. The preservation paragraph in both notices overpromises.**

> “If a court or authority gives us a binding order to keep named records, we copy those records by hand and keep the copy for as long as the order requires. We never pause cleanup.”

Section 13 and Rule 3.1 require preservation of data integrity. Neither imposes a general same-database rule. A complete, verifiable export may suffice if the order permits it and the export preserves the required data and metadata. If the order requires the live record, or the copy omits required data, letting cleanup delete the live record can violate the order. Pantas’s runbook records that it has no hold switch. A wording change leaves that operational gap. [RA 10175 §§13, 20](https://lawphil.net/statutes/repacts/ra2012/ra_10175_2012.html) · [Rule on Cybercrime Warrants §§2.7, 3.1](https://oca.judiciary.gov.ph/wp-content/uploads/A.M.-No.-17-11-03-SC.pdf) · [Pantas runbook](https://github.com/Aedwon/Pantas/blob/412e49c2a996cfc11624aaedf47866c60384e73e/docs/OPERATIONS.md#L181-L199)

> “The schedules above apply to guardian evidence and question reports, with one exception.”

There can be a duty without an order. For covered service providers, Section 13 sets a six-month minimum from the transaction for traffic data and subscriber information. Content data gets six months from receipt of an authorized law-enforcement order. A one-time extension or use as evidence can extend preservation. The Supreme Court has read “service provider” broadly, so Pantas’s study-app purpose alone does not settle coverage. [RA 10175 §§3(n), 13](https://lawphil.net/statutes/repacts/ra2012/ra_10175_2012.html) · [BDO v. People, G.R. No. 273720](https://lawphil.net/judjuris/juri2025/jul2025/gr_273720_2025.html)

**Replace the final paragraph in both notices with**

> We may keep specific records beyond these periods when the law requires it, including under a binding order. We may also keep specific records longer when we need them for a legal claim.

## Should-fix

> “If a court or authority gives us a binding order…”

If you name the issuer, use **“a court or another authority with legal power to issue the order.”** Authorized law enforcement can order preservation under Section 13. Disclosure under Section 14 requires a court warrant. Rule 21 lets courts and legally authorized officers or bodies compel production by subpoena. A subpoena to produce documents does not itself impose a general retention schedule. [RA 10175 §§10, 13–14](https://lawphil.net/statutes/repacts/ra2012/ra_10175_2012.html) · [Rule 21 §§1–4](https://lawphil.net/courts/rules/rc_1-71_civil.html#r21)

> “Choosing Continue means you agree to this check.”

That reads as consent. Replace the paragraph with **“Tap Continue to run the age check. You can go back before the check.”** [NPC Opinion 2017-049, p. 2](https://privacy.gov.ph/wp-content/uploads/2022/01/NPC_AdvisoryOpinionNo._2017-049.pdf#page=2) · [NPC Guidelines on Consent](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf)

## Nit

> “We use Section 12(f) for the ordinary contact information needed to send and protect the request.”

The bullet already says this and repeats the post-confirmation consent point. The replacement gives each basis once. [Data Privacy Act §§12–13](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html)

**Question 1 verdict.** Claim no Section 13 basis for the open flag. Describe its purpose and deletion plainly. That wording leaves the legal basis unresolved.

**Question 2 verdict.** Inaccurate as a blanket rule. The preservation duty and any binding order control what must survive cleanup.

**Biggest risk.** The server records sensitive age information on every teen request before guardian permission, with no clear Section 13 basis. That creates potential unauthorized-processing exposure under Section 25 even if Pantas deletes the request on time. [Data Privacy Act §25](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html)