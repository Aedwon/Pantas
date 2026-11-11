import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/deferred_route.dart';
import 'package:pantas/app/routes/mock_routes_native.dart' deferred as screens;
import 'package:pantas/features/mock_exam/application/mock_leave_guard.dart';

/// The pages that run a mock. Browser Back leaves them without a pop, so they
/// ask the running mock before they go (see [MockLeaveGuard]).
const _runningMockPaths = {
  '/quiz/mock/start',
  '/quiz/mock/resume/:attemptId',
};

List<RouteBase> mockRoutes(Ref ref) => [
      for (final path in const [
        '/quiz/mock/setup',
        '/quiz/mock/start',
        '/quiz/mock/resume/:attemptId',
        '/quiz/mock/custom-setup',
        '/mock/results/:attemptId',
        '/mock/review/:attemptId',
      ])
        GoRoute(
          path: path,
          builder: (context, state) => DeferredRoute(
            loadLibrary: screens.loadLibrary,
            builder: (context) => screens
                .mockRoutes(ref)
                .whereType<GoRoute>()
                .singleWhere((route) => route.path == path)
                .builder!(context, state),
          ),
          onExit: _runningMockPaths.contains(path)
              ? (context, state) =>
                  ref.read(mockLeaveGuardProvider).allowLeave()
              : null,
        ),
    ];
