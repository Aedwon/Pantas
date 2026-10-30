import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/public_id_provider.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/components/steps_screen.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_field.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_calendar.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  for (final dark in [false, true]) {
    Future<void> pump(
      WidgetTester tester,
      Widget screen, {
      AuthRepository? auth,
    }) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            currentUserProvider.overrideWith((ref) async => null),
            publicIdProvider.overrideWith(
              (ref) => Stream.value(const PublicIdState.notReady()),
            ),
            if (auth != null) authRepositoryProvider.overrideWithValue(auth),
            corpusSubjectsWithTopicsProvider.overrideWith(
              (ref) async => <String, Set<TopicId>>{
                'Mathematics': {'math'},
                'English': {'english'},
              },
            ),
          ],
          child: MaterialApp(
            builder: (context, child) => Shortcuts(
              shortcuts: const {
                SingleActivator(LogicalKeyboardKey.arrowUp):
                    DoNothingAndStopPropagationTextIntent(),
                SingleActivator(LogicalKeyboardKey.arrowDown):
                    DoNothingAndStopPropagationTextIntent(),
                SingleActivator(LogicalKeyboardKey.enter):
                    DoNothingAndStopPropagationTextIntent(),
              },
              child: child!,
            ),
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: Scaffold(body: screen),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('birth year field matches board dimensions $dark',
        (tester) async {
      await pump(
        tester,
        OnboardingAgeGateStep(
          currentYear: 2026,
          onAgeGatePassed: () {},
        ),
      );
      expect(tester.getSize(find.byType(TextField)), const Size(240, 64));
      await tester.tap(find.byTooltip('Next year'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '2013',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('birth year keeps its outline while focused $dark',
        (tester) async {
      await pump(
        tester,
        OnboardingAgeGateStep(currentYear: 2026, onAgeGatePassed: () {}),
      );
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '2000');
      await tester.pump();
      final decoration =
          tester.widget<TextField>(find.byType(TextField)).decoration!;
      expect(decoration.focusedBorder, decoration.enabledBorder);
      expect(decoration.border, decoration.enabledBorder);
    });

    testWidgets('birth year arrows step while typing $dark', (tester) async {
      await pump(
        tester,
        OnboardingAgeGateStep(currentYear: 2026, onAgeGatePassed: () {}),
      );
      await tester.enterText(find.byType(TextField), '2000');
      await tester.pump();
      final shortcuts = find.ancestor(
        of: find.byType(EditableText),
        matching: find.byType(Shortcuts),
      );
      expect(
        shortcuts
            .evaluate()
            .map(
              (e) => (e.widget as Shortcuts)
                  .shortcuts[const SingleActivator(LogicalKeyboardKey.arrowUp)],
            )
            .whereType<VoidCallbackIntent>(),
        isNotEmpty,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '2001',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '2000',
      );
    });

    testWidgets('Enter submits valid years and ignores disabled actions $dark',
        (tester) async {
      var completed = 0;
      await pump(
        tester,
        OnboardingAgeGateStep(
          currentYear: 2026,
          onAgeGatePassed: () => completed++,
        ),
      );
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(completed, 0);
      await tester.enterText(find.byType(TextField), '2000');
      await tester.pump();
      final shortcuts = find.ancestor(
        of: find.byType(EditableText),
        matching: find.byType(Shortcuts),
      );
      expect(
        shortcuts
            .evaluate()
            .map(
              (e) => (e.widget as Shortcuts)
                  .shortcuts[const SingleActivator(LogicalKeyboardKey.enter)],
            )
            .whereType<VoidCallbackIntent>(),
        isNotEmpty,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(completed, 1);
    });

    testWidgets('name input uses board height and typed text size $dark',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(
        tester,
        OnboardingNameField(
          controller: controller,
          label: 'Name',
          onChanged: (_) {},
        ),
      );
      expect(tester.getSize(find.byType(TextField)).height, 56);
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration!.labelText,
        isNull,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).style!.fontSize,
        19,
      );
    });

    testWidgets('outlined exam search uses a white bordered field $dark',
        (tester) async {
      await pump(tester, SearchField(outlined: true, onChanged: (_) {}));
      final fill =
          tester.widget<Container>(find.byKey(const ValueKey('search-fill')));
      final decoration = fill.decoration! as BoxDecoration;
      expect(decoration.color, dark ? const Color(0xFF1F1F1F) : Colors.white);
      expect(decoration.border, isNotNull);
      expect(
        tester.getSize(find.byKey(const ValueKey('search-fill'))).height,
        44,
      );
    });

    testWidgets('usage consent label toggles the row $dark', (tester) async {
      await pump(tester, OnboardingConsentStep(onCompleted: () {}));
      const label = 'Help improve Pantas by sharing anonymous usage data';
      await tester.tap(find.text(label));
      await tester.pump();
      final row = tester.widget<CheckboxRow>(
        find.byWidgetPredicate((w) => w is CheckboxRow && w.title == label),
      );
      expect(row.selected, isTrue);
      expect(tester.getTopLeft(find.text('Terms and Privacy')).dy, 168);
      expect(tester.getSize(find.byType(CheckboxRow).first).height, 56);
      expect(tester.takeException(), isNull);
    });

    testWidgets('custom subject controls match board sizing $dark',
        (tester) async {
      await pump(tester, const CustomTrackSubjectsStep(name: 'My Exam'));
      final tiles = find.byType(CheckboxRow);
      expect(tester.getSize(tiles.first).height, 52);
      expect(
        tester
            .getSize(
              find.ancestor(
                of: tiles.first,
                matching: find.byType(WebCard),
              ),
            )
            .width,
        285,
      );
      final checkbox = find.descendant(
        of: tiles.first,
        matching: find.byKey(const ValueKey('selection-mark')),
      );
      expect(tester.getSize(checkbox), const Size(24, 24));
      final center = tester.getCenter(checkbox);
      expect(center.dx - 12 - tester.getTopLeft(tiles.first).dx, 16);
      expect(
        tester.getTopLeft(find.text('Mathematics')).dx - center.dx - 12,
        12,
      );
      expect(
        tester.widget<Text>(
          find.text(tester.widget<CheckboxRow>(tiles.first).title),
        ),
        isA<Text>().having((text) => text.style?.fontSize, 'font size', 16),
      );
      await tester.tap(find.text('Mathematics'));
      await tester.pump();
      expect(tester.widget<CheckboxRow>(tiles.first).selected, isTrue);
      expect(tester.takeException(), isNull);
    });
    testWidgets('restore loading keeps heading above progress card $dark',
        (tester) async {
      await pump(
        tester,
        const StepsScreen(
          title: 'Restoring your progress',
          subtitle: 'Signed in as student@example.com',
          steps: [
            WorkStep(label: 'Your answers', state: WorkStepState.done),
            WorkStep(
              label: 'Lessons, bookmarks and flags',
              state: WorkStepState.done,
            ),
            WorkStep(
              label: 'Your plan',
              state: WorkStepState.active,
              detail: 'Rebuilt from your progress',
            ),
          ],
        ),
      );
      expect(
        find.ancestor(
          of: find.text('Restoring your progress'),
          matching: find.byType(WebCard),
        ),
        findsNothing,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('step-done-0'))),
        const Size.square(26),
      );
      expect(
        tester.getSize(find.byType(CircularProgressIndicator)),
        const Size.square(16),
      );
      expect(find.text('Continue'), findsNothing);
      expect(tester.getSize(find.byType(WebCard)).width, 520);
      expect(tester.takeException(), isNull);
    });
    testWidgets('sign in keeps account visible while busy $dark',
        (tester) async {
      final auth = _PendingSignIn();
      await pump(tester, const AccountPage(), auth: auth);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Sign in to get one'), findsOneWidget);
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      expect(find.text('Signing in…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      auth.result.complete(const SignInResult.cancelled());
      await tester.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('calendar month and day cells match board heights $dark',
        (tester) async {
      await pump(
        tester,
        Center(
          child: SizedBox(
            width: 780,
            child: OnboardingWebCalendar(
              value: const MonthFirstDate(year: 2026, month: 10, day: 4),
              today: DateTime(2026, 10, 3),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.widgetWithText(TextButton, 'Nov').first).height,
        42,
      );
      expect(tester.getSize(find.widgetWithText(TextButton, '1')).height, 46);
      final day =
          tester.widget<TextButton>(find.widgetWithText(TextButton, '5'));
      expect(day.style!.backgroundColor!.resolve({}), Colors.transparent);
      final picked =
          tester.widget<TextButton>(find.widgetWithText(TextButton, '4'));
      expect(
        picked.style!.backgroundColor!.resolve({}),
        isNot(Colors.transparent),
      );
      expect(
        tester.widget<Text>(find.text('Oct').first).style!.fontWeight,
        FontWeight.w700,
      );
      expect(
        tester.widget<Text>(find.text('4')).style!.fontWeight,
        FontWeight.w700,
      );
      expect(
        tester.widget<Text>(find.text('3')).style!.fontWeight,
        FontWeight.w700,
      );
      expect(
        tester.widget<Text>(find.text('Today')).style!.fontWeight,
        FontWeight.w700,
      );
      expect(
        tester.widget<Text>(find.text('5')).style!.fontWeight,
        FontWeight.w400,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

class _PendingSignIn implements AuthRepository {
  final result = Completer<SignInResult>();

  @override
  Future<SignInResult> signInWithGoogle() => result.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
