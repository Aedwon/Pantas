// No screen may show a lesson's typed-in minutes, or its part label.
//
// Every lesson used to carry a hand-typed "N min" (8 to 15). They were guesses,
// and a lesson split into parts makes them wrong, so nothing under a
// presentation folder may read `estimatedMinutes` or the summed
// `minutesLeftToRead`.
//
// The Nov 14 2026 ruling put "Part 2 of 9 · 3 questions" where the minutes
// were. Aedwon removed it on Nov 23 2026 ("the labels are unnecessary
// information that the user does not need to know ... it just adds noise").
// The part data stays in the models; no lesson, Home or reader screen may build
// the label or its shortened forms again. Mock exam parts ("Part 2 of 4") are
// a different thing and are not checked.
import 'check.dart';

/// Files that read a different `estimatedMinutes`. Key: path.
const _accepted = <String, String>{
  'lib/features/quiz/presentation/practice_picker_screen.dart':
      'PracticeSummary.estimatedMinutes is the length of a practice session '
          'the student sets, not a lesson',
};

final _minutes = RegExp(r'\b(estimatedMinutes|minutesLeftToRead)\b');

class LessonMinutesOnScreenCheck extends Check {
  const LessonMinutesOnScreenCheck();

  @override
  String get name => 'lesson-minutes-on-screen';

  @override
  String get origin =>
      'Nov 14 2026 bite-sized lessons: typed-in lesson minutes are gone from '
      'every screen. Nov 23 2026: the "Part X of Y · N questions" label that '
      'replaced them is gone too';

  @override
  List<Violation> run(String root) => [
        for (final entry in libSources(root).entries) ...[
          ...findLessonMinutesOnScreen(entry.key, entry.value),
          ...findPartLabelOnScreen(entry.key, entry.value),
        ],
      ];
}

List<Violation> findLessonMinutesOnScreen(String path, String source) {
  if (!path.contains('/presentation/')) return const [];
  final code = withoutLineComments(source);
  return [
    for (final match in _minutes.allMatches(code))
      Violation(
        '$path:${lineAt(code, match.start)}',
        'reads ${match.group(0)}; lesson rows show no minutes and no label',
        acceptedBecause: _accepted[path],
      ),
  ];
}

/// Builders of the old label. Any use, anywhere in lib, fails.
final _labelBuilder = RegExp(
  r'\b(LessonBiteLabel|LessonLabelLines|biteLabelText)\b',
);

/// A string that spells the label: "Part $part of $partCount", or a count
/// joined to a lesson line ("· $n questions"). Only checked where lessons are
/// shown, because the mock exam has its own "Part 2 of 4".
final _labelText = RegExp(
  r'Part \$\{?[\w.]+\}?\s*of\b|·\s*\$\{?[\w.]+\}?\s*questions?\b'
  r"|'\$\{?[\w.]+\}?\s+questions'",
);

bool _showsLessons(String path) =>
    path.contains('/presentation/') &&
    (path.contains('/features/lesson/') || path.contains('/features/home/'));

List<Violation> findPartLabelOnScreen(String path, String source) {
  final code = withoutLineComments(source);
  return [
    for (final match in _labelBuilder.allMatches(code))
      Violation(
        '$path:${lineAt(code, match.start)}',
        'uses ${match.group(0)}; the "Part X of Y · N questions" label is '
            'removed from every screen (Aedwon, Nov 23 2026)',
      ),
    if (_showsLessons(path))
      for (final match in _labelText.allMatches(code))
        Violation(
          '$path:${lineAt(code, match.start)}',
          'builds the part label text (${match.group(0)}); lesson screens '
              'show no part or question count',
        ),
  ];
}
