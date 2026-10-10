import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

@immutable
@Deprecated('W1 adapter, removed in W2 close-out')
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  @Deprecated('W1 adapter, removed in W2 close-out')
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

  @Deprecated('W1 adapter, removed in W2 close-out')
  factory AppTextStyles.create({PantasType? type}) {
    final tokens = type ?? PantasType.create();
    return AppTextStyles(
      displayLarge: tokens.largeTitle,
      displayMedium: tokens.pageTitle,
      displaySmall: tokens.sectionHero,
      headlineLarge: tokens.sectionHero,
      headlineMedium: tokens.sectionHero,
      headlineSmall: tokens.emphasized,
      titleSmall: tokens.subheadStrong,
      bodyLarge: tokens.body,
      bodyMedium: tokens.subhead,
      bodyRegular: tokens.body,
      bodySmall: tokens.subhead,
      captionSmall: tokens.caption,
      labelLarge: tokens.sectionHeader,
      labelSmall: tokens.footnote,
      mathBody: tokens.mathSerif,
    );
  }

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
