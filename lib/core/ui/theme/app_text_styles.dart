import 'package:flutter/material.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodyRegular,
    required this.bodySmall,
    required this.captionSmall,
    required this.labelLarge,
    required this.labelSmall,
    required this.mathBody,
  });

  /// One family, everywhere.
  ///
  /// Aedwon, 10 August: the serif was *"an eyesore"*, and a reader who is
  /// noticing the type is not reading the lesson. The argument for it was
  /// that Ink and Rule is a printed page; his answer was that the point of
  /// the printed page was to be quiet and distraction free, so a typeface
  /// that irritates defeats the purpose the serif was there to serve.
  ///
  /// **What carries the identity now is not the type.** It is the hairline
  /// rules, the underlined section heads, the tabular figures, the absence
  /// of tinted callouts and rounded cards. Those are what keep this from
  /// looking like every other study app, and they matter more now, not less.
  ///
  /// Hierarchy has to come from size, weight and space alone. The display
  /// sizes are tracked tighter than a default so they read as set rather
  /// than as typed.
  factory AppTextStyles.create() => const AppTextStyles(
        displayLarge: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.4,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.35,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        titleSmall: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.45,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyRegular: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        captionSmall: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 11.5,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        labelSmall: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        mathBody: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      );

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodyRegular;
  final TextStyle bodySmall;
  final TextStyle captionSmall;
  final TextStyle labelLarge;
  final TextStyle labelSmall;
  final TextStyle mathBody;

  @override
  AppTextStyles copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodyRegular,
    TextStyle? bodySmall,
    TextStyle? captionSmall,
    TextStyle? labelLarge,
    TextStyle? labelSmall,
    TextStyle? mathBody,
  }) {
    return AppTextStyles(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodyRegular: bodyRegular ?? this.bodyRegular,
      bodySmall: bodySmall ?? this.bodySmall,
      captionSmall: captionSmall ?? this.captionSmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelSmall: labelSmall ?? this.labelSmall,
      mathBody: mathBody ?? this.mathBody,
    );
  }

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodyRegular: TextStyle.lerp(bodyRegular, other.bodyRegular, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      captionSmall: TextStyle.lerp(captionSmall, other.captionSmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      mathBody: TextStyle.lerp(mathBody, other.mathBody, t)!,
    );
  }
}
