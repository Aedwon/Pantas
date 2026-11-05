import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/application/plan_provider.dart';

void main() {
  final today = DateTime(2026, 11, 5);
  test('Coming up keeps only later days: past and today are left out', () {
    // 3K-17: a past date is not announced. 4N-12: today's mock is in Today.
    expect(planMarkerComingUp(DateTime(2026, 11, 3), today), isFalse);
    expect(planMarkerComingUp(DateTime(2026, 11, 5), today), isFalse);
    expect(planMarkerComingUp(DateTime(2026, 11, 6), today), isTrue);
    expect(planMarkerComingUp(DateTime(2026, 11, 20), today), isTrue);
    expect(planMarkerComingUp(null, today), isFalse);
  });
}
