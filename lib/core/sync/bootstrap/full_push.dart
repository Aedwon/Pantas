import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/firestore/firestore_gateway.dart';
import 'package:cse_cet_reviewer/core/sync/firestore/functions_gateway.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/assessment_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/attempt_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/fsrs_card_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/lesson_progress_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/preferences_mapper.dart';

class FullPushBootstrap {
  FullPushBootstrap({
    required AppDatabase db,
    required FirestoreGateway gateway,
    required SyncFunctionsGateway functionsGateway,
    required String uid,
    required String deviceId,
    required DateTime Function() now,
  })  : _db = db,
        _gateway = gateway,
        _functionsGateway = functionsGateway,
        _uid = uid,
        _deviceId = deviceId,
        _now = now;

  final AppDatabase _db;
  final FirestoreGateway _gateway;
  final SyncFunctionsGateway _functionsGateway;
  final String _uid;
  final String _deviceId;
  final DateTime Function() _now;

  Future<void> run() async {
    await _setMarker();
    await _functionsGateway.resetCloudUserData();

    final writes = await _buildWrites();
    try {
      if (writes.isNotEmpty) {
        for (var start = 0; start < writes.length; start += 500) {
          final end = (start + 500).clamp(0, writes.length);
          await _gateway.commitBatch(writes.sublist(start, end));
        }
      }
      await _clearMarker();
    } on SyncGatewayException {
      return;
    }
  }

  Future<List<FirestoreWrite>> _buildWrites() async {
    final updatedAt = _now();
    final attempts = const AttemptMapper();
    final assessments = const AssessmentMapper();
    final fsrs = const FsrsCardMapper();
    final lessons = const LessonProgressMapper();
    final preferences = const PreferencesMapper();

    return [
      for (final row in await _db.select(_db.attemptsLocal).get())
        FirestoreWrite.set(
          path: 'users/$_uid/quiz_attempts/${attempts.documentId(row)}',
          data: attempts.toFirestore(
            row,
            updatedAt: updatedAt,
            originDeviceId: _deviceId,
          ),
        ),
      for (final row in await _db.select(_db.assessmentResultsLocal).get())
        FirestoreWrite.set(
          path: 'users/$_uid/assessments/${assessments.documentId(row)}',
          data: assessments.toFirestore(
            row,
            updatedAt: updatedAt,
            originDeviceId: _deviceId,
          ),
        ),
      for (final row in await _db.select(_db.reviewStateLocal).get())
        FirestoreWrite.set(
          path: 'users/$_uid/fsrs_cards/${fsrs.documentId(row)}',
          data: fsrs.toFirestore(
            row,
            updatedAt: updatedAt,
            originDeviceId: _deviceId,
          ),
        ),
      for (final row in await _db.select(_db.lessonProgressLocal).get())
        FirestoreWrite.set(
          path: 'users/$_uid/lesson_progress/${lessons.documentId(row)}',
          data: lessons.toFirestore(
            row,
            updatedAt: updatedAt,
            originDeviceId: _deviceId,
          ),
        ),
      FirestoreWrite.set(
        path: 'users/$_uid',
        data: preferences.toFirestore(await _db.select(_db.accountPrefs).get()),
      ),
    ];
  }

  Future<void> _setMarker() {
    return _db.into(_db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(key: 'pending_full_push', value: '1'),
        );
  }

  Future<void> _clearMarker() {
    return (_db.delete(_db.syncMeta)
          ..where((row) => row.key.equals('pending_full_push')))
        .go();
  }
}
