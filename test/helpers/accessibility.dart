import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

const Size defaultAccessibilityViewport = Size(800, 600);

/// Pumps one accessibility test surface.
///
/// [textScale] is deliberately linear. It is a repeatable widget-test stress
/// case, not a simulation of Android 14 nonlinear font scaling.
Future<void> pumpAccessibilitySurface(
  WidgetTester tester,
  Widget widget, {
  double textScale = 1,
  Size viewportSize = defaultAccessibilityViewport,
  Brightness brightness = Brightness.light,
  bool disableAnimations = false,
}) async {
  tester.view
    ..physicalSize = viewportSize
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      theme:
          brightness == Brightness.dark ? buildDarkTheme() : buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          size: viewportSize,
          textScaler: TextScaler.linear(textScale),
          platformBrightness: brightness,
          disableAnimations: disableAnimations,
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
}

/// Applies Flutter's built-in checks to the surface already pumped.
Future<void> expectMeetsAccessibilityGuidelines(
  WidgetTester tester, {
  List<AccessibilityGuideline> guidelines = const [
    androidTapTargetGuideline,
    labeledTapTargetGuideline,
    textContrastGuideline,
  ],
}) async {
  final semantics = tester.ensureSemantics();
  try {
    for (final guideline in guidelines) {
      await expectLater(tester, meetsGuideline(guideline));
    }
  } finally {
    semantics.dispose();
  }
}

/// Pumps [widget] at 1.0 and at 2.0 linear text scale and fails on overflow.
///
/// This proves repeatable Flutter layout behavior only. It does not simulate
/// Android 14 nonlinear font scaling or replace device verification.
Future<void> expectSurvivesTextScale(
  WidgetTester tester,
  Widget widget, {
  List<double> scales = const [1.0, 2.0],
  Size viewportSize = defaultAccessibilityViewport,
  Brightness brightness = Brightness.light,
  bool disableAnimations = false,
}) async {
  for (final scale in scales) {
    final errors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = errors.add;

    try {
      await pumpAccessibilitySurface(
        tester,
        widget,
        textScale: scale,
        viewportSize: viewportSize,
        brightness: brightness,
        disableAnimations: disableAnimations,
      );
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
