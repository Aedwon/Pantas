import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/wrapped/application/wrapped_providers.dart';
import 'package:pantas/features/wrapped/presentation/wrapped_reveal_page.dart';

void main() {
  group('Wrapped offline copy', () {
    testWidgets('shows connection copy when wrapped fails to load',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            wrappedArtifactProvider('stub').overrideWith(
              (ref) => Future.error(Exception('Network error')),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const WrappedRevealPage(artifactId: 'stub'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          "Your Wrapped needs a connection. It'll be here when you're back.",
        ),
        findsOneWidget,
      );
    });
  });
}
