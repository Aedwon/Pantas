import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/deferred_route.dart';
import 'package:pantas/app/routes/mock_routes_native.dart' as native;
import 'package:pantas/app/routes/mock_routes_web.dart' as web;
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_leave_guard.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_review_providers.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_review_page.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';

void main() {
  test('web declares the same paths as native', () {
    final ref = _RouteRef();
    expect(
      web.mockRoutes(ref).cast<GoRoute>().map((route) => route.path),
      native.mockRoutes(ref).cast<GoRoute>().map((route) => route.path),
    );
  });

  testWidgets('web mock run pages ask the running mock before browser Back',
      (tester) async {
    final routesProvider = Provider(web.mockRoutes);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final routes = container.read(routesProvider).cast<GoRoute>();
    final guarded = {
      for (final route in routes)
        if (route.onExit != null) route.path,
    };
    expect(guarded, {'/quiz/mock/start', '/quiz/mock/resume/:attemptId'});
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );
    final start = routes.singleWhere((r) => r.path == '/quiz/mock/start');
    final state = _FakeState();
    // Nothing running: leaving is allowed.
    expect(await start.onExit!(context, state), isTrue);
    // A running mock that refuses: leaving is stopped.
    final guard = container.read(mockLeaveGuardProvider);
    Future<bool> refuse() async => false;
    guard.running = refuse;
    expect(await start.onExit!(context, state), isFalse);
    guard.detach(refuse);
    expect(await start.onExit!(context, state), isTrue);
  });

  testWidgets('web review deep link loads the review page', (tester) async {
    final routesProvider = Provider(web.mockRoutes);
    final container = ProviderContainer(
      overrides: [
        mockReviewAccessProvider.overrideWith(
          (ref, id) async => const MockReviewAccess(
            canReview: true,
            proCovered: true,
          ),
        ),
        mockReviewProvider.overrideWith((ref, id) async => const []),
        mockMarkedQuestionIdsProvider.overrideWith((ref, id) async => const {}),
        mockOfferHandledProvider.overrideWith((ref, id) async => true),
        proForActiveExamProvider.overrideWith((ref) async => false),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/mock/review/old-attempt',
      routes: container.read(routesProvider),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child:
            MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DeferredRoute), findsOneWidget);
    expect(find.byType(MockReviewPage), findsOneWidget);
  });
}

class _FakeState implements GoRouterState {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RouteRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
