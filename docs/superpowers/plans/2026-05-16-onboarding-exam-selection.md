# Onboarding (Exam Selection + Age Gate) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the `/onboarding` stub with a real three-screen flow (Welcome → Age gate → Picker) gated by a router redirect that drives users to `/onboarding` whenever `passed_age_gate` or `selected_exam_id` is missing.

**Architecture:** Two new persisted preferences (`passed_age_gate`, reusing the existing `app_preferences_local` key/value table from Phase 1) feed a new `passedAgeGateProvider` alongside the existing `activeExamFocusProvider`. A single `/onboarding` route hosts an internal step state machine (`_OnboardingStep.welcome | ageGate | picker`). The router's `redirect:` callback evaluates the four-quadrant `(passedAgeGate × needsExamSelection)` matrix on every navigation, and a `ChangeNotifier`-based `refreshListenable` bridges Riverpod invalidations so completing a step re-runs the redirect automatically.

**Tech Stack:** Flutter, Riverpod, Drift, go_router, flutter_test, `CupertinoPicker` for the year wheel. No new packages.

**Source spec:** `docs/superpowers/specs/2026-05-16-onboarding-exam-selection-design.md`

---

## File Structure

**Create:**
- `lib/features/onboarding/onboarding.dart` — barrel exporting `OnboardingPage`
- `lib/features/onboarding/presentation/onboarding_page.dart` — `ConsumerStatefulWidget` that owns `_OnboardingStep` state and renders the active step via `AnimatedSwitcher`
- `lib/features/onboarding/presentation/onboarding_welcome_step.dart` — stateless widget with headline, subtitle, single `Get started` CTA
- `lib/features/onboarding/presentation/onboarding_age_gate_step.dart` — `ConsumerStatefulWidget` owning year-wheel state + internal block sub-state
- `lib/features/onboarding/presentation/onboarding_picker_step.dart` — `ConsumerStatefulWidget` listing active exams as emblem cards
- `lib/core/storage/age_gate.dart` — `passedAgeGateProvider` (kept separate from `selected_exam_focus.dart` so each file has one responsibility)
- `lib/app/router_refresh_listenable.dart` — `ChangeNotifier` adapter that listens to a list of providers and calls `notifyListeners()` when any changes
- `test/core/storage/data/repos/app_preferences_repository_test.dart` — extend existing file with age-gate tests
- `test/core/storage/age_gate_test.dart` — provider test
- `test/features/onboarding/presentation/onboarding_welcome_step_test.dart`
- `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`
- `test/features/onboarding/presentation/onboarding_picker_step_test.dart`
- `test/app/router_redirect_test.dart` — the four-quadrant redirect matrix

**Modify:**
- `lib/core/storage/data/repos/app_preferences_repository.dart` — add `hasPassedAgeGate()` / `setPassedAgeGate(bool)` (the existing repo, not a new file)
- `lib/core/storage/storage.dart` — nothing structural; `passedAgeGateProvider` is exported from `age_gate.dart`. (No change unless a consumer imports it via the barrel — none do today.)
- `lib/app/router.dart` — add `redirect:` + `refreshListenable:`, replace `_Stub('Onboarding')` with `OnboardingPage()`
- `test/app/app_boot_test.dart` — seed `passed_age_gate=true` and `selected_exam_id='cse'` so the existing assertions still hold
- `test/features/shell/app_shell_test.dart` — same seeding in `setUp`

**File responsibilities at a glance:**

- `onboarding_page.dart` owns step state and dispatches to step widgets via callbacks. Step widgets do not know about each other or about the router — they emit `onAdvance` / `onCompleted` callbacks and the page advances internal state or relies on the router redirect to pull the user away.
- Each step widget is independently testable by pumping it inside a `ProviderScope` with the needed overrides.
- `router_refresh_listenable.dart` is the only piece that bridges Riverpod and go_router, so the test for redirect rules can pump a real `GoRouter` and exercise both providers.

---

## Task 1: Age Gate Preference Storage Helpers

**Files:**
- Modify: `lib/core/storage/data/repos/app_preferences_repository.dart`
- Modify: `test/core/storage/data/repos/app_preferences_repository_test.dart`

- [ ] **Step 1: Write the failing tests**

Add at the bottom of `test/core/storage/data/repos/app_preferences_repository_test.dart`, before the closing `}` of `main`:

```dart
test('hasPassedAgeGate returns false when unset', () async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final repo = AppPreferencesRepository(db);

  expect(await repo.hasPassedAgeGate(), isFalse);
});

test('setPassedAgeGate persists true', () async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final repo = AppPreferencesRepository(db);

  await repo.setPassedAgeGate(true);

  expect(await repo.hasPassedAgeGate(), isTrue);
});

test('setPassedAgeGate overwrites previous value', () async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final repo = AppPreferencesRepository(db);

  await repo.setPassedAgeGate(true);
  await repo.setPassedAgeGate(false);

  expect(await repo.hasPassedAgeGate(), isFalse);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/storage/data/repos/app_preferences_repository_test.dart`
Expected: 3 failures with "The method 'hasPassedAgeGate' isn't defined" / "'setPassedAgeGate' isn't defined".

- [ ] **Step 3: Implement the helpers**

Edit `lib/core/storage/data/repos/app_preferences_repository.dart` so the full file reads:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';

class AppPreferencesRepository {
  AppPreferencesRepository(this._db);

  static const _selectedExamIdKey = 'selected_exam_id';
  static const _passedAgeGateKey = 'passed_age_gate';

  final AppDatabase _db;

  Future<String?> selectedExamId() async {
    final row = await (_db.select(_db.appPreferencesLocal)
          ..where((p) => p.key.equals(_selectedExamIdKey)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSelectedExamId(String examId) async {
    await _db.into(_db.appPreferencesLocal).insertOnConflictUpdate(
          AppPreferencesLocalCompanion.insert(
            key: _selectedExamIdKey,
            value: examId,
          ),
        );
  }

  Future<bool> hasPassedAgeGate() async {
    final row = await (_db.select(_db.appPreferencesLocal)
          ..where((p) => p.key.equals(_passedAgeGateKey)))
        .getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> setPassedAgeGate(bool value) async {
    await _db.into(_db.appPreferencesLocal).insertOnConflictUpdate(
          AppPreferencesLocalCompanion.insert(
            key: _passedAgeGateKey,
            value: value ? 'true' : 'false',
          ),
        );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/storage/data/repos/app_preferences_repository_test.dart`
Expected: 6 tests pass (3 existing + 3 new).

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/data/repos/app_preferences_repository.dart test/core/storage/data/repos/app_preferences_repository_test.dart
git commit -m "feat(storage): add age-gate preference helpers"
```

---

## Task 2: passedAgeGateProvider

**Files:**
- Create: `lib/core/storage/age_gate.dart`
- Create: `test/core/storage/age_gate_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/storage/age_gate_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/age_gate.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('returns false when preference is unset', () async {
    expect(await container.read(passedAgeGateProvider.future), isFalse);
  });

  test('returns true after setPassedAgeGate(true)', () async {
    await AppPreferencesRepository(db).setPassedAgeGate(true);
    container.invalidate(passedAgeGateProvider);

    expect(await container.read(passedAgeGateProvider.future), isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/storage/age_gate_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:cse_cet_reviewer/core/storage/age_gate.dart'`.

- [ ] **Step 3: Implement the provider**

Create `lib/core/storage/age_gate.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final passedAgeGateProvider = FutureProvider<bool>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).hasPassedAgeGate();
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/storage/age_gate_test.dart`
Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/age_gate.dart test/core/storage/age_gate_test.dart
git commit -m "feat(storage): add passedAgeGateProvider"
```

---

## Task 3: Welcome Step Widget

**Files:**
- Create: `lib/features/onboarding/presentation/onboarding_welcome_step.dart`
- Create: `test/features/onboarding/presentation/onboarding_welcome_step_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/onboarding/presentation/onboarding_welcome_step_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders headline, subtitle, and Get started CTA', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingWelcomeStep(onAdvance: () {}),
      ),
    );

    expect(find.text('Build your study plan'), findsOneWidget);
    expect(find.text("Pick your exam — we'll guide what to study first."),
        findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('tapping Get started invokes onAdvance', (tester) async {
    var advanced = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingWelcomeStep(onAdvance: () => advanced++),
      ),
    );

    await tester.tap(find.text('Get started'));
    await tester.pump();

    expect(advanced, equals(1));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/onboarding/presentation/onboarding_welcome_step_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement the widget**

Create `lib/features/onboarding/presentation/onboarding_welcome_step.dart`:

```dart
import 'package:flutter/material.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({super.key, required this.onAdvance});

  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.menu_book_rounded,
                  size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 32),
            Text(
              'Build your study plan',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              "Pick your exam — we'll guide what to study first.",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const Spacer(),
            FilledButton(
              onPressed: onAdvance,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Get started'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/onboarding/presentation/onboarding_welcome_step_test.dart`
Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/presentation/onboarding_welcome_step.dart test/features/onboarding/presentation/onboarding_welcome_step_test.dart
git commit -m "feat(onboarding): add welcome step widget"
```

---

## Task 4: Age Gate Step Widget

**Files:**
- Create: `lib/features/onboarding/presentation/onboarding_age_gate_step.dart`
- Create: `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`

The widget owns: (a) the wheel's selected year, (b) whether the under-13 block screen is shown, and (c) loading state during persistence. It receives `onAgeGatePassed` as a callback (the onboarding page advances internal step state on this callback). Persistence happens through `appPreferencesRepositoryProvider`. The block state replaces the input state in-place — no new route.

- [ ] **Step 1: Write the failing tests**

Create `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() => db.close());

  Future<void> pumpStep(WidgetTester tester, {VoidCallback? onPassed}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: OnboardingAgeGateStep(
              onAgeGatePassed: onPassed ?? () {},
              currentYear: 2026,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the prompt and disabled Continue initially', (tester) async {
    await pumpStep(tester);

    expect(find.text('Quick check'), findsOneWidget);
    expect(find.text('When were you born?'), findsOneWidget);
    final cont = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'));
    expect(cont.onPressed, isNull);
  });

  testWidgets('selecting a valid year persists and invokes onAgeGatePassed', (tester) async {
    var passed = 0;
    await pumpStep(tester, onPassed: () => passed++);

    final picker = find.byType(CupertinoPicker);
    expect(picker, findsOneWidget);
    // Default selection is currentYear - 18 = 2008. Drag down to confirm a year.
    await tester.drag(picker, const Offset(0, -32));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(passed, equals(1));
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
  });

  testWidgets('under-13 year shows block state without persisting', (tester) async {
    var passed = 0;
    await pumpStep(tester, onPassed: () => passed++);

    // Scroll wheel up enough to reach a year > 2013 (under 13 in 2026).
    final picker = find.byType(CupertinoPicker);
    // Default index lands at 2008 (currentYear - 18). To reach 2014 we scroll down
    // by 6 items. CupertinoPicker default item extent is 32.
    await tester.drag(picker, const Offset(0, -32.0 * 6));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text("Sorry, this app isn't available for users under 13."),
      findsOneWidget,
    );
    expect(find.text('Try a different year'), findsOneWidget);
    expect(passed, equals(0));
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
  });

  testWidgets('Try a different year returns to input state', (tester) async {
    await pumpStep(tester);

    final picker = find.byType(CupertinoPicker);
    await tester.drag(picker, const Offset(0, -32.0 * 6));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try a different year'));
    await tester.pumpAndSettle();

    expect(find.text('When were you born?'), findsOneWidget);
    expect(
      find.text("Sorry, this app isn't available for users under 13."),
      findsNothing,
    );
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`
Expected: FAIL — widget file missing.

- [ ] **Step 3: Implement the widget**

Create `lib/features/onboarding/presentation/onboarding_age_gate_step.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingAgeGateStep extends ConsumerStatefulWidget {
  const OnboardingAgeGateStep({
    super.key,
    required this.onAgeGatePassed,
    required this.currentYear,
  });

  final VoidCallback onAgeGatePassed;
  final int currentYear;

  @override
  ConsumerState<OnboardingAgeGateStep> createState() =>
      _OnboardingAgeGateStepState();
}

class _OnboardingAgeGateStepState extends ConsumerState<OnboardingAgeGateStep> {
  static const _minAge = 13;
  late final int _minYear = widget.currentYear - 100;
  late final int _maxYear = widget.currentYear;
  late final int _defaultYear = widget.currentYear - 18;
  late int _selectedYear = _defaultYear;
  bool _blocked = false;
  bool _saving = false;

  Future<void> _onContinue() async {
    final cutoff = widget.currentYear - _minAge;
    if (_selectedYear > cutoff) {
      setState(() => _blocked = true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(appPreferencesRepositoryProvider).setPassedAgeGate(true);
      ref.invalidate(appPreferencesRepositoryProvider);
      widget.onAgeGatePassed();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_blocked) return _buildBlocked(context);
    return _buildInput(context);
  }

  Widget _buildInput(BuildContext context) {
    final theme = Theme.of(context);
    final years = List<int>.generate(
      _maxYear - _minYear + 1,
      (i) => _maxYear - i,
    );
    final initialIndex = years.indexOf(_selectedYear);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('Quick check',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text('When were you born?',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController:
                    FixedExtentScrollController(initialItem: initialIndex),
                onSelectedItemChanged: (i) =>
                    setState(() => _selectedYear = years[i]),
                children: [for (final y in years) Center(child: Text('$y'))],
              ),
            ),
            FilledButton(
              onPressed: _saving ? null : _onContinue,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocked(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sorry, this app isn't available for users under 13.",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() => _blocked = false),
              child: const Text('Try a different year'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Note on the test for "valid year": because `CupertinoPicker` defaults to `currentYear - 18 = 2008`, the test as written passes by relying on the default already being valid — the `drag(0, -32)` simply confirms a single tick of scroll behavior, then taps Continue. If the drag does not change the year (e.g., the picker snaps back), the test still asserts the *default* year persists and triggers the callback, which is the correct contract.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`
Expected: 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/presentation/onboarding_age_gate_step.dart test/features/onboarding/presentation/onboarding_age_gate_step_test.dart
git commit -m "feat(onboarding): add age gate step with under-13 block"
```

---

## Task 5: Picker Step Widget

**Files:**
- Create: `lib/features/onboarding/presentation/onboarding_picker_step.dart`
- Create: `test/features/onboarding/presentation/onboarding_picker_step_test.dart`

The picker step reads `examListProvider`, filters to `isActive`, sorts by `name`. Tapping a card sets local selection. `Continue` persists via `setSelectedExamId` and invokes `onCompleted` — the router redirect then pulls the user to `/home` (the page does not navigate directly). On error: `SnackBar` with selection preserved.

- [ ] **Step 1: Write the failing tests**

Create `test/features/onboarding/presentation/onboarding_picker_step_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_picker_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(ExamsCompanion.insert(
          id: 'cse',
          code: 'CSE',
          name: 'Civil Service Exam',
          shortName: 'CSE',
          language: 'en',
        ));
    await db.into(db.exams).insert(ExamsCompanion.insert(
          id: 'upcat',
          code: 'UPCAT',
          name: 'UPCAT',
          shortName: 'UPCAT',
          language: 'en',
        ));
  });

  tearDown(() => db.close());

  Future<void> pumpStep(WidgetTester tester, {VoidCallback? onCompleted}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: OnboardingPickerStep(
              onCompleted: onCompleted ?? () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists active exams as emblem cards sorted by name', (tester) async {
    await pumpStep(tester);

    expect(find.text('Choose your exam'), findsOneWidget);
    expect(find.text('You can switch later in More.'), findsOneWidget);
    expect(find.text('CSE'), findsOneWidget); // emblem
    expect(find.text('UPCAT'), findsWidgets); // emblem + name
    expect(find.text('Civil Service Exam'), findsOneWidget);
  });

  testWidgets('Continue is disabled until a card is selected', (tester) async {
    await pumpStep(tester);

    final cont = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continue'));
    expect(cont.onPressed, isNull);

    await tester.tap(find.text('Civil Service Exam'));
    await tester.pump();

    final cont2 = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continue'));
    expect(cont2.onPressed, isNotNull);
  });

  testWidgets('Continue persists selection and invokes onCompleted', (tester) async {
    var completed = 0;
    await pumpStep(tester, onCompleted: () => completed++);

    await tester.tap(find.text('Civil Service Exam'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(completed, equals(1));
    expect(await AppPreferencesRepository(db).selectedExamId(), equals('cse'));
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/onboarding/presentation/onboarding_picker_step_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement the widget**

Create `lib/features/onboarding/presentation/onboarding_picker_step.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPickerStep extends ConsumerStatefulWidget {
  const OnboardingPickerStep({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  ConsumerState<OnboardingPickerStep> createState() =>
      _OnboardingPickerStepState();
}

class _OnboardingPickerStepState extends ConsumerState<OnboardingPickerStep> {
  String? _selectedId;
  bool _saving = false;

  Future<void> _onContinue() async {
    final id = _selectedId;
    if (id == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(appPreferencesRepositoryProvider).setSelectedExamId(id);
      ref.invalidate(appPreferencesRepositoryProvider);
      widget.onCompleted();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Couldn't save selection. Try again."),
          action: SnackBarAction(label: 'Retry', onPressed: _onContinue),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final examsAsync = ref.watch(examListProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('Choose your exam',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('You can switch later in More.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            Expanded(
              child: examsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                    child: Text('Could not load exams.')),
                data: (exams) {
                  final active = [...exams.where((e) => e.isActive)]
                    ..sort((a, b) => a.name.compareTo(b.name));
                  if (active.isEmpty) {
                    return const Center(
                        child: Text('No exams available right now.'));
                  }
                  return ListView.separated(
                    itemCount: active.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final exam = active[i];
                      return _ExamCard(
                        exam: exam,
                        selected: _selectedId == exam.id,
                        onTap: () => setState(() => _selectedId = exam.id),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed:
                  (_selectedId == null || _saving) ? null : _onContinue,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.exam,
    required this.selected,
    required this.onTap,
  });

  final Exam exam;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                exam.code,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                exam.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/onboarding/presentation/onboarding_picker_step_test.dart`
Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/presentation/onboarding_picker_step.dart test/features/onboarding/presentation/onboarding_picker_step_test.dart
git commit -m "feat(onboarding): add exam picker step"
```

---

## Task 6: Onboarding Page Orchestration

**Files:**
- Create: `lib/features/onboarding/presentation/onboarding_page.dart`
- Create: `lib/features/onboarding/onboarding.dart`

The page is a `ConsumerStatefulWidget`. On `initState`, it computes the initial step from `passedAgeGateProvider` and `activeExamFocusProvider` (read synchronously via `ref.read(provider.future)` is async, so use the AsyncValue's `value` directly — by the time the router redirect lets us land here, both have values). For the case where they're still loading, fall back to `welcome`.

The step widgets emit callbacks:
- Welcome `onAdvance` → `setState(step = ageGate)`
- AgeGate `onAgeGatePassed` → `setState(step = picker)` (the router will redirect to `/home` if exam already selected, so this is the "still need to pick" case)
- Picker `onCompleted` → does nothing locally; the router redirect pulls the user to `/home`

We do not write a widget test for `OnboardingPage` itself — its only logic is choosing the initial step, and the four-quadrant router redirect test (Task 8) plus the per-step tests already cover the relevant paths.

- [ ] **Step 1: Implement the page**

Create `lib/features/onboarding/presentation/onboarding_page.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/age_gate.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_picker_step.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _OnboardingStep { welcome, ageGate, picker }

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  _OnboardingStep? _step;

  @override
  Widget build(BuildContext context) {
    _step ??= _initialStep();
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _buildStep(_step!),
      ),
    );
  }

  _OnboardingStep _initialStep() {
    final passed = ref.read(passedAgeGateProvider).valueOrNull ?? false;
    if (!passed) return _OnboardingStep.welcome;
    final focus = ref.read(activeExamFocusProvider).valueOrNull;
    if (focus?.needsSelection ?? true) return _OnboardingStep.picker;
    return _OnboardingStep.welcome;
  }

  Widget _buildStep(_OnboardingStep step) {
    switch (step) {
      case _OnboardingStep.welcome:
        return KeyedSubtree(
          key: const ValueKey('welcome'),
          child: OnboardingWelcomeStep(
            onAdvance: () =>
                setState(() => _step = _OnboardingStep.ageGate),
          ),
        );
      case _OnboardingStep.ageGate:
        return KeyedSubtree(
          key: const ValueKey('ageGate'),
          child: OnboardingAgeGateStep(
            currentYear: DateTime.now().year,
            onAgeGatePassed: () =>
                setState(() => _step = _OnboardingStep.picker),
          ),
        );
      case _OnboardingStep.picker:
        return KeyedSubtree(
          key: const ValueKey('picker'),
          child: OnboardingPickerStep(
            onCompleted: () {
              // Router redirect handles navigation when prefs change.
            },
          ),
        );
    }
  }
}
```

- [ ] **Step 2: Create the barrel**

Create `lib/features/onboarding/onboarding.dart`:

```dart
export 'presentation/onboarding_page.dart';
```

- [ ] **Step 3: Run analyzer to verify clean**

Run: `flutter analyze lib/features/onboarding`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/onboarding/
git commit -m "feat(onboarding): add page orchestrating welcome, age gate, picker"
```

---

## Task 7: Router Refresh Listenable

**Files:**
- Create: `lib/app/router_refresh_listenable.dart`

The adapter is a `ChangeNotifier` that subscribes to a list of `ProviderListenable`s via `WidgetRef`-equivalent `ProviderContainer.listen`. We use the `Ref` from a `Provider.autoDispose` family or accept a `ProviderContainer`. The simplest approach is to take a list of `(container, provider)` pairs and call `container.listen(provider, (_, __) => notifyListeners())`.

No standalone test for this adapter — it's exercised by the redirect matrix tests in Task 8 (the redirect rules wouldn't fire on provider changes without it).

- [ ] **Step 1: Implement the adapter**

Create `lib/app/router_refresh_listenable.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridges Riverpod providers to go_router's `refreshListenable`.
///
/// Each time any of the watched providers emits a new value, the listenable
/// notifies, prompting go_router to re-run its `redirect` callback.
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(
    Ref ref,
    List<ProviderListenable<Object?>> providers,
  ) {
    for (final p in providers) {
      ref.listen<Object?>(p, (_, __) => notifyListeners());
    }
  }
}
```

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze lib/app/router_refresh_listenable.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/router_refresh_listenable.dart
git commit -m "feat(router): add provider-driven refresh listenable"
```

---

## Task 8: Router Redirect + Wire OnboardingPage + Update Boot Tests

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `test/app/app_boot_test.dart`
- Modify: `test/features/shell/app_shell_test.dart`
- Create: `test/app/router_redirect_test.dart`

This task ships the redirect logic together with the page wiring so the app remains buildable between commits. Existing boot/shell tests are updated in lockstep so the redirect doesn't pull them to `/onboarding`.

- [ ] **Step 1: Write the failing redirect tests**

Create `test/app/router_redirect_test.dart`:

```dart
import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(ExamsCompanion.insert(
          id: 'cse',
          code: 'CSE',
          name: 'Civil Service Exam',
          shortName: 'CSE',
          language: 'en',
        ));
    await db.into(db.exams).insert(ExamsCompanion.insert(
          id: 'upcat',
          code: 'UPCAT',
          name: 'UPCAT',
          shortName: 'UPCAT',
          language: 'en',
        ));
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('age gate not passed → boot lands on onboarding welcome',
      (tester) async {
    await pumpApp(tester);
    expect(find.text('Build your study plan'), findsOneWidget);
  });

  testWidgets(
      'age gate passed, needs selection → boot lands on onboarding picker',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(true);
    await pumpApp(tester);
    expect(find.text('Choose your exam'), findsOneWidget);
  });

  testWidgets('age gate passed, valid selection → boot lands on home',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Choose your exam'), findsNothing);
  });

  testWidgets('age gate passed, invalid persisted exam id → onboarding picker',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(true);
    await AppPreferencesRepository(db).setSelectedExamId('removed-exam');
    await pumpApp(tester);
    expect(find.text('Choose your exam'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run redirect tests to verify they fail**

Run: `flutter test test/app/router_redirect_test.dart`
Expected: All 4 fail — the redirect isn't wired yet, so the app still boots to `/home` with a `_Stub` for `/onboarding`.

- [ ] **Step 3: Update existing boot/shell tests to seed prefs**

Edit `test/app/app_boot_test.dart` — after the existing `await db.into(db.exams).insert(...)` block and before `pumpWidget`, add:

```dart
await AppPreferencesRepository(db).setPassedAgeGate(true);
await AppPreferencesRepository(db).setSelectedExamId('cse');
```

And add the import at the top:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
```

Edit `test/features/shell/app_shell_test.dart` — at the end of `setUp`, after the exam insert, add:

```dart
await AppPreferencesRepository(db).setPassedAgeGate(true);
await AppPreferencesRepository(db).setSelectedExamId('cse');
```

And add the same import at the top.

- [ ] **Step 4: Wire the redirect and replace the stub**

Edit `lib/app/router.dart`. Replace the entire file with:

```dart
import 'package:cse_cet_reviewer/app/router_refresh_listenable.dart';
import 'package:cse_cet_reviewer/core/storage/age_gate.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/features/assessment/assessment.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/learn_tab_home.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_list_page.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:cse_cet_reviewer/features/onboarding/onboarding.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_results_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_tab_home.dart';
import 'package:cse_cet_reviewer/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshListenable(ref, [
    passedAgeGateProvider,
    activeExamFocusProvider,
  ]);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final passedAsync = ref.read(passedAgeGateProvider);
      final focusAsync = ref.read(activeExamFocusProvider);
      final passed = passedAsync.valueOrNull;
      final focus = focusAsync.valueOrNull;
      if (passed == null || focus == null) return null;
      final atOnboarding = state.matchedLocation == '/onboarding';
      final needsSelection = focus.needsSelection;
      if (!passed && !atOnboarding) return '/onboarding';
      if (passed && needsSelection && !atOnboarding) return '/onboarding';
      if (passed && !needsSelection && atOnboarding) return '/home';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const AssessmentHomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/study',
                builder: (_, __) => const StudyTabHome(),
                routes: [
                  GoRoute(
                    path: 'topic/:topicId',
                    builder: (_, state) => LessonListPage(
                      topicId: state.pathParameters['topicId']!,
                      examId: state.uri.queryParameters['examId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quiz',
                builder: (_, __) => const QuizTabHome(),
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
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/quiz/quick/:examId',
        builder: (_, state) => QuizPage(
          examId: state.pathParameters['examId']!,
          topicId: state.uri.queryParameters['topicId'],
        ),
      ),
      GoRoute(
        path: '/quiz/results/:attemptId',
        builder: (_, state) =>
            QuizResultsPage(attemptId: state.pathParameters['attemptId']!),
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (_, state) => LessonPage(
          lessonId: state.pathParameters['lessonId']!,
          examId: state.uri.queryParameters['examId'],
        ),
      ),
      GoRoute(
        path: '/assessment/:examId',
        builder: (_, state) =>
            AssessmentPage(examId: state.pathParameters['examId']!),
        routes: [
          GoRoute(
            path: 'results',
            builder: (_, state) =>
                AssessmentResultsPage(examId: state.pathParameters['examId']!),
          ),
        ],
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

Note: the existing `routerProvider` name (lowercased) is preserved exactly. The plan does not rename it.

- [ ] **Step 5: Run all changed tests**

Run: `flutter test test/app/router_redirect_test.dart test/app/app_boot_test.dart test/features/shell/app_shell_test.dart`
Expected: All pass — redirect lands users correctly, boot/shell tests pass with seeded prefs.

- [ ] **Step 6: Commit**

```bash
git add lib/app/router.dart test/app/router_redirect_test.dart test/app/app_boot_test.dart test/features/shell/app_shell_test.dart
git commit -m "feat(router): redirect to onboarding when age gate or exam selection is missing"
```

---

## Task 9: Verification

**Files:** none — verification only.

- [ ] **Step 1: Run analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Run layering check**

Run: `dart run tool/check_layering.dart`
Expected: exit 0.

- [ ] **Step 3: Run format check**

Run: `dart format --set-exit-if-changed lib test`
Expected: exit 0. If it reports unformatted files, run `dart format lib test` and re-stage them in a fixup commit.

- [ ] **Step 4: Run the full test suite**

Run: `flutter test`
Expected: All tests pass (previous count was 268, this plan adds 16 new test cases: 3 repo + 2 provider + 2 welcome + 4 age gate + 3 picker + 4 redirect — expected total in the high 280s).

- [ ] **Step 5: Manual smoke test**

Launch the app on a clean install (delete app data first):

```bash
flutter run --flavor dev
```

Verify:
- App opens to Welcome ("Build your study plan").
- `Get started` → Age gate ("Quick check").
- Continue with a year in valid range → Picker ("Choose your exam").
- Pick CSE → Continue → Home dashboard.
- Hot-restart (`R`) — app reopens directly on Home (prefs persisted).

Then clear app data, run again, and verify the under-13 path:
- Welcome → Get started → Age gate → wheel to 2020 → Continue → block screen.
- `Try a different year` → back at wheel.

- [ ] **Step 6: Confirm no `_Stub('Onboarding')` lingers**

Run: `grep -n "Onboarding" lib/app/router.dart`
Expected: only the `OnboardingPage` import and `builder: (_, __) => const OnboardingPage()` line — no `_Stub('Onboarding')`.

---

## Self-Review

**Spec coverage:**

- Welcome / Age gate / Picker screens — Tasks 3, 4, 5.
- Age gate under-13 block + retry — Task 4 test cases.
- Birth year not persisted — Task 4 implementation stores only the boolean.
- Picker emblem cards using `Exam.code` + `Exam.name` — Task 5 `_ExamCard`.
- Picker save error → SnackBar with retry, selection preserved — Task 5 `_onContinue` catch block.
- Sorted-by-name picker order — Task 5 `.sort((a, b) => a.name.compareTo(b.name))`.
- Storage helpers + key `'passed_age_gate'` with `'true'`/`'false'` values — Task 1.
- `passedAgeGateProvider` parallel to `activeExamFocusProvider` — Task 2.
- Router redirect matrix (4 quadrants) — Task 8 + `router_redirect_test.dart` covers all four.
- `refreshListenable` bridging Riverpod → go_router — Task 7.
- Onboarding outside the bottom-nav shell — Task 8 keeps `/onboarding` as a top-level `GoRoute`, not inside `StatefulShellRoute`.
- `AnimatedSwitcher` step transitions — Task 6.
- Persisted invalid exam id → picker only — covered by Task 8 redirect test "age gate passed, invalid persisted exam id".
- Single-exam shortcut preserved — `activeExamFocusProvider` already auto-selects the only active exam (verified in `selected_exam_focus_test.dart`); no plan change needed.
- Per-tab Phase 1 fallback cards remain — no edits to existing tab homes.
- No new dependencies — confirmed: `CupertinoPicker` ships with Flutter, no `flutter_svg`, no new packages.

**Placeholder scan:** no TBDs, no "implement later", every code block is complete and runnable. The note in Task 4 about wheel-default vs. drag is an implementation note, not a placeholder.

**Type consistency:**

- `OnboardingWelcomeStep.onAdvance: VoidCallback` — same name in widget, test, and `OnboardingPage`.
- `OnboardingAgeGateStep.onAgeGatePassed: VoidCallback`, `currentYear: int` — consistent across widget, test, page.
- `OnboardingPickerStep.onCompleted: VoidCallback` — consistent.
- `AppPreferencesRepository.hasPassedAgeGate()` / `setPassedAgeGate(bool)` — same signatures in repo, tests, and Task 4 widget consumer.
- `passedAgeGateProvider` — same name in `age_gate.dart`, `age_gate_test.dart`, `router.dart`, `onboarding_page.dart`.
- `RouterRefreshListenable(ref, providers)` constructor — matches usage in `router.dart`.

**Risk follow-through:** the `refreshListenable` adapter (flagged in the spec self-review) is specified concretely in Task 7 and exercised by Task 8's redirect tests, which would fail if the bridge wasn't wired correctly.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-16-onboarding-exam-selection.md`. Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?
