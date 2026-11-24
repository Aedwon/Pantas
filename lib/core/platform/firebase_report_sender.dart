import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pantas/app/build_info.dart';
import 'package:pantas/core/platform/account_access.dart';
import 'package:pantas/core/platform/callable_options.dart';
import 'package:pantas/core/storage/data/report_queue.dart';

/// Calls the report callable by name. Throws `FirebaseFunctionsException`.
typedef ReportCallable = Future<void> Function(Map<String, Object?> data);

/// Sends a queued question report to the `sendQuestionReport` callable. The
/// server stores one report per report id, so a retry is safe.
class FirebaseReportSender implements ReportSender {
  FirebaseReportSender({
    ReportCallable? callable,
    String? Function()? currentAccount,
    String Function()? build,
  })  : _callable = callable ?? _call,
        _currentAccount = currentAccount ?? _signedInAccount,
        _build = build ?? _buildLabel;

  static const callableName = 'sendQuestionReport';

  final ReportCallable _callable;
  final String? Function() _currentAccount;
  final String Function() _build;

  @override
  Future<void> send(QuestionReport report) async {
    // The report goes out only under the account that wrote it. The server
    // checks the same id against the signed-in account.
    final account = _currentAccount();
    if (account == null || account != report.accountId) {
      throw const ReportUnavailable();
    }
    try {
      await _callable({
        'reportId': report.id,
        'accountId': account,
        'questionId': report.questionId,
        if (report.questionVersion != null)
          'questionVersion': report.questionVersion,
        if (report.examId != null) 'examId': report.examId,
        'message': report.message,
        'build': _build(),
      });
    } on FirebaseFunctionsException catch (e) {
      if (_isFinal(e)) throw ReportRefused(_reason(e));
      rethrow;
    }
  }

  /// The code, or for a quota refusal the server's own reason
  /// (`daily-limit` or `question-limit`).
  static String _reason(FirebaseFunctionsException e) {
    final details = e.details;
    final reason = details is Map ? details['reason'] : null;
    return e.code == 'resource-exhausted' && reason is String ? reason : e.code;
  }

  /// A refusal that no retry changes: a malformed report, a question that
  /// already has its three, or a full day. A held-back report would block
  /// sign-out, so a quota refusal is final: it is discarded and logged.
  static bool _isFinal(FirebaseFunctionsException e) {
    if (e.code == 'invalid-argument' || e.code == 'already-exists') {
      return true;
    }
    final details = e.details;
    return e.code == 'resource-exhausted' &&
        details is Map &&
        (details['reason'] == 'question-limit' ||
            details['reason'] == 'daily-limit');
  }
}

String? _signedInAccount() =>
    Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser?.uid;

String _buildLabel() => '$kBuildNumber';

Future<void> _call(Map<String, Object?> data) async {
  const name = FirebaseReportSender.callableName;
  await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
      .httpsCallable(name, options: callableOptionsFor(name))
      .callForAccount<Object?>(data);
}
