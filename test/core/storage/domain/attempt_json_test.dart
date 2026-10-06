import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';

void main() {
  const legacy = <String, dynamic>{
    'questionId': 'q1',
    'questionVersion': 1,
    'chosenChoiceId': 'c2',
    'correctChoiceId': 'c1',
    'responseMs': 4200,
  };

  test('other mistake and note survive a JSON round trip', () {
    final item = AttemptItem.fromJson({
      ...legacy,
      'mistakeTag': 'other',
      'mistakeNote': 'I used the wrong formula.',
    });
    final json = item.toJson();
    expect(json['mistakeTag'], 'other');
    expect(json['mistakeNote'], 'I used the wrong formula.');
    expect(AttemptItem.fromJson(json), item);
  });

  test('unknown mistake tags decode to null', () {
    final item = AttemptItem.fromJson({...legacy, 'mistakeTag': 'future'});
    expect(item.mistakeTag, isNull);
  });

  test('old JSON has no mistake tag or note', () {
    final json = AttemptItem.fromJson(legacy).toJson();
    expect(json['mistakeTag'], isNull);
    expect(json['mistakeNote'], isNull);
  });
}
