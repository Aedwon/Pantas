import 'package:cse_cet_reviewer/core/ui/components/bookmark_ribbon.dart';
import 'package:cse_cet_reviewer/core/ui/components/contents_glyph.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum ReaderOrigin { home, study }

class ReaderBar extends StatelessWidget {
  const ReaderBar({
    required this.title,
    required this.origin,
    required this.isBookmarked,
    required this.onBookmark,
    required this.onContents,
    required this.scrollOffset,
    super.key,
  });

  final String title;
  final ReaderOrigin origin;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onContents;
  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final originWord = origin == ReaderOrigin.home ? 'Home' : 'Study';

    final fraction = (scrollOffset / 90.0).clamp(0.0, 1.0);
    final stripHeight = fraction * 30.0;

    return ColoredBox(
      color: colors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: const Size(15, 15),
                          painter: _BackChevronPainter(color: colors.inkMuted),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          originWord,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onContents,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: ContentsGlyph(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BookmarkRibbon(
                    isBookmarked: isBookmarked,
                    onTap: onBookmark,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            key: const ValueKey('reader-title-strip'),
            height: stripHeight,
            child: stripHeight > 0
                ? Opacity(
                    opacity: fraction,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'SourceSerif4',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  const _BackChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.7, size.height * 0.15)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.85);

    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_BackChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
