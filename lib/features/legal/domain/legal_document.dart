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
    updatedAt: DateTime.utc(2026, 5, 23),
    sections: const [
      LegalSection(
        heading: 'Your data',
        body: 'CSE Reviewer keeps your study progress, quiz attempts, mock '
            'exam results, preferences, and account details so the app can '
            'save your work across devices. Regenerable content stays in '
            'content.db and is not synced as user data.',
      ),
      LegalSection(
        heading: 'Your RA 10173 rights',
        body: 'Under RA 10173, you may request access, correction, export, '
            'or deletion of your personal data. Send export or correction '
            'requests to our Data Protection Officer. To delete your account '
            'inside the app, open /settings/account.',
      ),
      LegalSection(
        heading: 'Notifications',
        body: 'The app uses local reminders on your device. Version 1 does '
            'not store FCM tokens or send server push notifications.',
      ),
    ],
  ),
  'terms': LegalDocument(
    id: 'terms',
    title: 'Terms of Service',
    updatedAt: DateTime.utc(2026, 7, 18),
    sections: const [
      LegalSection(
        heading: 'Use of the app',
        body: 'CSE Reviewer is a study tool. It does not guarantee exam '
            'results or replace official exam instructions.',
      ),
      LegalSection(
        heading: 'Subscriptions',
        body: 'Paid features depend on your active store subscription. '
            'Manage billing through the store account used for purchase.',
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
};
