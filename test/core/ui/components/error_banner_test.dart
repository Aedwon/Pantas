import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('ErrorBanner', () {
    testWidgets('error variant carries no emoji and a rust accent',
        (tester) async {
      await tester.pumpApp(
        const ErrorBanner(
          variant: ErrorBannerVariant.error,
          message: 'Something broke',
        ),
      );
      expect(find.textContaining('⚠'), findsNothing);
      final accent = tester.widget<Container>(
        find.byKey(const Key('error-banner-accent')),
      );
      expect(accent.color, AppColors.light.rust);
    });

    testWidgets('error variant shows message and retry label', (tester) async {
      await tester.pumpApp(
        ErrorBanner(
          variant: ErrorBannerVariant.error,
          message: 'Could not save answer',
          actionLabel: 'Retry',
          onAction: () {},
        ),
      );
      expect(find.text('Could not save answer'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('offline variant shows dismiss button', (tester) async {
      await tester.pumpApp(
        ErrorBanner(
          variant: ErrorBannerVariant.offline,
          message: 'Offline — progress is saved',
          onDismiss: () {},
        ),
      );
      expect(find.text('Offline — progress is saved'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('success variant shows message', (tester) async {
      await tester.pumpApp(
        const ErrorBanner(
          variant: ErrorBannerVariant.success,
          message: 'Progress synced',
        ),
      );
      expect(find.text('Progress synced'), findsOneWidget);
    });

    testWidgets('error variant fires onAction callback', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        ErrorBanner(
          variant: ErrorBannerVariant.error,
          message: 'Error',
          actionLabel: 'Retry',
          onAction: () => tapped = true,
        ),
      );
      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });

    testWidgets('offline variant fires onDismiss callback', (tester) async {
      var dismissed = false;
      await tester.pumpApp(
        ErrorBanner(
          variant: ErrorBannerVariant.offline,
          message: 'Offline',
          onDismiss: () => dismissed = true,
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });
  });
}
