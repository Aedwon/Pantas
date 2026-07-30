import 'package:pantas/features/study_plan/domain/plan_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('intensity parses lowercase stored values', () {
    expect(
      StudyPlanIntensityX.fromStorage('light'),
      StudyPlanIntensity.light,
    );
    expect(
      StudyPlanIntensityX.fromStorage('standard'),
      StudyPlanIntensity.standard,
    );
    expect(
      StudyPlanIntensityX.fromStorage('intense'),
      StudyPlanIntensity.intense,
    );
  });

  test('unknown intensity falls back to standard', () {
    expect(
      StudyPlanIntensityX.fromStorage('weekend'),
      StudyPlanIntensity.standard,
    );
  });

  test('date key keeps calendar day independent of timezone', () {
    final prefs = PlanPrefs(
      examDate: DateTime(2026, 5, 15, 23, 30),
    );

    expect(prefs.examDateKey, '2026-05-15');
  });
}
