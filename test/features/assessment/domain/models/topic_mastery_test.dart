import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/features/assessment/domain/models/topic_mastery.dart';
import 'package:flutter_test/flutter_test.dart';

Topic _topic() => const Topic(
      id: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    );

void main() {
  group('MasteryLevel derivation', () {
    test('0 of 0 → weak', () {
      expect(
        TopicMastery(topic: _topic(), correct: 0, total: 0).level,
        equals(MasteryLevel.weak),
      );
    });

    test('0% → weak', () {
      expect(
        TopicMastery(topic: _topic(), correct: 0, total: 3).level,
        equals(MasteryLevel.weak),
      );
    });

    test('40% boundary → weak', () {
      // 2/5 = 40%
      expect(
        TopicMastery(topic: _topic(), correct: 2, total: 5).level,
        equals(MasteryLevel.weak),
      );
    });

    test('41% → moderate', () {
      // 41/100 = 41%
      expect(
        TopicMastery(topic: _topic(), correct: 41, total: 100).level,
        equals(MasteryLevel.moderate),
      );
    });

    test('70% boundary → moderate', () {
      // 7/10 = 70%
      expect(
        TopicMastery(topic: _topic(), correct: 7, total: 10).level,
        equals(MasteryLevel.moderate),
      );
    });

    test('71% → strong', () {
      // 71/100 = 71%
      expect(
        TopicMastery(topic: _topic(), correct: 71, total: 100).level,
        equals(MasteryLevel.strong),
      );
    });

    test('100% → strong', () {
      expect(
        TopicMastery(topic: _topic(), correct: 3, total: 3).level,
        equals(MasteryLevel.strong),
      );
    });
  });
}
