import 'entitlement.dart';

class TrialNotice {
  const TrialNotice({
    required this.daysRemaining,
    required this.chargeDate,
  });

  final int daysRemaining;
  final DateTime chargeDate;

  static TrialNotice? fromEntitlement(
    Entitlement entitlement, {
    required DateTime today,
  }) {
    final chargeDate = entitlement.expiresAt;
    if (!entitlement.proIsActive ||
        !entitlement.isTrial ||
        !entitlement.willRenew ||
        chargeDate == null) {
      return null;
    }

    final daysRemaining = _calendarDaysBetween(today, chargeDate);
    if (daysRemaining > 2 || daysRemaining < 0) return null;
    return TrialNotice(daysRemaining: daysRemaining, chargeDate: chargeDate);
  }

  static int _calendarDaysBetween(DateTime start, DateTime end) {
    final startDay = DateTime.utc(start.year, start.month, start.day);
    final endDay = DateTime.utc(end.year, end.month, end.day);
    return endDay.difference(startDay).inDays;
  }
}
