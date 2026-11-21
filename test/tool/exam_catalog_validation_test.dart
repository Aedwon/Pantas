import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog contains valid unique exams and only supplied sittings', () {
    final entries =
        (jsonDecode(File('content/exams/catalog.json').readAsStringSync())
                as List<dynamic>)
            .cast<Map<String, dynamic>>();
    expect(entries.map((e) => e['id']).toSet().length, entries.length);
    expect(entries.length, 18);
    for (final entry in entries) {
      expect(entry['name'], isNotEmpty);
      expect(entry['shortName'], isNotEmpty);
      expect(
        {'Student', 'Civil Service', 'Licensure', 'PSHS-NCE'},
        contains(entry['priceTier']),
      );
      expect(
        {
          'College entrance',
          'Scholarships',
          'High school',
          'Civil service',
          'Licensure',
          'Uniformed services',
        },
        contains(entry['group']),
      );
      expect(entry['comingSoon'], isA<bool>());
      final sittings = (entry['publishedSittings'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final sitting in sittings) {
        for (final field in ['firstDay', 'lastDay']) {
          final date = sitting[field] as String;
          expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date), isTrue);
          expect(DateTime.parse(date).toIso8601String().substring(0, 10), date);
        }
        expect(
          DateTime.parse(sitting['lastDay'] as String)
              .isBefore(DateTime.parse(sitting['firstDay'] as String)),
          isFalse,
        );
        expect(Uri.parse(sitting['sourceUrl'] as String).scheme, 'https');
        expect(Uri.parse(sitting['sourceUrl'] as String).host, isNotEmpty);
      }
      if (['exam_cse_pro', 'exam_cse_sub'].contains(entry['id'])) {
        expect(
          sittings.map((s) => s['firstDay']),
          ['2027-03-14', '2027-08-08'],
        );
        expect(sittings.map((s) => s['lastDay']), ['2027-03-14', '2027-08-08']);
      } else {
        expect(sittings, isEmpty);
      }
    }
  });

  test('available catalog exams and PSHS-NCE have export rows', () async {
    final dir = Directory.systemTemp.createTempSync('pantas_catalog_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final output = '${dir.path}/export.json';
    final result = await Process.run('dart', [
      'run',
      'tools/build_content_export/build_content_export.dart',
      output,
    ]);
    expect(result.exitCode, 0, reason: result.stderr.toString());
    final export =
        jsonDecode(File(output).readAsStringSync()) as Map<String, dynamic>;
    final exams = {
      for (final exam
          in (export['exam'] as List<dynamic>).cast<Map<String, dynamic>>())
        exam['_id'] as String: exam,
    };
    expect(exams.keys, containsAll(['exam_dost_sei', 'exam_sm_foundation']));
    expect(
      exams.keys,
      contains('exam_pshs_nce'),
      reason: 'The export must include the exam row for PSHS-NCE questions',
    );
    final pshsNce = exams['exam_pshs_nce']!;
    expect(pshsNce['code'], 'PSHS_NCE');
    expect(pshsNce['name'], 'PSHS National Competitive Examination');
    expect(pshsNce['shortName'], 'PSHS-NCE');
    expect(pshsNce['language'], 'en');
    expect(pshsNce['isActive'], isTrue);
    final catalog =
        (jsonDecode(File('content/exams/catalog.json').readAsStringSync())
                as List<dynamic>)
            .cast<Map<String, dynamic>>();
    for (final entry in catalog) {
      if (entry['comingSoon'] == false && entry['id'] != 'exam_sm_foundation') {
        expect(exams.keys, contains(entry['id']));
      }
    }
  });
}
