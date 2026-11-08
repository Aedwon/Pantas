import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';

enum ReaderOrigin {
  study,
  home,
  bookmarks,
  search,
  plan,
  performance;

  static ReaderOrigin fromQuery(String? value) => values.firstWhere(
        (origin) => origin.name == value,
        orElse: () => study,
      );

  String get _fallback => switch (this) {
        home || plan || performance => '/home',
        _ => '/study',
      };

  /// What the back control names. It reads whether the reader has a page
  /// beneath it from the route, not from `canPop`, which turns false in the
  /// first frame of the exit and flipped the label while the page left.
  String backLabel(BuildContext context) =>
      !(ModalRoute.of(context)?.isFirst ?? !Navigator.of(context).canPop())
          ? switch (this) {
              study => 'Study',
              home => 'Home',
              bookmarks => 'Bookmarks',
              search => 'Search',
              plan => 'Your plan',
              performance => 'Your performance',
            }
          : _fallback == '/home'
              ? 'Home'
              : 'Study';

  void leave(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      context.go(_fallback);
    }
  }
}

class ReaderBar extends StatelessWidget {
  const ReaderBar({
    required this.title,
    required this.origin,
    required this.isBookmarked,
    required this.onBookmark,
    required this.onContents,
    required this.scrollOffset,
    this.dayContext,
    this.lessonId,
    this.advanceProgress = const AlwaysStoppedAnimation(0),
    super.key,
  })  : ending = false,
        onBack = null;

  const ReaderBar.ending({required this.origin, this.onBack, super.key})
      : title = '',
        lessonId = null,
        dayContext = null,
        isBookmarked = false,
        onBookmark = _ignore,
        onContents = _ignore,
        scrollOffset = const AlwaysStoppedAnimation(0),
        advanceProgress = const AlwaysStoppedAnimation(0),
        ending = true;

  static void _ignore() {}
  final bool ending;
  final VoidCallback? onBack;

  final String title;
  final String? lessonId;
  final LessonDayContext? dayContext;
  final ReaderOrigin origin;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onContents;

  /// A listenable, not a value. The bar's strip is the only thing on the
  /// reader that changes with scroll position, so it is the only thing that
  /// should rebuild when it changes.
  final ValueListenable<double> scrollOffset;
  final ValueListenable<double> advanceProgress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final originWord = origin.backLabel(context);
    final day = dayContext;
    final dayLabel =
        day == null ? null : '${day.index + 1} of ${day.lessonIds.length}';

    return ColoredBox(
      color: ending ? colors.background : colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s4,
                PantasSpace.s6,
                PantasSpace.s8,
                PantasSpace.s0,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'Back to $originWord',
                        onTap: onBack ?? () => origin.leave(context),
                        child: ExcludeSemantics(
                          child: GestureDetector(
                            onTap: onBack ?? () => origin.leave(context),
                            behavior: HitTestBehavior.opaque,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: PantasSize.targetTouch,
                                minHeight: PantasSize.targetTouch,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomPaint(
                                    size: const Size(24, 24),
                                    painter: _BackChevronPainter(
                                      color: colors.accent,
                                    ),
                                  ),
                                  const SizedBox(width: PantasSpace.s2),
                                  Flexible(
                                    child: Text(
                                      originWord,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.type.body.copyWith(
                                        color: colors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!ending)
                      Semantics(
                        button: true,
                        label: 'Contents',
                        value: dayLabel,
                        onTap: onContents,
                        child: ExcludeSemantics(
                          child: GestureDetector(
                            onTap: onContents,
                            behavior: HitTestBehavior.opaque,
                            child: dayLabel == null
                                ? SizedBox.square(
                                    dimension: PantasSize.targetTouch,
                                    child: Center(
                                      child: ContentsGlyph(
                                        size: 23,
                                        strokeWidth: 1.8,
                                        color: context.colors.iconMuted,
                                      ),
                                    ),
                                  )
                                : ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: PantasSize.targetTouch,
                                      minWidth: PantasSize.targetTouch,
                                      maxWidth: (constraints.maxWidth - 88)
                                          .clamp(44.0, double.infinity),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: PantasSpace.s10,
                                      ),
                                      child: Center(
                                        widthFactor: 1,
                                        child: Text(
                                          dayLabel,
                                          style: context.type.subhead
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: colors.secondaryLabel,
                                              )
                                              .tabular,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    if (!ending)
                      Semantics(
                        button: true,
                        label: isBookmarked
                            ? 'Remove lesson bookmark'
                            : 'Bookmark lesson',
                        onTap: onBookmark,
                        child: ExcludeSemantics(
                          child: SizedBox.square(
                            key: const ValueKey('reader-bookmark-control'),
                            dimension: PantasSize.targetTouch,
                            child: _ReaderBookmarkControl(
                              key: ValueKey(lessonId ?? title),
                              isBookmarked: isBookmarked,
                              onTap: onBookmark,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (!ending)
            AnimatedBuilder(
              animation: Listenable.merge([scrollOffset, advanceProgress]),
              builder: (context, _) {
                final offset = scrollOffset.value;
                final raw = advanceProgress.value.clamp(0.0, 1.0);
                final motion = PantasCurves.scroll.transform(raw);
                final fraction = (offset / 90.0).clamp(0.0, 1.0);
                final lineHeight = MediaQuery.textScalerOf(context).scale(
                      context.type.footnote.fontSize!,
                    ) *
                    context.type.footnote.height!;
                final stripHeight = fraction *
                    (lineHeight > 30 ? lineHeight : 30) *
                    (1 - motion);
                return SizedBox(
                  key: const ValueKey('reader-title-strip'),
                  height: stripHeight,
                  child: stripHeight > 0
                      ? Opacity(
                          opacity: fraction *
                              (1 - (raw * 480 / 150).clamp(0.0, 1.0)),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: PantasSpace.s56,
                            ),
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.type.footnote.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.label,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
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
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(15, 4.5)
      ..lineTo(7.5, 12)
      ..lineTo(15, 19.5);

    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_BackChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// The scale of the bookmark mark [value] of the way through its 520 ms pop.
double readerBookmarkPop(double value) => value <= .5
    ? .6 + .62 * PantasCurves.popB.transform(value * 2)
    : 1.22 - .22 * PantasCurves.popB.transform((value - .5) * 2);

/// Pops [child] when [bookmarked] turns true, as the phone's bookmark does:
/// 520 ms, from .6 to 1.22 and back to 1. Taking the bookmark away resets it
/// at once. Give it a key per lesson so a new lesson never pops.
///
/// With reduced motion the child is simply there.
class ReaderBookmarkPop extends StatefulWidget {
  const ReaderBookmarkPop({
    required this.bookmarked,
    required this.child,
    super.key,
  });
  final bool bookmarked;
  final Widget child;

  @override
  State<ReaderBookmarkPop> createState() => _ReaderBookmarkPopState();
}

class _ReaderBookmarkPopState extends State<ReaderBookmarkPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mark = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    value: widget.bookmarked ? 1 : 0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _mark
        ..stop()
        ..value = widget.bookmarked ? 1 : 0;
    }
  }

  @override
  void didUpdateWidget(ReaderBookmarkPop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookmarked == widget.bookmarked) return;
    if (widget.bookmarked && !MediaQuery.disableAnimationsOf(context)) {
      _mark.forward(from: 0);
    } else {
      _mark
        ..stop()
        ..value = widget.bookmarked ? 1 : 0;
    }
  }

  @override
  void dispose() {
    _mark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _mark,
        child: widget.child,
        builder: (context, child) => Transform.scale(
          key: const ValueKey('web-reader-bookmark-pop'),
          scale: widget.bookmarked ? readerBookmarkPop(_mark.value) : 1,
          child: child,
        ),
      );
}

class _ReaderBookmarkControl extends StatefulWidget {
  const _ReaderBookmarkControl({
    required this.isBookmarked,
    required this.onTap,
    super.key,
  });
  final bool isBookmarked;
  final VoidCallback onTap;

  @override
  State<_ReaderBookmarkControl> createState() => _ReaderBookmarkControlState();
}

class _ReaderBookmarkControlState extends State<_ReaderBookmarkControl>
    with TickerProviderStateMixin {
  late final AnimationController _press;
  late final AnimationController _mark;
  bool _still = false;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this, value: 1);
    _mark = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: widget.isBookmarked ? 1 : 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _press
        ..stop()
        ..value = 1;
      _mark
        ..stop()
        ..value = widget.isBookmarked ? 1 : 0;
    }
  }

  @override
  void didUpdateWidget(_ReaderBookmarkControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBookmarked == widget.isBookmarked) return;
    if (widget.isBookmarked) {
      _press.value = 1;
      if (_still) {
        _mark.value = 1;
      } else {
        _mark.forward(from: 0);
      }
    } else {
      _mark
        ..stop()
        ..value = 0;
    }
  }

  void _pressTo(double target) {
    if (!mounted) return;
    if (_still) {
      _press.value = 1;
      return;
    }
    _press.animateTo(
      target,
      duration: const Duration(milliseconds: 100),
      curve: PantasBoardCurves.easeOut,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    _mark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _pressTo(.82),
        onTapUp: (_) => _pressTo(1),
        onTapCancel: () => _pressTo(1),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_press, _mark]),
            builder: (context, child) => Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isBookmarked)
                  Transform.scale(
                    scale: _press.value,
                    child: CustomPaint(
                      size: const Size.square(22),
                      painter: _ReaderBookmarkPainter(
                        filled: false,
                        color: context.colors.iconMuted,
                      ),
                    ),
                  ),
                Transform.scale(
                  key: const ValueKey('reader-bookmark-pop'),
                  scale: _press.value *
                      (widget.isBookmarked
                          ? readerBookmarkPop(_mark.value)
                          : 1),
                  child: CustomPaint(
                    size: const Size.square(22),
                    painter: _ReaderBookmarkPainter(
                      filled: widget.isBookmarked,
                      color: widget.isBookmarked
                          ? context.colors.accent
                          : context.colors.iconMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// BM_MarkTeal's bookmark polygon, including its filled state.
class _ReaderBookmarkPainter extends CustomPainter {
  const _ReaderBookmarkPainter({required this.filled, required this.color});
  final bool filled;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(6.5, 3.5)
      ..lineTo(17.5, 3.5)
      ..lineTo(17.5, 20.5)
      ..lineTo(12, 16.7)
      ..lineTo(6.5, 20.5)
      ..close();
    canvas
      ..save()
      ..scale(size.width / 24, size.height / 24);
    if (filled) canvas.drawPath(path, Paint()..color = color);
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.9
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_ReaderBookmarkPainter oldDelegate) =>
      oldDelegate.filled != filled || oldDelegate.color != color;
}
