import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_card.dart';

/// YOUR PERFORMANCE on Home. No answers or no read means no card, with
/// nothing explaining why (D-110).
class HomePerformanceSection extends ConsumerWidget {
  const HomePerformanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view =
        ref.watch(performanceViewProvider).unwrapPrevious().asData?.value;
    if (view == null) return const SizedBox.shrink();
    final pro = ref.watch(currentStudyCoverageProvider);
    return HomePerformanceCard(
      rows: view.subjects,
      pro: pro,
      onOpen: () => unawaited(context.push('/performance')),
    );
  }
}
