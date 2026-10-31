import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// MK_NavMotion: wait 300ms, then arrive over 500ms with the board's overshoot.
class WebMockPanelTab extends StatefulWidget {
  const WebMockPanelTab({
    required this.hidden,
    required this.onPressed,
    super.key,
  });
  final bool hidden;
  final VoidCallback onPressed;

  @override
  State<WebMockPanelTab> createState() => _WebMockPanelTabState();
}

class _WebMockPanelTabState extends State<WebMockPanelTab>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  bool _hover = false;
  bool _closing = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized || MediaQuery.disableAnimationsOf(context)) {
      _initialized = true;
      _controller.value = widget.hidden ? 1 : 0;
    }
  }

  @override
  void didUpdateWidget(WebMockPanelTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hidden == widget.hidden) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.hidden ? 1 : 0;
    } else if (widget.hidden) {
      _closing = false;
      _controller.duration = const Duration(milliseconds: 800);
      _controller.forward(from: 0);
    } else {
      _closing = true;
      _controller.duration = const Duration(milliseconds: 180);
      _controller.reverse(from: 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.value == 0) return const SizedBox.shrink();
          final progress = _closing
              ? Curves.easeIn.transform(_controller.value)
              : const Cubic(.34, 1.56, .64, 1).transform(
                  ((_controller.value * 800 - 300) / 500).clamp(0, 1),
                );
          return Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              key: const ValueKey('web-mock-edge-tab'),
              // The board centers the tab on the page; the stage starts below
              // the 78 px header, so lift it by half of that.
              offset: Offset(-37.4 * (1 - progress), -39),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hover = true),
                onExit: (_) => setState(() => _hover = false),
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  curve: const Cubic(.32, .72, 0, 1),
                  width: _hover ? 40 : 34,
                  height: 76,
                  child: Material(
                    color: context.colors.surface,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(14),
                    ),
                    child: IconButton(
                      tooltip: 'Show the question list',
                      onPressed: widget.onPressed,
                      icon: AnimatedSlide(
                        offset: Offset(_hover ? .1 : 0, 0),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        curve: const Cubic(.32, .72, 0, 1),
                        child: const MockPanelGlyph(tab: true),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

/// The panel's children fade separately from its sliding surface.
class WebMockPanelContents extends StatelessWidget {
  const WebMockPanelContents({
    required this.open,
    required this.child,
    super.key,
  });
  final bool open;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return AnimatedSlide(
      offset: Offset(open ? 0 : -14 / 300, 0),
      duration: still ? Duration.zero : const Duration(milliseconds: 460),
      curve: const Cubic(.32, .72, 0, 1),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: open ? 1 : 0),
        duration:
            still ? Duration.zero : Duration(milliseconds: open ? 340 : 160),
        curve: open
            ? const Interval(120 / 340, 1, curve: Curves.ease)
            : Curves.ease,
        builder: (context, value, child) => Opacity(
          key: const ValueKey('web-mock-panel-content'),
          opacity: value,
          child: child,
        ),
        child: child,
      ),
    );
  }
}

/// The question-list icon from the boards: a window with a list strip on the
/// left (panel header) or a thick bar on the left (edge tab).
class MockPanelGlyph extends StatelessWidget {
  const MockPanelGlyph({this.tab = false, super.key});
  final bool tab;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size.square(20),
        painter: _MockPanelGlyphPainter(
          tab: tab,
          color: context.colors.secondaryLabel,
        ),
      );
}

class _MockPanelGlyphPainter extends CustomPainter {
  const _MockPanelGlyphPainter({required this.tab, required this.color});
  final bool tab;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.8 * k;
    if (tab) {
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(3.5 * k, 5.5 * k, 17 * k, 13 * k),
            Radius.circular(3 * k),
          ),
          paint,
        )
        ..drawLine(
          Offset(7.5 * k, 9.5 * k),
          Offset(7.5 * k, 14.5 * k),
          paint..strokeWidth = 2.4 * k,
        );
      return;
    }
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(3.5 * k, 4.5 * k, 17 * k, 15 * k),
          Radius.circular(2.5 * k),
        ),
        paint,
      )
      ..drawLine(Offset(9.5 * k, 4.5 * k), Offset(9.5 * k, 19.5 * k), paint);
    for (final y in [8.5, 11.5, 14.5]) {
      canvas.drawLine(Offset(5.8 * k, y * k), Offset(7.4 * k, y * k), paint);
    }
  }

  @override
  bool shouldRepaint(_MockPanelGlyphPainter old) =>
      old.tab != tab || old.color != color;
}
