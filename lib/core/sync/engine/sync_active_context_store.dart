import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:pantas/core/storage/data/app_database.dart';

@immutable
class SyncActiveContext {
  const SyncActiveContext({required this.uid, required this.generationId});

  final String uid;
  final String generationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncActiveContext &&
          other.uid == uid &&
          other.generationId == generationId;

  @override
  int get hashCode => Object.hash(uid, generationId);
}

class SyncActiveContextSnapshot {
  const SyncActiveContextSnapshot({required this.token, required this.context});

  final String token;
  final SyncActiveContext? context;
}

class SyncActiveContextStore {
  SyncActiveContextStore(this._db);

  static const _metaKey = 'syncActiveContext';
  static int _tokenSequence = 0;

  final AppDatabase _db;

  Future<SyncActiveContext?> readStable() async =>
      (await readSnapshot())?.context;

  Future<SyncActiveContextSnapshot?> readSnapshot() async {
    final rows = await _db
        .customSelect(
          "select value from sync_meta where key = 'syncActiveContext'",
        )
        .get();
    if (rows.isEmpty) return null;

    final raw = rows.single.read<String>('value');
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final token = decoded['token'];
      if (token is! String || token.isEmpty) return null;

      final uid = decoded['uid'];
      final generationId = decoded['generationId'];
      if (uid == null && generationId == null) {
        return SyncActiveContextSnapshot(token: token, context: null);
      }
      if (uid is! String || uid.isEmpty) return null;
      if (generationId is! String || generationId.isEmpty) return null;
      return SyncActiveContextSnapshot(
        token: token,
        context: SyncActiveContext(uid: uid, generationId: generationId),
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> publishStable({
    required String uid,
    required String generationId,
  }) async {
    if (uid.isEmpty) throw ArgumentError.value(uid, 'uid', 'must not be empty');
    if (generationId.isEmpty) {
      throw ArgumentError.value(
        generationId,
        'generationId',
        'must not be empty',
      );
    }
    await _writeEnvelope(
      <String, Object?>{
        'token': _nextToken(),
        'uid': uid,
        'generationId': generationId,
      },
    );
  }

  Future<void> clearStable() => _writeEnvelope(
        <String, Object?>{'token': _nextToken()},
      );

  Future<void> _writeEnvelope(Map<String, Object?> envelope) =>
      _db.customStatement(
        'insert into sync_meta (key,value) values (?,?) '
        'on conflict(key) do update set value=excluded.value',
        <Object?>[_metaKey, jsonEncode(envelope)],
      );

  static String _nextToken() {
    _tokenSequence += 1;
    return '${DateTime.now().microsecondsSinceEpoch}-$_tokenSequence';
  }
}
