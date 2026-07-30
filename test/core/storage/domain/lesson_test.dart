import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Lesson preserves bodyJson opaque list through serialization', () {
    const l = Lesson(
      id: 'l1',
      topicId: 't1',
      title: 'Title',
      summary: 'Summary',
      bodyJson: [
        {'type': 'paragraph', 'text': 'hello'},
      ],
      estimatedMinutes: 5,
    );
    expect(Lesson.fromJson(l.toJson()), equals(l));
  });
}
