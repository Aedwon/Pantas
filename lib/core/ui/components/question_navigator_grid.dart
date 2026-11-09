import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/question_navigator_chip.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// One question in a [QuestionNavigatorGrid].
@immutable
class NavigatorQuestion {
  const NavigatorQuestion({
    required this.number,
    this.answered = false,
    this.current = false,
    this.flagged = false,
    this.enabled = true,
  });

  /// The number shown on the chip.
  final int number;
  final bool answered;
  final bool current;
  final bool flagged;

  /// False for a locked question: it cannot be opened, and the arrow keys
  /// skip it.
  final bool enabled;

  /// The spoken name. It carries the state so color is never the only cue:
  /// "Question 12, blank, flagged".
  String get name {
    if (!enabled) return 'Question $number, locked';
    return 'Question $number${current ? ', current' : ''}'
        ', ${answered ? 'answered' : 'blank'}${flagged ? ', flagged' : ''}';
  }
}

/// The question grid of design system 4.0 (QuestionNavigator): six columns of
/// 36 px chips, 8 px apart, each in a 44 px touch area.
///
/// It shows progress only: answered, blank, current, locked and flagged. It
/// never colors a chip for right or wrong.
///
/// Keyboard: Tab reaches one chip, the current one (or the first open chip).
/// Left and Right move one chip, Up and Down one row of six, Home and End the
/// first and the last open chip. Arrows skip locked chips. Enter and Space
/// open the focused chip. The grid is a table of rows and cells to a screen
/// reader.
class QuestionNavigatorGrid extends StatefulWidget {
  const QuestionNavigatorGrid({
    required this.questions,
    required this.onSelected,
    this.chipKey,
    this.scrollCurrentIntoView = true,
    super.key,
  });

  /// The columns of the grid.
  static const int columns = 6;

  final List<NavigatorQuestion> questions;

  /// Called with the chip's number when it is opened.
  final ValueChanged<int> onSelected;

  /// A key for the chip at `index`, for callers whose tests find chips.
  final Key? Function(int index)? chipKey;

  /// Scrolls the current question into view when the grid is built inside a
  /// scrolling sheet.
  final bool scrollCurrentIntoView;

  @override
  State<QuestionNavigatorGrid> createState() => _QuestionNavigatorGridState();
}

class _QuestionNavigatorGridState extends State<QuestionNavigatorGrid> {
  final List<FocusNode> _nodes = [];

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool _open(int i) => widget.questions[i].enabled;

  /// The chip Tab reaches: the current one, else the first open one.
  int? get _tabStop {
    final questions = widget.questions;
    final current = questions.indexWhere((q) => q.current && q.enabled);
    if (current >= 0) return current;
    final first = questions.indexWhere((q) => q.enabled);
    return first >= 0 ? first : null;
  }

  void _sync() {
    while (_nodes.length < widget.questions.length) {
      _nodes.add(FocusNode(debugLabel: 'Question ${_nodes.length + 1}'));
    }
    while (_nodes.length > widget.questions.length) {
      final surplus = _nodes.removeLast();
      WidgetsBinding.instance.addPostFrameCallback((_) => surplus.dispose());
    }
    final stop = _tabStop;
    for (var i = 0; i < _nodes.length; i++) {
      _nodes[i].skipTraversal = i != stop;
    }
  }

  /// The next open chip from [from] in steps of [delta], without wrapping.
  int? _step(int from, int delta) {
    var i = from + delta;
    while (i >= 0 && i < widget.questions.length) {
      if (_open(i)) return i;
      i += delta;
    }
    return null;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final keys = HardwareKeyboard.instance;
    if (keys.isControlPressed || keys.isAltPressed || keys.isMetaPressed) {
      return KeyEventResult.ignored;
    }
    final from = _nodes.indexWhere((n) => n.hasFocus);
    if (from < 0) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final int? target;
    if (key == LogicalKeyboardKey.arrowRight) {
      target = _step(from, 1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      target = _step(from, -1);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      target = _step(from, QuestionNavigatorGrid.columns);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      target = _step(from, -QuestionNavigatorGrid.columns);
    } else if (key == LogicalKeyboardKey.home) {
      target = _step(-1, 1);
    } else if (key == LogicalKeyboardKey.end) {
      target = _step(widget.questions.length, -1);
    } else {
      return KeyEventResult.ignored;
    }
    if (target != null && target != from) {
      final next = _nodes[target]..requestFocus();
      final context = next.context;
      if (context != null && Scrollable.maybeOf(context) != null) {
        Scrollable.ensureVisible(context);
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    _sync();
    final questions = widget.questions;
    const columns = QuestionNavigatorGrid.columns;
    final rows = (questions.length / columns).ceil();
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: Semantics(
        role: SemanticsRole.table,
        container: true,
        explicitChildNodes: true,
        // The grid is 264 wide: six 44 px areas. A column narrower than that
        // (the 300 px panel with its padding) lets the 4 px of touch area
        // beside the outer chips hang over the edge.
        child: SizedBox(
          height: rows * PantasSize.targetTouch,
          child: OverflowBox(
            minWidth: columns * PantasSize.targetTouch,
            maxWidth: columns * PantasSize.targetTouch,
            child: Column(
              children: [
                for (var r = 0; r < rows; r++)
                  Semantics(
                    role: SemanticsRole.row,
                    container: true,
                    explicitChildNodes: true,
                    child: Row(
                      children: [
                        for (var c = 0; c < columns; c++)
                          if (r * columns + c < questions.length)
                            _Cell(
                              key: ValueKey(
                                'navigator-cell-${r * columns + c}',
                              ),
                              question: questions[r * columns + c],
                              chipKey: widget.chipKey?.call(r * columns + c),
                              focusNode: _nodes[r * columns + c],
                              scrollIntoView: widget.scrollCurrentIntoView,
                              onTap: () => widget.onSelected(
                                questions[r * columns + c].number,
                              ),
                            )
                          else
                            const SizedBox(
                              width: PantasSize.targetTouch,
                              height: PantasSize.targetTouch,
                            ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One chip in its 44 px touch area. The area takes the tap, so the 4 px
/// around the chip open it too, and the 8 px between chips are the gap.
class _Cell extends StatefulWidget {
  const _Cell({
    required this.question,
    required this.focusNode,
    required this.onTap,
    required this.scrollIntoView,
    this.chipKey,
    super.key,
  });

  final NavigatorQuestion question;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final bool scrollIntoView;
  final Key? chipKey;

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  @override
  void initState() {
    super.initState();
    if (widget.question.current && widget.scrollIntoView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Scrollable.maybeOf(context) != null) {
          Scrollable.ensureVisible(context, alignment: .5);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Semantics(
      role: SemanticsRole.cell,
      container: true,
      explicitChildNodes: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: q.enabled ? widget.onTap : null,
        child: SizedBox.square(
          dimension: PantasSize.targetTouch,
          child: Padding(
            padding: const EdgeInsets.all(PantasSpace.s4),
            child: QuestionNavigatorChip(
              key: widget.chipKey,
              number: q.number,
              name: q.name,
              enabled: q.enabled,
              answered: q.answered,
              current: q.current,
              flagged: q.flagged,
              focusNode: widget.focusNode,
              onTap: widget.onTap,
            ),
          ),
        ),
      ),
    );
  }
}
