import 'package:pantas/features/study_plan/data/plan_prefs_gateway.dart';
import 'package:pantas/features/study_plan/domain/plan_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exam date update serializes only examDate and examDateIsProvisional',
      () {
    final update = PlanPrefsCloudUpdate.examDate(
      DateTime(2026, 8, 21),
      provisional: false,
    );

    expect(update.fields, {
      'examDate': '2026-08-21',
      'examDateIsProvisional': false,
    });
  });

  test('intensity update serializes only intensityPreset', () {
    final update = PlanPrefsCloudUpdate.intensity(StudyPlanIntensity.intense);

    expect(update.fields, {'intensityPreset': 'intense'});
  });

  test('acknowledgement update serializes only acknowledgement timestamp', () {
    final update = PlanPrefsCloudUpdate.acknowledgedAt(
      DateTime.utc(2026, 5, 21, 6, 30),
    );

    expect(
      update.fields,
      {'lastPlanAcknowledgedAt': '2026-05-21T06:30:00.000Z'},
    );
  });
}
