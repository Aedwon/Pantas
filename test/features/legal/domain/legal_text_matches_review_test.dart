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

  test('teens, privacy and the replaced Terms sections match the review', () {
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
      'Study content and results',
      'Changes, suspension and ending',
      'Limits of responsibility',
      'Intellectual property',
      'Governing law and disputes',
      'Changes to these Terms',
    ]);

    final differences = [
      ..._differences('teens', docs['teens']!.sections, teens),
      ..._differences('privacy', docs['privacy']!.sections, privacy),
      ..._differences(
        'terms',
        docs['terms']!.sections,
        {...subscriptions, ...terms},
      ),
    ];
    expect(differences, isEmpty);
  });
}
