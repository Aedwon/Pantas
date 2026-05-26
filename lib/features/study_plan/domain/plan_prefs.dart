enum StudyPlanIntensity {
  light,
  standard,
  intense;
}

extension StudyPlanIntensityX on StudyPlanIntensity {
  String get storageValue => name;

  static StudyPlanIntensity fromStorage(String? value) {
    for (final intensity in StudyPlanIntensity.values) {
      if (intensity.storageValue == value) return intensity;
    }
    return StudyPlanIntensity.standard;
  }
}

class PlanPrefs {
  const PlanPrefs({
    this.examDate,
    this.examDateIsProvisional = true,
    this.intensity = StudyPlanIntensity.standard,
    this.planUpdatedPending = false,
  });

  final DateTime? examDate;
  final bool examDateIsProvisional;
  final StudyPlanIntensity intensity;
  final bool planUpdatedPending;

  String? get examDateKey {
    final date = examDate;
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
