import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/first_run/domain/first_run_progress.dart';

/// The open run on this device (device prefs, one key). The value names the
/// account and exam, so another account on the device never sees it. The
/// account wipe deletes the key.
class FirstRunStore {
  FirstRunStore(this._prefs);

  static const key = firstRunDeviceKey;

  final AppPreferencesRepository _prefs;

  /// The open run for [uid] and [examId], or null when none is open.
  Future<FirstRunProgress?> load({
    required String uid,
    required String examId,
  }) async {
    final p = FirstRunProgress.decode(await _prefs.deviceValue(key));
    return p != null && p.uid == uid && p.examId == examId ? p : null;
  }

  Future<void> open({required String uid, required String examId}) =>
      save(FirstRunProgress(uid: uid, examId: examId));

  Future<void> save(FirstRunProgress progress) =>
      _prefs.setDeviceValue(key, progress.encode());

  /// Done or Skip. An empty value reads as no run.
  Future<void> clear() => _prefs.setDeviceValue(key, '');
}
