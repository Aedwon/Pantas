# Frontend Foundation Implementation Plan

> **Pricing superseded (4 October 2026).** Prices, plans, and products in this file are historical. The only current prices are in `docs/pricing.md`. Do not quote or implement a price from this file.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete UI foundation — color/typography/spacing tokens, 12 core components, and the 3-tab navigation shell — so every subsequent feature plan can import from `core/ui/` rather than defining its own primitives.

**Architecture:** Token-first: `AppColors` and `AppTextStyles` are `ThemeExtension`s registered on both light and dark `ThemeData`; components read tokens via `context.colors` / `context.textStyles` and never touch raw hex. The 3-tab shell uses `go_router`'s `StatefulShellRoute` so each tab maintains its own navigation stack. All components have widget tests using a shared `pumpApp` helper that supplies the full token-aware theme.

**Tech Stack:** Flutter 3.41.x / Dart 3.11.x, `google_fonts ^6.2.1`, `flutter_math_fork ^0.7.2`, `go_router ^14.0.0`, `flutter_test`, `mocktail ^1.0.4`

---

## File Map

**New files:**
```
lib/core/ui/theme/app_colors.dart           AppColors ThemeExtension (light + dark)
lib/core/ui/theme/app_text_styles.dart      AppTextStyles ThemeExtension (Poppins + Noto Serif)
lib/core/ui/theme/app_dimensions.dart       Spacing/radius/shadow constants
lib/core/ui/theme/app_theme.dart            buildLightTheme() + buildDarkTheme() + BuildContext extensions
lib/core/ui/components/app_button.dart
lib/core/ui/components/quiz_answer_tile.dart
lib/core/ui/components/app_card.dart
lib/core/ui/components/empty_state.dart
lib/core/ui/components/error_banner.dart
lib/core/ui/components/inline_offline_banner.dart
lib/core/ui/components/coach_mark.dart
lib/core/ui/components/confirmation_dialog.dart
lib/core/ui/components/streak_banner.dart
lib/core/ui/components/pro_gate_banner.dart
lib/core/ui/components/skeleton_loader.dart
lib/core/ui/components/sync_status_indicator.dart
lib/features/shell/presentation/app_shell.dart

test/helpers/pump_app.dart                  Shared widget-test helper
test/core/ui/theme/app_colors_test.dart
test/core/ui/theme/app_text_styles_test.dart
test/core/ui/theme/app_dimensions_test.dart
test/core/ui/components/app_button_test.dart
test/core/ui/components/quiz_answer_tile_test.dart
test/core/ui/components/app_card_test.dart
test/core/ui/components/empty_state_test.dart
test/core/ui/components/error_banner_test.dart
test/core/ui/components/inline_offline_banner_test.dart
test/core/ui/components/coach_mark_test.dart
test/core/ui/components/confirmation_dialog_test.dart
test/core/ui/components/streak_banner_test.dart
test/core/ui/components/pro_gate_banner_test.dart
test/core/ui/components/skeleton_loader_test.dart
test/core/ui/components/sync_status_indicator_test.dart
test/features/shell/app_shell_test.dart
```

**Modified files:**
```
pubspec.yaml              add google_fonts, flutter_math_fork
lib/app/theme.dart        delegate appLightTheme/appDarkTheme → buildLightTheme/buildDarkTheme
lib/app/router.dart       replace stub GoRouter with StatefulShellRoute
test/app/app_boot_test.dart  update for new initial route /home
```

---

## Task 1: Add google_fonts and flutter_math_fork dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add the two packages to pubspec.yaml**

Open `pubspec.yaml`. Under `dependencies:`, add these two lines after the `intl` entry:

```yaml
  # UI / fonts
  google_fonts: ^6.2.1
  flutter_math_fork: ^0.7.2
```

- [ ] **Step 2: Fetch dependencies**

```bash
flutter pub get
```

Expected: resolves without conflict. Verify both packages appear in `.dart_tool/package_config.json`.

- [ ] **Step 3: Verify existing tests still pass**

```bash
flutter test
```

Expected: all tests PASS (no new failures — this is a dependency add only).

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add google_fonts and flutter_math_fork dependencies"
```

---

## Task 2: AppColors ThemeExtension

**Files:**
- Create: `lib/core/ui/theme/app_colors.dart`
- Create: `test/core/ui/theme/app_colors_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/theme/app_colors_test.dart`:

```dart
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
      expect(lerped.primary, Color.lerp(AppColors.light.primary, AppColors.dark.primary, 0.5));
    });

    test('returns self when other is null', () {
      final lerped = AppColors.light.lerp(null, 0.5);
      expect(lerped.primary, AppColors.light.primary);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/ui/theme/app_colors_test.dart
```

Expected: FAIL — `app_colors.dart` does not exist yet.

- [ ] **Step 3: Implement AppColors**

Create `lib/core/ui/theme/app_colors.dart`:

```dart
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
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
```

- [ ] **Step 4: Run tests and verify they pass**

```bash
flutter test test/core/ui/theme/app_colors_test.dart
```

Expected: all 8 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/theme/app_colors.dart test/core/ui/theme/app_colors_test.dart
git commit -m "feat(ui): add AppColors ThemeExtension with light and dark token sets"
```

---

## Task 3: AppTextStyles ThemeExtension

**Files:**
- Create: `lib/core/ui/theme/app_text_styles.dart`
- Create: `test/core/ui/theme/app_text_styles_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/theme/app_text_styles_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    // Prevent network calls in tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTextStyles.create()', () {
    late AppTextStyles styles;

    setUp(() => styles = AppTextStyles.create());

    test('displayLarge is 28sp weight 700', () {
      expect(styles.displayLarge.fontSize, 28);
      expect(styles.displayLarge.fontWeight, FontWeight.w700);
    });

    test('displaySmall is 22sp weight 700', () {
      expect(styles.displaySmall.fontSize, 22);
      expect(styles.displaySmall.fontWeight, FontWeight.w700);
    });

    test('bodyLarge is 16sp weight 500', () {
      expect(styles.bodyLarge.fontSize, 16);
      expect(styles.bodyLarge.fontWeight, FontWeight.w500);
    });

    test('bodyMedium is 14sp weight 400', () {
      expect(styles.bodyMedium.fontSize, 14);
      expect(styles.bodyMedium.fontWeight, FontWeight.w400);
    });

    test('labelSmall has 0.5 letter spacing', () {
      expect(styles.labelSmall.letterSpacing, 0.5);
    });

    test('mathBody uses notoSerif font family', () {
      expect(styles.mathBody.fontFamily, contains('NotoSerif'));
    });
  });

  group('AppTextStyles.copyWith', () {
    test('copies with overridden displayLarge', () {
      final styles = AppTextStyles.create();
      final copy = styles.copyWith(
        displayLarge: const TextStyle(fontSize: 99),
      );
      expect(copy.displayLarge.fontSize, 99);
      expect(copy.bodyMedium.fontSize, styles.bodyMedium.fontSize);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/ui/theme/app_text_styles_test.dart
```

Expected: FAIL — `app_text_styles.dart` does not exist yet.

- [ ] **Step 3: Implement AppTextStyles**

Create `lib/core/ui/theme/app_text_styles.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.displayLarge,
    required this.displaySmall,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelSmall,
    required this.mathBody,
  });

  final TextStyle displayLarge;
  final TextStyle displaySmall;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelSmall;
  final TextStyle mathBody;

  static AppTextStyles create() => AppTextStyles(
        displayLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 0.5,
        ),
        mathBody: GoogleFonts.notoSerif(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      );

  @override
  AppTextStyles copyWith({
    TextStyle? displayLarge,
    TextStyle? displaySmall,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelSmall,
    TextStyle? mathBody,
  }) {
    return AppTextStyles(
      displayLarge: displayLarge ?? this.displayLarge,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelSmall: labelSmall ?? this.labelSmall,
      mathBody: mathBody ?? this.mathBody,
    );
  }

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      mathBody: TextStyle.lerp(mathBody, other.mathBody, t)!,
    );
  }
}
```

- [ ] **Step 4: Run tests and verify they pass**

```bash
flutter test test/core/ui/theme/app_text_styles_test.dart
```

Expected: all 7 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/theme/app_text_styles.dart test/core/ui/theme/app_text_styles_test.dart
git commit -m "feat(ui): add AppTextStyles ThemeExtension with Poppins and Noto Serif scale"
```

---

## Task 4: AppDimensions constants + app_theme.dart + test helper

**Files:**
- Create: `lib/core/ui/theme/app_dimensions.dart`
- Create: `lib/core/ui/theme/app_theme.dart`
- Modify: `lib/app/theme.dart`
- Create: `test/core/ui/theme/app_dimensions_test.dart`
- Create: `test/helpers/pump_app.dart`

- [ ] **Step 1: Write failing dimension tests**

Create `test/core/ui/theme/app_dimensions_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDimensions radii', () {
    test('radiusMD is 10', () => expect(AppDimensions.radiusMD, 10.0));
    test('radiusLG is 14', () => expect(AppDimensions.radiusLG, 14.0));
    test('radiusFull is 999', () => expect(AppDimensions.radiusFull, 999.0));
  });

  group('AppDimensions tap targets', () {
    test('minTapTarget is 48', () => expect(AppDimensions.minTapTarget, 48.0));
  });
}
```

- [ ] **Step 2: Run to verify it fails**

```bash
flutter test test/core/ui/theme/app_dimensions_test.dart
```

Expected: FAIL — file does not exist yet.

- [ ] **Step 3: Implement AppDimensions**

Create `lib/core/ui/theme/app_dimensions.dart`:

```dart
import 'package:flutter/material.dart';

abstract final class AppDimensions {
  // Border radii
  static const double radiusXS = 6;
  static const double radiusSM = 8;
  static const double radiusMD = 10;
  static const double radiusLG = 14;
  static const double radiusXL = 20;
  static const double radiusFull = 999;

  // Tap targets
  static const double minTapTarget = 48;

  // Shadows
  static const BoxShadow shadowSM = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  );
  static const BoxShadow shadowMD = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  static const BoxShadow shadowLG = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  );
  static const BoxShadow shadowPrimary = BoxShadow(
    color: Color(0x591F6BFF),
    blurRadius: 10,
    offset: Offset(0, 3),
  );
}
```

- [ ] **Step 4: Implement app_theme.dart**

Create `lib/core/ui/theme/app_theme.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6BFF)),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: [AppColors.light, AppTextStyles.create()],
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F6BFF),
      brightness: Brightness.dark,
    ),
    extensions: [AppColors.dark, AppTextStyles.create()],
  );
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppTextStyles get textStyles => Theme.of(this).extension<AppTextStyles>()!;
}
```

- [ ] **Step 5: Update lib/app/theme.dart to delegate**

Replace the entire content of `lib/app/theme.dart` with:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

ThemeData appLightTheme() => buildLightTheme();
ThemeData appDarkTheme() => buildDarkTheme();
```

- [ ] **Step 6: Create the shared test pump helper**

Create `test/helpers/pump_app.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: [AppColors.light, AppTextStyles.create()],
        ),
        home: Scaffold(body: widget),
      ),
    );
    await pump();
  }
}
```

- [ ] **Step 7: Run all tests**

```bash
flutter test
```

Expected: all existing tests PASS including `app_boot_test.dart` (theme delegation is transparent to app.dart).

- [ ] **Step 8: Commit**

```bash
git add lib/core/ui/theme/app_dimensions.dart \
        lib/core/ui/theme/app_theme.dart \
        lib/app/theme.dart \
        test/core/ui/theme/app_dimensions_test.dart \
        test/helpers/pump_app.dart
git commit -m "feat(ui): add AppDimensions, app_theme builders, and BuildContext token accessors"
```

---

## Task 5: AppButton

**Files:**
- Create: `lib/core/ui/components/app_button.dart`
- Create: `test/core/ui/components/app_button_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/app_button_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'Start Review', onPressed: () {}),
      );
      expect(find.text('Start Review'), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        AppButton(label: 'Go', onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('disabled variant does not fire onPressed', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        AppButton(
          label: 'Go',
          onPressed: () => tapped = true,
          variant: AppButtonVariant.disabled,
        ),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    });

    testWidgets('loading variant shows CircularProgressIndicator', (tester) async {
      await tester.pumpApp(
        AppButton(
          label: 'Go',
          onPressed: () {},
          variant: AppButtonVariant.loading,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
    });

    testWidgets('renders leading icon when provided', (tester) async {
      await tester.pumpApp(
        AppButton(
          label: 'Start',
          onPressed: () {},
          leadingIcon: const Icon(Icons.play_arrow, key: Key('icon')),
        ),
      );
      expect(find.byKey(const Key('icon')), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('has minimum 48dp height', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'X', onPressed: () {}),
      );
      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/app_button_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement AppButton**

Create `lib/core/ui/components/app_button.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive, disabled, loading }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final isDisabled = variant == AppButtonVariant.disabled;
    final isLoading = variant == AppButtonVariant.loading;

    final Color bgColor;
    final Color textColor;
    Border? border;
    BoxShadow? shadow;

    switch (variant) {
      case AppButtonVariant.primary || AppButtonVariant.loading:
        bgColor = colors.primary;
        textColor = Colors.white;
        shadow = BoxShadow(
          color: colors.primary.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        );
      case AppButtonVariant.secondary:
        bgColor = colors.surface;
        textColor = colors.primary;
        border = Border.all(color: colors.primary, width: 2);
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = colors.primary;
      case AppButtonVariant.destructive:
        bgColor = colors.error;
        textColor = Colors.white;
      case AppButtonVariant.disabled:
        bgColor = colors.border;
        textColor = colors.onSurfaceMuted;
    }

    final Widget child;
    if (isLoading) {
      child = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
      );
    } else if (leadingIcon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingIcon!,
          const SizedBox(width: 8),
          Text(label, style: styles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: textColor)),
        ],
      );
    } else {
      child = Text(
        label,
        style: styles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: textColor),
      );
    }

    return Opacity(
      opacity: isLoading ? 0.8 : 1.0,
      child: GestureDetector(
        onTap: (isDisabled || isLoading) ? null : onPressed,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: AppDimensions.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: border,
            boxShadow: shadow != null ? [shadow] : null,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests and verify they pass**

```bash
flutter test test/core/ui/components/app_button_test.dart
```

Expected: all 6 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/app_button.dart test/core/ui/components/app_button_test.dart
git commit -m "feat(ui): add AppButton component with 6 variants"
```

---

## Task 6: QuizAnswerTile

**Files:**
- Create: `lib/core/ui/components/quiz_answer_tile.dart`
- Create: `test/core/ui/components/quiz_answer_tile_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/quiz_answer_tile_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/quiz_answer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('QuizAnswerTile', () {
    testWidgets('shows letter prefix and answer text', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(letter: 'A', text: 'Personnel audit', onTap: () {}),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Personnel audit'), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        QuizAnswerTile(letter: 'B', text: 'Option B', onTap: () => tapped = true),
      );
      await tester.tap(find.byType(QuizAnswerTile));
      expect(tapped, isTrue);
    });

    testWidgets('selected state shows check icon hidden — letter turns blue', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(letter: 'A', text: 'Option', onTap: () {}, isSelected: true),
      );
      // Letter 'A' is still shown (not replaced in selected state)
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('correct state shows checkmark icon', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(letter: 'A', text: 'Right answer', onTap: () {}, state: TileState.correct),
      );
      expect(find.text('✅'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('incorrect state shows X icon and strikethrough', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(letter: 'B', text: 'Wrong answer', onTap: () {}, state: TileState.incorrect),
      );
      expect(find.text('❌'), findsOneWidget);
    });

    testWidgets('correctMissed state shows bulb icon', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(letter: 'C', text: 'Correct option', onTap: () {}, state: TileState.correctMissed),
      );
      expect(find.text('💡'), findsOneWidget);
    });

    testWidgets('has minimum 48dp height', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(letter: 'A', text: 'Option', onTap: () {}),
      );
      final size = tester.getSize(find.byType(QuizAnswerTile));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/quiz_answer_tile_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement QuizAnswerTile**

Create `lib/core/ui/components/quiz_answer_tile.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum TileState { normal, correct, incorrect, correctMissed }

class QuizAnswerTile extends StatelessWidget {
  const QuizAnswerTile({
    required this.letter,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.state = TileState.normal,
    this.isMath = false,
    super.key,
  });

  final String letter;
  final String text;
  final VoidCallback onTap;
  final bool isSelected;
  final TileState state;
  final bool isMath;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final Color bgColor;
    final Color borderColor;
    final double borderWidth;
    final bool isDashed;
    final Color textColor;
    final String prefixDisplay;

    switch (state) {
      case TileState.normal:
        bgColor = colors.surface;
        borderColor = isSelected ? colors.borderSelected : colors.border;
        borderWidth = isSelected ? 1.5 : 1.5;
        isDashed = false;
        textColor = isSelected ? colors.onSurface : colors.onSurfaceMuted;
        prefixDisplay = letter;
      case TileState.correct:
        bgColor = colors.successContainer;
        borderColor = colors.success;
        borderWidth = 2;
        isDashed = false;
        textColor = colors.success;
        prefixDisplay = '✅';
      case TileState.incorrect:
        bgColor = colors.errorContainer;
        borderColor = colors.error;
        borderWidth = 2;
        isDashed = false;
        textColor = colors.error;
        prefixDisplay = '❌';
      case TileState.correctMissed:
        bgColor = colors.successContainer;
        borderColor = colors.success;
        borderWidth = 2;
        isDashed = true;
        textColor = colors.success;
        prefixDisplay = '💡';
    }

    final borderSide = isDashed
        ? BorderSide(color: borderColor, width: borderWidth)
        : BorderSide(color: borderColor, width: borderWidth);

    BoxBorder border;
    if (state == TileState.normal && isSelected) {
      border = Border(
        left: BorderSide(color: borderColor, width: 4),
        top: BorderSide(color: colors.border, width: 1.5),
        right: BorderSide(color: colors.border, width: 1.5),
        bottom: BorderSide(color: colors.border, width: 1.5),
      );
    } else {
      border = Border.all(color: borderColor, width: borderWidth);
    }

    final textStyle = isMath ? textStyles.mathBody : textStyles.bodyMedium;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: AppDimensions.minTapTarget),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: border,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                prefixDisplay,
                style: textStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected && state == TileState.normal
                      ? colors.borderSelected
                      : colors.onSurfaceMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: textStyle.copyWith(
                  color: textColor,
                  fontWeight: state == TileState.correct || isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  decoration: state == TileState.incorrect
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests and verify they pass**

```bash
flutter test test/core/ui/components/quiz_answer_tile_test.dart
```

Expected: all 7 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/quiz_answer_tile.dart test/core/ui/components/quiz_answer_tile_test.dart
git commit -m "feat(ui): add QuizAnswerTile with all 5 answer states"
```

---

## Task 7: AppCard

**Files:**
- Create: `lib/core/ui/components/app_card.dart`
- Create: `test/core/ui/components/app_card_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/app_card_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppCard', () {
    testWidgets('plain variant renders child', (tester) async {
      await tester.pumpApp(
        const AppCard(child: Text('Hello')),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('accent variant has a top border', (tester) async {
      await tester.pumpApp(
        const AppCard(variant: AppCardVariant.accent, child: Text('Due')),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.border, isNotNull);
    });

    testWidgets('gradient variant renders a gradient decoration', (tester) async {
      await tester.pumpApp(
        AppCard(
          variant: AppCardVariant.gradient,
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
          ),
          child: const Text('Streak'),
        ),
      );
      expect(find.text('Streak'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/app_card_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement AppCard**

Create `lib/core/ui/components/app_card.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppCardVariant { plain, accent, gradient }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.variant = AppCardVariant.plain,
    this.gradient,
    this.padding,
    super.key,
  });

  final Widget child;
  final AppCardVariant variant;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Border? border;
    Color bgColor = colors.surface;
    Gradient? resolvedGradient;

    switch (variant) {
      case AppCardVariant.plain:
        border = Border.all(color: colors.border, width: 1);
      case AppCardVariant.accent:
        border = Border(
          top: BorderSide(color: colors.primary, width: 3),
          left: BorderSide(color: colors.border, width: 1),
          right: BorderSide(color: colors.border, width: 1),
          bottom: BorderSide(color: colors.border, width: 1),
        );
      case AppCardVariant.gradient:
        resolvedGradient = gradient;
        bgColor = Colors.transparent;
        border = null;
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: resolvedGradient == null ? bgColor : null,
        gradient: resolvedGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: border,
        boxShadow: const [AppDimensions.shadowSM],
      ),
      child: child,
    );
  }
}
```

- [ ] **Step 4: Run tests and verify they pass**

```bash
flutter test test/core/ui/components/app_card_test.dart
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/app_card.dart test/core/ui/components/app_card_test.dart
git commit -m "feat(ui): add AppCard with plain, accent, and gradient variants"
```

---

## Task 8: EmptyState

**Files:**
- Create: `lib/core/ui/components/empty_state.dart`
- Create: `test/core/ui/components/empty_state_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/empty_state_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders illustration, headline, body and CTA', (tester) async {
      await tester.pumpApp(
        EmptyState(
          illustration: '🎉',
          headline: 'All caught up!',
          body: 'You have no cards due.',
          ctaLabel: 'Quiz instead',
          onCta: () {},
        ),
      );
      expect(find.text('🎉'), findsOneWidget);
      expect(find.text('All caught up!'), findsOneWidget);
      expect(find.text('You have no cards due.'), findsOneWidget);
      expect(find.text('Quiz instead'), findsOneWidget);
    });

    testWidgets('CTA fires callback', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        EmptyState(
          illustration: '📡',
          headline: 'No connection',
          body: 'Check your internet.',
          ctaLabel: 'Try again',
          onCta: () => tapped = true,
        ),
      );
      await tester.tap(find.text('Try again'));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/empty_state_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement EmptyState**

Create `lib/core/ui/components/empty_state.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.illustration,
    required this.headline,
    required this.body,
    required this.ctaLabel,
    required this.onCta,
    super.key,
  });

  final String illustration;
  final String headline;
  final String body;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(illustration, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            headline,
            style: textStyles.headlineSmall.copyWith(color: colors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          AppButton(label: ctaLabel, onPressed: onCta),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/ui/components/empty_state_test.dart
```

Expected: all 2 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/empty_state.dart test/core/ui/components/empty_state_test.dart
git commit -m "feat(ui): add EmptyState component with illustration + CTA"
```

---

## Task 9: ErrorBanner

**Files:**
- Create: `lib/core/ui/components/error_banner.dart`
- Create: `test/core/ui/components/error_banner_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/error_banner_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ErrorBanner', () {
    testWidgets('error variant shows message and retry label', (tester) async {
      await tester.pumpApp(
        ErrorBanner(
          variant: ErrorBannerVariant.error,
          message: 'Could not save answer',
          actionLabel: 'Retry',
          onAction: () {},
        ),
      );
      expect(find.text('Could not save answer'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('offline variant shows dismiss button', (tester) async {
      await tester.pumpApp(
        ErrorBanner(
          variant: ErrorBannerVariant.offline,
          message: 'Offline — progress is saved',
          onDismiss: () {},
        ),
      );
      expect(find.text('Offline — progress is saved'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('success variant shows message', (tester) async {
      await tester.pumpApp(
        const ErrorBanner(
          variant: ErrorBannerVariant.success,
          message: 'Progress synced',
        ),
      );
      expect(find.text('Progress synced'), findsOneWidget);
    });

    testWidgets('error variant fires onAction callback', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        ErrorBanner(
          variant: ErrorBannerVariant.error,
          message: 'Error',
          actionLabel: 'Retry',
          onAction: () => tapped = true,
        ),
      );
      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });

    testWidgets('offline variant fires onDismiss callback', (tester) async {
      var dismissed = false;
      await tester.pumpApp(
        ErrorBanner(
          variant: ErrorBannerVariant.offline,
          message: 'Offline',
          onDismiss: () => dismissed = true,
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/error_banner_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement ErrorBanner**

Create `lib/core/ui/components/error_banner.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum ErrorBannerVariant { error, offline, success }

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    required this.variant,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    super.key,
  });

  final ErrorBannerVariant variant;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final String icon;

    switch (variant) {
      case ErrorBannerVariant.error:
        bgColor = colors.errorContainer;
        borderColor = colors.error;
        textColor = colors.error;
        icon = '⚠️';
      case ErrorBannerVariant.offline:
        bgColor = colors.warningContainer;
        borderColor = colors.warning;
        textColor = colors.warning;
        icon = '📶';
      case ErrorBannerVariant.success:
        bgColor = colors.successContainer;
        borderColor = colors.success;
        textColor = colors.success;
        icon = '✅';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: textStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: textStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: colors.onSurfaceMuted),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/ui/components/error_banner_test.dart
```

Expected: all 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/error_banner.dart test/core/ui/components/error_banner_test.dart
git commit -m "feat(ui): add ErrorBanner with error, offline, and success variants"
```

---

## Task 10: InlineOfflineBanner

**Files:**
- Create: `lib/core/ui/components/inline_offline_banner.dart`
- Create: `test/core/ui/components/inline_offline_banner_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/inline_offline_banner_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/inline_offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('InlineOfflineBanner', () {
    testWidgets('shows offline message', (tester) async {
      await tester.pumpApp(
        InlineOfflineBanner(onDismiss: () {}),
      );
      expect(find.textContaining('Offline'), findsOneWidget);
    });

    testWidgets('shows dismiss button', (tester) async {
      await tester.pumpApp(
        InlineOfflineBanner(onDismiss: () {}),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('fires onDismiss when close tapped', (tester) async {
      var dismissed = false;
      await tester.pumpApp(
        InlineOfflineBanner(onDismiss: () => dismissed = true),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/inline_offline_banner_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement InlineOfflineBanner**

Create `lib/core/ui/components/inline_offline_banner.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InlineOfflineBanner extends StatelessWidget {
  const InlineOfflineBanner({required this.onDismiss, super.key});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.warningContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border(left: BorderSide(color: colors.warning, width: 4)),
      ),
      child: Row(
        children: [
          const Text('📶', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — your progress is still being saved',
              style: textStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.warning,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, size: 16, color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/ui/components/inline_offline_banner_test.dart
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/inline_offline_banner.dart test/core/ui/components/inline_offline_banner_test.dart
git commit -m "feat(ui): add InlineOfflineBanner — dismissible amber offline indicator"
```

---

## Task 11: CoachMark

**Files:**
- Create: `lib/core/ui/components/coach_mark.dart`
- Create: `test/core/ui/components/coach_mark_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/coach_mark_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/coach_mark.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('CoachMark', () {
    testWidgets('renders headline and body', (tester) async {
      await tester.pumpApp(
        CoachMark(
          headline: 'Tap this every day 🔁',
          body: 'This FSRS review keeps knowledge in long-term memory.',
          onDismiss: () {},
        ),
      );
      expect(find.text('Tap this every day 🔁'), findsOneWidget);
      expect(find.textContaining('long-term memory'), findsOneWidget);
    });

    testWidgets('shows dismiss CTA', (tester) async {
      await tester.pumpApp(
        CoachMark(
          headline: 'Got it',
          body: 'Body text',
          onDismiss: () {},
        ),
      );
      expect(find.textContaining('Got it'), findsAtLeast(1));
    });

    testWidgets('fires onDismiss when CTA tapped', (tester) async {
      var dismissed = false;
      await tester.pumpApp(
        CoachMark(
          headline: 'Headline',
          body: 'Body',
          onDismiss: () => dismissed = true,
        ),
      );
      await tester.tap(find.textContaining('Got it →'));
      expect(dismissed, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/coach_mark_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement CoachMark**

Create `lib/core/ui/components/coach_mark.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CoachMark extends StatelessWidget {
  const CoachMark({
    required this.headline,
    required this.body,
    required this.onDismiss,
    super.key,
  });

  final String headline;
  final String body;
  final VoidCallback onDismiss;

  static const _bgColor = Color(0xFF1E293B);
  static const _mutedColor = Color(0xFF94A3B8);
  static const _ctaColor = Color(0xFF4D8FFF);

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            headline,
            style: textStyles.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: textStyles.bodySmall.copyWith(color: _mutedColor),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onDismiss,
              child: Text(
                'Got it →',
                style: textStyles.bodySmall.copyWith(
                  color: _ctaColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/ui/components/coach_mark_test.dart
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/coach_mark.dart test/core/ui/components/coach_mark_test.dart
git commit -m "feat(ui): add CoachMark tooltip component for first-run onboarding"
```

---

## Task 12: ConfirmationDialog

**Files:**
- Create: `lib/core/ui/components/confirmation_dialog.dart`
- Create: `test/core/ui/components/confirmation_dialog_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/confirmation_dialog_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ConfirmationDialog', () {
    Future<void> pumpDialog(WidgetTester tester, {
      VoidCallback? onCancel,
      VoidCallback? onConfirm,
    }) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAppConfirmationDialog(
              context: context,
              icon: '⚠️',
              title: 'Leave quiz?',
              body: 'Your progress will be lost.',
              cancelLabel: 'Keep going',
              confirmLabel: 'Leave',
              onCancel: onCancel ?? () {},
              onConfirm: onConfirm ?? () {},
            ),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows icon, title, body, cancel and confirm labels', (tester) async {
      await pumpDialog(tester);
      expect(find.text('⚠️'), findsOneWidget);
      expect(find.text('Leave quiz?'), findsOneWidget);
      expect(find.text('Your progress will be lost.'), findsOneWidget);
      expect(find.text('Keep going'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
    });

    testWidgets('cancel is to the left of confirm', (tester) async {
      await pumpDialog(tester);
      final cancelOffset = tester.getCenter(find.text('Keep going'));
      final confirmOffset = tester.getCenter(find.text('Leave'));
      expect(cancelOffset.dx, lessThan(confirmOffset.dx));
    });

    testWidgets('fires onCancel when cancel tapped', (tester) async {
      var cancelled = false;
      await pumpDialog(tester, onCancel: () => cancelled = true);
      await tester.tap(find.text('Keep going'));
      expect(cancelled, isTrue);
    });

    testWidgets('fires onConfirm when confirm tapped', (tester) async {
      var confirmed = false;
      await pumpDialog(tester, onConfirm: () => confirmed = true);
      await tester.tap(find.text('Leave'));
      expect(confirmed, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/confirmation_dialog_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement ConfirmationDialog**

Create `lib/core/ui/components/confirmation_dialog.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showAppConfirmationDialog({
  required BuildContext context,
  required String icon,
  required String title,
  required String body,
  required String cancelLabel,
  required String confirmLabel,
  required VoidCallback onCancel,
  required VoidCallback onConfirm,
  bool isDestructive = true,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ConfirmationDialog(
      icon: icon,
      title: title,
      body: body,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      onCancel: onCancel,
      onConfirm: onConfirm,
      isDestructive: isDestructive,
    ),
  );
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.icon,
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    required this.isDestructive,
  });

  final String icon;
  final String title;
  final String body;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              title,
              style: textStyles.headlineSmall.copyWith(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Cancel always LEFT
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onCancel();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        border: Border.all(color: colors.border, width: 1.5),
                      ),
                      child: Text(
                        cancelLabel,
                        style: textStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Confirm always RIGHT
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDestructive ? colors.error : colors.primary,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Text(
                        confirmLabel,
                        style: textStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/ui/components/confirmation_dialog_test.dart
```

Expected: all 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/confirmation_dialog.dart test/core/ui/components/confirmation_dialog_test.dart
git commit -m "feat(ui): add ConfirmationDialog — cancel always left, destructive always right"
```

---

## Task 13: StreakBanner

**Files:**
- Create: `lib/core/ui/components/streak_banner.dart`
- Create: `test/core/ui/components/streak_banner_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/streak_banner_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/streak_banner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('StreakBanner', () {
    testWidgets('active state shows streak count and personal best', (tester) async {
      await tester.pumpApp(
        StreakBanner(
          streakCount: 7,
          personalBest: 12,
          variant: StreakBannerVariant.active,
          onReviewTap: () {},
        ),
      );
      expect(find.textContaining('7'), findsAtLeast(1));
      expect(find.textContaining('12'), findsOneWidget);
    });

    testWidgets('atRisk state shows review CTA', (tester) async {
      await tester.pumpApp(
        StreakBanner(
          streakCount: 5,
          personalBest: 10,
          variant: StreakBannerVariant.atRisk,
          onReviewTap: () {},
        ),
      );
      expect(find.textContaining('Review'), findsOneWidget);
    });

    testWidgets('atRisk fires onReviewTap when CTA tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        StreakBanner(
          streakCount: 3,
          personalBest: 8,
          variant: StreakBannerVariant.atRisk,
          onReviewTap: () => tapped = true,
        ),
      );
      await tester.tap(find.textContaining('Review'));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/streak_banner_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement StreakBanner**

Create `lib/core/ui/components/streak_banner.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum StreakBannerVariant { active, atRisk }

class StreakBanner extends StatelessWidget {
  const StreakBanner({
    required this.streakCount,
    required this.personalBest,
    required this.variant,
    required this.onReviewTap,
    super.key,
  });

  final int streakCount;
  final int personalBest;
  final StreakBannerVariant variant;
  final VoidCallback onReviewTap;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    final isAtRisk = variant == StreakBannerVariant.atRisk;

    final gradient = isAtRisk
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAtRisk ? 'STREAK AT RISK ⚠️' : 'CURRENT STREAK',
                style: textStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$streakCount 🔥',
                style: textStyles.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAtRisk
                    ? 'Review now to keep your streak!'
                    : 'Great work! Keep it going.',
                style: textStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          if (isAtRisk)
            GestureDetector(
              onTap: onReviewTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Text(
                  'Review\nnow',
                  style: textStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Personal best',
                  style: textStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '$personalBest 🏆',
                  style: textStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/ui/components/streak_banner_test.dart
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/streak_banner.dart test/core/ui/components/streak_banner_test.dart
git commit -m "feat(ui): add StreakBanner with active and at-risk gradient states"
```

---

## Task 14: ProGateBanner

**Files:**
- Create: `lib/core/ui/components/pro_gate_banner.dart`
- Create: `test/core/ui/components/pro_gate_banner_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/pro_gate_banner_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/pro_gate_banner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ProGateBanner', () {
    testWidgets('shows PRO badge, feature name, value prop, and price CTA', (tester) async {
      await tester.pumpApp(
        ProGateBanner(
          featureName: 'Full Mock Exams',
          valueProp: 'Practice with a real timed exam.',
          ctaLabel: 'View Pro — ₱99/mo',
          featureEmoji: '📝',
          onCta: () {},
          onDismiss: () {},
        ),
      );
      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('Full Mock Exams'), findsOneWidget);
      expect(find.textContaining('timed exam'), findsOneWidget);
      expect(find.text('View Pro — ₱99/mo'), findsOneWidget);
    });

    testWidgets('shows Maybe later dismiss button', (tester) async {
      await tester.pumpApp(
        ProGateBanner(
          featureName: 'Feature',
          valueProp: 'Value',
          ctaLabel: 'CTA',
          featureEmoji: '🔒',
          onCta: () {},
          onDismiss: () {},
        ),
      );
      expect(find.text('Maybe later'), findsOneWidget);
    });

    testWidgets('fires onCta when CTA tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        ProGateBanner(
          featureName: 'Feature',
          valueProp: 'Value',
          ctaLabel: 'Upgrade',
          featureEmoji: '⭐',
          onCta: () => tapped = true,
          onDismiss: () {},
        ),
      );
      await tester.tap(find.text('Upgrade'));
      expect(tapped, isTrue);
    });

    testWidgets('fires onDismiss when Maybe later tapped', (tester) async {
      var dismissed = false;
      await tester.pumpApp(
        ProGateBanner(
          featureName: 'Feature',
          valueProp: 'Value',
          ctaLabel: 'CTA',
          featureEmoji: '⭐',
          onCta: () {},
          onDismiss: () => dismissed = true,
        ),
      );
      await tester.tap(find.text('Maybe later'));
      expect(dismissed, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/pro_gate_banner_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement ProGateBanner**

Create `lib/core/ui/components/pro_gate_banner.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProGateBanner extends StatelessWidget {
  const ProGateBanner({
    required this.featureName,
    required this.valueProp,
    required this.ctaLabel,
    required this.featureEmoji,
    required this.onCta,
    required this.onDismiss,
    super.key,
  });

  final String featureName;
  final String valueProp;
  final String ctaLabel;
  final String featureEmoji;
  final VoidCallback onCta;
  final VoidCallback onDismiss;

  static const _bgStart = Color(0xFF1E293B);
  static const _bgEnd = Color(0xFF1F3A6E);
  static const _mutedColor = Color(0xFF94A3B8);
  static const _proBadgeColor = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bgStart, _bgEnd],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _proBadgeColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    'PRO',
                    style: textStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  featureName,
                  style: textStyles.headlineSmall.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  valueProp,
                  style: textStyles.bodySmall.copyWith(color: _mutedColor),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onCta,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                          child: Text(
                            ctaLabel,
                            style: textStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Text(
                        'Maybe later',
                        style: textStyles.bodySmall.copyWith(color: _mutedColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(featureEmoji, style: const TextStyle(fontSize: 36)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/ui/components/pro_gate_banner_test.dart
```

Expected: all 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/pro_gate_banner.dart test/core/ui/components/pro_gate_banner_test.dart
git commit -m "feat(ui): add ProGateBanner — value-first, always has a dismiss path"
```

---

## Task 15: SkeletonLoader

**Files:**
- Create: `lib/core/ui/components/skeleton_loader.dart`
- Create: `test/core/ui/components/skeleton_loader_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/skeleton_loader_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('SkeletonLoader', () {
    testWidgets('renders a box with given width and height', (tester) async {
      await tester.pumpApp(
        const SkeletonBox(width: 200, height: 16),
      );
      final box = tester.widget<Container>(find.byType(Container).last);
      expect(box.constraints?.maxWidth, 200);
    });

    testWidgets('SkeletonCard renders without error', (tester) async {
      await tester.pumpApp(const SkeletonCard());
      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('SkeletonCard contains multiple SkeletonBox widgets', (tester) async {
      await tester.pumpApp(const SkeletonCard());
      expect(find.byType(SkeletonBox), findsAtLeast(3));
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/skeleton_loader_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement SkeletonLoader**

Create `lib/core/ui/components/skeleton_loader.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    required this.height,
    this.width,
    this.borderRadius,
    super.key,
  });

  final double height;
  final double? width;
  final double? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      return _buildStatic(context);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => _buildShimmer(context),
    );
  }

  Widget _buildStatic(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? AppDimensions.radiusSM,
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(_animation.value - 1, 0),
          end: Alignment(_animation.value + 1, 0),
          colors: [colors.border, colors.background, colors.border],
        ),
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? AppDimensions.radiusSM,
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: const [AppDimensions.shadowSM],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(height: 10, width: 80),
              SkeletonBox(height: 10, width: 60),
            ],
          ),
          SizedBox(height: 12),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: 6),
          SkeletonBox(height: 14, width: 240),
          SizedBox(height: 14),
          SkeletonBox(height: 44, width: double.infinity, borderRadius: 10),
          SizedBox(height: 6),
          SkeletonBox(height: 44, width: double.infinity, borderRadius: 10),
          SizedBox(height: 6),
          SkeletonBox(height: 44, width: double.infinity, borderRadius: 10),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/ui/components/skeleton_loader_test.dart
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/skeleton_loader.dart test/core/ui/components/skeleton_loader_test.dart
git commit -m "feat(ui): add SkeletonBox and SkeletonCard with shimmer and reduce-motion support"
```

---

## Task 16: SyncStatusIndicator

**Files:**
- Create: `lib/core/ui/components/sync_status_indicator.dart`
- Create: `test/core/ui/components/sync_status_indicator_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/ui/components/sync_status_indicator_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/sync_status_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('SyncStatusIndicator', () {
    testWidgets('synced state shows Synced label', (tester) async {
      await tester.pumpApp(
        const SyncStatusIndicator(state: SyncState.synced),
      );
      expect(find.text('Synced'), findsOneWidget);
    });

    testWidgets('syncing state shows Syncing label', (tester) async {
      await tester.pumpApp(
        const SyncStatusIndicator(state: SyncState.syncing),
      );
      expect(find.textContaining('Syncing'), findsOneWidget);
    });

    testWidgets('offline state shows Offline label', (tester) async {
      await tester.pumpApp(
        const SyncStatusIndicator(state: SyncState.offline),
      );
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('fires onTap when tapped in non-synced state', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        SyncStatusIndicator(
          state: SyncState.offline,
          onTap: () => tapped = true,
        ),
      );
      await tester.tap(find.byType(SyncStatusIndicator));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/core/ui/components/sync_status_indicator_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement SyncStatusIndicator**

Create `lib/core/ui/components/sync_status_indicator.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum SyncState { synced, syncing, offline }

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({
    required this.state,
    this.onTap,
    super.key,
  });

  final SyncState state;
  final VoidCallback? onTap;

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.state == SyncState.syncing) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(SyncStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == SyncState.syncing) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final Color bgColor;
    final Color dotColor;
    final Color labelColor;
    final String label;

    switch (widget.state) {
      case SyncState.synced:
        bgColor = colors.successContainer;
        dotColor = colors.success;
        labelColor = colors.success;
        label = 'Synced';
      case SyncState.syncing:
        bgColor = colors.primaryContainer;
        dotColor = colors.primary;
        labelColor = colors.primary;
        label = 'Syncing...';
      case SyncState.offline:
        bgColor = colors.warningContainer;
        dotColor = colors.warning;
        labelColor = colors.warning;
        label = 'Offline';
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Opacity(
                opacity: widget.state == SyncState.syncing
                    ? 0.3 + (_pulse.value * 0.7)
                    : 1.0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: textStyles.labelSmall.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/ui/components/sync_status_indicator_test.dart
```

Expected: all 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/sync_status_indicator.dart test/core/ui/components/sync_status_indicator_test.dart
git commit -m "feat(ui): add SyncStatusIndicator pill with synced, syncing, and offline states"
```

---

## Task 17: Three-tab navigation shell

**Files:**
- Create: `lib/features/shell/presentation/app_shell.dart`
- Create: `test/features/shell/app_shell_test.dart`
- Modify: `lib/app/router.dart`
- Modify: `test/app/app_boot_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/features/shell/app_shell_test.dart`:

```dart
import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App navigation shell', () {
    testWidgets('renders three tabs: Home, Learn, More', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App(flavor: Flavor.dev)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Learn'), findsWidgets);
      expect(find.text('More'), findsWidgets);
    });

    testWidgets('tapping Learn tab navigates to Learn screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App(flavor: Flavor.dev)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Learn'), findsWidgets);
    });

    testWidgets('tapping More tab navigates to More screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App(flavor: Flavor.dev)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('More').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('More'), findsWidgets);
    });
  });
}
```

- [ ] **Step 2: Update app_boot_test.dart for new router**

Replace the content of `test/app/app_boot_test.dart` with:

```dart
import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and renders the navigation shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App(flavor: Flavor.dev)),
    );
    await tester.pumpAndSettle();

    // Shell renders with three tabs visible.
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Learn'), findsWidgets);
    expect(find.text('More'), findsWidgets);
  });
}
```

- [ ] **Step 3: Run tests to verify failure**

```bash
flutter test test/features/shell/app_shell_test.dart test/app/app_boot_test.dart
```

Expected: FAIL — `app_shell.dart` and updated router do not exist yet.

- [ ] **Step 4: Implement AppShell**

Create `lib/features/shell/presentation/app_shell.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _AppNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _AppNavBar extends StatelessWidget {
  const _AppNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 1)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _LearnNavItem(
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.more_horiz,
              activeIcon: Icons.more_horiz,
              label: 'More',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final color = isActive ? colors.primary : colors.onSurfaceMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: textStyles.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnNavItem extends StatelessWidget {
  const _LearnNavItem({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final labelColor = isActive ? colors.primary : colors.onSurfaceMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                boxShadow: const [AppDimensions.shadowPrimary],
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              'Learn',
              style: textStyles.labelSmall.copyWith(color: labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Update router to use StatefulShellRoute**

Replace the entire content of `lib/app/router.dart` with:

```dart
import 'package:cse_cet_reviewer/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const _TabStub('Home'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (_, __) => const _TabStub('Learn'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (_, __) => const _TabStub('More'),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const _Stub('Onboarding'),
      ),
      GoRoute(
        path: '/quiz',
        builder: (_, __) => const _Stub('Quiz'),
      ),
      GoRoute(
        path: '/lesson',
        builder: (_, __) => const _Stub('Lesson'),
      ),
      GoRoute(
        path: '/review',
        builder: (_, __) => const _Stub('Review'),
      ),
      GoRoute(
        path: '/mock-exam',
        builder: (_, __) => const _Stub('Mock Exam'),
      ),
      GoRoute(
        path: '/progress',
        builder: (_, __) => const _Stub('Progress'),
      ),
      GoRoute(
        path: '/paywall',
        builder: (_, __) => const _Stub('Paywall'),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const _Stub('Settings'),
      ),
      GoRoute(
        path: '/legal/:doc',
        builder: (_, state) => _Stub('Legal: ${state.pathParameters['doc']}'),
      ),
    ],
  );
});

class _TabStub extends StatelessWidget {
  const _TabStub(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$label — placeholder')),
    );
  }
}

class _Stub extends StatelessWidget {
  const _Stub(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text('$label — placeholder')),
    );
  }
}
```

- [ ] **Step 6: Run all tests**

```bash
flutter test
```

Expected: all tests PASS, including shell tests and updated app_boot_test.

- [ ] **Step 7: Verify app runs**

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

Expected: app launches, three tabs render, Learn tab has the raised circular blue button, switching tabs works.

- [ ] **Step 8: Commit**

```bash
git add lib/features/shell/presentation/app_shell.dart \
        lib/app/router.dart \
        test/features/shell/app_shell_test.dart \
        test/app/app_boot_test.dart
git commit -m "feat(shell): add 3-tab navigation shell with emphasized Learn tab"
```

---

## Task 18: Final run and coverage check

**Files:** None — verification only.

- [ ] **Step 1: Run the full test suite**

```bash
flutter test --coverage
```

Expected: all tests PASS with zero failures.

- [ ] **Step 2: Check coverage report**

```bash
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

Verify `lib/core/ui/` is ≥ 70% covered. If any component file is below 70%, add tests in its existing test file, then re-run.

- [ ] **Step 3: Run flutter analyze**

```bash
flutter analyze
```

Expected: no errors, no warnings. Fix any issues before proceeding.

- [ ] **Step 4: Commit if any fixes were made**

```bash
git add -A
git commit -m "test(ui): increase coverage to meet 70% gate"
```

Only run this step if fixes were needed. Skip if no changes.

---

## Self-Review Checklist (Controller runs before handing off)

- [ ] §3 (Color system): AppColors.light + AppColors.dark cover all 13/10 tokens — Task 2 ✅
- [ ] §4 (Typography): 9-token scale + mathBody in AppTextStyles — Task 3 ✅
- [ ] §5 (Spacing/Shape): AppDimensions covers all 6 radii + 4 shadows + minTapTarget — Task 4 ✅
- [ ] §6 (Navigation): 3-tab shell, Learn raised, blue header on tab screens — Task 17 ✅
- [ ] §7.1 AppButton: 6 variants including disabled+loading — Task 5 ✅
- [ ] §7.2 QuizAnswerTile: 5 states (normal/selected/correct/incorrect/correctMissed) — Task 6 ✅
- [ ] §7.3 AppCard: 3 variants (plain/accent/gradient) — Task 7 ✅
- [ ] §7.4 EmptyState: illustration+headline+body+CTA required — Task 8 ✅
- [ ] §7.5 ErrorBanner: error/offline/success variants — Task 9 ✅
- [ ] §7.6 InlineOfflineBanner: dismissible amber — Task 10 ✅
- [ ] §7.7 CoachMark: dark tooltip, dismiss CTA — Task 11 ✅
- [ ] §7.8 ConfirmationDialog: cancel left / destructive right rule enforced by test — Task 12 ✅
- [ ] §7.9 StreakBanner: active+atRisk gradient — Task 13 ✅
- [ ] §7.10 ProGateBanner: always has Maybe later dismiss — Task 14 ✅
- [ ] §7.11 SkeletonLoader: shimmer + reduce-motion fallback — Task 15 ✅
- [ ] §7.12 SyncStatusIndicator: 3 states + tap callback — Task 16 ✅
- [ ] §10 (Motion/animation): reduce-motion respected in SkeletonLoader and SyncStatusIndicator — Tasks 15/16 ✅
- [ ] §13 (Flutter impl): components import tokens via `context.colors`/`context.textStyles`, never raw hex — all tasks ✅
