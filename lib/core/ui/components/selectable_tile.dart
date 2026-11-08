import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_tag.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

/// A tile that picks one option of a group (exam, plan) or one of several.
///
/// The exam tile is at least 64 high, `radius-lg`, on `surface-card`, with a
/// name (16/600) and a sub line (13/400). Rest is a 1 `border-control` ring;
/// hover a 1 `text-secondary` ring; selected is `accent-tint` with a 2
/// `accent` ring and a sub line in `text-on-tint-secondary`. Press scales to
/// 0.98 over 180ms. Keyboard focus draws a 2 outline at offset 2, in
/// `text-primary` when the tile is selected so focus never looks like
/// selection.
///
/// A [tag] sits in a header slot at the top of the tile, centered on its top
/// edge and 16 from the left (D190). The slot is in the flow: the title starts
/// at the larger of the tile padding and half the tag plus 2, so at 200 percent
/// text the title stays below the tag. A tile without a tag in the same grid
/// sets [reserveTagSlot] to keep its title on the same line. A
/// [SelectableTileGrid] does this itself.
///
/// [SelectableTile.day] is the day tile (76 high, 44 wide at least): the
/// weekday above a count, selected as an `accent-fill` tile with no ring.
/// With a null [onTap] the tile is disabled: `fill` and `text-disabled`.
class SelectableTile extends StatefulWidget {
  const SelectableTile({
    required this.name,
    required this.selected,
    required this.onTap,
    this.sub,
    this.tag,
    this.tagTone = PantasTagTone.solid,
    this.reserveTagSlot = false,
    this.single = false,
    this.semanticLabel,
    super.key,
  })  : day = false,
        weekday = null;

  /// A day tile: [weekday] ("Mon") above [name] (the count, such as "1h").
  const SelectableTile.day({
    required this.weekday,
    required this.name,
    required this.selected,
    required this.onTap,
    this.semanticLabel,
    super.key,
  })  : day = true,
        sub = null,
        tag = null,
        tagTone = PantasTagTone.solid,
        reserveTagSlot = false,
        single = false;

  final String name;
  final String? sub;
  final String? weekday;
  final bool selected;

  /// Null disables the tile.
  final VoidCallback? onTap;

  /// A short status on the top edge ("7 Days Free"). Two words at most.
  final String? tag;
  final PantasTagTone tagTone;

  /// Keeps the header slot on an untagged tile whose siblings have a tag.
  final bool reserveTagSlot;

  /// A single-select tile reads as a radio; otherwise it reads as a checkbox.
  final bool single;

  /// The full name for a screen reader ("Monday, 1 hour" on a day tile).
  final String? semanticLabel;
  final bool day;

  /// The same tile with the tag slot reserved.
  SelectableTile withReservedSlot() => SelectableTile(
        name: name,
        selected: selected,
        onTap: onTap,
        sub: sub,
        tag: tag,
        tagTone: tagTone,
        reserveTagSlot: true,
        single: single,
        semanticLabel: semanticLabel,
        key: key,
      );

  /// The tile's top padding, `space-12`.
  static const double padTop = PantasSpace.s12;

  /// The tag's drawn height at the current text scale.
  static double tagHeight(BuildContext context) => PantasTag.heightFor(
        MediaQuery.textScalerOf(context).scale(PantasType.webTag.fontSize!),
      );

  /// The header slot above the title: zero at default text, where the title
  /// starts at the padding, and growing with the tag at large text.
  static double slotHeight(BuildContext context) {
    final extra = tagHeight(context) / 2 + PantasSpace.s2 - padTop;
    return extra > 0 ? extra : 0;
  }

  @override
  State<SelectableTile> createState() => _SelectableTileState();
}

class _SelectableTileState extends State<SelectableTile> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  // A press elsewhere takes the ring away without moving focus, and a key
  // press brings it back, so the ring also follows the last input.
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
    final enabled = w.onTap != null;
    final still = MediaQuery.disableAnimationsOf(context);
    final selected = w.selected && enabled;
    final fade = still ? Duration.zero : PantasDurations.short2;
    final radius = BorderRadius.circular(PantasRadius.lg);
    final daySelected = w.day && selected;

    final Color fill;
    if (!enabled) {
      fill = c.fill;
    } else if (daySelected) {
      fill = c.accentFill;
    } else if (selected) {
      fill = c.accentTint;
    } else {
      fill = c.surfaceCard;
    }
    final ink = !enabled
        ? c.textDisabled
        : daySelected
            ? c.onAccent
            : c.textPrimary;
    final subInk = !enabled
        ? c.textDisabled
        : daySelected
            ? c.onAccent
            : selected
                ? c.textOnTintSecondary
                : c.textSecondary;

    BoxDecoration? ring;
    if (enabled && !daySelected) {
      ring = BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: selected
              ? c.accent
              : _hovered
                  ? c.textSecondary
                  : c.borderControl,
          width: selected ? PantasBorder.ringSelected : PantasBorder.ring,
        ),
      );
    }

    final hasTag = w.tag != null;
    final slot = hasTag || w.reserveTagSlot
        ? SelectableTile.slotHeight(context)
        : PantasSpace.s0;

    final Widget content;
    if (w.day) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            w.weekday!,
            style: PantasType.webTag.copyWith(color: subInk),
          ),
          Text(
            w.name,
            style: PantasType.webH3.copyWith(
              color: ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slot > 0) SizedBox(height: slot),
          Text(
            w.name,
            style: PantasType.webTitleSm.copyWith(color: ink),
          ),
          if (w.sub != null) ...[
            const SizedBox(height: PantasSpace.s2),
            Text(
              w.sub!,
              style: PantasType.webSmall.copyWith(color: subInk),
            ),
          ],
        ],
      );
    }

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
      inMutuallyExclusiveGroup: w.single,
      enabled: enabled,
      label: w.semanticLabel,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          AnimatedScale(
            scale: enabled && _pressed && !still ? 0.98 : 1,
            duration: PantasDurations.short3,
            curve: PantasCurves.move,
            child: AnimatedContainer(
              key: const ValueKey('selectable-tile'),
              duration: fade,
              curve: PantasCurves.fade,
              constraints: BoxConstraints(
                minHeight: w.day ? PantasSize.tileDay : PantasSize.optMin,
                minWidth: w.day ? PantasSize.targetTouch : PantasSpace.s0,
              ),
              decoration: BoxDecoration(color: fill, borderRadius: radius),
              foregroundDecoration: ring,
              child: Material(
                type: MaterialType.transparency,
                borderRadius: radius,
                child: InkWell(
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
                    padding: w.day
                        ? const EdgeInsets.symmetric(
                            horizontal: PantasSpace.s4,
                            vertical: PantasSpace.s8,
                          )
                        : const EdgeInsets.fromLTRB(
                            PantasSpace.s16,
                            SelectableTile.padTop,
                            PantasSpace.s14,
                            PantasSpace.s12,
                          ),
                    child: w.day ? Center(child: content) : content,
                  ),
                ),
              ),
            ),
          ),
          if (hasTag)
            Positioned(
              key: const ValueKey('selectable-tile-tag'),
              top: -tagHeight / 2,
              left: PantasSpace.s16,
              child: IgnorePointer(
                child: PantasTag(w.tag!, tone: w.tagTone),
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
                  key: const ValueKey('selectable-tile-focus'),
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

/// A grid of [SelectableTile]s: columns at least `size-tile-min` wide (10rem,
/// scaled with the text, so large text drops to one column), 10 apart, rows
/// of equal height.
///
/// If any tile has a tag, the untagged tiles reserve the same header slot and
/// the grid adds half the tag's height above itself, so every title in a row
/// starts on one line (D190).
class SelectableTileGrid extends StatelessWidget {
  const SelectableTileGrid({required this.children, super.key});

  final List<SelectableTile> children;

  @override
  Widget build(BuildContext context) {
    final anyTag = children.any((tile) => tile.tag != null);
    final tiles = anyTag
        ? [
            for (final tile in children)
              tile.tag == null ? tile.withReservedSlot() : tile,
          ]
        : children;
    final minWidth = MediaQuery.textScalerOf(context).scale(
      PantasSize.tileMin,
    );
    final halfTag =
        anyTag ? SelectableTile.tagHeight(context) / 2 : PantasSpace.s0;
    return Padding(
      padding: EdgeInsets.only(top: halfTag),
      child: LayoutBuilder(
        builder: (context, box) {
          const gap = PantasSpace.s10;
          final columns = box.maxWidth.isFinite
              ? ((box.maxWidth + gap) / (minWidth + gap)).floor().clamp(1, 99)
              : 1;
          final rows = <Widget>[];
          for (var i = 0; i < tiles.length; i += columns) {
            final slice = tiles.skip(i).take(columns).toList();
            rows.add(
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = 0; j < columns; j++) ...[
                      if (j > 0) const SizedBox(width: gap),
                      Expanded(
                        child: j < slice.length
                            ? slice[j]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: gap),
                rows[i],
              ],
            ],
          );
        },
      ),
    );
  }
}
