import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

import '../../../helpers/pump_app.dart';

// U14: HP_WeekStrip (D196) draws the chip as "CSE Pro"; the Nov 25 UX lead
// ruling names the other CSE chip "CSE Subpro". Every other exam keeps its
// catalog short name.
void main() {
  Future<String> chipName(String id, String shortName) async {
    final container = ProviderContainer(
      overrides: [
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(
            buildExam(id: id, shortName: shortName),
          ),
        ),
        userSettingsProvider.overrideWith((_) async => UserSettings.defaults()),
      ],
    );
    addTearDown(container.dispose);
    final data = await container.read(homeMastheadProvider.future);
    return data.examShortName;
  }

  test('CSE Professional chip says CSE Pro', () async {
    expect(await chipName('exam_cse_pro', 'CSE Professional'), 'CSE Pro');
  });

  test('CSE Subprofessional chip says CSE Subpro', () async {
    expect(
      await chipName('exam_cse_sub', 'CSE Subprofessional'),
      'CSE Subpro',
    );
  });

  test('other exams keep the catalog short name', () async {
    expect(await chipName('upcat', 'UPCAT'), 'UPCAT');
  });
}
