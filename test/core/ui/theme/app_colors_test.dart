import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors.light', () {
    test('has correct primary color', () {
      expect(AppColors.light.primary, const Color(0xFF1F6BFF));
    });

    test('has correct surface color', () {
      expect(AppColors.light.surface, const Color(0xFFFFFFFF));
    });

    test('has correct background color', () {
      expect(AppColors.light.background, const Color(0xFFF8FAFC));
    });

    test('has correct success color', () {
      expect(AppColors.light.success, const Color(0xFF22C55E));
    });

    test('has correct warning color', () {
      expect(AppColors.light.warning, const Color(0xFFF59E0B));
    });

    test('has correct error color', () {
      expect(AppColors.light.error, const Color(0xFFEF4444));
    });
  });

  group('AppColors.dark', () {
    test('has adjusted primary color for dark mode', () {
      expect(AppColors.dark.primary, const Color(0xFF4D8FFF));
    });

    test('has correct dark surface color', () {
      expect(AppColors.dark.surface, const Color(0xFF1E293B));
    });

    test('has correct dark background color', () {
      expect(AppColors.dark.background, const Color(0xFF0F172A));
    });
  });

  group('AppColors.copyWith', () {
    test('copies with overridden primary', () {
      final copy = AppColors.light.copyWith(primary: const Color(0xFFFF0000));
      expect(copy.primary, const Color(0xFFFF0000));
      expect(copy.surface, AppColors.light.surface);
    });
  });

  group('AppColors.lerp', () {
    test('lerps between light and dark primary at t=0.5', () {
      final lerped = AppColors.light.lerp(AppColors.dark, 0.5);
      expect(lerped.primary,
          Color.lerp(AppColors.light.primary, AppColors.dark.primary, 0.5));
    });

    test('returns self when other is null', () {
      final lerped = AppColors.light.lerp(null, 0.5);
      expect(lerped.primary, AppColors.light.primary);
    });
  });
}
