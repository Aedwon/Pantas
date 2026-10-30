import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';

/// The phone masthead: the week card, then the greeting line.
/// Heights match the loaded week card (59.5 strip + 16 padding) and the
/// 34pt greeting line.
class HomeMastheadSkeleton extends StatelessWidget {
  const HomeMastheadSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonCard(height: 75.5),
            SizedBox(height: 22),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBlock(width: 230, height: 38, radius: 10),
              ),
            ),
          ],
        ),
      );
}

/// The phone Today block: the heading row, then the list card.
class HomeTodaySkeleton extends StatelessWidget {
  const HomeTodaySkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SkeletonBlock(width: 60, height: 13),
                ),
              ),
            ),
            SkeletonSurface(height: 366.5),
          ],
        ),
      );
}

/// Your performance on phone: the heading, then the gauge and subject rows.
class HomePerformanceSkeleton extends StatelessWidget {
  const HomePerformanceSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonHeading(),
            SkeletonSurface(height: 412),
          ],
        ),
      );
}

/// Phone Home from top to bottom while the data loads. Wide web uses the
/// board layout instead.
class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return const HomeWebLayout(
        header: _WideHeader(),
        today: HomeWebLoading(more: true),
        performance: HomeWebLoading(performance: true),
      );
    }
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
      children: const [
        HomeMastheadSkeleton(),
        SizedBox(height: 22),
        HomeTodaySkeleton(),
        SizedBox(height: 22),
        HomePerformanceSkeleton(),
        SizedBox(height: 24),
        SkeletonPulse(child: SkeletonGroup(rows: 2)),
      ],
    );
  }
}

class _WideHeader extends StatelessWidget {
  const _WideHeader();
  double _line(TextStyle style) =>
      (style.fontSize ?? 14) * (style.height ?? 1.2);
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 20,
      runSpacing: 20,
      children: [
        SkeletonPulse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _line(t.sub),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: SkeletonBlock(width: 180, height: 13),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: _line(t.h1),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: SkeletonBlock(width: 300, height: 28, radius: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 480, child: HomeWebLoading(header: true)),
      ],
    );
  }
}
