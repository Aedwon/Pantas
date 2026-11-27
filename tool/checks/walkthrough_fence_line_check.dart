import 'check.dart';
import 'lesson_size_check.dart';

/// A closing `:::` written at the end of a text line instead of on its own
/// line. The walk-through parser only sees a fence on its own line, so the
/// block stays open: the next block nests inside it (a parse failure), or,
/// at the end of an answer, the following text is swallowed into the hidden
/// answer without any error.
final _gluedFence = RegExp(r'\S.*:::\s*$');

/// Finds glued closing fences in one lesson body. [where] is the lesson id.
List<Violation> checkWalkthroughFenceLines(String where, String body) {
  final found = <Violation>[];
  final lines = body.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].replaceAll('\r', '');
    if (line.trimLeft().startsWith(':::')) continue;
    if (_gluedFence.hasMatch(line)) {
      found.add(
        Violation(
          '$where:${i + 1}',
          'closing ::: must be on its own line, or the block never closes: '
              '"${line.trim()}"',
        ),
      );
    }
  }
  return found;
}

/// Runs the fence-line check across active walk-through lessons.
List<Violation> runWalkthroughFenceLineCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    for (final lesson
        in readCheckLessons(contentRoot).where((lesson) => lesson.active)) {
      if (!lesson.body.contains(':::')) continue;
      found.addAll(checkWalkthroughFenceLines(lesson.id, lesson.body));
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class WalkthroughFenceLineCheck extends Check {
  const WalkthroughFenceLineCheck();

  @override
  String get name => 'walkthrough-fence-line';

  @override
  String get origin =>
      'Nov 26 walk-through lane: fixers glued a closing ::: to the end of a '
      'text line four times; one left a hidden answer open with no parse error';

  @override
  List<Violation> run(String root) =>
      runWalkthroughFenceLineCheck('$root/content');
}
