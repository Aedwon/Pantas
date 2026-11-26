import 'check.dart';
import 'lesson_size_check.dart';

/// A line that ends in two or more spaces, followed by a non-blank line.
/// Markdown reads that as a hard line break, but both app converters
/// (`lesson_markdown.dart`, `markdown_portable_text.dart`) trim each line
/// and join a paragraph's lines with one space. So stacked answer options
/// written this way run together on one line on screen.
final _trailingBreak = RegExp(r' {2,}$');

/// Fences and other lines the converters handle line by line, where a
/// trailing space changes nothing.
final _ownLine = RegExp(r'^\s*(?::::|\||#|\$\$|<!--)');

/// Finds forced line breaks in one lesson body. [where] is the lesson id.
List<Violation> checkWalkthroughHardBreaks(String where, String body) {
  final lines = body.split('\n').map((l) => l.replaceAll('\r', '')).toList();
  final found = <Violation>[];
  for (var i = 0; i + 1 < lines.length; i++) {
    final line = lines[i];
    final next = lines[i + 1];
    if (!_trailingBreak.hasMatch(line) || line.trim().isEmpty) continue;
    if (next.trim().isEmpty ||
        _ownLine.hasMatch(line) ||
        _ownLine.hasMatch(next)) {
      continue;
    }
    found.add(
      Violation(
        '$where:${i + 1}',
        'line ends in two spaces to force a break, but the app joins a '
            "paragraph's lines, so it runs into the next line; put a blank "
            'line between them: "${line.trim()}"',
      ),
    );
  }
  return found;
}

/// Runs the hard-break check across active walk-through lessons (those with
/// a `:::check` or `:::try` block). Older lessons outside the walk-through
/// rewrite can have the same defect; this check does not cover them yet.
List<Violation> runWalkthroughHardBreakCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    for (final lesson
        in readCheckLessons(contentRoot).where((lesson) => lesson.active)) {
      if (!RegExp(r'^:::(?:check|try)(?:\s|$)', multiLine: true)
          .hasMatch(lesson.body)) {
        continue;
      }
      found.addAll(checkWalkthroughHardBreaks(lesson.id, lesson.body));
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughHardBreakCheck extends Check {
  const WalkthroughHardBreakCheck();

  @override
  String get name => 'walkthrough-hard-break';

  @override
  String get origin =>
      'Nov 26 walk-through lane: answer options stacked with two trailing '
      'spaces render as one run-on line, because the app joins paragraph lines';

  @override
  List<Violation> run(String root) =>
      runWalkthroughHardBreakCheck('$root/content');
}
