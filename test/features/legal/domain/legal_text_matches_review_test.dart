import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/legal/legal.dart';

/// The reviewed texts, copied from the review file Aedwon checked. The app
/// must carry them word for word, so this test reports any difference after
/// whitespace and markdown markers are normalized.
const _reviewPath = 'test/fixtures/legal/2026-11-09-legal-texts-review.md';

String _normalize(String text) => text
    .replaceAll('**', '')
    .replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Splits the lines between two `## ` markers into `### ` sections.
Map<String, String> _reviewSections(
  List<String> lines,
  String startsWith,
  String endsWith,
) {
  final start = lines.indexWhere((l) => l.startsWith(startsWith));
  final end = lines.indexWhere((l) => l.startsWith(endsWith));
  expect(start, greaterThanOrEqualTo(0), reason: startsWith);
  expect(end, greaterThan(start), reason: endsWith);
  final sections = <String, StringBuffer>{};
  StringBuffer? current;
  for (final line in lines.sublist(start + 1, end)) {
    if (line.startsWith('### ')) {
      current = sections[line.substring(4)] = StringBuffer();
    } else if (line.trim() != '---') {
      current?.writeln(line);
    }
  }
  return {for (final e in sections.entries) e.key: _normalize('${e.value}')};
}

List<String> _differences(
  String label,
  List<LegalSection> app,
  Map<String, String> review,
) {
  final found = <String>[];
  final appByHeading = {for (final s in app) s.heading: _normalize(s.body)};
  for (final entry in review.entries) {
    final text = appByHeading[entry.key];
    if (text == null) {
      found.add('$label/${entry.key}: missing from the app');
    } else if (text != entry.value) {
      found.add('$label/${entry.key}: text differs');
    }
  }
  return found;
}

void main() {
  late List<String> lines;
  setUpAll(() {
    lines = File(_reviewPath).readAsLinesSync();
  });

  test('the review file has no em dashes', () {
    expect(lines.join('\n'), isNot(contains('—')));
  });

  test('unchanged legal sections match the prior signed review', () {
    final teens = _reviewSections(lines, '## A.', '## B.');
    final subscriptions = _reviewSections(lines, '## B.', '## C.');
    final privacy = _reviewSections(lines, '## D.', '## E.');
    final terms = _reviewSections(lines, '## E.', '## F.');
    final docs = legalDocumentFallbacks;

    expect(
      docs['teens']!.sections.map((s) => s.heading),
      teens.keys,
    );
    expect(
      docs['privacy']!.sections.map((s) => s.heading),
      privacy.keys,
    );
    // Terms order is fixed by the review file. Intellectual property is the
    // one section the review does not replace, so the app keeps its own.
    expect(docs['terms']!.sections.map((s) => s.heading), [
      'Use of the app',
      ...subscriptions.keys,
      'Accounts held for a child under 13',
      'Study content and results',
      'Changes, suspension and ending',
      'Limits of responsibility',
      'Intellectual property',
      'Governing law and disputes',
      'Changes to these Terms',
    ]);

    const revisedPrivacySections = {
      'Who this is for',
      'Who runs Pantas',
      'Why we ask your age',
      'Why we may use your data',
    };
    teens.removeWhere(
      (heading, _) =>
          revisedPrivacySections.contains(heading) ||
          heading == 'Payments for minors',
    );
    privacy.removeWhere(
      (heading, _) => revisedPrivacySections.contains(heading),
    );
    terms
      ..remove('Use of the app')
      ..remove('Governing law and disputes');
    final differences = [
      ..._differences('teens', docs['teens']!.sections, teens),
      ..._differences('privacy', docs['privacy']!.sections, privacy),
      ..._differences('terms', docs['terms']!.sections, terms),
    ];
    expect(differences, isEmpty);
  });

  test('under-13 Terms use the approved draft wording', () {
    final draft = File(
      'docs/legal/drafts/2026-11-17-under-13-legal-draft.md',
    ).readAsStringSync();
    final terms = legalDocumentFallbacks['terms']!.sections;
    final section = draft
        .split('### 2.3 New section:')
        .last
        .split('Drafting note, not for publication:')
        .first;
    final body = section
        .split('> **Accounts held for a child under 13**')
        .last
        .split('\n')
        .where((line) => line.startsWith('>'))
        .map((line) => line.substring(1))
        .join('\n')
        .replaceAll('[PENDING AEDWON DECISION 3]', '');
    final published = terms.singleWhere(
      (section) => section.heading == 'Accounts held for a child under 13',
    );
    expect(_normalize(published.body), _normalize(body));
  });
}
