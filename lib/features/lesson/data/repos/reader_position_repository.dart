import 'dart:convert';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';

/// Device-local position. Offset and fraction share one preference write.
class ReaderPositionRepository {
  ReaderPositionRepository(this.preferences, {AppDatabase? database})
      : _db = database;
  final AppDatabase? _db;

  AppDatabase get _database =>
      _db ??
      (throw StateError(
        'A database is required for guarded reader operations.',
      ));

  /// Starts before identity/content waits so even an empty-store wipe follows
  /// this transaction in the database queue. Only a fresh view may initialize.
  Future<String?> captureToken({required bool Function() isCurrent}) async {
    try {
      return await _database.transaction(() async {
        if (!isCurrent()) throw const _ExpiredReader();
        final contexts = SyncActiveContextStore(_database);
        var snapshot = await contexts.readSnapshot();
        if (!isCurrent()) throw const _ExpiredReader();
        if (snapshot == null) {
          await contexts.clearStable();
          snapshot = await contexts.readSnapshot();
        }
        if (!isCurrent()) throw const _ExpiredReader();
        return snapshot!.token;
      });
    } on _ExpiredReader {
      return null;
    }
  }

  /// Only initial capture may establish the missing legacy guest envelope.
  Future<ReaderBoundary?> captureBoundary(
    String examId, {
    required bool Function() isCurrent,
  }) =>
      _enqueue(() async {
        try {
          return await _database.transaction(() async {
            if (!isCurrent()) throw const _ExpiredReader();
            final exam = await preferences.selectedExamId();
            if (!isCurrent() || (exam != null && exam != examId)) {
              throw const _ExpiredReader();
            }
            final contexts = SyncActiveContextStore(_database);
            var snapshot = await contexts.readSnapshot();
            if (!isCurrent()) throw const _ExpiredReader();
            if (snapshot == null) {
              await contexts.clearStable();
              snapshot = await contexts.readSnapshot();
            }
            if (!isCurrent()) throw const _ExpiredReader();
            return ReaderBoundary(examId: examId, token: snapshot!.token);
          });
        } on _ExpiredReader {
          return null;
        }
      });

  /// Loading, retry, and saves can only read an existing boundary.
  Future<ReaderBoundary?> readBoundary(
    String examId, {
    required bool Function() isCurrent,
  }) async {
    if (!isCurrent()) return null;
    final snapshot = await SyncActiveContextStore(_database).readSnapshot();
    if (!isCurrent() || snapshot == null) return null;
    final boundary = ReaderBoundary(examId: examId, token: snapshot.token);
    return await isBoundaryCurrent(boundary, isCurrent: isCurrent)
        ? boundary
        : null;
  }

  Future<bool> isBoundaryCurrent(
    ReaderBoundary boundary, {
    required bool Function() isCurrent,
  }) async {
    if (!isCurrent()) return false;
    final snapshot = await SyncActiveContextStore(_database).readSnapshot();
    if (!isCurrent() || snapshot == null || snapshot.token != boundary.token) {
      return false;
    }
    final exam = await preferences.selectedExamId();
    return isCurrent() && (exam == null || exam == boundary.examId);
  }

  /// Guards both sides of async mutation in the actual write transaction.
  Future<bool> runGuarded(
    ReaderBoundary boundary,
    Future<void> Function() operation, {
    required bool Function() isCurrent,
  }) =>
      _enqueue(() async {
        try {
          return await _database.transaction(() async {
            if (!await isBoundaryCurrent(boundary, isCurrent: isCurrent)) {
              throw const _ExpiredReader();
            }
            await operation();
            if (!await isBoundaryCurrent(boundary, isCurrent: isCurrent)) {
              throw const _ExpiredReader();
            }
            return true;
          });
        } on _ExpiredReader {
          return false;
        }
      });

  Future<bool> writeGuarded(
    ReaderBoundary boundary,
    String lessonId,
    double offset, {
    required double fraction,
    required bool Function() isCurrent,
  }) {
    _validateOffset(offset);
    _validateFraction(fraction);
    return runGuarded(
      boundary,
      () => preferences.setDeviceValue(
        _key(boundary.examId, lessonId),
        jsonEncode({'offset': offset, 'fraction': fraction}),
      ),
      isCurrent: isCurrent,
    );
  }

  final AppPreferencesRepository preferences;
  Future<void> _writes = Future<void>.value();

  String _key(String examId, String lessonId) =>
      'lesson_offset.$examId.$lessonId';

  Future<({double offset, double? fraction})> _read(
    String examId,
    String lessonId,
  ) async {
    final raw = await preferences.deviceValue(_key(examId, lessonId));
    final legacy = double.tryParse(raw ?? '');
    if (legacy != null) {
      return (
        offset: legacy.isFinite && legacy >= 0 ? legacy : 0.0,
        fraction: null
      );
    }
    try {
      final decoded = jsonDecode(raw ?? 'null');
      if (decoded is Map<String, Object?>) {
        final offset = decoded['offset'];
        final fraction = decoded['fraction'];
        return (
          offset: offset is num && offset.isFinite && offset >= 0
              ? offset.toDouble()
              : 0.0,
          fraction: fraction is num &&
                  fraction.isFinite &&
                  fraction >= 0 &&
                  fraction <= 1
              ? fraction.toDouble()
              : null,
        );
      }
    } on FormatException {
      // A damaged value cannot supply a reading position or ring fraction.
    }
    return (offset: 0.0, fraction: null);
  }

  Future<double> read(String examId, String lessonId) async {
    await _writes;
    return (await _read(examId, lessonId)).offset;
  }

  /// Null means no measured fraction, so the consumer draws an empty ring.
  Future<double?> readFraction(String examId, String lessonId) async {
    await _writes;
    return (await _read(examId, lessonId)).fraction;
  }

  void _validateFraction(double fraction) {
    if (!fraction.isFinite || fraction < 0 || fraction > 1) {
      throw ArgumentError.value(fraction, 'fraction', 'Must be from 0 to 1');
    }
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final write = _writes.then((_) => operation());
    _writes = write.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return write;
  }

  Future<void> _queue(Future<void> Function() operation) => _enqueue(operation);

  void _validateOffset(double offset) {
    if (!offset.isFinite || offset < 0) {
      throw ArgumentError.value(
        offset,
        'offset',
        'Must be finite and positive',
      );
    }
  }

  /// Keeps an existing offset, including the older scalar format.
  Future<void> writeFraction(
    String examId,
    String lessonId,
    double fraction,
  ) async {
    _validateFraction(fraction);
    return _queue(() async {
      final position = await _read(examId, lessonId);
      await preferences.setDeviceValue(
        _key(examId, lessonId),
        jsonEncode({'offset': position.offset, 'fraction': fraction}),
      );
    });
  }

  Future<void> write(
    String examId,
    String lessonId,
    double offset, {
    double? fraction,
  }) async {
    if (!offset.isFinite || offset < 0) {
      throw ArgumentError.value(
        offset,
        'offset',
        'Must be finite and positive',
      );
    }
    if (fraction != null) _validateFraction(fraction);
    return _queue(
      () => preferences.setDeviceValue(
        _key(examId, lessonId),
        jsonEncode(
          {'offset': offset, if (fraction != null) 'fraction': fraction},
        ),
      ),
    );
  }
}

class ReaderBoundary {
  const ReaderBoundary({required this.examId, required this.token});
  final String examId;
  final String token;
}

class _ExpiredReader implements Exception {
  const _ExpiredReader();
}
