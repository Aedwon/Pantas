// ignore_for_file: directives_ordering

import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/home/presentation/plan_screen.dart';
import 'package:pantas/features/home/presentation/record_screen.dart';
import 'package:pantas/features/home/presentation/tendencies_screen.dart';
import 'package:pantas/features/home/presentation/performance_screen.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pane_transition.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
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
        pageBuilder: (_, state) => PaneTransitionPage<void>(
          key: state.pageKey,
          transition: _planPaneTransition,
          child: PlanDayScreen(
            date: state.pathParameters['date']!,
            onReadEarly: openPlanLesson,
            backLabel: state.extra is String ? state.extra! as String : 'Home',
          ),
        ),
      ),
      GoRoute(
        path: '/plan/week/:start',
        pageBuilder: (_, state) => PaneTransitionPage<void>(
          key: state.pageKey,
          transition: _planPaneTransition,
          child: PlanWeekScreen(start: state.pathParameters['start']!),
        ),
      ),
    ];

/// On wide web a day or week opens in a pane beside the plan, which stays still
/// (the Settings pane motion). A phone keeps the platform's transition.
PaneTransition _planPaneTransition(BuildContext context) =>
    context.wideWeb ? PaneTransition.instant : PaneTransition.platform;

/// Opens a lesson from a plan day as a drawer over the page (wide web).
Future<void> openPlanLesson(
  BuildContext context,
  String lessonId,
  String label,
  LessonDayContext dayContext,
) =>
    showWebOverlay<void>(
      context: context,
      motion: WebOverlayMotion.lesson,
      barrierLabel: 'Close lesson',
      barrierColor: Colors.black.withValues(alpha: .28),
      builder: (dialogContext) => Align(
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
