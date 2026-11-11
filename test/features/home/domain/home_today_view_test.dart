import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/domain/home_today_view.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

DayPlan plan({
  DateTime? day,
  List<String> lessons = const [],
  List<String> reviews = const [],
  List<String> fresh = const [],
  bool mock = false,
  bool rest = false,
}) =>
    DayPlan(
      day: day ?? DateTime(2026, 11),
      lessonIds: lessons,
      reviewQuestionIds: reviews,
      newQuestionIds: fresh,
      isMockDay: mock,
      isRestDay: rest,
      advancedIds: const {},
    );

HomeTodayView view({
  RoadmapState state = RoadmapState.planning,
  DayPlan? today,
  bool originalDone = false,
  bool canAdvance = false,
  String examDate = '2026-11-11:day',
}) =>
    homeTodayViewFor(
      state: state,
      plan: today ?? plan(lessons: ['l1']),
      originalDone: originalDone,
      canAdvance: canAdvance,
      examDate: examDate,
    );

void main() {
  test('roadmap states that replace Today map to their own cards', () {
    expect(
      view(state: RoadmapState.noContent).kind,
      HomeTodayKind.noContent,
    );
    expect(
      view(state: RoadmapState.examPassedAwaitingAnswer).kind,
      HomeTodayKind.passed,
    );
    expect(
      view(state: RoadmapState.needsAssessment).kind,
      HomeTodayKind.assessment,
    );
  });

  test('exam day shows the warm-up even on a rest weekday', () {
    final result = view(
      today: plan(day: DateTime(2026, 11, 11), reviews: ['q'], rest: true),
    );
    expect(result.kind, HomeTodayKind.examDay);
  });

  test('a month-only exam date is never exam day', () {
    final result = view(
      examDate: '2026-11-01:month',
      today: plan(day: DateTime(2026, 11), lessons: ['l']),
    );
    expect(result.kind, HomeTodayKind.checklist);
  });

  test('an empty rest day is a day off, never nothing due', () {
    final result = view(today: plan(rest: true), canAdvance: true);
    expect(result.kind, HomeTodayKind.dayOff);
    expect(result.offersAdvance, isTrue);
  });

  test('day off hides advance when it would add nothing', () {
    final result = view(today: plan(rest: true));
    expect(result.kind, HomeTodayKind.dayOff);
    expect(result.offersAdvance, isFalse);
  });

  test('an empty study day with everything covered is nothing due', () {
    final result = view(state: RoadmapState.allCovered, today: plan());
    expect(result.kind, HomeTodayKind.nothingDue);
  });

  test('an empty day in the review-only stretch says so', () {
    final result = view(state: RoadmapState.reviewOnly, today: plan());
    expect(result.kind, HomeTodayKind.reviewOnly);
  });

  test('a mock day is never empty', () {
    final result = view(today: plan(mock: true));
    expect(result.kind, HomeTodayKind.checklist);
  });

  test('done review-only week ends with its own line and no advance', () {
    final result = view(
      state: RoadmapState.reviewOnly,
      today: plan(day: DateTime(2026, 11, 6), reviews: ['q']),
      originalDone: true,
    );
    expect(result.kind, HomeTodayKind.checklist);
    expect(result.doneNote, HomeDoneNote.reviewWeek);
  });

  test('the day before the exam says it is tomorrow', () {
    final result = view(
      state: RoadmapState.reviewOnly,
      today: plan(day: DateTime(2026, 11, 10), reviews: ['q']),
      originalDone: true,
    );
    expect(result.doneNote, HomeDoneNote.lastDay);
  });

  test('done with nothing to bring forward still closes the day', () {
    final result = view(
      today: plan(lessons: ['l']),
      originalDone: true,
    );
    expect(result.doneNote, HomeDoneNote.plain);
  });

  test('done with advance available shows no closing note of its own', () {
    final result = view(
      today: plan(lessons: ['l']),
      originalDone: true,
      canAdvance: true,
    );
    expect(result.doneNote, isNull);
  });

  test('unfinished work has no closing note', () {
    expect(view().doneNote, isNull);
  });
}
