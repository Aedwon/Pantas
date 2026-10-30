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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
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
              offset: Offset(-37.4 * (1 - progress), 0),
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
                      icon: const Icon(Icons.view_sidebar_outlined, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}
