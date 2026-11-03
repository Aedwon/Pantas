import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

import '../../../helpers/pump_app.dart';

const _examId = 'exam_cse_sub';

Map<String, Object?> _reply(String status, {Object? next, String? exam}) => {
      'examId': exam ?? _examId,
      'serverNow': 2000,
      'nextEligibleAt': next,
      'status': status,
      'proCovered': false,
      if (status == 'available')
        'setup': {'questionCount': 170, 'expectedQuestionCount': 170},
    };

Future<void> _open(
  WidgetTester tester,
  Future<Object?> Function() reply,
) async {
  var starts = 0;
  final router = GoRouter(
    initialLocation: '/quiz',
    routes: [
      GoRoute(path: '/quiz', builder: (_, __) => const Text('Quiz tab')),
      GoRoute(
        path: '/quiz/mock/setup',
        builder: (_, __) => MockSetupRoute(
          examId: _examId,
          onStart: (_, {required strictMode}) => starts++,
        ),
      ),
    ],
  );
  await tester.pumpAppWithRouter(
    router,
    overrides: [
      mockUsesServerProvider.overrideWithValue(true),
      serverMockIdentityProvider.overrideWithValue('a'),
      serverMockActorProvider.overrideWithValue(() => 'a'),
      entitlementProvider
          .overrideWith((ref) => Stream.value(const Entitlement.free())),
      userSettingsProvider.overrideWith((_) async => UserSettings.defaults()),
      mockSetupParsedBlueprintProvider(_examId).overrideWith(
        (_) async => const ParsedMockBlueprint(
          blueprint: MockBlueprint(
            id: 'bp_1',
            examId: _examId,
            name: 'CSE Practice Paper',
            durationMinutes: 170,
            sectionsJson: '[]',
          ),
          sections: [],
        ),
      ),
      serverMockApiProvider
          .overrideWithValue(ServerMockApi((_, __) => reply())),
    ],
  );
  unawaited(router.push('/quiz/mock/setup'));
  await tester.pumpAndSettle();
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
}

void main() {
  testWidgets('cooldown shows when the next mock opens and no Start',
      (tester) async {
    await _open(tester, () async => _reply('cooldown', next: 2592002000));
    expect(find.text('Free includes one mock every 30 days.'), findsOneWidget);
    expect(find.textContaining('Your next one opens '), findsOneWidget);
    expect(find.text('Something went wrong.'), findsNothing);
    expect(find.text('Start the Mock Exam'), findsNothing);
    expect(find.byType(MockSetupPage), findsNothing);
  });

  testWidgets('cooldown offers a way back', (tester) async {
    await _open(tester, () async => _reply('cooldown', next: 2592002000));
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz tab'), findsOneWidget);
  });

  testWidgets('no blueprint shows the status card wording and no Start',
      (tester) async {
    await _open(tester, () async => _reply('no-blueprint'));
    expect(find.text('Mock paper not ready'), findsOneWidget);
    expect(find.text('Something went wrong.'), findsNothing);
    expect(find.text('Start the Mock Exam'), findsNothing);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets(
      'too few questions for the paper shows "Mock paper not ready", '
      'not an error with Try Again', (tester) async {
    await _open(
      tester,
      () async => throw const ServerMockException(
        code: 'failed-precondition',
        message: 'There are not enough questions for this mock yet.',
      ),
    );
    expect(find.text('Mock paper not ready'), findsOneWidget);
    expect(find.text('Something went wrong.'), findsNothing);
    expect(find.text('Try Again'), findsNothing);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('a cooldown reply with no date is still an error',
      (tester) async {
    await _open(tester, () async => _reply('cooldown'));
    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('a reply for another exam is still an error', (tester) async {
    await _open(
      tester,
      () async => _reply('cooldown', next: 2592002000, exam: 'other'),
    );
    expect(find.text('Something went wrong.'), findsOneWidget);
  });

  testWidgets('a network failure is still an error with Try Again',
      (tester) async {
    await _open(
      tester,
      () async => throw const ServerMockException(code: 'unavailable'),
    );
    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('an available mock still shows setup', (tester) async {
    await _open(tester, () async => _reply('available'));
    expect(find.byType(MockSetupPage), findsOneWidget);
  });
}
