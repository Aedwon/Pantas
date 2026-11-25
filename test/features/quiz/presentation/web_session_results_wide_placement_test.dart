import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';

import '../../../helpers/button_placement.dart';
import 'session_end_screen_test.dart' show completedAttempt, completedSession;

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  testWidgets('wide results Done and Start Session keep the 8 px gap',
      (tester) async {
    // Button placement rule: 8 px between a pair; it was 12 px before Nov 25.
    debugWebPlatformOverride = true;
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final session = completedSession(batch: true);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                size: Size(1440, 900),
                disableAnimations: true,
              ),
              child: SessionEndBody(
                session: session,
                attempt: completedAttempt(session),
                subjectNames: const {'t': 'Science'},
                proIsActive: false,
                onDone: () {},
                onQuestion: (_) {},
                onAll: () {},
                onMistakes: () {},
                onNotes: () {},
                onNext: () async {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expectWidePlacement(tester);
  });
}
