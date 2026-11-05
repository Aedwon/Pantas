// A lesson list must be scoped to the student's exam.
//
// A shared topic holds other exams' lessons. The repository leaves out lessons
// with no question for the exam only when a caller passes examId, so this
// guards the callers: on Nov 5 CSE Pro listed Mechanical, Clerical and ten
// Algebra lessons with no CSE questions, which also caused "Could not load
// your quiz".
import 'check.dart';

/// Callers that may read every exam's lessons. Key: path.
const _accepted = <String, String>{
  'lib/features/lesson/application/lesson_search_providers.dart':
      'keeps only lessons already in the exam-scoped study map',
};

final _call = RegExp(r'\.lessonsByTopics?\(');

class LessonListExamScopeCheck extends Check {
  const LessonListExamScopeCheck();

  @override
  String get name => 'lesson-list-exam-scope';

  @override
  String get origin =>
      'Nov 5 2026 CSE: Study listed lessons with no question for the exam, and '
      'their quiz could not load';

  @override
  List<Violation> run(String root) => [
        for (final entry in libSources(root).entries)
          ...findUnscopedLessonLists(entry.key, entry.value),
      ];
}

List<Violation> findUnscopedLessonLists(String path, String source) {
  final code = withoutLineComments(source);
  final violations = <Violation>[];
  for (final match in _call.allMatches(code)) {
    var depth = 1;
    var at = match.end;
    while (at < code.length && depth > 0) {
      if (code[at] == '(') depth++;
      if (code[at] == ')') depth--;
      at++;
    }
    if (code.substring(match.end, at).contains('examId:')) continue;
    violations.add(
      Violation(
        '$path:${lineAt(code, match.start)}',
        "lists lessons without examId, so other exams' lessons can show",
        acceptedBecause: _accepted[path],
      ),
    );
  }
  return violations;
}
