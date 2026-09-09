import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';
import 'package:pantas/features/quiz/domain/picker/today_topic_picker.dart';

class TodayInterleavedPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    final requested = context.requestedLength;
    if (requested <= 0) return const [];
    final topicId = context.topicId;
    if (topicId == null) {
      return TodayTopicPicker().pick(context);
    }

    final selectedTopicTarget = ((requested * 7) + 5) ~/ 10;
    final elsewhereTarget = requested - selectedTopicTarget;

    final selected = TodayTopicPicker().pick(
      _scoped(context, requestedLength: selectedTopicTarget, inside: true),
    );
    final elsewhere = TodayTopicPicker().pick(
      _scoped(context, requestedLength: elsewhereTarget, inside: false),
    );

    final used = <String>{
      for (final question in selected) question.id,
      for (final question in elsewhere) question.id,
    };
    final remaining = requested - selected.length - elsewhere.length;
    if (remaining <= 0) return [...selected, ...elsewhere];

    final fallback = TodayTopicPicker().pick(
      PickContext(
        allQuestions: _unused(context.allQuestions, used),
        dueQuestions: _unused(context.dueQuestions, used),
        weaknessQuestions: _unused(context.weaknessQuestions, used),
        newQuestions: _unused(context.newQuestions, used),
        requestedLength: remaining,
      ),
    );
    return [...selected, ...elsewhere, ...fallback];
  }
}

PickContext _scoped(
  PickContext context, {
  required int requestedLength,
  required bool inside,
}) {
  final topicId = context.topicId!;
  List<Question> filter(List<Question> questions) => questions
      .where((question) => (question.topicId == topicId) == inside)
      .toList();

  return PickContext(
    allQuestions: filter(context.allQuestions),
    dueQuestions: filter(context.dueQuestions),
    weaknessQuestions: filter(context.weaknessQuestions),
    newQuestions: filter(context.newQuestions),
    requestedLength: requestedLength,
  );
}

List<Question> _unused(List<Question> questions, Set<String> used) =>
    questions.where((question) => !used.contains(question.id)).toList();
