import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/legal/legal.dart';

/// The signed-off public-launch texts. The app must carry them word for
/// word, so this test reports any difference after whitespace and markdown
/// markers are normalized.
const _folder = 'docs/legal-drafts/2026-11-22-public-launch';
const _files = <String, String>{
  'privacy': '$_folder/privacy-policy.md',
  'terms': '$_folder/terms.md',
  'teens': '$_folder/teen-notice.md',
};

String _normalize(String text) => text
    .replaceAll('**', '')
    .replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Splits a signed-off file into its `## ` sections. Lines between the first
/// `---` and the first `## `, except the version stamp, belong to the first
/// section: they are part of the published text. Everything above the `---`
/// is drafting notes and is not published.
Map<String, String> _sections(List<String> lines) {
  final rule = lines.indexWhere((l) => l.trim() == '---');
  expect(rule, greaterThan(0), reason: 'no --- line');
  final sections = <String, StringBuffer>{};
  final lead = StringBuffer();
  StringBuffer? current;
  for (final line in lines.sublist(rule + 1)) {
    if (line.startsWith('## ')) {
      current = sections[line.substring(3)] = StringBuffer();
    } else if (current == null) {
      if (!line.startsWith('**Version:**')) lead.writeln(line);
    } else {
      current.writeln(line);
    }
  }
  final first = sections.keys.first;
  sections[first] = StringBuffer('$lead\n${sections[first]}');
  return {for (final e in sections.entries) e.key: _normalize('${e.value}')};
}

void main() {
  for (final entry in _files.entries) {
    group(entry.key, () {
      late String source;
      late Map<String, String> review;
      late LegalDocument document;
      setUpAll(() {
        source = File(entry.value).readAsStringSync();
        review = _sections(source.split('\n'));
        document = legalDocumentFallbacks[entry.key]!;
      });

      test('the signed-off file has no brackets and no em dashes', () {
        expect(source, isNot(contains('[')));
        expect(source, isNot(contains('—')));
      });

      test('the app has the same sections in the same order', () {
        expect(document.sections.map((s) => s.heading), review.keys);
      });

      test('the app text matches the signed-off file word for word', () {
        final differences = <String>[];
        for (final s in document.sections) {
          final expected = review[s.heading];
          if (expected != null && _normalize(s.body) != expected) {
            differences.add('${s.heading}: text differs');
          }
        }
        expect(differences, isEmpty);
      });

      test('the document date matches its guardian version stamp', () {
        final d = document.updatedAt;
        final stamp = '${d.year}-${d.month.toString().padLeft(2, '0')}-'
            '${d.day.toString().padLeft(2, '0')}';
        expect(stamp, guardianDocumentVersions[entry.key]);
      });
    });
  }
}
