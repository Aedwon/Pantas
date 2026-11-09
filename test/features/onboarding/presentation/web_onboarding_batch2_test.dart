import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_field.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_calendar.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  for (final dark in [false, true]) {
    Future<void> pump(WidgetTester tester, Widget screen) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: Scaffold(body: screen),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('name field uses the Field well padding and a 1 px ring $dark',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(
        tester,
        OnboardingNameField(
          controller: controller,
          label: 'Name',
          onChanged: (_) {},
        ),
      );
      // The Field well is 48 high (`size-field`) with 14 side padding and a
      // 1 px ring.
      final well = tester.widget<Container>(
        find.byKey(const ValueKey('field-well')),
      );
      expect(well.padding, const EdgeInsets.symmetric(horizontal: 14));
      expect(
        tester.getSize(find.byKey(const ValueKey('field-well'))).height,
        greaterThanOrEqualTo(48),
      );
      final ring = (well.foregroundDecoration! as BoxDecoration).border!;
      expect(ring.top.width, 1);
    });

    testWidgets('onboarding buttons are 48 tall $dark', (tester) async {
      await pump(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OnboardingButton(label: 'Continue', onPressed: () {}),
              OnboardingButton(
                label: 'Every Day',
                variant: PantasButtonVariant.tertiary,
                onPressed: () {},
              ),
              OnboardingButton(
                label: 'Different Date',
                variant: PantasButtonVariant.neutral,
                onPressed: () {},
              ),
              WebButton(label: 'Other', onPressed: () {}),
            ],
          ),
        ),
      );
      for (final label in ['Continue', 'Every Day', 'Different Date']) {
        expect(
          tester.getSize(find.widgetWithText(TextButton, label)).height,
          48,
          reason: label,
        );
      }
      final other = find.widgetWithText(TextButton, 'Other');
      expect(tester.getSize(other).height, 44);
    });

    testWidgets('date grid uses 4 px spacing and no today outline $dark',
        (tester) async {
      await pump(
        tester,
        Center(
          child: SizedBox(
            width: 780,
            child: OnboardingWebCalendar(
              value: const MonthFirstDate(year: 2026, month: 10, day: 20),
              today: DateTime(2026, 10, 3),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      final d5 = tester.getTopLeft(find.widgetWithText(TextButton, '5'));
      final d12 = tester.getTopLeft(find.widgetWithText(TextButton, '12'));
      expect(d12.dy - d5.dy, 50);
      final today = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '3'),
      );
      final shape = today.style!.shape!.resolve({})! as RoundedRectangleBorder;
      expect(shape.side, BorderSide.none);
      final cards = find.byType(WebCard);
      expect(
        tester.getSize(cards.at(0)).height,
        tester.getSize(cards.at(1)).height,
      );
    });

    testWidgets('age blocked shows the shared header $dark', (tester) async {
      await pump(
        tester,
        OnboardingAgeGateStep(currentYear: 2026, onAgeGatePassed: () {}),
      );
      await tester.enterText(find.byType(TextField), '2020');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 500));
      final title = tester.widget<Text>(find.text('Pantas').first);
      expect(title.style!.fontSize, 20);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(find.text('Try a Different Year'), findsNothing);
      expect(
        find.text('Entered the wrong year? Email contact@pantas.study.'),
        findsOneWidget,
      );
    });
  }
}
