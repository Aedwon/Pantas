import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/features/home/application/server_today.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// Everything the Home masthead needs from selected exam/settings state.
@immutable
class HomeMastheadData {
  const HomeMastheadData({
    required this.name,
    required this.examShortName,
    required this.examDate,
  });

  /// Retained because the settings source owns it. Task 2 intentionally does
  /// not render the student's name in the approved Home greeting.
  final String? name;
  final String examShortName;
  final ExamDate? examDate;

  @override
  bool operator ==(Object other) =>
      other is HomeMastheadData &&
      other.name == name &&
      other.examShortName == examShortName &&
      other.examDate == examDate;

  @override
  int get hashCode => Object.hash(name, examShortName, examDate);
}

final homeMastheadProvider = FutureProvider<HomeMastheadData>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final settings = await ref.watch(userSettingsProvider.future);
  final name = settings.name?.trim();
  return HomeMastheadData(
    name: name == null || name.isEmpty ? null : name,
    examShortName: focus.exam?.shortName ?? '',
    examDate: settings.examDate,
  );
});

@immutable
class HomeWeekStripData {
  HomeWeekStripData({
    required List<WeekDayState> states,
    required this.todayFraction,
    Map<int, WeekDayState> around = const {},
  })  : assert(
          states.length == 7,
          'Home week strips require exactly seven days.',
        ),
        states = List.unmodifiable(states),
        around = Map.unmodifiable(around);

  /// Sunday to Saturday of the current week.
  final List<WeekDayState> states;
  final double todayFraction;

  /// Days just outside the week, by their offset from its Sunday (-2, -1, 7
  /// and 8), for the phone strip's window that crosses a week boundary (D196).
  final Map<int, WeekDayState> around;

  /// The state of [day], given the Sunday that starts the week. A day with no
  /// known state is plain: no dot, no status and not dimmed. Its history is
  /// unknown, so it must not read as a rest day.
  WeekDayState stateOn(DateTime day, DateTime weekStart) {
    final from = DateTime.utc(weekStart.year, weekStart.month, weekStart.day);
    final offset =
        DateTime.utc(day.year, day.month, day.day).difference(from).inDays;
    if (offset >= 0 && offset < 7) return states[offset];
    return around[offset] ?? WeekDayState.plain;
  }
}

/// The approved Home week strip, derived from the persisted roadmap and the
/// same completion facts used by the roadmap itself.
final weekStripProvider =
    FutureProvider.family<HomeWeekStripData, ExamId>((ref, examId) async {
  ref.watch(roadmapRevisionProvider);

  final now = ref.watch(nowProvider)();
  final today = localDay(now);
  final settings = await ref.watch(userSettingsProvider.future);

  if (ref.watch(studyUsesServerProvider)) {
    final remote = await ref.watch(serverStudyRoadmapProvider(examId).future);
    final plan = remote.today;
    final remaining = remote.remaining;
    return HomeWeekStripData(
      states: serverWeekStates(remote.weekDays),
      // The server sends the week only. Days beyond it are planned if they
      // are study days; the days before it are unknown, so they carry no
      // status rather than an invented one.
      around: {
        for (final offset in const [7, 8])
          offset: settings.studyDays.isStudyDay(
            DateTime(today.year, today.month, today.day)
                .add(Duration(days: offset - today.weekday % 7)),
          )
              ? WeekDayState.plain
              : WeekDayState.dayOff,
      },
      todayFraction: todayCompletionFraction(
        total: [
          ...plan.lessonIds,
          ...plan.reviewQuestionIds,
          ...plan.newQuestionIds,
        ].where((id) => !plan.advancedIds.contains(id)).length,
        left: [
          ...remaining.lessonIds,
          ...remaining.reviewQuestionIds,
          ...remaining.newQuestionIds,
        ].where((id) => !plan.advancedIds.contains(id)).length,
      ),
    );
  }

  // Ensure today's canonical snapshot has been built before the strip reads
  // the repository directly. This does not build or mutate historical days.
  final roadmapToday = await ref.watch(roadmapTodayProvider(examId).future);
  final repository = ref.read(roadmapDayRepositoryProvider);
  final reader = ref.read(roadmapInputsReaderProvider);
  final todayFacts = await reader.completion(now);
  final todayTotal = _count(
    DaySnapshots.originalCounts(roadmapToday.snapshot.plan),
  );
  final todayLeft = _count(
    DaySnapshots.originalLeftCounts(roadmapToday.snapshot, todayFacts),
  );

  final weekStart = PantasDates.weekStart(today);
  final states = <WeekDayState>[];

  for (var offset = -2; offset < 9; offset++) {
    final day =
        DateTime(weekStart.year, weekStart.month, weekStart.day + offset);
    final isToday = day == today;
    final isFuture = day.isAfter(today);
    final isStudyDay = settings.studyDays.isStudyDay(day);

    if (isToday) {
      states.add(
        classifyWeekDay(
          isToday: true,
          isStudyDay: isStudyDay,
          isFuture: false,
          total: todayTotal,
          left: todayLeft,
        ),
      );
      continue;
    }

    if (!isStudyDay || isFuture) {
      states.add(
        classifyWeekDay(
          isToday: false,
          isStudyDay: isStudyDay,
          isFuture: isFuture,
          total: null,
          left: null,
        ),
      );
      continue;
    }

    final snapshot = await repository.read(examId, day);
    if (snapshot == null) {
      states.add(
        classifyWeekDay(
          isToday: false,
          isStudyDay: true,
          isFuture: false,
          total: null,
          left: null,
        ),
      );
      continue;
    }

    final facts = await reader.completionSince(examId, day);
    states.add(
      classifyWeekDay(
        isToday: false,
        isStudyDay: true,
        isFuture: false,
        total: _count(DaySnapshots.originalCounts(snapshot.plan)),
        left: _count(DaySnapshots.originalLeftCounts(snapshot, facts)),
      ),
    );
  }

  // states holds offsets -2 to 8: the week sits at indexes 2 to 8.
  return HomeWeekStripData(
    states: states.sublist(2, 9),
    around: {
      -2: states[0],
      -1: states[1],
      7: states[9],
      8: states[10],
    },
    todayFraction: todayCompletionFraction(total: todayTotal, left: todayLeft),
  );
});

@visibleForTesting
WeekDayState classifyWeekDay({
  required bool isToday,
  required bool isStudyDay,
  required bool isFuture,
  required int? total,
  required int? left,
}) {
  if (isToday) return WeekDayState.today;
  if (!isStudyDay) return WeekDayState.dayOff;
  if (isFuture) return WeekDayState.plain;
  if (total == null || left == null) return WeekDayState.missed;
  if (left <= 0) return WeekDayState.done;
  if (total > 0 && left < total) return WeekDayState.partial;
  return WeekDayState.missed;
}

@visibleForTesting
double todayCompletionFraction({required int total, required int left}) {
  if (total <= 0) return 0;
  return ((total - left) / total).clamp(0.0, 1.0);
}

int _count(RoadmapDayCounts counts) =>
    counts.lessons + counts.newQuestions + counts.reviews;
