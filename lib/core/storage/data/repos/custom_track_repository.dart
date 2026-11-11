import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/sync/custom_track/custom_track_projection.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';
import 'package:uuid/uuid.dart';

class _ContentDatabaseCustomTrackProjection implements CustomTrackProjection {
  _ContentDatabaseCustomTrackProjection(
    this._contentDb, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ContentDatabase _contentDb;
  final DateTime Function() _now;

  @override
  Future<void> upsert({required String examId, required String name}) {
    return _contentDb.into(_contentDb.contentExams).insertOnConflictUpdate(
          ContentExamsCompanion.insert(
            id: examId,
            code: 'custom',
            name: name,
            shortName: name,
            language: 'en',
            ordering: 9999,
            isCustom: const Value(true),
            schemaVersion: 1,
            updatedAt: _now(),
          ),
        );
  }

  @override
  Future<void> delete(String examId) {
    return (_contentDb.delete(_contentDb.contentExams)
          ..where((row) => row.id.equals(examId)))
        .go();
  }
}

/// The id `create` gives every custom track. The server accepts a stricter
/// shape, and this prefix is what tells the two kinds of exam apart here.
const customExamIdPrefix = 'exam_custom_';

bool isCustomExamId(ExamId examId) => examId.startsWith(customExamIdPrefix);

/// Removes every custom exam row from the content database, for a wipe.
Future<void> deleteCustomContentExams(ContentDatabase content) =>
    (content.delete(content.contentExams)
          ..where((row) => row.isCustom.equals(true)))
        .go();

/// A custom exam's paper as `getCustomTracks` returns it.
@immutable
class CustomTrackBlueprintRow {
  const CustomTrackBlueprintRow({
    required this.sectionsJson,
    required this.totalQuestions,
    required this.totalMinutes,
    required this.sectionsTimedSeparately,
    required this.updatedAt,
  });

  factory CustomTrackBlueprintRow.fromJson(Object? json) {
    final map = _jsonMap(json, 'blueprint');
    return CustomTrackBlueprintRow(
      sectionsJson: _jsonText(map['sectionsJson'], 'sectionsJson'),
      totalQuestions: _jsonInt(map['totalQuestions'], 'totalQuestions'),
      totalMinutes: _jsonInt(map['totalMinutes'], 'totalMinutes'),
      sectionsTimedSeparately: switch (map['sectionsTimedSeparately']) {
        final bool flag => flag,
        _ => throw const FormatException('Bad sectionsTimedSeparately'),
      },
      updatedAt: _jsonInt(map['updatedAt'], 'updatedAt'),
    );
  }

  final String sectionsJson;
  final int totalQuestions;
  final int totalMinutes;
  final bool sectionsTimedSeparately;

  /// Milliseconds since the epoch.
  final int updatedAt;
}

/// One custom exam from `getCustomTracks`. Parsing is strict about types, so a
/// reply of the wrong shape fails before anything is written locally.
@immutable
class CustomTrackRow {
  const CustomTrackRow({
    required this.examId,
    required this.name,
    required this.excludedTopicIds,
    required this.excludedLessonIds,
    required this.blueprint,
    required this.createdAt,
    required this.updatedAt,
    this.priceTier,
  });

  factory CustomTrackRow.fromJson(Object? json) {
    final map = _jsonMap(json, 'track');
    final examId = _jsonText(map['examId'], 'examId');
    // A listed exam's id here would let a reply shadow a listed exam.
    if (!isCustomExamId(examId)) throw const FormatException('Bad examId');
    return CustomTrackRow(
      examId: examId,
      name: map['name'] == null ? null : _jsonText(map['name'], 'name'),
      excludedTopicIds: _jsonTexts(map['excludedTopicIds'], 'excludedTopicIds'),
      excludedLessonIds:
          _jsonTexts(map['excludedLessonIds'], 'excludedLessonIds'),
      blueprint: map['blueprint'] == null
          ? null
          : CustomTrackBlueprintRow.fromJson(map['blueprint']),
      createdAt: _jsonInt(map['createdAt'], 'createdAt'),
      updatedAt: _jsonInt(map['updatedAt'], 'updatedAt'),
      priceTier: map['priceTier'] == null
          ? null
          : _jsonText(map['priceTier'], 'priceTier'),
    );
  }

  final ExamId examId;

  /// The tier the server works out from the subjects the exam keeps, spelled
  /// as the catalog spells it. Null on a reply from a server that sends none.
  final String? priceTier;

  /// Null when the server never received a name for this exam.
  final String? name;
  final Set<TopicId> excludedTopicIds;
  final Set<LessonId> excludedLessonIds;
  final CustomTrackBlueprintRow? blueprint;

  /// Milliseconds since the epoch.
  final int createdAt;
  final int updatedAt;
}

Map<String, Object?> _jsonMap(Object? value, String what) {
  if (value is Map && value.keys.every((key) => key is String)) {
    return {for (final e in value.entries) e.key! as String: e.value};
  }
  throw FormatException('Bad $what');
}

String _jsonText(Object? value, String what) =>
    value is String ? value : throw FormatException('Bad $what');

Set<String> _jsonTexts(Object? value, String what) {
  if (value is List && value.every((item) => item is String)) {
    return {for (final item in value) item as String};
  }
  throw FormatException('Bad $what');
}

// A number that crosses the browser boundary may arrive as a double.
int _jsonInt(Object? value, String what) {
  if (value is int) return value;
  if (value is double && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }
  throw FormatException('Bad $what');
}

/// Owns custom-track user data in AppDatabase and keeps ContentDatabase as a
/// recoverable display/content projection.
class CustomTrackRepository {
  CustomTrackRepository(
    this._db,
    this._contentDb, {
    Uuid? uuid,
    LocalSyncMutationRecorder? syncRecorder,
    CustomTrackProjection? projection,
  })  : _uuid = uuid ?? const Uuid(),
        _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db),
        _projection =
            projection ?? _ContentDatabaseCustomTrackProjection(_contentDb);

  static const _projectionMarkerPrefix = 'customTrackProjectionRequired:';

  final AppDatabase _db;
  final ContentDatabase _contentDb;
  final Uuid _uuid;
  final LocalSyncMutationRecorder _syncRecorder;
  final CustomTrackProjection _projection;

  /// Puts every stored track back into the in-memory content database. The web
  /// content database is empty at each start, and the retry markers that
  /// `create` and `rename` leave do not survive a reload.
  Future<void> reprojectAll() async {
    for (final row in await _db.select(_db.customTrackMetaLocal).get()) {
      await _projection.upsert(examId: row.examId, name: row.name);
    }
  }

  /// The student's name for the exam, or null when this browser has no
  /// such track.
  Future<String?> name(ExamId examId) async =>
      (await _customTrackMeta(examId))?.name;

  /// The saved paper in the five fields the server reads, or null when there
  /// is none or the server would refuse it. A refused paper must not fail the
  /// whole settings publish, so it is left out and the local row stays.
  Future<Map<String, Object?>?> blueprintPayload(ExamId examId) async {
    final row = await (_db.select(_db.customBlueprintsLocal)
          ..where((b) => b.examId.equals(examId)))
        .getSingleOrNull();
    if (row == null || !_serverAcceptsBlueprint(row)) return null;
    return {
      'sectionsJson': row.sectionsJson,
      'totalQuestions': row.totalQuestions,
      'totalMinutes': row.totalMinutes,
      'sectionsTimedSeparately': row.sectionsTimedSeparately,
      'updatedAt': row.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Brings a track made elsewhere onto this browser. Local wins: a track whose
  /// id is already stored here is left alone, and so is a reply with no name,
  /// which would leave a nameless exam. Returns whether anything was written.
  ///
  /// The meta, scope and blueprint rows go in one recorded batch, so a Pro
  /// account's sync sees them as ordinary local changes.
  Future<bool> restoreFromServer(CustomTrackRow row) async {
    final examId = row.examId;
    final name = row.name?.trim();
    if (name == null || name.isEmpty) return false;
    if (await _customTrackMeta(examId) != null) return false;
    final blueprint = row.blueprint;

    await _syncRecorder.runRecordedBatch(
      mutations: [
        SyncMutationTarget(
          collection: 'track_scope',
          rowId: TrackScopeDocumentId.metadata(examId),
          op: SyncLocalMutationOp.upsert,
        ),
        for (final topicId in row.excludedTopicIds)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.scope(examId, topicId),
            op: SyncLocalMutationOp.upsert,
          ),
        if (blueprint != null)
          SyncMutationTarget(
            collection: 'custom_blueprints',
            rowId: examId,
            op: SyncLocalMutationOp.upsert,
          ),
      ],
      mutate: () async {
        await _db.into(_db.customTrackMetaLocal).insertOnConflictUpdate(
              CustomTrackMetaLocalCompanion.insert(examId: examId, name: name),
            );
        for (final topicId in row.excludedTopicIds) {
          await _db.into(_db.trackScopeLocal).insertOnConflictUpdate(
                TrackScopeLocalCompanion.insert(
                  examId: examId,
                  topicId: topicId,
                ),
              );
        }
        if (row.excludedLessonIds.isNotEmpty) {
          await _db.into(_db.accountPrefs).insertOnConflictUpdate(
                AccountPrefsCompanion.insert(
                  key: _lessonKey(examId),
                  value: jsonEncode(row.excludedLessonIds.toList()..sort()),
                ),
              );
        }
        if (blueprint != null) {
          await _db.into(_db.customBlueprintsLocal).insertOnConflictUpdate(
                CustomBlueprintsLocalCompanion.insert(
                  examId: examId,
                  totalQuestions: blueprint.totalQuestions,
                  totalMinutes: blueprint.totalMinutes,
                  sectionsJson: blueprint.sectionsJson,
                  sectionsTimedSeparately:
                      Value(blueprint.sectionsTimedSeparately),
                  updatedAt: DateTime.fromMillisecondsSinceEpoch(
                    blueprint.updatedAt,
                    isUtc: true,
                  ),
                ),
              );
        }
        await _setProjectionRequired(examId, required: true);
      },
    );

    await _projectWithoutRollingBackAuthority(examId);
    return true;
  }

  Future<ExamId> create({
    required String name,
    required Set<TopicId> includedTopicIds,
  }) async {
    final examId = '$customExamIdPrefix${_uuid.v4()}';
    final allTopics = await _contentDb.select(_contentDb.contentTopics).get();
    final excludedTopicIds = {
      for (final topic in allTopics)
        if (!includedTopicIds.contains(topic.id)) topic.id,
    };

    await _syncRecorder.runRecordedBatch(
      mutations: [
        SyncMutationTarget(
          collection: 'track_scope',
          rowId: TrackScopeDocumentId.metadata(examId),
          op: SyncLocalMutationOp.upsert,
        ),
        for (final topicId in excludedTopicIds)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.scope(examId, topicId),
            op: SyncLocalMutationOp.upsert,
          ),
      ],
      mutate: () async {
        await _db.into(_db.customTrackMetaLocal).insertOnConflictUpdate(
              CustomTrackMetaLocalCompanion.insert(
                examId: examId,
                name: name,
              ),
            );
        for (final topicId in excludedTopicIds) {
          await _db.into(_db.trackScopeLocal).insertOnConflictUpdate(
                TrackScopeLocalCompanion.insert(
                  examId: examId,
                  topicId: topicId,
                ),
              );
        }
        await _setProjectionRequired(examId, required: true);
      },
    );

    await _projectWithoutRollingBackAuthority(examId);
    return examId;
  }

  Future<void> rename({required ExamId examId, required String name}) async {
    await _syncRecorder.runRecorded(
      collection: 'track_scope',
      rowId: TrackScopeDocumentId.metadata(examId),
      op: SyncLocalMutationOp.upsert,
      mutate: () async {
        final updated = await (_db.update(_db.customTrackMetaLocal)
              ..where((row) => row.examId.equals(examId)))
            .write(CustomTrackMetaLocalCompanion(name: Value(name)));
        if (updated == 0) {
          throw StateError('Unknown custom track: $examId');
        }
        await _setProjectionRequired(examId, required: true);
      },
    );
    await _projectWithoutRollingBackAuthority(examId);
  }

  Future<void> setExcluded({
    required ExamId examId,
    required Set<TopicId> topicIds,
    Set<LessonId>? lessonIds,
  }) =>
      _db.transaction(
        () => _setExcluded(
          examId: examId,
          topicIds: topicIds,
          lessonIds: lessonIds,
        ),
      );

  Future<void> _setExcluded({
    required ExamId examId,
    required Set<TopicId> topicIds,
    Set<LessonId>? lessonIds,
  }) async {
    if (lessonIds != null) {
      await _db.into(_db.accountPrefs).insertOnConflictUpdate(
            AccountPrefsCompanion.insert(
              key: _lessonKey(examId),
              value: jsonEncode(lessonIds.toList()..sort()),
            ),
          );
    }
    final current = await excludedTopicIds(examId);
    final added = topicIds.difference(current);
    final removed = current.difference(topicIds);
    if (added.isEmpty && removed.isEmpty) return;
    final isCustom = await _customTrackMeta(examId) != null;

    await _syncRecorder.runRecordedBatch(
      mutations: [
        for (final topicId in added)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.scope(examId, topicId),
            op: SyncLocalMutationOp.upsert,
          ),
        for (final topicId in removed)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.scope(examId, topicId),
            op: SyncLocalMutationOp.delete,
          ),
      ],
      mutate: () async {
        for (final topicId in removed) {
          await (_db.delete(_db.trackScopeLocal)
                ..where(
                  (row) =>
                      row.examId.equals(examId) & row.topicId.equals(topicId),
                ))
              .go();
        }
        for (final topicId in added) {
          await _db.into(_db.trackScopeLocal).insertOnConflictUpdate(
                TrackScopeLocalCompanion.insert(
                  examId: examId,
                  topicId: topicId,
                ),
              );
        }
        if (isCustom) {
          await _setProjectionRequired(examId, required: true);
        }
      },
    );

    if (isCustom) {
      await _projectWithoutRollingBackAuthority(examId);
    }
  }

  Future<void> delete(ExamId examId) async {
    await (_db.delete(_db.accountPrefs)
          ..where((p) => p.key.equals(_lessonKey(examId))))
        .go();
    final meta = await _customTrackMeta(examId);
    final scope = await excludedTopicIds(examId);
    if (meta == null && scope.isEmpty) return;

    await _syncRecorder.runRecordedBatch(
      mutations: [
        if (meta != null)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.metadata(examId),
            op: SyncLocalMutationOp.delete,
          ),
        for (final topicId in scope)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.scope(examId, topicId),
            op: SyncLocalMutationOp.delete,
          ),
      ],
      mutate: () async {
        await (_db.delete(_db.trackScopeLocal)
              ..where((row) => row.examId.equals(examId)))
            .go();
        await (_db.delete(_db.customTrackMetaLocal)
              ..where((row) => row.examId.equals(examId)))
            .go();
        if (meta != null) {
          await _setProjectionRequired(examId, required: true);
        }
      },
    );

    if (meta != null) {
      await _projectWithoutRollingBackAuthority(examId);
    }
  }

  Future<Set<TopicId>> excludedTopicIds(ExamId examId) async {
    final rows = await (_db.select(_db.trackScopeLocal)
          ..where((s) => s.examId.equals(examId)))
        .get();
    return {for (final row in rows) row.topicId};
  }

  // Account-bound preferences need no schema change and are cleared by the
  // existing account-boundary wipe. Topic rows keep their sync contract.
  String _lessonKey(ExamId examId) => 'settings.excluded_lessons.$examId';

  Future<Set<LessonId>> excludedLessonIds(ExamId examId) async {
    final row = await (_db.select(_db.accountPrefs)
          ..where((p) => p.key.equals(_lessonKey(examId))))
        .getSingleOrNull();
    if (row == null) return {};
    return (jsonDecode(row.value) as List).cast<String>().toSet();
  }

  Future<bool> projectionRequired(ExamId examId) async {
    final row = await _db.customSelect(
      'select value from sync_meta where key = ?',
      variables: [Variable<String>(_projectionMarkerKey(examId))],
    ).getSingleOrNull();
    return row?.read<String>('value') == '1';
  }

  Future<bool> anyProjectionRequired() async {
    final row = await _db.customSelect(
      'select 1 as pending from sync_meta where key like ? '
      "and value = '1' limit 1",
      variables: [const Variable<String>('$_projectionMarkerPrefix%')],
    ).getSingleOrNull();
    return row != null;
  }

  Future<void> retryProjection(ExamId examId) async {
    final meta = await _customTrackMeta(examId);
    if (meta == null) {
      await _projection.delete(examId);
    } else {
      await _projection.upsert(examId: examId, name: meta.name);
    }
    await _setProjectionRequired(examId, required: false);
  }

  Future<bool> retryPendingProjections() async {
    final rows = await _db.customSelect(
      "select key from sync_meta where key like ? and value = '1' order by key",
      variables: [const Variable<String>('$_projectionMarkerPrefix%')],
    ).get();
    var settled = true;
    for (final row in rows) {
      final key = row.read<String>('key');
      final encodedId = key.substring(_projectionMarkerPrefix.length);
      try {
        final identity = TrackScopeDocumentId.parse(encodedId);
        if (identity.kind != TrackScopeDocumentKind.metadata) {
          settled = false;
          continue;
        }
        await retryProjection(identity.examId);
      } on Object {
        settled = false;
      }
    }
    return settled && !await anyProjectionRequired();
  }

  Future<CustomTrackMetaLocalRow?> _customTrackMeta(ExamId examId) {
    return (_db.select(_db.customTrackMetaLocal)
          ..where((row) => row.examId.equals(examId)))
        .getSingleOrNull();
  }

  Future<void> _projectWithoutRollingBackAuthority(ExamId examId) async {
    try {
      await retryProjection(examId);
    } on Object {
      // Authority and the retry marker were committed before projection.
    }
  }

  Future<void> _setProjectionRequired(
    ExamId examId, {
    required bool required,
  }) async {
    final key = _projectionMarkerKey(examId);
    if (!required) {
      await _db.customStatement('delete from sync_meta where key = ?', [key]);
      return;
    }
    await _db.customStatement(
      'insert into sync_meta (key,value) values (?,?) '
      'on conflict(key) do update set value=excluded.value',
      <Object?>[key, '1'],
    );
  }

  String _projectionMarkerKey(ExamId examId) =>
      '$_projectionMarkerPrefix${TrackScopeDocumentId.metadata(examId)}';
}

// The server's own checks on a custom paper (`checkCustomBlueprint`), so a row
// it would refuse is left out of the publish instead of failing it. Keep in
// step with `functions/src/_customTrack.ts`.
final _serverSectionId = RegExp(r'^section_(all|\d{1,3})$');
final _serverTopicId = RegExp(r'^[A-Za-z0-9_.-]{1,160}$');

bool _inRange(Object? value, int min, int max) =>
    value is int && value >= min && value <= max;

bool _serverAcceptsBlueprint(CustomBlueprintRow row) {
  if (utf8.encode(row.sectionsJson).length > 64000) return false;
  final Object? parsed;
  try {
    parsed = jsonDecode(row.sectionsJson);
  } on FormatException {
    return false;
  }
  if (parsed is! List || parsed.isEmpty || parsed.length > 20) return false;
  final ids = <String>{};
  var questions = 0;
  var minutes = 0;
  for (final section in parsed) {
    if (section is! Map) return false;
    final id = section['id'];
    final name = section['name'];
    final count = section['questionCount'];
    final suggested = section['suggestedMinutes'];
    final topics = section['topicIds'];
    if (id is! String || !_serverSectionId.hasMatch(id) || !ids.add(id)) {
      return false;
    }
    if (name is! String || name.isEmpty || name.length > 80) return false;
    if (!_inRange(count, 1, 300) || !_inRange(suggested, 1, 720)) return false;
    if (topics is! List ||
        topics.isEmpty ||
        topics.length > 64 ||
        !topics.every((t) => t is String && _serverTopicId.hasMatch(t))) {
      return false;
    }
    questions += count! as int;
    minutes += suggested! as int;
  }
  if (!_inRange(row.totalQuestions, 1, 300) ||
      row.totalQuestions != questions) {
    return false;
  }
  if (!_inRange(row.totalMinutes, 1, 720)) return false;
  return !row.sectionsTimedSeparately ||
      (parsed.length >= 2 && row.totalMinutes == minutes);
}
