import 'package:cse_cet_reviewer/core/platform/remote_flags.dart';
import 'package:cse_cet_reviewer/core/platform/remote_flags_providers.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/shell/presentation/update_required_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  /// The router as the app builds it, cut down to the routes this test
  /// needs: the gate is a redirect, so it must be exercised through one.
  GoRouter buildRouter({
    required int currentBuild,
    required int minimumSupportedBuild,
    String initialLocation = '/home',
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) {
        final blocked = updateIsRequired(
          currentBuild: currentBuild,
          minimumSupportedBuild: minimumSupportedBuild,
        );
        if (blocked && state.matchedLocation != '/update-required') {
          return '/update-required';
        }
        if (!blocked && state.matchedLocation == '/update-required') {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/quiz/today/:examId',
          builder: (_, __) => const Scaffold(body: Text('quiz')),
        ),
        GoRoute(
          path: '/update-required',
          builder: (_, __) => const UpdateRequiredPage(),
        ),
      ],
    );
  }

  Widget harness(GoRouter router) {
    return ProviderScope(
      overrides: [
        remoteFlagsProvider.overrideWithValue(RemoteFlags.fallback),
      ],
      child: MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
      ),
    );
  }

  testWidgets('a build above the minimum reaches Home normally',
      (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 12, minimumSupportedBuild: 10)),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a build at the minimum is not blocked', (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 10, minimumSupportedBuild: 10)),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a build below the minimum is stopped', (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 9, minimumSupportedBuild: 10)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Pantas needs an update to keep working.'),
      findsOneWidget,
    );
    expect(find.text('home'), findsNothing);
  });

  testWidgets('a deep link is stopped too', (tester) async {
    await tester.pumpWidget(
      harness(
        buildRouter(
          currentBuild: 9,
          minimumSupportedBuild: 10,
          initialLocation: '/quiz/today/exam_upcat',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('quiz'), findsNothing);
    expect(
      find.text('Pantas needs an update to keep working.'),
      findsOneWidget,
    );
  });

  testWidgets('the gate does not fire when no minimum is published',
      (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 1, minimumSupportedBuild: 0)),
    );
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('the page cannot be dismissed and says nothing extra',
      (tester) async {
    await tester.pumpWidget(
      harness(buildRouter(currentBuild: 9, minimumSupportedBuild: 10)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BoardButton), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);

    // No version numbers, no changelog, no apology, no dismiss.
    expect(find.textContaining('version'), findsNothing);
    expect(find.textContaining('Sorry'), findsNothing);
    expect(find.textContaining('Later'), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });
}
