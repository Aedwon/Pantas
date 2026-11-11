/// Published versions shown by the guardian confirmation page.
///
/// Placeholder date. Set all three to the real publish date in the same
/// release as the new texts, and change the matching map in
/// `functions/src/guardianConsent.ts` to the same value (spec choice 14).
const guardianDocumentVersions = <String, String>{
  'privacy': '2026-11-11',
  'terms': '2026-11-11',
  'teens': '2026-11-11',
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
    updatedAt: DateTime.utc(2026, 11, 11),
    sections: const [
      LegalSection(
        heading: 'Who this is for',
        body: 'This policy is for people aged 18 and older. If you are under '
            '18, read the Notice for teens instead.',
      ),
      LegalSection(
        heading: 'Who runs Pantas',
        body: 'Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas '
            'Online Tutorial Services, a sole proprietorship. He is also '
            'the Data Protection Officer.\n\n'
            'Address: Poblacion, Norala, South Cotabato, Philippines.\n\n'
            'Questions about your data: dpo@pantas.study\n'
            'Help or payment problems: support@pantas.study',
      ),
      LegalSection(
        heading: 'Why we ask your age',
        body: 'Before we ask for your age, this step tells you what we do '
            'with it. When you set up Pantas, we ask you to enter your '
            'correct current age in full years. We use it once, on your '
            'device, to decide whether you can use Pantas and whether a '
            'parent or guardian must consent. Based on the age you enter, '
            'Pantas blocks use if you are under 13 and requires your parent '
            "or guardian's consent if you are 13 to 17. We do not save the "
            'age you enter. Our servers never receive it. Your device '
            'keeps your age group and the version of the age check '
            'notice. If you are under 13, it keeps only a block, so Pantas '
            'stays closed to you until support clears it.\n\n'
            'Choosing Continue means you give your specific permission for '
            'this age check. You may go back instead. Pantas requires this '
            'check before you can use it.',
      ),
      LegalSection(
        heading: 'What we collect',
        body: '• Account: an account ID, which Pantas creates even before '
            'you sign in. If you sign in with Google, we also receive your '
            'name, email address and profile photo. If you sign in with '
            'an email code, we receive your email address.\n'
            '• Study records: your study settings, answers, results, study '
            'times, bookmarked lessons and flagged questions.\n'
            '• Payments: if you buy Pro, we keep payment references, '
            'amounts, payment status, refunds and access dates. Card and '
            "wallet details are entered on PayMongo's checkout page.\n"
            '• Free trial: protected codes made from your verified sign-in '
            'details, so we can check whether a trial was already used.\n'
            '• Share cards: if you choose to share a Wrapped card, we keep '
            'the card image and a public link to it. You can remove it at '
            'any time.\n'
            '• Messages: emails you send to support@pantas.study or '
            'dpo@pantas.study.\n'
            '• Technical records: security and account records, such as '
            'sign-ins, payment checks and account deletions.',
      ),
      LegalSection(
        heading: 'How Pantas uses your answers',
        body: 'Software uses your answers and study timing to choose review '
            'dates and show study guidance. It also gives you a study-style '
            'label, such as the ones on share cards. These suggestions '
            'affect what Pantas recommends next. They do not decide any '
            'official exam eligibility or result.',
      ),
      LegalSection(
        heading: 'Optional usage sharing',
        body: 'Optional usage sharing helps us improve Pantas. It starts off. '
            'You choose whether to turn it on. It is a separate choice from '
            'setting up your account, and leaving it off does not stop you '
            'from using Pantas.\n\n'
            'If you turn it on, reports include the screens and features '
            'you use, your study sessions, question IDs, the answer you '
            'chose, and whether it was correct. These reports are linked '
            'to your account ID. The phone app can also send error reports.\n\n'
            'To turn it off, open Settings, then About, and use "Help '
            'improve Pantas by sharing usage data." You can also email '
            'dpo@pantas.study about reports already collected.',
      ),
      LegalSection(
        heading: 'Speed and error reports',
        body: 'To find slow screens and errors, the web app sends short '
            'technical reports. They include the app version, whether this '
            'is a first visit, a return visit or the first visit after an '
            'update, your browser family, your screen-size group, loading '
            'times, and error messages, counts and locations in our code. '
            'We filter common identifiers, such as email addresses, before '
            'a report is sent. Error text may still contain personal '
            'information. We do not deliberately include your answers or '
            'lesson content.\n\n'
            'Reports have no dedicated account ID or IP address field. '
            'Sending a report uses your sign-in session, including a guest '
            'session, to check the request and to limit how many reports '
            "are sent. We exclude this function's request logs from our "
            'default log storage. Google processes connection information '
            'to deliver requests.\n\n'
            'We keep the stored report logs for 30 days. These reports are '
            'on by default and are separate from optional usage sharing. '
            'The switch in Settings, then About, stops future reports from '
            'this browser or device. Repeat this on other devices. Email '
            'dpo@pantas.study for help, or for requests about reports '
            'already collected.',
      ),
      LegalSection(
        heading: 'Where your data goes',
        body: 'Some records stay in your browser or on your phone. On the '
            'web, your answers and study activity also go to our servers, '
            "including on Free. Our servers run in Google's Singapore "
            'region. Pro adds backup and syncing across devices.\n\n'
            'We use these providers:\n\n'
            '• Google (Firebase and Google Cloud): accounts, our servers, '
            'optional usage reports, and speed and error reports.\n'
            '• Resend: sign-in codes and emails we send you.\n'
            '• PayMongo: web payments.\n'
            '• RevenueCat and the app store you use: app-store purchases '
            'and the Pro access they give.\n\n'
            'These providers act for us under their own terms. They may '
            'process data outside the Philippines. We stay responsible for '
            'the data we give them. We may also share data when the law '
            'requires it, or when we need it to deal with fraud or a legal '
            'claim.\n\n'
            'We do not sell your data. We do not show ads.',
      ),
      LegalSection(
        heading: 'Your rights',
        body: 'You have the right to be informed about how your data is used. '
            'You can ask for a copy of your data, including in a common '
            'electronic format where the law allows. You can object to how '
            'it is used, ask us to fix wrong details, and ask us to stop '
            'using, block or delete data, when the law allows. You can ask '
            'for compensation where the law provides it. You can also '
            'complain to the National Privacy Commission (privacy.gov.ph).\n\n'
            'Send requests to dpo@pantas.study. We reply within 15 calendar '
            'days. We may ask for information we reasonably need to check '
            'who you are. If we cannot fully act on a request, we explain '
            'why.',
      ),
      LegalSection(
        heading: 'Withdrawing permission or deleting data',
        body: 'You can withdraw a permission you gave, such as optional usage '
            'sharing, at any time. Withdrawing is free. It does not undo '
            'use of data that was lawful before you withdrew. If you '
            'withdraw permission for study records, we cannot run your '
            'account and we close it.\n\n'
            'To delete your account, open Settings, then Account, then the '
            'delete option. For an account signed in with Google or an '
            'email code, this deletes your study records from our servers '
            'and clears Pantas data on the device you use. You may need '
            'to sign in again first. For an account that is not signed in, '
            'it clears data on your device only. To remove server records '
            'of such an account, email dpo@pantas.study.\n\n'
            'Deleting your account removes its study records. It does not '
            'cancel an app store subscription. Limited trial-use, security '
            'and required accounting records may remain for the purposes '
            'and periods in the next section. Copies on your other devices '
            "stay until you clear them. Copies in our providers' backups "
            'are removed within 180 days of deletion.',
      ),
      LegalSection(
        heading: 'How long we keep data',
        body: '• Study records and settings: while your account exists. We '
            'delete the account if you delete it, or if it has had no '
            'sign-in or study activity for 24 months. We identify '
            'inactivity from server-observed sign-in and session activity. '
            'Open Pantas while connected to keep the account active. We '
            'normally send a warning about 30 days beforehand if the '
            'account has a verified email address. An account with active '
            'paid access does not count as inactive. A guest account '
            'without an email address is deleted without a warning.\n'
            '• Free-trial codes: kept for as long as Pantas offers free '
            'trials, including after account deletion, so a trial cannot '
            'be repeated.\n'
            '• Payment and accounting records: five years, counted as tax '
            'law requires from the filing deadline of the related tax '
            'return. Records may stay longer while a tax matter is '
            'unresolved.\n'
            '• Our database security records: 730 days after the event.\n'
            '• Optional usage reports: Google Analytics keeps event records '
            'for up to 14 months after your last activity. This is the '
            'longest setting Google allows. Google starts removing phone '
            'error reports after 90 days.\n'
            '• Speed and error report logs from the web app: 30 days.\n'
            '• Share cards: until you remove the card or the account is '
            'deleted.\n'
            '• Messages to us: kept for up to two years after the matter '
            'closes, then deleted.\n\n'
            'If the law requires it, or we need specific records for a '
            'legal claim, we may keep those records longer.',
      ),
      LegalSection(
        heading: 'Why we may use your data',
        body: '• Age check: your specific permission, given at the age step '
            '(Data Privacy Act, Section 13(a)). We use your age only on '
            'your device without saving it. The device keeps only your age '
            'group and the version of the age check notice, or a block if '
            'you are under 13.\n'
            '• Account and payment records: we need them to provide the '
            'service you asked for (Section 12(b)).\n'
            '• Study records: your specific permission (Section 13(a)), '
            'given at setup when you accept the Terms and Privacy Policy. '
            'Answers and results can relate to education.\n'
            '• Optional usage sharing: your separate permission (Sections '
            '12(a) and 13(a)). You can withdraw it at any time.\n'
            '• Speed and error reports, security records and trial codes: '
            'our legitimate interest in keeping Pantas working, safe and '
            'fair (Section 12(f)). We keep each to what we need.\n'
            '• Accounting records: the law requires them (Section 12(c)).\n'
            '• Messages to us: we need them to answer you.',
      ),
      LegalSection(
        heading: 'Keeping data safe',
        body: 'We use reasonable organizational, physical and technical '
            'measures to protect your data. If a breach is likely to put '
            'you at real risk, we tell you and the National Privacy '
            'Commission as the law requires.',
      ),
      LegalSection(
        heading: 'Changes to this policy',
        body: 'We notify you before we change the processing described here. '
            'If a change needs new permission, we ask before starting it.',
      ),
    ],
  ),
  'terms': LegalDocument(
    id: 'terms',
    title: 'Terms of Service',
    updatedAt: DateTime.utc(2026, 11, 11),
    sections: const [
      LegalSection(
        heading: 'Use of the app',
        body: 'Pantas is a study tool for exam practice. You may use it for '
            'your own study. You must be 13 or older. If you are under 18, '
            'a parent or guardian must agree before you continue, as the '
            'Notice for teens explains.\n\n'
            'When you use Pantas, you agree to:\n\n'
            '• give true information when you set up your account;\n'
            '• keep your sign-in details private and tell us promptly about '
            'suspected misuse. You are responsible for activity you '
            'authorize;\n'
            '• use one account for yourself and not share your sign-in;\n'
            '• not copy, scrape, resell or reverse-engineer the app or its '
            'content;\n'
            '• not attack, overload or try to break into the app or any '
            'account;\n'
            '• not misuse trials, payments, limits or promotions; and\n'
            '• follow the law.\n\n'
            'Pantas is independent. It is not part of, approved by or '
            'connected to the Civil Service Commission or any other '
            'government office or exam body.',
      ),
      LegalSection(
        heading: 'Subscriptions',
        body: 'App store purchases. If you buy through an app store, your '
            'paid features depend on your active store subscription. Use '
            'the store account you bought with for billing, cancellation '
            'and store refund requests. Contact us about problems with '
            'Pantas itself.\n\n'
            'Web purchases. On the web, you buy Pro access in advance and '
            'pay through PayMongo. Web purchases do not renew '
            'automatically. If you want more access, you buy again. A web '
            'purchase does not cancel a separate store subscription.\n\n'
            'Price. The price is the amount shown in Philippine pesos on '
            'the Pro screen and at checkout when you pay. That amount is '
            'the full amount you pay. Check the plan and amount before you '
            'pay. We may change prices at any time. A change does not '
            'affect a payment you already made. Checkout shows the payment '
            'methods you can use.\n\n'
            'Plans. Weekly access lasts seven days. Monthly access lasts '
            'one calendar month. Yearly access lasts one calendar year. '
            'These plans give Civil Service Pro access. Monthly and Yearly '
            'access ends on the matching date at the same time in '
            'Philippine time. If that date does not exist, it ends on the '
            'last day of that month. A Season Pass covers its named exam '
            'until the end of the last day of the exam sitting stated at '
            'checkout.\n\n'
            'When access starts. We turn on access after we verify your '
            'payment with PayMongo. A plan period counts from the payment '
            'time PayMongo records, or from the end of your existing '
            'qualifying Pro access, whichever is later. A Season Pass runs '
            'from payment until its stated sitting and does not add to '
            'other passes. Returning from checkout does not confirm your '
            'payment. If you paid and Pro does not appear, email '
            'support@pantas.study with your payment details.\n\n'
            'Free trial. You can get one seven-day free trial of Monthly '
            'Pro if you qualify. You qualify only if you are signed in with '
            'verified sign-in details and have not had a trial or paid Pro '
            'before. You do not enter payment details. The trial ends after '
            'seven days. It does not become a paid plan and we do not '
            'charge you. We may change or stop future trial offers. We may '
            'refuse or end a trial we reasonably suspect is being misused, '
            'for example through several accounts. Deleting your account '
            'does not give you another trial.\n\n'
            'Free or promotional access. Pantas may give free access, such '
            'as a trial, a beta period or a prize, at its choice. This '
            'access lasts only for the period we state. It can end earlier '
            'if it is misused. It does not give you a right to more access '
            'and it does not start a paid plan.\n\n'
            'Refunds. Under our voluntary refund policy, we refund in full:\n\n'
            '• an extra payment for a period that has not started, such '
            'as a payment made twice; or\n'
            '• a payment that never gave you the access you bought.\n\n'
            'Email support@pantas.study within 30 days of the payment, with '
            'enough details to find it. We refund to the original payment '
            'method through PayMongo. The time the money takes to reach '
            'you depends on PayMongo and your bank.\n\n'
            'We do not give refunds for a change of mind, or partial '
            'refunds for unused time. A period that has started, or a '
            'Season Pass whose exam date has passed, is outside this '
            'voluntary policy.\n\n'
            'We may give other refunds as goodwill. A goodwill refund does '
            'not create a right to more refunds. If we agree to cancel a '
            'purchase with a partial refund, the remaining access is '
            'shortened in proportion to the amount refunded. A refund that '
            'the law requires for a defective service does not shorten your '
            'access.\n\n'
            'These limits and the 30-day deadline do not limit any remedy '
            'Philippine law gives you, such as for a service that did not '
            'work as promised.\n\n'
            'Disputes with your bank. If you dispute a payment with your '
            'bank or card issuer, we may suspend the access that payment '
            'gave while the dispute is open. If the payment is reversed, '
            'that access ends. If the dispute is resolved in our favor, '
            'the access returns. We may restrict an account we reasonably '
            'suspect of fraud or abuse.\n\n'
            'Ending Pro. When your Pro access ends, Pro-only features stop '
            'unless another plan or pass covers the exam. You can keep '
            'using Free features. Pro backup and syncing stop while you '
            'do not have Pro. Ending Pro does not by itself delete your '
            'progress. Your data follows the storage periods in our privacy '
            'notices.\n\n'
            'Deleting your account. If you delete your account, your access '
            'ends, including any time left on a plan. Deleting your account '
            'is not a refund request. The same applies if a parent or '
            'guardian withdraws permission for an under-18 account, or if '
            'we delete an account that has been inactive for 24 months. '
            'An account with active paid access is not treated as inactive.\n\n'
            'Students under 18. If you are under 18, your parent or '
            'guardian must make the purchase. At checkout, the buyer must '
            'tick "I am the parent or guardian and accept the Terms." '
            'Checkout does not work without it. On the web, we record the tick '
            'with the date, time and Terms version when checkout starts. '
            'By ticking, the buyer '
            'confirms they are the parent or guardian, that they accept '
            'these Terms as the buyer, and that they are allowed to use '
            'the payment method chosen. We rely on that confirmation. If '
            'we learn that someone who is not a parent or guardian ticked '
            'the box, we may cancel the purchase, refund it and end the '
            'access.\n\n'
            'Complaints. Send purchase complaints to support@pantas.study '
            'with the transaction reference and a description of the '
            'problem. If it is unresolved after seven calendar days, our '
            'internal complaint process is deemed exhausted.',
      ),
      LegalSection(
        heading: 'Study content and results',
        body: 'Pantas does not guarantee a passing result, admission, a job, '
            'a license or any particular score. Exams are set by others. '
            'Check the official exam instructions, eligibility '
            'requirements, schedules and announcements.\n\n'
            'We prepare lessons, questions and explanations with care. They '
            'can still contain mistakes or fall behind a change in an exam. '
            'The official exam source always comes first. Tell us about '
            'an error at support@pantas.study. We may correct or remove '
            'content at any time.\n\n'
            'Scores show your recorded performance in Pantas. Progress '
            'indicators and review dates provide study guidance. They do '
            'not predict your official exam result.\n\n'
            'Pantas is provided "as is" and "as available." We do not '
            'promise that it will run without interruption or errors, or '
            'on every device. This does not remove our duty to give you '
            'a service of the quality the law requires.',
      ),
      LegalSection(
        heading: 'Changes, suspension and ending',
        body: 'We may change, add or remove features, content and plans. We '
            'may pause the service for repairs or for reasons outside our '
            'control. We try to tell you about big changes in the app.\n\n'
            'If we permanently end a Pro feature, or the whole service, '
            'while you have paid access, we refund the unused part of your '
            'payment.\n\n'
            'We may suspend or close an account if you seriously break '
            'these Terms, misuse the app, put the app or other people at '
            'risk, make a payment we reasonably believe is fraudulent, or '
            'if the law requires it. We try to tell you why and let you '
            'reply first. We may act without notice if waiting would put '
            'others at risk or the law forbids notice. If you think we made '
            'a mistake, email support@pantas.study within 30 days. We will '
            'review it.\n\n'
            'If we close your account for serious misuse, we do not refund '
            'unused paid time, unless the law requires a refund.\n\n'
            'You can stop at any time by deleting your account.',
      ),
      LegalSection(
        heading: 'Limits of responsibility',
        body: 'We take reasonable care to run Pantas. Our responsibility '
            'follows Philippine law.\n\n'
            'The exclusions and cap below apply only where Philippine law '
            'permits. They do not limit your statutory consumer remedies '
            'or damages. They do not limit your data privacy rights or '
            'compensation. They do not limit liability for fraud, bad '
            'faith, willful misconduct, gross negligence, death or personal '
            'injury.\n\n'
            'For a good-faith breach of contract, recoverable damages '
            'follow Article 2201 of the Civil Code. Subject to the '
            'exceptions above, we exclude indirect or consequential loss, '
            'including lost income or lost opportunities, to the extent '
            'Philippine law permits.\n\n'
            'For other claims arising from one event or related events, '
            'our total money liability is limited to the greater of ₱1,000 '
            'or the amount you paid Pantas for the affected account in the '
            '12 months before the first event. This applies whether the '
            'claim is in contract, negligence or otherwise.\n\n'
            'If a court finds part of these Terms is not allowed, the rest '
            'stays in force.\n\n'
            'Payment providers, app stores, banks and other companies we '
            'use have their own terms and fees. We are not responsible for '
            'those terms or fees.',
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
      LegalSection(
        heading: 'Governing law and disputes',
        body: 'Philippine law governs these Terms and your use of Pantas.\n\n'
            'If you have a problem, please email support@pantas.study '
            'first. We want to fix it.\n\n'
            'Consumer proceedings may be brought in any place that '
            'applicable law and court rules allow. For other civil '
            'disputes, the parties agree to bring them only in the proper '
            'courts serving Norala, South Cotabato. You may always complain '
            'to the Department of Trade and Industry, the National Privacy '
            'Commission or any other government office.',
      ),
      LegalSection(
        heading: 'Changes to these Terms',
        body: 'We may update these Terms. We tell you in the app before a '
            'material change takes effect, at least 14 days ahead unless '
            'the law or security requires sooner. The date at the top shows '
            'the current version.\n\n'
            'A change that makes your rights worse does not apply to access '
            'you have already paid for until that access period ends. If '
            'you do not accept a change, stop using Pantas and delete your '
            'account. If you keep using Pantas after the change takes '
            'effect, you accept it, except where the law requires your new '
            'permission.',
      ),
    ],
  ),
  'teens': LegalDocument(
    id: 'teens',
    title: 'Notice for teens',
    updatedAt: DateTime.utc(2026, 11, 11),
    sections: const [
      LegalSection(
        heading: 'Who this is for',
        body: 'This notice is for teens ages 13 to 17 and for their parents '
            'or guardians. Pantas is for people aged 13 and older.\n\n'
            'If you are 18 or older, read the Privacy Policy instead.',
      ),
      LegalSection(
        heading: 'Who runs Pantas',
        body: 'Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas '
            'Online Tutorial Services, a sole proprietorship. He is also '
            'the Data Protection Officer.\n\n'
            'Address: Poblacion, Norala, South Cotabato, Philippines.\n\n'
            'Questions about your data: dpo@pantas.study\n'
            'Help or payment problems: support@pantas.study',
      ),
      LegalSection(
        heading: 'Why we ask your age',
        body: 'Before we ask for your age, this step tells you what we do '
            'with it. When you set up Pantas, we ask you to enter your '
            'correct current age in full years. We use it once, on your '
            'device, to decide whether you can use Pantas and whether a '
            'parent or guardian must consent. Based on the age you enter, '
            'Pantas blocks use if you are under 13 and requires your parent '
            "or guardian's consent if you are 13 to 17. We do not save the "
            'age you enter. Our servers never receive it. Your device '
            'keeps your age group and the version of the age check '
            'notice. If you are under 13, it keeps only a block, so Pantas '
            'stays closed to you until support clears it.\n\n'
            'Choosing Continue means you give your specific permission for '
            'this age check. You may go back instead. Pantas requires this '
            'check before you can use it.\n\n'
            'If you are in the under-18 group, we record that label on our '
            'servers, with the version of the age check notice, when you '
            'ask your guardian for permission. We need the record to send '
            'and check the request.\n\n'
            'When you turn 18, open Settings and choose "I\'m 18 now." '
            'Enter your current age and choose Continue. If you are 18 or '
            'older and the update succeeds, our servers record that you '
            "are 18 or older, your guardian's controls end and the "
            'guardian page links stop working.',
      ),
      LegalSection(
        heading: 'What we collect',
        body: '• Account: an account ID, which Pantas creates even before '
            'you sign in. If you sign in with Google, we also receive your '
            'name, email address and profile photo. If you sign in with '
            'an email code, we receive your email address.\n'
            '• Study records: your study settings, answers, results, study '
            'times, bookmarked lessons and flagged questions.\n'
            "• Guardian request: your guardian's name and email address. "
            'We keep the request status, its dates, a partly hidden version '
            'of the email address, and protected codes made from the email '
            'address and the link. Our servers do not keep the full email '
            "address. Your guardian's full name and email address stay on "
            'your device so you can resend the request. Your device deletes '
            'them once it learns the guardian has confirmed.\n'
            "• Guardian answer record: your guardian's answer, when it "
            'happened, which versions of our notices and terms were shown, '
            'and your account ID. It holds no name or email address. We '
            'add a line each time your guardian changes a permission or '
            'withdraws it.\n'
            '• Payments: if someone buys Pro for your account, we keep '
            'payment references, amounts, payment status, refunds and '
            'access dates. Card and wallet details are entered on '
            "PayMongo's checkout page. For a purchase on an under-18 "
            'account, we also record that the buyer ticked the parent or '
            'guardian box, with the date, time and Terms version.\n'
            '• Free trial: protected codes made from your verified sign-in '
            'details, so we can check whether a trial was already used.\n'
            '• Share cards: if you choose to share a Wrapped card, we keep '
            'the card image and a public link to it. You can remove it at '
            'any time.\n'
            '• Messages: emails you or your guardian send to '
            'support@pantas.study or dpo@pantas.study.\n'
            '• Technical records: security and account records, such as '
            'sign-ins, payment checks and account deletions.',
      ),
      LegalSection(
        heading: 'How Pantas uses your answers',
        body: 'Software uses your answers and study timing to choose review '
            'dates and show study guidance. It also gives you a study-style '
            'label, such as the ones on share cards. These suggestions '
            'affect what Pantas recommends next. They do not decide any '
            'official exam eligibility or result.',
      ),
      LegalSection(
        heading: 'Optional usage sharing',
        body: 'Sharing starts off. Your guardian must allow it before it can '
            'turn on. After that, you can turn it off in Settings. Your '
            'guardian can also withdraw that permission on the guardian '
            'page.\n\n'
            'If it is on, reports include the screens and features you use, '
            'your study sessions, question IDs, the answer you chose, and '
            'whether it was correct. These reports are linked to your '
            'account ID. The phone app can also send error reports.\n\n'
            'Leaving it off does not stop you from using Pantas. Your '
            'guardian can also email dpo@pantas.study about reports already '
            'collected.',
      ),
      LegalSection(
        heading: 'Speed and error reports',
        body: 'To find slow screens and errors, the web app sends short '
            'technical reports. They include the app version, whether this '
            'is a first visit, a return visit or the first visit after an '
            'update, your browser family, your screen-size group, loading '
            'times, and error messages, counts and locations in our code. '
            'We filter common identifiers, such as email addresses, before '
            'a report is sent. Error text may still contain personal '
            'information. We do not deliberately include your answers or '
            'lesson content.\n\n'
            'Reports have no dedicated account ID or IP address field. '
            'Sending a report uses your sign-in session, including a guest '
            'session, to check the request and to limit how many reports '
            "are sent. We exclude this function's request logs from our "
            'default log storage. Google processes connection information '
            'to deliver requests.\n\n'
            'We keep the stored report logs for 30 days. These reports are '
            'on by default and are separate from optional usage sharing. '
            'The switch in Settings, then About, stops future reports from '
            'this browser or device. Repeat this on other devices. Email '
            'dpo@pantas.study for help, or for requests about reports '
            'already collected.',
      ),
      LegalSection(
        heading: 'Why a guardian confirms',
        body: 'If you are in the under-18 group, Pantas asks a parent or '
            'guardian to read the terms and confirm before you continue.\n\n'
            'Opening the email link confirms nothing. The adult must tick '
            'the agreement box and choose Confirm. They can choose "I Don\'t '
            'Agree" instead.\n\n'
            'The first link works once and expires after seven days. A new '
            'link replaces the old one. The first email also holds a link '
            'to the guardian page, which works once your guardian has '
            'confirmed. The confirmation screen shows the same link. The '
            'guardian page link works until you confirm you are 18, or '
            'until the account is deleted.\n\n'
            'Anyone holding these links can use them to respond or manage '
            'permission. Keep them private. The links do not independently '
            "prove someone's identity or authority. Contact us if a link "
            'is lost, shared or misused.',
      ),
      LegalSection(
        heading: 'What your guardian can do',
        body: 'Your guardian can confirm or decline the request. Confirming '
            'does not give them a screen showing your results.\n\n'
            'After confirming, your guardian can use the guardian page to:\n\n'
            '• allow or withdraw optional usage sharing. It starts off.\n'
            '• withdraw permission. This closes your account and deletes '
            'it, as the section on withdrawing explains.\n\n'
            'Your guardian can also email our Data Protection Officer about '
            'your data. We may ask for information we reasonably need to '
            'check who is asking before we share information or act on '
            'instructions.',
      ),
      LegalSection(
        heading: 'Where your data goes',
        body: 'Some records stay in your browser or on your phone. On the '
            'web, your answers and study activity also go to our servers, '
            "including on Free. Our servers run in Google's Singapore "
            'region. Pro adds backup and syncing across devices.\n\n'
            'We use these providers:\n\n'
            '• Google (Firebase and Google Cloud): accounts, our servers, '
            'optional usage reports, and speed and error reports.\n'
            '• Resend: guardian emails and sign-in codes.\n'
            '• PayMongo: web payments.\n'
            '• RevenueCat and the app store you use: app-store purchases '
            'and the Pro access they give.\n\n'
            'These providers may process data outside the Philippines. We '
            'do not sell your data and we do not show ads.',
      ),
      LegalSection(
        heading: 'Your rights',
        body: 'You have the right to be informed about how your data is used. '
            'You can ask for a copy of your data, including in a common '
            'electronic format where the law allows. You can object to how '
            'it is used, ask us to fix wrong details, and ask us to stop '
            'using, block or delete data, when the law allows. You can ask '
            'for compensation where the law provides it. You can also '
            'complain to the National Privacy Commission.\n\n'
            'Your guardian can use these rights for you while you are under '
            '18. Send requests to dpo@pantas.study. We reply within 15 '
            'calendar days. We may ask for information we reasonably need '
            'to check who you are. If we cannot fully act on a request, '
            'we explain why.',
      ),
      LegalSection(
        heading: 'Withdrawing permission or deleting data',
        body: 'Your guardian can withdraw permission for you to use Pantas '
            'at any time. It is free. There are two ways:\n\n'
            '• Open the guardian page link and choose "Withdraw '
            'permission."\n'
            '• Email dpo@pantas.study with a message such as "I withdraw '
            'my permission for my child to use Pantas." Send it from the '
            'email address used for confirmation if you can, and include '
            'the account ID or sign-in email if you know it.\n\n'
            'When permission is withdrawn, we disable the account, sign '
            'it out, and delete it in the same way as account deletion. '
            'We keep the guardian answer record and the record of the '
            'withdrawal, for the reasons in the next section. Pantas cannot '
            "work without a guardian's permission for study records, so "
            'the account cannot continue.\n\n'
            'Withdrawing does not undo use of data that was lawful before. '
            'It does not cancel an app store subscription. It is not a '
            'refund request. Refunds follow the Terms.\n\n'
            'You can delete your account yourself. Open Settings, then '
            'Account, then the delete option. For an account signed in with '
            'Google or an email code, this deletes your study records from '
            'our servers and clears Pantas data on the device you use. You '
            'may need to sign in again first. For an account that is not '
            'signed in, it clears data on your device only. To remove '
            'server records of such an account, email dpo@pantas.study.\n\n'
            'Deleting your account removes its study records. Limited '
            'trial-use, guardian-answer, security and required accounting '
            'records may remain for the purposes and periods in the next '
            'section. Copies on your other devices stay until you clear '
            "them. Copies in our providers' backups are removed within 180 "
            'days of deletion.',
      ),
      LegalSection(
        heading: 'How long we keep data',
        body: '• Study records and settings: while your account exists. We '
            'delete the account if you delete it, if your guardian '
            'withdraws permission, or if it has had no sign-in or study '
            'activity for 24 months. We identify inactivity from '
            'server-observed sign-in and session activity. Open Pantas '
            'while connected to keep the account active. We normally send '
            'a warning about 30 days beforehand if the account has a '
            'verified email address. An account with active paid access '
            'does not count as inactive. A guest account without an email '
            'address is deleted without a warning.\n'
            '• Guardian requests and links: the first link stops working '
            'after seven days. Our hourly cleanup then deletes expired '
            'requests and links. A used, declined or replaced link is '
            'deleted seven days after that event. The guardian page link '
            'is deleted with the account.\n'
            '• Guardian evidence: we keep minimal guardian-response '
            'evidence while the account exists. This is the guardian answer '
            'record, the withdrawal record, and the purchase confirmation. '
            'When an account is deleted, we copy the purchase confirmation '
            '(date, time, Terms version and payment reference) into this '
            'evidence. After deletion, we normally remove it ten years '
            'after the most recent recorded guardian response. Relevant '
            'records may remain longer for a documented legal claim. We '
            'chose this period because a contract made by someone under '
            '18 can be challenged until four years after that person turns '
            '18.\n'
            '• Free-trial codes: kept for as long as Pantas offers free '
            'trials, including after account deletion, so a trial cannot '
            'be repeated.\n'
            '• Payment and accounting records: five years, counted as tax '
            'law requires from the filing deadline of the related tax '
            'return. Records may stay longer while a tax matter is '
            'unresolved.\n'
            '• Our database security records: 730 days after the event.\n'
            '• Optional usage reports: Google Analytics keeps event records '
            'for up to 14 months after your last activity. This is the '
            'longest setting Google allows. Google starts removing phone '
            'error reports after 90 days.\n'
            '• Speed and error report logs from the web app: 30 days.\n'
            '• Share cards: until you remove the card or the account is '
            'deleted.\n'
            '• Messages to us: kept for up to two years after the matter '
            'closes, then deleted.\n\n'
            'If the law requires it, or we need specific records for a '
            'legal claim, we may keep those records longer.',
      ),
      LegalSection(
        heading: 'Why we may use your data',
        body: '• Age check: your specific permission, given at the age step '
            '(Data Privacy Act, Section 13(a)). We use your age only on '
            'your device without saving it. The device keeps only your age '
            'group and the version of the age check notice, or a block if '
            'you are under 13.\n'
            "• Age-group record on an under-18 account: your guardian's "
            'permission (Section 13(a)). We keep minimal guardian evidence '
            'only where needed to establish or defend legal claims (Section '
            '13(f)).\n'
            '• Account and payment records: we need them to provide the '
            'service you asked for (Section 12(b)).\n'
            "• Study records: your guardian's specific permission (Section "
            '13(a)). Answers and results can relate to education.\n'
            "• Optional usage sharing: your guardian's separate permission. "
            'It can be withdrawn at any time.\n'
            '• Speed and error reports, security records, guardian requests '
            'and trial codes: our legitimate interest in keeping Pantas '
            'working, safe and fair (Section 12(f)). We keep each to what '
            'we need.\n'
            '• Accounting records: the law requires them.',
      ),
      LegalSection(
        heading: 'Changes to this notice',
        body: 'We notify you in the app, in plain language, before we change '
            'the processing described here. We also notify your guardian. '
            'If a change needs new permission, we ask before starting it.',
      ),
      LegalSection(
        heading: 'Payments for minors',
        body: 'If you are under 18, your parent or guardian must make the '
            'purchase. At checkout, they must tick the box "I am the parent '
            'or guardian and accept the Terms." Checkout does not work '
            'without it. On the web, we record the tick with the date, time '
            'and Terms version when checkout starts.\n\n'
            'Confirming your account is not a purchase. The buyer must be '
            'allowed to use the payment method.',
      ),
    ],
  ),
};
