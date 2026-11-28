I reviewed the changed passages in the three drafts against the launch rulings you supplied. The worktree still contains older cleanup and checkout code, so the replacements below describe the ruled launch behavior. I did not verify production deployment.

## Must-fix

**1. Teen Notice, lawful basis for the under-18 record.**

> “While the request is open, we rely on Section 13(f) where sensitive information is necessary to establish or defend a claim about capacity or authorization, such as whether your parent or legal guardian allowed your account.”
>
> “After your guardian confirms, we rely on their permission (Section 13(a)).”
>
> “A guardian's answer, including a decline, stays as guardian evidence for the periods above, and we rely on Section 13(f) for it.”

An account-linked age bracket is information about age, even when the server never receives the exact number. While the request is open, Section 12(f) can support necessary ordinary contact processing if Pantas meets the legitimate-interest test. The draft gives an operational reason for the sensitive flag: routing the request. Section 13(f) does not establish a basis for that use by itself. The NPC allows preparation before a case exists, but expects Pantas to identify the legal claim and show why each processing activity is necessary. [Data Privacy Act §§ 3(l), 11–13](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html), [NPC Advisory 2024-02 §§ 4–7](https://privacy.gov.ph/wp-content/uploads/2024/08/NPC-Advisory-No.-2024-02-Personal-Data-Processing-Based-on-Section-13-f.pdf), [NPC Advisory Opinion 2026-010, p. 4](https://privacy.gov.ph/wp-content/uploads/2026/10/NPC-Advisory-Opinion-No.-2026-010.pdf)

After confirmation, Section 13(a) can cover the specific uses the guardian approved in advance, including checkout use if the permission covers it. It cannot authorize the earlier write. After decline or expiry, the request serves no further routing purpose. The cleanup window does not supply a lawful basis for keeping the sensitive flag during that window. A separate answer record, including a decline, is more defensible under Section 13(f) as evidence of what was allowed and when. Its scope and each retention period still need a showing of necessity. An unanswered request produces no guardian answer. [Data Privacy Act IRR §§ 18–19](https://privacy.gov.ph/implementing-rules-regulations-data-privacy-act-2012/), [NPC child-oriented transparency guidance §§ 2–3](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf)

**Replacement for the basis language:** “We use ordinary contact details to send and protect the request (Section 12(f)). After your guardian gives permission, we use your under-18 group record for the purposes they approved (Section 13(a)). We keep a limited record of the answer, including a decline, when needed for a legal claim about whether and when we had permission (Section 13(f)).” The notice still needs a substantiated basis for recording and using the flag before confirmation. Wording alone cannot supply it.

**2. Teen Notice, legal justification for the two evidence periods.**

> “We chose the ten years because a contract made by someone under 18 can be challenged for four years after guardianship ends, and we know only that you are under 18, not your exact age, so we count the longest case.”
>
> “A claim on a written contract can also be brought for ten years.”
>
> “A decline creates no contract.”
>
> “Its record only answers a claim that we kept using data after a guardian said no, and such a claim has a four-year period.”

Article 1391 is the right provision for **annulment based on minority** under Article 1390(1). Ordinary majority begins at 18. For someone who contracts at 13, that makes roughly nine years from contracting to the ordinary annulment deadline at 22. This can inform a conservative schedule for relevant evidence. It does not explain ten years for every confirmation, withdrawal, or purchase declaration. A guardian’s own purchase also does not become a minor’s contract simply because it benefits a minor. [Civil Code Arts. 1327, 1390–1394](https://www.lawphil.net/statutes/repacts/ra1949/ra_386_1949.html), [RA 6809 §§ 1, 3](https://lawphil.net/statutes/repacts/ra1989/ra_6809_1989.html)

Article 1144 gives a written-contract action ten years **from accrual**, which may be later than the newest evidence record. Electronic terms and assent can qualify if proved. A tick alone does not establish who assented or their authority. A decline itself does not form a contract, but it can also be evidence in a dispute about earlier processing. Article 1146 supplies a four-year period for certain civil claims. It does not show that every relevant claim accrues on the decline date or that a decline-only record legally needs exactly four years. Special rules and interruption can affect the deadlines. Neither statute establishes a records-retention period. [Civil Code Arts. 1144, 1146, 1148, 1150, 1155](https://www.lawphil.net/statutes/repacts/ra1949/ra_386_1949.html), [E-Commerce Act §§ 7–8, 16, 18](https://www.lawphil.net/statutes/repacts/ra2000/ra_8792_2000.html), [Data Privacy Act § 11(e)](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html)

**Replacement:** “We keep limited evidence to answer legal claims about permission for an account or purchase. After account deletion, we schedule the evidence for deletion 3,653 days after its newest record if it includes a confirmation, withdrawal, or guardian checkout declaration. If it contains only declines, we schedule it for deletion 1,461 days after its newest record.”

**3. Teen Notice, flag timing across all three paragraphs.**

> “We hold it only while the request is open, which is seven days at most, and after a guardian confirms.”
>
> “We do not keep an under-18 group record for a request that expired or was declined.”
>
> “The whole record includes the under-18 group record, so no under-18 group record remains for an expired or declined request.”

These sentences imply the flag disappears when the request closes. A decline starts a seven-day wait, and expiry triggers scheduled cleanup. The “Why we ask your age” paragraph otherwise describes the intended whole-record deletion. Keep the confirmed-account endpoint and the distinction between the request record and separate answer evidence. [Data Privacy Act § 16(b)](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html), [NPC child-oriented transparency guidance § 3](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf)

**Replacement for the timing language in both explanations:** “If the request expires, scheduled cleanup deletes the whole request, including the under-18 group record. If your guardian declines, cleanup deletes that same record once seven days have passed. If your guardian confirms, we keep the group record until your account is updated to 18 or older or is deleted.” In the basis bullet, cross-reference this schedule instead of repeating it.

**4. Both notices, payment deletion and the buyer’s identity.**

> “We never keep a declaration that an adult made for their own account”
>
> “The one exception is a declaration made by a parent or legal guardian for an under-18 account: we first copy its date, time, Terms version, wording version, payment reference and product into the guardian evidence that the Notice for teens describes, and that evidence stays for the periods stated there.”
>
> “When an account is deleted, we copy into this evidence only declarations made by a parent or legal guardian.”

“We never keep” contradicts recording adult checkout declarations while the account exists. “The one exception” also blurs the difference between deleting the original account-linked records and keeping a limited copy. Both deletion summaries describe actual guardian identity where the system has a declaration. The six copied fields match across the notices. [Data Privacy Act §§ 11(c), 16(b)](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html), [E-Commerce Act § 18](https://www.lawphil.net/statutes/repacts/ra2000/ra_8792_2000.html)

**Replacement for both notices:** “When account deletion finishes, we delete the payment records tied to the account. Before deletion, we copy limited details from checkout declarations where the buyer says they are a parent or legal guardian buying for the student. We copy the date, time, Terms version, wording version, payment reference, and product. We never copy declarations for a buyer’s own account into guardian evidence.” Keep guardian answers and withdrawal in the surviving-record list, and keep the separate payment-reference records there too.

**5. Teen Notice and Privacy Policy, longer retention.**

> “If the law requires it, or we need specific records for a legal claim, we may keep those records longer.”

This is unchanged text that directly affects the changed promises. As written, it implies Pantas can extend the guardian evidence schedule for a claim. The cleanup cannot do that. Apply the same qualification in both notices. [Data Privacy Act §§ 11(e), 16(b)](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html), [Data Privacy Act IRR § 19](https://privacy.gov.ph/implementing-rules-regulations-data-privacy-act-2012/)

**Replacement:** “The schedules above apply to guardian evidence and question reports. We may keep other specific records longer when the law requires it or when we need them for a legal claim.”

### Conflicts with a ruling

- **Hard 90-day deadline with Firestore TTL alone.** Both notices say “we delete each report within 90 days of receipt.” They agree with each other, but Firestore typically deletes within 24 hours **after** expiry and gives no hard maximum. If the TTL timestamp is set at day 90, the accurate wording is “We schedule each report to expire 90 days after we receive it. Automatic deletion can take longer. We delete reports sooner when account deletion finishes.” That wording discloses the delay. It cannot also promise the ruled hard deadline. [Firestore TTL deletion behavior](https://firebase.google.com/docs/firestore/ttl#ttl_deletion)
- **Actual guardian identity, if the copy rule is read literally.** “Only declarations made by a parent or legal guardian” cannot be established by the tick alone. The replacement in finding 4 is accurate if eligibility means the buyer submitted the guardian version. It cannot promise that only declarations from verified guardians survive. [E-Commerce Act §§ 8, 18](https://www.lawphil.net/statutes/repacts/ra2000/ra_8792_2000.html)
- **Mandatory preservation, if ordered.** A fixed cleanup schedule can coexist with having no discretionary hold. If a binding preservation order covers the evidence, the notice cannot override it. There is no wording cure if cleanup cannot honor such an order. [Rules of Court, Rule 21](https://lawphil.net/courts/rules/pdf/am_19-10-20-sc_2019.pdf)

## Should-fix

**6. Both refund clauses in Terms and the Teen Notice, use the same claim route.**

> “If a parent or legal guardian of an under-18 student emails support@pantas.study to say they did not allow a purchase for that student's account, we refund the purchase in full without contest.”
>
> “If a parent or legal guardian tells us they did not allow a purchase for an under-18 student's account, we refund that purchase in full without contest, and the access it funded ends.”
>
> “If a parent or legal guardian tells us they did not allow a purchase for your account, we refund it in full without contest, and the access it funded ends.”

The trigger is already limited to a parent or legal guardian’s denial. The wording makes a refund promise without admitting the purchase was unauthorized. The other two passages omit the email route, and neither expressly carries over the deadline exception. A false claimant could impersonate a guardian or try to redirect a manual refund. Identify the payment and its proper recipient without asking the guardian to prove the denial. Credit any amount already returned toward the full refund. PayMongo’s own refund windows still apply to its refund mechanism, so the deadline exception is a promise Pantas must be able to fulfill even after that mechanism closes. [Internet Transactions Act §§ 20, 23–24](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/96902), [PayMongo refund windows](https://docs.paymongo.com/docs/payment-acceptance-refunds)

**Replacement in Refunds:** “If you are the parent or legal guardian of an under-18 student and did not allow a purchase for their account, email support@pantas.study. Include the payment reference if you have it. We refund the purchase in full without contest. The 30-day deadline does not apply. The access from that payment ends. Your legal rights still apply.” In **Students under 18**, cross-reference this refund clause. In the **Teen Notice**, give the same email and keep the full refund, deadline exception, and access outcome.

**7. Teen Notice, unsupported clock fallback and exact-day promise.**

> “It counts from the evidence's latest record, or from the deletion date if there is no record date.”
>
> “If the evidence holds a guardian's confirmation, a withdrawal or a guardian purchase declaration, we remove it 3,653 days (ten years) after its latest record.”
>
> “If it holds only declines, we remove it 1,461 days (four years) after its latest record.”

The deletion-date fallback exists in the older job, but it is outside the supplied ruling. The job also runs on a schedule, so “we remove it” on an exact day overstates what the job guarantees. Use finding 2’s replacement, with exact day counts and no unruled fallback. [Existing evidence cleanup](/Users/aedwon/.t3/worktrees/Pantas/t3-96a8fd9c-c6f6794e67cee48f/functions/src/purgeInactiveAccounts.ts:255), [Data Privacy Act § 16(b)](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html)

**8. All three drafts, checkout and cleanup claims need launch verification.**

> “Checkout does not start without it, and you can open the Terms without ticking it.”
>
> “For every web purchase, we record the declaration with the date, time, Terms version and wording version when checkout starts.”

The first sentence makes two checkout implementation claims beyond the supplied rulings. The checked-out server requires a tick only for flagged accounts and records no wording version. The checked-out cleanup also keeps the under-18 flag after failed requests and applies one evidence period. The launch summary identifies these as pending. [Checkout code](/Users/aedwon/.t3/worktrees/Pantas/t3-96a8fd9c-c6f6794e67cee48f/functions/src/paymongoCheckout.ts:43), [Guardian cleanup](/Users/aedwon/.t3/worktrees/Pantas/t3-96a8fd9c-c6f6794e67cee48f/functions/src/guardianConsent.ts:582), [Launch change summary](/Users/aedwon/.t3/worktrees/Pantas/t3-96a8fd9c-c6f6794e67cee48f/docs/legal-drafts/2026-11-22-public-launch/change-summary.md:89)

**Replacement once the launch behavior is verified:** “At web checkout, we record the buyer’s declaration, the date and time, the Terms version, and the version of the declaration shown.” Publish the stronger checkout claims only if the launch build supports them.

## Nit

> “For QR Ph, you approve payment in your bank or wallet app.”

In the Teen Notice payments bullet, “you” means the student. The buyer could be someone else. [Data Privacy Act § 11(c)](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html)

**Replacement:** “For QR Ph, the person paying approves the payment in their bank or wallet app.”

## Clauses found fine

- The Teen Notice explicitly calls the tick a declaration and says it does not prove guardian identity.
- The flag paragraphs remove the whole failed request and distinguish it from separate guardian-answer evidence. The timing qualifications above make that distinction exact.
- Both notices include earlier deletion of reports on account deletion, without tying it to the end of review.
- The Terms waive the ordinary 30-day deadline for this refund, end only the access funded by that payment, and preserve legal rights.

## Civil Code verdicts

- **Article 1108: held.** Acquisitive and extinctive prescription runs against minors and other incapacitated people who have parents, guardians, or other legal representatives. This general rule does not displace Article 1391’s specific annulment rule. [Lawphil, Arts. 1108 and 1115](https://www.lawphil.net/statutes/repacts/ra1949/ra_386_1949.html)
- **Article 1144: held.** Actions on a written contract, an obligation created by law, or a judgment generally have ten years from accrual. [Lawphil, Art. 1144](https://www.lawphil.net/statutes/repacts/ra1949/ra_386_1949.html)
- **Article 1146: held.** A civil action for injury to the plaintiff’s rights or for a quasi-delict generally has four years. Article 1150 supplies the default start when the action can first be brought. [Lawphil, Arts. 1146 and 1150](https://www.lawphil.net/statutes/repacts/ra1949/ra_386_1949.html)
- **Article 1391: held.** An action to annul a voidable contract has four years. For a contract entered into by a minor or another incapacitated person, the clock starts when guardianship ceases. [Lawphil, Arts. 1390–1391](https://www.lawphil.net/statutes/repacts/ra1949/ra_386_1949.html)

**Biggest legal risk:** Pantas records sensitive age-group information for routine request routing before guardian permission, while the notice cites a legal-claims basis whose necessity for that use has not been established. Shorter storage reduces exposure without resolving the initial collection. [Data Privacy Act § 13](https://www.lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html), [NPC Advisory 2024-02 §§ 4–5](https://privacy.gov.ph/wp-content/uploads/2024/08/NPC-Advisory-No.-2024-02-Personal-Data-Processing-Based-on-Section-13-f.pdf)