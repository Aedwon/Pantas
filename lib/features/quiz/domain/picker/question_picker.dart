import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';

// ignore: one_member_abstracts
abstract interface class QuestionPicker {
  List<Question> pick(PickContext context);
}
