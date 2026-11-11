// ignore_for_file: directives_ordering

import 'package:flutter/foundation.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import 'package:pantas/app/build_info.dart';
import 'package:pantas/app/start_location.dart';
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
import 'package:pantas/features/onboarding/application/onboarding_browser_back.dart';
import 'package:pantas/app/routes/guardian_routes.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/app/routes/wrapped_routes.dart';
import 'package:pantas/app/routes/states_routes.dart';
import 'package:pantas/app/routes/dev_routes.dart';

export 'package:pantas/app/routes/settings_routes.dart'
    show deleteAccountFromSettings;

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshListenable(ref, [
    passedAgeGateProvider,
    onboardingCompleteProvider,
    studyNeedsExamSettingsProvider,
    activeExamFocusProvider,
    entitlementProvider,
    guardianGateProvider,
    guardianAccountClosedProvider,
    betaGateActiveProvider,
    betaGateStatusProvider,
  ]);
  // Every page's address shows, so a reload stays on it. The address of a page
  // that needs in-memory arguments is handled by `startLocationFor`.
  GoRouter.optionURLReflectsImperativeAPIs = kIsWeb;
  final router = GoRouter(
    initialLocation: takeInitialRouterLocation(),
    refreshListenable: refreshListenable,
    // Every address is honored on the web, so one that matches no page
    // (a typo, a retired link) lands on Home, not go_router's error page.
    onException: (context, state, router) => router.go('/home'),
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

      // The guardian's links work signed out and before onboarding, and the
      // legal pages they link to must open for them too. The manage link also
      // opens on a device held on Waiting, since a guardian may open it there.
      final path = state.matchedLocation;
      if (path == '/guardian' ||
          path == '/guardian/manage' ||
          path.startsWith('/legal/') ||
          path == '/auth/email-link') {
        return null;
      }
      final guardianState = ref.read(guardianGateProvider);
      if (!guardianState.hasValue) {
        return path == '/startup'
            ? null
            : Uri(
                path: '/startup',
                queryParameters: {'from': state.uri.toString()},
              ).toString();
      }
      final guardian = guardianState.requireValue;
      if (ref.read(guardianAccountClosedProvider) != null ||
          guardian == GuardianGate.withdrawn) {
        return path == '/guardian/withdrawn' ? null : '/guardian/withdrawn';
      }
      if (path == '/startup') {
        final from = state.uri.queryParameters['from'];
        return from != null &&
                from.startsWith('/') &&
                !from.startsWith('//') &&
                Uri.parse(from).path != '/startup'
            ? from
            : '/home';
      }
      final betaActive = ref.read(betaGateActiveProvider);
      final betaRedirect = betaGateRedirect(
        path: path,
        active: betaActive,
        access: ref.read(betaGateStatusProvider),
        now: ref.read(betaClockProvider)(),
      );
      if (betaRedirect != null) return betaRedirect;
      if (path == '/beta') return null;
      if (guardian == GuardianGate.waiting) {
        // A minor is held on Waiting, or on the form to change the email,
        // until a guardian confirms. Nothing else is reachable.
        return path == '/guardian/waiting' ||
                path == '/guardian/contact' ||
                path.startsWith('/legal/')
            ? null
            : '/guardian/waiting';
      }
      if (path.startsWith('/guardian/')) {
        return guardian == GuardianGate.needsContact ? '/onboarding' : '/home';
      }
      // The legal pages open at any point in onboarding, for anyone. Going
      // back returns to the step that linked to them.
      if (path.startsWith('/legal/')) return null;

      final passedAsync = ref.read(passedAgeGateProvider);
      final focusAsync = ref.read(activeExamFocusProvider);
      final completeAsync = ref.read(onboardingCompleteProvider);
      final passed = passedAsync.valueOrNull;
      final focus = focusAsync.valueOrNull;
      final complete = completeAsync.valueOrNull;
      if (passed == null || focus == null || complete == null) return null;
      final atOnboarding = state.matchedLocation == '/onboarding' ||
          state.matchedLocation.startsWith('/onboarding/');
      // An address outside onboarding that arrives while onboarding is open is
      // the browser's Back or Forward: every step shares one address. The open
      // page goes back a step, and the student stays in onboarding.
      String toOnboarding() {
        ref.read(onboardingBrowserBackProvider).requested();
        return '/onboarding';
      }

      if (ref.read(studyNeedsExamSettingsProvider)) {
        return atOnboarding ? null : toOnboarding();
      }
      if (passed && focus.needsSelection) {
        if (!atOnboarding) return toOnboarding();
        return null;
      }
      if (!passed && !atOnboarding) return toOnboarding();
      if (passed && !complete && !atOnboarding) return toOnboarding();
      if (passed && complete && atOnboarding) return '/home';
      return null;
    },
    routes: buildAppRoutes(ref),
  );
  ref.onDispose(router.dispose);
  return router;
});

List<RouteBase> buildAppRoutes(
  Ref ref, {
  bool includeDebugGallery = true,
  bool web = kIsWeb,
}) {
  final home = homeRoutes(ref);
  final study = studyRoutes(ref, web: web);
  final quiz = quizRoutes(ref);
  final settings = settingsRoutes(ref);
  final homeRoot = _tabRoot(home, '/home');
  final homeSubpages = home.where((route) => route != homeRoot).toList();
  final studyRoot = _tabRoot(study, '/study');
  final quizRoot = _tabRoot(quiz, '/quiz');
  final settingsRoot = _tabRoot(settings, '/settings');
  final routes = <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        // Plan, Day, Week, history, Performance, topic, Record and Tendencies
        // are Home pages on the phone boards: they keep the floating tab bar
        // with Home lit, and back returns within this branch.
        StatefulShellBranch(routes: [homeRoot, ...homeSubpages]),
        StatefulShellBranch(routes: [studyRoot]),
        StatefulShellBranch(routes: [quizRoot]),
        StatefulShellBranch(routes: [settingsRoot]),
      ],
    ),
    ...study.where((route) => route != studyRoot),
    ...quiz.where((route) => route != quizRoot),
    ...mockRoutes(ref),
    ...settings.where((route) => route != settingsRoot),
    ...onboardingRoutes(ref),
    GoRoute(path: '/beta', builder: (context, state) => const BetaGatePage()),
    GoRoute(
      path: '/auth/email-link',
      builder: (context, state) => const EmailSignInPage(),
    ),
    ...guardianRoutes(ref),
    ...wrappedRoutes(ref),
    ...statesRoutes(ref),
    ...devRoutes(includeDebugGallery: includeDebugGallery),
  ];
  if (!web) return routes;
  // A lesson sits above the web shell, not inside it. Inside, it could only
  // cover the page beside the sidebar, so the shell had to drop the sidebar
  // the moment a lesson opened and the page behind jumped wider. Above it, the
  // lesson covers the whole window and the page and sidebar underneath stay
  // exactly as they were. Native builds already work this way.
  final lesson = routes
      .whereType<GoRoute>()
      .singleWhere((route) => route.path == '/lesson/:lessonId');
  // A page pushed over a lesson must sit above the shell too. Pushed from up
  // here, a page inside the shell asks for a second shell with the same
  // navigator: the one in use moves under the lesson and the new page is blank.
  final aboveLesson = routes
      .whereType<GoRoute>()
      .where((route) => webRoutesAboveLesson.contains(route.path))
      .toList();
  return [
    ShellRoute(
      builder: (context, state, child) =>
          WebRouteShell(path: state.uri.path, child: child),
      routes: routes
          .where((route) => route != lesson && !aboveLesson.contains(route))
          .toList(),
    ),
    lesson,
    for (final route in aboveLesson) _inWebRouteShell(route),
  ];
}

/// The quiz a lesson opens, and the pages its end screen pushes.
@visibleForTesting
const webRoutesAboveLesson = {
  '/quiz/inline/:examId/:lessonId',
  '/quiz/viewer/:attemptId',
  '/quiz/all/:attemptId',
  '/quiz/debrief/:attemptId',
};

GoRoute _inWebRouteShell(GoRoute route) => GoRoute(
      path: route.path,
      onExit: route.onExit,
      builder: (context, state) => WebRouteShell(
        path: state.uri.path,
        child: route.builder!(context, state),
      ),
    );

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
