import 'check.dart';
import 'lesson_size_check.dart';

/// The app converters' inline pattern, copied from
/// `tools/content/markdown_portable_text.dart` (`_inline`) and
/// `lib/core/content/remote/lesson_markdown.dart`: math, then `**bold**`,
/// then `*italic*`, matched left to right. Nested or triple stars
/// (`***word***`, `*a **b***`) do not survive it: a star is left on screen
/// or swallowed into the wrong span. Keep the two in step if the converter
/// changes.
final _inline = RegExp(r'\$([^$]+)\$|\*\*(.+?)\*\*|\*(.+?)\*');

final _bullet = RegExp(r'^\s*\*\s+');

/// Finds lines whose emphasis the converter would render with stray stars.
/// [where] is the lesson id.
List<Violation> checkWalkthroughEmphasis(String where, String body) {
  final found = <Violation>[];
  final lines = body.split('\n');
  var inMath = false;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].replaceAll('\r', '');
    final trimmed = line.trim();
    if (trimmed.startsWith(r'$$')) {
      final closes = trimmed.length > 2 && trimmed.endsWith(r'$$');
      if (!closes) inMath = !inMath;
      continue;
    }
    if (inMath || trimmed.startsWith('<!--') || trimmed.startsWith('|')) {
      continue;
    }
    final text = line.replaceFirst(_bullet, '');
    var bad = false;
    final rest = text.replaceAllMapped(_inline, (match) {
      if (match.group(1) != null) return ' ';
      final inner = match.group(2) ?? match.group(3)!;
      if (inner.contains('*')) bad = true;
      return ' ';
    });
    if (bad || rest.contains('*')) {
      found.add(
        Violation(
          '$where:${i + 1}',
          'emphasis the app cannot render: nested or unpaired stars show on '
              'screen; use one level, *italic* or **bold**: "$trimmed"',
        ),
      );
    }
  }
  return found;
}

/// Runs the emphasis check across active walk-through lessons (those with a
/// `:::check` or `:::try` block). Older lessons are not covered yet.
List<Violation> runWalkthroughEmphasisCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    for (final lesson
        in readCheckLessons(contentRoot).where((lesson) => lesson.active)) {
      if (!RegExp(r'^:::(?:check|try)(?:\s|$)', multiLine: true)
          .hasMatch(lesson.body)) {
        continue;
      }
      found.addAll(checkWalkthroughEmphasis(lesson.id, lesson.body));
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughEmphasisCheck extends Check {
  const WalkthroughEmphasisCheck();

  @override
  String get name => 'walkthrough-emphasis';

  @override
  String get origin =>
      'Nov 26 Fable audit of Language Application: bold nested in italics '
      '(*She **must register***) renders with stray stars in the app';

  @override
  List<Violation> run(String root) =>
      runWalkthroughEmphasisCheck('$root/content');
}
