import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Topic round-trips JSON', () {
    const t = Topic(id: 't1', subjectId: 's1', name: 'Vocabulary', ordering: 1);
    expect(Topic.fromJson(t.toJson()), equals(t));
  });
}
