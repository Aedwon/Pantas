import 'package:cse_cet_reviewer/features/legal/legal.dart';
import 'package:cse_cet_reviewer/features/legal/presentation/legal_document_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'privacy page renders title update date DPO contact and delete deep link',
      (tester) async {
    var location = '/legal/privacy';
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/legal/:doc',
          builder: (_, state) => LegalDocumentPage(
            documentId: state.pathParameters['doc']!,
            contact: defaultLegalContact,
          ),
        ),
        GoRoute(
          path: '/settings/account',
          builder: (_, __) => const Scaffold(body: Text('Account destination')),
        ),
      ],
      redirect: (_, state) {
        location = state.uri.toString();
        return null;
      },
    );

    await tester.pumpAppWithRouter(router);

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.textContaining('Updated May 23, 2026'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text(defaultLegalContact.dpoEmail), findsOneWidget);
    expect(
      find.textContaining(defaultLegalContact.physicalAddress),
      findsOneWidget,
    );

    await tester.tap(find.text('Manage account data'));
    await tester.pumpAndSettle();

    expect(location, '/settings/account');
    expect(find.text('Account destination'), findsOneWidget);
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
