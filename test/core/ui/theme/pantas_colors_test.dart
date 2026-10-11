import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

void main() {
  test('light matches every README color token', () {
    const c = PantasColors.light;
    expect(c.background, const Color(0xFFF5F5F7));
    expect(c.surface, const Color(0xFFFFFFFF));
    expect(c.label, const Color(0xFF1D1D1F));
    expect(c.secondaryLabel, const Color(0xFF6E6E73));
    expect(c.tertiaryLabel, const Color(0xFFAEAEB2));
    expect(c.separator, const Color(0xFFE3E3E8));
    expect(c.fill, const Color(0xFFEDEDF0));
    expect(c.chevron, const Color(0xFFC7C7CC));
    expect(c.accent, const Color(0xFF0B7A68));
    expect(c.accentFill, const Color(0xFF0B7A68));
    expect(c.accentTint, const Color(0xFFE4F1EE));
    expect(c.destructive, const Color(0xFFD70015));
    expect(c.wrongTint, const Color(0xFFFDECEE));
    expect(c.pro, const Color(0xFFD9A400));
    expect(c.liquidStart, const Color(0xFF14937D));
    expect(c.liquidEnd, const Color(0xFF0B7A68));
  });
  test('dark matches every README color token', () {
    const c = PantasColors.dark;
    expect(c.background, const Color(0xFF000000));
    expect(c.surface, const Color(0xFF1C1C1E));
    expect(c.label, const Color(0xFFF5F5F7));
    expect(c.secondaryLabel, const Color(0xFF98989D));
    expect(c.tertiaryLabel, const Color(0xFF5A5A5E));
    expect(c.separator, const Color(0xFF38383A));
    expect(c.fill, const Color(0xFF2C2C2E));
    expect(c.chevron, const Color(0xFF48484A));
    expect(c.accent, const Color(0xFF2FB39C));
    expect(c.accentFill, const Color(0xFF1F9C86));
    expect(c.accentTint, const Color(0xFF123F37));
    expect(c.destructive, const Color(0xFFD70015));
    expect(c.wrongTint, const Color(0xFF3A1215));
    expect(c.pro, const Color(0xFFD9A400));
    expect(c.liquidStart, const Color(0xFF14937D));
    expect(c.liquidEnd, const Color(0xFF0B7A68));
  });
  test('copy and interpolation preserve all token fields', () {
    expect(
      PantasColors.light.copyWith(background: Colors.pink).background,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).background,
      PantasColors.dark.background,
    );
    expect(
      PantasColors.light.copyWith(surface: Colors.pink).surface,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).surface,
      PantasColors.dark.surface,
    );
    expect(PantasColors.light.copyWith(label: Colors.pink).label, Colors.pink);
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).label,
      PantasColors.dark.label,
    );
    expect(
      PantasColors.light.copyWith(secondaryLabel: Colors.pink).secondaryLabel,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).secondaryLabel,
      PantasColors.dark.secondaryLabel,
    );
    expect(
      PantasColors.light.copyWith(tertiaryLabel: Colors.pink).tertiaryLabel,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).tertiaryLabel,
      PantasColors.dark.tertiaryLabel,
    );
    expect(
      PantasColors.light.copyWith(separator: Colors.pink).separator,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).separator,
      PantasColors.dark.separator,
    );
    expect(PantasColors.light.copyWith(fill: Colors.pink).fill, Colors.pink);
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).fill,
      PantasColors.dark.fill,
    );
    expect(
      PantasColors.light.copyWith(chevron: Colors.pink).chevron,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).chevron,
      PantasColors.dark.chevron,
    );
    expect(
      PantasColors.light.copyWith(accent: Colors.pink).accent,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).accent,
      PantasColors.dark.accent,
    );
    expect(
      PantasColors.light.copyWith(accentFill: Colors.pink).accentFill,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).accentFill,
      PantasColors.dark.accentFill,
    );
    expect(
      PantasColors.light.copyWith(accentTint: Colors.pink).accentTint,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).accentTint,
      PantasColors.dark.accentTint,
    );
    expect(
      PantasColors.light.copyWith(destructive: Colors.pink).destructive,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).destructive,
      PantasColors.dark.destructive,
    );
    expect(
      PantasColors.light.copyWith(wrongTint: Colors.pink).wrongTint,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).wrongTint,
      PantasColors.dark.wrongTint,
    );
    expect(PantasColors.light.copyWith(pro: Colors.pink).pro, Colors.pink);
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).pro,
      PantasColors.dark.pro,
    );
    expect(
      PantasColors.light.copyWith(liquidStart: Colors.pink).liquidStart,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).liquidStart,
      PantasColors.dark.liquidStart,
    );
    expect(
      PantasColors.light.copyWith(liquidEnd: Colors.pink).liquidEnd,
      Colors.pink,
    );
    expect(
      PantasColors.light.lerp(PantasColors.dark, 1).liquidEnd,
      PantasColors.dark.liquidEnd,
    );
  });
}
