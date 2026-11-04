import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/application/plan_provider.dart';

void main() {
  final today = DateTime(2026, 11, 5);
  test('Coming up keeps today and later days and drops past ones (3K-17)', () {
    expect(planMarkerComingUp(DateTime(2026, 11, 3), today), isFalse);
    expect(planMarkerComingUp(DateTime(2026, 11, 5), today), isTrue);
    expect(planMarkerComingUp(DateTime(2026, 11, 20), today), isTrue);
    expect(planMarkerComingUp(null, today), isFalse);
  });
}
