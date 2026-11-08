// LEGACY: remove in family M. This file keeps the old field names compiling
// while screens move onto the generated token classes. Nothing new reads it.
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// Old `PantasColors` field names, mapped to the system role of the same
/// meaning. Names that are also system roles (`accent`, `fill`, `pro`, ...)
/// need no entry: they read the system value directly.
extension LegacyPantasColors on PantasColors {
  bool get _legacyDark => bgPage.computeLuminance() < 0.5;

  // LEGACY: remove in family M
  Color get background => bgPage;

  // LEGACY: remove in family M
  Color get surface => surfaceCard;

  // LEGACY: remove in family M
  Color get segmentOn => surfaceSegmentOn;

  // LEGACY: remove in family M
  Color get cardEdge => edgeCard;

  // LEGACY: remove in family M
  Color get label => textPrimary;

  // LEGACY: remove in family M
  Color get secondaryLabel => textSecondary;

  // LEGACY: remove in family M
  Color get tertiaryLabel => textSecondary;

  // LEGACY: remove in family M
  Color get disabledActionLabel => textDisabled;

  // LEGACY: remove in family M
  Color get separator => divider;

  // LEGACY: remove in family M
  Color get onFillLabel => textOnFill;

  // LEGACY: remove in family M
  Color get skeleton => fillSkeleton;

  // LEGACY: remove in family M
  Color get chevron => iconChevron;

  // LEGACY: remove in family M
  Color get destructive => danger;

  // LEGACY: remove in family M
  Color get wrongTint => dangerTint;

  // LEGACY: remove in family M
  Color get wrongText => dangerText;

  // LEGACY: remove in family M
  Color get controlOutline => borderControl;

  // LEGACY: remove in family M
  Color get pickerBackground => surfaceInset;

  // LEGACY: remove in family M
  Color get choiceOutline => borderControl;

  // LEGACY: remove in family M
  Color get toastBackground => toastBg;

  // LEGACY: remove in family M
  Color get onToast => toastText;

  // LEGACY: remove in family M
  Color get onDestructive => onDanger;

  // LEGACY: remove in family M
  Color get figureBackground => figureBg;

  // LEGACY: remove in family M
  Color get readerFigureBackground => figureReaderBg;

  // LEGACY: remove in family M
  Color get figureViewerBackground => figureViewerBg;

  // LEGACY: remove in family M
  Color get onFigureViewer => figureOnViewer;

  // LEGACY: remove in family M
  Color get floatingRight => accentBar;

  // LEGACY: remove in family M
  Color get floatingWrong => dangerBar;

  // LEGACY: remove in family M
  Color get inactiveDateLabel => textSecondary;

  // LEGACY: remove in family M
  Color get searchPlaceholder => textSecondary;

  // LEGACY: remove in family M
  Color get pendingMark => dividerStrong;

  // LEGACY: remove in family M
  Color get readerWarn => readerMistake;

  // LEGACY: remove in family M
  Color get readerWarnTint => readerMistakeTint;

  // LEGACY: remove in family M
  Color get readerWarnText => readerMistakeText;

  /// LEGACY: remove in family M. Board accuracy colors, clamped below 40% and
  /// above 80%. No system role: a computed ramp.
  Color accuracyTint(double accuracy) {
    final t = ((accuracy - .4) / .4).clamp(0.0, 1.0);
    return Color.fromARGB(
      255,
      (207 - 160 * t).round(),
      (232 - 89 * t).round(),
      (226 - 100 * t).round(),
    );
  }

  // LEGACY: remove in family M. No role: a literal black for shadows.
  Color get shadow => const Color(0xFF000000);

  // LEGACY: remove in family M
  Color get transparent => const Color(0x00000000);

  // LEGACY: remove in family M. Now `PantasShadow.knob`.
  Color get switchThumbShadow =>
      (_legacyDark ? PantasShadow.dark : PantasShadow.light).knob.first.color;

  // LEGACY: remove in family M. Now `PantasShadow.segment`.
  Color get segmentedShadow =>
      (_legacyDark ? PantasShadow.dark : PantasShadow.light)
          .segment
          .first
          .color;
}

/// LEGACY: remove in family M. The old `context.type` bundle: the 15 phone
/// styles with their color applied, each built from the system styles.
@immutable
class LegacyType extends ThemeExtension<LegacyType> {
  const LegacyType({
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

  factory LegacyType.create({PantasColors colors = PantasColors.light}) {
    final primary = colors.textPrimary;
    final secondary = colors.textSecondary;
    // The old styles always carried a letter spacing (0 when none).
    TextStyle flat(TextStyle s) =>
        s.letterSpacing == null ? s.copyWith(letterSpacing: 0) : s;
    return LegacyType(
      largeTitle: PantasType.phoneLargeTitle.copyWith(color: primary),
      pageTitle: PantasType.phoneTitle1.copyWith(color: primary),
      pageTitleCompact: PantasType.phoneTitle1.copyWith(color: primary),
      sectionHero: PantasType.phoneTitle2.copyWith(color: primary),
      body: PantasType.phoneBody.copyWith(color: primary),
      rowValue: PantasType.phoneBody.copyWith(color: secondary),
      emphasized: PantasType.phoneHeadline.copyWith(color: primary),
      subhead: flat(PantasType.phoneExplanation).copyWith(
        height: 1.35,
        color: primary,
      ),
      subheadStrong: flat(PantasType.phoneExplanation).copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: primary,
      ),
      footnote: flat(PantasType.phoneFootnote).copyWith(color: secondary),
      sectionHeader: PantasType.phoneSectionHeader.copyWith(color: secondary),
      caption: flat(PantasType.phoneCaption).copyWith(color: secondary),
      captionSmall:
          flat(PantasType.phoneCaptionSmall).copyWith(color: secondary),
      captionStrong:
          flat(PantasType.phoneCaptionSmall).copyWith(color: secondary),
      // Math keeps the KaTeX face until the reader moves to Source Serif 4.
      mathSerif: PantasType.phoneBody.copyWith(
        fontFamily: 'packages/flutter_math_fork/KaTeX_Main',
        height: 1.5,
        letterSpacing: 0,
        color: primary,
      ),
    );
  }

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
  LegacyType copyWith({
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
      LegacyType(
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
  LegacyType lerp(LegacyType? other, double t) {
    if (other == null) return this;
    return LegacyType(
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

/// LEGACY: remove in family M.
extension PantasTabularType on TextStyle {
  TextStyle get tabular => copyWith(
        fontFeatures: <FontFeature>{
          ...?fontFeatures,
          const FontFeature.tabularFigures(),
        }.toList(),
      );
}

/// LEGACY: remove in family M. The four curves with no system token
/// (`popA`, `shake`, `easeOut`, `easeInOut`) and the step curve.
abstract final class LegacyCurves {
  static const popA = Cubic(0.3, 1.4, 0.5, 1);
  static const shake = Cubic(0.36, 0.07, 0.19, 0.97);
  static const easeOut = Cubic(0, 0, 0.58, 1);
  static const easeInOut = Cubic(0.42, 0, 0.58, 1);

  static Curve steps(int count) => _Steps(count);
}

class _Steps extends Curve {
  const _Steps(this.count) : assert(count > 0, 'steps must be positive');
  final int count;
  @override
  double transformInternal(double t) => (t * count).floor() / count;
}
