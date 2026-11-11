// Screen-facing names for the design system: the color names screens read
// through `context.colors`, the phone type bundle behind `context.type`, the
// tabular figures switch, and the board easing curves that have no system
// token. Every value comes from the generated contract in `tokens/`.
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// Screen-facing `PantasColors` names, each mapped to the system role of the
/// same meaning. Names that are also system roles (`accent`, `fill`, `pro`,
/// ...) need no entry: they read the system value directly.
extension PantasColorNames on PantasColors {
  Color get background => bgPage;

  Color get surface => surfaceCard;

  Color get segmentOn => surfaceSegmentOn;

  Color get cardEdge => edgeCard;

  Color get label => textPrimary;

  Color get secondaryLabel => textSecondary;

  Color get tertiaryLabel => textSecondary;

  Color get disabledActionLabel => textDisabled;

  Color get separator => divider;

  Color get onFillLabel => textOnFill;

  Color get skeleton => fillSkeleton;

  Color get chevron => iconChevron;

  Color get destructive => danger;

  Color get wrongTint => dangerTint;

  Color get wrongText => dangerText;

  Color get controlOutline => borderControl;

  Color get pickerBackground => surfaceInset;

  Color get toastBackground => toastBg;

  Color get onToast => toastText;

  Color get onDestructive => onDanger;

  Color get figureBackground => figureBg;

  Color get readerFigureBackground => figureReaderBg;

  Color get figureViewerBackground => figureViewerBg;

  Color get onFigureViewer => figureOnViewer;

  Color get floatingRight => accentBar;

  Color get floatingWrong => dangerBar;

  Color get pendingMark => dividerStrong;

  Color get readerWarn => readerMistake;

  Color get readerWarnTint => readerMistakeTint;

  Color get readerWarnText => readerMistakeText;

  /// No role: a literal black for shadows and scrims.
  Color get shadow => const Color(0xFF000000);

  Color get transparent => const Color(0x00000000);

  Color get choiceOutline => borderControl;

  Color get inactiveDateLabel => textSecondary;

  Color get searchPlaceholder => textSecondary;

  /// Board accuracy colors, clamped below 40% and
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

  /// The knob shadow, `PantasShadow.knob`.
  Color get switchThumbShadow =>
      (_isDark ? PantasShadow.dark : PantasShadow.light).knob.first.color;

  /// The segment shadow, `PantasShadow.segment`.
  Color get segmentedShadow =>
      (_isDark ? PantasShadow.dark : PantasShadow.light).segment.first.color;

  bool get _isDark => bgPage.computeLuminance() < 0.5;
}

/// The `context.type` bundle: the 15 phone styles with their color applied,
/// each built from the system styles.
@immutable
class PantasTypeBundle extends ThemeExtension<PantasTypeBundle> {
  const PantasTypeBundle({
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

  factory PantasTypeBundle.create({PantasColors colors = PantasColors.light}) {
    final primary = colors.textPrimary;
    final secondary = colors.textSecondary;
    // The old styles always carried a letter spacing (0 when none).
    TextStyle flat(TextStyle s) =>
        s.letterSpacing == null ? s.copyWith(letterSpacing: 0) : s;
    return PantasTypeBundle(
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
  PantasTypeBundle copyWith({
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
      PantasTypeBundle(
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
  PantasTypeBundle lerp(PantasTypeBundle? other, double t) {
    if (other == null) return this;
    return PantasTypeBundle(
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

/// Switches a style to tabular figures.
extension PantasTabularType on TextStyle {
  TextStyle get tabular => copyWith(
        fontFeatures: <FontFeature>{
          ...?fontFeatures,
          const FontFeature.tabularFigures(),
        }.toList(),
      );
}

/// The four board curves with no system token (`popA`, `shake`, `easeOut`,
/// `easeInOut`) and the step curve.
abstract final class PantasBoardCurves {
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
