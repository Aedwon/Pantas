import 'package:cloud_functions/cloud_functions.dart';
import 'package:drift/drift.dart' show StringExpressionOperators;
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

  /// The flush in progress for each account, exam and core on one database.
  /// Several senders exist at once (the read path and the lifecycle watcher),
  /// and each used to run its own pass, so one finished quiz was sent twice.
  /// The server ignores a repeat, but the second pass still cost a request
  /// and a full reread. They now share the passes.
  static final Expando<Map<String, _Flight>> _flights = Expando();

  String get _flightKey =>
      '${request.uid}\u0000${request.examId}\u0000$coreToken';

  Map<String, _Flight> get _flightsHere => _flights[db] ??= {};

  Future<void> flush() {
    final running = _flightsHere[_flightKey];
    return running == null ? _start() : _join(running);
  }

  Future<void> _start() {
    final flights = _flightsHere;
    final key = _flightKey;
    final result = _flush();
    final flight = _Flight(result);
    flights[key] = flight;
    void clear() {
      if (identical(flights[key], flight)) flights.remove(key);
    }

    result.then<void>(
      (_) => clear(),
      onError: (Object _, StackTrace __) => clear(),
    );
    return result;
  }

  /// A running pass read its rows before this caller asked, so it may have
  /// missed what finished since. Every caller that joins it waits for one
  /// fresh pass after it, shared between them, and takes that pass's result.
  /// A pass that fails for any reason but a changed owner is the result for
  /// the joiners too: its failure is not retried at once.
  Future<void> _join(_Flight running) =>
      running.next ??= _afterRunning(running);

  Future<void> _afterRunning(_Flight running) async {
    try {
      await running.pass;
    } on Object catch (error) {
      // The pass we joined was begun by a sender whose owner has since
      // changed. This sender may still be current, so it runs its own pass
      // once instead of inheriting that failure.
      if (error is! StateError ||
          error.message != 'Study owner changed' ||
          !await request.isCurrent()) {
        rethrow;
      }
    }
    // The finished pass has left the map. A pass another caller began since
    // read its rows after this caller asked, so it is fresh enough.
    await (_flightsHere[_flightKey]?.pass ?? _start());
  }

  String _receiptKey(String id) => 'home_sent_${request.uid}_${coreToken}_$id';

  /// Every receipt kept for this account and core, read once. A rejected
  /// observation also leaves a receipt, so it is skipped the same way.
  Future<Set<String>> _receipts() async {
    final prefs = db.devicePrefs;
    final rows = await (db.selectOnly(prefs)
          ..addColumns([prefs.key])
          ..where(prefs.key.like('${_receiptKey('')}%')))
        .get();
    return {for (final row in rows) row.read(prefs.key)!};
  }

  /// The ids of this exam's attempts not yet sent, in table order. Sent rows
  /// are dropped here, before their items are read.
  Future<List<String>> _unsentAttemptIds(Set<String> receipts) async {
    final table = db.attemptsLocal;
    final rows = await (db.selectOnly(table)
          ..addColumns([table.id])
          ..where(table.examId.equals(request.examId)))
        .get();
    return [
      for (final row in rows)
        if (!receipts.contains(_receiptKey('session_${row.read(table.id)}')))
          row.read(table.id)!,
    ];
  }

  Future<void> _flush() async {
    if (!await request.isCurrent()) throw StateError('Study owner changed');
    final receipts = await _receipts();
    final unsentIds = await _unsentAttemptIds(receipts);
    final rowsById = <String, AttemptLocalRow>{
      if (unsentIds.isNotEmpty)
        for (final row in await (db.select(db.attemptsLocal)
              ..where((t) => t.id.isIn(unsentIds)))
            .get())
          row.id: row,
    };
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

    for (final id in unsentIds) {
      final row = rowsById[id];
      if (row == null) continue;
      final attempt = repo.fromRow(row);
      if (!attempt.isCompleted ||
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
      final id = 'lesson_${row.lessonId}_${row.readAt.millisecondsSinceEpoch}';
      if (receipts.contains(_receiptKey(id))) continue;
      await deliver(
        'recordLessonRead',
        id,
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
    final key = _receiptKey(id);
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

/// One running pass, and the single pass queued behind it for the callers
/// that arrived while it ran.
class _Flight {
  _Flight(this.pass);
  final Future<void> pass;
  Future<void>? next;
}
