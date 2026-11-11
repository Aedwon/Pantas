import 'package:flutter/services.dart';

/// The typeahead rule shared by Select and Popover (design system Popover,
/// Keyboard): typing letters jumps to the item whose label starts with them.
///
/// Letters typed within [window] of each other build one prefix. A longer
/// pause starts a new one. This is a text-entry aid inside an open list, so
/// it is not gated by the letter-shortcuts setting.
class TypeaheadBuffer {
  /// How long a pause may be before the next letter starts a new prefix. It
  /// is a typing allowance, not a design value.
  static const Duration window = Duration(milliseconds: 1000);

  String _text = '';
  DateTime _at = DateTime.fromMillisecondsSinceEpoch(0);

  /// The prefix typed so far.
  String get text => _text;

  /// Whether [event] is a typed character that typeahead should take: a key
  /// down that carries a visible character. This is the one place typeahead
  /// reads an event's character.
  static bool accepts(KeyEvent event) =>
      event is KeyDownEvent &&
      event.character != null &&
      event.character!.trim().isNotEmpty;

  /// [search] for the character of an [accepts]ed [event].
  int? searchEvent(KeyEvent event, List<String> labels, {DateTime? now}) =>
      search(event.character!, labels, now: now);

  /// Adds [character] and returns the index of the first label that starts
  /// with the prefix (ignoring case), or null when none does. [now] is for
  /// tests.
  int? search(String character, List<String> labels, {DateTime? now}) {
    final time = now ?? DateTime.now();
    _text = time.difference(_at) > window ? character : _text + character;
    _at = time;
    final prefix = _text.toLowerCase();
    for (var i = 0; i < labels.length; i++) {
      if (labels[i].toLowerCase().startsWith(prefix)) return i;
    }
    return null;
  }

  void reset() {
    _text = '';
    _at = DateTime.fromMillisecondsSinceEpoch(0);
  }
}
