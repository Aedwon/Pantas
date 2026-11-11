import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/error/app_error_recovery.dart';
import 'package:pantas/core/ui/components/state_view.dart';

import '../../helpers/accessibility.dart';

void main() {
  test('debug preserves the framework error builder', () {
    final original = ErrorWidget.builder;
    addTearDown(() => ErrorWidget.builder = original);
    expect(kReleaseMode, isFalse);
    installAppErrorRecovery(onRetry: () {});
    expect(ErrorWidget.builder, same(original));
  });
  testWidgets('release builder shows the full state and keyboard retry',
      (tester) async {
    final original = ErrorWidget.builder;
    addTearDown(() => ErrorWidget.builder = original);
    try {
      var retries = 0;
      installAppErrorRecovery(releaseMode: true, onRetry: () => retries++);
      final error = Exception('private path and token');
      await pumpAccessibilitySurface(
        tester,
        ErrorWidget.builder(FlutterErrorDetails(exception: error)),
      );
      expect(find.byType(StateView), findsOneWidget);
      expect(find.text('Something went wrong.'), findsOneWidget);
      expect(find.text("Nothing you've done is lost."), findsOneWidget);
      expect(find.textContaining('private'), findsNothing);
      expect(find.text('Try Again'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(retries, 1);
    } finally {
      ErrorWidget.builder = original;
    }
  });
  testWidgets('an error before the app host exists gets its own themed root',
      (tester) async {
    final original = ErrorWidget.builder;
    installAppErrorRecovery(releaseMode: true, onRetry: () {});
    final replacement = ErrorWidget.builder(
      FlutterErrorDetails(exception: StateError('private root failure')),
    );
    ErrorWidget.builder = original;
    await tester.pumpWidget(replacement);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Something went wrong.'), findsOneWidget);
  });
}
