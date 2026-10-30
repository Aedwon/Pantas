import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/steps_screen.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  for (final dark in [false, true]) {
    testWidgets('settings steps use a centered column dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: const StepsScreen(
            title: 'Restoring your progress',
            subtitle: 'Signed in as student@example.com',
            steps: [
              WorkStep(label: 'Your answers', state: WorkStepState.done),
              WorkStep(
                label: 'Lessons, bookmarks and flags',
                state: WorkStepState.done,
              ),
              WorkStep(
                label: 'Your plan',
                state: WorkStepState.active,
                detail: 'Rebuilt from your progress',
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Restoring your progress'), findsOneWidget);
      expect(find.byType(WebCard), findsOneWidget);
      expect(tester.getSize(find.byType(WebCard)).width, 520);
      expect(find.byKey(const ValueKey('step-done-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('step-done-1')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
