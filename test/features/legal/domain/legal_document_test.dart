import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/legal/legal.dart';

void main() {
  test('teen notice publishes student wording without draft material', () {
    final document = legalDocumentFallbacks['teens'];
    expect(document, isNotNull);
    expect(document!.title, 'Notice for teens');
    expect(document.updatedAt, DateTime.utc(2026, 11, 9));
    final text =
        document.sections.map((s) => '${s.heading}\n${s.body}').join('\n');
    expect(text, contains('This notice is for teens ages 13 to 17'));
    expect(
      text,
      contains('I withdraw my permission for my child to use Pantas.'),
    );
    expect(text, contains('730 days from the first trial grant'));
    expect(text, contains('dpo@pantas.study'));
    for (final omitted in [
      'Owner note',
      'Changes needed',
      'App behavior',
      'Laws and guidance',
      'RISKS',
      '](',
      'lib/features/',
      'functions/src/',
      'draft for review',
      'lawyer',
      'Monitor the DPO inbox',
    ]) {
      expect(text, isNot(contains(omitted)));
    }
  });

  test('web terms describe prepaid access and lawful remedies', () {
    final sections = legalDocumentFallbacks['terms']!.sections;
    final subscriptions =
        sections.singleWhere((s) => s.heading == 'Subscriptions').body;
    expect(
      subscriptions,
      contains('Web purchases do not renew automatically.'),
    );
    expect(subscriptions, contains('The November 9 to 15, 2026 beta is free.'));
    expect(subscriptions, contains('These limits do not remove any refund'));
    final limits = sections
        .singleWhere(
          (s) => s.heading == 'Use of the app and limits of responsibility',
        )
        .body;
    expect(limits, contains('gross negligence'));
    expect(limits, isNot(contains('](')));
    expect(
      legalDocumentFallbacks['privacy']!.sections.first.body,
      isNot(contains('anonymous')),
    );
  });

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
    expect(document.updatedAt, DateTime.utc(2026, 11, 9));
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
