import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/offline_window.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

void main() {
  final end = DateTime.utc(2026, 10, 10);
  final cached = Entitlement(
    plan: EntitlementPlan.monthly,
    productId: 'pantas_pro_monthly',
    expiresAt: end,
    examTiers: const {'exam_upcat': PriceTier.student},
  );
  test('AC-1 cached Pro holds to expiry plus three days, then pauses', () {
    final inside = OfflineWindow.apply(
      cached,
      effectiveTime: end.add(const Duration(days: 2)),
      windowConsumed: false,
    );
    expect(inside.coversExam('exam_upcat'), isTrue);
    expect(inside.expiresAt, end);
    final expired = OfflineWindow.apply(
      cached,
      effectiveTime: end.add(const Duration(days: 3)),
      windowConsumed: false,
    );
    expect(expired.state, EntitlementState.paused);
    expect(expired.coversExam('exam_upcat'), isFalse);
  });
  test('AC-1 counted setbacks pause even before paid expiry', () {
    final paused = OfflineWindow.apply(
      cached,
      effectiveTime: end.subtract(const Duration(days: 1)),
      windowConsumed: true,
    );
    expect(paused.state, EntitlementState.paused);
    expect(paused.coversExam('exam_upcat'), isFalse);
  });
}
