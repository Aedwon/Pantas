import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Startup order is part of the load-speed work (spec S3 to S5). The startup
// function needs real Firebase, so these tests read its source and pin the
// order that matters: slow network steps start early and are still awaited
// before the first screen.
void main() {
  final source = File('lib/app/bootstrap.dart').readAsStringSync();
  int at(String needle) {
    final index = source.indexOf(needle);
    expect(index, isNonNegative, reason: 'bootstrap.dart has: $needle');
    return index;
  }

  test('Remote Config starts right after Firebase and is awaited at the flags',
      () {
    final firebase = at('await bootstrapFirebaseForStartup(flavor)');
    final started = at('bootstrapRemoteFlagsOverrides()');
    final appCheck = at('await activateAppCheck(flavor)');
    final awaited = at('await remoteFlags');
    final overridesUsed = at('...remoteFlagsOverrides');

    expect(started, greaterThan(firebase));
    expect(started, lessThan(appCheck), reason: 'started before App Check');
    expect(awaited, greaterThan(appCheck));
    expect(awaited, lessThan(overridesUsed));
    expect(
      source.indexOf('await bootstrapRemoteFlagsOverrides()'),
      -1,
      reason: 'the start is not also the wait',
    );
  });
  test('the beta check starts right after the account session', () {
    final auth = at('await bootstrapAuthSession(container, firebaseResult)');
    final check = at('startBetaAccessCheck(container)');
    final content = at('reprojectFailure = await startWebContent(container)');
    expect(check, greaterThan(auth));
    expect(check, lessThan(content), reason: 'runs beside the content restore');
  });

  test('payments start before the content restore and finish before sync', () {
    final started = at('final payments = bootstrapRevenueCat(container)');
    final content = at('reprojectFailure = await startWebContent(container)');
    final consent = at('await applyPersistedTelemetryConsent(container)');
    final awaited = at('await payments;');
    final sync = at('await bootstrapSyncRuntime(container, firebaseResult)');
    final firstPage = at('await settleGatesBeforeFirstPage(container)');
    final runApp = at('runApp(\n      UncontrolledProviderScope');

    expect(started, lessThan(content));
    expect(awaited, greaterThan(consent));
    expect(awaited, lessThan(sync));
    expect(sync, lessThan(firstPage));
    expect(firstPage, lessThan(runApp));
    // Never fire and forget: the entitlement is settled before the first page.
    expect(source, isNot(contains('unawaited(bootstrapRevenueCat')));
  });
}
