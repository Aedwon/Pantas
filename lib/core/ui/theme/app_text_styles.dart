import 'package:flutter/material.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.displayLarge,
    required this.displaySmall,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelSmall,
    required this.mathBody,
  });

  factory AppTextStyles.create() => const AppTextStyles(
        displayLarge: TextStyle(
          fontFamily: 'SourceSerif4',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SourceSerif4',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SourceSerif4',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SourceSerif4',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.3,
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
        bodySmall: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
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
          fontFamily: 'SourceSerif4',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      );

  final TextStyle displayLarge;
  final TextStyle displaySmall;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelSmall;
  final TextStyle mathBody;

  @override
  AppTextStyles copyWith({
    TextStyle? displayLarge,
    TextStyle? displaySmall,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelSmall,
    TextStyle? mathBody,
  }) {
    return AppTextStyles(
      displayLarge: displayLarge ?? this.displayLarge,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
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
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      mathBody: TextStyle.lerp(mathBody, other.mathBody, t)!,
    );
  }
}
