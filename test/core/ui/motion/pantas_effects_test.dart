import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';

void main() {
  testWidgets('pop eases each elapsed-time keyframe interval', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PantasEffects.pop(
          duration: const Duration(milliseconds: 500),
          builder: (_, __, ___) => const SizedBox(),
        ),
      ),
    );
    double scale() =>
        tester.widget<Transform>(find.byType(Transform)).transform.entry(0, 0);
    expect(scale(), closeTo(0.4, 0.000001));
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      scale(),
      closeTo(0.4 + 0.72 * PantasCurves.popC.transform(0.5), 0.000001),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(), closeTo(1.12, 0.000001));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      scale(),
      closeTo(1.12 - 0.12 * PantasCurves.popC.transform(0.5), 0.000001),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(scale(), closeTo(1, 0.000001));
  });
  testWidgets('shake keeps every elapsed-time keyframe and interval easing',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PantasEffects.shake(
          duration: const Duration(milliseconds: 1000),
          builder: (_, __, ___) => const SizedBox(),
        ),
      ),
    );
    double offset() =>
        tester.widget<Transform>(find.byType(Transform)).transform.entry(0, 3);
    await tester.pump(const Duration(milliseconds: 90));
    expect(offset(), closeTo(-9 * PantasCurves.shake.transform(0.5), 0.000001));
    await tester.pump(const Duration(milliseconds: 90));
    expect(offset(), closeTo(-9, 0.000001));
    for (final value in [8.0, -5.0, 3.0]) {
      await tester.pump(const Duration(milliseconds: 180));
      expect(offset(), closeTo(value, 0.000001));
    }
    await tester.pump(const Duration(milliseconds: 280));
    expect(offset(), closeTo(0, 0.000001));
  });

  testWidgets('pop jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.pop(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('rise jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.rise(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('gauge jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.gauge(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('checkDraw jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.checkDraw(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('shake jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.shake(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('press jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.press(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('ring jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.ring(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('burst jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.burst(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('push jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.push(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('collapse jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.collapse(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('fade jumps to its last frame with motion disabled',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PantasEffects.fade(
            duration: const Duration(seconds: 5),
            builder: (context, value, child) {
              progress = value;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets('normal motion reaches the last frame without replaying',
      (tester) async {
    double? progress;
    await tester.pumpWidget(
      MaterialApp(
        home: PantasEffects.rise(
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            progress = value;
            return const Text('Body');
          },
        ),
      ),
    );
    expect(progress, 0);
    await tester.pump(const Duration(milliseconds: 500));
    expect(progress, 1);
    await tester.pump(const Duration(seconds: 10));
    expect(progress, 1);
  });
}
