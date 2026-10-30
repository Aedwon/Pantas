import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// Rows inside the Today group (Reviews, New questions) while the counts load.
class QuizTodayRowsSkeleton extends StatelessWidget {
  const QuizTodayRowsSkeleton({this.wide = false, super.key});
  final bool wide;
  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: Column(
          children: [
            for (var i = 0; i < 2; i++)
              SizedBox(
                height: wide ? 66 : 63.5,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: wide ? 20 : 16),
                  child: Row(
                    children: [
                      const SkeletonBlock(width: 30, height: 30, radius: 15),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SkeletonBlock(width: 120, height: 15),
                            const SizedBox(height: 7),
                            SkeletonBlock(
                              width: i == 0 ? 160 : 140,
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                      const SkeletonBlock(width: 44, height: 14),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}

/// The phone Today group while the session panel loads.
class QuizTodaySkeleton extends StatelessWidget {
  const QuizTodaySkeleton({super.key});
  @override
  Widget build(BuildContext context) => context.wideWeb
      ? const SkeletonPulse(child: SkeletonCard(height: 235))
      : const SkeletonPulse(
          child: SkeletonSection(height: 209, headerWidth: 60),
        );
}

/// More ways to practice while the counts load.
class QuizMoreSkeleton extends StatelessWidget {
  const QuizMoreSkeleton({super.key});
  @override
  Widget build(BuildContext context) => context.wideWeb
      ? const SkeletonPulse(child: SkeletonCard(height: 216))
      : const SkeletonPulse(
          child: SkeletonGroup(rowHeight: 56, headerWidth: 170),
        );
}

/// The Mock panel while availability loads. Phone shows it between Today and
/// More ways to practice, wide web shows it beside them.
class QuizMockPanelSkeleton extends StatelessWidget {
  const QuizMockPanelSkeleton({super.key});
  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: SkeletonCard(height: context.wideWeb ? 300 : 190),
      );
}

/// The whole Quiz page while the exam loads.
class QuizPageSkeleton extends StatelessWidget {
  const QuizPageSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return const SkeletonPulse(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WebSkeletonEyebrow(width: 60),
                  SkeletonCard(height: 235),
                  SizedBox(height: 28),
                  WebSkeletonEyebrow(width: 170),
                  SkeletonCard(height: 216),
                ],
              ),
            ),
            SizedBox(width: 28),
            Expanded(child: SkeletonCard(height: 300)),
          ],
        ),
      );
    }
    return const SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonSection(height: 209, headerWidth: 60),
          SizedBox(height: 24),
          SkeletonCard(height: 190),
          SizedBox(height: 24),
          SkeletonGroup(rowHeight: 56, headerWidth: 170),
        ],
      ),
    );
  }
}

/// The Reviews and New questions sheets while their work loads: a title and
/// count, three rows, then the Start button.
class QuizSheetSkeleton extends StatelessWidget {
  const QuizSheetSkeleton({super.key});
  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBlock(width: 140, height: 24, radius: 8),
                    SizedBox(height: 8),
                    SkeletonBlock(width: 80, height: 14),
                  ],
                ),
              ),
              for (var i = 0; i < 3; i++)
                const SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      SkeletonBlock(width: 30, height: 30, radius: 15),
                      SizedBox(width: 14),
                      SkeletonBlock(width: 150, height: 15),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              const SkeletonBlock(height: 52, radius: 14),
            ],
          ),
        ),
      );
}
