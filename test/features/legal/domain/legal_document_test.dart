import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/legal/legal.dart';

void main() {
  test('privacy uses the approved plain summary', () {
    final document = legalDocumentFallbacks['privacy']!;
    expect(
      document.sections.map((s) => s.heading),
      ['What we collect', 'What we never do', 'Your rights'],
    );
    expect(
        document.sections.last.body,
        'You can see, correct or delete your data at any time. '
        'Contact our data protection officer from About.');
  });

  test('terms fallback has stable title and last updated date', () {
    final document = legalDocumentFallbacks['terms'];

    expect(document, isNotNull);
    expect(document!.title, 'Terms of Service');
    expect(document.updatedAt, DateTime.utc(2026, 7, 18));
  });

  test('terms fallback includes intellectual property clause', () {
    final document = legalDocumentFallbacks['terms'];

    expect(
      document!.sections.map((section) => section.body).join('\n'),
      allOf([
        contains('protected by copyright'),
        contains('machine-learning'),
        contains('written permission'),
      ]),
    );
  });

  test('legal contact carries real addresses and the group', () {
    expect(defaultLegalContact.dpoEmail, isNot(contains('example.com')));
    expect(defaultLegalContact.dpoEmail, contains('@'));
    expect(defaultLegalContact.supportEmail, contains('@'));
    expect(defaultLegalContact.communityGroupUrl, startsWith('https://'));
  });

  test('nothing legal still names the old product', () {
    for (final document in legalDocumentFallbacks.values) {
      for (final section in document.sections) {
        expect(section.body, isNot(contains('CSE Reviewer')));
      }
    }
    expect(defaultLegalContact.dpoEmail, isNot(contains('csecetreviewer')));
    expect(defaultLegalContact.supportEmail, isNot(contains('csecetreviewer')));
  });
}
