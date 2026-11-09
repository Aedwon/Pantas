The draft is **not ready to publish**. Its strongest business protections can remain, but several statements overreach or contradict the source.

Reviewed against `origin/web/design-system-4` at `7fcfc135`, the specified owner decisions, and current pricing. Production settings and separate bookkeeping remain unverified. No files were edited. Replacements marked **operational change needed** are proposed wording, not statements of current behavior.

**Text 1: Teen privacy notice**

1. **“Pantas is for people aged 13 and older.” Verdict: keep.**  
   Thirteen is a product restriction, not a Philippine statutory age of independent consent. The surrounding guardian requirement prevents that implication. No legal explanation needs adding. Child safeguards remain risk-based under NPC Advisory **2024-03**, §§2–3. [Child-oriented transparency guidance](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf)

2. **“We keep the age group, not your birth year.” Verdict: change.**  
   Substantially accurate, but the year remains temporarily in memory. The source also admits some twelve-year-olds turning thirteen that year. This matters when assessing the claimed minimum-age safeguard.

   **Replacement:** “We use your birth year to check your age group. We do not save it as a lasting record. We save the age group.”

   Assess the minimum-age mismatch under Advisory 2024-03 §2; wording alone cannot correct it.

3. **“He is also the Data Protection Officer.” Verdict: keep.**  
   A sole proprietor can perform this role. NPC guidance expressly recognizes an individual controller as the de facto DPO. Hiring another person is unnecessary merely to make this statement lawful. [NPC DPO guidance](https://privacy.gov.ph/appointing-a-data-protection-officer/)

4. **“Account … Study records … Technical records.” Verdict: keep, with one addition.**  
   These categories and purposes broadly match the source. Describe automated review planning more clearly, without disclosing proprietary formulas.

   **Add:** “We use your answers and study times to choose your review dates and show your progress.”

   DPA §16(b)(3) requires disclosure of processing scope and method. Missing detail creates transparency exposure, not an automatic duty to publish source code. [DPA](https://privacy.gov.ph/data-privacy-act/)

5. **“Guardian confirmation: … request status, its dates … scrambled codes.” Verdict: change.**  
   It omits separate response evidence. Current `guardianConsent.ts` records document versions, agreement, decision, and date outside the user tree. Account deletion preserves it.

   **Replacement:** “We also keep a record of the response, when it happened, and which notices and terms were shown. This record can remain after account deletion.”

   Its actual retention limit must also be settled. The draft’s contrary assertion undermines informed consent and invites an NPC complaint: DPA §§11, 16.

6. **“Card and wallet details … We do not receive them.” Verdict: change.**  
   Too absolute. The source processes PayMongo webhook bodies and API responses before extracting selected fields. That does not establish that Pantas receives no payment-method metadata.

   **Replacement:** “You enter payment credentials on PayMongo’s checkout page. We keep payment references, amounts, status, refunds, and access dates.”

   This preserves the useful assurance without claiming an unverified data boundary: DPA §16(b).

7. **“A scrambled code … so we can offer one trial per person.” Verdict: change.**  
   The code recognizes verified sign-in identities, not unique human beings. Hashing also does not make a record anonymous.

   **Replacement:** “We keep protected codes based on verified sign-in details to check whether a trial was already used.”

   Accurate disclosure avoids overstating identity checks: DPA §§3(g), 11.

8. **“Optional usage sharing … starting or finishing a session.” Verdict: change.**  
   Material omission: `submit_answer.dart` also sends question IDs, chosen answer labels, and correctness. These link to account IDs and can reveal educational performance.

   **Replacement:** “If you turn sharing on, reports include screens and features used, session activity, question IDs, chosen answer labels, and whether answers were correct. They can be linked to your account.”

   Omitting these fields risks invalid consent and an NPC order to stop collection. DPA §13(a); Circular 2023-04 §§8–9. [Consent guidelines](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf)

9. **“Your choice, or your guardian’s if you are under 18.” Verdict: change.**  
   A general guardian agreement does not establish separate consent to optional performance analytics. The source confirmation checkbox does not offer that separate choice.

   **Replacement:** “Optional sharing starts off. Permission for core study records does not include optional sharing. Refusing optional sharing does not stop you from using Pantas.”

   **Operational change needed:** obtain and record the applicable separate permission. Circular 2023-04 §8 prohibits bundling unrelated optional processing.

10. **“Speed and error reports … We cannot link a report to you.” Verdict: change.**  
    Apply items 35–39 below. The stored report omits an account ID, but collection uses authenticated requests and an account-derived rate-limit key. “Cannot” is unsupported.

11. **“Opening the email link confirms nothing … anyone who has it can answer.” Verdict: keep.**  
    These are accurate, useful safeguards. Do not remove the link warning merely because it acknowledges a risk. Electronic assent can be valid, but possession of a link does not establish guardianship. RA 8792 §§8, 16; Advisory 2024-03 §2. [E-Commerce Act](https://lawphil.net/statutes/repacts/ra2000/ra_8792_2000.html)

12. **“Confirming does not give them a screen showing your results.” Verdict: keep.**  
    Accurate. Verification before releasing data is also lawful. The strongest defensible position is reasonable verification, without demanding excessive documents. DPA §20; DPA IRR §34(c).

13. **“Where your data goes … Google, Resend, PayMongo.” Verdict: change.**  
    Keep the Free-server-records disclosure. The provider list is incomplete for a notice covering the phone app: the source also uses RevenueCat for store purchases and access management.

    **Add:** “For app-store purchases and related Pro access, we also use RevenueCat and the relevant app store.”

    Overseas processing is lawful with safeguards; consent is not automatically required solely because a provider is overseas. Pantas remains accountable under DPA §§14, 21.

14. **“Your rights … ask for a copy.” Verdict: change.**  
    Add portability explicitly. An email route can satisfy it; an export button is not inherently required.

    **Add:** “Where the law applies, you can request your data in a commonly used electronic format.”

    DPA §18; IRR §36. Omission risks an incomplete rights notice. [NPC portability guidance](https://privacy.gov.ph/right-to-data-portability/)

15. **“We reply within 15 calendar days.” Verdict: change.**  
    This creates an unnecessary general service commitment. It is not a universal DPA response deadline. Existing published commitments must be reconciled before replacement.

    **Replacement:** “We handle requests promptly. We may ask for information reasonably needed to check your identity. If we cannot fully act, we explain why.”

    Preserve any specifically applicable deadline. Do not use verification or progress updates to delay rights indefinitely: IRR §34.

16. **“To withdraw … a parent or guardian emails…” Verdict: change.**  
    Email support may assist, but an exclusive email process is problematic where consent takes a checkbox and button. Withdrawal must be comparably easy.

    **Proposed replacement, operational change needed:** “You or your guardian can withdraw permission through the confirmation page or email dpo@pantas.study. Withdrawal is free.”

    Circular 2023-04 §13(A)–(B). Current wording cannot cure the missing equivalent withdrawal route.

17. **“Withdrawing it means we close the account…” Verdict: keep.**  
    Lawful for processing genuinely necessary to the service and dependent on consent. Retaining specified records under another valid basis is permissible. Avoid suggesting that withdrawal ends unrelated statutory rights.

    Circular 2023-04 §13 permits termination of services dependent on withdrawn consent.

18. **“Delete your account … deletes your study data … Trial codes, security records and payment records [remain].” Verdict: change.**  
    The list omits surviving guardian-response evidence. Provider backups also need a verified limit or deletion schedule, not merely “longer.”

    **Replacement:** “Account deletion removes the account’s study records. Limited trial-use, guardian-response, security, and required accounting records may remain for their stated purposes and retention periods.”

    DPA §§11(e), 16(b)(7). This requires a complete, accurate retention schedule.

19. **“After 24 months [inactivity] … Free-trial codes: 24 months.” Verdict: change.**  
    No relevant purge exists in the inspected source. Trial markers lack timestamps. A reliable manual process could satisfy a promise, but none was established.

    **Replacement, only after establishing that process:** “We delete server study records after 24 months without use. We delete trial-use codes 24 months after the first trial.”

    The drafter’s “true until November 2028” reasoning is unsound. Future commitments need a credible means of performance now. DPA §§11(e)–(f), 16.

20. **“Guardian requests … deleted when the seven-day window ends … keep only [confirmation] while the account exists.” Verdict: change.**  
    Cleanup runs hourly, not precisely at expiry. Separate response evidence survives deletion and has no located purge.

    **Replacement:** “Links stop working after seven days. Server cleanup normally removes expired requests and links during the next hourly cleanup. Separate response evidence follows its own retention period.”

    **Publication blocker:** specify and implement that separate period. Do not invent one or conceal indefinite retention: IRR §19(d).

21. **“Payment and accounting records: five years, as tax rules require.” Verdict: change.**  
    Five years is broadly correct, but the starting point matters. The app deletes its payment index, so separate accounting preservation remains unverified.

    **Replacement:** “We keep required accounting records for five years, counted under tax law from the relevant return deadline or late filing date. Required records may remain longer for an unresolved tax matter.”

    Tax Code §235, amended by RA 11976 §33. Missing bookkeeping creates BIR exposure as well as an inaccurate notice. [Amending law](https://www.lawphil.net/statutes/repacts/ra2024/ra_11976_2024.html)

22. **“Security and account records: 730 days.” Verdict: keep narrowly.**  
    The database audit purge supports this. It does not establish the lifetime of every Cloud log, backup, or provider record.

    **Clarification:** “Our database audit records: 730 days after the event.”

    DPA §11(e) still requires a documented necessity for that period.

23. **“Analytics … no more than 14 months. Phone error reports … 90 days.” Verdict: change.**  
    Analytics retention settings exclude some aggregated reports and can refresh user identifiers. Crashlytics starts deletion after ninety days; completion is not necessarily immediate.

    **Replacement:** “Analytics event records follow our configured retention setting. Some user identifiers can remain longer when activity refreshes their expiry. Google starts removing Crashlytics crash records after 90 days.”

    Insert the verified Analytics setting before publication. [Analytics retention](https://support.google.com/analytics/answer/7667196?hl=en_EN), [Firebase retention](https://firebase.google.com/support/privacy/)

24. **“If … we need records for a legal claim … longer.” Verdict: keep.**  
    This is a useful business protection when limited to necessary records and a real retention justification. It does not authorize keeping everything indefinitely. DPA §§11(e), 13(f).

25. **“Needed to provide the service … permission … legitimate interests.” Verdict: change.**  
    Contract necessity under §12(b) does not alone authorize sensitive age or education data. Entering a year is not automatically informed consent; later guardian confirmation cannot retrospectively supply missing consent.

    **Replacement:** “We use ordinary account information to provide the service you request. We rely on specific permission for age and education information. Separate permission covers optional sharing.”

    Establish a lawful basis before the initial age processing. DPA §§3(l), 12–13.

26. **“For … security records, guardian email and trial code: our legitimate interests.” Verdict: change.**  
    Potentially lawful for ordinary personal information. Each purpose needs an assessment; a hash can remain personal information. Sensitive linked records require a §13 basis.

    **Replacement:** “We use limited contact, security, and trial-use records to manage guardian requests, protect Pantas, and prevent repeat trials.”

    Keep the legal-basis explanation alongside this sentence. Circular 2023-07 §§3(B), 4–8. [Legitimate-interest guidelines](https://privacy.gov.ph/wp-content/uploads/2024/01/NPC-Circular-No.-2023-07_Guidelines-on-Legitimate-Interest_13-December-2023.pdf)

27. **“Payments for minors … payment-method owner is responsible.” Verdict: change.**  
    Use the replacement in item 33. Neither a teen notice nor possession of payment credentials binds an uninvolved adult.

    Also correct the notes: new consent depends on changes to processing, not simply the owner’s preference. Circular 2023-04 §4(B) permits retaining consent only where the relevant processing remains unchanged.

**Text 2: Terms, “Subscriptions”**

28. **“App store purchases … store handles … refunds under its own rules.” Verdict: change.**  
    The billing route is accurate, but store rules cannot displace mandatory service remedies.

    **Replacement:** “For app-store purchases, use the store account for billing, cancellation, and store refund requests. Contact us about problems with Pantas itself.”

    Consumer Act Arts. 102, 105–106. Pantas cannot outsource its service-quality liability.

29. **“Web purchases … prepaid … do not renew automatically”; “Price”; “Plans.” Verdict: keep.**  
    These match the prepaid model and calendar calculations. Referencing checkout prices avoids unnecessary Terms revisions. “A change does not affect a payment you already made” appropriately protects existing purchases.

    Display the complete payable price before purchase, including applicable charges. RA 11967 §23(a); ITA IRR §34(b).

30. **“Access starts after PayMongo confirms … or existing Pro ends.” Verdict: change.**  
    Source contradiction: subscription periods use recorded payment time, potentially before webhook processing. Only qualifying same-or-higher-tier coverage queues them. Passes start independently and do not stack.

    **Replacement:** “We enable access after verifying payment. Plan periods are calculated from PayMongo’s recorded payment time or the end of qualifying existing Pro access, whichever is later. Season Passes run from payment through their stated sitting and do not stack.”

    Material activation delays can still require redress. Ambiguity otherwise works against Pantas: Civil Code Art. 1377.

31. **“We decide who qualifies [for a trial].” Verdict: change.**  
    Reserve control over future offers, while honoring published eligibility and accepted trials.

    **Replacement:** “Eligibility depends on verified sign-in details and previous Pro or trial use. We may change future trial offers. We may refuse or end trials reasonably suspected of abuse.”

    The remaining seven-day, no-payment-details, no-conversion wording can stay. Arbitrary contradiction of an advertised offer risks Consumer Act Art. 50.

32. **“Free or promotional access … period we state … earlier if misused.” Verdict: keep.**  
    This already favors the business without reserving arbitrary cancellation. Honor the announced period unless the stated abuse condition applies. Civil Code Arts. 1159, 1306.

33. **“Students under 18 … person whose payment method is used is responsible.” Verdict: change.**  
    A payment-method owner is not automatically the purchaser or an authorized contracting party.

    **Replacement:** “If you are under 18, your parent or guardian must make the purchase and accept these Terms as the purchaser. Purchasers must be authorized to use the selected payment method.”

    **Operational change needed:** capture adult purchase assent. Existing guardian confirmation expressly authorizes no charge. Civil Code Arts. 1317, 1327, 1390; RA 8792 §16.

    **Correct the notes:** minors’ contracts are generally **voidable**, not automatically void. Articles **1426–1427 expressly address the former eighteen-to-twenty-one minority bracket**; they provide no blanket defense for thirteen-to-seventeen purchases. Majority is now eighteen under RA 6809. Article **1399** limits the minor’s restitution to actual benefit. Article **1489** concerns a reasonable price for proven necessaries; an optional exam-prep subscription does not automatically qualify. [Civil Code](https://lawphil.net/statutes/repacts/ra1949/ra_386_1949.html), [RA 6809](https://lawphil.net/statutes/repacts/ra1989/ra_6809_1989.html)

34. **“Refunds … final … only these two cases”; “within 30 days”; “cannot ask for a partial refund”; “after the exam date.” Verdict: change.**  
    These can restrict the **voluntary policy**, not statutory remedies. Consumer Act Art. **102** expressly permits proportionate price reduction for defective services. Arts. **105–106** prohibit contractual exoneration. An isolated saving clause does not reliably cure contradictory absolutes or misleading descriptions of rights.

    **Replace the restrictive refund paragraphs with:**

    > “Under our voluntary refund policy, we refund an unused duplicate payment or a payment that never provided the purchased access. Send requests within 30 days of payment to support@pantas.study, with enough details to identify the transaction.  
    >   
    > We do not offer change-of-mind refunds or partial refunds for unused time. Once an access period starts, or a Season Pass’s exam date passes, it falls outside this voluntary policy. These restrictions and the 30-day deadline do not limit remedies required by Philippine law.”

    Consequence: DTI complaint, statutory refund or price reduction, and the offending restriction denied effect. ITA IRR §37 independently preserves legal remedies. [Consumer Act](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/2/3302), [Final ITA IRR](https://ecommerce.dti.gov.ph/wp-content/uploads/2024/06/Joint-Administrative-Order-No.-24-03.pdf)

35. **“At our choice … partial refund shortens access proportionally.” Verdict: change.**  
    Suitable for a goodwill cancellation. It must not automatically reduce promised service when the refund compensates for defective service.

    **Replacement:** “We may grant goodwill refunds without creating a general entitlement. For an agreed cancellation, refunded access may be reduced proportionally. A refund required for defective service follows the applicable legal remedy.”

    Current automatic shortening needs that distinction operationally. Otherwise, a statutory price reduction could wrongly purchase less service. Consumer Act Art. 102.

36. **“Refund to the original payment method … depends on PayMongo and your bank.” Verdict: keep.**  
    PayMongo supports original-method refunds. The sentence appropriately distinguishes settlement time from approval. It does not excuse Pantas from initiating an owed refund promptly. [PayMongo refund documentation](https://docs.paymongo.com/reference/refund-resource)

37. **“If you dispute … we end all … We may also suspend the account.” Verdict: change.**  
    Temporarily suspending disputed paid access is defensible. Automatic forfeiture and whole-account punishment for a good-faith complaint are disproportionate and may themselves breach the contract.

    **Replacement:** “We may suspend access funded by a disputed payment while it is investigated. Reversed payments end the related access. If the dispute resolves in our favor, access follows the payment’s restored status. We may restrict accounts reasonably suspected of fraud or abuse.”

    This better matches the dispute-resolution code. Consumer Act Arts. 50, 52; Civil Code Arts. 19, 1159.

38. **“Ending Pro does not delete your progress”; “Deleting your account … access ends.” Verdict: change the first; keep the second.**  
    Expiry alone does not delete progress, but privacy retention rules still apply.

    **Replacement:** “Ending Pro does not itself delete progress. Data remains subject to our privacy retention rules.”

    Voluntary account deletion can end unused access without a discretionary refund. It cannot extinguish an existing statutory claim. Civil Code Art. 1306; DPA §11(e).

39. **“Your legal rights … cannot be waived.” Verdict: keep.**  
    Useful, but not a cure for misleading substantive clauses. Illegal stipulations may fail under Civil Code Art. **1409**; obscure wording may be read against Pantas under Art. **1377**. Adhesion alone does not invalidate the entire contract.

40. **Omitted: complaint process and merchant disclosures. Verdict: change.**  
    Add a clear internal complaint route. RA 11967 §§23(i), 24 and IRR §§34(j), 38 require an accessible mechanism. Exhaustion occurs after seven unresolved calendar days.

    **Add:** “Send purchase complaints to support@pantas.study. If unresolved after seven calendar days, our internal complaint process is deemed exhausted.”

    Separately, the **homepage** must disclose the business name, physical business address, telephone number, and email. Sales require invoices. These duties cannot be satisfied solely inside the teen notice: §23(f), (h); IRR §34(g), (i). Missing information creates DTI enforcement exposure. [ITA](https://lawphil.net/statutes/repacts/ra2023/ra_11967_2023.html)

**Text 3: Telemetry legal-basis line and Privacy Policy section**

41. **“Legitimate interests … keeping Pantas working and fast.” Verdict: keep conditionally.**  
    This is a defensible purpose for necessary ordinary technical data. Consent need not be the default basis. However, the assessment must cover authenticated collection, connection metadata, retained error text, and children.

    Circular 2023-07 §§3–8 requires documented purpose, necessity, balancing, and regular review. A favorable conclusion is not established merely by writing it down.

42. **“These reports are not linked to your account”; “We cannot link a report to you.” Verdict: change.**  
    The collection endpoint receives Firebase identity and hashes the UID for rate limiting. Lack of an ID in the application log does not establish anonymity.

    **Replacement:** “The stored technical report does not contain your account ID. The request uses your account session, including an anonymous session, to authenticate and limit reports.”

    False anonymity assurances create NPC transparency exposure. DPA §§3(g), 11, 16.

43. **“They show … loading … browser … cleaned error details.” Verdict: change.**  
    Also disclose build version, visit category, error counts, and technical stack information. Client filtering misses some names, URL paths, and free text; server validation checks structure and length, not anonymity.

    **Replacement:** “Reports include app version, visit category, browser family, screen-size category, loading times, and filtered error messages, counts, and technical locations. We filter common identifiers before sending.”

    **Operational issue:** prevent sensitive information entering errors. Section 12(f) cannot authorize sensitive data merely because its collection was accidental.

44. **“No … answers or lesson content.” Verdict: change.**  
    No dedicated fields collect these, but retained arbitrary error messages make an absolute exclusion unproven.

    **Replacement:** “We do not deliberately include answers or lesson content in these reports.”

    This qualifies the factual claim; it does not cure excessive collection. Prefer fixed error categories over unrestricted error messages. Circular 2023-07 §6.

45. **“Google’s server logs may … IP address. We do not use these details to identify you.” Verdict: keep with clarification.**  
    The caveat is appropriate. Cloud Run creates request logs separately from application logs; production fields and correlation remain unverified.

    **Replacement:** “Google’s connection logs may include IP addresses and browser details. These details can sometimes identify a person when combined with other information. We do not use them to identify users.”

    Do not imply that Google alone controls Pantas’s processing obligations. [Cloud Run logging](https://docs.cloud.google.com/run/docs/logging?hl=en)

46. **“Google deletes the reports after 30 days.” Verdict: change.**  
    Thirty days is a configurable default, not proof of this project’s settings or exported copies.

    **Replacement, after verification:** “We retain these technical report logs for 30 days. Separate security logs follow the retention periods described in this policy.”

    Verify buckets, routing, exports, and relevant connection logs. Incorrect retention disclosures invite an NPC complaint. [Google retention settings](https://docs.cloud.google.com/logging/quotas)

47. **“On for everyone … whether or not you share extra usage data.” Verdict: change.**  
    Default-on processing can rely on legitimate interest. That does not eliminate the right to object. Inability to locate old reports does not explain why future collection cannot stop.

    **Replacement:** “These technical reports run by default and are separate from optional usage sharing. You can object by contacting dpo@pantas.study. We assess objections under applicable law.”

    **Operational change needed:** genuinely handle objections and stop processing where required. IRR §34(b) exceptions require a supported basis. The owner’s always-on preference is insufficient. [NPC legitimate-interest FAQ, questions 21 and 40](https://privacy.gov.ph/wp-content/uploads/2024/01/FAQ-Guidelines-on-Legitimate-Interest-as-of-28-December-2023.pdf)

48. **Assessment: “No sensitive information”; “about one to three reports”; “individual objection cannot be performed.” Verdict: change.**  
    All three conclusions exceed the evidence. Error text can contain sensitive information; reporting can recur while new data exists; prospective suppression is technically distinct from finding historical logs.

    **Replacement assessment wording:** “Assess authenticated collection and associated logs as personal-data processing. Document actual frequency, error-content risks, less intrusive alternatives, children’s interests, retention, and objection handling before relying on Section 12(f).”

    “Users expect telemetry” also needs evidence beyond the notice itself. Circular 2023-07 §§6–8.

49. **“Review every 12 months”; uncertain circular date; unnamed child guidance. Verdict: change.**  
    An annual review is an owner-selected schedule, not the circular’s prescribed interval.

    **Replacement:** “Review regularly and whenever processing or relevant risks change.”

    Correct references to **NPC Advisory 2024-03, dated December 17, 2024**. Circular 2023-07 §18 governs effectivity; §15 separately grants a ninety-day records-compliance transition. Do not conflate those dates.

50. **“Add [telemetry section] to the Privacy Policy stub.” Verdict: change.**  
    Necessary, but insufficient. Adults still lack the controller’s identity/contact, complete categories and purposes, bases, recipients, retention, and usable rights information.

    **Replacement instruction:** “Publish a complete Privacy Policy incorporating the corrected disclosures above, with this telemetry section available before collection or at the next practical opportunity.”

    DPA §16; IRR §34(a). Child-facing notices additionally need accessible, timely explanations of relevant risks and safeguards. Advisory 2024-03 §§2–3 requires more than placing a long notice behind a link. [DPA IRR](https://privacy.gov.ph/implementing-rules-regulations-data-privacy-act-2012/)

**Five most important changes, in priority order**

1. Make every refund restriction expressly voluntary; preserve defective-service refunds and statutory price reductions.
2. Correct omitted analytics fields, surviving guardian evidence, and unsupported retention promises.
3. Obtain specific, appropriately authorized consent before sensitive processing; provide comparably easy withdrawal.
4. Replace anonymity claims and make telemetry objection handling real; reassess the complete collection path.
5. Capture adult purchase assent and provide the required merchant disclosures, invoices, and complaint mechanism.