import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/domain/home_mock_row.dart';

void main() {
  test('durations read like the board', () {
    expect(formatMockDuration(165), '2 hr 45 min');
    expect(formatMockDuration(180), '3 hr');
    expect(formatMockDuration(45), '45 min');
  });

  test('the row names the exam simulation', () {
    final row = HomeMockRow.fromBlueprint(
      examShortName: 'UPCAT',
      durationMinutes: 165,
    );
    expect(row.subtitle, 'UPCAT simulation');
    expect(row.duration, '2 hr 45 min');
  });
}
