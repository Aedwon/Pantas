# Under-13 accounts: legal text draft (Nov 17, 2026)

Status: draft for Aedwon's check. Written by an agent to favor Pantas as far as Philippine law allows. **No lawyer has reviewed it.** Revised Nov 17 after the Codex GPT 6.1 Sol high critique (`docs/workflow/process-improvement.md`, rule 5), with the lead's rulings applied. Items in [BRACKETS] need a decision or a build fact.

Base texts: the live Terms, Privacy Policy and Notice for teens in `lib/features/legal/domain/legal_document.dart` (version 2026-11-11), and the teen guardian copy. Rulings: `docs/superpowers/decisions/2026-11-17-under-13-accounts-log.md` (R1 to R15, Fable 5.2, final).

Defined terms reused from the live texts: "Pantas", "Data Protection Officer", "Terms", "Privacy Policy", "Notice for teens", "Pro". New defined terms: "Child Notice", "child account", "guardian".

---

## 1. Child Notice

Three parts, published together as one document titled "Child Notice": (a) the full legal notice for the guardian; (b) a short child notice, shown to the child before anything is processed; (c) a fuller child-friendly explanation, separate from the guardian notice and linked from (b). Version date: [set at release; also set in the guardian consent record, and in the version strings listed in section 9].

### Layer (a): For parents and guardians

**Who this is for**

This notice is for the parent or guardian who sets up a Pantas account for a child under 13. We call that person the guardian. Your email address is a holder sign-in that holds no study data. Each child has a separate account with no email of its own, linked to your sign-in on our servers. One guardian email may hold up to 5 active children, for example twins or siblings. Support can raise the limit. The child uses the account with a nickname.

If the child is 13 to 17, read the Notice for teens. If you are 18 or older and the account is for you, read the Privacy Policy.

**Who runs Pantas**

Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services, a sole proprietorship. He is the personal information controller and also the Data Protection Officer.

Address: Poblacion, Norala, South Cotabato, Philippines.

Questions about your child's data: dpo@pantas.study
Help or payment problems: support@pantas.study
Telephone: [BUSINESS PHONE: Aedwon to supply or confirm]

**What we collect for a child account**

- Your sign-in details. If you sign in with an email code, we receive your email address. If you sign in with Google, we also receive your name and profile photo. We use your email address to send you the receipt and notices about this account. We do not copy your name or photo into the child's profile.
- An account ID for each child account, which Pantas creates.
- The child's nickname. You choose it. We store it on our servers so we can list brothers and sisters on your sign-in. We do not ask for the child's real name, school, photo, birth date or exact age.
- The link between your sign-in and each child account, and a holder ID. Each child account has no email of its own.
- A label that the account is a child account. This label is information about age.
- Study records: the exam (PSHS-NCE), study settings, answers, results, study times, bookmarked lessons and flagged questions.
- Your consent record, for each child: your two confirmations when you add that child, the date and time, the version of the Terms and of this notice, and the account ID.
- Payments: if you buy PSHS-NCE access, we keep payment references, amounts, payment status, refunds and access dates. Card and wallet details are entered on PayMongo's checkout page. We also record the checkout declaration you tick, with the date, time and Terms version.
- Rate-limit records: counts of requests from a sign-in session or network address, so we can stop abuse and overload. [CONFIRM RETENTION AGAINST THE BUILD BEFORE PUBLISHING. If the build cannot state a period, publish "kept for as short a time as the build allows, no longer than 30 days" only after Aedwon confirms it is true.]
- Messages: emails you send to support@pantas.study or dpo@pantas.study.
- Technical and security records: sign-ins, payment checks and account deletions. Google's servers also process connection details, such as an IP address, to deliver requests.

**What is off for a child account**

- Optional usage sharing (usage analytics). It stays off. The child cannot turn it on.
- Speed and error reports from the web app. They stay off.
- Share cards and hosted Wrapped pages. A child account cannot make a public page.
- Push notifications.
- Study-style labels on share cards.

We do not sell data. We do not show ads. We do not use a child's data for marketing.

**Why we use the data, and our legal basis**

- Running the child account and choosing study guidance: your specific consent as guardian, given at setup (Data Privacy Act, Section 12(a); Section 13(a) for the child-account label and for answers and results, which can relate to education and age). Under Philippine privacy guidance a child cannot give this consent, so you give it.
- Your sign-in details, the account and payment records: we need them to provide the service you asked for and to carry out our contract with you (Section 12(b)).
- Your consent record: your consent and our need to show it later if a claim or complaint arises (Sections 12(a), 12(f) and 13(f)).
- Rate-limit, security and trial records: our legitimate interest in keeping Pantas working, safe and fair (Section 12(f)). We keep each to what we need.
- Accounting records: the law requires them (Section 12(c)).
- Messages to us: we need them to answer you.

Your consent is separate from your acceptance of the Terms. You give each by its own tick. The required consent covers only what a child account needs to work. Optional extras, if we ever offer them for children, will need a separate choice. If you withdraw your consent, we cannot run the account, so we close it.

**How Pantas uses answers to guide study**

Pantas uses answers and study timing to select review dates and suggested practice. These suggestions affect practice inside Pantas. They do not decide official eligibility or exam results. To question how they are used, contact our Data Protection Officer at dpo@pantas.study. [CONFIRM this matches the build.]

**How long we keep data**

- Each child account and its study records: until you delete that child's account. We also delete a child account that has had no sign-in or study activity for 12 months. Each child account is counted on its own. If you close the last child account, we also delete your holder sign-in and your email address, except as the consent-evidence item below says. We normally email you a warning about 30 days before. An account with active paid access does not count as inactive.
- Consent evidence: after the account is deleted, we keep a minimal consent record only while it is necessary to defend a documented claim, and ordinarily no longer than ten years after the account closes. It holds the account ID, a protected code made from your email address, the dates and times, the versions of the documents shown, and the checkout declaration with its payment reference. A protected code can still be linked back to you, so we treat it as personal data. The record holds no nickname and no study records. We review whether we still need it, and keep a specific record longer only for a documented legal hold. [The ten-year ceiling is a Pantas judgment of claim-defense need under the data minimization and retention rules (Data Privacy Act Section 11(e); IRR Section 19, not re-read). It is not a period any statute sets.]
- Payment and accounting records: five years, counted as tax law requires. They may stay longer while a tax matter is unresolved.
- Security records in our database: 730 days after the event.
- Rate-limit records: [CONFIRM against the build; same note as above].
- Messages to us: up to two years after the matter closes.
- Copies in our providers' backups: removed within 180 days of deletion.
- Payment records and consent evidence stay longer than the study account, as stated above.

If the law requires it, we may keep records longer.

**Who receives data, and transfers abroad**

Our servers run in Google's Singapore region. We use these providers, who act for us under their own terms:

- Google (Firebase and Google Cloud): sign-in, our servers and logs.
- Resend: your sign-in codes and the emails we send you.
- PayMongo: web payments.

These providers may process data outside the Philippines. We stay responsible for the data we give them. We may also share data when the law requires it, or to deal with fraud or a legal claim. Pantas does not offer PSHS-NCE on Android this cycle, so app-store providers do not receive child account data.

**If there is a data breach**

When a breach requires notification, we notify the National Privacy Commission, you and your child within the legal deadline. We explain it to your child in language they understand.

**Your rights as guardian**

You can use your child's privacy rights for the child. You can be informed, get a copy of the data, object, ask us to fix wrong details, and ask us to stop using, block or delete the data. You can ask for compensation where the law provides it. You can complain to the National Privacy Commission (privacy.gov.ph).

How to use them:

- Open "For parents" in the account settings. It works for one child at a time. For that child, you can read this notice, get a copy of the data, delete the account, or withdraw permission and close the account. These actions affect that child only.
- For a data copy, a withdrawal, a deletion, or adding a child, we first email a 6-digit code to your email address. You enter it in the child's session.
- If the copy does not work, or you want something else, email dpo@pantas.study. We reply within 15 calendar days. We may ask for information we reasonably need to check who you are.

Withdrawing permission and closing a child's account is free. Study processing stops and the account closes. Limited records remain for the purposes and periods in this notice. Earlier lawful processing stays lawful.

Deleting the account deletes the child's study records from our servers. It keeps only the records the retention section lists. Copies on other devices stay until cleared. Voluntary deletion or withdrawal alone is not a change-of-mind refund. Refunds follow the Terms, and your rights under the law stay.

We issue an electronic receipt or invoice for each purchase.

**If we find a child account without guardian setup**

Pantas is for people 13 and older, and for under-13 children only through a guardian's setup. If we learn that a person under 13 has an account that no guardian set up, we delete it. Deleting it does not need notice, and it gives no refund beyond the Terms.

**Changes to this notice**

We email you, the guardian, before we change the processing described here. If a change needs new consent, we ask before starting it. We also show the change in the app, and we explain it to your child in plain words.

### Layer (b): Short notice for the child (shown before anything is processed)

> Hi. A parent or guardian is setting up Pantas for you.
> Pantas will keep your nickname, your answers and your scores so you can practice.
> Your parent or guardian says yes to this for you. They can say no later.
> Want to know more? Tap "Read more for kids."
>
> [Read more for kids]  [Ask my parent or guardian]

### Layer (c): Read more for kids (fuller child-friendly explanation)

Your parent or guardian set up your Pantas account. Here is what that means.

**What Pantas keeps about you**

- The nickname your parent or guardian picked.
- The questions you answer and your scores.
- Which lessons you saved.
- The days and times you study.

**What Pantas does not keep**

- Your real name.
- Your school.
- Your photo.
- Your birthday.

**Why your parent or guardian says yes**

You are too young to say yes to this by yourself. So your parent or guardian says yes for you. They can change their mind at any time.

**What Pantas does with it**

We use your answers and the times you study to pick what you should practice next. This only helps your practice in Pantas. It does not decide if you pass the real exam. We do not sell your information. We do not show ads.

**Possible risks**

Any app that keeps information can have problems, like someone getting it by mistake. We use safeguards to protect your information. But problems can still happen. If one does, we tell your parent or guardian and we tell you in simple words.

**What is turned off for you**

- We do not collect extra reports about how you use the app.
- You cannot post your results on a public page.
- Pantas does not send you push messages.

**Who can see it**

Your parent or guardian can ask for a copy of your information. They can also close your account. If you have a brother or sister on the same parent account, they can open your account, and you can open theirs. A few companies help us store your information, such as Google. We use safeguards, but problems can happen.

**Your rights**

You and your parent or guardian can ask what we keep. You can ask us to fix it or delete it. You can tell us if something feels wrong. Your parent or guardian can also tell a government office called the National Privacy Commission.

**How long we keep it**

After 12 months without use, we delete your study account, unless your family has paid access that is still running. We keep a few payment and permission records longer.

**If Pantas changes**

If we change what we do with your information, we tell your parent or guardian first. We also tell you in simple words.

**If you have a question**

Ask your parent or guardian. They can write to dpo@pantas.study.

Drafting note: the plain layers target Grade 6, but the spec has no lower age limit. Test with 9 to 12 year olds. Offer a simpler or audio version where needed.

---

## 2. Terms changes

### 2.1 "Use of the app": replace the first paragraph

Replace the paragraph that begins "Pantas is a study tool for exam practice." and ends "as the Notice for teens explains." with:

> Pantas is a study tool for exam practice. You may use it for your own study. You must be 13 or older to hold an account yourself. If you are 13 to 17, a parent or guardian must agree before you continue, as the Notice for teens explains. A child under 13 may use Pantas only on an account that a parent or guardian holds and sets up for the child, as the section "Accounts held for a child under 13" explains. If we learn that a person under 13 has an account that no guardian set up, we may delete it.

The bullet list that follows stays, with these changes. Replace its first two bullets, and replace its third bullet ("use one account for yourself and not share your sign-in"), with:

> • give true information when you set up an account, including your true age or, for a child, the child's true status as under 13;
> • keep your sign-in details private and tell us promptly about suspected misuse. You are responsible for activity you authorize, including a child's use of an account you hold;
> • use one account for yourself, or, as a parent or guardian, hold one account for each child under these Terms, and not share access outside that arrangement;

### 2.2 "Students under 18" (inside "Subscriptions"): replace the whole paragraph

Replace the paragraph that begins "Students under 18." with:

> Students under 18 and PSHS-NCE purchases. If the student is under 18, a parent or guardian must make the purchase. Every PSHS-NCE purchase, whatever the age of the account holder, needs the buyer to tick this box at checkout: "I am 18 or older, I am this student's parent or guardian, and I accept the Terms." Checkout does not work without it. On the web, we record the tick with the date, time and Terms version when checkout starts. By ticking, the buyer confirms those statements, that they accept these Terms as the buyer, and that they are allowed to use the payment method chosen. We rely on that confirmation. If we learn that the box was ticked by someone who is not the student's parent or guardian, or who is under 18, we may cancel the purchase, refund it and end the access.

Also replace the sentence in "Deleting your account" that reads "The same applies if a parent or guardian withdraws permission for an under-18 account, or if we delete an account that has been inactive for 24 months." with:

> The same applies if a parent or guardian withdraws permission for an under-18 account, if a guardian deletes an account held for a child under 13, if we delete a child account that has been inactive for 12 months, or if we delete any other account that has been inactive for 24 months.

### 2.3 New section: "Accounts held for a child under 13"

Place it after "Subscriptions". Heading and body:

> **Accounts held for a child under 13**
>
> Who the contract is with. An account for a child under 13 is held by a parent or guardian. The guardian, not the child, is the party to these Terms. The child uses the account only with the guardian's permission and under the guardian's supervision.
>
> What the guardian confirms. By setting up the account, the guardian confirms and promises that:
>
> • they are 18 or older;
> • they are the child's parent or legal guardian, or otherwise have legal authority over the child to agree to these Terms and to consent to the processing of the child's data;
> • they have read the Terms and the Child Notice; and
> • the information they give is true.
>
> If a statement is false, we may close the account, as stated below.
>
> Supervision and responsibility. The adult accepting these Terms contracts personally and agrees to supervise each child's authorized use, including use by brothers and sisters on the same sign-in. They are responsible for losses legally attributable to their own breach or false statements. This does not transfer Pantas's legal duties or waive the child's rights. The guardian keeps the sign-in details private and does not give them to others.
>
> One child for each account. Each child account is for one child. A guardian may hold up to 5 active child accounts under one email address. Support may allow more. Each child needs a separate account and a separate acceptance of these Terms and the Child Notice. A guardian cannot use one child account for several children. An email address that already holds an adult or teen account with progress cannot also hold child accounts. A guardian who studies for their own exam needs a second email address.
>
> PSHS-NCE only. For this exam cycle, accounts for children under 13 are for PSHS-NCE only. A child account cannot buy or use other exams. We may refuse any other purchase on a child account.
>
> Accounts made without a guardian. If we learn that a person under 13 holds an account that no guardian set up, we may delete it and its data. We may suspend access while we check the guardian's authority, and close an account we find unauthorized. These steps are subject to the rights in the next paragraphs.
>
> Withdrawing and deleting. The guardian may withdraw permission and close a child's account, or delete it, at any time. They use "For parents" in the account settings, the link in the receipt email, or an email to dpo@pantas.study. These actions affect one child's account only. We ask for a code sent to the guardian's email first. Withdrawing is free. When the last child account closes, we also delete the guardian's holder sign-in and email address, except for the consent evidence the Child Notice describes. We may close a child account that has had no activity for 12 months, as the Child Notice explains.
>
> Passes. Each PSHS-NCE pass belongs to one child's account. [PENDING AEDWON: price per child]
>
> Siblings. Children on the same guardian's sign-in can open each other's accounts on a shared device. The guardian accepts this and supervises it.
>
> Refunds. Refunds for a child account follow the standard refund policy in "Subscriptions". [PENDING AEDWON DECISION 3] Voluntary deletion or withdrawal alone does not create a change-of-mind refund. Statutory refunds, restitution and compensation remain available. We state this at checkout. We issue an electronic receipt or invoice for each purchase.
>
> Limits of responsibility. The section "Limits of responsibility" applies to the guardian and to the child account, as far as Philippine law allows. It does not limit rights the law gives the guardian or the child, including data privacy rights, and it does not limit liability for fraud, bad faith, willful misconduct or gross negligence.
>
> The child is not a party. Nothing in these Terms makes the child a contracting party.

Drafting note, not for publication: the Civil Code treats a minor's contract as voidable and limits what a minor must return (Arts. 1327, 1390, 1399; Art. 1489 on necessaries; see sources). Making the adult the party avoids that exposure. Codex warned that a child posing as a guardian cannot create an adult party, and that adult duties cannot override incapacity rules or Pantas's privacy duties. The clauses above are limited to the adult's own breach and false statements for that reason.

---

## 3. Privacy Policy changes

### 3.1 "Who this is for": replace

> This policy is for people aged 18 and older. If you are 13 to 17, read the Notice for teens instead. If a parent or guardian holds an account for a child under 13, read the Child Notice.

### 3.2 "Why we ask your age": replace the sentence beginning "Based on the age you enter" through "...until support clears it."

> Based on the age you enter, Pantas asks for your parent or guardian's consent if you are 13 to 17. If you are under 13, Pantas opens a screen that asks a parent or guardian to set up the account, as the Child Notice explains. Before child setup, we process the adult's sign-in information and necessary connection and security data. We do not upload the child's age, nickname or study records before guardian consent. [VERIFY request sequence in build] We do not save the age you enter. Your device keeps your age group and the version of the age check notice. If you are under 13, it keeps only that the guardian screen applies, so Pantas stays on that screen on this device until a guardian sets up the account.

Replace the "Age check" bullet in "Why we may use your data" with:

> • Age check: your specific permission, given at the age step (Data Privacy Act, Section 13(a)). We use your age only on your device without saving it. The device keeps only your age group and the version of the age check notice, or, if you are under 13, a marker that sends the device to the guardian screen. For a child account, the guardian's consent covers the child-account label our servers keep.

The age-check basis stays as the live texts state it. Aedwon kept the current age-step flow on Nov 11 (option A in the minor-label research). See the residual risk in section 8. The identical under-13 sentence appears in the Notice for teens ("Why we ask your age" and the age check bullet). Make the same two replacements there.

Add to "Who this is for" in the Notice for teens: "If the account is for a child under 13, read the Child Notice."

---

## 4. Consent wording at guardian setup

Two separate ticks. Neither is pre-ticked. The setup button stays off until both are ticked. Each tick has its own link. Each is under 40 words.

**Tick 1** (31 words):
> I am 18 or older and I am the parent or guardian with authority over this child. I accept the [Terms] for myself and for my child's use of Pantas.

**Tick 2** (30 words):
> I consent to Pantas using my child's data as the [Child Notice] describes. I understand I can withdraw this consent at any time in "For parents."

Both ticks are given for each child, every time a child is added. Wording is unchanged. Records kept at acceptance (server only, R7), per child: the holder ID, the guardian-to-child link, both ticks, the exact text version of each, the date and time, the Terms version, the Child Notice version, and the account ID. Separate acceptance and consent improve clarity. The required consent covers only necessary child-account processing. Unrelated optional purposes need separate choices. Two ticks are good practice, not a formula the Circular requires (Circular 2023-04 Sections 7(C) and 8, as Codex read them; not re-read here).

---

## 5. Checkout declaration (every PSHS-NCE purchase)

> I am 18 or older, I am this student's parent or guardian, and I accept the Terms.

Keeps the required phrase "and I accept the Terms". Replaces "I am the parent or guardian and accept the Terms."

---

## 6. Guardian receipt email (sent by the product)

Subject: `Pantas account for {nickname}`

> Hi,
>
> You set up a Pantas account for {nickname} on {date}. You accepted the Terms and agreed to the Child Notice (version {notice_version}). If you want to delete {nickname}'s account and data, use the button below. You can also do this in the app under "For parents." We send one email for each child.
>
> [Delete account]({delete_link})

Follows rule 8 (plain label, three short sentences, one button, no sign-off). The product sends it itself, so rule 6 (self-test) does not apply. The delete link needs a confirmation step so a forwarded email cannot delete by accident. [BUILD NOTE]

---

## 7. Screen text

In-app voice: short, friendly, plain.

**Under-13 fork** (shown after the age step when the answer is under 13)

- Title: "Ask a parent or guardian to set up Pantas for you"
- Body: "Pantas needs a parent or guardian to set up your account. They sign in with their own email. Then you can study with a nickname."
- Primary button: "I'm the Parent or Guardian"
- Link: "What a parent or guardian agrees to" (opens the Child Notice)

No "go back" action on this screen. The device stays here (R1).

**Guardian setup, after sign-in**

- Title: "Set up Pantas for your child"
- Button: "Set Up Account" (off until both ticks are on)

**Nickname step** (the normal onboarding name step, after setup and the short child notice; lead ruling Nov 17)

- Field label: "Child's nickname"
- Help under the field: "Not a real name. Pick a nickname your child will recognize."

**Email already used** (setup refuses an email that holds an adult or teen account with progress)

- "This email already has a Pantas account. Use another email." (spec wording; "Set Up Account" stays off until the email changes)

**Switch child** (Settings; lists children on this guardian's sign-in by nickname, no code needed)

- Row: "Switch Child"
- Title: "Who is studying?"
- Each row: the nickname
- Last row: "Add a Child"
- Help: "Brothers and sisters on this account can open each other's accounts."

**Add a child**

- Title: "Add a child"
- Body: "You can have up to 5 children on this email. Each child gets their own account and their own two confirmations."
- Button: "Continue" (asks for the code, then the setup screen)
- If the limit is reached: "You have reached 5 children on this email. Email support@pantas.study if you need more."

**Guardian code gate** (adding a child, data copy, withdraw, delete)

- Title: "Enter your code"
- Body: "We sent a 6-digit code to {masked_email}. Enter it to continue."
- Field label: "6-digit code"
- Button: "Confirm"
- Wrong code: "That code is not right. Check it and try again."
- Resend: "Send a New Code"
- Resend confirmation: "We sent a new code."

**Last child closed** (shown before the final withdraw or delete)

- "This is your last child on this email. We will also delete your sign-in and email address from Pantas."


**Adult-account prompt** (when an adult account picks or switches to PSHS-NCE)

- Title: "Is this for a child under 13?"
- Body: "A parent or guardian sets up PSHS-NCE accounts for children under 13."
- Buttons: "Yes" and "No" (dialog pair)

**Settings entry**

- "For parents" (for the child now open; "Switch Child" changes which child) with rows "Read the Child Notice", "Get a copy of your child's data", "Withdraw permission and close account", "Delete this account".
- Text under "Withdraw permission and close account": "This is free. Study processing stops and the account closes. Limited records remain for the purposes and periods in the Child Notice. Earlier lawful processing remains lawful."
- Spec note: the For parents entry gains this withdraw control.
- One line in settings: "This account is managed by a parent or guardian."

---

## 8. Open legal risks

- **No lawyer has reviewed any of this.** Every clause rests on agent reading of statutes and NPC guidance. A Codex critique is required next, and a Philippine lawyer is the real fix.
- **Guardians are self-declared.** We do not check ID or relationship. A child can tick both boxes. The text puts responsibility on the declarant and lets us delete, but an NPC complaint could still say consent was not valid.
- **Self-declared age.** An under-13 child can enter an adult age and make a normal adult account. NPC Advisory 2024-03 FAQ says self-declaration is not forbidden but may be weak for high-risk processing. R11 accepts this; the Terms say we delete such accounts when found.
- **Age check basis (not changed).** The live texts rely on the user's own permission (Section 13(a)) at the age step, and on Section 13(f) for the age-group record. NPC Advisory Opinion 2017-049 says a minor cannot give DPA consent, and later guardian consent cannot cure earlier processing. Codex rated this high and advised asking the guardian before the age step. Aedwon kept the flow on Nov 11 (option A). The risk stays open and is carried in the impact assessment.
- **Sensitive data.** The child-account label is information about age (Section 3(l)(1)), so it needs valid prior consent. A guardian's consent is the best route, but no NPC ruling decides this exact case.
- **Contract with a guardian for a child's use.** We assume the guardian can bind themselves. The "guardian stays bound" clause may be read narrowly. Consumer rules (RA 7394) may also limit the waivers and caps; they are not confirmed here.
- **Consent evidence period.** A regulator could call a ten-year ceiling too long for a record about a child. It is a necessity judgment, not a statutory period, and the protected code of the guardian email may still count as personal data.
- **12-month inactivity deletion is not built yet.** The notice promises it. It must exist before November 2027.
- **Official NPC texts could not be fetched by me.** The NPC site blocked automated reads. Codex reports reading them; section numbers here come from Codex, earlier research and summaries. Recheck before publishing.
- **Sibling access and shared devices.** A sibling can open a sibling's account with no gate. Accepted for low-risk data under one guardian. A guardian could object if a child sees a sibling's results.
- **Guardian cannot cure impersonation.** A child posing as a guardian creates no adult party. The Terms limit the guardian's liability to their own breach and false statements.
- **E-commerce disclosures.** RA 11967 Section 23 (as Codex cites it; not read) asks direct sellers for business contact details and sales receipts or invoices. The telephone number is a placeholder, and the receipt or invoice must exist in the build.
- **NPC registration and the signed impact assessment** are Aedwon's decision 1. Without them, selling carries extra risk.
- **Changes to what we collect need an email before they take effect** once the app is public (rule 9). The Child Notice change clause assumes that email.

---

## 9. Items to sync before publishing

Every place below must carry the new text or version, and the old accepted texts must be kept as evidence.

- Checkout declaration: the live string "I am the parent or guardian and accept the Terms." appears in the Terms ("Students under 18"), the Notice for teens ("Payments for minors"), the checkout screen, the server checkout check and the consent record. Change all to: "I am 18 or older, I am this student's parent or guardian, and I accept the Terms."
- Document versions: `guardianDocumentVersions` (privacy, terms, teens) and the matching map in the guardian consent function must change together. Live values mix 2026-11-11 (document dates) and 2026-11-12 (consent versions). Add a `child` version. Set all to one real publish date.
- The guardian notice wording version string in the guardian copy file.
- The "updated" date on the Terms, Privacy Policy and Notice for teens.
- The setup tick text versions and the Child Notice version stored in the consent record.
- The receipt email's notice version field.
- Setup screens, the per-child receipt email template and the code-gate email are new text. Keep each version with the consent record.
- The consent record now carries the holder ID and the guardian-to-child link: update the stored field list and the retention text together.
- The per-child price: [PENDING AEDWON: price per child]. Publish no figure until he decides.
- The business phone number, in every place the live texts list contact details.

---

## Sources

Checked directly (official or primary text read in this session):

- RA 10173, Data Privacy Act: Sections 3(l)(1) age as sensitive information, 11(e) retention, 12(a) consent, 13(a) prior specific consent, 16 data subject rights. https://lawphil.net/statutes/repacts/ra2012/ra_10173_2012.html

Existence and date confirmed through search results only. **Official text could not be read** (privacy.gov.ph returned HTTP 403 to automated fetch, so quoted provisions below are unconfirmed):

- NPC Circular 2023-04, Guidelines on Consent (Nov 7, 2023). https://privacy.gov.ph/wp-content/uploads/2023/11/NPC-Circular-No.-2023-04_Guidelines-on-Consent_07Nov2023.pdf. The bar on bundled consent and the rules on specific consent and withdrawal are unconfirmed at the official text. The Fable ruling (R2) says to check it. Do that before release.
- NPC Advisory 2024-03, Guidelines on Child-Oriented Transparency (Dec 17, 2024). https://privacy.gov.ph/wp-content/uploads/2024/12/Advisory-2024.12.17-Guidelines-on-Child-Oriented-Transparency-w-SGD.pdf. Search results and law firm notes confirm layered, age-appropriate notices and a child-focused impact assessment under Section 2(A). The FAQ at https://privacy.gov.ph/wp-content/uploads/2024/12/FAQs-Advisory-on-Guidelines-on-Child-Oriented-Transparency.pdf is not read directly.
- NPC Advisory Opinion 2017-049 (minors cannot give consent under the Act). https://privacy.gov.ph/wp-content/uploads/2022/01/NPC_AdvisoryOpinionNo._2017-049.pdf. Taken from `docs/legal/research/2026-11-11-minor-label-lawful-basis.md`. Not re-read.
- DPA Implementing Rules and Regulations. https://privacy.gov.ph/implementing-rules-regulations-data-privacy-act-2012/. Not re-read.

Not confirmed from text:

- Civil Code (RA 386): Arts. 1327 (minors cannot consent), 1390 (voidable contracts), 1391 (four-year period), 1399 (an incapacitated party restores only what benefited them), 1489 (necessaries sold to a minor), 1144 (ten-year period for written contracts). The lawphil page was fetched but only the first part loaded. Article numbers are from memory and general summaries.
- RA 7394, Consumer Act: not read. Applicability to waivers and liability caps is unconfirmed.
- RA 6809 (age of majority 18), cited in the earlier research file.
- NPC Advisory 2024-02 (Section 13(f) legal claims), cited in the earlier research file. Not re-read.
