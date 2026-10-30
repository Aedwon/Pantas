import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_card.dart';
import 'package:pantas/features/home/presentation/widgets/home_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';

/// YOUR PERFORMANCE on Home. No answers or no read means no card, with
/// nothing explaining why (D-110).
class HomePerformanceSection extends ConsumerWidget {
  const HomePerformanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(performanceViewProvider);
    if (state.hasError) {
      return errorFor(
        'performance',
        () => ref.invalidate(performanceViewProvider),
        boardLayout: true,
      );
    }
    final view = state.unwrapPrevious().asData?.value;
    if (view == null) {
      return context.wideWeb
          ? const HomeWebLoading(performance: true)
          : const HomePerformanceSkeleton();
    }
    final pro = ref.watch(currentStudyCoverageProvider);
    return HomePerformanceCard(
      rows: view.subjects,
      overallCorrect: view.overallCorrect,
      overallAnswered: view.overallAnswered,
      pro: pro,
      onOpen: () => unawaited(context.push('/performance')),
    );
  }
}
