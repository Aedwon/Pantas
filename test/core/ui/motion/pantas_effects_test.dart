import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';

void main() {
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
