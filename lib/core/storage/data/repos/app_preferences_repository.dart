import 'package:pantas/core/storage/data/app_database.dart';

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
    if (row != null) return row.value == 'true';

    // Installs from before the flag existed finished onboarding the moment
    // they chose an exam. Treat that as complete rather than sending them
    // back through a flow they already did.
    return await selectedExamId() != null;
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

  /// `minor` or `adult`. Only the group is kept, never the age.
  Future<String?> ageGroup() => _deviceValue('age_group');

  Future<void> setAgeGroup(String group) => _setDeviceValue('age_group', group);

  /// The minimum age in force when a student was blocked, or null if never
  /// blocked. The block lasts until support clears it, so it survives a reload.
  /// The version of the age step line the student saw when the group was set.
  Future<String?> ageCheckNoticeVersion() =>
      _deviceValue('age_check_notice_version');

  Future<void> setAgeCheckNoticeVersion(String version) =>
      _setDeviceValue('age_check_notice_version', version);

  /// The wording of the setup acceptance the student agreed to.
  Future<String?> setupAcceptanceVersion() =>
      _deviceValue('setup_acceptance_version');

  Future<void> setSetupAcceptanceVersion(String version) =>
      _setDeviceValue('setup_acceptance_version', version);

  /// `uid|version` once the server has the acceptance for that account.
  Future<String?> setupAcceptanceRecordedFor() =>
      _deviceValue('setup_acceptance_recorded_for');

  Future<void> setSetupAcceptanceRecordedFor(String marker) =>
      _setDeviceValue('setup_acceptance_recorded_for', marker);

  Future<int?> blockedMinimumAge() async {
    final raw = await _deviceValue('age_blocked_minimum');
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> setBlockedMinimumAge(int minimumAge) =>
      _setDeviceValue('age_blocked_minimum', '$minimumAge');

  /// Kept on this device only, so the student can resend the link. The
  /// server keeps hashes and a masked address.
  Future<({String name, String email})?> guardianContact() async {
    final name = await _deviceValue('guardian_contact_name');
    final email = await _deviceValue('guardian_contact_email');
    if (name == null || email == null) return null;
    return (name: name, email: email);
  }

  Future<void> setGuardianContact({
    required String name,
    required String email,
  }) async {
    await _setDeviceValue('guardian_contact_name', name);
    await _setDeviceValue('guardian_contact_email', email);
  }

  Future<void> clearGuardianContact() async {
    await (_db.delete(_db.devicePrefs)
          ..where(
            (p) => p.key.isIn(
              const ['guardian_contact_name', 'guardian_contact_email'],
            ),
          ))
        .go();
  }

  /// The last status the server gave. The server stays the source of truth;
  /// this only covers a start with no connection.
  Future<String?> guardianStatusCache() => _deviceValue('guardian_status');

  Future<void> setGuardianStatusCache(String status) =>
      _setDeviceValue('guardian_status', status);

  /// True once a guardian's permission to share usage was applied on this
  /// device. It lets the student turn sharing off without it coming back.
  Future<bool> guardianSharingApplied() async =>
      await _deviceValue('guardian_sharing_applied') == 'true';

  Future<void> setGuardianSharingApplied({required bool value}) =>
      _setDeviceValue('guardian_sharing_applied', value ? 'true' : 'false');

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
