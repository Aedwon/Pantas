// ignore_for_file: directives_ordering

import 'package:flutter/foundation.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

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
      if (context.wideWeb && state.uri.path.startsWith('/wrapped/')) {
        return '/record';
      }

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

List<RouteBase> buildAppRoutes(Ref ref, {bool includeDebugGallery = true}) {
  final home = homeRoutes(ref);
  final study = studyRoutes(ref);
  final quiz = quizRoutes(ref);
  final settings = settingsRoutes(ref);
  final homeRoot = _tabRoot(home, '/home');
  final studyRoot = _tabRoot(study, '/study');
  final quizRoot = _tabRoot(quiz, '/quiz');
  final settingsRoot = _tabRoot(settings, '/settings');
  final routes = <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [homeRoot]),
        StatefulShellBranch(routes: [studyRoot]),
        StatefulShellBranch(routes: [quizRoot]),
        StatefulShellBranch(routes: [settingsRoot]),
      ],
    ),
    ...home.where((route) => route != homeRoot),
    ...study.where((route) => route != studyRoot),
    ...quiz.where((route) => route != quizRoot),
    ...mockRoutes(ref),
    ...settings.where((route) => route != settingsRoot),
    ...onboardingRoutes(ref),
    ...wrappedRoutes(ref),
    ...statesRoutes(ref),
    ...devRoutes(includeDebugGallery: includeDebugGallery),
  ];
  if (!kIsWeb) return routes;
  return [
    ShellRoute(
      builder: (context, state, child) =>
          WebRouteShell(path: state.uri.path, child: child),
      routes: routes,
    ),
  ];
}

GoRoute _tabRoot(List<RouteBase> routes, String path) =>
    routes.whereType<GoRoute>().singleWhere((route) => route.path == path);

class _FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Flattens the router's declared paths. Exists so a test can assert that
/// every Settings row has somewhere to land.
List<String> collectRoutePaths({bool includeDebugGallery = true}) {
  final paths = <String>[];
  void visit(List<RouteBase> routes) {
    for (final route in routes) {
      if (route is GoRoute) paths.add(route.path);
      visit(route.routes);
    }
  }

  visit(buildAppRoutes(_FakeRef(), includeDebugGallery: includeDebugGallery));
  return paths;
}
