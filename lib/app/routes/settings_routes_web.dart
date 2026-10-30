import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/deferred_route.dart';
import 'package:pantas/app/routes/settings_routes_native.dart'
    deferred as screens;
import 'package:pantas/core/platform/first_screen_ready.dart';
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
        '/settings/exam',
        '/settings/exam/change',
        '/settings/exam/upgrade',
        '/settings/exam/transfer',
        '/settings/exam/included',
        '/settings/account',
        '/settings/account/name',
        '/settings/account/delete',
        '/settings/pro',
        '/settings/backup',
        '/settings/about',
        '/settings/_debug',
        '/legal/:doc',
      ])
        GoRoute(
          path: path,
          redirect: path == '/settings/exam/transfer'
              ? (_, state) =>
                  state.extra is CarryOverRequest ? null : '/settings/exam'
              : null,
          builder: (context, state) => DeferredRoute(
            loadLibrary: screens.loadLibrary,
            builder: (context) => Consumer(
              builder: (context, localRef, _) {
                final child = screens
                    .settingsRoutes(ref)
                    .whereType<GoRoute>()
                    .singleWhere((route) => route.path == path)
                    .builder!(context, state);
                const dataScreens = {
                  '/settings/pro',
                  '/settings/exam/upgrade',
                  '/settings/exam/change',
                  '/settings/exam/included',
                };
                if (dataScreens.contains(path)) return child;
                return FirstScreenReady(
                  ready: !localRef.watch(userSettingsProvider).isLoading &&
                      !localRef.watch(themePreferenceProvider).isLoading,
                  child: child,
                );
              },
            ),
          ),
        ),
    ];
