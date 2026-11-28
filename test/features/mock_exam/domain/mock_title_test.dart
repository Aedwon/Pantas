import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/domain/mock_title.dart';

void main() {
  // Boards MK_Results and web MK_ResultsFirst name the mock "<Exam>
  // simulation", whether the mock ran on the phone or on the server (U18).
  group('mockResultsTitle', () {
    test('a server result for a listed exam gets the simulation name', () {
      expect(
        mockResultsTitle('exam_cse_pro', 'CSE Professional'),
        'CSE Professional simulation',
      );
      expect(
        mockResultsTitle('exam_cse_sub', 'CSE Subprofessional'),
        'CSE Subprofessional simulation',
      );
    });

    test('a named custom exam is called its name plus simulation', () {
      expect(
        mockResultsTitle('exam_custom_1', 'PUP CET'),
        'PUP CET simulation',
      );
    });

    test('a local paper name drops Practice Paper', () {
      expect(
        mockResultsTitle('exam_upcat', 'UPCAT Practice Paper'),
        'UPCAT simulation',
      );
    });

    test('the unnamed fallback stays as it is', () {
      expect(mockResultsTitle('exam_custom_1', 'Mock exam'), 'Mock exam');
    });
  });

  // P10: a name that carries the practice label never repeats it on a line
  // that already sits next to the exam name.
  group('mockNameWithoutLabel', () {
    test('drops the label and keeps the exam name', () {
      expect(
        mockNameWithoutLabel(
          'CSE Professional ($mockPracticeLabel)',
        ),
        'CSE Professional',
      );
    });

    test('leaves a name with no label alone', () {
      expect(
        mockNameWithoutLabel('UPCAT Practice Paper'),
        'UPCAT Practice Paper',
      );
    });
  });
}
