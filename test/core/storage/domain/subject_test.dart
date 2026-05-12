import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Subject round-trips JSON', () {
    const s = Subject(
      id: 's1',
      examId: 'exam_cse_pro',
      name: 'Verbal',
      ordering: 1,
    );
    expect(Subject.fromJson(s.toJson()), equals(s));
  });
}
