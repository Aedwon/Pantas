import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';

@immutable
class PantasColors extends AppColors {
  const PantasColors({
    required this.background,
    required this.surface,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.separator,
    required this.fill,
    required this.chevron,
    required this.accent,
    required this.accentFill,
    required this.accentTint,
    required this.destructive,
    required this.wrongTint,
    required this.pro,
    required this.liquidStart,
    required this.liquidEnd,
  });

  @override
  final Color background;
  @override
  final Color surface;
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color separator;
  final Color fill;
  final Color chevron;
  final Color accent;
  final Color accentFill;
  final Color accentTint;
  final Color destructive;
  final Color wrongTint;
  final Color pro;
  final Color liquidStart;
  final Color liquidEnd;

  static const light = PantasColors(
    background: Color(0xFFF5F5F7),
    surface: Color(0xFFFFFFFF),
    label: Color(0xFF1D1D1F),
    secondaryLabel: Color(0xFF6E6E73),
    tertiaryLabel: Color(0xFFAEAEB2),
    separator: Color(0xFFE3E3E8),
    fill: Color(0xFFEDEDF0),
    chevron: Color(0xFFC7C7CC),
    accent: Color(0xFF0B7A68),
    accentFill: Color(0xFF0B7A68),
    accentTint: Color(0xFFE4F1EE),
    destructive: Color(0xFFD70015),
    wrongTint: Color(0xFFFDECEE),
    pro: Color(0xFFD9A400),
    liquidStart: Color(0xFF14937D),
    liquidEnd: Color(0xFF0B7A68),
  );

  static const dark = PantasColors(
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    label: Color(0xFFF5F5F7),
    secondaryLabel: Color(0xFF98989D),
    tertiaryLabel: Color(0xFF5A5A5E),
    separator: Color(0xFF38383A),
    fill: Color(0xFF2C2C2E),
    chevron: Color(0xFF48484A),
    accent: Color(0xFF2FB39C),
    accentFill: Color(0xFF1F9C86),
    accentTint: Color(0xFF123F37),
    destructive: Color(0xFFD70015),
    wrongTint: Color(0xFF3A1215),
    pro: Color(0xFFD9A400),
    liquidStart: Color(0xFF14937D),
    liquidEnd: Color(0xFF0B7A68),
  );

  @override
  Object get type => PantasColors;

  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get ink => label;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get inkMuted => secondaryLabel;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get rule => separator;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get ruleFaint => fill;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get board => accent;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get boardTint => accentTint;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get onBoard => surface;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get rust => destructive;
  @override
  @Deprecated('W1 adapter, removed in W2 close-out')
  Color get amber => pro;

  @override
  PantasColors copyWith({
    Color? background,
    Color? surface,
    Color? label,
    Color? secondaryLabel,
    Color? tertiaryLabel,
    Color? separator,
    Color? fill,
    Color? chevron,
    Color? accent,
    Color? accentFill,
    Color? accentTint,
    Color? destructive,
    Color? wrongTint,
    Color? pro,
    Color? liquidStart,
    Color? liquidEnd,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? ink,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? inkMuted,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? rule,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? ruleFaint,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? board,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? boardTint,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? onBoard,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? rust,
    @Deprecated('W1 adapter, removed in W2 close-out') Color? amber,
  }) =>
      PantasColors(
        background: background ?? this.background,
        surface: surface ?? onBoard ?? this.surface,
        label: label ?? ink ?? this.label,
        secondaryLabel: secondaryLabel ?? inkMuted ?? this.secondaryLabel,
        tertiaryLabel: tertiaryLabel ?? this.tertiaryLabel,
        separator: separator ?? rule ?? this.separator,
        fill: fill ?? ruleFaint ?? this.fill,
        chevron: chevron ?? this.chevron,
        accent: accent ?? board ?? this.accent,
        accentFill: accentFill ?? this.accentFill,
        accentTint: accentTint ?? boardTint ?? this.accentTint,
        destructive: destructive ?? rust ?? this.destructive,
        wrongTint: wrongTint ?? this.wrongTint,
        pro: pro ?? amber ?? this.pro,
        liquidStart: liquidStart ?? this.liquidStart,
        liquidEnd: liquidEnd ?? this.liquidEnd,
      );

  @override
  PantasColors lerp(covariant PantasColors? other, double t) {
    if (other == null) return this;
    return PantasColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      label: Color.lerp(label, other.label, t)!,
      secondaryLabel: Color.lerp(secondaryLabel, other.secondaryLabel, t)!,
      tertiaryLabel: Color.lerp(tertiaryLabel, other.tertiaryLabel, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      chevron: Color.lerp(chevron, other.chevron, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentFill: Color.lerp(accentFill, other.accentFill, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      wrongTint: Color.lerp(wrongTint, other.wrongTint, t)!,
      pro: Color.lerp(pro, other.pro, t)!,
      liquidStart: Color.lerp(liquidStart, other.liquidStart, t)!,
      liquidEnd: Color.lerp(liquidEnd, other.liquidEnd, t)!,
    );
  }
}
