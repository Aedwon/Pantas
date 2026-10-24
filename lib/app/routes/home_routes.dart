// ignore_for_file: directives_ordering

import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/home/presentation/performance_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> homeRoutes(Ref ref) => [
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeTab(),
      ),
      GoRoute(
        path: '/performance',
        builder: (_, __) => const PerformanceScreen(),
      ),
      GoRoute(
        path: '/performance/topic/:topicId',
        builder: (_, state) =>
            TopicScreen(topicId: state.pathParameters['topicId']!),
      ),
      GoRoute(path: '/progress', redirect: (_, __) => '/home'),
      GoRoute(path: '/plan/dossier/:mockId', redirect: (_, __) => '/home'),
      GoRoute(path: '/progress/how-you-work', redirect: (_, __) => '/home'),
      GoRoute(path: '/progress/your-record', redirect: (_, __) => '/home'),
    ];
