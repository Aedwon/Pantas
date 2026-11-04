import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/presentation/plan_web.dart';

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  testWidgets(
      'Plan shares the left edge of the other pages in a window wider than '
      'the page (3K-15)', (tester) async {
    // A 1180 px landscape tablet: the shell leaves 1092 px for the page.
    tester.view
      ..physicalSize = const Size(1180, 820)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: PlanWebFrame(
            title: 'Your plan',
            onBack: () {},
            child: const SizedBox(height: 40, child: Text('Body')),
          ),
        ),
      ),
    );
    await tester.pump();
    // 44 px of shell padding plus half of the 12 px the page does not use.
    expect(tester.getTopLeft(find.text('Your plan')).dx, 50);
    expect(tester.getTopLeft(find.text('Body')).dx, 50);
  });
}
