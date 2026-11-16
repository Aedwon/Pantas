import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/dev/input_check_overlay.dart';
import 'package:pantas/core/dev/input_check_probe.dart';

void main() {
  late Duration now;
  late InputCheckProbe probe;

  setUp(() {
    now = Duration.zero;
    probe = InputCheckProbe(clock: () => now);
  });

  tearDown(() => probe.dispose());

  PointerEvent down(int pointer) => PointerDownEvent(
        pointer: pointer,
        timeStamp: now,
        position: const Offset(10, 10),
      );
  PointerEvent move(int pointer, Duration stamp) => PointerMoveEvent(
        pointer: pointer,
        timeStamp: stamp,
        position: const Offset(10, 20),
        delta: const Offset(0, 1),
      );
  PointerEvent up(int pointer) => PointerUpEvent(
        pointer: pointer,
        timeStamp: now,
        position: const Offset(10, 30),
      );

  // One 16 ms screen refresh. Four touch samples arrive in one batch, the
  // list moves or not, Flutter draws or not.
  Future<void> refresh({
    bool samples = true,
    bool moves = true,
    bool draws = true,
    int pointer = 1,
  }) async {
    now += const Duration(milliseconds: 16);
    if (samples) {
      for (var i = 0; i < 4; i++) {
        probe.onPointer(move(pointer, now + Duration(microseconds: i * 4000)));
      }
    }
    if (moves) probe.onScrollUpdate(5);
    probe.onVsync();
    if (draws) probe.onFrame();
    // Lets the batch close.
    await Future<void>.value();
  }

  test('a drag counts frames, vsyncs, moves, batches and moved frames',
      () async {
    probe.onPointer(down(1));
    await refresh();
    await refresh();
    await refresh(moves: false);
    await refresh();
    await refresh(draws: false); // moved, but Flutter drew nothing this vsync
    probe.onPointer(up(1));

    final drag = probe.report.value.drag!;
    expect(drag.vsyncs, 5);
    expect(drag.frames, 4);
    expect(drag.movedFrames, 3);
    expect(drag.moves, 20);
    expect(drag.batches, 5);
    expect(drag.stamps, 20);
    expect(drag.elapsed, const Duration(milliseconds: 80));
    expect(drag.framesPerSecond, closeTo(50, 0.001));
    expect(drag.vsyncsPerSecond, closeTo(62.5, 0.001));
    expect(drag.movesPerSecond, closeTo(250, 0.001));
    expect(drag.batchesPerSecond, closeTo(62.5, 0.001));
    expect(drag.movedShare, closeTo(0.75, 0.001));
    expect(drag.vsyncsWithoutMove, 2);
  });

  test('the fling is counted from release to the end of the scroll', () async {
    probe.onPointer(down(1));
    await refresh();
    probe.onPointer(up(1));
    await refresh(samples: false);
    await refresh(samples: false);
    await refresh(samples: false, moves: false);
    await refresh(samples: false, draws: false);
    probe.onScrollEnd();

    final fling = probe.report.value.fling!;
    expect(fling.vsyncs, 4);
    expect(fling.frames, 3);
    expect(fling.movedFrames, 2);
    expect(fling.moves, 0);
    expect(fling.elapsed, const Duration(milliseconds: 64));
    expect(fling.vsyncsWithoutMove, 2);
    // The drag is kept.
    expect(probe.report.value.drag!.frames, 1);
  });

  test('a touch that never scrolls is not a drag', () async {
    probe.onPointer(down(1));
    await refresh(moves: false);
    probe
      ..onPointer(up(1))
      ..onScrollEnd();
    expect(probe.report.value.drag, isNull);
    expect(probe.report.value.fling, isNull);
  });

  test('a tap does not replace the last drag', () async {
    probe.onPointer(down(1));
    await refresh();
    probe
      ..onPointer(up(1))
      ..onScrollEnd();
    final before = probe.report.value.drag;
    probe
      ..onPointer(down(1))
      ..onPointer(up(1));
    expect(probe.report.value.drag, same(before));
  });

  test('a drag that ends with no speed leaves no fling', () async {
    probe.onPointer(down(1));
    await refresh();
    probe
      ..onPointer(up(1))
      ..onScrollEnd();
    expect(probe.report.value.drag, isNotNull);
    expect(probe.report.value.fling, isNull);
  });

  test('a new touch closes the fling and starts a drag', () async {
    probe.onPointer(down(1));
    await refresh();
    probe.onPointer(up(1));
    await refresh(samples: false);
    probe.onPointer(down(1));
    expect(probe.report.value.fling!.frames, 1);
    await refresh();
    probe.onPointer(up(1));
    expect(probe.report.value.drag!.frames, 1);
  });

  test('a second finger is ignored', () async {
    probe
      ..onPointer(down(1))
      ..onPointer(down(2));
    await refresh();
    probe
      ..onPointer(move(2, now))
      ..onPointer(up(2))
      ..onPointer(up(1));
    expect(probe.report.value.drag!.moves, 4);
  });

  test('resampled moves that share a timestamp count as one stamp', () async {
    probe.onPointer(down(1));
    now += const Duration(milliseconds: 16);
    final stamp = now;
    probe
      ..onPointer(move(1, stamp))
      ..onPointer(move(1, stamp))
      ..onScrollUpdate(5)
      ..onVsync()
      ..onFrame()
      ..onPointer(up(1));
    final drag = probe.report.value.drag!;
    expect(drag.moves, 2);
    expect(drag.stamps, 1);
    expect(drag.batches, 1);
  });

  test('nothing is counted outside a drag or a fling', () {
    probe
      ..onVsync()
      ..onFrame()
      ..onScrollUpdate(5)
      ..onPointer(move(1, now));
    expect(probe.report.value.drag, isNull);
    expect(probe.report.value.fling, isNull);
  });

  test('the report reaches the listener as plain data', () async {
    final seen = <Map<String, Object?>>[];
    probe.dispose();
    probe = InputCheckProbe(clock: () => now, onPublish: seen.add)
      ..onPointer(down(1));
    await refresh();
    probe.onPointer(up(1));
    final data = seen.last;
    final drag = data['drag']! as Map<String, Object?>;
    expect(drag['frames'], 1);
    expect(drag['vsyncs'], 1);
    expect(drag['moves'], 4);
    expect(drag['movedFrames'], 1);
    expect(drag['ms'], 16);
    expect(data['fling'], isNull);
  });

  test('a disposed probe counts nothing', () async {
    probe
      ..dispose()
      ..onPointer(down(1))
      ..onScrollUpdate(5)
      ..onFrame()
      ..onPointer(up(1));
    expect(probe.report.value.drag, isNull);
  });

  group('wired to the real binding', () {
    testWidgets('a finger drag shows in the overlay and never blocks taps',
        (tester) async {
      final testProbe = InputCheckProbe();
      installInputCheckProbe(
        testProbe,
        gestures: GestureBinding.instance,
        scheduler: SchedulerBinding.instance,
      );
      addTearDown(testProbe.dispose);
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: InputCheckOverlay(
            probe: testProbe,
            child: Scaffold(
              body: ListView(
                children: [
                  for (var i = 0; i < 60; i++)
                    ListTile(title: Text('Row $i'), onTap: () => taps++),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.textContaining('Drag'), findsOneWidget);

      await tester.tap(find.text('Row 0'), warnIfMissed: false);
      expect(taps, 1);

      final gesture = await tester.startGesture(const Offset(200, 400));
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      final drag = testProbe.report.value.drag!;
      expect(drag.moves, 6);
      expect(drag.frames, greaterThan(0));
      expect(drag.movedFrames, greaterThan(0));
      expect(find.textContaining('moved'), findsWidgets);
    });
  });
}
