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
  const SyncActiveContextSnapshot({
    required this.token,
    required this.context,
    required this.rememberedContext,
  });

  final String token;
  final SyncActiveContext? context;

  /// The local data owner, even while its active Sync context is suspended.
  final SyncActiveContext? rememberedContext;
}

class SyncActiveContextStore {
  SyncActiveContextStore(this._db);

  /// The sync_meta row that holds the active context and its token.
  static const metaKey = 'syncActiveContext';
  static const _metaKey = metaKey;
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
        return SyncActiveContextSnapshot(
          token: token,
          context: null,
          rememberedContext: null,
        );
      }
      if (uid is! String || uid.isEmpty) return null;
      if (generationId is! String || generationId.isEmpty) return null;
      final remembered = SyncActiveContext(
        uid: uid,
        generationId: generationId,
      );
      return SyncActiveContextSnapshot(
        token: token,
        context: decoded['suspended'] == true ? null : remembered,
        rememberedContext: remembered,
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
    final current = await readSnapshot();
    final owner = SyncActiveContext(uid: uid, generationId: generationId);
    await _writeEnvelope(
      <String, Object?>{
        'token':
            current?.rememberedContext == owner ? current!.token : _nextToken(),
        'uid': uid,
        'generationId': generationId,
      },
    );
  }

  /// Stops exposing an active context without changing the local data owner.
  Future<void> suspendStable() async {
    final current = await readSnapshot();
    if (current == null) return clearStable();
    final owner = current.context;
    if (owner == null) return;
    await _writeEnvelope(<String, Object?>{
      'token': current.token,
      'uid': owner.uid,
      'generationId': owner.generationId,
      'suspended': true,
    });
  }

  /// Clears the context. A context that is already cleared keeps its token:
  /// every entitlement refresh calls this, and a new token would make
  /// guards that Home and Quiz captured from it fail with no real change.
  Future<void> clearStable() async {
    final current = await readSnapshot();
    if (current != null && current.rememberedContext == null) return;
    await renewToken();
  }

  /// Expires guards and forgets the owner when a full snapshot replaces data.
  Future<void> renewToken() =>
      _writeEnvelope(<String, Object?>{'token': _nextToken()});

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
