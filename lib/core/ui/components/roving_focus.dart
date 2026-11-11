import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

/// Roving focus for a row of single-choice items (SegmentedControl and
/// WeekStrip READMEs, Keyboard): Tab reaches one item only, the arrow keys
/// move to the next item and choose it, Home and End choose the first and the
/// last.
///
/// [builder] receives one [FocusNode] per item. The item gives its node to
/// its focusable control (`InkWell.focusNode`, `TextButton.focusNode`). The
/// node of [tabStop] is the only one Tab visits; the others are reached by
/// the arrow keys or a click.
class RovingFocus extends StatefulWidget {
  const RovingFocus({
    required this.count,
    required this.tabStop,
    required this.onSelect,
    required this.builder,
    this.isEnabled,
    this.wrap = true,
    this.vertical = true,
    super.key,
  });

  /// How many items there are.
  final int count;

  /// The item Tab reaches: the selected one.
  final int tabStop;

  /// Called with the item the key chose, before focus moves to it.
  final ValueChanged<int> onSelect;

  /// Whether an item can be chosen. Disabled items are skipped. Null means
  /// every item is enabled.
  final bool Function(int index)? isEnabled;

  /// True when the arrow keys wrap from the last item to the first.
  final bool wrap;

  /// True when Up and Down also move, as Left and Right do.
  final bool vertical;

  final Widget Function(BuildContext context, List<FocusNode> nodes) builder;

  @override
  State<RovingFocus> createState() => _RovingFocusState();
}

class _RovingFocusState extends State<RovingFocus> {
  final List<FocusNode> _nodes = [];

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _sync() {
    while (_nodes.length < widget.count) {
      _nodes.add(FocusNode(debugLabel: 'RovingFocus ${_nodes.length}'));
    }
    while (_nodes.length > widget.count) {
      // The old child may still hold this node until this frame ends, so it
      // is disposed after the frame rather than during build.
      final surplus = _nodes.removeLast();
      WidgetsBinding.instance.addPostFrameCallback((_) => surplus.dispose());
    }
    for (var i = 0; i < _nodes.length; i++) {
      _nodes[i].skipTraversal = i != widget.tabStop;
    }
  }

  bool _enabled(int i) => widget.isEnabled?.call(i) ?? true;

  int? _step(int from, int delta) {
    var i = from;
    for (var n = 0; n < widget.count; n++) {
      i += delta;
      if (i < 0 || i >= widget.count) {
        if (!widget.wrap) return null;
        i = (i + widget.count) % widget.count;
      }
      if (_enabled(i)) return i;
    }
    return null;
  }

  int? _edge({required bool first}) {
    final order = [for (var i = 0; i < widget.count; i++) i];
    for (final i in first ? order : order.reversed) {
      if (_enabled(i)) return i;
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
    if (key == LogicalKeyboardKey.arrowRight ||
        (widget.vertical && key == LogicalKeyboardKey.arrowDown)) {
      target = _step(from, 1);
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        (widget.vertical && key == LogicalKeyboardKey.arrowUp)) {
      target = _step(from, -1);
    } else if (key == LogicalKeyboardKey.home) {
      target = _edge(first: true);
    } else if (key == LogicalKeyboardKey.end) {
      target = _edge(first: false);
    } else {
      return KeyEventResult.ignored;
    }
    if (target != null && target != from) {
      widget.onSelect(target);
      final next = _nodes[target]..requestFocus();
      _reveal(next);
    }
    return KeyEventResult.handled;
  }

  /// Scrolls the chosen item into view when the row scrolls sideways.
  void _reveal(FocusNode node) {
    final target = node.context;
    if (target == null || Scrollable.maybeOf(target) == null) return;
    final still = MediaQuery.disableAnimationsOf(context);
    unawaited(
      Scrollable.ensureVisible(
        target,
        duration: still ? Duration.zero : PantasDurations.short2,
        curve: PantasCurves.house,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _sync();
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: widget.builder(context, _nodes),
    );
  }
}
