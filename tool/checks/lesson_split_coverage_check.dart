import 'check.dart';
import 'lesson_size_check.dart';

String _visible(String value) =>
    value.replaceAll(RegExp(r'<!--[\s\S]*?-->'), ' ');

String _normalize(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();

final _walkthroughMarker = RegExp(
  r'^[ \t]*:::(?:check|try|why|pair|checklist)(?:\s|$)',
  multiLine: true,
);

// Parts restart numbering. Only headings lose that number; bodies stay exact.
String _renumbered(String value) => value.replaceAllMapped(
      RegExp(r'^(###\s+)#\d+:\s+', multiLine: true),
      (m) => m.group(1)!,
    );

List<CheckLesson> _resolveReplacements(
  Map<String, CheckLesson> byId,
  CheckLesson root,
) {
  final parts = <CheckLesson>[];
  final added = <String>{};
  final visited = <String>{root.id};

  void walk(CheckLesson current) {
    for (final id in current.replacements) {
      final target = byId[id];
      if (target == null) continue;
      if (target.active) {
        if (added.add(target.id)) parts.add(target);
        continue;
      }
      if (!visited.add(id)) continue;
      if (target.replacements.isEmpty) {
        if (added.add(target.id)) parts.add(target);
        continue;
      }
      walk(target);
    }
  }

  walk(root);
  return parts;
}

List<Violation> runLessonSplitCoverageCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    final lessons = readCheckLessons(contentRoot);
    final byId = {for (final lesson in lessons) lesson.id: lesson};
    for (final lesson in lessons.where((lesson) => !lesson.active)) {
      final parts = _resolveReplacements(byId, lesson);
      final activeParts = parts.where((part) => part.active).toList();
      final isWalkthrough = activeParts.any(
        (part) => _walkthroughMarker.hasMatch(_visible(part.body)),
      );
      final visible = _visible(lesson.body);
      final exact = isWalkthrough
          ? const <String>[]
          : <String>[
              ...lessonSectionItems(visible, 'Examples'),
              ...lessonSectionItems(visible, 'Traps to Watch For'),
            ];
      final figures = <String>[
        ...RegExp(r'<!--\s*FIGURE\b[\s\S]*?-->')
            .allMatches(lesson.body)
            .map((m) => m.group(0)!),
      ];
      final repeatable = isWalkthrough
          ? const <String>[]
          : <String>[
              ...RegExp(r'\$\$[\s\S]*?\$\$')
                  .allMatches(visible)
                  .map((m) => m.group(0)!),
              ...RegExp(r'\*\*[\s\S]*?\*\*')
                  .allMatches(visible)
                  .map((m) => m.group(0)!),
            ];
      final targetParts = isWalkthrough ? activeParts : parts;
      for (final item in {...exact, ...repeatable, ...figures}) {
        final normalized =
            _normalize(exact.contains(item) ? _renumbered(item) : item);
        final count = targetParts.fold<int>(0, (count, part) {
          if (exact.contains(item)) {
            final body = _visible(part.body);
            return count +
                [
                  ...lessonSectionItems(body, 'Examples'),
                  ...lessonSectionItems(body, 'Traps to Watch For'),
                ]
                    .where(
                      (candidate) =>
                          _normalize(_renumbered(candidate)) == normalized,
                    )
                    .length;
          }
          return count +
              RegExp(RegExp.escape(normalized))
                  .allMatches(
                    _normalize(
                      figures.contains(item) ? part.body : _visible(part.body),
                    ),
                  )
                  .length;
        });
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
