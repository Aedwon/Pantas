import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light palette matches the Paper spec', () {
    const c = AppColors.light;
    expect(c.background, const Color(0xFFFBF9F4));
    expect(c.surface, const Color(0xFFFFFFFF));
    expect(c.ink, const Color(0xFF26221B));
    expect(c.inkMuted, const Color(0xFF6E675C));
    expect(c.rule, const Color(0xFFE5DFD3));
    expect(c.ruleFaint, const Color(0xFFF1EDE4));
    expect(c.board, const Color(0xFF1D5C50));
    expect(c.boardTint, const Color(0xFFE3EFEA));
    expect(c.onBoard, const Color(0xFFFFFFFF));
    expect(c.rust, const Color(0xFFA33B2E));
    expect(c.amber, const Color(0xFF9A6B15));
  });

  test('dark palette matches the Night spec', () {
    const c = AppColors.dark;
    expect(c.background, const Color(0xFF191613));
    expect(c.surface, const Color(0xFF211D18));
    expect(c.ink, const Color(0xFFEFEAE0));
    expect(c.inkMuted, const Color(0xFFA69C8C));
    expect(c.rule, const Color(0xFF38332B));
    expect(c.ruleFaint, const Color(0xFF2A2620));
    expect(c.board, const Color(0xFF4FA08D));
    expect(c.boardTint, const Color(0xFF22352F));
    expect(c.onBoard, const Color(0xFF14110D));
    expect(c.rust, const Color(0xFFD4705F));
    expect(c.amber, const Color(0xFFC99A45));
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
}
