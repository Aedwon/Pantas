import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

void main() {
  testWidgets('wide notice shows the Enter chip and Enter presses the action',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: WebFullNotice(
          title: 'Something went wrong.',
          lead: "Nothing you've done is lost.",
          actionLabel: 'Try Again',
          onPressed: () => pressed++,
        ),
      ),
    );
    await tester.pump();
    // Boards SY_Error and SY_Update draw an Enter chip on the button.
    expect(find.text('Enter'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(pressed, 1);
    await tester.tap(find.text('Try Again'));
    expect(pressed, 2);
  });
}
