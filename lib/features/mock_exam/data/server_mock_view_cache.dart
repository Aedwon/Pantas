import 'dart:convert';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/features/mock_exam/application/server_mock_session.dart';

/// The question the student was on and the questions they flagged, kept on
/// this device under the account and mock they belong to. It is a
/// convenience only: the paper, clock and answers are the server's.
class ServerMockViewCache implements ServerMockViewStore {
  ServerMockViewCache(AppDatabase db) : _prefs = AppPreferencesRepository(db);

  final AppPreferencesRepository _prefs;

  static String keyFor(String uid, String mockId) =>
      'server_mock_view_${uid}_$mockId';

  @override
  Future<void> write({
    required String uid,
    required String mockId,
    required int cursor,
    required Set<String> flags,
  }) =>
      _prefs.setDeviceValue(
        keyFor(uid, mockId),
        jsonEncode({'cursor': cursor, 'flags': flags.toList()..sort()}),
      );

  /// Null when nothing usable is stored; a damaged value is ignored, never
  /// guessed at.
  Future<({int cursor, Set<String> flags})?> read({
    required String uid,
    required String mockId,
  }) async {
    try {
      final raw = await _prefs.deviceValue(keyFor(uid, mockId));
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final cursor = decoded['cursor'];
      final flags = decoded['flags'];
      if (cursor is! int || cursor < 0 || flags is! List) return null;
      return (
        cursor: cursor,
        flags: {
          for (final flag in flags)
            if (flag is String) flag,
        },
      );
    } on Object {
      return null;
    }
  }
}
