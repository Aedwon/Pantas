// Every question id fits every limit the app and server put on an id.
//
// Nov 22 2026, prod: question ids past 64 characters broke the analytics
// property check and with it the answer save, for 261 questions. The limits
// that apply to a question id today:
// - analytics event parameter value: 100 characters, letters, digits, _ and -
//   (kMaxPropertyIdentifierLength in lib/core/telemetry/telemetry.dart);
// - the server's answer ingest: 128 characters (functions/src/_answers.ts);
// - content ids: 160 characters, letters, digits, _, . and -
//   (functions/src/content.ts).
// The tightest is the analytics one, so it is the rule here. A test keeps the
// 100 below equal to the app's constant.
import 'check.dart';
import 'content_snapshot.dart';

const maxQuestionIdLength = 100;

final _idPattern = RegExp(r'^[A-Za-z0-9_-]+$');

class QuestionIdLimitsCheck extends Check {
  const QuestionIdLimitsCheck();

  @override
  String get name => 'question-id-limits';

  @override
  String get origin =>
      'Nov 22 2026 prod: question ids past 64 characters broke the answer '
      'save for 261 questions';

  @override
  List<Violation> run(String root) =>
      findQuestionIdsPastLimits(ContentSnapshot.load(root).questions);
}

List<Violation> findQuestionIdsPastLimits(Iterable<QuestionRow> questions) => [
      for (final question in questions)
        if (question.id.length > maxQuestionIdLength)
          Violation(
            question.id,
            'question id is ${question.id.length} characters; the limit is '
            '$maxQuestionIdLength',
          )
        else if (!_idPattern.hasMatch(question.id))
          Violation(
            question.id,
            'question id may use only letters, digits, _ and -',
          ),
    ];
