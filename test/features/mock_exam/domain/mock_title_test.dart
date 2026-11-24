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
}
