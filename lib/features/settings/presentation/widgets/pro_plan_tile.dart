import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_tag.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

/// The plan tile of the Pro page (SelectableTile, "plan tile"): the plan name
/// (15/600), the price (amount 26/700 and period), an optional per-month line
/// and an optional solid tag on the top edge.
///
/// It follows the exam tile of [SelectableTile]: `radius-lg`, `surface-card`,
/// a 1 `divider` edge at rest, `accent-tint` with a 2 `accent` ring when
/// chosen, press scale 0.98, and a keyboard focus ring that turns
/// `text-primary` on the chosen plan. The tag sits in a header slot in the
/// flow (D190). A null [onTap] stops the tap but keeps the look; [unavailable]
/// draws the disabled look.
class ProPlanTile extends StatefulWidget {
  const ProPlanTile({
    required this.name,
    required this.amount,
    required this.period,
    required this.selected,
    required this.onTap,
    this.sub,
    this.tag,
    this.reserveTagSlot = false,
    this.unavailable = false,
    super.key,
  });

  final String name;
  final String amount;
  final String period;
  final String? sub;
  final bool selected;
  final VoidCallback? onTap;

  /// A short status on the top edge ("7 DAYS FREE").
  final String? tag;

  /// Keeps the header slot on an untagged tile whose siblings have a tag.
  final bool reserveTagSlot;

  /// The plan cannot be chosen yet: the disabled look.
  final bool unavailable;

  @override
  State<ProPlanTile> createState() => _ProPlanTileState();
}

class _ProPlanTileState extends State<ProPlanTile> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  void _inputChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    webKeyboardInput.addListener(_inputChanged);
  }

  @override
  void dispose() {
    webKeyboardInput.removeListener(_inputChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final c = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final selected = w.selected && !w.unavailable;
    final radius = BorderRadius.circular(PantasRadius.lg);
    final fill = w.unavailable
        ? c.fill
        : selected
            ? c.accentTint
            : c.surfaceCard;
    final ink = w.unavailable ? c.textDisabled : c.textPrimary;
    final subInk = w.unavailable
        ? c.textDisabled
        : selected
            ? c.textOnTintSecondary
            : c.textSecondary;
    final ring = w.unavailable
        ? null
        : BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? c.accent
                  : _hovered
                      ? c.textSecondary
                      : c.divider,
              width: selected ? PantasBorder.ringSelected : PantasBorder.ring,
            ),
          );
    final hasTag = w.tag != null;
    final slot = hasTag || w.reserveTagSlot
        ? SelectableTile.slotHeight(context)
        : PantasSpace.s0;
    final focusRing = webFocusRing(
      {if (_focused) WidgetState.focused},
      selected ? c.textPrimary : c.accent,
    );
    const outset = PantasBorder.focus + PantasSpace.s2;
    final tagHeight = SelectableTile.tagHeight(context);
    return Semantics(
      container: true,
      button: true,
      checked: w.selected,
      inMutuallyExclusiveGroup: true,
      enabled: !w.unavailable && w.onTap != null,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          AnimatedScale(
            scale: w.onTap != null && _pressed && !still ? 0.98 : 1,
            duration: PantasDurations.short3,
            curve: PantasCurves.move,
            child: AnimatedContainer(
              key: const ValueKey('pro-plan-tile'),
              duration: still ? Duration.zero : PantasDurations.short2,
              curve: PantasCurves.fade,
              constraints: const BoxConstraints(minHeight: PantasSize.optMin),
              decoration: BoxDecoration(color: fill, borderRadius: radius),
              foregroundDecoration: ring,
              child: Material(
                type: MaterialType.transparency,
                borderRadius: radius,
                child: InkWell(
                  // ds-raw: tile draws its own states, as SelectableTile
                  onTap: w.onTap,
                  borderRadius: radius,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  onHover: (v) => setState(() => _hovered = v),
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  onFocusChange: (v) => setState(() => _focused = v),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PantasSpace.s16,
                      SelectableTile.padTop,
                      PantasSpace.s14,
                      PantasSpace.s12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (slot > 0) SizedBox(height: slot),
                        Text(
                          w.name,
                          style: PantasType.webLink.copyWith(color: ink),
                        ),
                        const SizedBox(height: PantasSpace.s6),
                        // The price never breaks across lines: it shrinks.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                w.amount,
                                maxLines: 1,
                                softWrap: false,
                                style: PantasType.webH2.copyWith(
                                  color: ink,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: PantasSpace.s6),
                              Text(
                                w.period,
                                maxLines: 1,
                                softWrap: false,
                                style: PantasType.webSub.copyWith(
                                  color: subInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (w.sub != null) ...[
                          const SizedBox(height: PantasSpace.s2),
                          Text(
                            w.sub!,
                            style: PantasType.webSmall.copyWith(color: subInk),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (hasTag)
            Positioned(
              key: const ValueKey('pro-plan-tile-tag'),
              top: -tagHeight / 2,
              left: PantasSpace.s16,
              child: IgnorePointer(
                child: PantasTag(w.tag!, tone: PantasTagTone.solid),
              ),
            ),
          if (focusRing != null)
            Positioned(
              left: -outset,
              top: -outset,
              right: -outset,
              bottom: -outset,
              child: IgnorePointer(
                child: DecoratedBox(
                  key: const ValueKey('pro-plan-tile-focus'),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      PantasRadius.lg + outset,
                    ),
                    border: Border.fromBorderSide(focusRing),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
