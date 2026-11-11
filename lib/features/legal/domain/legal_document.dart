/// Published versions shown by the guardian confirmation page.
const guardianDocumentVersions = <String, String>{
  'privacy': '2026-11-10',
  'terms': '2026-11-10',
  'teens': '2026-11-10',
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
    updatedAt: DateTime.utc(2026, 11, 10),
    sections: const [
      LegalSection(
        heading: 'Who this is for',
        body: 'This policy is for people aged 18 and older. If you are under '
            '18, read the Notice for teens instead.',
      ),
      LegalSection(
        heading: 'Who runs Pantas',
        body: 'Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas '
            'Online Tutorial Services, a sole proprietorship. He is also the '
            'Data Protection Officer.\n\nAddress: Poblacion, Norala, South '
            'Cotabato, Philippines.\n\nQuestions about your data: '
            'dpo@pantas.study\nHelp or payment problems: support@pantas.study',
      ),
      LegalSection(
        heading: 'Why we ask your age',
        body: 'When you set up Pantas, we ask you to enter your correct '
            'current age in full years. We use it once, on your device, to '
            'decide whether you can use Pantas and whether a parent or '
            'guardian must consent. Based on the age you enter, Pantas blocks '
            "use if you are under 13 and requires your parent or guardian's "
            'consent if you are 13 to 17. We use your age only on your '
            'device without saving it and keep only the resulting age group '
            'there. Our servers never receive your age.',
      ),
      LegalSection(
        heading: 'What we collect',
        body: '• Account: an account ID, which Pantas creates even before you '
            'sign in. If you sign in with Google, we also receive your name, '
            'email address and profile photo. If you sign in with an email '
            'code, we receive your email address.\n• Study records: your '
            'study settings, answers, results, study times, bookmarked '
            'lessons and flagged questions.\n• Payments: if you buy Pro, we '
            'keep payment references, amounts, payment status, refunds and '
            "access dates. Card and wallet details are entered on PayMongo's "
            'checkout page.\n• Free trial: protected codes made from your '
            'verified sign-in details, so we can check whether a trial was '
            'already used.\n• Share cards: if you choose to share a Wrapped '
            'card, we keep the card image, its public page, and a share '
            'record with your account ID and study-style label. Where the '
            'Wrapped screen offers it, revoking a card removes the image and '
            'turns off its public page. To remove a card another way, email '
            'dpo@pantas.study.\n• Messages: emails you send to '
            'support@pantas.study or dpo@pantas.study.\n• Technical records: '
            'security and account records, such as sign-ins, payment checks '
            'and account deletions.',
      ),
      LegalSection(
        heading: 'How Pantas uses your answers',
        body: 'Software uses your answers and study timing to choose review '
            'dates and show study guidance. It also gives you a study-style '
            'label, such as the ones on share cards. These suggestions affect '
            'what Pantas recommends next. They do not decide any official '
            'exam eligibility or result.',
      ),
      LegalSection(
        heading: 'Optional usage sharing',
        body: 'Optional usage sharing helps us improve Pantas. It starts off. '
            'You choose whether to turn it on. It is a separate choice from '
            'setting up your account, and leaving it off does not stop you '
            'from using Pantas.\n\nIf you turn it on, reports include the '
            'screens and features you use, your study sessions, question IDs, '
            'the answer you chose, and whether it was correct. These reports '
            'are linked to your account ID. The phone app can also send error '
            'reports.\n\nTo turn it off, open Settings, then About, and use '
            '"Help improve Pantas by sharing usage data." You can also email '
            'dpo@pantas.study about reports already collected.',
      ),
      LegalSection(
        heading: 'Speed and error reports',
        body: 'To find slow screens and errors, the web app sends short '
            'technical reports. They include the app version, whether this is '
            'a first visit, a return visit or the first visit after an '
            'update, your browser family, your screen-size group, loading '
            'times, and error messages, counts and locations in our code. We '
            'filter common identifiers, such as email addresses, before a '
            'report is sent. Error text may still contain personal '
            'information. We do not deliberately include your answers or '
            'lesson content.\n\nReports have no dedicated account ID or IP '
            'address field. Sending a report uses your sign-in session, '
            'including a guest session, to check the request and to limit how '
            "many reports are sent. Google's connection logs for these "
            'reports also record your IP address and full browser details. We '
            'do not use them to identify you.\n\nWe keep these report logs '
            'for 30 days. These reports are on for everyone who uses the web '
            'app and are separate from optional usage sharing. To object, '
            'email dpo@pantas.study.',
      ),
      LegalSection(
        heading: 'Where your data goes',
        body: 'Some records stay in your browser or on your phone. On the '
            'web, your answers and study activity also go to our servers, '
            "including on Free. Our servers run in Google's Singapore region. "
            'Pro adds backup and syncing across devices.\n\nWe use these '
            'providers:\n\n• Google (Firebase and Google Cloud): accounts, '
            'our servers, optional usage reports, and speed and error '
            'reports.\n• Resend: sign-in codes and emails we send you.\n• '
            'PayMongo: web payments.\n• RevenueCat and the app store you use: '
            'app-store purchases and the Pro access they give.\n\nThese '
            'providers act for us under their own terms. They may process '
            'data outside the Philippines. We stay responsible for the data '
            'we give them. We may also share data when the law requires it, '
            'or when we need it to deal with fraud or a legal claim.\n\nWe do '
            'not sell your data. We do not show ads.',
      ),
      LegalSection(
        heading: 'Your rights',
        body: 'You have the right to be informed about how your data is used. '
            'You can ask for a copy of your data, including in a common '
            'electronic format where the law allows. You can object to how it '
            'is used, ask us to fix wrong details, and ask us to stop using, '
            'block or delete data, when the law allows. You can ask for '
            'compensation where the law provides it. You can also complain to '
            'the National Privacy Commission (privacy.gov.ph).\n\nSend '
            'requests to dpo@pantas.study. We reply within 15 calendar days. '
            'We may ask for information we reasonably need to check who you '
            'are. If we cannot fully act on a request, we explain why.',
      ),
      LegalSection(
        heading: 'Withdrawing permission or deleting data',
        body: 'You can withdraw a permission you gave, such as optional usage '
            'sharing, at any time. Withdrawing is free. It does not undo use '
            'of data that was lawful before you withdrew. If you withdraw '
            'permission for study records, we cannot run your account and we '
            'close it.\n\nTo delete your account, open Settings, then '
            'Account, then the delete option. For an account signed in with '
            'Google or an email code, this removes your study records from '
            'our servers, and clears study records and account settings on '
            'the device you use. Some device preferences remain. You may need '
            'to sign in again first. For an account that is not signed in, it '
            'clears study records and account settings on your device only. '
            'To remove server records of such an account, email '
            'dpo@pantas.study.\n\nDeleting your account removes its study '
            'records. It does not cancel an app store subscription. Limited '
            'trial-use, security and required accounting records may remain '
            'for the purposes and periods in the next section. Copies on your '
            'other devices stay until you clear them. Copies in our '
            "providers' backups can take longer to disappear. For sign-in "
            'data, Google removes them within 180 days.',
      ),
      LegalSection(
        heading: 'How long we keep data',
        body: '• Study records and settings: while your account exists. They '
            'are deleted when you delete your account.\n• Free-trial codes: '
            'kept after account deletion, so a trial cannot be repeated. They '
            'have no set end date yet.\n• Payment records in Pantas: deleted '
            'with your account. PayMongo keeps its own transaction records '
            'under its own rules. Accounting records that tax law requires, '
            'such as invoices, are kept for five years, counted as that law '
            'requires.\n• Account and payment audit records: 730 days after '
            'the event.\n• Optional usage reports: kept under the retention '
            'setting of our Google Analytics account. Google starts removing '
            'phone error reports after 90 days.\n• Speed and error report '
            'logs from the web app: 30 days.\n• Share cards: the image and '
            'public page until you revoke the card or delete your account. '
            'The share record stays until your account is deleted.\n• '
            'Messages to us: kept for up to two years after the matter '
            'closes, then deleted.\n\nIf the law requires it, or we need '
            'specific records for a legal claim, we may keep those records '
            'longer.',
      ),
      LegalSection(
        heading: 'Why we may use your data',
        body: '• Age check: needed to decide whether a guardian must confirm '
            'before you use Pantas. We use your age only on your device '
            'without saving it and keep only the resulting age group there.'
            '\n• Account and payment records: we need them to provide '
            'the service you asked for.\n• Study records: your specific '
            'permission, given at setup when you agree to the Terms and this '
            'Privacy Policy. Answers and results can relate to education.\n• '
            'Optional usage sharing: your separate permission. You can '
            'withdraw it at any time.\n• Speed and error reports, security '
            'records and trial codes: our legitimate interest in keeping '
            'Pantas working, safe and fair. We keep each to what we need.\n• '
            'Accounting records: the law requires them.\n• Messages to us: we '
            'need them to answer you.',
      ),
      LegalSection(
        heading: 'Keeping data safe',
        body: 'We use reasonable organizational, physical and technical '
            'measures to protect your data. If a breach is likely to put you '
            'at real risk, we tell you and the National Privacy Commission as '
            'the law requires.',
      ),
      LegalSection(
        heading: 'Changes to this policy',
        body: 'When we change this policy, we update it here and change the '
            'date at the top.',
      ),
    ],
  ),
  'terms': LegalDocument(
    id: 'terms',
    title: 'Terms of Service',
    updatedAt: DateTime.utc(2026, 11, 10),
    sections: const [
      LegalSection(
        heading: 'Use of the app',
        body: 'Pantas is a study tool. It does not guarantee exam '
            'results or replace official exam instructions.',
      ),
      LegalSection(
        heading: 'Subscriptions',
        body: 'App store purchases. If you buy through an app store, your '
            'paid features depend on your active store subscription. Use the '
            'store account you bought with for billing, cancellation and '
            'store refund requests. Contact us about problems with Pantas '
            'itself.\n\nWeb purchases. On the web, you buy Pro access in '
            'advance and pay through PayMongo. Web purchases do not renew '
            'automatically. If you want more access, you buy again. A web '
            'purchase does not cancel a separate store '
            'subscription.\n\nPrice. The price is the amount shown in '
            'Philippine pesos on the Pro screen and at checkout when you pay. '
            'That amount is the full amount you pay. Check the plan and '
            'amount before you pay. We may change prices at any time. A '
            'change does not affect a payment you already made. Checkout '
            'shows the payment methods you can use.\n\nPlans. Weekly access '
            'lasts seven days. Monthly access lasts one calendar month. '
            'Yearly access lasts one calendar year. These plans give Civil '
            'Service Pro access. Monthly and Yearly access ends on the '
            'matching date at the same time in Philippine time. If that date '
            'does not exist, it ends on the last day of that month. A Season '
            'Pass covers its named exam until the end of the last day of the '
            'exam sitting stated at checkout.\n\nWhen access starts. We turn '
            'on access after we verify your payment with PayMongo. A plan '
            'period counts from the payment time PayMongo records, or from '
            'the end of your existing qualifying Pro access, whichever is '
            'later. A Season Pass runs from payment until its stated sitting '
            'and does not add to other passes. Returning from checkout does '
            'not confirm your payment. If you paid and Pro does not appear, '
            'email support@pantas.study with your payment details.\n\nFree '
            'trial. The free trial is on Monthly only. You can get one '
            'seven-day free trial of Monthly Pro if you qualify. You qualify '
            'only if you are signed in with verified sign-in details and have '
            'not had a trial or paid Pro before. You do not enter payment '
            'details. The trial ends after seven days. It does not become a '
            'paid plan and we do not charge you. Weekly, Yearly and Season '
            'Passes have no trial. We may change or stop future trial offers. '
            'We may refuse or end a trial we reasonably suspect is being '
            'misused, for example through several accounts. Deleting your '
            'account does not give you another trial.\n\nFree or promotional '
            'access. Pantas may give free access, such as a trial, a beta '
            'period or a prize, at its choice. This access lasts only for the '
            'period we state. It can end earlier if it is misused. It does '
            'not give you a right to more access and it does not start a paid '
            'plan.\n\nRefunds. Under our voluntary refund policy, we refund '
            'in full:\n\n• an extra payment for a period that has not '
            'started, such as a payment made twice; or\n• a payment that '
            'never gave you the access you bought.\n\nEmail '
            'support@pantas.study within 30 days of the payment, with enough '
            'details to find it. We refund to the original payment method '
            'through PayMongo. The time the money takes to reach you depends '
            'on PayMongo and your bank.\n\nWe do not give refunds for a '
            'change of mind, or partial refunds for unused time. A period '
            'that has started, or a Season Pass whose exam date has passed, '
            'is outside this voluntary policy.\n\nWe may give other refunds '
            'as goodwill. A goodwill refund does not create a right to more '
            'refunds. A partial refund shortens the original access period in '
            'proportion to the total refunded, which can end access at once. '
            'A full refund ends that access.\n\nThese limits and the 30-day '
            'deadline do not limit any remedy Philippine law gives you, such '
            'as for a service that did not work as promised.\n\nDisputes with '
            'your bank. If you dispute a payment with your bank or card '
            'issuer, we may suspend the access that payment gave while the '
            'dispute is open. If the payment is reversed, that access ends. '
            'If the dispute is resolved in our favor, we lift the suspension. '
            'The original end date of that access still applies. We may '
            'restrict an account we reasonably suspect of fraud or '
            'abuse.\n\nEnding Pro. When your Pro access ends, Pro-only '
            'features stop unless another plan or pass covers the exam. You '
            'can keep using Free features. Pro backup and syncing stop while '
            'you do not have Pro. Ending Pro does not by itself delete your '
            'progress. Your data follows the storage periods in our privacy '
            'notices.\n\nDeleting your account. If you delete your account, '
            'your access ends, including any time left on a plan. Deleting '
            'your account is not a refund request. The same applies if a '
            'parent or guardian withdraws permission for an under-18 '
            'account.\n\nStudents under 18. If you are under 18, your parent '
            'or guardian should make the purchase with their own payment '
            'method, and they accept these Terms as the buyer. The buyer must '
            'be allowed to use the payment method chosen. If we learn that a '
            "purchase was made without a parent's or guardian's agreement, we "
            'may cancel it, refund it and end the access.\n\nComplaints. Send '
            'purchase complaints to support@pantas.study with the transaction '
            'reference and a description of the problem. If it is unresolved '
            'after seven calendar days, our internal complaint process is '
            'deemed exhausted.',
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
    updatedAt: DateTime.utc(2026, 11, 10),
    sections: const [
      LegalSection(
        heading: 'Who this is for',
        body: 'This notice is for teens ages 13 to 17 and for their parents '
            'or guardians. Pantas is for people aged 13 and older.\n\nIf you '
            'are 18 or older, read the Privacy Policy instead.',
      ),
      LegalSection(
        heading: 'Who runs Pantas',
        body: 'Pantas is run by Aerol Dwayne Daños Balayon, trading as Pantas '
            'Online Tutorial Services, a sole proprietorship. He is also the '
            'Data Protection Officer.\n\nAddress: Poblacion, Norala, South '
            'Cotabato, Philippines.\n\nQuestions about your data: '
            'dpo@pantas.study\nHelp or payment problems: support@pantas.study',
      ),
      LegalSection(
        heading: 'Why we ask your age',
        body: 'When you set up Pantas, we ask you to enter your correct '
            'current age in full years. We use it once, on your device, to '
            'decide whether you can use Pantas and whether a parent or '
            'guardian must consent. Based on the age you enter, Pantas blocks '
            "use if you are under 13 and requires your parent or guardian's "
            'consent if you are 13 to 17. We use your age only on your '
            'device without saving it and keep only the resulting age group '
            'there. Our servers never receive your age.\n\n'
            'If you are in the under-18 group, we record that on our '
            "servers with your guardian's request, so a parent or guardian "
            'can confirm.',
      ),
      LegalSection(
        heading: 'What we collect',
        body: '• Account: an account ID, which Pantas creates even before you '
            'sign in. If you sign in with Google, we also receive your name, '
            'email address and profile photo. If you sign in with an email '
            'code, we receive your email address.\n• Study records: your '
            'study settings, answers, results, study times, bookmarked '
            'lessons and flagged questions.\n• Guardian request: your '
            "guardian's name and email address. We keep the request status, "
            'its dates, a partly hidden version of the email address, and '
            'protected codes made from the email address and the link. Our '
            "servers do not keep the full email address. Your guardian's full "
            'name and email address stay on your device so you can resend the '
            'request. Your device deletes them once it learns the guardian '
            "has confirmed.\n• Guardian answer record: your guardian's "
            'answer, when it happened, which versions of our notices and '
            'terms were shown, and your account ID. It holds no name or email '
            'address.\n• Payments: if someone buys Pro for your account, we '
            'keep payment references, amounts, payment status, refunds and '
            "access dates. Card and wallet details are entered on PayMongo's "
            'checkout page.\n• Free trial: protected codes made from your '
            'verified sign-in details, so we can check whether a trial was '
            'already used.\n• Share cards: if you choose to share a Wrapped '
            'card, we keep the card image, its public page, and a share '
            'record with your account ID and study-style label. Where the '
            'Wrapped screen offers it, revoking a card removes the image and '
            'turns off its public page. To remove a card another way, email '
            'dpo@pantas.study.\n• Messages: emails you or your guardian send '
            'to support@pantas.study or dpo@pantas.study.\n• Technical '
            'records: security and account records, such as sign-ins, payment '
            'checks and account deletions.',
      ),
      LegalSection(
        heading: 'How Pantas uses your answers',
        body: 'Software uses your answers and study timing to choose review '
            'dates and show study guidance. It also gives you a study-style '
            'label, such as the ones on share cards. These suggestions affect '
            'what Pantas recommends next. They do not decide any official '
            'exam eligibility or result.',
      ),
      LegalSection(
        heading: 'Optional usage sharing',
        body: 'You choose whether to share extra usage data to help improve '
            'Pantas. It starts off. It is a separate choice from setting up '
            'your account, and leaving it off does not stop you from using '
            'Pantas.\n\nIf you turn it on, reports include the screens and '
            'features you use, your study sessions, question IDs, the answer '
            'you chose, and whether it was correct. These reports are linked '
            'to your account ID. The phone app can also send error '
            'reports.\n\nTo turn it off, open Settings, then About, and use '
            '"Help improve Pantas by sharing usage data." You or your '
            'guardian can also email dpo@pantas.study about reports already '
            'collected.',
      ),
      LegalSection(
        heading: 'Speed and error reports',
        body: 'To find slow screens and errors, the web app sends short '
            'technical reports. They include the app version, whether this is '
            'a first visit, a return visit or the first visit after an '
            'update, your browser family, your screen-size group, loading '
            'times, and error messages, counts and locations in our code. We '
            'filter common identifiers, such as email addresses, before a '
            'report is sent. Error text may still contain personal '
            'information. We do not deliberately include your answers or '
            'lesson content.\n\nReports have no dedicated account ID or IP '
            'address field. Sending a report uses your sign-in session, '
            'including a guest session, to check the request and to limit how '
            "many reports are sent. Google's connection logs for these "
            'reports also record your IP address and full browser details. We '
            'do not use them to identify you.\n\nWe keep these report logs '
            'for 30 days. These reports are on for everyone who uses the web '
            'app and are separate from optional usage sharing. To object, '
            'email dpo@pantas.study.',
      ),
      LegalSection(
        heading: 'Why a guardian confirms',
        body: 'If you are in the under-18 group, Pantas asks a parent or '
            'guardian to read the terms and confirm before you '
            'continue.\n\nOpening the email link confirms nothing. The adult '
            'must tick the agreement box and choose Confirm. They can choose '
            '"I Don\'t Agree" instead.\n\nThe link works once and expires '
            'after seven days. A new link replaces the old one.\n\nAnyone '
            'holding the link can use it to respond. Keep it private. The '
            "link does not prove someone's identity or authority. Contact us "
            'if a link is lost, shared or misused.',
      ),
      LegalSection(
        heading: 'What your guardian can do',
        body: 'Your guardian can confirm or decline the request. Confirming '
            'does not give them a screen showing your results.\n\nYour '
            'guardian can email our Data Protection Officer about your data '
            'or to withdraw permission. We may ask for information we '
            'reasonably need to check who is asking before we share '
            'information or act on instructions.',
      ),
      LegalSection(
        heading: 'Where your data goes',
        body: 'Some records stay in your browser or on your phone. On the '
            'web, your answers and study activity also go to our servers, '
            "including on Free. Our servers run in Google's Singapore region. "
            'Pro adds backup and syncing across devices.\n\nWe use these '
            'providers:\n\n• Google (Firebase and Google Cloud): accounts, '
            'our servers, optional usage reports, and speed and error '
            'reports.\n• Resend: guardian emails and sign-in codes.\n• '
            'PayMongo: web payments.\n• RevenueCat and the app store you use: '
            'app-store purchases and the Pro access they give.\n\nThese '
            'providers may process data outside the Philippines. We do not '
            'sell your data and we do not show ads.',
      ),
      LegalSection(
        heading: 'Your rights',
        body: 'You have the right to be informed about how your data is used. '
            'You can ask for a copy of your data, including in a common '
            'electronic format where the law allows. You can object to how it '
            'is used, ask us to fix wrong details, and ask us to stop using, '
            'block or delete data, when the law allows. You can ask for '
            'compensation where the law provides it. You can also complain to '
            'the National Privacy Commission.\n\nYour guardian can use these '
            'rights for you while you are under 18. Send requests to '
            'dpo@pantas.study. We reply within 15 calendar days. We may ask '
            'for information we reasonably need to check who you are. If we '
            'cannot fully act on a request, we explain why.',
      ),
      LegalSection(
        heading: 'Withdrawing permission or deleting data',
        body: 'You can withdraw a permission you gave, such as optional usage '
            'sharing, at any time. Withdrawing is free.\n\nTo withdraw '
            'permission for a child to use Pantas, a parent or guardian '
            'emails dpo@pantas.study with a message such as: "I withdraw my '
            'permission for my child to use Pantas." Send it from the email '
            "address used for confirmation if you can. Include the child's "
            'sign-in email or account ID if you know it. If you do not, tell '
            'us and we will help find the account.\n\nAfter we check the '
            'request, we stop the use of data that depended on that '
            'permission. Pantas cannot work without permission for study '
            'records, so withdrawing it means we close the account and delete '
            'its study records. We keep only the records described below that '
            'have another lawful reason.\n\nWithdrawing does not undo use of '
            'data that was lawful before you withdrew. It does not cancel an '
            'app store subscription. It is not a refund request. Refunds '
            'follow the Terms.\n\nAfter setup, you can delete your account '
            'yourself. Open Settings, then Account, then the delete option. '
            'If you are still waiting for a guardian to confirm, email '
            'dpo@pantas.study instead. For an account signed in with Google '
            'or an email code, deleting removes your study records from our '
            'servers, and clears study records and account settings on the '
            'device you use. Some device preferences remain. You may need to '
            'sign in again first. For an account that is not signed in, it '
            'clears study records and account settings on your device only. '
            'To remove server records of such an account, email '
            'dpo@pantas.study.\n\nDeleting your account removes its study '
            'records. Limited trial-use, guardian-answer, security and '
            'required accounting records may remain for the purposes and '
            'periods in the next section. Copies on your other devices stay '
            "until you clear them. Copies in our providers' backups can take "
            'longer to disappear. For sign-in data, Google removes them '
            'within 180 days.',
      ),
      LegalSection(
        heading: 'How long we keep data',
        body: '• Study records and settings: while your account exists. They '
            'are deleted when you delete your account or when the account is '
            'closed after a withdrawal.\n• Guardian requests and links: a '
            'link stops working after seven days. Our hourly cleanup then '
            'deletes expired requests and links. A used, declined or replaced '
            'link is deleted seven days after that event.\n• Guardian answer '
            'record: kept after account deletion, for as long as we may need '
            'it to show that permission was given or to answer a legal '
            'claim.\n• Free-trial codes: kept after account deletion, so a '
            'trial cannot be repeated. They have no set end date yet.\n• '
            'Payment records in Pantas: deleted with your account. PayMongo '
            'keeps its own transaction records under its own rules. '
            'Accounting records that tax law requires, such as invoices, are '
            'kept for five years, counted as that law requires.\n• Account '
            'and payment audit records: 730 days after the event.\n• Optional '
            'usage reports: kept under the retention setting of our Google '
            'Analytics account. Google starts removing phone error reports '
            'after 90 days.\n• Speed and error report logs from the web app: '
            '30 days.\n• Share cards: the image and public page until you '
            'revoke the card or delete your account. The share record stays '
            'until your account is deleted.\n• Messages to us: kept for up to '
            'two years after the matter closes, then deleted.\n\nIf the law '
            'requires it, or we need specific records for a legal claim, we '
            'may keep those records longer.',
      ),
      LegalSection(
        heading: 'Why we may use your data',
        body: '• Age check: needed to decide whether a guardian must confirm '
            'before you use Pantas. We use your age only on your device '
            'without saving it and keep only the resulting age group there. '
            'For '
            "an under-18 account, your guardian's permission covers the "
            'age-group record.\n• Account and payment records: we need them '
            'to provide the service you asked for.\n• Study records: your '
            "permission at setup and your guardian's permission. Answers and "
            'results can relate to education.\n• Optional usage sharing: your '
            'separate choice. You can withdraw it at any time.\n• Speed and '
            'error reports, security records, guardian requests and trial '
            'codes: our legitimate interest in keeping Pantas working, safe '
            'and fair. We keep each to what we need.\n• Guardian answer '
            'records kept after deletion: to establish or defend legal '
            'claims.\n• Accounting records: the law requires them.',
      ),
      LegalSection(
        heading: 'Changes to this notice',
        body: 'When we change this notice, we update it here and change the '
            'date at the top.',
      ),
      LegalSection(
        heading: 'Payments for minors',
        body: 'If you are under 18, ask your parent or guardian to make the '
            'purchase with their own payment method. They accept the Terms as '
            'the buyer. Confirming your account is not a purchase.',
      ),
    ],
  ),
};
