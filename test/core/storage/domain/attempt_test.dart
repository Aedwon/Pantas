import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';

void main() {
  const base = AttemptItem(
    questionId: 'q1',
    questionVersion: 1,
    chosenChoiceId: 'c2',
    correctChoiceId: 'c1',
    responseMs: 4200,
  );

  test('an attempt item has no mistake tag until one is noted', () {
    expect(base.mistakeTag, isNull);
  });

  test('a mistake tag round-trips through json', () {
    final json = base.copyWith(mistakeTag: MistakeTag.slipped).toJson();

    expect(json['mistakeTag'], 'slipped');
    expect(AttemptItem.fromJson(json).mistakeTag, MistakeTag.slipped);
  });

  test('items written before tagging existed still parse', () {
    final legacy = <String, dynamic>{
      'questionId': 'q1',
      'questionVersion': 1,
      'chosenChoiceId': 'c2',
      'correctChoiceId': 'c1',
      'responseMs': 4200,
    };

    expect(AttemptItem.fromJson(legacy).mistakeTag, isNull);
  });
}
