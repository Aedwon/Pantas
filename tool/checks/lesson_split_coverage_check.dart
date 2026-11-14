import 'check.dart';
import 'lesson_size_check.dart';

String _visible(String value) =>
    value.replaceAll(RegExp(r'<!--[\s\S]*?-->'), ' ');

String _normalize(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();

List<Violation> runLessonSplitCoverageCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    final lessons = readCheckLessons(contentRoot);
    final byId = {for (final lesson in lessons) lesson.id: lesson};
    for (final lesson in lessons.where((lesson) => !lesson.active)) {
      final parts = [
        for (final id in lesson.replacements)
          if (byId[id] != null) byId[id]!,
      ];
      final visible = _visible(lesson.body);
      final exact = <String>[
        ...lessonSectionItems(visible, 'Examples'),
        ...lessonSectionItems(visible, 'Traps to Watch For'),
      ];
      final figures = <String>[
        ...RegExp(r'<!--\s*FIGURE\b[\s\S]*?-->')
            .allMatches(lesson.body)
            .map((m) => m.group(0)!),
      ];
      final repeatable = <String>[
        ...RegExp(r'\$\$[\s\S]*?\$\$')
            .allMatches(visible)
            .map((m) => m.group(0)!),
        ...RegExp(r'\*\*[\s\S]*?\*\*')
            .allMatches(visible)
            .map((m) => m.group(0)!),
      ];
      for (final item in {...exact, ...repeatable, ...figures}) {
        final normalized = _normalize(item);
        final count = parts.fold<int>(
          0,
          (count, part) =>
              count +
              RegExp(RegExp.escape(normalized))
                  .allMatches(
                    _normalize(
                      figures.contains(item) ? part.body : _visible(part.body),
                    ),
                  )
                  .length,
        );
        if (count == 0 ||
            ((exact.contains(item) || figures.contains(item)) && count != 1)) {
          final excerpt =
              normalized.length > 90 ? normalized.substring(0, 90) : normalized;
          found.add(
            Violation(
              lesson.id,
              '${count == 0 ? 'missing' : 'duplicated'}: $excerpt',
            ),
          );
        }
      }
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class LessonSplitCoverageCheck extends Check {
  const LessonSplitCoverageCheck();
  @override
  String get name => 'lesson-split-coverage';
  @override
  String get origin => 'Bite-sized lessons B6, nothing dropped';
  @override
  List<Violation> run(String root) =>
      runLessonSplitCoverageCheck('$root/content');
}
