import 'dart:convert';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/features/home/domain/study_models.dart';

/// Public offline restore is bound to account, exam and the original core.
/// Paid details require a current server read before they can be restored.
class StudyReadCache {
  StudyReadCache(
    this.db, {
    required this.uid,
    required this.examId,
    required this.coreToken,
    required this.isCurrent,
  });
  final AppDatabase db;
  final String uid;
  final String examId;
  final String coreToken;
  final Future<bool> Function() isCurrent;
  String _key(String kind) =>
      'home_read_cache_${uid}_${examId}_${coreToken}_$kind';
  Future<void> write(String kind, Map<String, Object?> value) async {
    final encoded = jsonEncode(value);
    await db.transaction(() async {
      if (!await isCurrent()) throw StateError('Study owner changed');
      await AppPreferencesRepository(db).setDeviceValue(_key(kind), encoded);
      if (!await isCurrent()) throw StateError('Study owner changed');
    });
  }

  Future<Map<String, Object?>?> read(String kind) async {
    if (!await isCurrent()) throw StateError('Study owner changed');
    final encoded = await AppPreferencesRepository(db).deviceValue(_key(kind));
    if (!await isCurrent()) throw StateError('Study owner changed');
    if (encoded == null) return null;
    final value = Map<String, Object?>.of(studyMap(jsonDecode(encoded)));
    value['proCovered'] = false;
    value.removeWhere(
      (key, _) => const {
        'comingUp',
        'history',
        'tendencies',
        'whenYouWork',
        'trialEndsAt',
      }.contains(key),
    );
    if (value['performance'] != null) {
      final performance =
          Map<String, Object?>.of(studyMap(value['performance']))
            ..removeWhere((key, _) => key == 'topics' || key == 'lessons');
      value['performance'] = Map<String, Object?>.unmodifiable(performance);
    }
    return Map.unmodifiable(value);
  }
}
