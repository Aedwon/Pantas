import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';

void main() {
  test('native coverage keeps its accepted value during a refresh', () async {
    final refreshed = Completer<bool>();
    var reads = 0;
    final scope = ProviderContainer(
      overrides: [
        studyUsesServerProvider.overrideWithValue(false),
        proForActiveExamProvider.overrideWith((_) {
          reads++;
          return reads == 1 ? Future.value(true) : refreshed.future;
        }),
      ],
    );
    addTearDown(scope.dispose);
    final subscription = scope.listen(currentStudyCoverageProvider, (_, __) {});
    addTearDown(subscription.close);
    await scope.read(proForActiveExamProvider.future);
    expect(scope.read(currentStudyCoverageProvider), isTrue);
    scope.invalidate(proForActiveExamProvider);
    await scope.pump();
    final duringRefresh = scope.read(currentStudyCoverageProvider);
    refreshed.complete(true);
    await scope.read(proForActiveExamProvider.future);
    expect(duringRefresh, isTrue);
  });
}
