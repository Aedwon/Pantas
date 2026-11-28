## Must-fix

### 1. Tie the guardian’s assent to the order

> “I am this student's parent or guardian, 18 or older, and may use the payment method I will pay with. I accept the Terms and refund policy.”

> “For a purchase on your account, the buyer is your parent or guardian, who ticks that they are your parent or guardian, 18 or older, may use the payment method, and accept the Terms and refund policy.”

The first is a declaration. The second states the buyer’s identity as fact. A confirmed guardian on the account establishes who approved the account. The checkout code I reviewed accepts the Terms version from the student’s session, so the record establishes what that session submitted. Have the guardian approve the specific order through a verified guardian channel and bind that approval to the order. “This student” is clear if the checkout identifies the student’s account. “Buying for this student” also makes the adult’s role clear. [Civil Code arts. 1317, 1327, 1390 and 1403](https://lawphil.net/statutes/repacts/ra1949/ra_386_1949.html) · [Family Code art. 220](https://lawphil.net/executive/execord/eo1987/eo_209_1987.html) · [Checkout code](https://github.com/Aedwon/Pantas/blob/cc0029392b593099d4689b5a516bdd241771dacd/functions/src/paymongoCheckout.ts#L39-L64)

**Guardian checkbox**  
“I’m 18+ and buying for this student as their parent or legal guardian. I’m authorized to use the payment method and accept the Terms and refund policy.”

**Teen Notice**  
“For web purchases, we record the buyer’s declaration that they’re your parent or legal guardian and agree to the purchase.”

### 2. Show the sole proprietor’s name and publish the actual seller details

> “Sold by [registered business name], [full place of business]. Phone [business phone]. Email support@pantas.study.”

> “[registered business name] · [full place of business] · [business phone] · support@pantas.study”

> “Beside the Pay button, checkout shows who sells the plan: our business name, place of business, phone and email.”

RA 11967 §23(f) expressly requires the e-retailer details **on the homepage**. A readable footer on the homepage can serve that purpose. The DTI’s electronic-commerce consumer rules also call for a sole proprietor’s name and applicable registration details to be easily accessible. Put the proprietor’s name on both lines. Use the actual geographic business address, a working mobile or landline, and the monitored email. Put applicable DTI and permit details in a nearby **Business details** link. The ITA separately requires submission of seller details and proof of identity to the Bureau. It does not require an ID scan beside Pay. [RA 11967 §23(f)](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96902) · [ITA implementing rules §34(g)](https://ecommerce.dti.gov.ph/wp-content/uploads/2024/06/Joint-Administrative-Order-No.-24-03-1.pdf) · [Joint DTI-DOH-DA Order 01-2008 §5](https://www.wipo.int/wipolex/en/legislation/details/14004)

**Checkout and homepage line**  
“Sold by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services · [full business address] · [phone] · support@pantas.study”

Keep the plan, access period, total in pesos, and Terms and refund link visible before payment. Make `support@pantas.study` an actual complaint channel. “Payment help” is enough for the link label. The ITA requires internal redress and an invoice or receipt for every sale. Those are operational duties. DTI Trustmark application is voluntary under DAO 25-07. The BIR separately suspended mandatory display of its Registration Seal Badge until further notice. [RA 11967 §§23–24](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96902) · [DTI checkout rules §§5–6](https://www.wipo.int/wipolex/en/legislation/details/14004) · [DTI Trustmark order](https://trustmark.dti.gov.ph/img/DAO%2025%E2%80%9307_Trustmark%20%28Issued%20on%2027%20June%202025%29_1.pdf) · [BIR suspension announcement](https://bir-cdn.bir.gov.ph/BIR/pdf/PR124OCT2626.pdf)

### 3. Give checkout evidence a lawful basis and a deletion rule

> “Checkout declarations: we record the declaration to complete the purchase and to establish, exercise or defend a claim about the buyer's age, authority or acceptance of the Terms (Sections 12(b) and 12(f)).”

A minimal record for every buyer is proportionate in principle. Keep the order reference, server time, declaration shown, and Terms version. Preserve the exact wording and Terms for that version. For guardian orders, link the record to the verified approval. Set a shorter period for abandoned attempts and preserve only the evidence needed for a documented dispute. Section 12(b) covers ordinary data necessary for the buyer’s contract. Section 12(f) can cover ordinary dispute evidence after a documented balancing assessment. Section 18 concerns portability. Section 16 governs notice and access.

Treat an identifiable “18 or older” assertion or minor-linked marker as sensitive age information. Sections 12(b) and 12(f) alone are insufficient for that part. Document a Section 13 basis. Section 13(f) can apply before a case is filed if Pantas identifies the claim and shows why the specific record is necessary. A general possibility of disputes is a weak basis for years of storage. If relying on Section 13(a), obtain specific, informed consent for the age processing from the proper person. The proposed Terms tick alone does not provide it. [Data Privacy Act §§3(l), 11–13, 16 and 18](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/50253) · [NPC Advisory 2024-02](https://privacy.gov.ph/wp-content/uploads/2024/08/NPC-Advisory-No.-2024-02-Personal-Data-Processing-Based-on-Section-13-f.pdf) · [NPC Advisory Opinion 2026-010](https://privacy.gov.ph/wp-content/uploads/2026/10/NPC-Advisory-Opinion-No.-2026-010.pdf) · [NPC Circular 2023-04](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf)

**Notice wording, once the basis is settled**  
“We save what the buyer agreed to, when they agreed, and the Terms version to complete the order and handle disputes.” State the applicable sensitive-data basis in the linked notice.

> “We delete them when you delete the account.”

> “For an under-18 account, we first copy the purchase declaration into the guardian evidence above.”

> “We chose this period because a contract made by someone under 18 can be challenged until four years after that person turns 18.”

Keeping limited guardian evidence after deletion can be defensible. Disclose it in **both** notices. Select it by the declaration made **at purchase**, so a student turning 18 does not change how a past order is treated. The existing copier selects records by timestamp alone. If adult checkout starts writing that field, the copier will also retain adult declarations unless it changes. The copy also includes the product, which the draft’s field list omits. Article 1391 measures four years from the end of guardianship for annulment based on incapacity. That provision does not prescribe ten years of storage for every guardian response, declined request, or adult purchase for a teen. The cleanup code has no legal-hold check. [Civil Code arts. 1390–1391](https://lawphil.net/statutes/repacts/ra1949/ra_386_1949.html) · [Data Privacy Act §§11 and 16](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/50253) · [Evidence copy](https://github.com/Aedwon/Pantas/blob/cc0029392b593099d4689b5a516bdd241771dacd/functions/src/deleteUserData.ts#L116-L144) · [Evidence cleanup](https://github.com/Aedwon/Pantas/blob/cc0029392b593099d4689b5a516bdd241771dacd/functions/src/purgeInactiveAccounts.ts#L263-L293)

**Both notices, once deletion matches**  
“Deleting the account removes its checkout records. We keep a limited copy of guardian purchase approvals for the period stated in the Teen Notice.” Give that period and its starting event in the Teen Notice. Keep any longer claim-specific exception only if the process can honor it.

### 4. Set a real expiry for question reports

> “Question reports: [Period to publish, for example "until we have reviewed the report, then at most two years"].”

> “Question reports: our legitimate interest in finding and fixing mistakes in questions and in handling abuse of the report function (Section 12(f)). We use only what the report holds, and we do not use it to profile you.”

A bracket is fine in the draft. The published notice needs a real period or an intelligible deletion rule that Pantas follows. The report branch has account-deletion cleanup and no scheduled expiry. I would defend **up to 90 days from receipt**, with earlier deletion when the issue closes or the account is deleted. That is a proposed operational limit. Keep a de-identified fix record if useful. Retain identifiable text longer only for a specific legal duty or documented claim.

Section 12(f) is defensible for ordinary optional reports after Pantas documents purpose, necessity, and balancing, including effects on minors. The account ID supports account deletion and abuse limits. The code also keeps derived report counts, so “only what the report holds” is too narrow. Free text can contain health, education, or other sensitive information. The warning helps minimize collection. It supplies no Section 13 basis for keeping sensitive text. Restrict access and promptly remove unnecessary sensitive text. Circular 2023-04 governs consent if relied on. Circular 2023-07 governs legitimate interest. [Data Privacy Act §§11–13 and 16](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/50253) · [NPC Circular 2023-04](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf) · [NPC Circular 2023-07](https://privacy.gov.ph/wp-content/uploads/2024/01/NPC-Circular-No.-2023-07_Guidelines-on-Legitimate-Interest_13-December-2023.pdf) · [Report storage](https://github.com/Aedwon/Pantas/blob/daef9e944277573f393e50ac76a48adf01cf464b/functions/src/questionReports.ts#L117-L143)

**Notice wording, once the expiry works**  
“We use reports to fix questions and report counts to prevent misuse.”  
“We delete reports when we finish reviewing them, within 90 days of receipt, or sooner if the account is deleted.”

> “Please do not put personal details in the message.”

Keep the warning and move it to the report form. The NPC’s child-transparency advisory calls for a short notice at the point of collection, backed by a child-readable notice. The linked notice should cover who can access reports, how long they stay, and how to request access or object. [NPC Advisory 2024-03 §4](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf)

**Beside Send**  
“We use your report to fix questions. Leave out names and private details. See how we use reports.”

### 5. Verify the requester’s authority before exporting teen data

> “Answer from the address on the account, or ask for what is needed to check identity. For an under-18 account, the guardian may ask for the student.”

> “Send the file to the verified address, and note the date. Reply as the law requires.”

> “Question reports are stored text the student wrote, so they belong in every export.”

The account ID query is sound. The procedure should verify identity, delivery address, and any guardian’s current authority. Accept requests from teens through an age-appropriate process. Include reports Pantas still holds when they are within the request’s scope. Redact protected third-party information case by case. Search relevant retained evidence and processor-held data Pantas controls, including after account closure. An access response may also need sources, uses, recipients and other information under §16(c). NPC guidance gives 30 working days after receipt of the request or required documents, with up to 15 more working days for complex or numerous requests and notice of the reason.

Manual export is workable. Reports processed solely under legitimate interest remain subject to access rights. NPC portability guidance applies to consent- or contract-based processing that meets its other conditions. CSV or JSON is still practical for a report copy. [Data Privacy Act §§16, 18 and 20](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/50253) · [NPC Advisory 2021-01 §§5, 8 and 11](https://privacy.gov.ph/wp-content/uploads/2026/05/SGD-Advisory-DS-Rights-29-Jan-2021.pdf)

**README procedure**  
“Verify identity and any representative’s authority. Export the requested records we still hold, including reports and report counts where in scope. Redact protected data, send securely, and log the response.”

## Should-fix

### Shorten the adult declaration and preserve the right to check authority

> “I am 18 or older and may use the payment method I will pay with. I accept the Terms and refund policy.”

**Adult checkbox**  
“I’m 18+, authorized to use the payment method, and accept the Terms and refund policy.”

“May use” does the legal work. “Authorized” is clearer. Neither checkbox needs “in my own name” as a condition on the payment method. A buyer can contract personally and use a payment method they are authorized to use under the applicable issuer or provider rules.

A required, initially unchecked box with the linked Terms available before payment can establish electronic assent under RA 8792 §16. Let the buyer open and retain the Terms without ticking the box. Link “refund policy” directly to the refund section if practical. Tie the event to the order and preserve an authenticatable record. RA 11967 adds consumer duties. Assent leaves statutory remedies in force. [RA 8792 §§7–8, 11–12 and 16](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/3888) · [RA 11967 §20](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96902) · [DTI checkout rules §§5–6](https://www.wipo.int/wipolex/en/legislation/details/14004)

Both cases are verified. In *Mercado v. Espiritu*, the signed deed expressly represented that the signers were of age. *Braganza v. Villa Abrille* distinguished that case from silence about age and cautioned against extending it. An affirmative age tick helps Pantas prove a representation if it can attribute the tick to the buyer. Its weight depends on the facts. A minor’s contract is generally voidable on incapacity grounds, and an unauthorized representative presents a separate enforceability issue. [*Mercado*, G.R. L-11872 (1917)](https://lawphil.net/judjuris/juri1917/dec1917/gr_l-11872_1917.html) · [*Braganza*, G.R. L-12471 (1959)](https://lawphil.net/judjuris/juri1959/apr1959/gr_l-12471_1959.html) · [Civil Code arts. 1390 and 1403](https://lawphil.net/statutes/repacts/ra1949/ra_386_1949.html)

> “We may ask for proof if authority is disputed.”

> “If we find that a purchase lacked authorization, we may cancel the access and return the payment to the verified payer, subject to applicable law and any payment reversal already made.”

The first sentence narrows Pantas’s discretion to a dispute that has already arisen. The second can be read as giving Pantas discretion over a legally required refund. Keep discretion over access and honor required refunds through the original channel where practical. [Civil Code arts. 1398–1399](https://lawphil.net/statutes/repacts/ra1949/ra_386_1949.html) · [RA 11967 §§20 and 23](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96902)

**Terms wording**  
“We may ask for proof of authority before or after payment. We may cancel unauthorized access. We refund as required by law and account for any payment reversal.”

## Nit

> “If your phone cannot connect, it keeps the report on the device until it can send it.”

> “Question reports: if you report a problem with a question, we keep the message you wrote (up to 1,000 characters), the question and its version, the exam, the app build, the time and your account ID.”

Use “device” for web and mobile. Sending can end in a permanent refusal, and a local wipe can clear the queue. The server’s timestamp is the time of receipt. Older queued reports can lack an exam or question version. [Report queue](https://github.com/Aedwon/Pantas/blob/daef9e944277573f393e50ac76a48adf01cf464b/lib/core/storage/data/report_queue.dart) · [Report validation and storage](https://github.com/Aedwon/Pantas/blob/daef9e944277573f393e50ac76a48adf01cf464b/functions/src/questionReports.ts#L34-L78)

**Notice wording**  
“Your device may save an unsent report and try again later.”  
“When we receive it, we save your message, question, build, receipt time and account ID, plus the exam and question version when available.”

## Code accuracy

I reviewed the Nov 23 working drafts, checkout candidate `cc0029392`, and the updated report branch `daef9e944`. The checkout design in the prompt is the intended launch state. The findings below reflect source review. Live PayMongo, website deployment and mailbox operation were outside that verification.

- **The checkout box, wording and link are ahead of the candidate.** This covers the README’s “A required tick beside the Pay button.” and “"Terms and refund policy" links to the Terms (section 5 is the refund policy).” It also covers the Terms’ “Every web purchase needs a tick in a box beside the Pay button.”, “Checkout does not start without it.”, both “sees” sentences, and “"Terms and refund policy" links to these Terms.” The Teen Notice repeats the same claims in “Every web purchase has a tick box beside the Pay button.”, “When a guardian has confirmed your account, it reads:” and the sentence about the link. The reviewed UI has the older guardian-only label and a `Terms` link. The UI uses the device’s age group. The server checks its stored minor flag and the supplied Terms version. [Pro screen](https://github.com/Aedwon/Pantas/blob/cc0029392b593099d4689b5a516bdd241771dacd/lib/features/settings/presentation/pages/pro_page.dart#L399-L433) · [Checkout server](https://github.com/Aedwon/Pantas/blob/cc0029392b593099d4689b5a516bdd241771dacd/functions/src/paymongoCheckout.ts#L39-L64)
- **Universal recording and payer identity are unsupported.** This covers “For every web purchase, we record the declaration with the date, time and Terms version when checkout starts.”, its “we also record” equivalents in both Payments bullets, “For every web purchase, we record the tick with the date, time and Terms version when checkout starts.”, both Checkout declarations basis bullets insofar as they assert the new recording, and “For a purchase on your account, the buyer is your parent or guardian, who ticks…”. The older server records a timestamp and Terms version for minor-flag orders. The README export inventory’s “the checkout declaration” is therefore conditional on what was actually collected. [Order write](https://github.com/Aedwon/Pantas/blob/cc0029392b593099d4689b5a516bdd241771dacd/functions/src/paymongoCheckout.ts#L44-L95)
- **The seller display is still a launch requirement.** “Beside the Pay button, checkout shows who sells the plan: our business name, place of business, phone and email.” is unsupported by the reviewed Pro screen. The homepage source I checked also lacks the proposed footer line. The two README templates are draft instructions.
- **The deletion wording overstates what disappears and understates what survives.** “We delete them when you delete the account.” needs the guardian-copy qualification in the general policy too. “For an under-18 account, we first copy the purchase declaration into the guardian evidence above.” describes the intended selection. The actual selection is any timestamped attestation. “When an account is deleted, we copy the purchase declaration (date, time, Terms version and payment reference) into this evidence.” also omits the product field. The about-ten-year cleanup itself is implemented. [Evidence copy](https://github.com/Aedwon/Pantas/blob/cc0029392b593099d4689b5a516bdd241771dacd/functions/src/deleteUserData.ts#L116-L144) · [Evidence cleanup](https://github.com/Aedwon/Pantas/blob/cc0029392b593099d4689b5a516bdd241771dacd/functions/src/purgeInactiveAccounts.ts#L263-L293)
- **Report storage and account-deletion claims are supported on the report branch.** The two sentences quoted under **Nit** need the qualifications given there. “We use only what the report holds” omits the quota records. The example report expiry is a placeholder with no implementation. The export stub is real. “Exports go through dpo@pantas.study.” describes a manual channel whose operation source code cannot establish. [Report storage](https://github.com/Aedwon/Pantas/blob/daef9e944277573f393e50ac76a48adf01cf464b/functions/src/questionReports.ts#L117-L143) · [Report deletion](https://github.com/Aedwon/Pantas/blob/daef9e944277573f393e50ac76a48adf01cf464b/functions/src/deleteUserData.ts#L94-L97) · [Export stub](https://github.com/Aedwon/Pantas/blob/daef9e944277573f393e50ac76a48adf01cf464b/functions/src/exportData.ts#L7-L20)
- **Both Payments bullets misdescribe QR Ph.** “For web purchases, card and wallet details are entered on PayMongo's checkout page.” QR Ph is approved in the buyer’s banking or wallet app. Use “PayMongo handles card payments. For QR Ph, you approve payment in your bank or wallet app.” [PayMongo QR Ph](https://docs.paymongo.com/docs/payment-acceptance-qr-ph)

## Checked and fine

- Requiring an authorized adult to make a teen’s web purchase, and treating account confirmation as a separate act from purchase.
- Linking “Terms and refund policy” to a single document that contains both, provided the buyer can review it before paying.
- Showing the total Pantas charges in pesos, including applicable taxes and seller charges. The draft can use that sentence alone once the total is verified.
- Deleting server reports on completed user-requested, inactive-account, and guardian-withdrawal deletion on the report branch. The rules deny direct client access. [Report deletion](https://github.com/Aedwon/Pantas/blob/daef9e944277573f393e50ac76a48adf01cf464b/functions/src/deleteUserData.ts#L23-L28) · [Firestore rules](https://github.com/Aedwon/Pantas/blob/daef9e944277573f393e50ac76a48adf01cf464b/firestore.rules#L402-L405)

**Biggest legal risk:** treating a tick from the student’s session as proof that the guardian bought the plan. If a payment is disputed, Pantas can show what the session submitted. The evidence Pantas needs is the guardian’s own approval tied to that specific order.