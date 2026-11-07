import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/routes/settings_routes_native.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/beta_feedback/presentation/exit_survey_page.dart';
import 'package:pantas/features/beta_feedback/presentation/feedback_page.dart';
import 'package:pantas/features/beta_feedback/presentation/sent_feedback_page.dart';
import 'package:pantas/features/paywall/application/beta_pro_provider.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/pump_app.dart';
import '../../settings/presentation/pro_page_payments_test.dart'
    show SettingsGateway;
import 'beta_feedback_fakes.dart';
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

  testWidgets('wide survey: back link with Esc, and Esc goes back',
      (tester) async {
    final h = FbHarness(wide: true, now: ph(11, 16, 9));
    await h.pump(
      tester,
      const ExitSurveyPage(frame: feedbackFrame),
      overrides: _shellOverrides(),
      routes: {
        '/settings/beta-feedback': (_) =>
            const Scaffold(body: Text('feedback page')),
      },
    );
    expect(find.text('Esc'), findsOneWidget);
    expect(find.text('Exit Survey'), findsOneWidget);
    expect(
      find.text('7 questions. You can send it once, until Nov 22.'),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('feedback page'), findsOneWidget);
  });

  testWidgets('wide survey: the sent state has no heading', (tester) async {
    final h = FbHarness(
      wide: true,
      now: ph(11, 16, 9),
      api: FakeBetaFeedbackApi(
        reward: fakeReward(
          days: betaDays.take(5).toList(),
          surveySubmitted: true,
        ),
      ),
    );
    await h.pump(
      tester,
      const ExitSurveyPage(frame: feedbackFrame),
      overrides: _shellOverrides(),
    );
    expect(find.text('Survey sent'), findsOneWidget);
    expect(find.text('Exit Survey'), findsNothing);
    expect(find.text('Feedback'), findsNWidgets(2));
  });

  testWidgets('phone: a sent item takes its date as the title', (tester) async {
    final h = FbHarness(
      api: FakeBetaFeedbackApi(
        sent: [fakeSent('a', 'Hello there', ph(11, 11, 21, 41))],
      ),
    );
    await h.pump(
      tester,
      const SentFeedbackPage(frame: feedbackFrame, id: 'a'),
      overrides: _shellOverrides(),
    );
    expect(find.text('Nov 11, 9:41 PM'), findsOneWidget);
    expect(find.text('Hello there'), findsOneWidget);
    expect(find.text('Feedback'), findsOneWidget);
  });
}
