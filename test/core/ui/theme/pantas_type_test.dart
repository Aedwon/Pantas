import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

void main() {
  test('largeTitle has the approved type metrics and tabular variant', () {
    final style = PantasType.create().largeTitle;
    expect(style.fontSize, 34);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(-0.748, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('pageTitle has the approved type metrics and tabular variant', () {
    final style = PantasType.create().pageTitle;
    expect(style.fontSize, 30);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(-0.66, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('pageTitleCompact has the approved type metrics and tabular variant',
      () {
    final style = PantasType.create().pageTitleCompact;
    expect(style.fontSize, 28);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(-0.616, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('sectionHero has the approved type metrics and tabular variant', () {
    final style = PantasType.create().sectionHero;
    expect(style.fontSize, 24);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.fontFamily, 'Geist');
    expect(style.height, 1.35);
    expect(style.letterSpacing, closeTo(-0.288, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('body has the approved type metrics and tabular variant', () {
    final style = PantasType.create().body;
    expect(style.fontSize, 17);
    expect(style.fontWeight, FontWeight.w400);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(-0.204, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('rowValue has the approved type metrics and tabular variant', () {
    final style = PantasType.create().rowValue;
    expect(style.fontSize, 17);
    expect(style.fontWeight, FontWeight.w400);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(-0.204, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('emphasized has the approved type metrics and tabular variant', () {
    final style = PantasType.create().emphasized;
    expect(style.fontSize, 17);
    expect(style.fontWeight, FontWeight.w600);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(-0.204, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('subhead has the approved type metrics and tabular variant', () {
    final style = PantasType.create().subhead;
    expect(style.fontSize, 15);
    expect(style.fontWeight, FontWeight.w400);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(0, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('subheadStrong has the approved type metrics and tabular variant', () {
    final style = PantasType.create().subheadStrong;
    expect(style.fontSize, 15);
    expect(style.fontWeight, FontWeight.w600);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(0, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('footnote has the approved type metrics and tabular variant', () {
    final style = PantasType.create().footnote;
    expect(style.fontSize, 13);
    expect(style.fontWeight, FontWeight.w400);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(0, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('sectionHeader has the approved type metrics and tabular variant', () {
    final style = PantasType.create().sectionHeader;
    expect(style.fontSize, 13);
    expect(style.fontWeight, FontWeight.w600);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(0.26, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('caption has the approved type metrics and tabular variant', () {
    final style = PantasType.create().caption;
    expect(style.fontSize, 11);
    expect(style.fontWeight, FontWeight.w500);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(0, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('captionSmall has the approved type metrics and tabular variant', () {
    final style = PantasType.create().captionSmall;
    expect(style.fontSize, 10);
    expect(style.fontWeight, FontWeight.w500);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(0, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('captionStrong has the approved type metrics and tabular variant', () {
    final style = PantasType.create().captionStrong;
    expect(style.fontSize, 10);
    expect(style.fontWeight, FontWeight.w600);
    expect(style.fontFamily, 'Geist');
    expect(style.letterSpacing, closeTo(0, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('mathSerif has the approved type metrics and tabular variant', () {
    final style = PantasType.create().mathSerif;
    expect(style.fontSize, 17);
    expect(style.fontWeight, FontWeight.w400);
    expect(style.fontFamily, 'packages/flutter_math_fork/KaTeX_Main');
    expect(style.letterSpacing, closeTo(0, 0.000001));
    expect(
      style.tabular.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(style.tabular.fontSize, style.fontSize);
  });
  test('row value follows the palette secondary label', () {
    expect(
      PantasType.create().rowValue.color,
      PantasColors.light.secondaryLabel,
    );
    expect(
      PantasType.create(colors: PantasColors.dark).rowValue.color,
      PantasColors.dark.secondaryLabel,
    );
  });
}
