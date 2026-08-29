import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/nav_glyph.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _labels = ['home', 'study', 'quiz', 'progress'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) {
          ref.read(telemetryProvider).log(
            TelemetryEvent.tabOpened,
            properties: {'tab': _labels[i]},
          );
          navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

/// Public so it can be widget-tested without a router.
class AppNavBar extends StatelessWidget {
  const AppNavBar({required this.currentIndex, required this.onTap, super.key});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = <({String label, NavGlyphKind glyph})>[
    (label: 'Home', glyph: NavGlyphKind.home),
    (label: 'Study', glyph: NavGlyphKind.study),
    (label: 'Quiz', glyph: NavGlyphKind.quiz),
    (label: 'Progress', glyph: NavGlyphKind.progress),
  ];

  static const _labelHorizontalAllowance = 8.0;

  List<double> _itemWidths(BuildContext context, double availableWidth) {
    final equalWidth = availableWidth / _tabs.length;
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final labelStyle = context.textStyles.labelSmall.copyWith(
      fontWeight: FontWeight.w700,
    );

    final requiredWidths = [
      for (final tab in _tabs)
        () {
          final painter = TextPainter(
            text: TextSpan(text: tab.label, style: labelStyle),
            textDirection: textDirection,
            textScaler: textScaler,
            maxLines: 1,
          )..layout();
          final width = painter.width + _labelHorizontalAllowance;
          return width < AppDimensions.minTapTarget
              ? AppDimensions.minTapTarget
              : width;
        }(),
    ];

    if (requiredWidths.every((width) => width <= equalWidth)) {
      return List<double>.filled(_tabs.length, equalWidth);
    }

    final requiredTotal = requiredWidths.fold<double>(
      0,
      (total, width) => total + width,
    );
    if (requiredTotal > availableWidth) {
      return List<double>.filled(_tabs.length, equalWidth);
    }

    final extraPerItem = (availableWidth - requiredTotal) / _tabs.length;
    return [for (final width in requiredWidths) width + extraPerItem];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.rule,
            // ignore: avoid_redundant_argument_values
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final widths = _itemWidths(context, constraints.maxWidth);
              return Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    SizedBox(
                      width: widths[i],
                      child: _NavItem(
                        label: _tabs[i].label,
                        glyph: _tabs[i].glyph,
                        isActive: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.glyph,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final NavGlyphKind glyph;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  /// Longer than the platform norm, and chosen against a live slider rather
  /// than from a description. Re-check on the emulator once the page
  /// transition is also in play, since perceived latency compounds.
  static const _riseDuration = Duration(milliseconds: 400);
  static const _riseCurve = Cubic(.22, 1, .36, 1);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _riseDuration,
    value: widget.isActive ? 1 : 0,
  );
  late final Animation<double> _fill = CurvedAnimation(
    parent: _controller,
    curve: _riseCurve,
  );

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (old.isActive == widget.isActive) return;
    if (!widget.isActive) {
      // The outgoing tab drains instantly. Two glyphs animating at once
      // reads as busy, so only the incoming one plays.
      _controller.value = 0;
    } else if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    // Board green is reserved for primary actions, progress indicators and
    // done-checks. Marking navigation with it would cost the primary button
    // its meaning.
    final color = widget.isActive ? colors.ink : colors.inkMuted;

    return Semantics(
      label: widget.label,
      button: true,
      selected: widget.isActive,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: widget.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minTapTarget,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _fill,
                builder: (context, _) => NavGlyph(
                  kind: widget.glyph,
                  fill: _fill.value,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: styles.labelSmall.copyWith(
                  color: color,
                  fontWeight:
                      widget.isActive ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
