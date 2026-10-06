import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

@immutable
@Deprecated('W1 adapter, removed in W2 close-out')
abstract class AppColors extends ThemeExtension<AppColors> {
  @Deprecated('W1 adapter, removed in W2 close-out')
  const AppColors();
  @Deprecated('W1 adapter, removed in W2 close-out')
  const factory AppColors.fromTokens(PantasColors colors) = _AppColorsAdapter;

  static const light = _AppColorsAdapter(PantasColors.light);
  static const dark = _AppColorsAdapter(PantasColors.dark);
  Color get background;
  Color get surface;
  Color get ink;
  Color get inkMuted;
  Color get rule;
  Color get ruleFaint;
  Color get board;
  Color get boardTint;
  Color get onBoard;
  Color get rust;
  Color get amber;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? ink,
    Color? inkMuted,
    Color? rule,
    Color? ruleFaint,
    Color? board,
    Color? boardTint,
    Color? onBoard,
    Color? rust,
    Color? amber,
  });
}

class _AppColorsAdapter extends AppColors {
  const _AppColorsAdapter(this._colors);

  @override
  Object get type => AppColors;
  final PantasColors _colors;

  @override
  Color get background => _colors.background;
  @override
  Color get surface => _colors.surface;
  @override
  Color get ink => _colors.label;
  @override
  @override
  Color get inkMuted => _colors.secondaryLabel;
  @override
  Color get rule => _colors.separator;
  @override
  @override
  Color get ruleFaint => _colors.fill;
  @override
  Color get board => _colors.accent;
  @override
  @override
  Color get boardTint => _colors.accentTint;
  @override
  Color get onBoard => _colors.surface;
  @override
  Color get rust => _colors.destructive;
  @override
  Color get amber => _colors.pro;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? ink,
    Color? inkMuted,
    Color? rule,
    Color? ruleFaint,
    Color? board,
    Color? boardTint,
    Color? onBoard,
    Color? rust,
    Color? amber,
  }) =>
      _AppColorsAdapter(
        _colors.copyWith(
          background: background,
          surface: surface ?? onBoard,
          label: ink,
          secondaryLabel: inkMuted,
          separator: rule,
          fill: ruleFaint,
          accent: board,
          accentTint: boardTint,
          destructive: rust,
          pro: amber,
        ),
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    final tokens =
        other is PantasColors ? other : (other as _AppColorsAdapter)._colors;
    return _AppColorsAdapter(_colors.lerp(tokens, t));
  }
}
