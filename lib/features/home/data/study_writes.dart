import 'dart:async';
import 'dart:convert';

import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/features/home/data/study_api.dart';

/// Session wall time is an observed interval. Attempts have no per-answer wall
/// timestamp, so answers deliberately omit answeredAt.
Map<String, Object?> studySessionPayload(Attempt attempt) {
  final finished = attempt.completedAt;
  if (finished == null || finished.isBefore(attempt.startedAt)) {
    throw StateError('Completed session timing required');
  }
  return {
    'sessionId': attempt.id,
    'origin': attempt.origin,
    'startedAt': attempt.startedAt.millisecondsSinceEpoch,
    'finishedAt': finished.millisecondsSinceEpoch,
    'durationMs': finished.difference(attempt.startedAt).inMilliseconds,
    'answers': [
      for (final item in attempt.items)
        {
          'questionId': item.questionId,
          'chosen': item.chosenChoiceId,
          'correct': item.isCorrect,
          'responseMs': item.responseMs,
          'questionVersion': item.questionVersion,
        },
    ],
  };
}

/// One feature-local queue per database. A new intent replaces a failed retry
/// immediately. A dispatched write finishes before its successor.
class StudyWrites {
  Future<void> _tail = Future<void>.value();
  Future<void> _latestSettings = Future<void>.value();
  int _intent = 0;
  Future<void> Function()? _retry;

  StudySettingsIntent beginSettings() {
    final result = StudySettingsIntent._(this, ++_intent);
    _retry = null;
    _latestSettings = result._completion.future;
    // A failed unobserved reservation must not create an unhandled error.
    unawaited(
      _latestSettings.then<void>(
        (_) {},
        onError: (Object _, StackTrace __) {},
      ),
    );
    return result;
  }

  Future<void> settings(StudyRequest request, Map<String, Object?> payload) =>
      beginSettings().publish(request, payload);

  Future<void> _publish(
    StudySettingsIntent intent,
    StudyRequest request,
    Map<String, Object?> payload,
  ) {
    final saved =
        (jsonDecode(jsonEncode(payload)) as Map).cast<String, Object?>();
    Future<void> send() async {
      if (intent._id != _intent) return;
      await request.read('setExamSettings', payload: saved);
      if (intent._id == _intent) _retry = null;
    }

    if (intent._id == _intent) _retry = send;
    final dispatched = _enqueue(send)
      ..then<void>(
        (_) => intent._finish(),
        onError: (Object e, StackTrace st) => intent._finish(e, st),
      );
    return dispatched.then((_) async {
      while (intent._id != _intent) {
        final latest = _latestSettings;
        await latest;
        if (identical(latest, _latestSettings)) break;
      }
    });
  }

  Future<void> retrySettings() => _enqueue(() async => _retry?.call());

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }
}

/// A tap reserves ordering before any owner/settings hydration can yield.
/// Failed local persistence cancels it without restoring an older retry.
class StudySettingsIntent {
  StudySettingsIntent._(this._writes, this._id);
  final StudyWrites _writes;
  final int _id;
  final _completion = Completer<void>();
  bool _submitted = false;
  Future<void> publish(StudyRequest request, Map<String, Object?> payload) {
    if (_submitted) throw StateError('Settings intent already completed');
    _submitted = true;
    return _writes._publish(this, request, payload);
  }

  void cancel() {
    if (_submitted) return;
    _submitted = true;
    _finish();
  }

  void _finish([Object? error, StackTrace? stack]) {
    if (_completion.isCompleted) return;
    if (error == null) {
      _completion.complete();
    } else {
      _completion.completeError(error, stack);
    }
  }
}

/// Created at the tap. Retry retains this exact envelope.
class StudyAdvance {
  StudyAdvance(
    this.request, {
    required String requestId,
    required String expectedDay,
    required String expectedRevision,
  }) : payload = Map.unmodifiable({
          'requestId': requestId,
          'expectedDay': expectedDay,
          'expectedRevision': expectedRevision,
        });
  final StudyRequest request;
  final Map<String, Object?> payload;
  Future<Map<String, Object?>> send() =>
      request.read('advanceRoadmap', payload: payload);
}
