// ignore_for_file: directives_ordering

import 'package:pantas/app/build_info.dart';
import 'package:pantas/app/router_refresh_listenable.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:pantas/features/shell/presentation/update_required_page.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pantas/app/routes/home_routes.dart';
import 'package:pantas/app/routes/study_routes.dart';
import 'package:pantas/app/routes/quiz_routes.dart';
import 'package:pantas/app/routes/mock_routes.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/app/routes/onboarding_routes.dart';
import 'package:pantas/app/routes/wrapped_routes.dart';
import 'package:pantas/app/routes/states_routes.dart';
import 'package:pantas/app/routes/dev_routes.dart';

export 'package:pantas/app/routes/settings_routes.dart'
    show deleteAccountFromSettings;

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshListenable(ref, [
    passedAgeGateProvider,
    onboardingCompleteProvider,
    activeExamFocusProvider,
    entitlementProvider,
  ]);
  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      // The stop comes first: a build the server has retired must not
      // reach any route, including a deep link.
      final flags = ref.read(remoteFlagsProvider);
      final blocked = updateIsRequired(
        currentBuild: kBuildNumber,
        minimumSupportedBuild: flags.minimumSupportedBuild,
      );
      final atUpdateRequired = state.matchedLocation == '/update-required';
      if (blocked && !atUpdateRequired) return '/update-required';
      if (!blocked && atUpdateRequired) return '/home';

      final passedAsync = ref.read(passedAgeGateProvider);
      final focusAsync = ref.read(activeExamFocusProvider);
      final completeAsync = ref.read(onboardingCompleteProvider);
      final passed = passedAsync.valueOrNull;
      final focus = focusAsync.valueOrNull;
      final complete = completeAsync.valueOrNull;
      if (passed == null || focus == null || complete == null) return null;
      final atOnboarding = state.matchedLocation == '/onboarding' ||
          state.matchedLocation.startsWith('/onboarding/');
      if (passed && focus.needsSelection) {
        if (!atOnboarding) return '/onboarding';
        return null;
      }
      if (!passed && !atOnboarding) return '/onboarding';
      if (passed && !complete && !atOnboarding) return '/onboarding';
      if (passed && complete && atOnboarding) return '/home';
      return null;
    },
    routes: buildAppRoutes(ref),
  );
  ref.onDispose(router.dispose);
  return router;
});

List<RouteBase> buildAppRoutes(Ref ref) {
  final home = homeRoutes(ref);
  final study = studyRoutes(ref);
  final quiz = quizRoutes(ref);
  final settings = settingsRoutes(ref);
  return [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [home.first]),
        StatefulShellBranch(routes: [study.first]),
        StatefulShellBranch(routes: [quiz.first]),
        StatefulShellBranch(routes: [settings.first]),
      ],
    ),
    ...home.skip(1),
    ...study.skip(1),
    ...quiz.skip(1),
    ...mockRoutes(ref),
    ...settings.skip(1),
    ...onboardingRoutes(ref),
    ...wrappedRoutes(ref),
    ...statesRoutes(ref),
    ...devRoutes(),
  ];
}

class _FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Flattens the router's declared paths. Exists so a test can assert that
/// every Settings row has somewhere to land.
List<String> collectRoutePaths() {
  final paths = <String>[];
  void visit(List<RouteBase> routes) {
    for (final route in routes) {
      if (route is GoRoute) paths.add(route.path);
      visit(route.routes);
    }
  }

  visit(buildAppRoutes(_FakeRef()));
  return paths;
}
