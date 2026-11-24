import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/home/presentation/widgets/home_columns.dart';

/// Phone Your record: the three always-present sections of the loaded page.
class RecordSkeleton extends StatelessWidget {
  const RecordSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonSection(height: 125),
            SizedBox(height: PantasSpace.s24),
            SkeletonSection(height: 238),
            SizedBox(height: PantasSpace.s24),
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
            SizedBox(height: PantasSpace.s24),
            SkeletonSection(height: 400),
          ],
        ),
      );
}

/// Phone Your performance (PF_Subjects): the ring, the Subjects switch with
/// its sort square, then four subject rows.
class PerformanceSkeleton extends StatelessWidget {
  const PerformanceSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBlock(height: 144, radius: 14),
            SizedBox(height: PantasSpace.s16),
            Row(
              children: [
                Expanded(child: SkeletonBlock(height: 48, radius: 9)),
                SizedBox(width: PantasSpace.s8),
                SkeletonBlock(height: 36, width: 36, radius: 9),
              ],
            ),
            SizedBox(height: PantasSpace.s28),
            SkeletonGroup(rows: 4, rowHeight: 78, headerWidth: 90),
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
                SizedBox(height: PantasSpace.s28),
                WebSkeletonEyebrow(width: 110),
                _TotalsGrid(),
                SizedBox(height: PantasSpace.s28),
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
            if (HomeColumns.stacks(constraints.maxWidth)) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [left, SizedBox(height: PantasSpace.s28), right],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: HomeColumns.primaryWidth(constraints.maxWidth),
                  child: left,
                ),
                const SizedBox(width: PantasSpace.s28),
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
            SizedBox(height: PantasSpace.s24),
            WebSkeletonEyebrow(),
            Row(
              children: [
                Expanded(child: SkeletonCard(height: 180)),
                SizedBox(width: PantasSpace.s14),
                Expanded(child: SkeletonCard(height: 180)),
              ],
            ),
            SizedBox(height: PantasSpace.s14),
            Row(
              children: [
                Expanded(child: SkeletonCard(height: 180)),
                SizedBox(width: PantasSpace.s14),
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
                  SizedBox(height: PantasSpace.s16),
                  WebSkeletonEyebrow(width: 90),
                  SkeletonCard(height: 240),
                ],
              ),
            ),
            SizedBox(width: PantasSpace.s28),
            Expanded(
              flex: 100,
              child: Padding(
                padding: EdgeInsets.only(top: PantasSpace.s56),
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
