import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/domain/debrief/miss_cause.dart';

void main() {
  for (final entry in [(1, 'second'), (2, 'seconds'), (0, 'seconds')]) {
    test('rushed cause uses ${entry.$2} for ${entry.$1}', () {
      final cause = RushedCause(
        responseSeconds: entry.$1,
        usualSeconds: 21,
        topicName: 'Chemistry',
      );
      expect(
          cause.line,
          'You answered in ${entry.$1} ${entry.$2}. '
          'You usually take 21 on Chemistry.');
    });
  }
}
