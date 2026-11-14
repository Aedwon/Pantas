// No screen may show a lesson's typed-in minutes.
//
// Every lesson used to carry a hand-typed "N min" (8 to 15). They were guesses,
// and a lesson split into parts makes them wrong. The bite-sized label ruling
// (Nov 14 2026) replaced them with "Part 2 of 9 · 3 questions" everywhere, so
// nothing under a presentation folder may read `estimatedMinutes` or the
// summed `minutesLeftToRead`.
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
      'Nov 14 2026 bite-sized lessons: typed-in lesson minutes are replaced '
      'by the part and question label on every screen';

  @override
  List<Violation> run(String root) => [
        for (final entry in libSources(root).entries)
          ...findLessonMinutesOnScreen(entry.key, entry.value),
      ];
}

List<Violation> findLessonMinutesOnScreen(String path, String source) {
  if (!path.contains('/presentation/')) return const [];
  final code = withoutLineComments(source);
  return [
    for (final match in _minutes.allMatches(code))
      Violation(
        '$path:${lineAt(code, match.start)}',
        'reads ${match.group(0)}; show the lesson label instead '
            '(LessonBiteLabel)',
        acceptedBecause: _accepted[path],
      ),
  ];
}
