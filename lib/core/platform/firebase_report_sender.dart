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
    bool Function()? hasAccount,
    String Function()? build,
  })  : _callable = callable ?? _call,
        _hasAccount = hasAccount ?? _signedIn,
        _build = build ?? _buildLabel;

  static const callableName = 'sendQuestionReport';

  final ReportCallable _callable;
  final bool Function() _hasAccount;
  final String Function() _build;

  @override
  Future<void> send(QuestionReport report) async {
    if (!_hasAccount()) throw const ReportUnavailable();
    try {
      await _callable({
        'reportId': report.id,
        'questionId': report.questionId,
        if (report.questionVersion != null)
          'questionVersion': report.questionVersion,
        if (report.examId != null) 'examId': report.examId,
        'message': report.message,
        'build': _build(),
      });
    } on FirebaseFunctionsException catch (e) {
      if (_isFinal(e)) throw ReportRefused(e.code);
      rethrow;
    }
  }

  /// A refusal that no retry changes: a malformed report, or a question that
  /// already has its three. The daily limit lifts at midnight, so it is kept.
  static bool _isFinal(FirebaseFunctionsException e) {
    if (e.code == 'invalid-argument') return true;
    final details = e.details;
    return e.code == 'resource-exhausted' &&
        details is Map &&
        details['reason'] == 'question-limit';
  }
}

bool _signedIn() =>
    Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

String _buildLabel() => '$kBuildNumber';

Future<void> _call(Map<String, Object?> data) async {
  const name = FirebaseReportSender.callableName;
  await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
      .httpsCallable(name, options: callableOptionsFor(name))
      .callForAccount<Object?>(data);
}
