import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';

class AppPreferencesRepository {
  AppPreferencesRepository(this._db);

  static const _selectedExamIdKey = 'selected_exam_id';
  static const _passedAgeGateKey = 'passed_age_gate';
  static const _onboardingCompleteKey = 'onboarding_complete';
  static const _contentSeedVersionKey = 'content_seed_version';
  static const _appliedContentVersionKey = 'applied_content_version';
  static const _recentLessonsPrefix = 'recent_lessons_';
  static const _openTopicPrefix = 'open_topic_';
  static const _recentLessonsKept = 3;

  final AppDatabase _db;

  Future<bool> hasCompletedOnboarding() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_onboardingCompleteKey)))
        .getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> setCompletedOnboarding({required bool value}) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: _onboardingCompleteKey,
            value: value ? 'true' : 'false',
          ),
        );
  }

  Future<String?> selectedExamId() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_selectedExamIdKey)))
        .getSingleOrNull();
    if (row != null) return row.value;

    final legacyRow = await (_db.select(_db.appPreferencesLocal)
          ..where((p) => p.key.equals(_selectedExamIdKey)))
        .getSingleOrNull();
    return legacyRow?.value;
  }

  Future<void> setSelectedExamId(String examId) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: _selectedExamIdKey,
            value: examId,
          ),
        );
  }

  Future<bool> hasPassedAgeGate() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_passedAgeGateKey)))
        .getSingleOrNull();
    if (row != null) return row.value == 'true';

    final legacyRow = await (_db.select(_db.appPreferencesLocal)
          ..where((p) => p.key.equals(_passedAgeGateKey)))
        .getSingleOrNull();
    return legacyRow?.value == 'true';
  }

  Future<void> setPassedAgeGate({required bool value}) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: _passedAgeGateKey,
            value: value ? 'true' : 'false',
          ),
        );
  }

  Future<String?> installedContentSeedVersion() =>
      _deviceValue(_contentSeedVersionKey);

  Future<void> setInstalledContentSeedVersion(String version) =>
      _setDeviceValue(_contentSeedVersionKey, version);

  Future<int?> appliedContentVersion() async {
    final raw = await _deviceValue(_appliedContentVersionKey);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<void> setAppliedContentVersion(int version) =>
      _setDeviceValue(_appliedContentVersionKey, version.toString());

  /// The lessons most recently opened for this exam, newest first, at most
  /// three. Device-local on purpose: only `account_prefs` sync, and where
  /// someone was reading is a property of one screen on one device.
  Future<List<String>> recentlyOpenedLessonIds(String examId) async {
    final raw = await _deviceValue('$_recentLessonsPrefix$examId');
    if (raw == null || raw.isEmpty) return const [];
    return raw.split(',');
  }

  Future<String?> lastOpenedLessonId(String examId) async {
    final recent = await recentlyOpenedLessonIds(examId);
    return recent.isEmpty ? null : recent.first;
  }

  /// Moves [lessonId] to the head. Reopening something already in the list
  /// moves it rather than duplicating it, so three entries always name three
  /// lessons.
  Future<void> pushOpenedLesson({
    required String examId,
    required String lessonId,
  }) async {
    // A copy: the getter returns a const list when nothing is stored, and
    // removing from that throws.
    final recent = [...await recentlyOpenedLessonIds(examId)]..remove(lessonId);
    final next = [lessonId, ...recent].take(_recentLessonsKept);
    await _setDeviceValue(
      '$_recentLessonsPrefix$examId',
      next.join(','),
    );
  }

  Future<String?> openTopicId(String examId) =>
      _deviceValue('$_openTopicPrefix$examId');

  /// A null [topicId] means the student collapsed the topic, so the row goes
  /// rather than storing an empty string that every reader has to special-case.
  Future<void> setOpenTopicId({
    required String examId,
    required String? topicId,
  }) async {
    final key = '$_openTopicPrefix$examId';
    if (topicId == null) {
      await (_db.delete(_db.devicePrefs)..where((p) => p.key.equals(key))).go();
      return;
    }
    await _setDeviceValue(key, topicId);
  }

  Future<bool> hasAnnouncedFirstFlag() async {
    final raw = await _deviceValue('first_flag_announced');
    return raw == 'true';
  }

  Future<void> setAnnouncedFirstFlag() =>
      _setDeviceValue('first_flag_announced', 'true');

  Future<String?> deviceValue(String key) => _deviceValue(key);

  Future<void> setDeviceValue(String key, String value) =>
      _setDeviceValue(key, value);

  Future<String?> _deviceValue(String key) async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _setDeviceValue(String key, String value) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(key: key, value: value),
        );
  }
}
