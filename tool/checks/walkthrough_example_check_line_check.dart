import 'check.dart';
import 'lesson_size_check.dart';

final _frontmatterPattern = RegExp(r'^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)');
final _commentPattern = RegExp(r'<!--[\s\S]*?-->');
final _blockPattern = RegExp('^:::[a-z]', multiLine: true);
final _checkLinePattern = RegExp(r'^\*\*Check:\*\*');

/// One `###` example under `## Examples`.
class _Example {
  _Example(this.heading, this.line);
  final String heading;
  final int line;
  bool hasTry = false;
  bool checkInAnswer = false;
  bool checkOutsideAnswer = false;
}

/// Checks one lesson: every `###` example under `## Examples` ends with a
/// `**Check:**` line, and in an example with a `:::try` that line sits inside
/// the try's `:::answer`, so nothing below the closed card gives the answer
/// away. [sourceId] is the lesson id or path.
List<Violation> checkWalkthroughExampleCheckLines(
  String sourceId,
  String markdown,
) {
  final fm = _frontmatterPattern.firstMatch(markdown);
  final blanked = markdown.replaceAllMapped(
    _commentPattern,
    (m) => m.group(0)!.replaceAll(RegExp(r'[^\n]'), ' '),
  );
  final bodyStart = fm?.end ?? 0;
  final body = blanked.substring(bodyStart);
  if (!_blockPattern.hasMatch(body)) return const [];

  final lineOffset = '\n'.allMatches(blanked.substring(0, bodyStart)).length;
  final lines = body.split('\n');
  final examples = <_Example>[];
  var inExamples = false;
  _Example? current;
  var fence = ''; // '', 'try' (stem), 'answer' (inside a try's answer), other
  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].replaceAll('\r', '').trim();
    if (trimmed.startsWith(':::')) {
      if (trimmed == ':::') {
        fence = '';
      } else if (trimmed == ':::answer') {
        fence = fence == 'try' ? 'answer' : 'other-answer';
      } else {
        fence = trimmed.substring(3).split(RegExp(r'\s')).first;
        if (fence == 'try') current?.hasTry = true;
      }
      continue;
    }
    if (fence.isNotEmpty) {
      if (fence == 'answer' && _checkLinePattern.hasMatch(trimmed)) {
        current?.checkInAnswer = true;
      }
      continue;
    }
    if (trimmed.startsWith('## ')) {
      inExamples = RegExp(r'^##\s+Examples\s*$').hasMatch(trimmed);
      current = null;
    } else if (inExamples && trimmed.startsWith('### ')) {
      current = _Example(trimmed.substring(4).trim(), i + 1 + lineOffset);
      examples.add(current);
    } else if (current != null && _checkLinePattern.hasMatch(trimmed)) {
      current.checkOutsideAnswer = true;
    }
  }

  final found = <Violation>[];
  for (final example in examples) {
    String? problem;
    if (example.hasTry) {
      if (!example.checkInAnswer) {
        problem = example.checkOutsideAnswer
            ? 'has a :::try, but its **Check:** sits outside the '
                ':::answer, below the closed card; move it inside the answer'
            : 'has a :::try but no **Check:** line inside its :::answer';
      }
    } else if (!example.checkOutsideAnswer) {
      problem = 'no **Check:** line';
    }
    if (problem != null) {
      found.add(
        Violation(
          '$sourceId:${example.line}',
          'example "${example.heading}": $problem',
        ),
      );
    }
  }
  return found;
}

/// Runs the example Check-line check across all active walk-through lessons.
List<Violation> runWalkthroughExampleCheckLineCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    for (final lesson
        in readCheckLessons(contentRoot).where((lesson) => lesson.active)) {
      found.addAll(
        checkWalkthroughExampleCheckLines(lesson.id, lesson.body),
      );
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughExampleCheckLineCheck extends Check {
  const WalkthroughExampleCheckLineCheck();

  @override
  String get name => 'walkthrough-example-check-line';

  @override
  String get origin =>
      'Nov 27 Codex audit: 29 Grammar worked examples had no **Check:** '
      'line, cut by workers to save words; the standard requires one on '
      'every example, inside the hidden answer for a :::try';

  @override
  List<Violation> run(String root) =>
      runWalkthroughExampleCheckLineCheck('$root/content');
}
