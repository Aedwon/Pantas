// ignore_for_file: directives_ordering

import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/home/presentation/plan_screen.dart';
import 'package:pantas/features/home/presentation/record_screen.dart';
import 'package:pantas/features/home/presentation/tendencies_screen.dart';
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
      GoRoute(path: '/record', builder: (_, __) => const RecordScreen()),
      GoRoute(
        path: '/tendencies',
        builder: (_, __) => const TendenciesScreen(),
      ),
      GoRoute(path: '/plan', builder: (_, __) => const PlanScreen()),
      GoRoute(
        path: '/plan/day/:date',
        builder: (_, state) => PlanDayScreen(
          date: state.pathParameters['date']!,
          backLabel: state.extra is String ? state.extra! as String : 'Home',
        ),
      ),
      GoRoute(
        path: '/plan/week/:start',
        builder: (_, state) =>
            PlanWeekScreen(start: state.pathParameters['start']!),
      ),
    ];
