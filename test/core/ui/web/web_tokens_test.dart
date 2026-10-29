import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

void main() {
  test('web light uses handoff tokens', () {
    const t = WebTokens(Brightness.light);
    expect(t.colors.background, const Color(0xFFF5F5F7));
    expect(t.colors.surface, Colors.white);
    expect(t.colors.label, const Color(0xFF1D1D1F));
    expect(t.colors.secondaryLabel, const Color(0xFF6E6E73));
    expect(t.colors.separator, const Color(0xFFE3E3E8));
    expect(t.colors.accent, const Color(0xFF0B7A68));
    expect(t.colors.accentTint, const Color(0xFFE4F1EE));
    expect(t.colors.destructive, const Color(0xFFD70015));
    expect(t.colors.tertiaryLabel, const Color(0xFF8A8A8E));
    expect(t.colors.wrongTint, const Color(0xFFFDE8EA));
    expect(t.accentHover, const Color(0xFF086A5A));
  });
  test('web dark overrides every destructive and wrong role', () {
    const t = WebTokens(Brightness.dark);
    expect(t.colors.background, const Color(0xFF151515));
    expect(t.colors.surface, const Color(0xFF1F1F1F));
    expect(t.colors.fill, const Color(0xFF2A2A2A));
    expect(t.colors.label, const Color(0xFFF5F5F5));
    expect(t.colors.secondaryLabel, const Color(0xFFA3A3A3));
    expect(t.colors.tertiaryLabel, const Color(0xFF949494));
    expect(t.colors.separator, const Color(0xFF303030));
    expect(t.colors.accentFill, const Color(0xFF0F8571));
    expect(t.colors.accent, const Color(0xFF4CC3AC));
    expect(t.colors.accentTint, const Color(0xFF18332D));
    expect(t.tintText, const Color(0xFF7FD8C6));
    expect(t.colors.destructive, const Color(0xFFC44A46));
    expect(t.colors.wrongText, const Color(0xFFE0706B));
    expect(t.colors.wrongTint, const Color(0xFF33201F));
    expect(t.colors.floatingWrong, const Color(0xFF2E1E1D));
    expect(t.cardEdge, const Color(0xFF2C2C2C));
    expect(t.strongDivider, const Color(0xFF3D3D3D));
    expect(t.segmentOn, const Color(0xFF4A4A4A));
    expect(t.colors.onAccent, Colors.white);
  });
  test('web themes install the light and dark handoff palette', () {
    expect(
      buildDarkTheme(web: true).extension<PantasColors>()!.background,
      const Color(0xFF151515),
    );
    expect(
      buildLightTheme(web: true).extension<PantasColors>()!.wrongTint,
      const Color(0xFFFDE8EA),
    );
  });
  test('native themes retain their existing palette', () {
    expect(buildDarkTheme().extension<PantasColors>(), PantasColors.dark);
    expect(buildLightTheme().extension<PantasColors>(), PantasColors.light);
  });
}
