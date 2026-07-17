import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [widget] at 1.0 and at 2.0 text scale and fails on any overflow.
Future<void> expectSurvivesTextScale(
  WidgetTester tester,
  Widget widget, {
  List<double> scales = const [1.0, 2.0],
}) async {
  for (final scale in scales) {
    final errors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = errors.add;

    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: [AppColors.light, AppTextStyles.create()],
          ),
          home: MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(scale),
            ),
            child: Scaffold(
              body: Center(
                child: widget,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    } finally {
      FlutterError.onError = originalOnError;
    }

    final exception = tester.takeException();
    if (exception != null) {
      fail('Widget threw exception at text scale $scale: $exception');
    }

    for (final error in errors) {
      final message = error.toString();
      if (message.contains('overflowed')) {
        fail('Widget overflowed at text scale $scale: ${error.exception}');
      }
    }
  }
}
