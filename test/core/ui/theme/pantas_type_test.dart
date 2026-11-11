import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

void main() {
  group('PantasType holds the design system 4.0 styles', () {
    test('phone scale', () {
      const t = PantasType.phoneLargeTitle;
      expect(t.fontSize, 34);
      expect(t.fontWeight, FontWeight.w700);
      expect(t.fontFamily, 'Geist');
      expect(t.height, 1.12);
      expect(t.letterSpacing, closeTo(-0.748, 0.000001));
      expect(PantasType.phoneBody.fontSize, 17);
      expect(PantasType.phoneBody.letterSpacing, closeTo(-0.204, 0.000001));
      expect(PantasType.phoneCaptionSmall.fontSize, 10);
      expect(PantasType.phoneCaptionSmall.fontWeight, FontWeight.w600);
    });

    test('desktop scale', () {
      expect(PantasType.webH1.fontSize, 38);
      expect(PantasType.webH1.letterSpacing, closeTo(-0.912, 0.000001));
      expect(PantasType.webH2.fontSize, 26);
      expect(PantasType.webQuestion.fontSize, 27);
      expect(PantasType.webBigNumeral.fontSize, 40);
      expect(PantasType.webEyebrow.letterSpacing, closeTo(0.26, 0.000001));
    });

    test('numbers that align use tabular figures', () {
      expect(
        PantasType.webDisplay.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(
        PantasType.phoneDisplayM.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    });

    test('math display uses Source Serif 4', () {
      expect(PantasType.mathDisplay.fontFamily, 'Source Serif 4');
      expect(PantasType.mathDisplay.height, 1.4);
    });
  });

  group('PantasTypeBundle maps the old names to system styles', () {
    final type = PantasTypeBundle.create();
    final cases = <String, (TextStyle, double, FontWeight, double?)>{
      'largeTitle': (type.largeTitle, 34, FontWeight.w700, -0.748),
      'pageTitle': (type.pageTitle, 28, FontWeight.w700, -0.616),
      'pageTitleCompact': (type.pageTitleCompact, 28, FontWeight.w700, -0.616),
      'sectionHero': (type.sectionHero, 22, FontWeight.w700, -0.264),
      'body': (type.body, 17, FontWeight.w400, -0.204),
      'rowValue': (type.rowValue, 17, FontWeight.w400, -0.204),
      'emphasized': (type.emphasized, 17, FontWeight.w600, -0.204),
      'subhead': (type.subhead, 15, FontWeight.w400, null),
      'subheadStrong': (type.subheadStrong, 15, FontWeight.w600, null),
      'footnote': (type.footnote, 13, FontWeight.w400, null),
      'sectionHeader': (type.sectionHeader, 13, FontWeight.w600, 0.26),
      'caption': (type.caption, 12, FontWeight.w400, null),
      'captionSmall': (type.captionSmall, 10, FontWeight.w600, null),
      'captionStrong': (type.captionStrong, 10, FontWeight.w600, null),
    };
    for (final entry in cases.entries) {
      test('${entry.key} has the system metrics and a tabular variant', () {
        final (style, size, weight, spacing) = entry.value;
        expect(style.fontSize, size);
        expect(style.fontWeight, weight);
        expect(style.fontFamily, 'Geist');
        expect(style.letterSpacing ?? 0, closeTo(spacing ?? 0, 0.000001));
        expect(
          style.tabular.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
        expect(style.tabular.fontSize, style.fontSize);
      });
    }

    test('mathSerif keeps the KaTeX face until the reader moves', () {
      final style = type.mathSerif;
      expect(style.fontSize, 17);
      expect(style.fontWeight, FontWeight.w400);
      expect(style.fontFamily, 'packages/flutter_math_fork/KaTeX_Main');
      expect(style.letterSpacing, closeTo(0, 0.000001));
    });

    test('row value follows the palette secondary text', () {
      expect(type.rowValue.color, PantasColors.light.textSecondary);
      expect(
        PantasTypeBundle.create(colors: PantasColors.dark).rowValue.color,
        PantasColors.dark.textSecondary,
      );
    });
  });
}
