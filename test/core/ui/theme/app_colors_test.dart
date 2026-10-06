import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';

void main() {
  test('light palette matches the new light tokens', () {
    const c = AppColors.light;
    expect(c.background, const Color(0xFFF5F5F7));
    expect(c.surface, const Color(0xFFFFFFFF));
    expect(c.ink, const Color(0xFF1D1D1F));
    expect(c.inkMuted, const Color(0xFF6E6E73));
    expect(c.rule, const Color(0xFFE3E3E8));
    expect(c.ruleFaint, const Color(0xFFEDEDF0));
    expect(c.board, const Color(0xFF0B7A68));
    expect(c.boardTint, const Color(0xFFE4F1EE));
    expect(c.onBoard, const Color(0xFFFFFFFF));
    expect(c.rust, const Color(0xFFD70015));
    expect(c.amber, const Color(0xFFD9A400));
  });

  test('dark palette matches the new dark tokens', () {
    const c = AppColors.dark;
    expect(c.background, const Color(0xFF000000));
    expect(c.surface, const Color(0xFF1C1C1E));
    expect(c.ink, const Color(0xFFF5F5F7));
    expect(c.inkMuted, const Color(0xFF98989D));
    expect(c.rule, const Color(0xFF38383A));
    expect(c.ruleFaint, const Color(0xFF2C2C2E));
    expect(c.board, const Color(0xFF2FB39C));
    expect(c.boardTint, const Color(0xFF123F37));
    expect(c.onBoard, const Color(0xFF1C1C1E));
    expect(c.rust, const Color(0xFFD70015));
    expect(c.amber, const Color(0xFFD9A400));
  });

  test('lerp at t=1 lands exactly on the other palette', () {
    final lerped = AppColors.light.lerp(AppColors.dark, 1);
    expect(lerped.background, AppColors.dark.background);
    expect(lerped.surface, AppColors.dark.surface);
    expect(lerped.ink, AppColors.dark.ink);
    expect(lerped.inkMuted, AppColors.dark.inkMuted);
    expect(lerped.rule, AppColors.dark.rule);
    expect(lerped.ruleFaint, AppColors.dark.ruleFaint);
    expect(lerped.board, AppColors.dark.board);
    expect(lerped.boardTint, AppColors.dark.boardTint);
    expect(lerped.onBoard, AppColors.dark.onBoard);
    expect(lerped.rust, AppColors.dark.rust);
    expect(lerped.amber, AppColors.dark.amber);
  });

  test('label clears normal-text contrast on both backgrounds', () {
    double contrast(Color foreground, Color background) {
      final lighter =
          foreground.computeLuminance() > background.computeLuminance()
              ? foreground
              : background;
      final darker = foreground == lighter ? background : foreground;
      return (lighter.computeLuminance() + 0.05) /
          (darker.computeLuminance() + 0.05);
    }

    expect(
      contrast(AppColors.light.ink, AppColors.light.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppColors.dark.ink, AppColors.dark.background),
      greaterThanOrEqualTo(4.5),
    );
  });
}
