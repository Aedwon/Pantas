import 'package:pantas/core/storage/data/repos/quiz_nudge_repository.dart';

class DismissQuizNudge {
  DismissQuizNudge(this._nudge);

  final QuizNudgeRepository _nudge;

  Future<void> call() => _nudge.markDismissed();
}
