import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/update_coordinator_provider.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

import '../../../helpers/pump_app.dart';
import 'update_coordinator_test.dart' show SafePoints;

void main() {
  for (final action in ['complete', 'navigate', 'restart']) {
    testWidgets('mock results completion respects $action before its callback',
        (tester) async {
      final safe = SafePoints();
      final updates = UpdateCoordinator(
        onFailure: (error, stack) => fail('$error'),
        onSafePoint: safe.call,
      )..routeChanged('/mock/run/one');
      addTearDown(updates.dispose);
      await tester.pumpAppWithProviders(
        Stack(
          children: [
            const MockResultsRoute(attemptId: 'one'),
            Builder(
              builder: (context) {
                if (action == 'navigate') {
                  updates.routeChanged('/quiz/inline/new');
                } else if (action == 'restart') {
                  updates.quizStarted();
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        overrides: [
          updateCoordinatorProvider.overrideWithValue(updates),
          mockResultsProvider('one').overrideWith((ref) async => null),
          mockReviewAccessProvider('one').overrideWith(
            (ref) => Completer<MockReviewAccess>().future,
          ),
          mockEarlierResultsProvider('one').overrideWith((ref) async => []),
          entitlementProvider.overrideWith(
            (ref) => const Stream<Entitlement>.empty(),
          ),
        ],
      );
      await updates.check();
      expect(safe.count, action == 'complete' ? isPositive : 0);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
