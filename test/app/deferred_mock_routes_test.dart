import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/deferred_route.dart';
import 'package:pantas/app/routes/mock_routes_native.dart' as native;
import 'package:pantas/app/routes/mock_routes_web.dart' as web;
import 'package:pantas/core/ui/theme/app_theme.dart';
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

class _RouteRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
