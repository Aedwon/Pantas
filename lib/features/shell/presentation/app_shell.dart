import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_shape.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;
  static const _labels = ['home', 'study', 'quiz', 'settings'];

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SafeArea(
            top: false,
            child: AppNavBar(
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
          ),
        ),
      );
}

class AppNavBar extends StatelessWidget {
  const AppNavBar({required this.currentIndex, required this.onTap, super.key});
  final int currentIndex;
  final ValueChanged<int> onTap;
  static final _tabs = <({String label, IconData glyph})>[
    (label: 'Home', glyph: PantasIcons.homeTab),
    (label: 'Study', glyph: PantasIcons.studyTab),
    (label: 'Quiz', glyph: PantasIcons.quizTab),
    (label: 'Settings', glyph: PantasIcons.settingsTab),
  ];

  static const _labelHorizontalAllowance = 8.0;

  List<double> _itemWidths(BuildContext context, double availableWidth) {
    final equalWidth = availableWidth / _tabs.length;
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final labelStyle = context.type.captionSmall.copyWith(
      fontWeight: FontWeight.w600,
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
    if (requiredTotal <= availableWidth) {
      final extraPerItem = (availableWidth - requiredTotal) / _tabs.length;
      return [for (final width in requiredWidths) width + extraPerItem];
    }

    final minimumTotal = AppDimensions.minTapTarget * _tabs.length;
    if (minimumTotal >= availableWidth) {
      return List<double>.filled(_tabs.length, equalWidth);
    }

    final extraNeeds = [
      for (final width in requiredWidths)
        width > AppDimensions.minTapTarget
            ? width - AppDimensions.minTapTarget
            : 0.0,
    ];
    final totalExtraNeed = extraNeeds.fold<double>(
      0,
      (total, width) => total + width,
    );
    final distributableWidth = availableWidth - minimumTotal;

    return [
      for (final need in extraNeeds)
        AppDimensions.minTapTarget +
            (totalExtraNeed == 0
                ? distributableWidth / _tabs.length
                : distributableWidth * need / totalExtraNeed),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(PantasShape.pillRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D1D1F).withValues(alpha: 0.14),
            offset: const Offset(0, 10),
            blurRadius: 30,
          ),
          BoxShadow(
            color: const Color(0xFF1D1D1F).withValues(alpha: 0.08),
            spreadRadius: 0.5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final widths = _itemWidths(context, constraints.maxWidth - 6);
          return Row(
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 2),
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
            ],
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.glyph,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final IconData glyph;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Unselected tabs are enabled controls, not disabled text.
    final color = isActive ? colors.accent : colors.secondaryLabel;
    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            color: isActive ? colors.accentTint : Colors.transparent,
            borderRadius: BorderRadius.circular(PantasShape.pillRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(glyph, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: context.type.captionSmall.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
