import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
