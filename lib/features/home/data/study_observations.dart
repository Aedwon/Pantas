import 'package:cloud_functions/cloud_functions.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_writes.dart';

/// Retries the existing durable observations. Receipts belong to the original
/// account/core, and never replace the persisted session or lesson read.
class StudyObservations {
  StudyObservations(this.db, {required this.request, required this.coreToken});
  final AppDatabase db;
  final StudyRequest request;
  final String coreToken;
  Future<void>? _pending;

  Future<void> flush() {
    if (_pending case final pending?) return pending;
    final result = _flush();
    _pending = result;
    void clear() => _pending = null;
    result.then<void>(
      (_) => clear(),
      onError: (Object _, StackTrace __) => clear(),
    );
    return result;
  }

  Future<void> _flush() async {
    if (!await request.isCurrent()) throw StateError('Study owner changed');
    final attempts = await db.select(db.attemptsLocal).get();
    final reads = await db.select(db.lessonProgressLocal).get();
    final repo = AttemptsRepository(db);
    Object? firstFailure;
    StackTrace? firstStack;
    Future<void> deliver(
      String endpoint,
      String id,
      Map<String, Object?> Function() payload,
    ) async {
      try {
        await _send(endpoint, id, payload);
      } catch (error, stack) {
        if (!await request.isCurrent()) rethrow;
        if (error is FirebaseFunctionsException &&
            error.code == 'resource-exhausted') {
          rethrow;
        }
        firstFailure ??= error;
        firstStack ??= stack;
      }
    }

    for (final row in attempts) {
      if (row.examId != request.examId) continue;
      final attempt = await repo.byId(row.id);
      if (attempt == null ||
          !attempt.isCompleted ||
          attempt.items.isEmpty ||
          !const {
            'today_topic',
            'today_interleaved',
            'new_questions',
            'drill',
            'flagged',
            'retake',
            'inline',
            'assessment',
          }.contains(attempt.origin)) {
        continue;
      }
      await deliver(
        'ingestSession',
        'session_${attempt.id}',
        () => studySessionPayload(attempt),
      );
    }
    for (final row in reads) {
      await deliver(
        'recordLessonRead',
        'lesson_${row.lessonId}_${row.readAt.millisecondsSinceEpoch}',
        () => {
          'lessonId': row.lessonId,
          'readAt': row.readAt.millisecondsSinceEpoch,
        },
      );
    }
    if (firstFailure != null) {
      Error.throwWithStackTrace(firstFailure!, firstStack!);
    }
  }

  Future<void> _send(
    String endpoint,
    String id,
    Map<String, Object?> Function() payload,
  ) async {
    final prefs = AppPreferencesRepository(db);
    final key = 'home_sent_${request.uid}_${coreToken}_$id';
    if (!await request.isCurrent()) throw StateError('Study owner changed');
    if (await prefs.deviceValue(key) != null) return;
    try {
      final data = payload();
      await request.read(endpoint, payload: data);
    } catch (error) {
      final permanent = error is FirebaseFunctionsException
          ? const {
              'invalid-argument',
              'not-found',
              'permission-denied',
              'failed-precondition',
              'already-exists',
              'out-of-range',
              'unimplemented',
            }.contains(error.code)
          : error is StateError &&
              error.message == 'Completed session timing required';
      if (permanent && await request.isCurrent()) {
        await db.transaction(() async {
          if (!await request.isCurrent()) {
            throw StateError('Study owner changed');
          }
          await prefs.setDeviceValue(key, 'rejected');
          if (!await request.isCurrent()) {
            throw StateError('Study owner changed');
          }
        });
      }
      rethrow;
    }
    await db.transaction(() async {
      if (!await request.isCurrent()) throw StateError('Study owner changed');
      await prefs.setDeviceValue(key, '1');
      if (!await request.isCurrent()) throw StateError('Study owner changed');
    });
  }
}
