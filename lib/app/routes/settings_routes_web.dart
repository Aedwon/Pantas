import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/deferred_route.dart';
import 'package:pantas/app/routes/settings_routes_native.dart'
    deferred as screens;
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/ui/motion/pane_transition.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';

export 'settings_account_deletion.dart';

List<RouteBase> settingsRoutes(Ref ref) => [
      GoRoute(
        path: '/pro',
        redirect: (_, state) =>
            state.uri.replace(path: '/settings/pro').toString(),
      ),
      for (final path in const [
        '/settings',
        '/settings/practice',
        '/settings/appearance',
        '/settings/accessibility',
        '/settings/exam',
        '/settings/exam/change',
        '/settings/exam/upgrade',
        '/settings/exam/transfer',
        '/settings/exam/included',
        '/settings/account',
        '/settings/account/adult-check',
        '/settings/account/name',
        '/settings/account/delete',
        '/settings/pro',
        '/settings/beta-feedback',
        '/settings/beta-feedback/survey',
        '/settings/beta-feedback/sent/:id',
        '/settings/backup',
        '/settings/about',
        '/settings/_debug',
        '/legal/:doc',
      ])
        GoRoute(
          path: path,
          redirect: path == '/settings/exam/transfer'
              ? (_, state) => carryOverRequestFor(state.extra) == null
                  ? '/settings/exam'
                  : null
              : null,
          // The tab root stays an ordinary route. Every other Settings page
          // and the legal pages open without a page-level slide, see
          // [PaneTransitionPage].
          builder: path == '/settings'
              ? (context, state) => _screen(ref, path, state)
              : null,
          pageBuilder: path == '/settings'
              ? null
              : (context, state) => PaneTransitionPage<void>(
                    key: state.pageKey,
                    transition: path.startsWith('/legal/')
                        ? (context) => _legalTransition(ref, context)
                        : _modalPages.contains(path)
                            ? _modalTransition
                            : _settingsTransition,
                    child: _screen(ref, path, state),
                  ),
        ),
    ];

/// Settings pages on wide web keep the list and heading still and move only
/// the detail (item 15). Everywhere else the platform's transition stays.
PaneTransition _settingsTransition(BuildContext context) =>
    context.wideWeb ? PaneTransition.detail : PaneTransition.platform;

/// These open as a dialog over a copy of the page behind on wide web. The
/// dialog has its own entrance and exit, so the route must add nothing: a fade
/// of its own would replay the page behind after the dialog has gone.
const _modalPages = {
  '/settings/exam/change',
  '/settings/exam/transfer',
  '/settings/account/delete',
};

PaneTransition _modalTransition(BuildContext context) =>
    context.wideWeb ? PaneTransition.instant : PaneTransition.platform;

/// Legal pages (items 1 and 15). On wide web, opened during onboarding or
/// from the guardian page, the page fades in with its logo and frame still.
/// Opened from Settings it is a Settings detail and behaves as one. On a phone
/// and on a portrait tablet it keeps the platform's transition.
PaneTransition _legalTransition(Ref ref, BuildContext context) {
  if (!context.wideWeb) return PaneTransition.platform;
  return ref.read(legalInOnboardingProvider)
      ? PaneTransition.fade
      : PaneTransition.detail;
}

const _dataScreens = {
  '/settings/pro',
  '/settings/exam/upgrade',
  '/settings/exam/change',
  '/settings/exam/included',
};

Widget _screen(Ref ref, String path, GoRouterState state) => DeferredRoute(
      cacheKey: 'settings-screens',
      loadLibrary: screens.loadLibrary,
      builder: (context) => Consumer(
        builder: (context, localRef, _) {
          final child = screens
              .settingsRoutes(ref)
              .whereType<GoRoute>()
              .singleWhere((route) => route.path == path)
              .builder!(context, state);
          if (_dataScreens.contains(path)) return child;
          return FirstScreenReady(
            ready: !localRef.watch(userSettingsProvider).isLoading &&
                !localRef.watch(themePreferenceProvider).isLoading,
            child: child,
          );
        },
      ),
    );
