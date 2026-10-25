import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('Privacy policy'), findsOneWidget);
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
