import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/week_preview.dart';

void main() {
  test('long future previews avoid repeated calendar scans', () {
    final clock = Stopwatch()..start();
    final lessons = [
      for (var i = 0; i < 200; i++)
        RoadmapLesson(id: 'l$i', topicId: 't', ordering: i),
    ];
    final weeks = WeekPreviews.build(
      today: DateTime(2026, 10, 24),
      reviewOnlyFrom: DateTime(2031, 10, 24),
      lessonTopicOrder: ['t'],
      lessons: lessons,
      scheduledToday: {},
    );
    expect(weeks, isNotEmpty);
    expect(clock.elapsed, lessThan(const Duration(seconds: 2)));
  });
}
