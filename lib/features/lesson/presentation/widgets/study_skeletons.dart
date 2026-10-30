import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';

/// Phone Study below the search field: Bookmarks, then each subject's topic
/// rows, under the Last opened card.
class StudyMapSkeleton extends StatelessWidget {
  const StudyMapSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonSurface(height: 166),
            SizedBox(height: 24),
            SkeletonSection(height: 94, headerWidth: 100),
            SizedBox(height: 24),
            SkeletonGroup(rows: 4, rowHeight: 47),
            SizedBox(height: 24),
            SkeletonGroup(rows: 4, rowHeight: 47),
            SizedBox(height: 24),
            SkeletonGroup(rowHeight: 47),
          ],
        ),
      );
}

/// The Bookmarks section while its rows load: the heading and the empty-state
/// height, which the section keeps when nothing is saved.
class BookmarksSkeleton extends StatelessWidget {
  const BookmarksSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: SkeletonPulse(
          child: SkeletonSection(height: 94, headerWidth: 100),
        ),
      );
}

/// The Last opened card while the last lesson loads.
class LastOpenedSkeleton extends StatelessWidget {
  const LastOpenedSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: SkeletonPulse(child: SkeletonSurface(height: 166)),
      );
}

/// A lesson before it opens: the title, a meta line, then body paragraphs.
class ReaderSkeleton extends StatelessWidget {
  const ReaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget paragraph(List<double> widths) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final w in widths) ...[
              FractionallySizedBox(
                widthFactor: w,
                alignment: Alignment.centerLeft,
                child: const SkeletonBlock(height: 17),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
    return SkeletonPulse(
      label: 'Loading lesson',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SkeletonBlock(width: 110, height: 13),
            const SizedBox(height: 12),
            const FractionallySizedBox(
              widthFactor: .86,
              alignment: Alignment.centerLeft,
              child: SkeletonBlock(height: 34, radius: 8),
            ),
            const SizedBox(height: 10),
            const FractionallySizedBox(
              widthFactor: .5,
              alignment: Alignment.centerLeft,
              child: SkeletonBlock(height: 34, radius: 8),
            ),
            const SizedBox(height: 28),
            paragraph(const [1, 1, .94, .6]),
            const SizedBox(height: 14),
            paragraph(const [1, .97, 1, .88, .4]),
            const SizedBox(height: 14),
            paragraph(const [1, 1, .72]),
          ],
        ),
      ),
    );
  }
}
