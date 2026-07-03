import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';

/// What a plan costs a student to cover them through their exam.
///
/// Printing this is allowed under the evidentiary rule: it multiplies a
/// published price by a date the student asserted. Both terms are facts, so
/// it is not a measurement combined with an assumption.
class PlanCost {
  const PlanCost({this.total, this.renewals, this.overshootDays});

  /// Null when there is no exam date, because there is nothing to compute to.
  final double? total;
  final int? renewals;

  /// Days the term runs past the exam. Only meaningful for Yearly, and it is
  /// printed deliberately: it looks like it damages the most expensive SKU
  /// and it is exactly what makes the other two figures believable.
  final int? overshootDays;
}

PlanCost costForPackage({
  required PaywallPackage package,
  required ExamDate? examDate,
  required DateTime today,
}) {
  if (examDate == null) return const PlanCost();

  final days = _daysToCover(examDate: examDate, today: today);
  if (days <= 0) return const PlanCost();

  return switch (package.sku) {
    PaywallSku.weekly => _periodCost(package, days, 7),
    PaywallSku.monthly => _periodCost(package, days, 30),
    PaywallSku.yearly => PlanCost(
        total: package.priceAmount,
        renewals: 1,
        overshootDays: 365 - days,
      ),
  };
}

/// Always rounds up. A student needs cover through their exam, so a term
/// that stops one day short is the wrong answer at any price.
PlanCost _periodCost(PaywallPackage package, int days, int periodDays) {
  final renewals = (days / periodDays).ceil();
  return PlanCost(
    total: package.priceAmount * renewals,
    renewals: renewals,
  );
}

/// At month precision, compute against the last day of the stated month.
///
/// The accepted cost is up to 30 days of extra horizon, which can tip a
/// student at 9.2 months from Monthly into Yearly. It is disclosed on screen
/// by the column head, and it errs toward cover rather than toward a cheaper
/// recommendation, which is the safer direction to be wrong in.
int _daysToCover({required ExamDate examDate, required DateTime today}) {
  final target = examDate.day ?? _lastDayOfMonth(examDate.year, examDate.month);
  return target.difference(DateTime(today.year, today.month, today.day)).inDays;
}

DateTime _lastDayOfMonth(int year, int month) {
  return DateTime(year, month + 1, 0);
}
