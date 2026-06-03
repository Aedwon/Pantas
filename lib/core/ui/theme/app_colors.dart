import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.rule,
    required this.ruleFaint,
    required this.board,
    required this.boardTint,
    required this.onBoard,
    required this.rust,
    required this.amber,
  });

  final Color background;
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final Color rule;
  final Color ruleFaint;
  final Color board;
  final Color boardTint;
  final Color onBoard;
  final Color rust;
  final Color amber;

  static const light = AppColors(
    background: Color(0xFFFBF9F4),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF26221B),
    inkMuted: Color(0xFF6E675C),
    rule: Color(0xFFE5DFD3),
    ruleFaint: Color(0xFFF1EDE4),
    board: Color(0xFF1D5C50),
    boardTint: Color(0xFFE3EFEA),
    onBoard: Color(0xFFFFFFFF),
    rust: Color(0xFFA33B2E),
    amber: Color(0xFF9A6B15),
  );

  static const dark = AppColors(
    background: Color(0xFF191613),
    surface: Color(0xFF211D18),
    ink: Color(0xFFEFEAE0),
    inkMuted: Color(0xFFA69C8C),
    rule: Color(0xFF38332B),
    ruleFaint: Color(0xFF2A2620),
    board: Color(0xFF4FA08D),
    boardTint: Color(0xFF22352F),
    onBoard: Color(0xFF14110D),
    rust: Color(0xFFD4705F),
    amber: Color(0xFFC99A45),
  );

  // Transitional aliases so pre-redesign screens compile until the Plan 2
  // sweep replaces them. Every alias intentionally lands on a new token —
  // pastel containers collapse to neutral ruleFaint by design.
  @Deprecated('Use ink') Color get onSurface => ink;
  @Deprecated('Use inkMuted') Color get onSurfaceMuted => inkMuted;
  @Deprecated('Use rule') Color get border => rule;
  @Deprecated('Use board') Color get borderSelected => board;
  @Deprecated('Use board') Color get primary => board;
  @Deprecated('Use boardTint') Color get primaryContainer => boardTint;
  @Deprecated('Use board') Color get success => board;
  @Deprecated('Use boardTint') Color get successContainer => boardTint;
  @Deprecated('Use amber') Color get warning => amber;
  @Deprecated('Use ruleFaint') Color get warningContainer => ruleFaint;
  @Deprecated('Use rust') Color get error => rust;
  @Deprecated('Use ruleFaint') Color get errorContainer => ruleFaint;

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
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      rule: rule ?? this.rule,
      ruleFaint: ruleFaint ?? this.ruleFaint,
      board: board ?? this.board,
      boardTint: boardTint ?? this.boardTint,
      onBoard: onBoard ?? this.onBoard,
      rust: rust ?? this.rust,
      amber: amber ?? this.amber,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      ruleFaint: Color.lerp(ruleFaint, other.ruleFaint, t)!,
      board: Color.lerp(board, other.board, t)!,
      boardTint: Color.lerp(boardTint, other.boardTint, t)!,
      onBoard: Color.lerp(onBoard, other.onBoard, t)!,
      rust: Color.lerp(rust, other.rust, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
    );
  }
}
