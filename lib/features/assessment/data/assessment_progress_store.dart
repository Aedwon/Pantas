import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/features/assessment/domain/models/assessment_progress.dart';

/// Saved assessment progress on this device (device prefs, no table, no sync).
/// One entry per account and exam. `local_state_wiper.dart` removes them all
/// by key prefix when an account is wiped.
class AssessmentProgressStore {
  const AssessmentProgressStore(this._prefs);

  final AppPreferencesRepository _prefs;

  Future<AssessmentProgress?> load(String uid, String examId) async {
    final raw = await _prefs.deviceValue(
      AppPreferencesRepository.assessmentProgressKey(uid, examId),
    );
    return raw == null ? null : AssessmentProgress.tryParse(raw);
  }

  Future<void> save(String uid, AssessmentProgress progress) =>
      _prefs.setDeviceValue(
        AppPreferencesRepository.assessmentProgressKey(uid, progress.examId),
        progress.encode(),
      );

  Future<void> clear(String uid, String examId) => _prefs.removeDeviceValue(
        AppPreferencesRepository.assessmentProgressKey(uid, examId),
      );
}
