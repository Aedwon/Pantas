import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/sync/sync_status.dart';

/// Every string that lands in the value column.
///
/// It lives apart from the page so the evidentiary rule is testable on its
/// own: no function here prints a day count, and the exam date prints a month
/// when a month is all the student gave us.
abstract final class SettingsValueFormats {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String examDate(ExamDate? date) {
    if (date == null) return 'Not set';
    final day = date.day;
    if (day != null) {
      return '${day.day} ${_shortMonths[day.month - 1]} ${day.year}';
    }
    final month = date.monthStart;
    return '${_months[month.month - 1]} ${month.year}';
  }

  static String name(String? name) => name ?? 'Add your name';

  static String onOff({required bool value}) => value ? 'On' : 'Off';

  static String account({
    required AuthUser? user,
    required bool isAnonymous,
  }) {
    if (user != null && !isAnonymous) return 'Signed in';
    return 'Not signed in';
  }

  static String backup({
    required bool isAnonymous,
    required SyncStatus? status,
  }) {
    if (isAnonymous) return 'Not backed up';
    return switch (status) {
      // A failure reads as "Backing up" here and only here. Sync retries by
      // itself, so a student cannot act on the failure from a settings row,
      // and the silent-sync invariant forbids alarming them with one. The
      // backup page below says "Couldn't back up" plainly and offers the
      // retry, which is where a student can actually do something about it.
      Syncing() || SyncPartialFailure() || SyncFailedSince() => 'Backing up',
      SyncOk() || SyncIdle() => 'Saved',
      null => 'Not backed up',
    };
  }
}
