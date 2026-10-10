import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

Widget harness(
        {bool dark = false,
        ValueChanged<int>? onTap,
        TextScaler textScaler = TextScaler.noScaling}) =>
    MaterialApp(
      theme: dark ? buildDarkTheme() : buildLightTheme(),
      home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: Scaffold(
              bottomNavigationBar:
                  AppNavBar(currentIndex: 0, onTap: onTap ?? (_) {}))),
    );

void main() {
  setUpAll(() async {
    final font = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      font.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await font.load();
  });
  for (final (width, scale) in [(320.0, 3.0), (360.0, 2.0), (390.0, 1.0)]) {
    testWidgets('whole tab labels fit at $width px and $scale text scale',
        (tester) async {
      tester.view
        ..physicalSize = Size(width, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                  bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppNavBar(currentIndex: 0, onTap: (_) {}),
              )))));
      final scales = <double>[];
      for (final label in ['Home', 'Study', 'Quiz', 'Settings']) {
        final paragraph =
            tester.renderObject<RenderParagraph>(find.text(label));
        final boxes = paragraph.getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: label.length));
        expect(boxes, hasLength(1));
        expect(boxes.single.left, greaterThanOrEqualTo(-0.001));
        expect(
            boxes.single.right, lessThanOrEqualTo(paragraph.size.width + 0.001),
            reason: label);
        expect(paragraph.didExceedMaxLines, isFalse);
        scales.add(paragraph.textScaler.scale(10));
      }
      expect(scales, everyElement(scales.first));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tab glyphs use the board size of 23', (tester) async {
    await tester.pumpWidget(harness());
    expect(tester.widgetList<Icon>(find.byType(Icon)).map((icon) => icon.size),
        everyElement(23));
  });

  for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
    testWidgets('every tab accepts keyboard ${key.keyLabel}', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(harness(onTap: taps.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      for (var index = 0; index < 4; index++) {
        await tester.sendKeyEvent(key);
        await tester.pump();
        expect(taps, List<int>.generate(index + 1, (i) => i));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(tester.binding.transientCallbackCount, 0);
    });
  }

  for (final dark in [false, true]) {
    testWidgets(
        'unselected tab labels and icons use secondaryLabel, dark=$dark',
        (tester) async {
      await tester.pumpWidget(harness(dark: dark));
      final palette = dark ? PantasColors.dark : PantasColors.light;
      for (final label in ['Study', 'Quiz', 'Settings']) {
        final color = tester.widget<Text>(find.text(label)).style!.color!;
        expect(color, palette.secondaryLabel);
        final luminances = [
          color.computeLuminance(),
          palette.surface.computeLuminance()
        ]..sort();
        expect((luminances.last + 0.05) / (luminances.first + 0.05),
            greaterThanOrEqualTo(4.5));
      }
      expect(
          tester
              .widgetList<Icon>(find.byType(Icon))
              .skip(1)
              .map((icon) => icon.color),
          everyElement(palette.secondaryLabel));
    });
  }
}
