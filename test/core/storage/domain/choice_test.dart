import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Choice', () {
    test('round-trips through JSON', () {
      const choice =
          Choice(id: 'c_1', label: 'A', text: 'Hello', isCorrect: true);
      final json = choice.toJson();
      final restored = Choice.fromJson(json);
      expect(restored, equals(choice));
    });

    test('equality is value-based', () {
      const a = Choice(id: 'c_1', label: 'A', text: 'x', isCorrect: false);
      const b = Choice(id: 'c_1', label: 'A', text: 'x', isCorrect: false);
      expect(a, equals(b));
    });
  });
}
