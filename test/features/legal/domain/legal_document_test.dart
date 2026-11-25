import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/legal/legal.dart';

void main() {
  test('teen notice publishes student wording without draft material', () {
    final document = legalDocumentFallbacks['teens'];
    expect(document, isNotNull);
    expect(document!.title, 'Notice for teens');
    expect(document.updatedAt, legalTextsPublishedAt);
    final text =
        document.sections.map((s) => '${s.heading}\n${s.body}').join('\n');
    expect(text, contains('This notice covers only accounts that a parent'));
    expect(text, contains('we do not send new guardian requests'));
    expect(text, isNot(contains('Balayon')));
    expect(
      text,
      contains('I withdraw my permission for my child to use Pantas.'),
    );
    expect(
      text,
      contains('we normally clear database audit logs after 730 days'),
    );
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
    final all = sections.map((s) => s.body).join('\n');
    expect(all, contains('Web purchases do not renew automatically.'));
    expect(all, contains('our internal process is deemed exhausted'));
    expect(all, contains('Philippine law gives you remedies'));
    final limits = sections
        .singleWhere((s) => s.heading == '10. Limits of responsibility')
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
      [
        'Who this is for',
        'Who runs Pantas',
        'Why we ask your age',
        'What we collect',
        'How Pantas uses your answers',
        'Optional usage sharing',
        'Speed and error reports',
        'Where your data goes',
        'Your rights',
        'Withdrawing permission or deleting data',
        'How long we keep data',
        'Why we may use your data',
        'Keeping data safe',
        'Changes to this policy',
      ],
    );
    expect(
      document.sections.last.body,
      'Before a change to what we collect, why we use it, how long we keep '
      'it or who receives it, we tell affected users in the app, and by '
      'email if we have an address. The change takes effect after that '
      'notice. If a change needs new permission, we ask before applying '
      'it. Changing the version date alone is not notice or permission.',
    );
  });

  test('terms fallback has stable title and last updated date', () {
    final document = legalDocumentFallbacks['terms'];

    expect(document, isNotNull);
    expect(document!.title, 'Terms of Service');
    expect(document.updatedAt, legalTextsPublishedAt);
  });

  test('terms fallback includes intellectual property clause', () {
    final document = legalDocumentFallbacks['terms'];

    expect(
      document!.sections.map((section) => section.body).join('\n'),
      allOf([
        contains('protected by applicable intellectual property laws'),
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

  group('speed and error reports notice', () {
    final sections = legalDocumentFallbacks['teens']!.sections;
    final headings = sections.map((s) => s.heading).toList();

    test('sits right after Optional usage sharing, with the approved text', () {
      final at = headings.indexOf('Optional usage sharing');
      expect(at, isNonNegative);
      expect(headings[at + 1], 'Speed and error reports');
      final body = sections[at + 1].body;
      expect(
        body,
        startsWith(
          'To find slow screens and errors, and to learn which screens are '
          'used, the web app sends short technical reports.',
        ),
      );
      expect(
        body,
        contains(
          'We keep the stored report logs for 30 days. These reports are on '
          'by default and are separate from optional usage sharing.',
        ),
      );
    });

    test('Where your data goes names Google Cloud for speed and error reports',
        () {
      final body =
          sections.singleWhere((s) => s.heading == 'Where your data goes').body;
      expect(
        body,
        contains(
          '\u2022 Google (Firebase and Google Cloud): accounts, our servers '
          'and database, security checks that confirm requests come from the '
          'real Pantas app (Firebase App Check with reCAPTCHA Enterprise), '
          'optional usage reports, and speed and error reports.',
        ),
      );
    });

    test('the legal basis for speed and error reports is the approved line',
        () {
      final basis =
          sections.singleWhere((s) => s.heading == 'Why we may use your data');
      expect(
        basis.body,
        contains(
          '\u2022 Speed and error reports, security records, trial codes, '
          "and a guardian request's contact and request details: our "
          'legitimate interest in keeping Pantas working, safe and fair, in '
          'learning which screens are used so we can improve them, and in '
          'stopping repeat free trials (Section 12(f)). We keep each to what '
          'we need.',
        ),
      );
    });

    test('no notice uses an em dash', () {
      for (final document in legalDocumentFallbacks.values) {
        for (final section in document.sections) {
          expect(
            '${section.heading}${section.body}',
            isNot(contains('\u2014')),
          );
        }
      }
    });
  });

  test('the owner name appears only in the Privacy Policy and the Terms', () {
    String all(String id) => legalDocumentFallbacks[id]!
        .sections
        .map((s) => '${s.heading}\n${s.body}')
        .join('\n');
    expect(all('privacy'), contains('Aerol Dwayne Daños Balayon'));
    expect(all('terms'), contains('Aerol Dwayne Daños Balayon'));
    expect(all('teens'), isNot(contains('Balayon')));
    for (final id in ['privacy', 'terms', 'teens']) {
      expect(all(id), contains('Pantas Online Tutorial Services'));
    }
  });

  test('the Data Protection Officer is named by title and contact', () {
    for (final id in ['privacy', 'teens']) {
      final text =
          legalDocumentFallbacks[id]!.sections.map((s) => s.body).join();
      expect(text, contains('Data Protection Officer: dpo@pantas.study'));
      expect(text, isNot(contains('He is also the Data Protection Officer')));
    }
  });

  test('the texts say an account needs age 18 or older for now', () {
    String all(String id) =>
        legalDocumentFallbacks[id]!.sections.map((s) => s.body).join();
    expect(all('terms'), contains('You must be 18 or older to create'));
    expect(all('terms'), isNot(contains('You must be 13 or older')));
    expect(all('privacy'), contains('An account needs age 18 or older'));
    for (final id in ['privacy', 'teens']) {
      expect(all(id), isNot(contains('below 13')));
    }
  });
}
