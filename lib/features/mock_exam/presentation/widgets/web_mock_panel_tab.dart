import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/icons/own/mock_panel_glyph.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_motion_recipes.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

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
  // Wait, then arrive: the whole run is the wait plus the reveal.
  static final _arrive = PantasDurations.wait + PantasDurations.reveal;
  late final _controller = AnimationController(
    vsync: this,
    duration: _arrive,
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
      _controller.duration = _arrive;
      _controller.forward(from: 0);
    } else {
      _closing = true;
      _controller.duration = PantasDurations.short3;
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
              : PantasCurves.spring.transform(
                  ((_controller.value * _arrive.inMilliseconds -
                              PantasDurations.wait.inMilliseconds) /
                          PantasDurations.reveal.inMilliseconds)
                      .clamp(0, 1),
                );
          return Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              key: const ValueKey('web-mock-edge-tab'),
              // The tab is centered on the page; the stage starts below the
              // focus header, so lift it by half of that.
              offset: Offset(
                -PantasSpace.s32 * (1 - progress),
                -PantasLayout.focusHead / 2,
              ),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hover = true),
                onExit: (_) => setState(() => _hover = false),
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : PantasDurations.nudge,
                  curve: PantasCurves.move,
                  width: _hover ? PantasSpace.s40 : PantasSpace.s32,
                  height: PantasSize.btnBar,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colors.surfaceCard,
                      boxShadow: context.shadows.popover,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(PantasRadius.md),
                      ),
                    ),
                    child: PantasIconButton(
                      tooltip: 'Show the question list',
                      onPressed: widget.onPressed,
                      icon: AnimatedSlide(
                        offset: Offset(_hover ? .1 : 0, 0),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : PantasDurations.nudge,
                        curve: PantasCurves.move,
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
    const arrive = PantasMotionRecipes.panelChildrenIn;
    const leave = PantasMotionRecipes.panelChildrenOut;
    final arriveTotal = arrive.delay + arrive.duration;
    return AnimatedSlide(
      offset: Offset(open ? 0 : -PantasSpace.s14 / PantasLayout.qpanel, 0),
      duration: still ? Duration.zero : PantasDurations.navPanel,
      curve: PantasCurves.move,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: open ? 1 : 0),
        duration: still
            ? Duration.zero
            : open
                ? arriveTotal
                : leave.duration,
        curve: open
            ? Interval(
                arrive.delay.inMilliseconds / arriveTotal.inMilliseconds,
                1,
                curve: arrive.curve,
              )
            : leave.curve,
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
