import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';

/// Phone Your record: the three always-present sections of the loaded page.
class RecordSkeleton extends StatelessWidget {
  const RecordSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonSection(height: 125),
            SizedBox(height: 24),
            SkeletonSection(height: 306),
            SizedBox(height: 24),
            SkeletonSection(height: 230),
          ],
        ),
      );
}

/// Phone Your tendencies: the profile card, then the findings.
class TendenciesSkeleton extends StatelessWidget {
  const TendenciesSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonSurface(height: 150),
            SizedBox(height: 24),
            SkeletonSection(height: 400),
          ],
        ),
      );
}

/// Phone Your performance: gauge, level switch, then the subject rows.
class PerformanceSkeleton extends StatelessWidget {
  const PerformanceSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBlock(height: 130, radius: 14),
            SizedBox(height: 20),
            SkeletonBlock(height: 32, radius: 9),
            SizedBox(height: 16),
            SkeletonSection(height: 360, headerWidth: 90),
          ],
        ),
      );
}

/// Wide Your record: the left column of figures and the mocks column.
class WebRecordLoading extends StatelessWidget {
  const WebRecordLoading({super.key});
  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const left = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WebSkeletonEyebrow(),
                SkeletonCard(height: 100),
                SizedBox(height: 28),
                WebSkeletonEyebrow(width: 110),
                _TotalsGrid(),
                SizedBox(height: 28),
                WebSkeletonEyebrow(width: 190),
                SkeletonCard(height: 236),
              ],
            );
            const right = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WebSkeletonEyebrow(width: 100),
                SkeletonCard(height: 224),
              ],
            );
            if (constraints.maxWidth < 868) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [left, SizedBox(height: 28), right],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 520 + (constraints.maxWidth - 868) * 1.6 / 2.6,
                  child: left,
                ),
                const SizedBox(width: 28),
                const Expanded(child: right),
              ],
            );
          },
        ),
      );
}

class _TotalsGrid extends StatelessWidget {
  const _TotalsGrid();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < 6; i++)
              SkeletonCard(
                width: (constraints.maxWidth - 24) / 3,
                height: 76,
              ),
          ],
        ),
      );
}

/// L_ProgressSlow: Your tendencies. A profile card, then two rows of findings.
class WebTendenciesLoading extends StatelessWidget {
  const WebTendenciesLoading({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonCard(height: 112),
            SizedBox(height: 26),
            WebSkeletonEyebrow(),
            Row(
              children: [
                Expanded(child: SkeletonCard(height: 180)),
                SizedBox(width: 14),
                Expanded(child: SkeletonCard(height: 180)),
              ],
            ),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: SkeletonCard(height: 180)),
                SizedBox(width: 14),
                Expanded(child: SkeletonCard(height: 180)),
              ],
            ),
          ],
        ),
      );
}

/// Wide Your performance: the level switch and table, then the Overall gauge.
class WebPerformanceLoading extends StatelessWidget {
  const WebPerformanceLoading({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 145,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SkeletonBlock(height: 36, radius: 10),
                  SizedBox(height: 16),
                  WebSkeletonEyebrow(width: 90),
                  SkeletonCard(height: 360),
                ],
              ),
            ),
            SizedBox(width: 28),
            Expanded(
              flex: 100,
              child: Padding(
                padding: EdgeInsets.only(top: 54),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WebSkeletonEyebrow(width: 70),
                    SkeletonCard(height: 190),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
