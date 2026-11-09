**Not ready to publish.** The main protections are defensible, but the age basis, adult study-data basis, and several build claims need correction.

Reviewed against the settled Part 2 design, the earlier critique, and source at `origin/web/design-system-4` (`5c960a4b`). No files edited. Earlier refund, analytics-field, guardian-withdrawal, and adult-purchase findings are substantially addressed; remaining issues follow.

1. **A/D: “Age check … Section 12(f)”; “This is not a consent request.” — Change.**

   Age is sensitive information. Local processing and immediate disposal reduce risk; they do not establish a DPA exemption. Section 12(f) cannot authorize sensitive processing. Later guardian consent cannot cure the earlier check. [DPA §§3, 13](https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html); [Circular 2023-07 §3(B)](https://privacy.gov.ph/wp-content/uploads/2024/01/NPC-Circular-No.-2023-07_Guidelines-on-Legitimate-Interest_13-December-2023.pdf).

   **Strongest framing:** specific prior consent for screening; guardian authorization where required; §13(f) for necessary evidence afterward.

   **Replacement, requiring a build change:** “Before checking your birth year, we ask you, or your parent or guardian where required, to authorize this check. We use the year on your device and keep only the resulting age group.”

   **The settled build does not obtain that prior authorization. Wording alone cannot close this gap.**

2. **A: “We keep the under-18 age group … as evidence under Section 13(f).” — Change.**

   Section 13(f) can support minimal consent and capacity evidence without an existing lawsuit. NPC Advisory 2024-02 expressly allows preparatory processing. It does not automatically authorize routine age screening merely because litigation is conceivable. [Advisory 2024-02 §§2–5, 7](https://privacy.gov.ph/wp-content/uploads/2024/08/NPC-Advisory-No.-2024-02-Personal-Data-Processing-Based-on-Section-13-f.pdf).

   **Replacement:** “Your guardian’s permission covers the age-group record needed to operate your account. We retain limited permission evidence where necessary to establish or defend legal claims.”

   The draft’s suggestion that §13(f) normally requires an actual claim is too narrow; its use for initial screening remains insufficiently justified.

3. **D: “We treat practice answers as ordinary personal information.” — Remove.**

   Identifiable answers and learning results plausibly concern education. The statute contains no exemption for informal self-study. Obtain §13(a) consent rather than stake the business on that distinction.

   **Replacement:** “We use ordinary account and payment information to provide the requested service. We obtain specific permission to process identifiable answers, learning results, and study records.”

   **Important correction to the earlier critique:** a separate core-service checkbox is not invariably required. Necessary sensitive processing can form part of contractual consent if properly specified. Expand the existing acceptance wording; keep optional analytics separate. [Circular 2023-04 §§8(A), 19](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf).

4. **A: “You cannot turn it on yourself”; “Only your guardian can turn it on.” — Change the surrounding explanation.**

   Part 2 permits the student to turn sharing **off** after guardian approval. The notice currently obscures that control.

   **Replacement:** “Sharing starts off. Your guardian must allow it before it can turn on. After that, you can turn it off in Settings. Your guardian can also withdraw that permission.”

   This is a factual correction under DPA §16.

5. **A: “We treat anyone who uses a link as your guardian.” — Change.**

   A bearer link authorizes a technical action; it does not conclusively establish legal authority. Electronic contracting rules preserve questions of attribution and reasonable reliance. [RA 8792 §§8–12, 18](https://lawphil.net/statutes/repacts/ra2000/ra_8792_2000.html).

   **Replacement:** “Anyone holding these links can use them to respond or manage permission. Keep them private. The links do not independently prove someone’s identity or authority. Contact us if a link is lost, shared, or misused.”

   Also address adulthood: the planned lifelong link could let a former guardian delete an adult’s account. **Required build condition:** guardian controls must end when authority ends, unless the adult user authorizes continued representation. Risk-based verification need not mean collecting government IDs routinely. [Advisory 2024-03 §2](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf).

6. **A: “Guardian answer record, the withdrawal record and the purchase confirmation … ten years after your guardian’s answer.” — Change; retain the ten-year approach narrowly.**

   Ten years is defensible for minimal guardian evidence given admitted twelve-year-olds and the minority-annulment window. It is **Pantas’s chosen period**, not a statutory retention requirement. Document necessity and restrict access. [Civil Code Arts. 1390–1391](https://www.wipo.int/wipolex/en/legislation/details/3452); [DPA §11(e)](https://privacy.gov.ph/data-privacy-act/).

   Two build contradictions remain:

   - Part 2 counts from the **newest guardian response**, including later sharing or withdrawal actions.
   - Purchase attestations live in checkout records that account deletion removes. The batch adds no surviving purchase-evidence archive.

   **Replacement:** “We keep minimal guardian-response evidence while the account exists. After deletion, we normally remove it ten years after the most recent recorded guardian response. Relevant records may remain longer for a documented legal claim.”

   Remove purchase confirmation from this promise unless its preservation is added to the build.

7. **A/D: “Any activity cancels the deletion”; warning sent “to the account’s email address.” — Change.**

   Part 2 measures Firebase sign-in/token-refresh activity and emails **verified** addresses. Offline study does not necessarily reach that measurement.

   **Replacement:** “We identify inactivity from server-observed sign-in and session activity. Open Pantas while connected to keep the account active. We normally send a warning about 30 days beforehand if the account has a verified email address.”

8. **A/D: “The stored report does not contain … your IP address”; “We tell Google not to store its connection log entries.” — Change.**

   Error text can contain identifiers, including IP addresses. The planned exclusion affects one logging sink, not every possible Google record or destination. [Google logging exclusions](https://docs.cloud.google.com/logging/docs/reference/v2/rest/v2/exclusions).

   **Replacement:** “Reports have no dedicated account-ID or IP-address field. We filter common identifiers, but error text may still contain personal information. We exclude this function’s request logs from our default log storage. Google processes connection information to deliver requests.”

   Keep broader assurances only after checking every applicable logging destination.

9. **C: “Ordinary technical data”; “The fields reveal nothing about age or ability”; “This closes … risk 7.” — Change.**

   The assessment still understates authenticated collection and unrestricted error-text risks. It also lacks a reasoned comparison with fixed error codes, sampling, and reduced collection. A switch improves balancing; it does not establish necessity. [Circular 2023-07 §§4–8](https://privacy.gov.ph/wp-content/uploads/2024/01/NPC-Circular-No.-2023-07_Guidelines-on-Legitimate-Interest_13-December-2023.pdf).

   **Replacement assessment:** “Assess the authenticated request, temporary account-derived rate-limit key, connection handling, and stored report together. Evaluate reporting frequency, children’s expectations, sensitive-data leakage, and less intrusive alternatives. Record why the remaining fields are necessary.”

   Section 12(f) remains a defensible basis for minimized ordinary telemetry. It cannot authorize sensitive information accidentally embedded in errors.

10. **C/A/D: “You can turn them off”; emailed objection handled by “pointing to the switch.” — Change.**

    The switch is local. It does not necessarily stop collection on another device or address existing identifiable reports.

    **Replacement:** “The switch stops future reports from this browser or device. Repeat this on other devices. Email dpo@pantas.study for help or requests concerning reports already collected.”

    An emailed objection requires actual assessment and assistance, not automatic dismissal. [DPA IRR §34(b)](https://privacy.gov.ph/implementing-rules-regulations-data-privacy-act-2012/).

11. **A/D: “14 months after your last activity”; backups “can take longer”; messages “no longer than needed.” — Change.**

    These remain incomplete or unverified retention disclosures. Analytics distinguishes event expiry, identifier renewal, and aggregated reports. The batch does not verify these settings. [Analytics retention](https://support.google.com/analytics/answer/7667196?hl=en-au).

    **Replacement instructions:** publish the verified Analytics setting and cleanup cycle; identify any longer-lived identifiable exports; give provider recovery-copy limits. Firebase’s applicable terms provide a maximum deletion period of 180 days following a qualifying deletion instruction, not a universal backup rule. [Firebase deletion terms §6](https://firebase.google.com/terms/data-processing-terms).

    For messages: “Routine correspondence is deleted [chosen, implemented period] after closure. Necessary dispute records follow a documented legal hold.” Do not publish the placeholder.

12. **D: “This choice is made by our software”; A has no equivalent explanation. — Expand.**

    Naming automation alone does not fully explain its logic and consequences. [IRR §34(a)(2)(f)](https://privacy.gov.ph/implementing-rules-regulations-data-privacy-act-2012/).

    **Replacement for both notices:** “Software uses your answers and study timing to choose review dates and show study guidance. These suggestions affect what Pantas recommends next. They do not determine official exam eligibility or results.”

    Add other material profiling actually used, including study-profile labels. No proprietary formula disclosure is necessary.

13. **D: “We tell you … before a material change”; A omits policy changes. — Change.**

    Notice changes and renewed consent are different requirements. Continued use cannot replace consent where processing changes substantially. [Circular 2023-04 §§4(B), 21](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf).

    **Replacement:** “We notify you before changing the processing described here. If a change requires new permission, we ask before starting it.”

    Give children the notice directly in suitable language; telling only the guardian is insufficient.

14. **B: “Complaints. Send purchase complaints…”; missing merchant contact details. — Expand the mechanism; complete homepage disclosures.**

    Email can serve as the complaint channel. The business must actually operate an accessible, efficient process. Seven unresolved calendar days exhaust the statutory internal process. The homepage must show the business identity, physical business address, telephone number, and email. Sales require transaction documentation. [RA 11967 §§23–24](https://lawphil.net/statutes/repacts/ra2023/ra_11967_2023.html).

    **Replacement:** “Send purchase complaints to support@pantas.study with the transaction reference and problem. If unresolved after seven calendar days, our internal complaint process is deemed exhausted.”

    Add the real phone number and complete business address on the homepage. An invoice sentence in the Terms is unnecessary; issuing the required invoice is necessary.

15. **E: “You are responsible for what happens in your account.” — Change.**

    This could shift losses caused by Pantas’s own security failure.

    **Replacement:** “Keep your sign-in details private and tell us promptly about suspected misuse. You are responsible for activity you authorize.”

    Mandatory service and privacy duties remain with Pantas. [Consumer Act Arts. 99, 105–106](https://lawphil.net/statutes/repacts/ra1992/ra_7394_1992.html).

16. **E: “Your scores … are estimates.” — Change.**

    Recorded quiz scores are measured results, not estimates.

    **Replacement:** “Scores show your recorded performance in Pantas. Progress indicators and review dates provide study guidance. They do not predict your official exam result.”

17. **E: “Losses such as … lost income, extra fees … are not losses we could foresee.” — Change.**

    Foreseeability depends on facts. The draft overstates Article 2201 and could undermine an otherwise useful exclusion.

    **Replacement:** “For a good-faith contractual breach, recoverable damages follow Article 2201. Subject to the exceptions below, we exclude indirect or consequential loss, including lost income or opportunities, to the extent Philippine law permits.”

    Put the mandatory-law exceptions before these limitations. [Civil Code Arts. 1170–1174, 2201](https://lawphil.net/statutes/repacts/ra1949/ra_386_1949.html).

18. **E: “Limited to the amount you paid … If you paid nothing … ₱1,000.” — Change.**

    This is not a ₱1,000 floor: someone paying ₱200 receives a ₱200 cap. A corrected cap is **arguable for residual, lawfully limitable claims**, not reliably enforceable across consumer claims. Adhesion alone does not invalidate it, but ₱1,000 is no statutory safe harbor. Carrier valuation cases do not establish a general software-consumer rule.

    **Replacement:**

    > “The following exclusions and cap apply only where Philippine law permits. They do not limit statutory consumer remedies or damages, data privacy rights or compensation, or liability for fraud, bad faith, willful misconduct, gross negligence, death, or personal injury.
    >
    > For other claims arising from an event or related events, our aggregate monetary liability, whether in contract, negligence, or otherwise, is limited to the greater of ₱1,000 or the amount paid to Pantas for the affected account during the 12 months before the first event.”

    Statutory **damages**, not merely refunds and re-performance, must remain outside the cap. Article 106 expressly prohibits reducing covered indemnification. Clear presentation before assent improves the remaining clause’s position; severability cannot validate an illegal restriction. [Consumer Act Arts. 99–106](https://lawphil.net/statutes/repacts/ra1992/ra_7394_1992.html); [Civil Code Arts. 1306, 1377, 1409](https://www.wipo.int/wipolex/en/legislation/details/3452).

19. **E: “South Cotabato … and no other court.” — Remove consumer exclusivity.**

    Written exclusive venue can bind an adhesion-contract subscriber: *Pilipino Telephone v. Tecson*. But *Sweet Lines* permits rejection where the clause practically obstructs claims. Neither establishes automatic validity or invalidity for Pantas. [Tecson](https://lawphil.net/judjuris/juri2004/may2004/gr_156966_2004.html); [Sweet Lines](https://lawphil.net/judjuris/juri1978/may1978/gr_37750_1978.html).

    **Recommendation:** the limited benefit does not justify a consumer venue fight for this business.

    **Replacement:** “Philippine law governs. Consumer proceedings may be brought in venues allowed by applicable law and court rules. For other civil disputes, the parties agree exclusively to the proper courts serving Norala, South Cotabato.”

    Keep regulator access intact. Also correct the notes: small claims generally use ordinary venue rules; they do not universally override written venue agreements. The draft’s carve-out voluntarily preserves broader filing choices. [Rule 4 §4](https://lawphil.net/courts/rules/rc_1-71_civil.html); [2022 small-claims rules, Rule IV §5](https://elibrary.judiciary.gov.ph/assets/pdf/journals/Collation_and_Codification_of_SC_Issuance_DIGITAL.pdf).

The official JAO 24-03 scan was located, but its relevant pages could not be read through the available tools. Its detailed section numbering remains unverified; the merchant, redress, and consumer-remedy conclusions above are independently supported by the verified statutes.

**Five most important changes, in priority order**

1. Establish a lawful basis **before age screening**; local processing and later consent do not close that gap.
2. Obtain specific consent for identifiable study data, including adults; retain separate optional-sharing consent.
3. Correct the cap’s floor and expressly preserve mandatory consumer **damages**.
4. Align guardian authority, surviving evidence, retention clocks, and device controls with the actual build.
5. Complete homepage merchant disclosures, complaint handling, and verified retention disclosures.