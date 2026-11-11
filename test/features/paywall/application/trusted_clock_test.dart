import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/application/trusted_clock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DateTime wall;
  late Duration elapsed;
  late Map<String, String> values;
  setUp(() {
    wall = DateTime.utc(2026, 10, 10, 12);
    elapsed = const Duration(hours: 10);
    values = {};
  });
  TrustedClock clock() => TrustedClock(
        readValue: (key) async => values[key],
        writeValue: (key, value) async => values[key] = value,
        deviceNow: () => wall,
        elapsedNow: () async => elapsed,
      );

  test('AC-1 cached answer does not reset the mark or trusted time', () async {
    final c = clock();
    await c.start();
    final trusted = wall;
    expect(await c.confirm(trusted), isTrue);
    wall = wall.add(const Duration(hours: 1));
    elapsed += const Duration(hours: 1);
    await c.observe();
    expect(await c.confirm(trusted), isFalse);
    expect(c.effectiveTime, wall);
    expect(c.trustedTime, trusted);
  });

  test('AC-1 repeated small setbacks consume the offline window', () async {
    final c = clock();
    await c.start();
    await c.confirm(wall);
    for (var i = 0; i < 6; i++) {
      wall = wall.subtract(const Duration(minutes: 2));
      elapsed += const Duration(seconds: 1);
      await c.observe();
    }
    expect(c.rollbackTotal, greaterThan(const Duration(minutes: 10)));
    expect(c.windowConsumed, isTrue);
  });

  test('AC-1 an in-session setback counts and time never moves backward',
      () async {
    final c = clock();
    await c.start();
    final trusted = wall;
    await c.confirm(trusted);
    wall = wall.subtract(const Duration(minutes: 1));
    elapsed += const Duration(minutes: 2);
    await c.observe();
    expect(c.rollbackTotal, isNot(Duration.zero));
    expect(c.effectiveTime, trusted.add(const Duration(minutes: 2)));
  });

  test('AC-1 a closed-app setback in the same boot counts only once', () async {
    final first = clock();
    await first.start();
    wall = wall.subtract(const Duration(minutes: 2));
    elapsed += const Duration(minutes: 1);
    final resumed = clock();
    await resumed.start();
    final counted = resumed.rollbackTotal;
    expect(counted, isNot(Duration.zero));
    await resumed.observe();
    expect(resumed.rollbackTotal, counted);
    final again = clock();
    await again.start();
    expect(again.rollbackTotal, counted);
  });

  test('AC-1 a reboot and ordinary start do not count a setback', () async {
    await clock().start();
    wall = wall.add(const Duration(hours: 1));
    elapsed = const Duration(minutes: 1);
    final restarted = clock();
    await restarted.start();
    expect(restarted.rollbackTotal, Duration.zero);
  });

  test('AC-1 a newer trusted check clears a corrected wrong-year clock',
      () async {
    final c = clock();
    await c.start();
    final trusted = wall;
    await c.confirm(trusted);
    wall = DateTime.utc(2027, 10, 10, 12);
    await c.observe();
    wall = trusted;
    elapsed += const Duration(seconds: 1);
    await c.observe();
    expect(c.windowConsumed, isTrue);
    expect(await c.confirm(trusted.add(const Duration(seconds: 1))), isTrue);
    expect(c.rollbackTotal, Duration.zero);
    expect(c.effectiveTime, trusted.add(const Duration(seconds: 1)));
  });

  test('AC-1 clock records survive a new clock instance', () async {
    final c = clock();
    await c.start();
    await c.confirm(wall);
    wall = wall.subtract(const Duration(minutes: 2));
    await c.observe();
    final next = clock();
    await next.start();
    expect(next.trustedTime, c.trustedTime);
    expect(next.rollbackTotal, c.rollbackTotal);
  });

  test('AC-1 missing elapsed channel is no reading, never a setback', () async {
    const channel = MethodChannel('pantas/trusted_clock');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (_) async => throw MissingPluginException(),
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    expect(await readElapsedRealtime(), isNull);
  });
}
