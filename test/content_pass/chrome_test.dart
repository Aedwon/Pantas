// ignore_for_file: cascade_invocations, use_raw_strings, require_trailing_commas, unnecessary_raw_strings, lines_longer_than_80_chars
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tools/content_pass/app/chrome_switch.dart';
import '../../tools/content_pass/app/device.dart';
import '../../tools/content_pass/app/palette.dart';

void main() {
  group('Device.fromStored', () {
    test('reads the three sizes', () {
      expect(Device.fromStored('desktop'), Device.desktop);
      expect(Device.fromStored('tablet'), Device.tablet);
      expect(Device.fromStored('phone'), Device.phone);
    });

    test('old notes that stored wide mean desktop', () {
      expect(Device.fromStored('wide'), Device.desktop);
    });

    test('anything else is phone', () {
      expect(Device.fromStored(null), Device.phone);
      expect(Device.fromStored('huge'), Device.phone);
    });

    test('the sizes are the ones the reviewer lays screens out at', () {
      expect((Device.desktop.width, Device.desktop.height), (1440, 900));
      expect((Device.tablet.width, Device.tablet.height), (820, 1180));
      expect((Device.phone.width, Device.phone.height), (390, 844));
    });
  });

  group('switch contrast', () {
    for (final dark in [false, true]) {
      final p = Palette.of(dark: dark);
      final name = dark ? 'dark' : 'light';
      test('muted text on the track and panel, $name', () {
        expect(contrastRatio(p.muted, p.track), greaterThanOrEqualTo(4.5));
        expect(contrastRatio(p.muted, p.panel), greaterThanOrEqualTo(4.5));
        expect(contrastRatio(p.muted, p.bg), greaterThanOrEqualTo(4.5));
      });
    }

    test('white text on the green thumb', () {
      expect(
          contrastRatio(Colors.white, thumbGreen), greaterThanOrEqualTo(4.5));
    });
  });

  group('ChromeSwitch', () {
    Widget host({
      required ValueChanged<int> onChanged,
      bool enabled = true,
    }) =>
        MaterialApp(
          home: Material(
            child: Center(
              child: ChromeSwitch(
                palette: Palette.of(dark: false),
                enabled: enabled,
                segments: const [
                  SwitchSegment.text('Free'),
                  SwitchSegment.text('Pro'),
                ],
                selected: 1,
                onChanged: onChanged,
              ),
            ),
          ),
        );

    testWidgets('a tap reports the segment', (tester) async {
      int? tapped;
      await tester.pumpWidget(host(onChanged: (i) => tapped = i));
      await tester.tap(find.text('Free'));
      expect(tapped, 0);
    });

    testWidgets('a disabled switch ignores taps and stays in place', (
      tester,
    ) async {
      int? tapped;
      await tester
          .pumpWidget(host(onChanged: (i) => tapped = i, enabled: false));
      final before = tester.getRect(find.byType(ChromeSwitch));
      await tester.tap(find.text('Free'), warnIfMissed: false);
      expect(tapped, isNull);
      expect(tester.getRect(find.byType(ChromeSwitch)), before);
    });
  });
}
