import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/presentation/quiz_note_editor.dart';

import '../../../helpers/button_placement.dart';
import '../../../helpers/pump_app.dart';

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  for (final existing in [false, true]) {
    testWidgets(
        'wide note editor pair keeps the 8 px gap (existing: $existing)',
        (tester) async {
      // Button placement rule: 8 px between a pair; it was 4 px before Nov 25.
      debugWebPlatformOverride = true;
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        QuizNoteEditor(
          tag: existing ? MistakeTag.misread : null,
          onCancel: () {},
          onSave: (_, __) async {},
        ),
      );
      await tester.pumpAndSettle();
      expectWidePlacement(tester);
    });
  }
}
