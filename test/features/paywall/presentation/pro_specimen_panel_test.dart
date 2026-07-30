import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/presentation/pro_specimen_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: SingleChildScrollView(child: ProSpecimenPanel()),
        ),
      ),
    );
  }

  testWidgets('marks itself as a sample in the plate, above the figures',
      (tester) async {
    await pump(tester);
    expect(find.text('Under pressure'), findsOneWidget);
    expect(find.text('Sample'), findsOneWidget);
  });

  testWidgets('prints both tier tags and both comparison labels',
      (tester) async {
    await pump(tester);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Pro'), findsOneWidget);
    expect(find.textContaining('practising'), findsWidgets);
    expect(find.textContaining('under time'), findsWidgets);
  });

  testWidgets('uses no lock icon and no card', (tester) async {
    await pump(tester);
    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byType(Card), findsNothing);
  });
}
