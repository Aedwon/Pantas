import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/metrics/overall_accuracy.dart';

void main() {
  test('CSE Professional parts carry their weight, as Aedwon set the format',
      () {
    expect(
      csePartLabel('exam_cse_pro', 'Verbal Ability'),
      'Verbal Ability (30%)',
    );
    expect(
      csePartLabel('exam_cse_pro', 'Analytical Ability'),
      'Analytical Ability (35%)',
    );
    expect(
      csePartLabel('exam_cse_pro', 'Numerical Ability'),
      'Numerical Ability (30%)',
    );
    expect(
      csePartLabel('exam_cse_pro', 'General Information'),
      'General Information (5%)',
    );
  });

  test('Subprofessional, other exams and other names show no weight', () {
    expect(csePartLabel('exam_cse_sub', 'Verbal Ability'), 'Verbal Ability');
    expect(
      csePartLabel('exam_cse_sub', 'Clerical Ability'),
      'Clerical Ability',
    );
    expect(csePartLabel('exam_upcat', 'Verbal Ability'), 'Verbal Ability');
    expect(csePartLabel(null, 'Verbal Ability'), 'Verbal Ability');
    expect(csePartLabel('exam_cse_pro', 'Algebra'), 'Algebra');
    expect(csePartLabel('exam_cse_pro', 'Part 1'), 'Part 1');
  });
}
