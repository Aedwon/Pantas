import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/quiz/application/quiz_preparation_stamp.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';

@immutable
class QuizPreparationRequest {
  const QuizPreparationRequest({
    required this.userId,
    required this.examId,
    this.topicId,
  });

  final String userId;
  final ExamId examId;
  final TopicId? topicId;

  @override
  bool operator ==(Object other) =>
      other is QuizPreparationRequest &&
      other.userId == userId &&
      other.examId == examId &&
      other.topicId == topicId;

  @override
  int get hashCode => Object.hash(userId, examId, topicId);
}

@immutable
class PreparedTodaySession {
  PreparedTodaySession({
    required TodaySessionPlan plan,
    required this.stamp,
    required this.preparedAt,
  })  : plan = _freezePlan(plan),
        orderedQuestionIds = List<QuestionId>.unmodifiable(
          plan.questions.map((question) => question.id),
        );

  final TodaySessionPlan plan;
  final QuizPreparationStamp stamp;
  final DateTime preparedAt;
  final List<QuestionId> orderedQuestionIds;
}

TodaySessionPlan _freezePlan(TodaySessionPlan plan) {
  return TodaySessionPlan(
    questions: List.unmodifiable(plan.questions),
    dueCount: plan.dueCount,
    weaknessCount: plan.weaknessCount,
    freshCount: plan.freshCount,
    topicId: plan.topicId,
    topicName: plan.topicName,
  );
}

typedef QuizPreparationStampReader = Future<QuizPreparationStamp> Function(
  QuizPreparationRequest request,
);
typedef TodayPlanBuilder = Future<TodaySessionPlan> Function(
  QuizPreparationRequest request,
);

class TodayQuizPreparer {
  TodayQuizPreparer({
    required QuizPreparationStampReader readStamp,
    required TodayPlanBuilder buildPlan,
    required DateTime Function() now,
    this.maxEntries = 4,
  })  : _readStamp = readStamp,
        _buildPlan = buildPlan,
        _now = now {
    if (maxEntries < 1) {
      throw ArgumentError.value(maxEntries, 'maxEntries', 'must be positive');
    }
  }

  final QuizPreparationStampReader _readStamp;
  final TodayPlanBuilder _buildPlan;
  final DateTime Function() _now;
  final int maxEntries;

  final LinkedHashMap<QuizPreparationRequest, PreparedTodaySession> _cache =
      LinkedHashMap<QuizPreparationRequest, PreparedTodaySession>();
  final Map<QuizPreparationRequest, Future<PreparedTodaySession>> _inFlight =
      <QuizPreparationRequest, Future<PreparedTodaySession>>{};
  final Map<QuizPreparationRequest, int> _generations =
      <QuizPreparationRequest, int>{};

  int get cachedEntryCount => _cache.length;

  Future<QuizPreparationStamp> currentStamp(QuizPreparationRequest request) =>
      _readStamp(request);

  void invalidate(QuizPreparationRequest request) {
    _generations[request] = (_generations[request] ?? 0) + 1;
    _cache.remove(request);
    _inFlight.remove(request);
  }

  void invalidateAll() {
    final keys = <QuizPreparationRequest>{
      ..._cache.keys,
      ..._inFlight.keys,
      ..._generations.keys,
    };
    for (final request in keys) {
      invalidate(request);
    }
  }

  Future<PreparedTodaySession> prepare(QuizPreparationRequest request) {
    final existing = _inFlight[request];
    if (existing != null) return existing;

    final generation = _generations[request] ?? 0;
    late final Future<PreparedTodaySession> future;
    future = _prepare(request, generation);
    _inFlight[request] = future;
    unawaited(
      future.then<void>(
        (_) => _clearInFlight(request, future),
        onError: (Object _, StackTrace __) {
          _clearInFlight(request, future);
        },
      ),
    );
    return future;
  }

  Future<PreparedTodaySession> _prepare(
    QuizPreparationRequest request,
    int generation,
  ) async {
    final before = await _readStamp(request);
    if (!_isCurrent(request, generation)) return prepare(request);

    final cached = _cache[request];
    if (cached != null && cached.stamp == before && before.isFreshAt(_now())) {
      _touch(request, cached);
      return cached;
    }

    final plan = await _buildPlan(request);
    if (!_isCurrent(request, generation)) return prepare(request);

    final after = await _readStamp(request);
    if (!_isCurrent(request, generation)) return prepare(request);
    if (after != before || !after.isFreshAt(_now())) {
      invalidate(request);
      return prepare(request);
    }

    final prepared = PreparedTodaySession(
      plan: plan,
      stamp: after,
      preparedAt: _now(),
    );
    _touch(request, prepared);
    while (_cache.length > maxEntries) {
      _cache.remove(_cache.keys.first);
    }
    return prepared;
  }

  void _clearInFlight(
    QuizPreparationRequest request,
    Future<PreparedTodaySession> future,
  ) {
    if (identical(_inFlight[request], future)) {
      _inFlight.remove(request);
    }
  }

  bool _isCurrent(QuizPreparationRequest request, int generation) =>
      (_generations[request] ?? 0) == generation;

  void _touch(
    QuizPreparationRequest request,
    PreparedTodaySession prepared,
  ) {
    _cache.remove(request);
    _cache[request] = prepared;
  }
}
