# Codex critique, Nov 24 remaining brackets (GPT 6.2 Sol, high effort)

Read-only, from the worktree on branch `legal/public-launch-r1`. Process rule 5. Covers only the four brackets filled under the rulings "Nov 24, remaining legal brackets" (B1 to B4). The diff it read held the first wording. Every wording finding below is applied in the texts.

## Prompt

<<<PROMPT
You are a read-only legal critic. Do not edit, create or delete any file. Answer in text only. No em dashes. American spelling.

Context. Pantas is a Philippine exam-review study app run by a sole proprietor (not VAT-registered, 8% income tax option), with PayMongo web payments, users aged 13 and older, and a guardian-confirmation flow for ages 13 to 17. No lawyer. The texts should lean as far in favor of Pantas as Philippine law allows, without being unenforceable, misleading or unlawful. Wording must stay plain and short.

Scope. Read `git diff HEAD -- docs/legal-drafts/2026-11-22-public-launch/terms.md docs/legal-drafts/2026-11-22-public-launch/privacy-policy.md docs/legal-drafts/2026-11-22-public-launch/teen-notice.md` in this worktree. Critique only those changed passages (four brackets were replaced with values). Do not re-review the rest. The product rulings below are final and you must not propose changing a value; if wording cannot be right under a ruling, say so as a separate item "conflicts with a ruling".

Rulings behind the four changes.
1. Google Analytics: the Google Analytics 4 property will be set to 2 months for both user-level data and event data, with "Reset user data on new activity" off, before the texts publish. Google's help page (support.google.com/analytics/answer/7667196) says expired data "is deleted automatically on a monthly basis" and that the setting "does not affect standard aggregated reports".
2. Refund reply aim: three business days. The sentence about the seven calendar days under the Internet Transactions Act stays as it is.
3. Messages are emails sent to support@pantas.study or dpo@pantas.study and our replies. Ordinary messages are deleted within 90 days after the matter closes. Messages about a payment, a refund, a purchase complaint or a privacy request are deleted within two years after the matter closes. A matter closes on the day of the last message in it. The owner deletes by hand in a monthly sweep (thresholds 45 days and 23 months, so the published limits hold). When a refund is paid, a minimum record (date, payer name, payment reference, amount, route, transfer reference, last four digits of the receiving account) goes into the refund records kept five years with the tax books. A later sentence in both notices already says: "We may keep other specific records longer when the law requires it or when we need them for a legal claim."
4. Invoice: sales invoices are issued by hand for each web purchase from the first live payment, and the sentence publishes only once that process exists. The sentence makes no promise about the delivery channel or timing.

Questions.
1. Google Analytics sentences (Privacy Policy and Notice for teens): accurate and not misleading given ruling 1 and Google's page? Is silence about aggregated reports a problem under the Data Privacy Act, Sections 11 and 16?
2. "We aim to reply within three business days." Any conflict with RA 11967 Sections 23(i) and 24 or JAO 24-03, or any way it reads as a binding promise?
3. Message periods: are the two classes clear to a reader, is "A matter closes on the day of the last message in it" workable and fair, and are 90 days and two years defensible under the Data Privacy Act Section 11(e) and (f)? Give the prescriptive periods that bear on the two-year class with the actual text or a close paraphrase and a URL: Consumer Act (RA 7394) Article 169, the National Privacy Commission complaint filing period, and any Internet Transactions Act period. Say if you cannot verify one. Is the sentence "The record of a refund we paid follows the five-year period above" accurate in both notices (check that a five-year bullet sits above it in each)? Does the guardian of a teen read correctly into the teen notice version?
4. Invoice sentence in the Terms, "Pantas issues a sales invoice for each web purchase.": accurate for a non-VAT sole proprietor who issues by hand? Is "sales invoice" the right term after the Ease of Paying Taxes Act? Does any rule let a seller skip invoices under a peso amount, and does RA 11967 override that for online sales? Does the sentence add risk beyond the legal duty?
5. Any sentence in the changed passages that states a fact beyond the rulings.

Output format. Findings ranked must-fix, should-fix, nit. For each: the exact sentence quoted, the problem, the source with URL, and replacement wording. Then a short list of clauses found fine. Finish with the single biggest legal risk in these passages. Keep it under 900 words.
PROMPT

## Output

## Must-fix

**Analytics, both notices.** “Google Analytics event records are kept for the period set in our Google Analytics account, which is two months. Google deletes data older than that in a monthly cleanup.”

The two-month setting and monthly cleanup are accurate. The first sentence omits user-level data. The second can imply that Google deletes all older Analytics data. Google applies a changed setting after 24 hours and removes affected older records in its next monthly cleanup. Standard aggregated reports are outside the setting. Sections 11 and 16 require transparency about personal data and how long it is stored. Silence about genuinely non-identifying summaries alone is fine, but the broad deletion wording can mislead. [Google Analytics Help](https://support.google.com/analytics/answer/7667196) · [Data Privacy Act §§11, 16](https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html)

**Replace with** “Google Analytics data about individual users and events expires after two months. Google deletes expired data in a monthly cleanup. Standard reports that combine data can stay available longer.”

## Should-fix

**Email scope, both notices.** “We delete ordinary messages within 90 days after the matter closes. We delete messages about a payment, a refund, a purchase complaint or a privacy request within two years after the matter closes.”

The four subjects are clear. “Ordinary” leaves the scope unclear, including whether replies count. The teen notice elsewhere mentions messages from guardians, so the current wording can cover them. Naming guardians here makes that clear where readers see the deadlines. Both limits are defensible if Pantas keeps identifiable messages only as long as needed for the stated purposes. A filing period alone does not justify keeping every attachment or an entire mailbox. [Data Privacy Act §§11(e)–(f), 16](https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html) · [NPC child-oriented transparency guidance](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf)

**Replace with** “These limits cover emails to support@pantas.study or dpo@pantas.study and our replies. We delete emails about a payment, refund, purchase complaint or privacy request within two years after the matter closes. We delete other emails within 90 days after the matter closes.” In the teen notice, add “That includes emails from you or your guardian.”

**Closure, both notices.** “A matter closes on the day of the last message in it.”

The last email gives a workable date for mailbox cleanup, including when either side stops replying. Calling the matter closed can imply that silence resolves an unanswered request or ends the right to escalate. The existing exception covers specific records needed for legal duties or claims. [Data Privacy Act §§11, 16](https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html) · [Internet Transactions Act §24](https://lawphil.net/statutes/repacts/ra2023/ra_11967_2023.html)

**Replace with** “We count these periods from the date of the last email about the matter.”

The filing periods relevant to that schedule are:

- **Consumer Act Article 169.** Claims under the Act or its rules prescribe two years after the transaction was completed or the deceptive, unfair, or unconscionable practice occurred. For hidden defects, the period starts at discovery. [RA 7394, Article 169](https://lawphil.net/statutes/repacts/ra1992/ra_7394_1992.html)
- **NPC complaints.** I could not verify a general filing deadline for administrative privacy complaints. Rule II §2 generally requires written notice first. The NPC can proceed if timely or appropriate action was lacking or if there was no response within 15 calendar days of receipt. Rule I §6 applies Act 3326’s penalty-based periods to criminal violations. [NPC Rules of Procedure, as amended](https://privacy.gov.ph/wp-content/uploads/2024/03/2021-Rules-of-Procedure-of-the-NPC-As-Amended.pdf) · [Act 3326](https://lawphil.net/statutes/acts/act1926/act_3326_1926.html)
- **Internet Transactions Act §28.** A consumer may file for damages in court or with DTI within two years after the cause of action arose. JAO 24-03 §44 also states a two-year period for seeking DTI administrative penalties. [RA 11967 §28](https://lawphil.net/statutes/repacts/ra2023/ra_11967_2023.html) · [JAO 24-03 §44](https://ecommerce.dti.gov.ph/wp-content/uploads/2024/06/Joint-Administrative-Order-No.-24-03.pdf)

## Nit

**Refund record.** “The record of a refund we paid follows the five-year period above.”

Accurate in both notices. Each has the five-year bullet above it. Naming the separate record helps readers distinguish it from the emails. **Replace with** “We keep a short record of each refund we pay under the five-year tax records schedule above.” [Tax Code §235, as amended](https://lawphil.net/statutes/repacts/ra2024/ra_11976_2024.html)

## Clauses found fine

- “We aim to reply within three business days.” This reads as a good-faith target, with little risk of a guaranteed deadline. RA 11967 §23(i) requires accessible, efficient redress. Section 24 and JAO §38 deem it exhausted after seven calendar days if unresolved, even if Pantas replied. [RA 11967](https://lawphil.net/statutes/repacts/ra2023/ra_11967_2023.html) · [JAO 24-03](https://ecommerce.dti.gov.ph/wp-content/uploads/2024/06/Joint-Administrative-Order-No.-24-03.pdf)
- “Pantas issues a sales invoice for each web purchase.” “Sales invoice” is correct. The general non-VAT tax rule uses ₱500, with exceptions for buyer requests and daily aggregates of at least ₱500. The ITA and its rules independently cover every online sale. A BIR-authorized handwritten invoice works if Pantas qualifies for the Micro taxpayer exemption from mandatory electronic invoicing. The sentence creates a contractual commitment that tracks the online duty and specifies neither delivery channel nor timing. [Tax Code §237](https://lawphil.net/statutes/repacts/ra2024/ra_11976_2024.html) · [RA 11967 §23(h)](https://lawphil.net/statutes/repacts/ra2023/ra_11967_2023.html) · [BIR RMC 98-2026](https://bir-cdn.bir.gov.ph/BIR/pdf/RMC%20No.%2098-2026%20Digest.pdf)

**Biggest legal risk:** Deleting evidence still needed for an unresolved payment or privacy claim because the last email aged out. The mailbox sweep needs to honor the existing exception for specific records. [Data Privacy Act §11(e)](https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html)
