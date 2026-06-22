# Home, Plan 1 of 6: The Bottom Navigation

> **How to work this plan.** Implement it task by task, in order. For each task: write the
> failing test first, run it and confirm it fails, then write the code that makes it pass. Do
> not skip a step and do not batch tasks. Steps use checkbox (`- [ ]`) syntax so progress can
> be tracked.
>
> **Required reading before Task 1:** `AGENTS.md` at the repository root, in full. It carries
> the build commands, the visual identity bans, the voice rules, the never-invent-a-figure
> rule and the landmines, and every one of them applies to this plan whether or not the
> Global Constraints below happen to repeat it.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous, contradicts the spec, or looks
> wrong, **stop and say so** rather than inventing a solution. A plausible invention is more
> expensive than a question, because it looks finished.
>
> **Analyzer baseline:** `flutter analyze` reports **25 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. **The number drifts as those tools change; the
> invariant is that `lib/` and `test/` outside `test/tool/` are clean.** Any issue there is
> one you introduced.
>
> **Work only inside your worktree.** Never write to the main checkout. A previous run left a
> half-applied `app_database.dart` in the main tree with `schemaVersion` bumped and no
> migration: a broken state that compiles.
>
> **Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand and never
> committed.** This repo gitignores them.
>
> **No AI attribution in commit messages.** No `Co-Authored-By` trailers, no "Generated with"
> lines, no similar marker.

**Goal:** Replace the text-only bottom navigation with four glyphs that fill from the
bottom up when their tab is activated, and disable that animation under reduce-motion.

**Architecture:** One new painted-glyph component in `lib/core/ui/components/`, holding
the four paths and the fill sweep, and a rewrite of `_AppNavBar` and `_NavItem` in
`app_shell.dart` to use it. No providers, no storage, no routing changes.

**Tech Stack:** Flutter, go_router (`StatefulNavigationShell`, already wired),
flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-26-home-and-navigation-design.md`
Section 1.

---

## Why this is its own plan

It touches two files, shares nothing with the rest of the Home thread, and closes UI-009
on its own. It can be executed, reviewed and merged before any other Home plan exists,
and it is the only Home plan that does not depend on `RuledPanel` from Quiz 2a.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout. A previous
  background run left a half-applied file in the main checkout that still compiled.
- **Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand and never
  committed.** This repository gitignores them.
- **Check `lib/core/ui/components/` before writing any widget.** The kit holds
  `AnswerRow`, `BoardButton`, `ConfirmationDialog`, `EmptyState`, `ErrorBanner`,
  `FaintBars`, `InkTableRow`, `InlineMeter`, `PageScaffold`, `PortableTextRenderer`,
  `ProgressRule`, `QuestionCard`, `QuizProgressBar`, `RuledSection`, `SectionHeader` and
  `StatsBand`. There is no glyph component; this plan adds the first.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no blur, no shimmer.
- **No board green anywhere in the navigation bar.** Spec Section 1, rule 3. The colour
  budget reserves board for primary actions, progress indicators and done-checks.
  Marking navigation with it would cost the primary button its meaning.
- **Voice.** The four labels are exactly `Home`, `Study`, `Quiz`, `Progress`. No new
  user-facing copy is introduced by this plan.
- **Analyzer must be clean.** `very_good_analysis` with `strict-casts` and
  `strict-inference`. Write the types.

## Verification commands

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

---

## File structure

| File | Responsibility |
|---|---|
| `lib/core/ui/components/nav_glyph.dart` (create) | The four paths, the outline stroke, the bottom-to-top fill sweep. Knows nothing about tabs or routing |
| `lib/features/shell/presentation/app_shell.dart` (modify) | Chooses which glyph each tab shows, drives the sweep on activation only, reads reduce-motion |
| `test/core/ui/components/nav_glyph_test.dart` (create) | The component in isolation |
| `test/features/shell/app_shell_test.dart` (create or extend) | The bar's behaviour |

---

### Task 1: The glyph component, static

**Files:**
- Create: `lib/core/ui/components/nav_glyph.dart`
- Test: `test/core/ui/components/nav_glyph_test.dart`

**Interfaces:**
- Consumes: `context.colors` from `lib/core/ui/theme/app_theme.dart`, which exposes
  `ink` and `inkMuted`.
- Produces: `enum NavGlyphKind { home, study, quiz, progress }` and
  `class NavGlyph extends StatelessWidget` with named parameters
  `({required NavGlyphKind kind, required double fill, required Color color, double size = 23, Key? key})`.
  `fill` is 0 to 1 and is the height of the filled region measured from the bottom of the
  glyph box. Task 2 drives it.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/ui/components/nav_glyph_test.dart
import 'package:cse_cet_reviewer/core/ui/components/nav_glyph.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders at the specified size', (tester) async {
    await tester.pumpWidget(
      harness(
        NavGlyph(
          kind: NavGlyphKind.home,
          fill: 0,
          color: AppColors.light.inkMuted,
        ),
      ),
    );
    final box = tester.getSize(find.byType(NavGlyph));
    expect(box.width, 23);
    expect(box.height, 23);
  });

  testWidgets('every kind paints without throwing', (tester) async {
    for (final kind in NavGlyphKind.values) {
      await tester.pumpWidget(
        harness(
          NavGlyph(kind: kind, fill: 0.5, color: AppColors.light.ink),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('fill outside 0..1 is clamped rather than throwing',
      (tester) async {
    await tester.pumpWidget(
      harness(
        NavGlyph(
          kind: NavGlyphKind.quiz,
          fill: 1.8,
          color: AppColors.light.ink,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('repaints when fill changes and not when it does not',
      (tester) async {
    const kind = NavGlyphKind.progress;
    await tester.pumpWidget(
      harness(const NavGlyph(kind: kind, fill: 0, color: Color(0xFF000000))),
    );
    final painter = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(NavGlyph),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter! as NavGlyphPainter;
    expect(
      painter.shouldRepaint(
        const NavGlyphPainter(
          kind: kind,
          fill: 0,
          color: Color(0xFF000000),
        ),
      ),
      isFalse,
    );
    expect(
      painter.shouldRepaint(
        const NavGlyphPainter(
          kind: kind,
          fill: 0.4,
          color: Color(0xFF000000),
        ),
      ),
      isTrue,
    );
  });
}
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/core/ui/components/nav_glyph_test.dart`
Expected: FAIL, `Error: Couldn't resolve the package 'cse_cet_reviewer' ... nav_glyph.dart`
or `Undefined name 'NavGlyphKind'`.

- [ ] **Step 3: Write the component**

The four paths are authored on a **24 by 24 grid** and scaled to `size`. Keeping one
design grid means the strokes optically match across the four glyphs. The stroke is
**1.50** at 23px, so it is expressed as `1.5 * size / 23` to survive a size change.

```dart
// lib/core/ui/components/nav_glyph.dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Which of the four bottom-navigation glyphs to draw.
enum NavGlyphKind { home, study, quiz, progress }

/// A navigation glyph drawn as an outline that fills from the bottom up.
///
/// [fill] is the height of the filled region as a fraction of the glyph box,
/// measured from the bottom. 0 is the plain outline, 1 is wholly filled.
/// The caller owns the animation; this widget is a pure function of its
/// arguments.
class NavGlyph extends StatelessWidget {
  const NavGlyph({
    required this.kind,
    required this.fill,
    required this.color,
    this.size = 23,
    super.key,
  });

  final NavGlyphKind kind;
  final double fill;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: NavGlyphPainter(
          kind: kind,
          fill: fill.clamp(0.0, 1.0),
          color: color,
        ),
      ),
    );
  }
}

/// Public so widget tests can assert on [shouldRepaint].
class NavGlyphPainter extends CustomPainter {
  const NavGlyphPainter({
    required this.kind,
    required this.fill,
    required this.color,
  });

  final NavGlyphKind kind;
  final double fill;
  final Color color;

  /// The grid every path below is authored on.
  static const double _grid = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _grid;
    final path = _pathFor(kind)
        .transform(Matrix4.diagonal3Values(scale, scale, 1).storage);

    if (fill > 0) {
      final top = size.height * (1 - fill);
      canvas
        ..save()
        ..clipRect(Rect.fromLTRB(0, top, size.width, size.height))
        ..drawPath(path, Paint()..color = color)
        ..restore();
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * size.width / 23
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  Path _pathFor(NavGlyphKind kind) {
    switch (kind) {
      case NavGlyphKind.home:
        return _house();
      case NavGlyphKind.study:
        return _openBook();
      case NavGlyphKind.quiz:
        return _bubble();
      case NavGlyphKind.progress:
        return _sheet();
    }
  }

  /// A house: roof apex at the top centre, walls down to the baseline.
  Path _house() {
    return Path()
      ..moveTo(12, 3)
      ..lineTo(21, 10.5)
      ..lineTo(21, 20.5)
      ..lineTo(3, 20.5)
      ..lineTo(3, 10.5)
      ..close();
  }

  /// An open book: two leaves meeting at a central spine.
  Path _openBook() {
    return Path()
      ..moveTo(12, 6.5)
      ..cubicTo(9.5, 4.5, 6, 4.5, 3, 5.5)
      ..lineTo(3, 19)
      ..cubicTo(6, 18, 9.5, 18, 12, 20)
      ..cubicTo(14.5, 18, 18, 18, 21, 19)
      ..lineTo(21, 5.5)
      ..cubicTo(18, 4.5, 14.5, 4.5, 12, 6.5)
      ..close();
  }

  /// A single answer bubble. The fill sweep is the metaphor: ink rising
  /// into a bubble is a pencil shading an answer sheet.
  Path _bubble() {
    return Path()..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 8.5));
  }

  /// A sheet with a folded corner and a line rising across it.
  Path _sheet() {
    return Path()
      ..moveTo(5, 3)
      ..lineTo(14.5, 3)
      ..lineTo(19, 7.5)
      ..lineTo(19, 21)
      ..lineTo(5, 21)
      ..close()
      ..moveTo(8, 17)
      ..lineTo(11, 13.5)
      ..lineTo(13.5, 15.5)
      ..lineTo(16, 11);
  }

  @override
  bool shouldRepaint(NavGlyphPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.fill != fill ||
        oldDelegate.color != color;
  }
}
```

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/core/ui/components/nav_glyph_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Analyze and format**

```bash
flutter analyze lib/core/ui/components/nav_glyph.dart
dart format lib/core/ui/components/nav_glyph.dart test/core/ui/components/nav_glyph_test.dart
```
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/core/ui/components/nav_glyph.dart test/core/ui/components/nav_glyph_test.dart
git commit -m "feat(ui): add NavGlyph, four painted navigation glyphs with a fill sweep"
```

---

### Task 2: The bar drives the sweep, on the incoming tab only

**Files:**
- Modify: `lib/features/shell/presentation/app_shell.dart:26-98`, replacing `_AppNavBar`
  and `_NavItem` wholesale
- Test: `test/features/shell/app_shell_test.dart`

**Interfaces:**
- Consumes: `NavGlyph`, `NavGlyphKind`, `NavGlyphPainter` from Task 1.
- Produces: nothing later tasks read. `AppShell`'s own constructor is unchanged, so
  `lib/app/router.dart` needs no edit.

**Three rules from the spec that the test must pin:**

1. The rise plays **only on the tab being activated**. The outgoing tab drains
   instantly, because two glyphs animating at once reads as busy.
2. The animation is **disabled under reduce-motion**, falling back to a plain swap. This
   is an accessibility requirement, not a preference.
3. **No board green anywhere in the bar.**

Duration is **400ms** on `Cubic(.22, 1, .36, 1)`. Longer than the platform norm, and
Aedwon selected it against a live slider rather than from a description. It is a single
constant, `_riseDuration`, so the emulator re-check the spec asks for is a one-line
change.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/shell/app_shell_test.dart
import 'package:cse_cet_reviewer/core/ui/components/nav_glyph.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness({
  required int currentIndex,
  required ValueChanged<int> onTap,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    theme: buildLightTheme(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        bottomNavigationBar: AppNavBar(
          currentIndex: currentIndex,
          onTap: onTap,
        ),
      ),
    ),
  );
}

double fillOf(WidgetTester tester, NavGlyphKind kind) {
  final glyph = tester.widget<NavGlyph>(
    find.byWidgetPredicate((w) => w is NavGlyph && w.kind == kind),
  );
  return glyph.fill;
}

void main() {
  testWidgets('renders four labelled glyphs', (tester) async {
    await tester.pumpWidget(harness(currentIndex: 0, onTap: (_) {}));
    expect(find.byType(NavGlyph), findsNWidgets(4));
    for (final label in ['Home', 'Study', 'Quiz', 'Progress']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('the active glyph settles filled and the others stay empty',
      (tester) async {
    await tester.pumpWidget(harness(currentIndex: 0, onTap: (_) {}));
    await tester.pumpAndSettle();
    expect(fillOf(tester, NavGlyphKind.home), 1.0);
    expect(fillOf(tester, NavGlyphKind.study), 0.0);
    expect(fillOf(tester, NavGlyphKind.quiz), 0.0);
    expect(fillOf(tester, NavGlyphKind.progress), 0.0);
  });

  testWidgets('the outgoing tab drains instantly, the incoming one rises',
      (tester) async {
    await tester.pumpWidget(harness(currentIndex: 0, onTap: (_) {}));
    await tester.pumpAndSettle();

    await tester.pumpWidget(harness(currentIndex: 2, onTap: (_) {}));
    await tester.pump(const Duration(milliseconds: 200));

    // Outgoing: gone on the first frame, not fading.
    expect(fillOf(tester, NavGlyphKind.home), 0.0);
    // Incoming: partway up.
    final quiz = fillOf(tester, NavGlyphKind.quiz);
    expect(quiz, greaterThan(0.0));
    expect(quiz, lessThan(1.0));

    await tester.pumpAndSettle();
    expect(fillOf(tester, NavGlyphKind.quiz), 1.0);
  });

  testWidgets('reduce-motion swaps without animating', (tester) async {
    await tester.pumpWidget(
      harness(currentIndex: 0, onTap: (_) {}, disableAnimations: true),
    );
    await tester.pumpWidget(
      harness(currentIndex: 3, onTap: (_) {}, disableAnimations: true),
    );
    // One frame, already at the destination.
    await tester.pump();
    expect(fillOf(tester, NavGlyphKind.progress), 1.0);
    expect(fillOf(tester, NavGlyphKind.home), 0.0);
  });

  testWidgets('tapping reports the index', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(harness(currentIndex: 0, onTap: taps.add));
    await tester.tap(find.text('Progress'));
    expect(taps, [3]);
  });

  testWidgets('no board green anywhere in the bar', (tester) async {
    await tester.pumpWidget(harness(currentIndex: 1, onTap: (_) {}));
    await tester.pumpAndSettle();
    final board = AppColors.light.board;
    for (final glyph in tester.widgetList<NavGlyph>(find.byType(NavGlyph))) {
      expect(glyph.color, isNot(board));
    }
    for (final text in tester.widgetList<Text>(
      find.descendant(of: find.byType(AppNavBar), matching: find.byType(Text)),
    )) {
      expect(text.style?.color, isNot(board));
    }
  });

  testWidgets('the active label is w700 and the rest are not', (tester) async {
    await tester.pumpWidget(harness(currentIndex: 1, onTap: (_) {}));
    expect(
      tester.widget<Text>(find.text('Study')).style?.fontWeight,
      FontWeight.w700,
    );
    expect(
      tester.widget<Text>(find.text('Home')).style?.fontWeight,
      isNot(FontWeight.w700),
    );
  });
}
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/shell/app_shell_test.dart`
Expected: FAIL, `Undefined name 'AppNavBar'`. The current class is private `_AppNavBar`
and cannot be constructed from a test. Task 3's implementation makes it public, which is
why the test names it.

- [ ] **Step 3: Rewrite the bar**

Replace everything from `class _AppNavBar` (line 26) to the end of the file. `AppShell`
itself changes only in the class name it constructs.

```dart
// lib/features/shell/presentation/app_shell.dart
import 'package:cse_cet_reviewer/core/ui/components/nav_glyph.dart';
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
      bottomNavigationBar: AppNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

/// Public so it can be widget-tested without a router.
class AppNavBar extends StatelessWidget {
  const AppNavBar({required this.currentIndex, required this.onTap, super.key});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = <({String label, NavGlyphKind glyph})>[
    (label: 'Home', glyph: NavGlyphKind.home),
    (label: 'Study', glyph: NavGlyphKind.study),
    (label: 'Quiz', glyph: NavGlyphKind.quiz),
    (label: 'Progress', glyph: NavGlyphKind.progress),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.rule,
            // ignore: avoid_redundant_argument_values
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                _NavItem(
                  label: _tabs[i].label,
                  glyph: _tabs[i].glyph,
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.glyph,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final NavGlyphKind glyph;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  /// Longer than the platform norm, and chosen against a live slider rather
  /// than from a description. Re-check on the emulator once the page
  /// transition is also in play, since perceived latency compounds.
  static const _riseDuration = Duration(milliseconds: 400);
  static const _riseCurve = Cubic(.22, 1, .36, 1);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _riseDuration,
    value: widget.isActive ? 1 : 0,
  );
  late final Animation<double> _fill = CurvedAnimation(
    parent: _controller,
    curve: _riseCurve,
  );

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (old.isActive == widget.isActive) return;
    if (!widget.isActive) {
      // The outgoing tab drains instantly. Two glyphs animating at once
      // reads as busy, so only the incoming one plays.
      _controller.value = 0;
    } else if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    // Board green is reserved for primary actions, progress indicators and
    // done-checks. Marking navigation with it would cost the primary button
    // its meaning.
    final color = widget.isActive ? colors.ink : colors.inkMuted;

    return Expanded(
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _fill,
              builder: (context, _) => NavGlyph(
                kind: widget.glyph,
                fill: _fill.value,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: styles.labelSmall.copyWith(
                color: color,
                fontWeight:
                    widget.isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Why `didUpdateWidget` and not `initState`:** the shell rebuilds the whole bar on every
branch change, and `_NavItem` keeps its state because its position in the `Row` is
stable. A tab that is active on first build starts at `value: 1` with no animation, which
is correct: nothing was activated, the app just opened.

**Why `MediaQuery.disableAnimationsOf` is read in `didUpdateWidget` and not cached:** the
setting can change while the app is running, and reading it at the moment of the swap is
both correct and free.

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/features/shell/app_shell_test.dart`
Expected: PASS, 7 tests.

- [ ] **Step 5: Run the whole suite, because this file is on every screen**

Run: `flutter test`
Expected: PASS. If a test fails asserting on the old text-only bar, it is asserting on
behaviour this plan deliberately changes: update it to the new structure rather than
reverting the change, and say so in the commit body.

- [ ] **Step 6: Analyze and format**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```
Expected: `No issues found!` and no format diff.

- [ ] **Step 7: Commit**

```bash
git add lib/features/shell/presentation/app_shell.dart test/features/shell/app_shell_test.dart
git commit -m "feat(shell): give the bottom navigation glyphs and an ink rise

Icons were added for recognition speed, which was the objection: a
decorative active marker was rejected as answering the wrong question.
The rise plays only on the tab being activated, the outgoing tab drains
instantly, and reduce-motion falls back to a plain swap. No board green
anywhere in the bar.

Closes UI-009."
```

---

## What this plan does not do

- **It does not re-check 400ms on a device.** The spec asks for that once page
  transitions are also running, and page transitions are not this plan's business. The
  duration is one constant, `_riseDuration` in `app_shell.dart`.
- **It does not touch Home's composition.** Plans 3 to 6 do that.
- **It does not screenshot anything.** Report the text-only signals above and ask Aedwon
  to look. He files findings in `docs/ui-audit.md`.

## Verification, for the reviewer

- `flutter test` passes and `flutter analyze` is clean.
- Tapping a tab still switches branches: the `onTap` contract is unchanged, so
  `lib/app/router.dart` needed no edit.
- Under reduce-motion the glyph is filled on the first frame after the swap.
- No `colors.board` reference exists anywhere in `app_shell.dart`.
