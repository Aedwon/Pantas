import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/legal/presentation/legal_document_page.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('privacy is a plain reading page with no account controls',
      (tester) async {
    await tester.pumpApp(
      const LegalDocumentPage(
        documentId: 'privacy',
        contact: defaultLegalContact,
      ),
    );
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Manage account data'), findsNothing);
    expect(find.text('Data Protection Officer'), findsNothing);
  });

  testWidgets('terms page renders terms sections', (tester) async {
    await tester.pumpApp(
      const LegalDocumentPage(
        documentId: 'terms',
        contact: defaultLegalContact,
      ),
    );

    expect(find.text('Terms of Service'), findsWidgets);
    expect(find.text('Use of the app'), findsOneWidget);
    expect(find.text('Subscriptions'), findsOneWidget);
    expect(find.text('Intellectual property'), findsOneWidget);
  });

  testWidgets('the onboarding legal page draws the system Back link',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: const OnboardingLegalPage(documentId: 'terms'),
      ),
    );
    await tester.pump();
    final back = find.byType(WebBackLink);
    expect(back, findsOneWidget);
    expect(
      find.descendant(of: back, matching: find.text('Back')),
      findsOneWidget,
    );
    expect(find.byType(SvgPicture), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.text('Terms of Service'), findsWidgets);
  });

  // BackLink README: a chevron, the label, a hit area at least `size-back`
  // (40) high on wide screens and 44 on a phone, and a tap goes back.
  for (final width in [1440.0, 390.0]) {
    testWidgets(
        'the legal Back link at $width has a chevron, a hit area and '
        'goes back', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = Size(width, 900)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const OnboardingLegalPage(documentId: 'terms'),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final back = find.byType(WebBackLink);
      expect(back, findsOneWidget);
      final chevron = find.descendant(
        of: back,
        matching: find.byIcon(PantasIcons.bold(PantasIcons.back)),
      );
      expect(chevron, findsOneWidget);
      expect(
        tester.widget<Icon>(chevron).size,
        PantasSize.icon,
        reason: 'the chevron is 20',
      );
      final hit = find.descendant(of: back, matching: find.byType(TextButton));
      expect(tester.getSize(hit).height, greaterThanOrEqualTo(40));
      if (width < 1024) {
        // Off wide screens the link sits in a padded 44 touch area.
        final touch =
            find.ancestor(of: hit, matching: find.byType(TouchTarget));
        expect(tester.getSize(touch.first).height, greaterThanOrEqualTo(44));
      }
      await tester.tap(find.descendant(of: back, matching: find.text('Back')));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingLegalPage), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  }

  testWidgets('unknown legal doc renders not found state', (tester) async {
    await tester.pumpApp(
      const LegalDocumentPage(
        documentId: 'missing',
        contact: defaultLegalContact,
      ),
    );

    expect(find.text('Legal page not found'), findsOneWidget);
  });
}
