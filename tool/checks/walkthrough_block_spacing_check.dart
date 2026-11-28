import 'check.dart';
import 'lesson_size_check.dart';

/// A heading or a list item written on the line directly under a paragraph
/// line, with no blank line between them. Nov 27 walk-through lane: worker
/// edits removed the blank line between blocks, and verifiers found a
/// `## Traps to Watch For` heading under a paragraph line, lists under a
/// sentence, and a paragraph line under another paragraph.
///
/// What the converters do (`lesson_markdown.dart` and
/// `markdown_portable_text.dart`): they trim every line and join a
/// paragraph's consecutive lines with one space. A heading or a list item
/// line ends the open paragraph at once, so
/// those two shapes still render as a heading and a list. The same joining
/// does merge a glued paragraph line into the paragraph above it, which a
/// line check cannot tell from a wrapped sentence. This check therefore
/// enforces the blank-line rule in the source, so a lost blank line is caught
/// where the heading or list sits, before a neighbouring paragraph merges.
final _heading = RegExp(r'^#{1,6}\s+\S');
final _listItem = RegExp(r'^\s*(?:[-*+]|\d+\.)\s+\S');
final _codeFence = RegExp(r'^\s*(?:```|~~~)');

/// Lines the converters handle on their own: walk-through fences, tables,
/// quotes, display maths and comments are not paragraph prose.
final _ownLine = RegExp(r'^\s*(?::::|\||>|\$\$|<!--)');

/// Finds headings and list items glued to a paragraph line in one lesson
/// body. [where] is the lesson id.
List<Violation> checkWalkthroughBlockSpacing(String where, String body) {
  final lines = body.split('\n').map((l) => l.replaceAll('\r', '')).toList();
  final found = <Violation>[];
  var inCode = false;
  // True from a list item until a blank line, a heading or a fence: a line in
  // between that is not an item is that item's wrapped continuation.
  var inList = false;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (_codeFence.hasMatch(line)) {
      inCode = !inCode;
      inList = false;
      continue;
    }
    if (inCode) continue;
    final isHeading = _heading.hasMatch(line);
    final isItem = !isHeading && _listItem.hasMatch(line);
    if ((isHeading || isItem) && i > 0 && !inList) {
      final above = lines[i - 1];
      if (above.trim().isNotEmpty &&
          !_heading.hasMatch(above) &&
          !_listItem.hasMatch(above) &&
          !_ownLine.hasMatch(above) &&
          !above.trimRight().endsWith(r'$$') &&
          !_codeFence.hasMatch(above)) {
        found.add(
          Violation(
            '$where:${i + 1}',
            '${isHeading ? 'heading' : 'list item'} sits directly under a '
                'paragraph line; put a blank line above it: "${line.trim()}"',
          ),
        );
      }
    }
    if (line.trim().isEmpty || isHeading || _ownLine.hasMatch(line)) {
      inList = false;
    } else if (isItem) {
      inList = true;
    }
  }
  return found;
}

/// Runs the block-spacing check across active walk-through lessons (those
/// with a `:::check` or `:::try` block).
List<Violation> runWalkthroughBlockSpacingCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    for (final lesson
        in readCheckLessons(contentRoot).where((lesson) => lesson.active)) {
      if (!RegExp(r'^:::(?:check|try)(?:\s|$)', multiLine: true)
          .hasMatch(lesson.body)) {
        continue;
      }
      found.addAll(checkWalkthroughBlockSpacing(lesson.id, lesson.body));
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughBlockSpacingCheck extends Check {
  const WalkthroughBlockSpacingCheck();

  @override
  String get name => 'walkthrough-block-spacing';

  @override
  String get origin =>
      'Nov 27 walk-through lane: worker edits removed the blank line between '
      'blocks, leaving a heading or a list glued under a paragraph line';

  @override
  List<Violation> run(String root) =>
      runWalkthroughBlockSpacingCheck('$root/content');
}
