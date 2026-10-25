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
        heading: 'What we collect',
        body: 'Your answers, your plan and your settings, so Pantas can '
            'plan your reviews. With your permission, anonymous data '
            'about how the app is used.',
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
    updatedAt: DateTime.utc(2026, 7, 18),
    sections: const [
      LegalSection(
        heading: 'Use of the app',
        body: 'Pantas is a study tool. It does not guarantee exam '
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
