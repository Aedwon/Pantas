import 'package:cloud_functions/cloud_functions.dart';

/// Callables whose server side consumes the App Check token and refuses a
/// token that was used before: payment, trial, account deletion, export, admin
/// and paid mock actions. Each call must carry a fresh, limited-use token or
/// the second call from the same browser is refused. Keep in step with
/// `REPLAY_PROTECTED` in `functions/test/app-check.test.mjs`.
const replayProtectedCallables = <String>{
  'createPaymongoCheckout',
  'startWebTrial',
  'setBetaPro',
  'deleteAccount',
  'exportData',
  'recomputePassEnds',
  'startMock',
  'updateMockReview',
};

/// Options for calling [name]: limited-use App Check tokens for the callables
/// above, the default for every other callable.
HttpsCallableOptions callableOptionsFor(String name) => HttpsCallableOptions(
      limitedUseAppCheckToken: replayProtectedCallables.contains(name),
    );
