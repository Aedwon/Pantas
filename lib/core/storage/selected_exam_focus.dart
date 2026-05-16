import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveExamFocus {
  const ActiveExamFocus._({
    required this.exam,
    required this.needsSelection,
  });

  const ActiveExamFocus.selected(Exam exam)
      : this._(exam: exam, needsSelection: false);

  const ActiveExamFocus.needsSelection()
      : this._(exam: null, needsSelection: true);

  final Exam? exam;
  final bool needsSelection;
}

final activeExamFocusProvider = FutureProvider<ActiveExamFocus>((ref) async {
  final exams = await ref.watch(examListProvider.future);
  final activeExams = exams.where((exam) => exam.isActive).toList();
  final selectedId =
      await ref.watch(appPreferencesRepositoryProvider).selectedExamId();

  if (selectedId != null) {
    for (final exam in activeExams) {
      if (exam.id == selectedId) {
        return ActiveExamFocus.selected(exam);
      }
    }
    return const ActiveExamFocus.needsSelection();
  }

  if (activeExams.length == 1) {
    return ActiveExamFocus.selected(activeExams.single);
  }

  return const ActiveExamFocus.needsSelection();
});
