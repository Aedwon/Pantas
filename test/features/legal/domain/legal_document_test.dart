import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/legal/legal.dart';

void main() {
  test('teen notice publishes student wording without draft material', () {
    final document = legalDocumentFallbacks['teens'];
    expect(document, isNotNull);
    expect(document!.title, 'Notice for teens');
    expect(document.updatedAt, DateTime.utc(2026, 11, 11));
    final text =
        document.sections.map((s) => '${s.heading}\n${s.body}').join('\n');
    expect(text, contains('This notice is for teens ages 13 to 17'));
    expect(
      text,
      contains('I withdraw my permission for my child to use Pantas.'),
    );
    expect(
      text,
      contains('Our database security records: 730 days after the event.'),
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
    final subscriptions =
        sections.singleWhere((s) => s.heading == 'Subscriptions').body;
    expect(
      subscriptions,
      contains('Web purchases do not renew automatically.'),
    );
    expect(
      subscriptions,
      contains('our internal complaint process is deemed exhausted'),
    );
    expect(
      subscriptions,
      contains('do not limit any remedy Philippine law gives you'),
    );
    final limits = sections
        .singleWhere((s) => s.heading == 'Limits of responsibility')
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
      'We notify you before we change the processing described here. If a '
      'change needs new permission, we ask before starting it.',
    );
  });

  test('terms fallback has stable title and last updated date', () {
    final document = legalDocumentFallbacks['terms'];

    expect(document, isNotNull);
    expect(document!.title, 'Terms of Service');
    expect(document.updatedAt, DateTime.utc(2026, 11, 11));
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

  group('speed and error reports notice', () {
    final sections = legalDocumentFallbacks['teens']!.sections;
    final headings = sections.map((s) => s.heading).toList();

    test('sits right after Optional usage sharing, with the approved text', () {
      final at = headings.indexOf('Optional usage sharing');
      expect(at, isNonNegative);
      expect(headings[at + 1], 'Speed and error reports');
      expect(
        sections[at + 1].body,
        'To find slow screens and errors, the web app sends short technical '
        'reports. They include the app version, whether this is a first '
        'visit, a return visit or the first visit after an update, your '
        'browser family, your screen-size group, loading times, and error '
        'messages, counts and locations in our code. We filter common '
        'identifiers, such as email addresses, before a report is sent. '
        'Error text may still contain personal information. We do not '
        'deliberately include your answers or lesson content.\n\n'
        'Reports have no dedicated account ID or IP address field. Sending '
        'a report uses your sign-in session, including a guest session, to '
        'check the request and to limit how many reports are sent. We '
        "exclude this function's request logs from our default log "
        'storage. Google processes connection information to deliver '
        'requests.\n\n'
        'We keep the stored report logs for 30 days. These reports are on '
        'by default and are separate from optional usage sharing. The '
        'switch in Settings, then About, stops future reports from this '
        'browser or device. Repeat this on other devices. Email '
        'dpo@pantas.study for help, or for requests about reports already '
        'collected.',
      );
    });

    test('Where your data goes names Google Cloud for speed and error reports',
        () {
      final body =
          sections.singleWhere((s) => s.heading == 'Where your data goes').body;
      expect(
        body,
        contains(
          '\u2022 Google (Firebase and Google Cloud): accounts, our servers, '
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
          '\u2022 Speed and error reports, security records, guardian '
          'requests and trial codes: our legitimate interest in keeping '
          'Pantas working, safe and fair (Section 12(f)). We keep each to '
          'what we need.',
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
}
