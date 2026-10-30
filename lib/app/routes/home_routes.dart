// ignore_for_file: directives_ordering

import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/home/presentation/plan_screen.dart';
import 'package:pantas/features/home/presentation/record_screen.dart';
import 'package:pantas/features/home/presentation/tendencies_screen.dart';
import 'package:pantas/features/home/presentation/performance_screen.dart';
import 'package:flutter/material.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
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
        path: '/plan/history',
        builder: (_, __) => const PlanHistoryScreen(),
      ),
      GoRoute(
        path: '/plan/day/:date',
        builder: (_, state) => PlanDayScreen(
          date: state.pathParameters['date']!,
          onReadEarly: _openPlanLesson,
          backLabel: state.extra is String ? state.extra! as String : 'Home',
        ),
      ),
      GoRoute(
        path: '/plan/week/:start',
        builder: (_, state) =>
            PlanWeekScreen(start: state.pathParameters['start']!),
      ),
    ];

Future<void> _openPlanLesson(
  BuildContext context,
  String lessonId,
  String label,
  LessonDayContext dayContext,
) =>
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close lesson',
      barrierColor: Colors.black.withValues(alpha: .28),
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 620,
          height: double.infinity,
          child: LessonPage(
            lessonId: lessonId,
            origin: ReaderOrigin.home,
            dayContext: dayContext,
            planLabel: label,
            onPlanClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      ),
    );
