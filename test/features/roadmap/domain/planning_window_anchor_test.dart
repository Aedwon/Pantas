import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/features/roadmap/domain/planning_window.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

void main() {
  final dec7 = ExamDate.onDay(DateTime(2026, 12, 7));

  test('an anchored review-only date holds as the exam nears', () {
    final window = PlanningWindows.resolve(
      today: DateTime(2026, 11, 25),
      examDate: dec7,
      anchoredReviewOnlyFrom: DateTime(2026, 11, 30),
    );
    expect(window.reviewOnlyFrom, DateTime(2026, 11, 30));
    expect(window.workingDays, 5);
    expect(window.quiet, 7);
  });

  test('on or after the anchored date there are no working days', () {
    final window = PlanningWindows.resolve(
      today: DateTime(2026, 12, 2),
      examDate: dec7,
      anchoredReviewOnlyFrom: DateTime(2026, 11, 30),
    );
    expect(window.workingDays, 0);
    expect(window.daysLeft, 5);
    expect(window.state, RoadmapState.reviewOnly);
  });

  test('an anchor after the exam day is ignored', () {
    final window = PlanningWindows.resolve(
      today: DateTime(2026, 9, 30),
      examDate: dec7,
      anchoredReviewOnlyFrom: DateTime(2026, 12, 20),
    );
    expect(window.reviewOnlyFrom, DateTime(2026, 11, 30));
  });
}
