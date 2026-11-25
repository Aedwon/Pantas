import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/presentation/web_assessment_layout.dart';

import '../../../helpers/button_placement.dart';

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> show(WidgetTester tester, {required bool wide}) async {
    tester.view
      ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugWebPlatformOverride = wide;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: wide),
        home: Scaffold(
          body: WebAssessmentLeaveDialog(onKeepGoing: () {}, onLeave: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const body = 'Your answers are saved on this device. Continue from Home.';

  testWidgets('phone: the drawn copy and a side-by-side pair, Leave teal',
      (tester) async {
    await show(tester, wide: false);
    expect(find.text('Leave the assessment?'), findsOneWidget);
    expect(find.text(body), findsOneWidget);
    expect(find.text("Your answers so far won't be kept."), findsNothing);
    final keep = find.widgetWithText(PantasButton, 'Keep Going');
    final leave = find.widgetWithText(PantasButton, 'Leave');
    expect(
        tester.widget<PantasButton>(keep).variant, PantasButtonVariant.neutral);
    expect(tester.widget<PantasButton>(leave).variant,
        PantasButtonVariant.primary);
    final keepRect = tester.getRect(keep);
    final leaveRect = tester.getRect(leave);
    expect(keepRect.height, greaterThanOrEqualTo(46));
    expect(leaveRect.height, greaterThanOrEqualTo(46));
    expect(leaveRect.width, keepRect.width);
    expect(keepRect.right, lessThan(leaveRect.left));
    expect(leaveRect.center.dy, closeTo(keepRect.center.dy, 1));
  });

  testWidgets(
      'wide: Keep Going tertiary then Leave teal, no key hint, at '
      'the right', (tester) async {
    await show(tester, wide: true);
    expect(find.text('Leave the assessment?'), findsOneWidget);
    expect(find.text(body), findsOneWidget);
    final keep = find.widgetWithText(WebButton, 'Keep Going');
    final leave = find.widgetWithText(WebButton, 'Leave');
    expect(tester.widget<WebButton>(keep).variant, WebButtonVariant.tertiary);
    expect(tester.widget<WebButton>(leave).variant, WebButtonVariant.primary);
    expect(tester.widget<WebButton>(leave).keyHint, isNull);
    final keepRect = tester.getRect(keep);
    final leaveRect = tester.getRect(leave);
    expect(keepRect.right, lessThan(leaveRect.left));
    expect(leaveRect.center.dy, closeTo(keepRect.center.dy, 1));
    final dialog = tester.getRect(find.byKey(const ValueKey(
      'centered-dialog-surface',
    )));
    expect(dialog.right - leaveRect.right, closeTo(24, 1));
    expectWidePlacement(tester);
  });
}
