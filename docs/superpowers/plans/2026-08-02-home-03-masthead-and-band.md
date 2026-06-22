# Home, Plan 3 of 6: The Masthead, the Stats Band and the Page Frame

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
> **Analyzer baseline:** `flutter analyze` reports **27 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. `lib/` is clean. Any issue under `lib/` or `test/` is
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

**Goal:** Give Home the masthead the spec describes, greeting the student by name over a
countdown line that never states more than it knows, centre the stats band, and leave a
page frame the three remaining Home plans drop their panels into.

**Architecture:** `assessment_home_tab.dart` is split: the page shell and its states stay,
the masthead and band become their own widgets in a new `home/` directory, and
`RuledPanel` gains the header action slot Home needs and Quiz did not. No new storage.

**Tech Stack:** Flutter, Riverpod, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-26-home-and-navigation-design.md`
Section 3 (masthead, blocks and their separation, stats band) and Section 7 (copy rules).
**Also binding:** `docs/superpowers/specs/2026-08-02-onboarding-name-and-date-design.md`
Section 4, which owns the countdown copy.

---

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-quiz-tab-02a-frame-and-panel.md` | `RuledPanel` | **Blocking.** Task 3 extends it. Do not write a second panel |
| `2026-08-02-onboarding-flow-and-new-steps.md` Task 1 | `ExamDate`, `ExamDatePrecision` | **Blocking for Task 2.** The countdown cannot be written against a bare `DateTime` without reintroducing the precision bug that type exists to prevent |
| `2026-08-02-onboarding-flow-and-new-steps.md` Task 2 | `UserSettings.name` | **Blocking for Task 2** |
| `2026-08-02-quiz-tab-02b-session-panel.md` | `StatsBand` gaining `centred` | **Not blocking.** Task 4 adds it if it is absent, and skips if present. Check first |

**Task 1 waits on nothing** and can be executed and reviewed while the above land.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.** The kit holds
  `AnswerRow`, `BoardButton`, `ConfirmationDialog`, `EmptyState`, `ErrorBanner`,
  `FaintBars`, `InkTableRow`, `InlineMeter`, `NavGlyph`, `PageScaffold`,
  `PortableTextRenderer`, `ProgressRule`, `QuestionCard`, `QuizProgressBar`,
  `RuledPanel`, `RuledSection`, `SectionHeader` and `StatsBand`.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer. A ruled
  panel is a 1px `rule` rectangle on the same paper as the page.
- **One primary action per screen.** Home's is "Continue lesson" in Plan 4. **This plan
  introduces no `BoardButton` that is not `secondary`**, and the existing non-secondary
  buttons in the no-exam and no-assessment states are each the only button on their own
  state, which is why they stay.
- **Never invent a figure.** Every number this plan prints is measured from the
  student's own use or asserted by the student. The countdown table in Task 2 is an
  evidentiary rule, not a copy preference.
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**, sentence case,
  stat labels lowercase, no emoji, no all-caps. Every user-facing string here is quoted
  from a spec. Do not improvise copy.
- **Analyzer must be clean.**

## Verification commands

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

---

## File structure

`assessment_home_tab.dart` is 350 lines and holds the page, both empty states, the
loading and error states, the band, the focus topics and two navigation helpers. Plans 4
to 6 add three more panels to it. Split it now, while it is still small enough to move in
one commit, rather than after it has doubled.

| File | Responsibility |
|---|---|
| `lib/features/home/presentation/home_tab.dart` (create) | The page: exam focus, the four states, the scroll, and the slots Plans 4 to 6 fill |
| `lib/features/home/presentation/widgets/home_masthead.dart` (create) | Greeting, name or invitation, countdown line, gear |
| `lib/features/home/presentation/widgets/home_stats_band.dart` (create) | The two figures and the "Lately" line |
| `lib/features/home/presentation/home_providers.dart` (create) | `homeMastheadProvider`, so the masthead is not reaching into three repositories itself |
| `lib/core/ui/components/ruled_panel.dart` (modify) | Gains `action` and `onAction` |
| `lib/features/assessment/presentation/assessment_home_tab.dart` (delete) | Replaced by the above |
| `lib/app/router.dart` (modify) | Points the Home branch at `HomeTab` |

**Why `lib/features/home/` and not `lib/features/assessment/`.** Home stopped being the
assessment's screen the moment it grew four blocks reading four different features. Its
current address is why `_FocusTopics` reaches into `TopicMastery` directly: the file lives
inside the feature it should be consuming through a provider.

---

### Task 1: `RuledPanel` gains a header action

**Files:**
- Modify: `lib/core/ui/components/ruled_panel.dart`
- Test: `test/core/ui/components/ruled_panel_test.dart` (extend)

**Interfaces:**
- Consumes: `RuledPanel({required String heading, required Widget child, String? count})`
  as Quiz 2a built it.
- Produces: `RuledPanel({required String heading, required Widget child, String? count,
  String? action, VoidCallback? onAction})`. Plans 4, 5 and 6 all pass `action`.

**The header's trailing slot holds one thing.** The Quiz spec settled this: it is a count
in 12px `inkMuted` or an action in board at 12/600, and never a status word. Passing both
is a caller error, so assert on it rather than picking one silently.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('an action renders in board and fires', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      harness(
        RuledPanel(
          heading: 'Practice',
          action: 'See all',
          onAction: () => tapped = true,
          child: const Text('body'),
        ),
      ),
    );
    final action = tester.widget<Text>(find.text('See all'));
    expect(action.style?.color, AppColors.light.board);
    await tester.tap(find.text('See all'));
    expect(tapped, isTrue);
  });

  testWidgets('an action with no handler is muted, not board', (tester) async {
    await tester.pumpWidget(
      harness(
        const RuledPanel(
          heading: 'Practice',
          action: 'See all',
          child: Text('body'),
        ),
      ),
    );
    expect(
      tester.widget<Text>(find.text('See all')).style?.color,
      AppColors.light.inkMuted,
    );
  });

  testWidgets('a count and an action together is an error', (tester) async {
    await tester.pumpWidget(
      harness(
        const RuledPanel(
          heading: 'Practice',
          count: '3',
          action: 'See all',
          child: Text('body'),
        ),
      ),
    );
    expect(tester.takeException(), isA<AssertionError>());
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/core/ui/components/ruled_panel_test.dart`
Expected: FAIL, `No named parameter with the name 'action'`.

- [ ] **Step 3: Extend the component**

```dart
  const RuledPanel({
    required this.heading,
    required this.child,
    this.count,
    this.action,
    this.onAction,
    super.key,
  }) : assert(
          count == null || action == null,
          'The panel header carries one trailing element: a count or an '
          'action, never both.',
        );

  final String heading;
  final Widget child;

  /// Tabular figures in 12px `inkMuted`. Never a status word.
  final String? count;

  /// A text action in board at 12/600, in the same slot as [count].
  final String? action;
  final VoidCallback? onAction;
```

In the header `Row`, after the existing `count` branch, add the action. Mirror
`SectionHeader`'s treatment exactly, including its comment about why `Padding` and not
`Center`: it keeps the action on the title's baseline while still reaching the 48dp tap
target.

```dart
              if (action != null)
                InkWell(
                  onTap: onAction,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      action!,
                      style: styles.labelSmall.copyWith(
                        color: onAction != null
                            ? colors.board
                            : colors.inkMuted,
                      ),
                    ),
                  ),
                ),
```

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/core/ui/components/ruled_panel_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/ruled_panel.dart test/core/ui/components/ruled_panel_test.dart
git commit -m "feat(ui): let RuledPanel carry a header action

Home's panels need one; Quiz's did not. A count and an action together
asserts, because the header's trailing slot holds exactly one thing."
```

---

### Task 2: The masthead

**Files:**
- Create: `lib/features/home/presentation/home_providers.dart`
- Create: `lib/features/home/presentation/widgets/home_masthead.dart`
- Test: `test/features/home/presentation/widgets/home_masthead_test.dart`

**Interfaces:**
- Consumes: `UserSettings.name` (`String?`) and `UserSettings.examDate` (`ExamDate?`)
  from onboarding Tasks 1 and 2; `ExamDatePrecision`; `ExamDate.daysUntil(DateTime)`;
  `activeExamFocusProvider` from `lib/core/storage/selected_exam_focus.dart`.
- Produces: `class HomeMastheadData` with fields
  `({String? name, String examShortName, ExamDate? examDate})`;
  `final homeMastheadProvider = FutureProvider<HomeMastheadData>(...)`;
  `class HomeMasthead extends ConsumerWidget`. Plan 6 reads nothing from here; Plans 4
  and 5 read only the page frame in Task 4.

**The three lines, and the rule under each:**

```
Magandang gabi,          kicker, time-based, as _greeting() already implements
Aedwon                   serif, the stored name, or the invitation
42 days to UPCAT         the meta line
```

**The meta line may print exactly three things**, per
`2026-08-02-onboarding-name-and-date-design.md` Section 4. This is the evidentiary rule,
not a copy preference:

| `examDate` | The line |
|---|---|
| precision `day` | `42 days to UPCAT` |
| precision `month` | `Your exam is in October 2026` |
| null | `UPCAT`, the exam short name alone |

**The month state is not a degraded countdown.** It is the true statement available. A day
count derived from a month is a figure made of a measurement and an assumption, which
`2026-07-30-progress-tab-design.md` Section 1 bans outright. `ExamDate.day` returns null at
month precision precisely so this cannot be got wrong by accident: do not reach around it.

**The no-name state** is `Add your name` in the name slot, tapping through to the Settings
name row. Muted, never board: the single primary action on Home belongs to Plan 4. It is
self-healing and needs no migration prompt, which is why every existing install gets it
for free.

**Month names are written out in full and in English**, `October 2026`. Do not use
`intl`'s `DateFormat` with a device locale here: the rest of the app's copy is English
with Filipino greetings only, and a device set to another locale would print a month name
in a language nothing else on the screen uses.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/home/presentation/widgets/home_masthead_test.dart
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/home/presentation/home_providers.dart';
import 'package:cse_cet_reviewer/features/home/presentation/widgets/home_masthead.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(HomeMastheadData data, {DateTime? now}) {
  return ProviderScope(
    overrides: [
      homeMastheadProvider.overrideWith((ref) async => data),
    ],
    child: MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: HomeMasthead(now: now ?? DateTime(2026, 8, 2, 20)),
      ),
    ),
  );
}

void main() {
  testWidgets('greets by name in the evening', (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.onDay(DateTime(2026, 9, 13)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Magandang gabi,'), findsOneWidget);
    expect(find.text('Aedwon'), findsOneWidget);
  });

  testWidgets('a day-precision date prints a day count', (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.onDay(DateTime(2026, 9, 13)),
        ),
        now: DateTime(2026, 8, 2, 20),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('42 days to UPCAT'), findsOneWidget);
  });

  testWidgets('a month-precision date never prints a day count',
      (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.inMonth(year: 2026, month: 10),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your exam is in October 2026'), findsOneWidget);
    expect(find.textContaining('days'), findsNothing);
  });

  testWidgets('no date prints the exam short name alone', (tester) async {
    await tester.pumpWidget(
      harness(
        const HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('UPCAT'), findsOneWidget);
    expect(find.textContaining('days'), findsNothing);
    expect(find.textContaining('Your exam'), findsNothing);
  });

  testWidgets('no name shows the invitation, muted and not board',
      (tester) async {
    await tester.pumpWidget(
      harness(
        const HomeMastheadData(
          name: null,
          examShortName: 'UPCAT',
          examDate: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final invitation = tester.widget<Text>(find.text('Add your name'));
    expect(invitation.style?.color, isNot(AppColors.light.board));
  });

  testWidgets('an exam today prints zero days, not a negative', (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.onDay(DateTime(2026, 8, 2)),
        ),
        now: DateTime(2026, 8, 2, 20),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0 days to UPCAT'), findsOneWidget);
  });

  testWidgets('one day reads "1 day", not "1 days"', (tester) async {
    await tester.pumpWidget(
      harness(
        HomeMastheadData(
          name: 'Aedwon',
          examShortName: 'UPCAT',
          examDate: ExamDate.onDay(DateTime(2026, 8, 3)),
        ),
        now: DateTime(2026, 8, 2, 20),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 day to UPCAT'), findsOneWidget);
  });

  testWidgets('the kicker follows the hour', (tester) async {
    for (final (hour, kicker) in [
      (8, 'Magandang umaga,'),
      (14, 'Magandang hapon,'),
      (21, 'Magandang gabi,'),
    ]) {
      await tester.pumpWidget(
        harness(
          const HomeMastheadData(
            name: 'Aedwon',
            examShortName: 'UPCAT',
            examDate: null,
          ),
          now: DateTime(2026, 8, 2, hour),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(kicker), findsOneWidget);
    }
  });
}
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/home/`
Expected: FAIL, `Couldn't resolve the package ... home_providers.dart`.

- [ ] **Step 3: Write the provider**

```dart
// lib/features/home/presentation/home_providers.dart
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// Everything the masthead prints, gathered once so the widget reads one
/// provider rather than three repositories.
@immutable
class HomeMastheadData {
  const HomeMastheadData({
    required this.name,
    required this.examShortName,
    required this.examDate,
  });

  /// Null and empty are the same state: no name.
  final String? name;
  final String examShortName;
  final ExamDate? examDate;

  @override
  bool operator ==(Object other) =>
      other is HomeMastheadData &&
      other.name == name &&
      other.examShortName == examShortName &&
      other.examDate == examDate;

  @override
  int get hashCode => Object.hash(name, examShortName, examDate);
}

final homeMastheadProvider = FutureProvider<HomeMastheadData>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final settings = await ref.watch(userSettingsProvider.future);
  final name = settings.name?.trim();
  return HomeMastheadData(
    name: name == null || name.isEmpty ? null : name,
    examShortName: focus.exam?.shortName ?? '',
    examDate: settings.examDate,
  );
});
```

Find the real settings provider name with
`grep -rn "UserSettings>" lib/features/settings/presentation/` and use it. If none
exists, add one beside the repository provider rather than reading the repository from
the widget.

- [ ] **Step 4: Write the masthead**

```dart
// lib/features/home/presentation/widgets/home_masthead.dart
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/home/presentation/home_providers.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeMasthead extends ConsumerWidget {
  const HomeMasthead({required this.now, super.key});

  /// Injected so the kicker and the day count are testable without a clock.
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final data = ref.watch(homeMastheadProvider).valueOrNull;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingFor(now),
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 1),
              if (data == null)
                const FaintBars()
              else ...[
                if (data.name == null)
                  // Muted, never board: Home's one primary action is
                  // "Continue lesson". Tapping through is self-healing, so
                  // no install needs a migration prompt.
                  InkWell(
                    onTap: () => context.push('/settings'),
                    child: Text(
                      'Add your name',
                      style: styles.displaySmall
                          .copyWith(color: colors.inkMuted),
                    ),
                  )
                else
                  Text(data.name!, style: styles.displaySmall),
                const SizedBox(height: 2),
                Text(
                  metaLineFor(
                    examShortName: data.examShortName,
                    examDate: data.examDate,
                    now: now,
                  ),
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: Icon(
            Icons.settings_outlined,
            size: 20,
            color: colors.inkMuted,
          ),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}

@visibleForTesting
String greetingFor(DateTime now) {
  final h = now.hour;
  if (h < 12) return 'Magandang umaga,';
  if (h < 18) return 'Magandang hapon,';
  return 'Magandang gabi,';
}

/// The three states the meta line may print, and no fourth.
///
/// A day count derived from a month would be a figure made of a measurement
/// and an assumption. `ExamDate.day` is null at month precision so that this
/// cannot be got wrong by reaching around the type.
@visibleForTesting
String metaLineFor({
  required String examShortName,
  required ExamDate? examDate,
  required DateTime now,
}) {
  if (examDate == null) return examShortName;
  switch (examDate.precision) {
    case ExamDatePrecision.month:
      return 'Your exam is in ${_monthName(examDate.month)} ${examDate.year}';
    case ExamDatePrecision.day:
      final days = examDate.daysUntil(now);
      if (days == null) return examShortName;
      final unit = days == 1 ? 'day' : 'days';
      return '$days $unit to $examShortName';
  }
}

/// Written out in English rather than through `intl`, because the rest of
/// this screen's copy is English and a device locale would print one month
/// name in a language nothing else here uses.
String _monthName(int month) {
  const names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return names[month - 1];
}
```

**If `daysUntil` returns a negative** for an exam already past, that is a state this plan
does not design. Return the exam short name alone rather than printing `-3 days`, and
raise it: an exam date in the past is a real state (the student sat the exam) and it
belongs to the exam-switching spec, not here.

- [ ] **Step 5: Run the tests and make sure they pass**

Run: `flutter test test/features/home/`
Expected: PASS, 8 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/features/home test/features/home
git commit -m "feat(home): add the masthead, with a countdown that states only what it knows

Three states, per the onboarding spec's Section 4: a day count at day
precision, the month at month precision, and the exam short name alone
with no date. A day count derived from a month is a figure made of a
measurement and an assumption, so it is never printed."
```

---

### Task 3: The stats band and the "Lately" line

**Files:**
- Create: `lib/features/home/presentation/widgets/home_stats_band.dart`
- Modify: `lib/core/ui/components/stats_band.dart`, **only if `centred` is absent**
- Test: `test/features/home/presentation/widgets/home_stats_band_test.dart`
- Test: `test/core/ui/components/stats_band_test.dart` (extend, if you added `centred`)

**Interfaces:**
- Consumes: `StatsBand`, `StatFigure`; `homeAtomProvider` from
  `lib/features/metrics/providers/home_atom_provider.dart`, which the current Home
  already uses for the "Lately" chip.
- Produces: `class HomeStatsBand extends ConsumerWidget`, taking
  `({required ExamId examId, required DateTime now})`.

**Check `StatsBand` for `centred` first.** Quiz 2b adds it, and if it has landed this task
adds nothing to the component. If it has not:

```dart
  const StatsBand({required this.figures, this.centred = false, super.key});

  /// Centres each figure and its label. Home and the Quiz tab both centre;
  /// the shipped default is left-aligned and stays that way so nothing
  /// already drawn moves.
  final bool centred;
```

and inside, swap the two alignments:

```dart
          child: Column(
            crossAxisAlignment: centred
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
```

**The two figures are accuracy, and lessons read against total.** Days to exam lives in
the masthead meta line and is not repeated here, which is what frees the second slot.

**Lessons read is not available to this plan.** It counts `lesson_progress_local` rows
against `lessons` for the active exam, and no provider does that today. Study Plan 1
builds the lesson foundations and `readCountForTopicProvider` (`storage.dart:98`) already
computes the topic rollup and is referenced nowhere. **Write the second figure against a
provider you add here**, `lessonsReadProvider`, returning `({int read, int total})`, and
implement it with a direct query. If Study Plan 1 has landed and exposes an exam-level
rollup, consume that instead of adding a second query.

**With no assessment result, the band does not render at all.** The Study brainstorm
settled this: "In the no-assessment state the stats band is dropped entirely rather than
half filled." A band showing lessons read beside an empty accuracy slot is the half-filled
state that rule exists to prevent.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/home/presentation/widgets/home_stats_band_test.dart
void main() {
  testWidgets('prints accuracy and lessons read, centred', (tester) async {
    await tester.pumpWidget(
      harness(accuracyPct: 64, read: 41, total: 96),
    );
    await tester.pumpAndSettle();

    expect(find.text('64%'), findsOneWidget);
    expect(find.text('accuracy'), findsOneWidget);
    expect(find.text('41'), findsOneWidget);
    expect(find.text('/96'), findsOneWidget);
    expect(find.text('lessons read'), findsOneWidget);

    expect(tester.widget<StatsBand>(find.byType(StatsBand)).centred, isTrue);
  });

  testWidgets('days to exam is not repeated here', (tester) async {
    await tester.pumpWidget(harness(accuracyPct: 64, read: 41, total: 96));
    await tester.pumpAndSettle();
    expect(find.textContaining('days'), findsNothing);
  });

  testWidgets('no assessment result drops the band entirely', (tester) async {
    await tester.pumpWidget(harness(accuracyPct: null, read: 41, total: 96));
    await tester.pumpAndSettle();
    expect(find.byType(StatsBand), findsNothing);
  });

  testWidgets('the Lately line renders beneath, with no em dash',
      (tester) async {
    await tester.pumpWidget(
      harness(
        accuracyPct: 64,
        read: 41,
        total: 96,
        lately: 'day 6 streak, your longest this month.',
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Lately: day 6 streak, your longest this month.'),
      findsOneWidget,
    );
    expect(find.textContaining('—'), findsNothing);
  });

  testWidgets('no Lately atom renders no line', (tester) async {
    await tester.pumpWidget(
      harness(accuracyPct: 64, read: 41, total: 96, lately: null),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Lately'), findsNothing);
  });
}
```

Write `harness` with `ProviderScope` overrides for the accuracy, lessons and atom
providers. Follow whatever override style the existing Home tests use.

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/home/presentation/widgets/home_stats_band_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the widget**

The "Lately" line is **centred** beneath the band, separated by a faint rule. Its copy is
`Lately: ` followed by the atom text. The current code writes `Lately — ` with an em dash
(`assessment_home_tab.dart:140`), which Section 7 of the spec bans by name. Fixing it is
part of this task.

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/features/home/`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(home): centre the stats band and fix the Lately line's em dash

Two figures: accuracy, and lessons read against total. Days to exam
lives in the masthead meta line and is not repeated. With no assessment
result the band is dropped whole rather than half filled."
```

---

### Task 4: The page, and the slots the remaining plans fill

**Files:**
- Create: `lib/features/home/presentation/home_tab.dart`
- Delete: `lib/features/assessment/presentation/assessment_home_tab.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/home/presentation/home_tab_test.dart`

**Interfaces:**
- Consumes: `HomeMasthead` and `HomeStatsBand` from Tasks 2 and 3; `activeExamFocusProvider`.
- Produces: `class HomeTab extends ConsumerWidget`, and **three named build methods
  returning `const SizedBox.shrink()`**: `_upNextPanel`, `_practicePanel`,
  `_tendenciesPanel`. Plans 4, 5 and 6 each replace exactly one of them.

**Why stubs and not nothing:** three later plans each need to know where their panel goes
and in what order, and the spec fixes the order. A stub with the spec's block order
written beside it is how each of those plans stays a one-file change.

**The four states, in order of check:**

| State | What renders |
|---|---|
| Exam focus loading | `FaintBars` |
| No exam chosen | The existing "Choose your exam" fallback, unchanged |
| Exam chosen, no assessment result | Masthead, no band, the existing "Take the assessment" invitation |
| Exam chosen, result present | Masthead, band, Lately, then the three panel slots |

**The error state must stop printing `e.toString()`.** The current `_HomeError` prints
the exception to students (`assessment_home_tab.dart:88` passes `e.toString()`). Use
`ErrorBanner` in its error variant with `Could not load your home. Pull down to try
again.` The Quiz and Progress specs both forbid the exception string by name and Home was
never exempted.

**Do not delete `/study/topic/:topicId` in this plan.** Four live call sites still reach
it, two of them in the file being deleted here. Repoint the two in
`assessment_home_tab.dart` to the Study map (`/study`) as you move the file, and leave
`assessment_results_page.dart:122` and `:203` to Study Plan 2 Task 8, which owns them.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('with a result: masthead, band, and three panel slots',
      (tester) async { /* ... */ });

  testWidgets('with no result: masthead and the assessment invitation, no band',
      (tester) async { /* ... */ });

  testWidgets('with no exam: the choose-exam fallback and no masthead',
      (tester) async { /* ... */ });

  testWidgets('an error never shows the exception string', (tester) async {
    await tester.pumpWidget(harnessThatThrows('PlatformException(42)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('PlatformException'), findsNothing);
    expect(
      find.text('Could not load your home. Pull down to try again.'),
      findsOneWidget,
    );
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/home/presentation/home_tab_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write `HomeTab`**

Block order is fixed by the spec and the stubs carry it:

```dart
        // Block order, spec Section 3. Each stub is replaced by exactly
        // one later plan; do not reorder them.
        _upNextPanel(context, ref),      // Home plan 4
        _practicePanel(context, ref),    // Home plan 5
        _tendenciesPanel(context, ref),  // Home plan 6
```

```dart
  Widget _upNextPanel(BuildContext context, WidgetRef ref) =>
      const SizedBox.shrink();
```

- [ ] **Step 4: Repoint the router**

In `lib/app/router.dart`, the Home branch points at `AssessmentHomeTab`. Point it at
`HomeTab` and delete the old import.

- [ ] **Step 5: Delete the old file and fix every reference**

```bash
git rm lib/features/assessment/presentation/assessment_home_tab.dart
grep -rn "assessment_home_tab\|AssessmentHomeTab" lib test
```
Expected: no hits. Delete or move any test that targeted the old file.

- [ ] **Step 6: Run everything**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```
Expected: PASS, `No issues found!`, no format diff.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "refactor(home): move Home into its own feature and stop printing exceptions

assessment_home_tab.dart held the page, four states, the band, the focus
topics and two navigation helpers, and three more panels were about to
land in it. Home stopped being the assessment's screen the moment it read
four features.

The error state showed e.toString() to students, which the Quiz and
Progress specs both forbid by name and Home was never exempted."
```

---

## What this plan deliberately leaves undone

- **The three panels.** Plans 4, 5 and 6, into the stubs Task 4 leaves.
- **`/study/topic/:topicId`.** Two of its four call sites die with the deleted file; the
  other two belong to Study Plan 2 Task 8. The route must not be deleted until that runs.
- **The exam-already-past state.** `daysUntil` can return a negative and Task 2 falls back
  to the exam short name. Designing that state belongs with exam switching.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- `grep -rn "toString()" lib/features/home` returns nothing.
- `grep -rn "—" lib/features/home` returns nothing.
- A month-precision exam date prints no day count anywhere on the screen.
- The band is absent, not empty, when there is no assessment result.
- Report these as text signals and ask Aedwon to look. Never screenshot the emulator.
