import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/legacy_theme_shim.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

void main() {
  test('light holds the design system 4.0 roles', () {
    const c = PantasColors.light;
    expect(c.bgPage, const Color(0xFFF5F5F7));
    expect(c.surfaceCard, const Color(0xFFFFFFFF));
    expect(c.textPrimary, const Color(0xFF1D1D1F));
    expect(c.textSecondary, const Color(0xFF6E6E73));
    expect(c.textDisabled, const Color(0xFFAEAEB2));
    expect(c.divider, const Color(0xFFE3E3E8));
    expect(c.fill, const Color(0xFFEDEDF0));
    expect(c.iconChevron, const Color(0xFF8E8E93));
    expect(c.accent, const Color(0xFF0B7A68));
    expect(c.accentFill, const Color(0xFF0B7A68));
    expect(c.accentTint, const Color(0xFFE4F1EE));
    expect(c.danger, const Color(0xFFD70015));
    expect(c.dangerTint, const Color(0xFFFDECEE));
    expect(c.pro, const Color(0xFFD9A400));
    expect(c.liquidStart, const Color(0xFF14937D));
    expect(c.liquidEnd, const Color(0xFF0B7A68));
  });

  test('dark holds the design system 4.0 roles', () {
    const c = PantasColors.dark;
    expect(c.bgPage, const Color(0xFF151515));
    expect(c.surfaceCard, const Color(0xFF1F1F1F));
    expect(c.textPrimary, const Color(0xFFF5F5F5));
    expect(c.textSecondary, const Color(0xFFA3A3A3));
    expect(c.textDisabled, const Color(0xFF6B6B6B));
    expect(c.divider, const Color(0xFF303030));
    expect(c.fill, const Color(0xFF303033));
    expect(c.iconChevron, const Color(0xFF949494));
    expect(c.accent, const Color(0xFF4CC3AC));
    expect(c.accentFill, const Color(0xFF0F8571));
    expect(c.accentTint, const Color(0xFF18332D));
    expect(c.danger, const Color(0xFFC44A46));
    expect(c.dangerTint, const Color(0xFF33201F));
    expect(c.pro, const Color(0xFFD9A400));
    expect(c.liquidStart, const Color(0xFF14937D));
    expect(c.liquidEnd, const Color(0xFF0B7A68));
  });

  test('surface and text roles copy and interpolate', () {
    const light = PantasColors.light;
    const dark = PantasColors.dark;
    expect(light.edgeCard, Colors.transparent);
    expect(light.surfaceSegmentOn, Colors.white);
    expect(dark.edgeCard, const Color(0xFF2A2A2A));
    expect(dark.surfaceSegmentOn, const Color(0xFF4A4A4A));
    expect(dark.accentTintText, const Color(0xFF7FD8C6));
    expect(dark.dangerText, const Color(0xFFE0706B));
    expect(dark.dangerBar, const Color(0xFF2E1E1D));
    expect(dark.onAccent, Colors.white);
    final copied = light.copyWith(
      edgeCard: dark.edgeCard,
      surfaceSegmentOn: dark.surfaceSegmentOn,
      accentTintText: dark.accentTintText,
    );
    final mixed = light.lerp(dark, 1);
    expect(copied.edgeCard, mixed.edgeCard);
    expect(copied.surfaceSegmentOn, mixed.surfaceSegmentOn);
    expect(copied.accentTintText, mixed.accentTintText);
  });

  test('copyWith replaces one role and lerp reaches the other theme', () {
    const light = PantasColors.light;
    const dark = PantasColors.dark;
    expect(light.copyWith(bgPage: Colors.pink).bgPage, Colors.pink);
    expect(light.copyWith(bgPage: Colors.pink).surfaceCard, light.surfaceCard);
    expect(light.lerp(dark, 1).bgPage, dark.bgPage);
    expect(light.lerp(dark, 1).textPrimary, dark.textPrimary);
    expect(light.lerp(dark, 1).dividerStrong, dark.dividerStrong);
    expect(light.lerp(null, .5).bgPage, light.bgPage);
  });

  test('legacy names read the role of the same meaning', () {
    for (final c in [PantasColors.light, PantasColors.dark]) {
      expect(c.background, c.bgPage);
      expect(c.surface, c.surfaceCard);
      expect(c.label, c.textPrimary);
      expect(c.secondaryLabel, c.textSecondary);
      expect(c.tertiaryLabel, c.textSecondary);
      expect(c.separator, c.divider);
      expect(c.chevron, c.iconChevron);
      expect(c.destructive, c.danger);
      expect(c.wrongTint, c.dangerTint);
      expect(c.cardEdge, c.edgeCard);
      expect(c.segmentOn, c.surfaceSegmentOn);
      expect(c.controlOutline, c.borderControl);
      expect(c.floatingRight, c.accentBar);
      expect(c.floatingWrong, c.dangerBar);
    }
  });
}
