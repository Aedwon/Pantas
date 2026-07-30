import 'package:pantas/features/study_plan/domain/plan_prefs.dart';

class PlanPrefsCloudUpdate {
  const PlanPrefsCloudUpdate._(this.fields);

  factory PlanPrefsCloudUpdate.examDate(
    DateTime date, {
    required bool provisional,
  }) {
    return PlanPrefsCloudUpdate._({
      'examDate': _formatDate(date),
      'examDateIsProvisional': provisional,
    });
  }

  factory PlanPrefsCloudUpdate.intensity(StudyPlanIntensity intensity) {
    return PlanPrefsCloudUpdate._({
      'intensityPreset': intensity.storageValue,
    });
  }

  factory PlanPrefsCloudUpdate.acknowledgedAt(DateTime date) {
    return PlanPrefsCloudUpdate._({
      'lastPlanAcknowledgedAt': date.toUtc().toIso8601String(),
    });
  }

  final Map<String, Object?> fields;

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
