import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/wrapped/presentation/share_privacy_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the public-link disclosure line', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: SharePrivacySheet(
            selection: const SharePrivacySelection(
              includeArchetype: false,
              includeScore: false,
            ),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text(SharePrivacySheet.hostingDisclosure), findsOneWidget);
  });
}
