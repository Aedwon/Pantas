import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pantas/core/time/date_entry_validator.dart';

/// Focus and keys for a month's grid of day cells (DatePicker README,
/// Keyboard), shared by every wide date grid.
///
/// Left and Right move one day, Up and Down one week, Home and End go to the
/// first and last allowed day. Keys only move focus and stay inside the month
/// shown; Enter or Space on a cell chooses it. One cell is in the Tab order.
///
/// Each day has a [FocusNode], [nodeFor]. A cell either hands its node to the
/// control that takes focus, or wraps the control in a `Focus` that owns the
/// node (`canRequestFocus: false`, `descendantsAreTraversable` from
/// [isTabStop]); both work. Own one of these in a `State` and call [dispose].
class DateGridFocus {
  final List<FocusNode> _nodes = [
    for (var day = 1; day <= 31; day++)
      FocusNode(debugLabel: 'calendar day $day'),
  ];

  FocusNode nodeFor(int day) => _nodes[day - 1];

  /// Whether [day] is the cell Tab reaches. Set by [setTabStop].
  bool isTabStop(int day) => _tabStop == day;
  int? _tabStop;

  /// Makes [day] (or none) the one cell Tab reaches.
  void setTabStop(int? day) {
    _tabStop = day;
    for (var d = 1; d <= 31; d++) {
      _nodes[d - 1].skipTraversal = d != day;
    }
  }

  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
  }

  /// The first day of the month that may be chosen, or null.
  static int? firstAllowedDay(
    int year,
    int month, {
    required DateTime firstAllowed,
    DateTime? lastAllowed,
  }) {
    final last = DateTime(year, month + 1, 0).day;
    for (var day = 1; day <= last; day++) {
      if (DateEntryValidator.isAllowed(
        DateTime(year, month, day),
        firstAllowed: firstAllowed,
        lastAllowed: lastAllowed,
      )) {
        return day;
      }
    }
    return null;
  }

  void _focus(int day) {
    final node = _nodes[day - 1];
    if (node.canRequestFocus) {
      node.requestFocus();
      return;
    }
    for (final inner in node.descendants) {
      if (inner.canRequestFocus) {
        inner.requestFocus();
        return;
      }
    }
  }

  /// Handles a key on the grid of [year] and [month]. Returns ignored when the
  /// key is not a grid key or no cell has focus.
  KeyEventResult onKey(
    KeyEvent event, {
    required int year,
    required int month,
    required DateTime firstAllowed,
    DateTime? lastAllowed,
  }) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final keys = HardwareKeyboard.instance;
    if (keys.isControlPressed || keys.isAltPressed || keys.isMetaPressed) {
      return KeyEventResult.ignored;
    }
    final last = DateTime(year, month + 1, 0).day;
    var from = 0;
    for (var day = 1; day <= last; day++) {
      if (_nodes[day - 1].hasFocus) from = day;
    }
    if (from == 0) return KeyEventResult.ignored;
    bool allowed(int day) => DateEntryValidator.isAllowed(
          DateTime(year, month, day),
          firstAllowed: firstAllowed,
          lastAllowed: lastAllowed,
        );
    final first = firstAllowedDay(
      year,
      month,
      firstAllowed: firstAllowed,
      lastAllowed: lastAllowed,
    );
    if (first == null) return KeyEventResult.ignored;
    var end = last;
    while (end > first && !allowed(end)) {
      end--;
    }
    final key = event.logicalKey;
    final int target;
    if (key == LogicalKeyboardKey.arrowLeft) {
      target = from - 1;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      target = from + 1;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      target = from - DateTime.daysPerWeek;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      target = from + DateTime.daysPerWeek;
    } else if (key == LogicalKeyboardKey.home) {
      target = first;
    } else if (key == LogicalKeyboardKey.end) {
      target = end;
    } else {
      return KeyEventResult.ignored;
    }
    if (target >= first && target <= end && target != from) _focus(target);
    return KeyEventResult.handled;
  }
}
