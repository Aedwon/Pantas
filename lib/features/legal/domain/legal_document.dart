/// Published versions shown by the guardian confirmation page.
const guardianDocumentVersions = <String, String>{
  'privacy': '2026-11-09',
  'terms': '2026-11-09',
  'teens': '2026-11-09',
};

class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.sections,
  });

  final String id;
  final String title;
  final DateTime updatedAt;
  final List<LegalSection> sections;
}

class LegalSection {
  const LegalSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

final legalDocumentFallbacks = <String, LegalDocument>{
  'privacy': LegalDocument(
    id: 'privacy',
    title: 'Privacy Policy',
    updatedAt: DateTime.utc(2026, 11, 9),
    sections: const [
      LegalSection(
        heading: 'What we collect',
        body: 'Your answers, your plan and your settings, so Pantas can '
            'plan your reviews. With your permission, extra usage reports '
            'can be linked to your account ID.',
      ),
      LegalSection(
        heading: 'What we never do',
        body: "We don't sell your data. We don't show ads.",
      ),
      LegalSection(
        heading: 'Your rights',
        body: 'You can see, correct or delete your data at any time. '
            'Contact our data protection officer from About.',
      ),
    ],
  ),
  'terms': LegalDocument(
    id: 'terms',
    title: 'Terms of Service',
    updatedAt: DateTime.utc(2026, 11, 9),
    sections: const [
      LegalSection(
        heading: 'Use of the app',
        body: 'Pantas is a study tool. It does not guarantee exam '
            'results or replace official exam instructions.',
      ),
      LegalSection(
        heading: 'Subscriptions',
        body: 'For purchases through an app store, paid features depend on '
            'your active store subscription. Manage billing through the '
            'store account used for purchase.\n\nOn the web, you buy prepaid '
            'Pantas Pro access through PayMongo. Weekly, Monthly, and '
            'Yearly plans provide Civil Service Pro access for a set '
            'period. A Season Pass covers the named exam through its '
            'stated exam sitting.\n\nWeb purchases do not renew '
            'automatically. You must choose to buy again.\n\nPrices are '
            'shown in Philippine pesos on the Pro screen and at PayMongo '
            'checkout. Review the selected plan and amount before paying. '
            'The currently approved web payment methods are cards and QR '
            'Ph.\n\nWeekly access lasts seven days. Monthly access lasts one '
            'calendar month. Yearly access lasts one calendar year. '
            'Monthly and Yearly periods end on the corresponding calendar '
            'date at the same time in Philippine time. If that date does '
            'not exist, they end on the last day of that month.\n\nA new '
            'period starts at the recorded payment time or after existing '
            'qualifying Pro access ends. Season Passes end at the end of '
            'the last day of their recorded exam sitting.\n\nPro access is '
            'added after Pantas verifies the payment with PayMongo. '
            'Returning from checkout does not by itself confirm that '
            'access is ready. If you paid and Pro has not appeared, '
            'contact support@pantas.study.\n\nEligible signed-in accounts '
            'can start a seven-day web trial. No payment details are '
            'needed to start it. The trial does not charge you or turn '
            'into a paid plan.\n\nThe trial is limited to one per account '
            'and verified sign-in identity. Prior paid Pro, a '
            'subscription, a pass, or another qualifying grant can make an '
            'account ineligible. Temporary beta Pro alone does not use up '
            'the later trial.\n\nDeleting an account does not entitle you to '
            'another trial or immediately remove its trial-use code. The '
            "teen notice explains the code's storage period.\n\nThere is no "
            'automatic web renewal to cancel. To stop buying Pro, do not '
            'make another purchase. Leaving an unpaid checkout does not '
            'create Pro access.\n\nDeleting your account ends its access and '
            'does not itself request a refund. A web purchase does not '
            'cancel a separate app store subscription. Manage that '
            'subscription through the store.\n\nUnder our voluntary web '
            'refund policy, you may request a full refund for an extra '
            'payment whose access period has not started, such as an '
            'unused duplicate payment, or for a payment that never '
            'unlocked Pro.\n\nWe do not offer partial refunds merely because '
            'you choose not to use the remaining time. Access whose period '
            'has started or has been used is outside this voluntary '
            'policy. Season Pass requests made after the exam date are '
            'also outside the voluntary policy.\n\nThese limits do not '
            'remove any refund, reperformance, price reduction, '
            'compensation, or other remedy required by Philippine law. '
            'They do not exclude a remedy for defective service or a '
            'payment for access Pantas could not provide. Send payment '
            'problems to support@pantas.study.\n\nWhen Pro access for an '
            'exam ends, its Pro-only features stop unless another active '
            'plan or pass covers it. You can keep using Free '
            'features.\n\nEnding Pro does not itself delete your progress. '
            'Pro backup and syncing stop while you do not have Pro. '
            'Necessary server study records can still be collected on '
            'Free. Data remains subject to the storage rules in the '
            'privacy notice.\n\nThe November 9 to 15, 2026 beta is free. Its '
            'temporary beta Pro access ends at midnight at the start of '
            'November 16, Philippine time. Beta access does not start a '
            'paid plan.\n\nFor a student under 18, a parent or guardian '
            'should complete the payment using their own payment method. '
            'Guardian account confirmation does not authorize a charge. '
            "Checkout does not verify the payer's age or guardianship.",
      ),
      LegalSection(
        heading: 'Use of the app and limits of responsibility',
        body: 'Pantas is a study tool. It does not guarantee a passing '
            'result, admission, employment, a license, or any particular '
            'score. Check official exam instructions, eligibility '
            'requirements, schedules, and announcements.\n\nPantas does not '
            'promise uninterrupted or error-free operation. This does not '
            'remove its duty to provide services with the quality and care '
            'required by law.\n\nFor an ordinary contractual breach '
            'committed in good faith, recoverable damages follow '
            'Philippine law, including its rules on causation, proof, and '
            'reasonably foreseeable loss. Pantas does not accept '
            'responsibility for losses that the law does not attribute to '
            'its acts or omissions.\n\nNothing in these terms excludes or '
            'limits responsibility for fraud, bad faith, willful '
            'misconduct, gross negligence, or any liability that cannot '
            'lawfully be excluded or limited. Mandatory service-quality '
            'remedies, privacy rights, statutory damages, and complaint '
            'rights remain available.',
      ),
      LegalSection(
        heading: 'Intellectual property',
        body: 'All content in the app, including lessons, illustrations, '
            'questions, and mock exams, belongs to Pantas and is protected '
            'by copyright. You may use it only for your own study inside '
            'the app. You may not copy, redistribute, sell, scrape, or use '
            'it to train machine-learning systems without our written '
            'permission.',
      ),
    ],
  ),
  'teens': LegalDocument(
    id: 'teens',
    title: 'Notice for teens',
    updatedAt: DateTime.utc(2026, 11, 9),
    sections: const [
      LegalSection(
        heading: 'Who this is for',
        body: 'This notice is for teens ages 13 to 17 and their parents or '
            'guardians. Pantas currently sets 13 as its minimum age.\n\nWe '
            'ask for your birth year to check which age group applies. We '
            'keep the age group, not a saved birth-year record. If your '
            'birth year could mean you are still 17, we ask a guardian to '
            'confirm too. A birth-year check cannot establish your exact '
            "birthday.\n\nThirteen is Pantas's access rule. It is not a "
            'Philippine rule that everyone aged 13 can independently '
            'consent to every use of personal data.',
      ),
      LegalSection(
        heading: 'Who runs Pantas',
        body: 'Pantas is operated by Aerol Dwayne Daños Balayon, trading as '
            'Pantas Online Tutorial Services, a sole proprietorship. He is '
            'also the Data Protection Officer.\n\nBusiness address: '
            'Poblacion, Norala, South Cotabato, Philippines.\n\nFor '
            'questions about your data, email dpo@pantas.study. For '
            'general help or payment problems, email support@pantas.study.',
      ),
      LegalSection(
        heading: 'What we collect',
        body: 'Pantas uses an account ID even before you sign in with '
            'Google. If you sign in with Google, Pantas receives account '
            'details such as your name, email, and profile photo.\n\nWe keep '
            'your study settings, answers, results, and study times. We '
            'also keep lessons you bookmark and questions you flag. We use '
            'these records to run your study sessions, plan reviews, and '
            'show your progress.\n\nFor guardian confirmation, we ask for '
            "your guardian's name and email. We send them an email link. "
            'Our server keeps the request status, dates, a partly hidden '
            'email address, and keyed codes for the email and link. These '
            'codes protect the original values, but they are not '
            'necessarily anonymous.\n\nThe full guardian name and email also '
            'stay on your device so you can resend the request. They are '
            'cleared from that device when Pantas checks a successful '
            'confirmation.\n\nIf someone buys Pro for your account, we keep '
            'payment references, the amount paid, refund records, and '
            "access dates. Web payment details are entered on PayMongo's "
            'checkout page.',
      ),
      LegalSection(
        heading: 'Optional usage sharing',
        body: 'You can choose whether to share extra usage data to help '
            'improve Pantas. This starts off.\n\nIf you turn it on, reports '
            'can include which screens you use, question IDs, your answer '
            'choices, and whether those choices were correct. Reports can '
            'be linked to your account ID. The phone app also supports '
            'error reports. These reports should not be described as '
            'anonymous.\n\nYou can turn sharing off in Settings, About, '
            'under “Help improve Pantas by sharing usage data.” Turning it '
            'off does not stop the study records needed to run the app. '
            'You can also email dpo@pantas.study about reports already '
            'collected.',
      ),
      LegalSection(
        heading: 'Speed and error reports',
        body: 'To find slow screens and errors, the web app sends short '
            'technical reports: how long loading steps took, your browser '
            'type, and error details. These reports do not include your '
            'account ID, your answers, or lesson content. Google keeps them '
            'for 30 days.',
      ),
      LegalSection(
        heading: 'Why a guardian confirms',
        body: 'When Pantas places you in the minor age group, its setup flow '
            'asks a parent or guardian to review the terms and confirm '
            'before you continue.\n\nOpening the email link does not confirm '
            'anything. The adult must check the agreement box and choose '
            "Confirm. They can choose “I Don't Agree” instead.\n\nThe link "
            'works once and expires after seven days. Sending a new link '
            'closes the old one. Keep the link private because someone who '
            'has it can answer the request.\n\nThis is an email confirmation '
            "process. It does not independently prove the responder's age "
            'or legal authority.',
      ),
      LegalSection(
        heading: 'What your guardian can do',
        body: 'Your guardian can confirm or decline the request. '
            'Confirmation does not create a guardian dashboard or give '
            'them a screen showing your results.\n\nYou or your guardian can '
            'contact our Data Protection Officer about your data. We check '
            "a representative's authority before disclosing private "
            'information or acting on their instructions. Your privacy '
            'rights still belong to you.',
      ),
      LegalSection(
        heading: 'Where your data goes',
        body: 'Some records stay in your browser or phone. On the web, '
            'answers and study activity also go to our servers, including '
            'on Free. Pro supports additional backup and syncing across '
            'devices.\n\nPantas uses Google Firebase for account and server '
            'services. Guardian emails go through Resend. Web payments go '
            'through PayMongo. Optional usage reports use Firebase '
            'Analytics, with Crashlytics error reporting on the phone '
            'app. Speed and error reports from the web app go to Google '
            'Cloud logs.\n\nThese providers may process information '
            'outside the Philippines. Pantas remains responsible for the '
            "information it entrusts to service providers. A server's "
            'location does not establish where every provider record or '
            'recovery copy is kept.',
      ),
      LegalSection(
        heading: 'Your rights',
        body: 'You have the right to know how your data is used. You can ask '
            'for a copy, including an electronic copy where the law '
            'allows. You can ask us to fix wrong details. You can object '
            'to processing and ask us to stop using, block, or delete data '
            'when the law allows. You can also complain to the National '
            'Privacy Commission and seek compensation where the law '
            'provides it.\n\nSend these requests to dpo@pantas.study. We '
            'reply within 15 calendar days. Our reply may explain '
            'necessary identity checks, progress, or a justified '
            'limitation. This is a reply commitment, not a promise that '
            'every request will be completed within that period.\n\nData '
            'export is handled through the Data Protection Officer. There '
            'is no working export button in the app.',
      ),
      LegalSection(
        heading: 'Withdrawing permission or deleting data',
        body: 'You can withdraw permission for data uses that rely on '
            "consent.\n\nA guardian can withdraw permission for the child's "
            'account by emailing dpo@pantas.study. A simple message is '
            'enough:\n\nI withdraw my permission for my child to use Pantas. '
            "Please stop the account's consent-based processing.\n\nIf "
            'possible, send it from the email address used for '
            "confirmation. Include the child's sign-in email or account ID "
            'if you know it. If you do not know those details, tell us and '
            'we will help locate the request. You do not need the old '
            'confirmation link, a Pantas login, a paid plan, or a special '
            'form.\n\nWe do not charge for withdrawal. We ask only for '
            'information reasonably needed to locate the account and check '
            'your authority. Do not send an identification document unless '
            'we explain why it is necessary.\n\nAfter reasonably verifying '
            'the request, we stop the processing that depends on the '
            'withdrawn permission without undue delay. Withdrawing '
            'permission for the core study service means we must close the '
            "child's account and remove its study data, unless a separate "
            'lawful reason requires specific records to remain. '
            'Withdrawing only optional usage sharing does not close the '
            'account.\n\nWithdrawal does not undo processing that was lawful '
            'before withdrawal. It does not automatically request a refund '
            'or cancel a separate app store subscription. Any refund or '
            'other remedy required by law remains available.\n\nWe reply '
            'within 15 calendar days. We do not treat that period as '
            'permission to continue consent-based processing '
            'unnecessarily.\n\nThe guardian link cannot undo a confirmation. '
            'There is no separate withdrawal button in the current app. '
            'The email route requires manual action by the owner.\n\nIf you '
            'have finished setup, you can open Settings, Account, and '
            'choose the delete option. For a Google-linked account, the '
            "deletion process removes the account's server study data and "
            'clears local user data on the device making the request. You '
            'may need to sign in again first.\n\nWithout a Google-linked '
            'account, the delete option clears local data only. If you are '
            'waiting for guardian confirmation, or need server records '
            'removed from an anonymous account, contact '
            'dpo@pantas.study.\n\nAccount deletion does not erase every '
            'record held by every service. Trial-use codes, security '
            'records, and records required for tax or a specific legal '
            'claim can have separate storage rules. Copies on other '
            'devices also require separate attention.',
      ),
      LegalSection(
        heading: 'How long we keep data',
        body: 'The following schedule sets when records become due for '
            'deletion. Earlier deletion applies when consent is withdrawn '
            'and no other lawful basis permits keeping them.\n\nExcept for '
            'the tax rule and identified provider rules, these are '
            "Pantas's chosen limits. They are not statutory minimums or "
            'permission to keep unnecessary information.',
      ),
      LegalSection(
        heading: 'Study data and account settings',
        body: 'Keep while the account is being used. Make server study data '
            'due for deletion after 24 consecutive months without '
            'user-initiated app activity, or earlier when the account is '
            'deleted or core consent is withdrawn. This supports study '
            'across exam cycles while limiting abandoned-account storage. '
            'Pro expiry alone does not start deletion. Local copies remain '
            'until cleared through the app, browser, or device; server '
            'deletion cannot erase an offline device.',
      ),
      LegalSection(
        heading: 'Guardian requests and confirmation links',
        body: 'An unanswered request and its contact-linked records become '
            'due for deletion when its seven-day response window ends. '
            'Used, declined, or replaced link records become due for '
            'deletion seven days after that event. These brief periods '
            'allow delivery troubleshooting and response checks. Keep '
            'minimum confirmation evidence while permission is relied on, '
            'then for 730 days after the last processing covered by that '
            'permission, solely to demonstrate and resolve questions about '
            'permission. Do not retain study answers as consent evidence.',
      ),
      LegalSection(
        heading: 'Payment and accounting records',
        body: 'Keep necessary books, invoices, receipts, refund records, and '
            'supporting transaction records for five years, counted from '
            'the day after the applicable return-filing deadline, or from '
            'the actual filing date if filed late, for the taxable year '
            'when the last entry was made in the books. Keep relevant '
            'records longer where a pending tax protest, tax-credit or '
            'refund claim, or another applicable legal duty requires it. '
            'This is the tax-preservation rule, not five years from the '
            'purchase date. Unpaid checkout coordination records become '
            'due for deletion 30 days after the checkout is confirmed '
            'closed or expired, unless needed for a documented payment '
            'dispute.',
      ),
      LegalSection(
        heading: 'Security records',
        body: 'Account and payment audit records become due for deletion 730 '
            'days after the event. This supports investigation of account '
            'access, deletion, payment verification, and recurring abuse '
            'without keeping a permanent activity history. Ordinary '
            'rate-limit counters become due seven days after their '
            'enforcement window ends. Payment-event duplicate-detection '
            'records become due after 30 days. Keep additional incident '
            'evidence only under a documented legal or investigation need.',
      ),
      LegalSection(
        heading: 'Trial-use codes',
        body: 'Keep the keyed identity code and minimum trial-use fact for '
            '730 days from the first trial grant, including after account '
            'deletion. Do not restart that period when the person signs '
            'in, is recognized again, or deletes an account. This provides '
            'a bounded repeat-trial check across exam cycles without '
            'keeping a lifelong identity marker. Delete earlier if the '
            'trial program permanently ends and the code has no remaining '
            'justified purpose.',
      ),
      LegalSection(
        heading: 'Optional usage and error reports',
        body: 'Set identifiable Analytics user and event data to two '
            'calendar months, with identifier renewal on new activity '
            'turned off. Google performs expiry cleanup monthly. '
            'Crashlytics keeps crash data and associated identifiers for '
            '90 days before beginning removal from live and backup '
            'systems. These periods support recent usage analysis and '
            'fault diagnosis. A valid deletion request can require earlier '
            'action. Aggregate reports are outside these limits only where '
            'they no longer identify a person.\n\nThe payment period follows '
            'Tax Code Section 235, as amended by RA 11976 Section 33, and '
            'BIR Revenue Regulations 7-2024, Section 4. The regulation '
            'includes invoices, receipts, vouchers, returns, and other '
            'supporting source documents. Account deletion does not remove '
            'this duty.\n\nA specific legal obligation or the establishment, '
            'exercise, or defense of a legal claim can justify keeping '
            'relevant records longer. This does not justify keeping the '
            'whole account indefinitely.\n\nProvider recovery copies can '
            'take longer to disappear. For example, Firebase states that '
            'authentication data is removed from live and backup systems '
            'within 180 days after the customer initiates user deletion. '
            'That is not a general 180-day storage period for every Pantas '
            'record.',
      ),
      LegalSection(
        heading: 'Why the law allows these uses',
        body: 'Philippine law treats information about age and education as '
            'sensitive personal information. Pantas should therefore treat '
            'age groups and identifiable learning results cautiously, even '
            'where they are not formal school records. Keeping only an age '
            'group or a keyed identity code does not automatically remove '
            'privacy protection.\n\nFor ordinary personal information, '
            'Section 12 provides grounds including contract, legal '
            'obligation, legitimate interest, and consent. Sensitive '
            'information needs an applicable Section 13 exception. A '
            'contract or a legitimate business interest alone does not '
            'supply that exception.',
      ),
      LegalSection(
        heading: 'Age checks',
        body: 'Specific prior consent under Section 13(a) for age '
            'information, with Section 12(a) covering associated ordinary '
            'information. Obtain consent from a lawful representative '
            "where required. Checking age is Pantas's safeguard, not a "
            'general legal obligation requiring this particular birth-year '
            'collection.',
      ),
      LegalSection(
        heading: 'Study records and account operation',
        body: 'Contract under Section 12(b) for ordinary information '
            'necessary to provide the requested service. Specific consent '
            'under Section 13(a) for identifiable education information. '
            'Guardian authorization must cover the necessary study uses '
            'for a minor.',
      ),
      LegalSection(
        heading: 'Optional usage and error reporting',
        body: 'Consent under Section 12(a), plus Section 13(a) where reports '
            'reveal age, answers, or learning performance. Keep this '
            'choice separate from core service permission. Refusal must '
            'not remove Free or purchased study access.',
      ),
      LegalSection(
        heading: 'Payments',
        body: "Contract under Section 12(b) for the adult purchaser's "
            'necessary transaction information. Legal obligation under '
            'Section 12(c) for required accounting records. Section 13(b) '
            'applies only to sensitive information whose processing is '
            'actually authorized by the relevant law or regulation with '
            'its required safeguards. Child-linked study or access '
            'information still needs its own Section 13 basis.',
      ),
      LegalSection(
        heading: 'Trial-use codes',
        body: 'Legitimate interest under Section 12(f) can support a '
            'strictly limited ordinary identity marker used to prevent '
            'repeat trials, subject to a documented assessment. Because a '
            'teen-linked marker may also reveal use of an educational '
            'service, this draft requires specific Section 13(a) consent '
            'for that potentially sensitive context. If that consent is '
            'withdrawn, remove the sensitive marker unless a separate '
            'Section 13 exception actually applies.',
      ),
      LegalSection(
        heading: 'Guardian data',
        body: 'Legitimate interest under Section 12(f) for a minimal '
            'invitation to the adult contact supplied by the student, '
            'subject to necessity and balancing. Consent under Section '
            "12(a) for the guardian's confirmation response. The linked "
            'child age and study information requires Section 13(a) '
            'authorization; the adult-contact basis does not authorize all '
            'child processing.',
      ),
      LegalSection(
        heading: 'Security and compliance evidence',
        body: 'Section 12(f) for necessary ordinary security records, and '
            'Section 12(c) where a specific legal duty requires '
            'processing. Sensitive evidence needs a corresponding Section '
            '13 exception, such as Section 13(b) for an applicable '
            'regulatory duty or Section 13(f) for necessary legal-claim '
            'evidence. Security is not a blanket exception.\n\nMinimum '
            'consent evidence may be kept to meet the obligation to '
            'demonstrate permission. Any sensitive portion retained under '
            'Section 13(b) must actually fall within the applicable '
            'regulatory requirement and safeguards. Section 13(f) can '
            'support necessary evidence for establishing or defending a '
            'legal claim, but not a general archive kept because a dispute '
            'is theoretically possible.',
      ),
      LegalSection(
        heading: 'Payments for minors',
        body: 'If you are under 18, ask your parent or guardian to complete '
            'a payment using their own payment method.\n\nConfirming your '
            'account does not make a payment or approve a future charge. '
            'The checkout screen shows a guardian reminder. It does not '
            'check who is paying.',
      ),
    ],
  ),
};
