import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/topic.dart';

void main() {
  test('Topic round-trips JSON', () {
    const t = Topic(id: 't1', subjectId: 's1', name: 'Vocabulary', ordering: 1);
    expect(Topic.fromJson(t.toJson()), equals(t));
  });
}
