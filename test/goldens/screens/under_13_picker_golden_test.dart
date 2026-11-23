// Under-13 boards, built 1:1 from the picked boards. One sheet per screen, at
// the phone width the boards are drawn at (390).
//   5    under_13_picker_child     EX5.dc.html
//   3A   under_13_picker_question  Q3A.dc.html
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/onboarding/application/exam_picker_availability.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';

import '../../helpers/in_memory_database.dart';
import 'screen_harness.dart';

const _phone = [390.0];

ExamCatalogEntry _entry(String id, String name, String group) =>
    ExamCatalogEntry(
      id: id,
      name: name,
      shortName: name,
      priceTier: 'test',
      group: group,
      comingSoon: false,
      publishedSittings: const [],
      hasContent: true,
    );

final _catalog = [
  _entry('exam_upcat', 'UPCAT', 'College entrance'),
  _entry('exam_acet', 'ACET', 'College entrance'),
  _entry('exam_pshs_nce', 'PSHS-NCE', 'High school'),
  _entry('exam_cse_pro', 'CSE Professional', 'Civil service'),
];

Future<Finder> _pump(
  WidgetTester tester,
  double width, {
  required AgeGroup ageGroup,
}) async {
  final db = inMemoryDatabase();
  afterCapture(db.close);
  final target = await pumpScreen(
    tester,
    width,
    ExamPickerScreen(
      mode: ExamPickerMode.onboarding,
      onPicked: (_) async {},
      onBack: () {},
      onCustom: () {},
      customExams: false,
    ),
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      examPickerPolicyProvider.overrideWithValue(
        ExamPickerPolicy(ageGroup: ageGroup, isWeb: true),
      ),
      examPickerCatalogProvider.overrideWith((ref) => Stream.value(_catalog)),
      activeExamFocusProvider.overrideWith(
        (ref) async => const ActiveExamFocus.needsSelection(),
      ),
    ],
  );
  return target;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  goldenScreen(
    'under_13_picker_child',
    (tester, width) async {
      final target = await _pump(tester, width, ageGroup: AgeGroup.child);
      // PSHS-NCE is the one pick, shown chosen as the board draws it.
      await tester.tap(find.byKey(const ValueKey('exam-exam_pshs_nce')));
      await settleFrames(tester, 3);
      return target;
    },
    widths: _phone,
  );

  goldenScreen(
    'under_13_picker_question',
    (tester, width) async {
      await _pump(tester, width, ageGroup: AgeGroup.adult);
      await tester.tap(find.byKey(const ValueKey('exam-exam_pshs_nce')));
      await settleFrames(tester, 4);
      // The dialog is its own route, so the whole app is captured.
      return find.byType(MaterialApp);
    },
    widths: _phone,
  );
}
