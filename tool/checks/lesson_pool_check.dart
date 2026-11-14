import '../../tools/build_content_export/build_content_export.dart'
    show lessonQuizSize;
import '../content/content_gate.dart';
import '../content/question_hash.dart';
import '../content/shipping_questions.dart';
import 'check.dart';
import 'lesson_size_check.dart';

List<Violation> runLessonPoolCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    final lessons = readCheckLessons(contentRoot);
    final targets = lessons
        .where((lesson) => lesson.active && lesson.front['keyPoints'] != null)
        .toList();
    if (targets.isEmpty) return found;
    final byId = {for (final lesson in lessons) lesson.id: lesson};
    final failing = runContentGate(contentRoot).map((f) => f.id).toSet();
    // A damaged ledger or root cannot supply a gate-passing question.
    final gateValid =
        !failing.contains('legacy.json') && !failing.contains('content');
    final questions = allQuestionsForApproval(contentRoot);
    final shipping = shippingQuestions(contentRoot).map((q) => q.id).toSet();
    String resolve(String initialId) {
      var id = initialId;
      final seen = <String>{};
      while (byId[id]?.active == false) {
        if (!seen.add(id)) throw FormatException('replacedBy cycle at $id');
        final replacements = byId[id]!.replacements;
        if (replacements.isEmpty) {
          throw FormatException('retired lesson $id replaces nothing');
        }
        id = replacements.first;
      }
      return id;
    }

    for (final lesson in targets) {
      final relevant = questions
          .where(
            (q) => resolve(questionLesson(q.question, q.meta)) == lesson.id,
          )
          .toList();
      final exams = {
        for (final q in relevant) ...(q.meta['exams'] as List).cast<String>(),
      };
      final keys = (lesson.front['keyPoints'] as List).length;
      final size = lessonQuizSize(lesson.front, lesson.body);
      for (final exam in exams) {
        final pool = relevant
            .where(
              (q) =>
                  gateValid &&
                  shipping.contains(q.id) &&
                  !failing.contains(q.id) &&
                  (q.meta['exams'] as List).contains(exam),
            )
            .toList();
        for (var key = 1; key <= keys; key++) {
          if (!pool.any((q) => q.question['keyPoint'] == key)) {
            found.add(
              Violation(
                lesson.id,
                '$exam: key point $key has no shipping, gate-passing question',
              ),
            );
          }
        }
        if (pool.length < size) {
          found.add(
            Violation(
              lesson.id,
              '$exam: pool ${pool.length} is below quizSize $size',
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

class LessonPoolCheck extends Check {
  const LessonPoolCheck();
  @override
  String get name => 'lesson-pool';
  @override
  String get origin => 'Bite-sized lessons B3, per-exam pool';
  @override
  List<Violation> run(String root) => runLessonPoolCheck('$root/content');
}
