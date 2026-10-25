import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

@immutable
class PantasType extends ThemeExtension<PantasType> {
  const PantasType({
    required this.largeTitle,
    required this.pageTitle,
    required this.pageTitleCompact,
    required this.sectionHero,
    required this.body,
    required this.rowValue,
    required this.emphasized,
    required this.subhead,
    required this.subheadStrong,
    required this.footnote,
    required this.sectionHeader,
    required this.caption,
    required this.captionSmall,
    required this.captionStrong,
    required this.mathSerif,
  });

  factory PantasType.create({PantasColors colors = PantasColors.light}) =>
      PantasType(
        largeTitle: TextStyle(
          fontFamily: 'Geist',
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.748,
          height: 1.12,
          color: colors.label,
        ),
        pageTitle: TextStyle(
          fontFamily: 'Geist',
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.66,
          height: 1.12,
          color: colors.label,
        ),
        pageTitleCompact: TextStyle(
          fontFamily: 'Geist',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.616,
          height: 1.12,
          color: colors.label,
        ),
        sectionHero: TextStyle(
          fontFamily: 'Geist',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.288,
          height: 1.35,
          color: colors.label,
        ),
        body: TextStyle(
          fontFamily: 'Geist',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.204,
          height: 1.35,
          color: colors.label,
        ),
        rowValue: TextStyle(
          fontFamily: 'Geist',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.204,
          height: 1.35,
          color: colors.secondaryLabel,
        ),
        emphasized: TextStyle(
          fontFamily: 'Geist',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.204,
          height: 1.35,
          color: colors.label,
        ),
        subhead: TextStyle(
          fontFamily: 'Geist',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.35,
          color: colors.label,
        ),
        subheadStrong: TextStyle(
          fontFamily: 'Geist',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.35,
          color: colors.label,
        ),
        footnote: TextStyle(
          fontFamily: 'Geist',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.35,
          color: colors.secondaryLabel,
        ),
        sectionHeader: TextStyle(
          fontFamily: 'Geist',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.26,
          height: 1.35,
          color: colors.secondaryLabel,
        ),
        caption: TextStyle(
          fontFamily: 'Geist',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.35,
          color: colors.secondaryLabel,
        ),
        captionSmall: TextStyle(
          fontFamily: 'Geist',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.35,
          color: colors.secondaryLabel,
        ),
        captionStrong: TextStyle(
          fontFamily: 'Geist',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.35,
          color: colors.secondaryLabel,
        ),
        mathSerif: TextStyle(
          fontFamily: 'packages/flutter_math_fork/KaTeX_Main',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.5,
          color: colors.label,
        ),
      );

  final TextStyle largeTitle;
  final TextStyle pageTitle;
  final TextStyle pageTitleCompact;
  final TextStyle sectionHero;
  final TextStyle body;
  final TextStyle rowValue;
  final TextStyle emphasized;
  final TextStyle subhead;
  final TextStyle subheadStrong;
  final TextStyle footnote;
  final TextStyle sectionHeader;
  final TextStyle caption;
  final TextStyle captionSmall;
  final TextStyle captionStrong;
  final TextStyle mathSerif;

  @override
  PantasType copyWith({
    TextStyle? largeTitle,
    TextStyle? pageTitle,
    TextStyle? pageTitleCompact,
    TextStyle? sectionHero,
    TextStyle? body,
    TextStyle? rowValue,
    TextStyle? emphasized,
    TextStyle? subhead,
    TextStyle? subheadStrong,
    TextStyle? footnote,
    TextStyle? sectionHeader,
    TextStyle? caption,
    TextStyle? captionSmall,
    TextStyle? captionStrong,
    TextStyle? mathSerif,
  }) =>
      PantasType(
        largeTitle: largeTitle ?? this.largeTitle,
        pageTitle: pageTitle ?? this.pageTitle,
        pageTitleCompact: pageTitleCompact ?? this.pageTitleCompact,
        sectionHero: sectionHero ?? this.sectionHero,
        body: body ?? this.body,
        rowValue: rowValue ?? this.rowValue,
        emphasized: emphasized ?? this.emphasized,
        subhead: subhead ?? this.subhead,
        subheadStrong: subheadStrong ?? this.subheadStrong,
        footnote: footnote ?? this.footnote,
        sectionHeader: sectionHeader ?? this.sectionHeader,
        caption: caption ?? this.caption,
        captionSmall: captionSmall ?? this.captionSmall,
        captionStrong: captionStrong ?? this.captionStrong,
        mathSerif: mathSerif ?? this.mathSerif,
      );

  @override
  PantasType lerp(PantasType? other, double t) {
    if (other == null) return this;
    return PantasType(
      largeTitle: TextStyle.lerp(largeTitle, other.largeTitle, t)!,
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t)!,
      pageTitleCompact:
          TextStyle.lerp(pageTitleCompact, other.pageTitleCompact, t)!,
      sectionHero: TextStyle.lerp(sectionHero, other.sectionHero, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      rowValue: TextStyle.lerp(rowValue, other.rowValue, t)!,
      emphasized: TextStyle.lerp(emphasized, other.emphasized, t)!,
      subhead: TextStyle.lerp(subhead, other.subhead, t)!,
      subheadStrong: TextStyle.lerp(subheadStrong, other.subheadStrong, t)!,
      footnote: TextStyle.lerp(footnote, other.footnote, t)!,
      sectionHeader: TextStyle.lerp(sectionHeader, other.sectionHeader, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      captionSmall: TextStyle.lerp(captionSmall, other.captionSmall, t)!,
      captionStrong: TextStyle.lerp(captionStrong, other.captionStrong, t)!,
      mathSerif: TextStyle.lerp(mathSerif, other.mathSerif, t)!,
    );
  }
}

extension PantasTabularType on TextStyle {
  TextStyle get tabular => copyWith(
        fontFeatures: <FontFeature>{
          ...?fontFeatures,
          const FontFeature.tabularFigures(),
        }.toList(),
      );
}
