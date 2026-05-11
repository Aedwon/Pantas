import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum SyncState { synced, syncing, offline }

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({
    required this.state,
    this.onTap,
    super.key,
  });

  final SyncState state;
  final VoidCallback? onTap;

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.state == SyncState.syncing) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(SyncStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == SyncState.syncing) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final Color bgColor;
    final Color dotColor;
    final Color labelColor;
    final String label;

    switch (widget.state) {
      case SyncState.synced:
        bgColor = colors.successContainer;
        dotColor = colors.success;
        labelColor = colors.success;
        label = 'Synced';
      case SyncState.syncing:
        bgColor = colors.primaryContainer;
        dotColor = colors.primary;
        labelColor = colors.primary;
        label = 'Syncing...';
      case SyncState.offline:
        bgColor = colors.warningContainer;
        dotColor = colors.warning;
        labelColor = colors.warning;
        label = 'Offline';
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Opacity(
                opacity: widget.state == SyncState.syncing
                    ? 0.3 + (_pulse.value * 0.7)
                    : 1.0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: textStyles.labelSmall.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
