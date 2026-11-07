import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/routes/settings_routes_native.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/beta_feedback/presentation/feedback_page.dart';
import 'package:pantas/features/paywall/application/beta_pro_provider.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/pump_app.dart';
import '../../settings/presentation/pro_page_payments_test.dart'
    show SettingsGateway;
import 'feedback_harness.dart';

List<Override> _shellOverrides() => [
      currentUserProvider.overrideWith((ref) async => null),
      isAnonymousProvider.overrideWith((ref) async => false),
      userSettingsProvider.overrideWith((ref) async => UserSettings.defaults()),
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(buildExam(id: 'e')),
      ),
      syncStatusProvider.overrideWith((ref) => Stream.value(const SyncOff())),
      revenueCatGatewayProvider.overrideWithValue(
        SettingsGateway(initial: const Entitlement.free()),
      ),
      proForActiveExamProvider.overrideWith((ref) async => false),
      betaProProvider.overrideWith((ref) => Stream.value(null)),
    ];

void main() {
  testWidgets('phone: Settings back link, title with BETA, no wide list',
      (tester) async {
    final h = FbHarness();
    await h.pump(
      tester,
      const FeedbackPage(frame: feedbackFrame),
      overrides: _shellOverrides(),
    );
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Feedback'), findsOneWidget);
    expect(find.text('BETA'), findsOneWidget);
    expect(find.text('3 of 5 days'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide: the pane keeps the list, selects Feedback and has no Esc',
      (tester) async {
    final h = FbHarness(wide: true);
    await h.pump(
      tester,
      const FeedbackPage(frame: feedbackFrame),
      overrides: _shellOverrides(),
    );
    // The list row and the page heading both read Feedback with BETA.
    expect(find.text('Feedback'), findsNWidgets(2));
    expect(find.text('BETA'), findsNWidgets(2));
    final row = tester
        .widgetList<WebRow>(find.byType(WebRow))
        .firstWhere((r) => r.title == 'Feedback');
    expect(row.selected, isTrue);
    expect(find.text('Esc'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
