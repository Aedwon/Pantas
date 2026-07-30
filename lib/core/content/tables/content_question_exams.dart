import 'package:drift/drift.dart';
import 'package:pantas/core/content/tables/content_exams.dart';
import 'package:pantas/core/content/tables/content_questions.dart';

@DataClassName('ContentQuestionExamRow')
class ContentQuestionExams extends Table {
  TextColumn get questionId => text().references(ContentQuestions, #id)();
  TextColumn get examId => text().references(ContentExams, #id)();

  @override
  Set<Column<Object>> get primaryKey => {questionId, examId};
}
