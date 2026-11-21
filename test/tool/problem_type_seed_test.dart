import 'package:flutter_test/flutter_test.dart';

import '../../tools/build_content_seed/problem_type_seed.dart';

void main() {
  test('native adapter keeps protected notes and maps exam references', () {
    final row = nativeProblemType({
      'question': {
        'id': 'qt-example',
        'exams': ['cse-pro'],
        'isActive': false,
      },
      'free': {'id': 'qt-example'},
      'pro': {
        'rationales': {
          '0': [null, 'note'],
        },
      },
    });
    expect(row.question['isActive'], false);
    expect(row.examIds, ['exam_cse_pro']);
    expect(row.freeJson, '{"id":"qt-example"}');
    expect(row.proJson, contains('note'));
  });
}
