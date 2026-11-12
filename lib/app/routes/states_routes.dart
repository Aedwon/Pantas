import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
// ignore_for_file: directives_ordering

import 'package:pantas/features/shell/presentation/update_required_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> statesRoutes(Ref ref) => [
      GoRoute(
        path: '/startup',
        builder: (_, __) => Consumer(
          builder: (context, ref, _) {
            final gate = ref.watch(guardianGateProvider);
            return Scaffold(
              body: gate.hasError
                  ? StateView.fullScreen(
                      onRetry: () => ref.invalidate(guardianGateProvider),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(PantasSpace.s24),
                      child: loadingFor(const AsyncLoading<void>()),
                    ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/update-required',
        builder: (_, __) => const FirstScreenReady(child: UpdateRequiredPage()),
      ),
    ];
