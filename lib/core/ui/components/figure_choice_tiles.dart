import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/roving_focus.dart';
import 'package:pantas/core/ui/figures/choice_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The mark at a tile's top right corner: 22, as on the O2 boards.
// ds-board: O2 boards, `.opt__mark` is 22 by 22 on a tile
const double _markSize = 22;

/// The share of the figure card's width the figure takes (`.fc-back svg`).
// ds-board: O2 boards, the figure is 60% of the card's width
const double _figureShare = 0.6;

/// The mark's pop: 560 ms, peaking at 320 (AnswerOption README, Motion).
// ds-board: AnswerOption README: the pop runs 560 ms
const Duration _popDuration = Duration(milliseconds: 560);
const double _popPeakMs = 320;

/// One choice of a figure choice group.
@immutable
class FigureChoiceItem {
  const FigureChoiceItem({
    required this.letter,
    required this.description,
    required this.figure,
    this.state = ChoiceRowState.plain,
    this.chosen,
  });

  final String letter;

  /// What the figure shows, in words. A screen reader reads it; it is never
  /// drawn.
  final String description;
  final ChoiceFigure figure;
  final ChoiceRowState state;

  /// Whether the student picked this tile. Null takes it from [state]: the
  /// picked tile and the wrong tile.
  final bool? chosen;
}

/// Whether the focused control is an answer that hands Enter to the page: a
/// text row that is already picked, or a figure tile that is picked or read
/// only. Enter on it checks the answer, or goes to Next once it is checked, so
/// a page's Enter shortcut passes this as `keepsEnter`. A tile that is not yet
/// picked takes Enter itself and picks.
bool focusedAnswerIsPicked(BuildContext focused) =>
    focused.findAncestorWidgetOfExactType<WebAnswerOption>()?.state ==
        WebOptionState.selected ||
    (focused.findAncestorWidgetOfExactType<FigureChoiceTile>()?.state ??
            ChoiceRowState.plain) !=
        ChoiceRowState.plain;

/// The choices of a question as figure tiles (AnswerOption's states on a
/// square tile): two columns on a phone, one row on wide web.
///
/// A radio group named by the question's stem. Tab reaches one tile, the
/// picked one or the first. Before the answer is checked the arrow keys move
/// focus and pick; after it they move focus only. After the reveal a tile is
/// read only: it stays focusable and readable, and is never disabled.
class FigureChoiceGroup extends StatelessWidget {
  const FigureChoiceGroup({
    required this.stem,
    required this.items,
    this.onPick,
    super.key,
  });

  /// The question's stem: the group's accessible name.
  final String stem;
  final List<FigureChoiceItem> items;

  /// Picks the tile at an index. Null means the answer cannot be changed:
  /// checked, or being checked.
  final ValueChanged<int>? onPick;

  static bool _revealed(ChoiceRowState state) =>
      state == ChoiceRowState.right ||
      state == ChoiceRowState.wrong ||
      state == ChoiceRowState.dimmed;

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final revealed = items.any((i) => _revealed(i.state));
    final wrongShown = items.any((i) => i.state == ChoiceRowState.wrong);
    var tabStop = items.indexWhere(
      (i) =>
          i.state == ChoiceRowState.picked || i.state == ChoiceRowState.wrong,
    );
    if (tabStop < 0) {
      tabStop = items.indexWhere((i) => i.state == ChoiceRowState.right);
    }
    if (tabStop < 0) tabStop = 0;
    // Four across in the 720 column, five across for five choices (O2_States).
    // A phone always has two columns.
    final columns = wide ? math.min(5, math.max(4, items.length)) : 2;
    final gap = wide ? PantasSpace.s12 : PantasSpace.s10;
    return Semantics(
      role: SemanticsRole.radioGroup,
      label: stem,
      explicitChildNodes: true,
      child: RovingFocus(
        count: items.length,
        tabStop: tabStop,
        // Arrows move and pick before the reveal, and only move after it.
        onSelect: (i) {
          if (!revealed) onPick?.call(i);
        },
        builder: (context, nodes) => LayoutBuilder(
          builder: (context, constraints) {
            final side = (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < items.length; i++)
                  SizedBox.square(
                    dimension: side,
                    child: FigureChoiceTile(
                      key: ValueKey('figure-choice-${items[i].letter}'),
                      letter: items[i].letter,
                      description: items[i].description,
                      figure: items[i].figure,
                      state: items[i].state,
                      chosen: items[i].chosen,
                      delayed:
                          items[i].state == ChoiceRowState.right && wrongShown,
                      focusNode: nodes[i],
                      onTap:
                          onPick == null || revealed ? null : () => onPick!(i),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One figure choice: the letter badge at the top left over the figure on its
/// white backing, with the result mark at the top right once revealed.
///
/// Figures are never dimmed and a tile never uses opacity. A tile that is
/// neither picked nor right keeps its rest look after the reveal and only its
/// badge ring turns to `divider`.
class FigureChoiceTile extends StatefulWidget {
  const FigureChoiceTile({
    required this.letter,
    required this.description,
    required this.figure,
    required this.state,
    this.chosen,
    this.delayed = false,
    this.focusNode,
    this.onTap,
    super.key,
  });

  final String letter;
  final String description;
  final ChoiceFigure figure;
  final ChoiceRowState state;
  final bool? chosen;

  /// The right tile that follows a wrong pick, 150 ms after it.
  final bool delayed;
  final FocusNode? focusNode;

  /// Null makes the tile read only. It still takes focus.
  final VoidCallback? onTap;

  @override
  State<FigureChoiceTile> createState() => _FigureChoiceTileState();
}

class _FigureChoiceTileState extends State<FigureChoiceTile>
    with SingleTickerProviderStateMixin {
  late ChoiceRowState _visual = widget.state;
  Timer? _delay;
  bool _hovered = false;
  bool _focused = false;
  late final AnimationController _pop;

  static void _noop() {}

  static bool _result(ChoiceRowState s) =>
      s == ChoiceRowState.right || s == ChoiceRowState.wrong;

  @override
  void initState() {
    super.initState();
    // Built here, not on first use, so dispose never creates it.
    _pop = AnimationController(vsync: this, duration: _popDuration, value: 1);
    webKeyboardInput.addListener(_inputChanged);
  }

  void _inputChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(FigureChoiceTile old) {
    super.didUpdateWidget(old);
    if (widget.state == old.state) return;
    _delay?.cancel();
    final reduced = MediaQuery.disableAnimationsOf(context);
    final arriving = _result(widget.state) && !_result(_visual);
    if (arriving && !reduced) {
      final wait = widget.state == ChoiceRowState.right && widget.delayed
          ? PantasDurations.short2
          : Duration.zero;
      void show() {
        if (!mounted) return;
        setState(() => _visual = widget.state);
        unawaited(_pop.forward(from: 0));
      }

      if (wait == Duration.zero) {
        show();
      } else {
        _delay = Timer(wait, show);
      }
      return;
    }
    _visual = widget.state;
    _pop.value = 1;
  }

  @override
  void dispose() {
    webKeyboardInput.removeListener(_inputChanged);
    _delay?.cancel();
    _pop.dispose();
    super.dispose();
  }

  double _markScale(bool wrong) {
    final top = wrong ? 1.1 : 1.15;
    final ms = _pop.value * _popDuration.inMilliseconds;
    if (ms <= _popPeakMs) {
      return .4 + (top - .4) * PantasCurves.move.transform(ms / _popPeakMs);
    }
    return top +
        (1 - top) *
            PantasCurves.move.transform(
              (ms - _popPeakMs) / (_popDuration.inMilliseconds - _popPeakMs),
            );
  }

  String get _suffix => switch (widget.state) {
        ChoiceRowState.right => ', correct answer',
        ChoiceRowState.wrong => ', your answer, wrong',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final wide = context.wideWeb;
    final still = MediaQuery.disableAnimationsOf(context);
    final v = _visual;
    final right = v == ChoiceRowState.right;
    final wrong = v == ChoiceRowState.wrong;
    final picked = v == ChoiceRowState.picked;
    final dimmed = v == ChoiceRowState.dimmed;
    final filled = right || wrong || picked;
    final readOnly = widget.onTap == null;
    final live = !readOnly && (v == ChoiceRowState.plain || picked);
    final fade = still ? Duration.zero : PantasDurations.short3;
    const radius = BorderRadius.all(Radius.circular(PantasRadius.lg));

    final Color ring;
    final double ringWidth;
    if (right || picked) {
      ring = c.accent;
      ringWidth = PantasBorder.ringSelected;
    } else if (wrong) {
      ring = c.danger;
      ringWidth = PantasBorder.ringSelected;
    } else if (live && _hovered) {
      ring = c.dividerStrong;
      ringWidth = PantasBorder.ringStrong;
    } else {
      ring = Colors.transparent;
      ringWidth = PantasBorder.ringStrong;
    }
    final background = right
        ? c.accentTint
        : wrong
            ? c.dangerTint
            : c.surfaceCard;

    final badgeBase = wide ? PantasSize.optBadge : PantasSize.optBadgePhone;
    final badge = math.max(
      badgeBase,
      MediaQuery.textScalerOf(context).scale(PantasType.webLink.fontSize!) *
          (wide ? 2.15 : 2),
    );
    final badgeFill = wrong
        ? c.dangerFill
        : filled
            ? c.accentFill
            : null;
    final letterInk = wrong
        ? c.onDanger
        : filled
            ? c.onAccent
            : c.textSecondary;

    final chosen = widget.chosen ??
        (widget.state == ChoiceRowState.picked ||
            widget.state == ChoiceRowState.wrong);

    const outset = PantasBorder.focus + PantasSpace.s2;
    final focusRing = wide
        ? webFocusRing(
            {if (_focused) WidgetState.focused},
            // text-primary only on a checked tile, so focus never looks like
            // selection; an unpicked right tile keeps the accent outline.
            chosen ? c.textPrimary : c.accent,
          )
        : null;

    final markVisible = right || wrong;
    final markColor = right ? c.accentTintText : c.dangerText;

    return Semantics(
      label: '${widget.letter}, ${widget.description}$_suffix',
      checked: chosen,
      selected: chosen,
      inMutuallyExclusiveGroup: true,
      // Read only after the reveal, never disabled: it stays focusable.
      enabled: true,
      readOnly: readOnly,
      focusable: true,
      focused: _focused,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          PressScale(
            enabled: live,
            child: AnimatedContainer(
              duration: fade,
              curve: PantasCurves.fade,
              decoration: BoxDecoration(
                color: background,
                borderRadius: radius,
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: ring, width: ringWidth),
              ),
              child: Material(
                type: MaterialType.transparency,
                borderRadius: radius,
                // ds-raw: core/ui component; raw_controls.dart is for screens
                // and does not apply here. The tile is its own tap target.
                child: InkWell(
                  focusNode: widget.focusNode,
                  // A read-only tile stays focusable, so the tap does nothing
                  // rather than being null, which would disable it.
                  onTap: widget.onTap ?? _noop,
                  borderRadius: radius,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  mouseCursor: readOnly || !live
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                  onHover: (v) => setState(() => _hovered = v),
                  onFocusChange: (v) => setState(() => _focused = v),
                  child: Padding(
                    padding: const EdgeInsets.all(PantasSpace.s12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            key: const ValueKey('figure-choice-badge'),
                            duration: fade,
                            curve: PantasCurves.fade,
                            width: badge,
                            height: badge,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: badgeFill,
                              border: filled
                                  ? null
                                  : Border.all(
                                      color:
                                          dimmed ? c.divider : c.borderControl,
                                      width: PantasBorder.ringStrong,
                                    ),
                            ),
                            child: Text(
                              widget.letter,
                              style: PantasType.webLink.copyWith(
                                // ds-board: README type: web-glyph leading 1
                                height: 1,
                                fontWeight:
                                    filled ? FontWeight.w700 : FontWeight.w600,
                                color: letterInk,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: PantasSpace.s8),
                        Expanded(
                          child: _FigureCard(figure: widget.figure),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (markVisible)
            Positioned(
              top: PantasSpace.s12,
              right: PantasSpace.s12,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _pop,
                  builder: (context, _) {
                    final ms =
                        _pop.value * _popDuration.inMilliseconds / _popPeakMs;
                    return Transform.scale(
                      key: const ValueKey('figure-choice-mark'),
                      scale: _markScale(wrong),
                      child: Icon(
                        right ? PantasIcons.check : PantasIcons.close,
                        size: _markSize,
                        color: markColor.withValues(
                          alpha: ms.clamp(0, 1).toDouble(),
                        ),
                      ),
                    );
                  },
                ),
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
                  key: const ValueKey('figure-choice-focus'),
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

/// The figure on its white backing: `figure-bg` (white in dark too), radius
/// `radius-md` and a 1px `divider` ring. The figure takes 60% of the card's
/// width, as drawn on the boards, and never more than the card's height.
class _FigureCard extends StatelessWidget {
  const _FigureCard({required this.figure});

  final ChoiceFigure figure;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const radius = BorderRadius.all(Radius.circular(PantasRadius.md));
    return DecoratedBox(
      key: const ValueKey('figure-choice-card'),
      decoration: BoxDecoration(color: c.figureBg, borderRadius: radius),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: radius,
          // The ring is the default 1px (`border-ring`).
          border: Border.all(color: c.divider),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = math.min(
              constraints.maxWidth * _figureShare,
              constraints.maxHeight,
            );
            return Center(
              child: ExcludeSemantics(
                child: SizedBox.square(
                  dimension: side,
                  child: ChoiceFigureDrawing(figure: figure),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
