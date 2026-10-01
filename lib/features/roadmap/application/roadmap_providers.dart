import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_inputs_reader.dart';
import 'package:pantas/features/roadmap/data/roadmap_change_log_repository.dart';
import 'package:pantas/features/roadmap/data/roadmap_day_repository.dart';
import 'package:pantas/features/roadmap/domain/build_roadmap.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/planning_window.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_diff.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// Today as the student sees it: the stored plan with what is done taken
/// out.
@immutable
final class RoadmapToday {
  const RoadmapToday({
    required this.snapshot,
    required this.remaining,
    required this.originalDone,
  });

  final DaySnapshot snapshot;

  /// What is left of today, in plan order.
  final DayPlan remaining;

  /// Every item today was built with is done; advancing is possible.
  final bool originalDone;

  RoadmapState get state => snapshot.state;
}

final roadmapBuilderProvider = Provider<Roadmap Function(RoadmapInputs)>(
  (_) => BuildRoadmap.call,
);

final roadmapInputsReaderProvider = Provider<RoadmapInputsReader>(
  RoadmapInputsReader.new,
);

final roadmapDayRepositoryProvider = Provider<RoadmapDayRepository>(
  (ref) => RoadmapDayRepository(ref.watch(appDatabaseProvider)),
);

final roadmapChangeLogRepositoryProvider = Provider<RoadmapChangeLogRepository>(
  (ref) => RoadmapChangeLogRepository(ref.watch(appDatabaseProvider)),
);

final roadmapControllerProvider = Provider<RoadmapController>(
  RoadmapController.new,
);

/// Bumped whenever the plan may have changed; screens watching today
/// re-read it. The read is cheap when nothing that shapes the plan moved.
final roadmapRevisionProvider =
    NotifierProvider<RoadmapRevision, int>(RoadmapRevision.new);

class RoadmapRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state += 1;
}

/// Today's plan for one exam. Recomputed whenever a screen starts watching
/// it and whenever the revision moves.
final roadmapTodayProvider =
    FutureProvider.autoDispose.family<RoadmapToday, ExamId>((ref, examId) {
  ref
    ..watch(roadmapRevisionProvider)
    ..watch(quizSessionPanelRevisionProvider)
    // An exam date or scope change must reach a plan already on screen.
    ..watch(userSettingsProvider)
    ..watch(trackScopeProvider(examId));
  return ref.read(roadmapControllerProvider).today(examId);
});

/// Whether "I want to advance" would add anything for this exam now. Read
/// alongside [roadmapTodayProvider]; a screen offers advance only when true.
final roadmapCanAdvanceProvider =
    FutureProvider.autoDispose.family<bool, ExamId>((ref, examId) async {
  // Recomputed whenever today's plan is.
  await ref.watch(roadmapTodayProvider(examId).future);
  return ref.read(roadmapControllerProvider).canAdvance(examId);
});

/// Keeps one plan per exam and local day (spec 4.9). A day is built on its
/// first read, rebuilt only when the exam, its date, the topics in scope,
/// the content, the assessment or recorded mocks change, and otherwise read
/// back with what is done subtracted.
class RoadmapController {
  RoadmapController(this._ref);

  final Ref _ref;
  final Map<ExamId, Future<RoadmapToday>> _inFlight = {};

  Future<RoadmapToday> today(ExamId examId) {
    final existing = _inFlight[examId];
    if (existing != null) return existing;
    // The cleanup must not return the removed future: whenComplete waits on
    // a returned future, and this one is the future being completed.
    final future = _today(examId).whenComplete(() {
      _inFlight.remove(examId);
    });
    _inFlight[examId] = future;
    return future;
  }

  /// Whether [advance] would add anything now: today's original work is done
  /// and there is material to bring in. Builds what advance would, saves
  /// nothing. Lets a screen offer advance only when it does something.
  Future<bool> canAdvance(ExamId examId) async {
    final current = await today(examId);
    return await _advanced(examId, current) != null;
  }

  /// Adds the next study day's material once today's original work is done.
  /// With no study day left, brings in the remaining material for today.
  Future<RoadmapToday> advance(ExamId examId) async {
    final current = await today(examId);
    final advanced = await _advanced(examId, current);
    if (advanced == null) return current;

    await _ref
        .read(roadmapDayRepositoryProvider)
        .write(examId, advanced, _now());
    await _ref.read(roadmapChangeLogRepositoryProvider).append(examId, [
      RoadmapDiff.advanced(
        before: current.snapshot,
        after: advanced,
        occurredAt: _now(),
      ),
    ]);
    _ref.read(roadmapRevisionProvider.notifier).bump();
    final completion =
        await _ref.read(roadmapInputsReaderProvider).completion(_now());
    return _view(advanced, completion);
  }

  /// Today's snapshot with the advanced items added, or null when advance
  /// would do nothing (today not done, or nothing left to bring in).
  Future<DaySnapshot?> _advanced(ExamId examId, RoadmapToday current) async {
    if (!current.originalDone) return null;

    final reader = _ref.read(roadmapInputsReaderProvider);
    final day = current.snapshot.day;
    final settings = await _ref.read(userSettingsProvider.future);
    final examDay = PlanningWindows.resolve(
      today: day,
      examDate: settings.examDate,
      anchoredReviewOnlyFrom: current.snapshot.reviewOnlyFrom,
      studyDays: settings.studyDays,
    ).examDay;
    final target = examDay == null
        ? DateTime(day.year, day.month, day.day + 1)
        : settings.studyDays.nextAfter(day, before: examDay);
    final inputs = await reader.inputs(
      examId,
      target ?? day,
      anchoredReviewOnlyFrom: current.snapshot.reviewOnlyFrom,
      treatTodayAsStudyDay: target == null,
    );
    final next = _ref.read(roadmapBuilderProvider)(inputs);
    var reviews = const <QuestionId>[];
    if (current.snapshot.plan.isRestDay &&
        !current.snapshot.plan.reviewQuestionIds
            .any(current.snapshot.plan.advancedIds.contains)) {
      final forToday = target == null
          ? next
          : _ref.read(roadmapBuilderProvider)(
              await reader.inputs(
                examId,
                day,
                anchoredReviewOnlyFrom: current.snapshot.reviewOnlyFrom,
                treatTodayAsStudyDay: true,
              ),
            );
      reviews = forToday.today.reviewQuestionIds;
    }
    final advanced =
        DaySnapshots.advance(current.snapshot, next.today, reviews: reviews);
    return advanced.plan.advancedIds.length ==
            current.snapshot.plan.advancedIds.length
        ? null
        : advanced;
  }

  Future<RoadmapToday> _today(ExamId examId) async {
    await _ref.read(mockAnswerRecorderProvider).reconcile(examId);

    final reader = _ref.read(roadmapInputsReaderProvider);
    final days = _ref.read(roadmapDayRepositoryProvider);
    final now = _now();
    final day = localDay(now);
    final digest = await reader.digest(examId);
    final completion = await reader.completion(now);

    final stored = await days.read(examId, day);
    if (stored != null && stored.digest == digest) {
      return _view(stored, completion);
    }

    final prior = stored ?? await days.latestBefore(examId, day);
    final sameExamDate = prior != null &&
        prior.digest.examId == digest.examId &&
        prior.digest.examDate == digest.examDate;
    final inputs = await reader.inputs(
      examId,
      day,
      anchoredReviewOnlyFrom: sameExamDate ? prior.reviewOnlyFrom : null,
    );
    final roadmap = _ref.read(roadmapBuilderProvider)(inputs);
    final next = DaySnapshot(
      plan: roadmap.today,
      digest: digest,
      topicOrderHead: roadmap.topicOrder,
      reviewOnlyFrom: roadmap.reviewOnlyFrom,
      state: roadmap.state,
    );

    final changes = RoadmapDiff.between(
      prior: prior,
      priorCompletion: prior != null && prior.day != day
          ? await reader.completionSince(examId, prior.day)
          : null,
      next: next,
      backlogCapped: roadmap.backlogCapped,
      cycleDetected: roadmap.cycleDetected,
      examPassed: roadmap.state == RoadmapState.examPassedAwaitingAnswer,
      examDateMissing: digest.examDate.isEmpty,
      occurredAt: now,
    );
    await days.write(examId, next, now);
    await _ref.read(roadmapChangeLogRepositoryProvider).append(examId, changes);
    return _view(next, completion);
  }

  RoadmapToday _view(DaySnapshot snapshot, CompletionFacts completion) =>
      RoadmapToday(
        snapshot: snapshot,
        remaining: DaySnapshots.remaining(snapshot, completion),
        originalDone: DaySnapshots.originalDone(snapshot, completion),
      );

  DateTime _now() => _ref.read(nowProvider)();
}
