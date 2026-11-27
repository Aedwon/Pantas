import 'check.dart';
import 'lesson_size_check.dart';

final _frontmatterPattern = RegExp(r'^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)');
final _commentPattern = RegExp(r'<!--[\s\S]*?-->');
final _blockPattern = RegExp('^:::[a-z]', multiLine: true);
final _checkOpenPattern = RegExp(r'^:::check(?:\s|$)');
const _checkLineMarker = '**Check:**';

/// Checks one lesson against the slim walk-through format (Nov 27 spec
/// revision): at most one `:::check` block, and no `**Check:**` line anywhere
/// in the body (examples, `:::answer` bodies, anywhere). One violation per
/// problem, at the line of the extra block or of the Check line. A lesson with
/// no `:::` block is not a walk-through lesson and is skipped. [sourceId] is
/// the lesson id or path.
List<Violation> checkWalkthroughSlimFormat(String sourceId, String markdown) {
  final fm = _frontmatterPattern.firstMatch(markdown);
  final blanked = markdown.replaceAllMapped(
    _commentPattern,
    (m) => m.group(0)!.replaceAll(RegExp(r'[^\n]'), ' '),
  );
  final bodyStart = fm?.end ?? 0;
  final body = blanked.substring(bodyStart);
  if (!_blockPattern.hasMatch(body)) return const [];

  final lineOffset = '\n'.allMatches(blanked.substring(0, bodyStart)).length;
  final found = <Violation>[];
  var checks = 0;
  final lines = body.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].replaceAll('\r', '').trim();
    final line = i + 1 + lineOffset;
    if (_checkOpenPattern.hasMatch(trimmed)) {
      checks++;
      if (checks > 1) {
        found.add(
          Violation(
            '$sourceId:$line',
            'more than one :::check block (this is check $checks); a '
                'lesson has one Quick Check',
          ),
        );
      }
    } else if (trimmed.contains(_checkLineMarker)) {
      found.add(
        Violation(
          '$sourceId:$line',
          'has a **Check:** line; the slim format dropped the per-example '
              'Check line',
        ),
      );
    }
  }
  return found;
}

/// Runs the slim-format check across all active walk-through lessons.
List<Violation> runWalkthroughSlimFormatCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    for (final lesson
        in readCheckLessons(contentRoot).where((lesson) => lesson.active)) {
      found.addAll(checkWalkthroughSlimFormat(lesson.id, lesson.body));
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughSlimFormatCheck extends Check {
  const WalkthroughSlimFormatCheck();

  @override
  String get name => 'walkthrough-slim-format';

  @override
  String get origin =>
      'Nov 27 spec revision: one Quick Check per lesson (rule 6) and the '
      'per-example **Check:** line dropped (rule 7), so a lesson with '
      'several :::check blocks or any Check line is the old format';

  @override
  List<Violation> run(String root) =>
      runWalkthroughSlimFormatCheck('$root/content');
}
