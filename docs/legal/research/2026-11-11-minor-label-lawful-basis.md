# May the server store the "minor" label before guardian consent?

Legal research, Nov 11, 2026. Codex GPT 6.1 Sol High via codex-pick, read-only, at Aedwon's request ("for the research use a codex 6.1 Sol agent. research how other apps navigate this as well"). Not legal advice. Decision, Nov 11: Aedwon kept the current flow (option A); see the launch log.

**Pantas cannot safely describe the current flow as lawful on guardian consent alone.** An account-linked `minor` label very likely remains sensitive age information, even without exact age. Future consent cannot authorize an earlier write, especially when consent never arrives.

However, Philippine law does **not** categorically require guardian consent before every age check. Another Section 13 exception could apply. Section 13(f), concerning legal claims, gives Pantas a credible but untested argument.

**My recommendation is option D:** obtain authorization before processing a child’s age, use a genuinely generic setup invitation beforehand, and store the age group after authorization. Adults authorize their own checks. Checkout must never treat missing age information as proof of adulthood.

The smallest **server-side mitigation** is option B plus a checkout safeguard that works without the label. That alone does not resolve the local age check or an invitation that itself reveals minority.

**Confidence:** high on the legal framework, moderate on its application here. I am not a lawyer. A Philippine lawyer’s assessment of Section 13(f) could justify retaining more of the current flow.

---

**What the repository actually establishes**

I first read `AGENTS.md` and `WORKFLOW.md` through `git show origin/main:<path>`. The policy revision was `f406507f7`.

This checkout’s application source is older than the relevant work. I therefore also inspected the privacy branch and its merged source at `origin/main`, without switching branches.

The important findings are:

| Finding | Consequence for this question |
|---|---|
| The current age step asks for age in full years. It computes the group locally and does not send exact age. | This substantially reduces collection, but does not establish a lawful basis by itself. |
| Sending the guardian link writes `ageGroup: 'minor'`, request metadata, and the age-notice version when supplied. | The server records minority before guardian approval. |
| Cleanup replaces expired or declined requests with the age group alone. | **The notice version does not survive that cleanup.** |
| Checkout requires the guardian attestation only when the server finds `ageGroup == 'minor'`. | Removing the label alone would weaken the existing checkout safeguard. Missing records currently bypass this particular requirement. |
| Guardian responses are separately preserved as evidence. | Response evidence and an operational age classification need separate justification. |
| The teen notice identifies guardian consent as the basis for the server age-group record. | That explanation does not cover the pre-consent period or requests never approved. |

Sources: [guardian writes, responses, and cleanup](https://github.com/Aedwon/Pantas/blob/f406507f74b7bd7b6d1f51a857b586a4920ad6b6/functions/src/guardianConsent.ts), [checkout enforcement](https://github.com/Aedwon/Pantas/blob/f406507f74b7bd7b6d1f51a857b586a4920ad6b6/functions/src/paymongoCheckout.ts), and [current in-app legal texts](https://github.com/Aedwon/Pantas/blob/f406507f74b7bd7b6d1f51a857b586a4920ad6b6/lib/features/legal/domain/legal_document.dart).

The November 10 log explains why the label survives cleanup: deleting it let checkout proceed without the guardian box. The November 11 entry records the critique about prior guardian consent. It also distinguishes the merged privacy batch from the older production release. [Launch decision log](https://github.com/Aedwon/Pantas/blob/f406507f74b7bd7b6d1f51a857b586a4920ad6b6/docs/superpowers/decisions/2026-10-19-pwa-launch-log.md).

I treated `docs/PRIVACY.md`, the May RA 10173 plan and notes, and earlier legal drafts as historical context. The November texts and later decisions supersede relevant older descriptions.

**Philippine law requires a lawful basis, not consent in every case.**

RA 10173 makes the following distinctions:

| Provision | Rule relevant to Pantas |
|---|---|
| **Sections 3(g), 3(j)** | Identifiable account information is personal information. Collection, computation, storage, and use can constitute processing. |
| **Section 3(l)(1)** | Information about age is sensitive personal information. The wording is not limited to birth dates or exact ages. |
| **Section 12** | Ordinary information can rely on consent, contract, legal obligation, vital interests, emergency/public-authority grounds, or legitimate interest. |
| **Section 13** | Sensitive information requires its own exception: prior specific consent; qualifying law or regulation; specified life/health circumstances; qualifying organizational purposes; medical treatment; or legal claims/public-authority grounds. |
| **Section 11** | Purpose, proportionality, accuracy, and retention requirements still apply. |

[RA 10173, Sections 3, 11–13](https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html).

**My interpretation:** an identifiable `minor` label is very likely information about age. I found no NPC ruling expressly deciding this exact binary field. Calling it `guardianRequired` would not change that interpretation if only minors receive it.

The IRR reinforces the distinction. **Section 22(a)** requires consent before sensitive processing when consent supplies the basis. **Sections 18–19** require necessary, proportionate processing and justified retention. **Section 21’s** ordinary-information criteria cannot simply replace Section 22. [DPA IRR](https://privacy.gov.ph/implementing-rules-regulations-data-privacy-act-2012/).

Consequently:

- Keeping exact age off the server is good minimization.
- Keeping only one bit does not make identifiable information anonymous.
- A notice version demonstrates what wording applied. It does not demonstrate consent.
- “We need it for checkout” explains the purpose, but does not establish a Section 13 exception.

**Legitimate interest alone does not solve the age-data issue.**

Pantas has a reasonable protective objective: preventing minors from purchasing without an adult’s agreement. Nevertheless, Section 12(f) is not an independent basis for sensitive age information. The NPC’s legitimate-interest rules require purpose, necessity, and balancing assessments for processing within their scope. [NPC Circular 2023-07, especially Section 3(B)](https://privacy.gov.ph/wp-content/uploads/2024/01/NPC-Circular-No.-2023-07_Guidelines-on-Legitimate-Interest_13-December-2023.pdf).

A minimal invitation to the adult contact supplied by a student might have a legitimate-interest justification. That does not automatically authorize the associated disclosure that an identifiable account belongs to a minor.

**NPC guidance supports age assurance, while preserving the lawful-basis requirement.**

NPC **Advisory 2024-03, Section 2(B)(1)** expressly contemplates mechanisms that determine users’ age ranges. It requires a lawful basis and compliance with privacy principles.

Its **Section 2(A)** addresses child privacy impact assessments. **Section 2(A)(12)** makes parental involvement depend on context and risk. **Section 3** requires suitable notices for children. [Signed Advisory 2024-03](https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf).

The NPC’s accompanying FAQ is particularly relevant:

- **Question 6:** establishing a specific digital-consent age requires legislation.
- **Question 13:** the advisory’s parental-involvement factor does not itself establish mandatory parental consent for every activity.
- **Questions 14–15:** controllers choose suitable age-assurance methods; self-declaration is not expressly prohibited, though potentially inadequate for high-risk processing.

[NPC child-transparency FAQ](https://privacy.gov.ph/wp-content/uploads/2024/12/FAQs-Advisory-on-Guidelines-on-Child-Oriented-Transparency.pdf).

The NPC also called for effective, privacy-preserving age assurance in its **September 23, 2026 public advisory**. That supports the protective purpose of screening, without creating a blanket sensitive-data exception. [NPC public advisory](https://privacy.gov.ph/public-advisory-npc-calls-on-digital-platforms-to-ensure-compliance/).

**The student’s own permission remains a material weakness.**

In **Advisory Opinion 2017-049, page 3**, concerning a teacher searching a minor’s phone, the NPC states that a minor cannot validly provide DPA consent. It nevertheless recognizes alternative lawful grounds. **Advisory Opinion 2019-046** repeats that position in a trafficking-related context. [2017-049](https://privacy.gov.ph/wp-content/uploads/2022/01/NPC_AdvisoryOpinionNo._2017-049.pdf), [2019 compendium, printed page 241](https://privacy.gov.ph/wp-content/uploads/2023/05/2019-Compendium_rev-2-Single-1.pdf).

These opinions concern different facts from a minimal age screen. Their broad language still makes reliance on a teen’s own click uncertain. The later transparency guidance recognizes evolving capacities, but does not clearly establish a teen-consent exception for this screen.

NPC **Circular 2023-04**, particularly **Sections 5(C), 8–12, 13, and 19**, addresses alternative lawful criteria, specific consent, representatives, withdrawal, and contracts involving sensitive information. It does not allow later consent to repair earlier processing that required prior authorization. [Guidelines on Consent](https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf).

Therefore, moving the label onto the device reduces exposure, but does not automatically remove the legal question. Pantas still determines the purpose and operation of its local age check.

**Section 13(f) is Pantas’s strongest argument for keeping the current label without consent.**

This exception deserves serious consideration.

NPC **Advisory 2024-02, Sections 2, 4, 5(A)–(B), and 7**, permits necessary processing for legal claims before proceedings exist. An already-filed lawsuit is unnecessary. The NPC reaffirmed preparatory processing in **Advisory Opinion 2026-002, page 4**. [Advisory 2024-02](https://privacy.gov.ph/wp-content/uploads/2024/08/NPC-Advisory-No.-2024-02-Personal-Data-Processing-Based-on-Section-13-f.pdf), [Opinion 2026-002](https://privacy.gov.ph/wp-content/uploads/2026/05/NPC-Advisory-Opinion-No-2026-002_Redacted-1.pdf).

Pantas could argue that a minimal age declaration and authorization history protect its position concerning contractual capacity and disputed permission. This is a credible interpretation.

The difficulty is the label’s actual function. After expiry, it is an operational checkout condition, rather than evidence of a completed consent or purchase. A universal purchaser declaration or an account-authorization gate offers an apparent alternative.

**My assessment:** Section 13(f) could justify narrowly defined evidence. The sources do not clearly establish that it justifies this continuing classification for every unanswered request. A blanket statement that future litigation is possible would be insufficient reasoning.

A lawyer could change this assessment by establishing why this particular processing is necessary for defined legal claims. I would not declare option A lawful merely by changing the notice to cite Section 13(f).

**Other Philippine laws explain the safeguards, but do not clearly authorize this database field.**

| Law | Relevance and limit |
|---|---|
| **RA 6809, Sections 1 and 3** | Majority generally begins at 18. Emancipation terminates parental authority, subject to legal exceptions. [Text](https://lawphil.net/statutes/repacts/ra1989/ra_6809_1989.html) |
| **Civil Code, Articles 1327, 1390–1391** | Minority affects contractual consent. An incapacity-based contract is generally voidable, not automatically void. Article 1391 supplies the relevant annulment period. These rules support adult purchase authorization, but do not expressly require a persistent minor flag. [Text](https://lawphil.net/statutes/repacts/ra1949/ra_386_1949.html) |
| **RA 7610, Sections 2–3(a)** | Establishes child-protection policy and the child definition. It does not create a general exception for online age-data collection. [Text](https://lawphil.net/statutes/repacts/ra1992/ra_7610_1992.html) |
| **RA 11930, Sections 9 and 35** | Contains duties for relevant intermediaries and providers. Section 35 requires anonymous age verification for adult-content providers. That requirement should not be imported as authorization for an exam-prep checkout database. [Text](https://lawphil.net/statutes/repacts/ra2022/ra_11930_2022.html) |

I found no provision in these laws expressly requiring Pantas to retain this label after refusal or expiry. Their protective objectives do not, by themselves, settle Section 13(b)’s requirements.

**Published app practice commonly identifies age before formal parental confirmation.**

These examples establish practice, not Philippine legal permission. Public documents seldom disclose exact database fields or what survives refusal.

| Service | Published practice | What it establishes |
|---|---|---|
| **Duolingo** | Schools guidance says missing birth dates receive the strongest privacy settings. Users below the applicable digital-consent age supply a parent’s email. [Guidance](https://duolingoschools.zendesk.com/hc/en-us/articles/6830532051085-Is-Duolingo-compliant-with-my-school-or-district-s-privacy-policies) | Protective defaults and age-based routing. It does not establish indefinite pre-consent label retention. |
| **Quizlet** | The younger user creates an account, then Quizlet emails the parent for confirmation. Certain features remain restricted pending confirmation. [FAQ](https://help.quizlet.com/hc/en-us/articles/360029923632-FAQs-about-younger-Quizlet-users) | Direct evidence of account state before parental confirmation. |
| **Khan Academy** | Children under 13 can create provisional accounts. Its published help says unapproved accounts are deleted after seven days. [Help article](https://support.khanacademy.org/hc/en-us/articles/115002742211-Why-was-my-child-s-account-deleted-after-7-days) | A bounded pre-approval period. Seven days is its policy, not a Philippine deadline. |
| **Brainly** | Its policy describes parental authorization and parent-created child accounts through Brainly Parent. [Policy, Section 11](https://brainly.com/pages/privacy_policy) | A parent-led alternative. No disclosed equivalent of Pantas’s surviving label. |
| **Google account age gate** | Existing accounts identified as potentially underage receive 14 days to establish supervision or verify age. Disabling and eventual deletion follow. [Account process](https://support.google.com/accounts/answer/1333913?hl=en) | Direct evidence that an account-specific age concern persists before supervision is established. |
| **Google Family Link** | Separately supports parent-led creation of child accounts. [Creation process](https://support.google.com/families/answer/7103338?hl=en) | Parent-led new-account creation differs from handling an existing underage account. |
| **Apple** | Parents ordinarily create child accounts. Its instructions collect the child’s birthday during setup. [Instructions](https://support.apple.com/en-us/102617) | Age-based setup, but no published proof concerning abandoned pre-consent storage. |
| **Roblox** | Its policy requires birth date for under-13 registration and says parent email is optional for account creation. [Policy, Section 2](https://en.help.roblox.com/hc/en-us/articles/115004630823-Roblox-Privacy-and-Cookie-Policy) | Age can be recorded before formal parent linking. This does not prove absence of informal parental permission. |
| **Discord** | Requests birth date and publishes retention of an age signal until deletion or change. [Birthday guidance](https://support.discord.com/hc/en-us/articles/360040724612-Why-is-Discord-asking-for-my-birthday), [retention](https://support.discord.com/hc/en-us/articles/5431812448791-How-long-Discord-keeps-your-information) | Retained age classification. It generally excludes below-minimum-age users rather than accepting parental permission to override that minimum. |
| **Quipper Philippines** | Terms require a parent to enter the agreement for under-18 use. Its notice addresses parental authority and unconsented child information. [Terms](https://ph.quipper.com/terms-and-conditions), [privacy notice](https://ph.quipper.com/privacy-notice) | Relevant Philippine edtech practice, but no disclosed pre-consent age-record design. |
| **GCash Jr.** | The guardian-led process obtains consent before collecting detailed child information. [Instructions](https://help.gcash.com/hc/en-us/articles/63730760036377-How-to-create-a-GCash-Jr-account-as-a-guardian) | An early-consent example from regulated financial onboarding. |

The strongest operational lessons are temporary pending state, protective defaults for unknown ages, and parent-led activation. None of these policies establishes Pantas’s precise post-decline retention as a recognized Philippine safe harbor.

**The foreign rules recognize the same sequencing problem, under different laws.**

**United States, COPPA:** actual knowledge that a general-audience service is collecting personal information from an under-13 child triggers obligations. The FTC permits neutral age screening. Current **16 CFR 312.5(c)(1)** allows limited collection of names or contact information solely to obtain parental consent, with deletion if consent does not arrive within a reasonable time. [FTC FAQ](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions), [current rule](https://www.ecfr.gov/current/title-16/chapter-I/subchapter-C/part-312/section-312.5).

The FTC’s **2026 age-verification enforcement statement, pages 2–3**, additionally offers conditional enforcement discretion for specified operators using age-verification mechanisms before parental consent. Conditions include purpose limitation, necessary retention, deletion, notice, and security. It creates no substantive entitlement. **The Philippines has no equivalent exception established by the sources reviewed.** [FTC statement](https://www.ftc.gov/system/files/ftc_gov/pdf/coppa-age-verification-policy-statement.pdf).

**European Union, GDPR:** **Article 8** governs consent-based information-society services offered directly to children. The threshold is 16, subject to national reductions no lower than 13. It is not a universal parental-consent requirement for every processing basis. [Official GDPR text](https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng).

The EDPB endorses obtaining only an over/under-threshold result where sufficient, while requiring a lawful basis. Age is not automatically GDPR special-category data, unlike its express treatment under Philippine law. [EDPB Statement 1/2025, paragraphs 20 and 23–24](https://www.edpb.europa.eu/system/files/documents/2025-04/edpb_statement_20250211ageassurance_v1-2_en.pdf).

**United Kingdom, Children’s Code:** **Standard 3** allows proportionate age assurance or applying children’s protections to all users. **Standard 8** requires minimal collection and retention. This supports an unknown-age protective default as a design option. It supplies no Philippine processing permission. [Standard 3](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/3-age-appropriate-application/), [Standard 8](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/8-data-minimisation/).

**Pantas’s options have different legal and product costs.**

These are relative research assessments, not quantified legal-risk scores.

| Option | Legal assessment | Product cost | Student experience |
|---|---|---|---|
| **A. Keep the current flow** | Protective purpose and strong minimization help. Current consent explanation leaves a gap. Section 13(f) offers an arguable defense, with unresolved necessity and retention questions. | Lowest engineering cost; continued legal uncertainty. | Unchanged. |
| **B. Keep age group locally until approval** | Removes the explicit pre-consent server classification. Does not automatically resolve local processing or an age-revealing guardian request. | Small server change plus checkout and request redesign. | Age entry can remain; checkout needs another safeguard. |
| **C. Guardian consent before the age check** | Provides a clearer Section 13(a) route when valid authorization genuinely comes first. Philippine law does not expressly mandate this sequence for every possible lawful basis. | Greater onboarding friction if applied indiscriminately. | A guardian acts earlier. Requiring guardians for competent adults would be unnecessary. |
| **D. Generic setup invitation, authorization before child-age processing, and checkout protection independent of missing age** | Clearest practical consent-based route. Avoids depending on an unsettled screening exception. | Moderate changes to ordering, pending state, and checkout. Existing links can be reused. | Adults authorize themselves. Represented learners wait for authorization before entering age. |

A purported option B that merely deletes `ageGroup` but retains a minors-only request has not necessarily removed age information. The request itself can reveal the same fact.

Likewise, deleting the field while leaving checkout’s current missing-record behavior would create a product regression.

**I recommend D as the lowest-uncertainty option, rather than claiming Philippine law expressly requires it.**

Its essential behavior would be:

1. **Use a genuinely generic setup invitation.** It must support adult and represented learners, without recording minority through another field or minors-only request type.
2. **Obtain authorization before the covered age processing.** Competent adults authorize their own checks. A lawful guardian authorizes the child’s check and necessary age-group retention.
3. **Write the age group after authorization.** Preserve the relevant affirmative action, purposes, date, and notice versions.
4. **Keep consent-dependent processing closed while setup is incomplete.** An expired or declined request must not become an adult account by default.
5. **Make checkout safe without a pre-consent age label.** A universal adult-buyer or authorized-guardian declaration is one fallback. It remains an attestation, not independent proof of identity.
6. **Expire unfinished setup records and retain only justified evidence.** Any surviving refusal, consent, or transaction evidence needs its own purpose and retention assessment. Preserve correction and adulthood routes.

This is legally stronger because valid authorization precedes the sensitive processing for which Pantas relies on consent. It preserves the checkout objective without requiring a persistent, unapproved age classification.

For the narrow server-record problem, **B plus a checkout safeguard is the smallest mitigation**. I cannot honestly call it a complete compliance fix while the local check and implied age disclosure remain unresolved.

A lawyer’s view would matter most on two questions: whether Section 13(f) supports this particular preliminary screening record, and whether a minor can validly authorize this tightly limited local check. A favorable, reasoned answer could support a smaller change than D.

Some NPC PDFs intermittently returned access errors. I cross-checked official indexed text and identified transcriptions where needed. **No authority located directly decides Pantas’s exact binary-label design.** All work remained read-only; no files, deployments, or account data were changed.