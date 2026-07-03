import 'package:cse_cet_reviewer/core/storage/domain/exam_date.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/plan_cost.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 8, 2);
  final examOct12 = ExamDate.onDay(DateTime(2026, 10, 12));

  const weekly = PaywallPackage(
    sku: PaywallSku.weekly,
    productId: 'pro_weekly',
    priceString: '₱29',
    priceAmount: 29,
  );
  const monthly = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pro_monthly',
    priceString: '₱99',
    priceAmount: 99,
  );
  const yearly = PaywallPackage(
    sku: PaywallSku.yearly,
    productId: 'pro_yearly',
    priceString: '₱999',
    priceAmount: 999,
  );

  test('Weekly covers 71 days with 11 renewals at ₱319', () {
    final cost = costForPackage(
      package: weekly,
      examDate: examOct12,
      today: today,
    );
    expect(cost.renewals, 11);
    expect(cost.total, 319);
  });

  test('Monthly covers 71 days with 3 months at ₱297', () {
    final cost = costForPackage(
      package: monthly,
      examDate: examOct12,
      today: today,
    );
    expect(cost.renewals, 3);
    expect(cost.total, 297);
  });

  test('Yearly is one payment and runs past the exam', () {
    final cost = costForPackage(
      package: yearly,
      examDate: examOct12,
      today: today,
    );
    expect(cost.renewals, 1);
    expect(cost.total, 999);
    expect(cost.overshootDays, 294);
  });

  test('cover always reaches the exam, never stops short', () {
    // 8 days needs 2 weekly renewals, not 1.
    final cost = costForPackage(
      package: weekly,
      examDate: ExamDate.onDay(DateTime(2026, 8, 10)),
      today: today,
    );
    expect(cost.renewals, 2);
  });

  test('at month precision it computes through the last day of that month', () {
    final cost = costForPackage(
      package: monthly,
      examDate: ExamDate.inMonth(year: 2026, month: 10),
      today: today,
    );
    // 2 August to 31 October is 90 days, so 3 months.
    expect(cost.renewals, 3);
    expect(cost.total, 297);
  });

  test('with no exam date there is no total to print', () {
    final cost = costForPackage(
      package: monthly,
      examDate: null,
      today: today,
    );
    expect(cost.total, isNull);
    expect(cost.renewals, isNull);
  });
}
