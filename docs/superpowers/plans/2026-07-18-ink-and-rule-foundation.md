# Ink & Rule Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Pantas's vibe-coded theme with the approved "Ink & Rule" identity — bundled fonts, new token layer, and an eight-widget component kit — so the whole app re-skins immediately and Plan 2 can sweep screens.

**Architecture:** Token-first. Rewrite the three `ThemeExtension` files with the new vocabulary while keeping deprecated getter aliases for old names, so the app compiles and repaints app-wide on day one. New kit widgets are additive in `lib/core/ui/components/`. Screen rework happens in Plan 2 (`docs/superpowers/specs/2026-07-18-ui-redesign-design.md` § Section 3).

**Tech Stack:** Flutter 3.44 / Material 3, `ThemeExtension` tokens, bundled TTF assets (no `google_fonts` at runtime), `flutter_test` widget tests.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-18-ui-redesign-design.md` — color values and budget are normative.
- NEVER add AI/Claude attribution or Co-Authored-By trailers to commits (project rule).
- No emojis in UI copy. Sentence case everywhere; no all-caps letterspaced labels.
- No new shadows; depth comes from 1px rules. (Legacy `AppDimensions.shadow*` stay until Plan 2 removes their usages.)
- Fonts must be bundled assets. Do not add `google_fonts` usages.
- Run commands from the repo root `/Users/aedwon/Documents/Projects/Pantas`. `flutter` is on PATH.
- Every task ends with `flutter analyze` clean (`No issues found!`) before commit.

---

### Task 1: Bundle Source Serif 4 + Source Sans 3, drop google_fonts from pubspec

**Files:**
- Create: `assets/fonts/SourceSerif4-Regular.ttf`, `assets/fonts/SourceSerif4-SemiBold.ttf`, `assets/fonts/SourceSerif4-Bold.ttf`, `assets/fonts/SourceSans3-Regular.ttf`, `assets/fonts/SourceSans3-SemiBold.ttf`, `assets/fonts/SourceSans3-Bold.ttf`, `assets/fonts/OFL-SourceSerif4.txt`, `assets/fonts/OFL-SourceSans3.txt`
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: font families `SourceSerif4` and `SourceSans3` resolvable by `TextStyle(fontFamily: ...)` at weights 400/600/700. Task 2 depends on these exact family names.

- [ ] **Step 1: Download static TTFs**

```bash
mkdir -p assets/fonts /tmp/fontdl && cd /tmp/fontdl
curl -fLo ss4.zip "https://gwfh.mranftl.com/api/fonts/source-serif-4?download=zip&subsets=latin&variants=regular,600,700&formats=ttf"
curl -fLo ss3.zip "https://gwfh.mranftl.com/api/fonts/source-sans-3?download=zip&subsets=latin&variants=regular,600,700&formats=ttf"
unzip -o ss4.zip && unzip -o ss3.zip && ls *.ttf
```

Expected: six `.ttf` files. If a URL 404s, download the family zips from fonts.google.com instead and use the static TTFs from each zip; also copy each family's `OFL.txt`.

- [ ] **Step 2: Rename into the repo**

```bash
cd /tmp/fontdl
for f in *source-serif-4*regular*.ttf; do cp "$f" /Users/aedwon/Documents/Projects/Pantas/assets/fonts/SourceSerif4-Regular.ttf; done
for f in *source-serif-4*600*.ttf;     do cp "$f" /Users/aedwon/Documents/Projects/Pantas/assets/fonts/SourceSerif4-SemiBold.ttf; done
for f in *source-serif-4*700*.ttf;     do cp "$f" /Users/aedwon/Documents/Projects/Pantas/assets/fonts/SourceSerif4-Bold.ttf; done
for f in *source-sans-3*regular*.ttf;  do cp "$f" /Users/aedwon/Documents/Projects/Pantas/assets/fonts/SourceSans3-Regular.ttf; done
for f in *source-sans-3*600*.ttf;      do cp "$f" /Users/aedwon/Documents/Projects/Pantas/assets/fonts/SourceSans3-SemiBold.ttf; done
for f in *source-sans-3*700*.ttf;      do cp "$f" /Users/aedwon/Documents/Projects/Pantas/assets/fonts/SourceSans3-Bold.ttf; done
ls -la /Users/aedwon/Documents/Projects/Pantas/assets/fonts/
```

Expected: six TTFs, each > 100 KB. Also fetch licenses:

```bash
curl -fLo /Users/aedwon/Documents/Projects/Pantas/assets/fonts/OFL-SourceSerif4.txt https://raw.githubusercontent.com/google/fonts/main/ofl/sourceserif4/OFL.txt
curl -fLo /Users/aedwon/Documents/Projects/Pantas/assets/fonts/OFL-SourceSans3.txt https://raw.githubusercontent.com/google/fonts/main/ofl/sourcesans3/OFL.txt
```

- [ ] **Step 3: Declare fonts in pubspec.yaml**

In `pubspec.yaml` under the top-level `flutter:` key (alongside the existing `assets:` list), add:

```yaml
  fonts:
    - family: SourceSerif4
      fonts:
        - asset: assets/fonts/SourceSerif4-Regular.ttf
        - asset: assets/fonts/SourceSerif4-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/SourceSerif4-Bold.ttf
          weight: 700
    - family: SourceSans3
      fonts:
        - asset: assets/fonts/SourceSans3-Regular.ttf
        - asset: assets/fonts/SourceSans3-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/SourceSans3-Bold.ttf
          weight: 700
```

Do NOT remove the `google_fonts` dependency yet — Task 2 removes its last import first.

- [ ] **Step 4: Verify**

Run: `flutter pub get && flutter analyze`
Expected: `Got dependencies!`, `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add assets/fonts pubspec.yaml
git commit -m "theme: bundle Source Serif 4 and Source Sans 3 with OFL licenses"
```

---

### Task 2: Rewrite AppTextStyles onto bundled fonts; remove google_fonts

**Files:**
- Modify: `lib/core/ui/theme/app_text_styles.dart`
- Modify: `pubspec.yaml` (remove `google_fonts` dependency)
- Test: `test/core/ui/theme/app_text_styles_test.dart`

**Interfaces:**
- Consumes: font families `SourceSerif4`, `SourceSans3` from Task 1.
- Produces: `AppTextStyles.create()` with the same ten field names as today (`displayLarge`, `displaySmall`, `headlineMedium`, `headlineSmall`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelLarge`, `labelSmall`, `mathBody`) — callers do not change.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/theme/app_text_styles_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('display and headline styles use Source Serif 4', () {
    final s = AppTextStyles.create();
    expect(s.displayLarge.fontFamily, 'SourceSerif4');
    expect(s.displaySmall.fontFamily, 'SourceSerif4');
    expect(s.headlineMedium.fontFamily, 'SourceSerif4');
    expect(s.headlineSmall.fontFamily, 'SourceSerif4');
    expect(s.mathBody.fontFamily, 'SourceSerif4');
  });

  test('body and label styles use Source Sans 3', () {
    final s = AppTextStyles.create();
    expect(s.bodyLarge.fontFamily, 'SourceSans3');
    expect(s.bodyMedium.fontFamily, 'SourceSans3');
    expect(s.bodySmall.fontFamily, 'SourceSans3');
    expect(s.labelLarge.fontFamily, 'SourceSans3');
    expect(s.labelSmall.fontFamily, 'SourceSans3');
  });

  test('no letterspaced all-caps label styles remain', () {
    final s = AppTextStyles.create();
    expect(s.labelSmall.letterSpacing, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/ui/theme/app_text_styles_test.dart`
Expected: FAIL (families are Poppins/NotoSerif; letterSpacing is 0.5)

- [ ] **Step 3: Rewrite the factory**

In `lib/core/ui/theme/app_text_styles.dart`: delete the `google_fonts` import and replace the `create()` factory body. Only the factory changes — fields, `copyWith`, and `lerp` stay:

```dart
  factory AppTextStyles.create() => const AppTextStyles(
        displayLarge: TextStyle(
          fontFamily: 'SourceSerif4',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SourceSerif4',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SourceSerif4',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SourceSerif4',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        labelSmall: TextStyle(
          fontFamily: 'SourceSans3',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        mathBody: TextStyle(
          fontFamily: 'SourceSerif4',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      );
```

Then remove `google_fonts:` from `pubspec.yaml` dependencies and run `flutter pub get`. If `grep -rn "google_fonts" lib test` shows other importers, replace each with the equivalent bundled-font `TextStyle` (same pattern as above) in the same commit.

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/ui/theme/app_text_styles_test.dart && flutter analyze`
Expected: all PASS, `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A lib pubspec.yaml pubspec.lock test/core/ui/theme/app_text_styles_test.dart
git commit -m "theme: replace Poppins with bundled Source Serif 4 / Source Sans 3"
```

---

### Task 3: Rewrite AppColors with the Ink & Rule vocabulary + deprecated aliases

**Files:**
- Modify: `lib/core/ui/theme/app_colors.dart` (full rewrite)
- Test: `test/core/ui/theme/app_colors_test.dart`

**Interfaces:**
- Produces: fields `background, surface, ink, inkMuted, rule, ruleFaint, board, boardTint, onBoard, rust, amber` on `AppColors`, plus statics `AppColors.light` / `AppColors.dark`. Deprecated getters keep old callers compiling: `onSurface→ink, onSurfaceMuted→inkMuted, border→rule, borderSelected→board, primary→board, primaryContainer→boardTint, success→board, successContainer→boardTint, warning→amber, warningContainer→ruleFaint, error→rust, errorContainer→ruleFaint`. Tasks 4–12 consume the new names only.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/theme/app_colors_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
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

  test('deprecated aliases map onto new tokens', () {
    const c = AppColors.light;
    // ignore: deprecated_member_use_from_same_package
    expect(c.primary, c.board);
    // ignore: deprecated_member_use_from_same_package
    expect(c.onSurface, c.ink);
    // ignore: deprecated_member_use_from_same_package
    expect(c.errorContainer, c.ruleFaint);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/ui/theme/app_colors_test.dart`
Expected: FAIL — compile errors (`ink` undefined)

- [ ] **Step 3: Rewrite `app_colors.dart`**

Replace the file body: same class shape as today (const ctor, statics, `copyWith`, `lerp`) but over the eleven new fields, then append the deprecated getters:

```dart
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
```

- [ ] **Step 4: Run tests and analyze**

Run: `flutter test test/core/ui/theme/app_colors_test.dart && flutter analyze`
Expected: PASS. Analyzer may emit `deprecated_member_use_from_same_package` infos from feature code — those are the Plan 2 worklist and are acceptable; errors are not.

- [ ] **Step 5: Run the whole suite (old widget tests may assert old colors)**

Run: `flutter test`
Expected: failures only in tests asserting old hex values (e.g. `0xFF1F6BFF`). Update each failing expectation to the new token color, using the alias table above to pick the replacement. Re-run until green.

- [ ] **Step 6: Commit**

```bash
git add -A lib test
git commit -m "theme: Ink & Rule color tokens with transitional aliases"
```

---

### Task 4: Tighten AppDimensions and re-seed the Material theme

**Files:**
- Modify: `lib/core/ui/theme/app_dimensions.dart`
- Modify: `lib/core/ui/theme/app_theme.dart`
- Test: `test/core/ui/theme/app_theme_test.dart`

**Interfaces:**
- Produces: `AppDimensions.radiusButton = 5`, `radiusSurface = 8`, `hairline = 1.0`, `progressHeight = 3.0` (old radius constants remain as deprecated aliases). `buildLightTheme()`/`buildDarkTheme()` seed from board green and set `scaffoldBackgroundColor`. Kit tasks 5–12 consume these.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/theme/app_theme_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new dimension tokens', () {
    expect(AppDimensions.radiusButton, 5);
    expect(AppDimensions.radiusSurface, 8);
    expect(AppDimensions.hairline, 1.0);
    expect(AppDimensions.progressHeight, 3.0);
  });

  test('themes use paper/ink scaffold backgrounds', () {
    expect(buildLightTheme().scaffoldBackgroundColor, AppColors.light.background);
    expect(buildDarkTheme().scaffoldBackgroundColor, AppColors.dark.background);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/ui/theme/app_theme_test.dart`
Expected: FAIL (`radiusButton` undefined)

- [ ] **Step 3: Implement**

In `app_dimensions.dart`, add inside the class (keep everything existing):

```dart
  // Ink & Rule tokens
  static const double radiusButton = 5;
  static const double radiusSurface = 8;
  static const double hairline = 1.0;
  static const double progressHeight = 3.0;

  @Deprecated('Use radiusButton or radiusSurface') // pill radii retired
  static const double radiusPill = radiusFull;
```

In `app_theme.dart`, replace both builders:

```dart
ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D5C50)),
    scaffoldBackgroundColor: AppColors.light.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: [AppColors.light, AppTextStyles.create()],
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1D5C50),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.dark.background,
    extensions: [AppColors.dark, AppTextStyles.create()],
  );
}
```

(The `AppThemeContext` extension is unchanged.)

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/ui/theme/ && flutter analyze`
Expected: PASS, no analyzer errors.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/theme test/core/ui/theme
git commit -m "theme: seed Material from board green; add Ink & Rule dimension tokens"
```

---

### Task 5: BoardButton

**Files:**
- Create: `lib/core/ui/components/board_button.dart`
- Test: `test/core/ui/components/board_button_test.dart`

**Interfaces:**
- Consumes: `context.colors` / `context.textStyles` (from `app_theme.dart`), `AppDimensions.radiusButton`.
- Produces: `BoardButton({required String label, required VoidCallback? onPressed, bool secondary = false})`. Primary: full-width flat board fill, `onBoard` text. Secondary: text-only, board-colored label, no fill. All later screen work uses this for actions.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/board_button_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('primary renders board fill and fires onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(harness(
      BoardButton(label: 'Continue lesson', onPressed: () => tapped = true),
    ));
    final box = tester.widget<DecoratedBox>(find.descendant(
      of: find.byType(BoardButton),
      matching: find.byType(DecoratedBox),
    ).first);
    expect((box.decoration as BoxDecoration).color, AppColors.light.board);
    await tester.tap(find.text('Continue lesson'));
    expect(tapped, isTrue);
  });

  testWidgets('secondary has no fill', (tester) async {
    await tester.pumpWidget(harness(
      BoardButton(label: 'Skip', onPressed: () {}, secondary: true),
    ));
    expect(
      find.descendant(
        of: find.byType(BoardButton),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
    expect(find.text('Skip'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/ui/components/board_button_test.dart`
Expected: FAIL (file missing)

- [ ] **Step 3: Implement**

Create `lib/core/ui/components/board_button.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Flat identity button. Board green is budgeted: at most one primary
/// BoardButton per screen.
class BoardButton extends StatelessWidget {
  const BoardButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textStyles.labelLarge;
    if (secondary) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(label,
              textAlign: TextAlign.center,
              style: style.copyWith(color: colors.board)),
        ),
      );
    }
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled ? colors.board : colors.ruleFaint,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          child: Container(
            width: double.infinity,
            constraints:
                const BoxConstraints(minHeight: AppDimensions.minTapTarget),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(label,
                style: style.copyWith(
                    color: enabled ? colors.onBoard : colors.inkMuted)),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/ui/components/board_button_test.dart && flutter analyze`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/board_button.dart test/core/ui/components/board_button_test.dart
git commit -m "components: add BoardButton"
```

---

### Task 6: SectionHeader

**Files:**
- Create: `lib/core/ui/components/section_header.dart`
- Test: `test/core/ui/components/section_header_test.dart`

**Interfaces:**
- Consumes: theme context extensions.
- Produces: `SectionHeader({required String title, String? action, VoidCallback? onAction})` — serif title left, optional sans action right, sharing a baseline.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/section_header_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('renders serif title and tappable action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(harness(SectionHeader(
      title: "Today's plan",
      action: '2 of 3 done',
      onAction: () => tapped = true,
    )));
    final title = tester.widget<Text>(find.text("Today's plan"));
    expect(title.style?.fontFamily, 'SourceSerif4');
    await tester.tap(find.text('2 of 3 done'));
    expect(tapped, isTrue);
  });

  testWidgets('action is optional', (tester) async {
    await tester.pumpWidget(harness(const SectionHeader(title: 'Up next')));
    expect(find.text('Up next'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/ui/components/section_header_test.dart`
Expected: FAIL (file missing)

- [ ] **Step 3: Implement**

Create `lib/core/ui/components/section_header.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Serif section heading with an optional trailing action on the same
/// baseline. Never boxed, never all-caps.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: Text(title, style: styles.headlineSmall)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: styles.labelSmall.copyWith(
                color: onAction != null ? colors.board : colors.inkMuted,
              ),
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/ui/components/section_header_test.dart && flutter analyze`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/section_header.dart test/core/ui/components/section_header_test.dart
git commit -m "components: add SectionHeader"
```

---

### Task 7: RuledSection and PageScaffold

**Files:**
- Create: `lib/core/ui/components/ruled_section.dart`
- Create: `lib/core/ui/components/page_scaffold.dart`
- Test: `test/core/ui/components/ruled_section_test.dart`

**Interfaces:**
- Consumes: theme context, `AppDimensions.hairline`.
- Produces: `RuledSection({required Widget child, bool topRule = true, EdgeInsets padding = const EdgeInsets.symmetric(vertical: 12)})` and `PageScaffold({required Widget body, Widget? bottomNavigationBar, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20)})`.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/ruled_section_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RuledSection draws a top hairline in rule color', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildLightTheme(),
      home: const Scaffold(body: RuledSection(child: Text('content'))),
    ));
    final container = tester.widget<Container>(find.ancestor(
      of: find.text('content'),
      matching: find.byType(Container),
    ).first);
    final border = (container.decoration as BoxDecoration).border as Border;
    expect(border.top.color, AppColors.light.rule);
    expect(border.top.width, 1.0);
  });

  testWidgets('PageScaffold paints paper background', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildLightTheme(),
      home: const PageScaffold(body: Text('hello')),
    ));
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.light.background);
    expect(find.text('hello'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/ui/components/ruled_section_test.dart`
Expected: FAIL (files missing)

- [ ] **Step 3: Implement both widgets**

Create `lib/core/ui/components/ruled_section.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The card replacement: a flat content block bounded by a 1px hairline.
/// Depth comes from rules, never shadows.
class RuledSection extends StatelessWidget {
  const RuledSection({
    super.key,
    required this.child,
    this.topRule = true,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  final Widget child;
  final bool topRule;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        border: topRule
            ? Border(
                top: BorderSide(
                  color: context.colors.rule,
                  width: AppDimensions.hairline,
                ),
              )
            : null,
      ),
      child: child,
    );
  }
}
```

Create `lib/core/ui/components/page_scaffold.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Standard screen shell: paper background, safe area, identity padding.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget body;
  final Widget? bottomNavigationBar;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(child: Padding(padding: padding, child: body)),
    );
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/ui/components/ruled_section_test.dart && flutter analyze`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/ruled_section.dart lib/core/ui/components/page_scaffold.dart test/core/ui/components/ruled_section_test.dart
git commit -m "components: add RuledSection and PageScaffold"
```

---

### Task 8: InkTableRow

**Files:**
- Create: `lib/core/ui/components/ink_table_row.dart`
- Test: `test/core/ui/components/ink_table_row_test.dart`

**Interfaces:**
- Consumes: theme context, `AppDimensions.hairline`.
- Produces: `enum InkRowState { plain, active, done }` and `InkTableRow({required String title, String? subtitle, String? category, String? meta, InkRowState state = InkRowState.plain, bool bottomRule = true, VoidCallback? onTap})`. Done rows: muted strikethrough-free text with a board `✓`; active rows: semibold with `○`; meta right-aligned.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/ink_table_row_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('done row shows board check and muted title', (tester) async {
    await tester.pumpWidget(harness(const InkTableRow(
      title: 'Vocabulary in context',
      meta: '9 min',
      state: InkRowState.done,
    )));
    final check = tester.widget<Text>(find.text('✓'));
    expect(check.style?.color, AppColors.light.board);
    final title = tester.widget<Text>(find.text('Vocabulary in context'));
    expect(title.style?.color, AppColors.light.inkMuted);
  });

  testWidgets('active row is semibold with circle glyph and fires onTap',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(harness(InkTableRow(
      title: 'Reading comprehension',
      subtitle: 'Main idea & supporting details',
      meta: '12 min',
      state: InkRowState.active,
      onTap: () => tapped = true,
    )));
    expect(find.text('○'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Reading comprehension'));
    expect(title.style?.fontWeight, FontWeight.w600);
    await tester.tap(find.text('Reading comprehension'));
    expect(tapped, isTrue);
  });

  testWidgets('plain row renders category column', (tester) async {
    await tester.pumpWidget(harness(const InkTableRow(
      title: 'Number series',
      category: 'Numerical ability',
      meta: '10 min',
    )));
    expect(find.text('Numerical ability'), findsOneWidget);
    expect(find.text('✓'), findsNothing);
    expect(find.text('○'), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/ui/components/ink_table_row_test.dart`
Expected: FAIL (file missing)

- [ ] **Step 3: Implement**

Create `lib/core/ui/components/ink_table_row.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum InkRowState { plain, active, done }

/// Tabular list row: optional state glyph, title/subtitle, category and
/// right-aligned meta columns, faint bottom rule.
class InkTableRow extends StatelessWidget {
  const InkTableRow({
    super.key,
    required this.title,
    this.subtitle,
    this.category,
    this.meta,
    this.state = InkRowState.plain,
    this.bottomRule = true,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? category;
  final String? meta;
  final InkRowState state;
  final bool bottomRule;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final titleStyle = switch (state) {
      InkRowState.done => styles.bodyMedium.copyWith(color: colors.inkMuted),
      InkRowState.active =>
        styles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      InkRowState.plain => styles.bodyMedium,
    };

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (state != InkRowState.plain) ...[
          Text(
            state == InkRowState.done ? '✓' : '○',
            style: styles.bodySmall.copyWith(
              color: state == InkRowState.done ? colors.board : colors.ink,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle),
              if (subtitle != null)
                Text(subtitle!,
                    style: styles.bodySmall.copyWith(color: colors.inkMuted)),
            ],
          ),
        ),
        if (category != null) ...[
          const SizedBox(width: 8),
          Text(category!,
              style: styles.bodySmall.copyWith(color: colors.inkMuted)),
        ],
        if (meta != null) ...[
          const SizedBox(width: 12),
          Text(meta!,
              style: styles.bodySmall.copyWith(color: colors.inkMuted)),
        ],
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: bottomRule
              ? Border(
                  bottom: BorderSide(
                    color: colors.ruleFaint,
                    width: AppDimensions.hairline,
                  ),
                )
              : null,
        ),
        child: row,
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/ui/components/ink_table_row_test.dart && flutter analyze`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/ink_table_row.dart test/core/ui/components/ink_table_row_test.dart
git commit -m "components: add InkTableRow"
```

---

### Task 9: StatsBand

**Files:**
- Create: `lib/core/ui/components/stats_band.dart`
- Test: `test/core/ui/components/stats_band_test.dart`

**Interfaces:**
- Consumes: theme context, `AppDimensions.hairline`.
- Produces: `class StatFigure { const StatFigure({required this.value, this.suffix, required this.label}); }` and `StatsBand({required List<StatFigure> figures})` — the approved "figures first" band: 30px serif numerals, muted suffix, sans label beneath, vertical hairlines between figures, ruled top and bottom.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/stats_band_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders serif numerals with labels and dividers', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildLightTheme(),
      home: const Scaffold(
        body: StatsBand(figures: [
          StatFigure(value: '78%', label: 'Average score'),
          StatFigure(value: '41', suffix: '/96', label: 'Lessons done'),
        ]),
      ),
    ));
    final numeral = tester.widget<Text>(find.text('78%'));
    expect(numeral.style?.fontFamily, 'SourceSerif4');
    expect(numeral.style?.fontSize, 30);
    expect(find.text('/96'), findsOneWidget);
    expect(find.text('Average score'), findsOneWidget);
    expect(find.text('Lessons done'), findsOneWidget);
    // one vertical divider between two figures
    expect(find.byKey(const ValueKey('stats-divider-0')), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/ui/components/stats_band_test.dart`
Expected: FAIL (file missing)

- [ ] **Step 3: Implement**

Create `lib/core/ui/components/stats_band.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StatFigure {
  const StatFigure({required this.value, this.suffix, required this.label});

  final String value;
  final String? suffix;
  final String label;
}

/// "Figures first" stats: large serif numerals, sans labels beneath,
/// vertical hairlines between figures, ruled top and bottom.
class StatsBand extends StatelessWidget {
  const StatsBand({super.key, required this.figures});

  final List<StatFigure> figures;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final numeralStyle = styles.displayLarge.copyWith(fontSize: 30, height: 1);
    final suffixStyle = numeralStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: colors.inkMuted,
    );

    final children = <Widget>[];
    for (var i = 0; i < figures.length; i++) {
      final f = figures[i];
      children.add(Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(
              text: f.value,
              style: numeralStyle,
              children: [
                if (f.suffix != null)
                  TextSpan(text: f.suffix, style: suffixStyle),
              ],
            )),
            const SizedBox(height: 4),
            Text(f.label,
                style: styles.bodySmall.copyWith(color: colors.inkMuted)),
          ],
        ),
      ));
      if (i < figures.length - 1) {
        children.add(Container(
          key: ValueKey('stats-divider-$i'),
          width: AppDimensions.hairline,
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: colors.rule,
        ));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.rule, width: AppDimensions.hairline),
          bottom: BorderSide(color: colors.rule, width: AppDimensions.hairline),
        ),
      ),
      child: IntrinsicHeight(
        child:
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: children),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/ui/components/stats_band_test.dart && flutter analyze`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/stats_band.dart test/core/ui/components/stats_band_test.dart
git commit -m "components: add StatsBand"
```

---

### Task 10: ProgressRule and InlineMeter

**Files:**
- Create: `lib/core/ui/components/progress_rule.dart`
- Create: `lib/core/ui/components/inline_meter.dart`
- Test: `test/core/ui/components/progress_rule_test.dart`

**Interfaces:**
- Consumes: theme context, `AppDimensions.progressHeight`.
- Produces: `ProgressRule({required double value})` (value clamped 0–1, board fill on faint track) and `InlineMeter({required double value, required Color color, double width = 70})` (compact right-aligned bar; caller passes `colors.rust`/`colors.amber`/`colors.board` per the color budget).

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/progress_rule_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/inline_meter.dart';
import 'package:cse_cet_reviewer/core/ui/components/progress_rule.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) => MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(body: Center(child: SizedBox(width: 200, child: child))));

void main() {
  testWidgets('ProgressRule fills proportionally in board green',
      (tester) async {
    await tester.pumpWidget(harness(const ProgressRule(value: 0.5)));
    final fill = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox));
    expect(fill.widthFactor, 0.5);
    final colored = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .whereType<Color>()
        .toList();
    expect(colored, contains(AppColors.light.board));
  });

  testWidgets('ProgressRule clamps out-of-range values', (tester) async {
    await tester.pumpWidget(harness(const ProgressRule(value: 1.7)));
    final fill = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox));
    expect(fill.widthFactor, 1.0);
  });

  testWidgets('InlineMeter uses the caller color', (tester) async {
    await tester.pumpWidget(harness(
        InlineMeter(value: 0.38, color: AppColors.light.rust)));
    final colored = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .whereType<Color>()
        .toList();
    expect(colored, contains(AppColors.light.rust));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/ui/components/progress_rule_test.dart`
Expected: FAIL (files missing)

- [ ] **Step 3: Implement both widgets**

Create `lib/core/ui/components/progress_rule.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// 3px board-green progress line on a faint track.
class ProgressRule extends StatelessWidget {
  const ProgressRule({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.progressHeight / 2),
      child: Container(
        height: AppDimensions.progressHeight,
        width: double.infinity,
        color: colors.ruleFaint,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(color: colors.board),
          ),
        ),
      ),
    );
  }
}
```

Create `lib/core/ui/components/inline_meter.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Compact meter for score contexts (weak areas). Caller supplies the
/// semantic color per the budget: rust, amber, or board.
class InlineMeter extends StatelessWidget {
  const InlineMeter({
    super.key,
    required this.value,
    required this.color,
    this.width = 70,
  });

  final double value;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: AppDimensions.progressHeight,
      child: Container(
        color: context.colors.ruleFaint,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(decoration: BoxDecoration(color: color)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/ui/components/progress_rule_test.dart && flutter analyze`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/progress_rule.dart lib/core/ui/components/inline_meter.dart test/core/ui/components/progress_rule_test.dart
git commit -m "components: add ProgressRule and InlineMeter"
```

---

### Task 11: Full-suite green + emulator re-skin verification

**Files:**
- Modify: any remaining tests asserting Poppins/old hex values (discovered by the run)

**Interfaces:**
- Consumes: everything above.
- Produces: green suite; screenshots proving the app-wide re-skin in light and night.

- [ ] **Step 1: Run the entire suite**

Run: `flutter test`
Expected: PASS. Fix any straggler tests still asserting `Poppins`, `0xFF1F6BFF`, or other retired values — update expectations to the new tokens (alias table in Task 3).

- [ ] **Step 2: Launch on the emulator**

```bash
~/Library/Android/sdk/emulator/emulator -avd pantas_pixel > /tmp/emu.log 2>&1 &
~/Library/Android/sdk/platform-tools/adb wait-for-device
until [ "$(~/Library/Android/sdk/platform-tools/adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 2; done
flutter run --flavor dev -t lib/main_dev.dart -d emulator-5554
```

Expected: app builds and launches.

- [ ] **Step 3: Screenshot light mode**

```bash
~/Library/Android/sdk/platform-tools/adb shell "cmd uimode night no"
~/Library/Android/sdk/platform-tools/adb exec-out screencap -p > /tmp/reskin-light.png
```

Inspect the screenshot: background must be warm paper (#FBF9F4), text ink-brown, buttons blackboard green, serif headings visible. No stock blue anywhere.

- [ ] **Step 4: Screenshot night mode**

```bash
~/Library/Android/sdk/platform-tools/adb shell "cmd uimode night yes"
~/Library/Android/sdk/platform-tools/adb exec-out screencap -p > /tmp/reskin-night.png
```

Inspect: warm near-black background (#191613), cream text, lightened board green. Not slate blue.

- [ ] **Step 5: Commit any test fixes**

```bash
git add -A test
git commit -m "test: update assertions to Ink & Rule tokens"
```

(Skip if Step 1 needed no fixes.)

---

## After this plan

Plan 2 (separate document) sweeps the 17 features in the spec's order — `shell` and `home` (`AssessmentHomeTab`) first as the reference implementation — replacing legacy layouts (pastel blocks, pill buttons, stat tiles, `AppCard`/`AppButton` usages) with the kit, deleting the deprecated aliases feature by feature, and finishing with the alias removal + full walkthrough.
