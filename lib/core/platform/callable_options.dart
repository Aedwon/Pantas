import 'package:cloud_functions/cloud_functions.dart';

/// Callables whose server side consumes the App Check token and refuses a
/// token that was used before: payment, trial, account deletion, export, admin
/// and paid mock actions. Each call must carry a fresh, limited-use token or
/// the second call from the same browser is refused. Keep in step with
/// `REPLAY_PROTECTED` in `functions/test/app-check.test.mjs`, except the five
/// beta feedback callables, which that list does not name yet.
const replayProtectedCallables = <String>{
  'createPaymongoCheckout',
  'startWebTrial',
  'setBetaPro',
  'getBetaAccess',
  'deleteAccount',
  'exportData',
  'recomputePassEnds',
  'startMock',
  'updateMockReview',
  'sendGuardianLink',
  'answerGuardianRequest',
  'setGuardianSharing',
  'withdrawGuardianPermission',
  'requestSignInCode',
  'verifySignInCode',
  'exchangeGoogleSignIn',
  'sendBetaFeedback',
  'recordBetaDay',
  'submitBetaSurvey',
  'activateBetaReward',
  'getBetaReward',
};

/// Options for calling [name]: limited-use App Check tokens for the callables
/// above, the default for every other callable.
HttpsCallableOptions callableOptionsFor(String name) => HttpsCallableOptions(
      limitedUseAppCheckToken: replayProtectedCallables.contains(name),
    );
