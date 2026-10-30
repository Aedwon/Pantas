import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';

/// Which plan screen is loading.
enum PlanSkeletonKind { plan, day, week, history }

/// Phone Your plan: Today, Coming up, History.
class PlanSkeleton extends StatelessWidget {
  const PlanSkeleton({this.kind = PlanSkeletonKind.plan, super.key});
  final PlanSkeletonKind kind;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: switch (kind) {
            PlanSkeletonKind.plan || PlanSkeletonKind.history => const [
                SkeletonSection(height: 63),
                SizedBox(height: 24),
                SkeletonSection(height: 228, headerWidth: 120),
                SizedBox(height: 24),
                SkeletonSection(height: 270, headerWidth: 90),
              ],
            PlanSkeletonKind.day => const [
                SkeletonSection(height: 190, headerWidth: 90),
              ],
            PlanSkeletonKind.week => const [
                SkeletonSection(height: 450, headerWidth: 120),
              ],
          },
        ),
      );
}

/// Wide Your plan: Today and Coming up beside History (the 13 to 10 split).
class WebPlanLoading extends StatelessWidget {
  const WebPlanLoading({this.kind = PlanSkeletonKind.plan, super.key});
  final PlanSkeletonKind kind;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: switch (kind) {
          PlanSkeletonKind.plan => const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 13,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WebSkeletonEyebrow(width: 70),
                      SkeletonCard(height: 77),
                      SizedBox(height: 28),
                      WebSkeletonEyebrow(width: 110),
                      SkeletonCard(height: 430),
                    ],
                  ),
                ),
                SizedBox(width: 28),
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WebSkeletonEyebrow(width: 80),
                      SkeletonCard(height: 330),
                    ],
                  ),
                ),
              ],
            ),
          PlanSkeletonKind.history => Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: const SkeletonCard(height: 420),
              ),
            ),
          PlanSkeletonKind.day || PlanSkeletonKind.week => const SkeletonCard(
              height: 360,
            ),
        },
      );
}
