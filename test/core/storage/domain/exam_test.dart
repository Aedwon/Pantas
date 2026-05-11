import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Exam round-trips JSON including nested subjects', () {
    const e = Exam(
      id: 'exam_cse_pro',
      code: 'CSE_PRO',
      name: 'CSE Professional',
      shortName: 'CSE Pro',
      language: 'en',
      isActive: true,
      subjects: [
        Subject(id: 's1', examId: 'exam_cse_pro', name: 'Verbal', ordering: 1),
      ],
    );
    expect(Exam.fromJson(e.toJson()), equals(e));
  });
}
