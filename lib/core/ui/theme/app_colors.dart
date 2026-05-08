import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface,
    required this.background,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.border,
    required this.borderSelected,
    required this.primaryContainer,
    required this.successContainer,
    required this.errorContainer,
    required this.warningContainer,
    required this.primary,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color surface;
  final Color background;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color border;
  final Color borderSelected;
  final Color primaryContainer;
  final Color successContainer;
  final Color errorContainer;
  final Color warningContainer;
  final Color primary;
  final Color success;
  final Color warning;
  final Color error;

  static const light = AppColors(
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF8FAFC),
    onSurface: Color(0xFF1E293B),
    onSurfaceMuted: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
    borderSelected: Color(0xFF1F6BFF),
    primaryContainer: Color(0xFFEFF6FF),
    successContainer: Color(0xFFF0FDF4),
    errorContainer: Color(0xFFFEF2F2),
    warningContainer: Color(0xFFFFFBEB),
    primary: Color(0xFF1F6BFF),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
  );

  static const dark = AppColors(
    surface: Color(0xFF1E293B),
    background: Color(0xFF0F172A),
    onSurface: Color(0xFFF1F5F9),
    onSurfaceMuted: Color(0xFF94A3B8),
    border: Color(0xFF334155),
    borderSelected: Color(0xFF4D8FFF),
    primaryContainer: Color(0xFF1E3A70),
    successContainer: Color(0xFF14532D),
    errorContainer: Color(0xFF450A0A),
    warningContainer: Color(0xFF451A03),
    primary: Color(0xFF4D8FFF),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFCD34D),
    error: Color(0xFFF87171),
  );

  @override
  AppColors copyWith({
    Color? surface,
    Color? background,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? border,
    Color? borderSelected,
    Color? primaryContainer,
    Color? successContainer,
    Color? errorContainer,
    Color? warningContainer,
    Color? primary,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      background: background ?? this.background,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      border: border ?? this.border,
      borderSelected: borderSelected ?? this.borderSelected,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      successContainer: successContainer ?? this.successContainer,
      errorContainer: errorContainer ?? this.errorContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      primary: primary ?? this.primary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSelected: Color.lerp(borderSelected, other.borderSelected, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
