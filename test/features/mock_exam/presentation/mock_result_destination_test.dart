import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/mock_routes.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

void main() {
  testWidgets('result destination keeps only fresh submission extra',
      (tester) async {
    final routesProvider = Provider(mockRoutes);
    final container = ProviderContainer(
      overrides: [
        mockResultsProvider.overrideWith((ref, id) async => null),
        mockReviewAccessProvider.overrideWith(
          (ref, id) async => const MockReviewAccess(canReview: false),
        ),
        mockEarlierResultsProvider.overrideWith((ref, id) async => []),
        proForActiveExamProvider.overrideWith((ref) async => false),
        entitlementProvider
            .overrideWith((ref) => Stream.value(const Entitlement.free())),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/mock/results/a',
      routes: container.read(routesProvider),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    final input = MockFinaleInput(
      reason: MockSubmitReason.timeUp,
      currentPartIndex: 0,
      currentQuestionIndex: 0,
      parts: const [],
    );
    router.go('/mock/results/a?fresh=1&endedPart=3', extra: input);
    await tester.pumpAndSettle();
    var route = tester.widget<MockResultsRoute>(find.byType(MockResultsRoute));
    expect(route.fresh, isTrue);
    expect(route.endedPart, 3);
    expect(identical(route.finaleInput, input), isTrue);
    router.go('/mock/results/a?endedPart=-2', extra: input);
    await tester.pumpAndSettle();
    route = tester.widget<MockResultsRoute>(find.byType(MockResultsRoute));
    expect(route.fresh, isFalse);
    expect(route.endedPart, isNull);
    expect(route.finaleInput, isNull);
  });
}
