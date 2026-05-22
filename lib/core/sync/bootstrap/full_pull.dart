import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/firestore/firestore_gateway.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/assessment_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/attempt_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/fsrs_card_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/lesson_progress_mapper.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/preferences_mapper.dart';

class FullPullBootstrap {
  FullPullBootstrap({
    required AppDatabase db,
    required FirestoreGateway gateway,
    required String uid,
  })  : _db = db,
        _gateway = gateway,
        _uid = uid;

  final AppDatabase _db;
  final FirestoreGateway _gateway;
  final String _uid;

  Future<void> run() async {
    await _setMarker();
    await _wipeSyncedState();
    await _applyCloudRows();
    await _clearMarker();
  }

  Future<void> _wipeSyncedState() async {
    await _db.transaction(() async {
      await _db.delete(_db.attemptsLocal).go();
      await _db.delete(_db.assessmentResultsLocal).go();
      await _db.delete(_db.reviewStateLocal).go();
      await _db.delete(_db.lessonProgressLocal).go();
      await _db.delete(_db.accountPrefs).go();
      await _db.delete(_db.pendingSync).go();
      final deviceId = await (_db.select(_db.syncMeta)
            ..where((row) => row.key.equals('deviceId')))
          .getSingleOrNull();
      await _db.delete(_db.syncMeta).go();
      if (deviceId != null) {
        await _db.into(_db.syncMeta).insert(deviceId);
      }
    });
  }

  Future<void> _applyCloudRows() async {
    const attempts = AttemptMapper();
    for (final doc
        in await _gateway.readCollection('users/$_uid/quiz_attempts')) {
      await _db.into(_db.attemptsLocal).insertOnConflictUpdate(
            attempts.toCompanion(attempts.fromFirestore(doc)),
          );
    }

    const assessments = AssessmentMapper();
    for (final doc
        in await _gateway.readCollection('users/$_uid/assessments')) {
      await _db.into(_db.assessmentResultsLocal).insertOnConflictUpdate(
            assessments.toCompanion(assessments.fromFirestore(doc)),
          );
    }

    const fsrs = FsrsCardMapper();
    for (final doc in await _gateway.readCollection('users/$_uid/fsrs_cards')) {
      await _db.into(_db.reviewStateLocal).insertOnConflictUpdate(
            fsrs.toCompanion(fsrs.fromFirestore(doc)),
          );
    }

    const lessons = LessonProgressMapper();
    for (final doc
        in await _gateway.readCollection('users/$_uid/lesson_progress')) {
      await _db.into(_db.lessonProgressLocal).insertOnConflictUpdate(
            lessons.toCompanion(lessons.fromFirestore(doc)),
          );
    }

    final root = await _gateway.readDocument('users/$_uid');
    if (root != null) {
      for (final row in const PreferencesMapper().fromFirestore(root)) {
        await _db.into(_db.accountPrefs).insertOnConflictUpdate(
              AccountPrefsCompanion.insert(key: row.key, value: row.value),
            );
      }
    }
  }

  Future<void> _setMarker() {
    return _db.into(_db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(key: 'pending_full_pull', value: '1'),
        );
  }

  Future<void> _clearMarker() {
    return (_db.delete(_db.syncMeta)
          ..where((row) => row.key.equals('pending_full_pull')))
        .go();
  }
}
