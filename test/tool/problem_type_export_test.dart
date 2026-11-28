import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'exports rendered type records separately from legacy questions',
    () async {
      final temp = Directory.systemTemp.createTempSync('problem-export');
      addTearDown(() => temp.deleteSync(recursive: true));
      final output = File('${temp.path}/export.json');
      final result = await Process.run('dart', [
        'tools/build_content_export/build_content_export.dart',
        output.path,
      ]);
      expect(result.exitCode, 0, reason: result.stderr.toString());
      final json =
          jsonDecode(output.readAsStringSync()) as Map<String, Object?>;
      expect(json['problemTypes'], isA<List<Object?>>());
      final records =
          (json['problemTypes']! as List<Object?>).cast<Map<String, Object?>>();
      final record = records.firstWhere(
        (row) =>
            (row['question']! as Map<String, Object?>)['id'] ==
            'qt-spatial-abstract-reasoning-series-dots-size',
      );
      final free = record['free']! as Map<String, Object?>;
      final variants =
          (free['variants']! as List<Object?>).cast<Map<String, Object?>>();
      expect(variants.first['variantIndex'], 0);
      expect(variants.first['explanation'], isNot(contains('{answerText}')));
      expect(jsonEncode(free), isNot(contains('rationale')));
      expect(
        (record['pro']! as Map<String, Object?>)['rationales'],
        contains('0'),
      );
      final activity = json['mergedQuestionActivity']! as Map<String, Object?>;
      final singles =
          (json['question']! as List<Object?>).cast<Map<String, Object?>>();
      for (final row
          in singles.where((row) => activity.containsKey(row['_id']))) {
        expect(row['isActive'], isFalse);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
