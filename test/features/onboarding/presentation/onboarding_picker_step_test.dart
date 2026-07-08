import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_picker_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

class _ThrowingPrefsRepo extends AppPreferencesRepository {
  _ThrowingPrefsRepo(super.db);

  @override
  Future<void> setSelectedExamId(String examId) async {
    throw Exception('DB write failed');
  }
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'cse',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'upcat',
            code: 'UPCAT',
            name: 'UPCAT',
            shortName: 'UPCAT',
            language: 'en',
          ),
        );
  });

  tearDown(() => db.close());

  Future<void> pumpStep(
    WidgetTester tester, {
    VoidCallback? onCompleted,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildLightTheme(),
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

  testWidgets('lists active exams as emblem cards sorted by name',
      (tester) async {
    await pumpStep(tester);

    expect(find.text('Choose your exam'), findsOneWidget);
    expect(find.text('You can switch later in Settings.'), findsOneWidget);
    expect(find.text('CSE'), findsOneWidget); // emblem
    expect(find.text('UPCAT'), findsWidgets); // emblem + name
    expect(find.text('Civil Service Exam'), findsOneWidget);
  });

  testWidgets('Continue is disabled until a card is selected', (tester) async {
    await pumpStep(tester);

    final cont = tester
        .widget<BoardButton>(find.widgetWithText(BoardButton, 'Continue'));
    expect(cont.onPressed, isNull);

    await tester.tap(find.text('Civil Service Exam'));
    await tester.pump();

    final cont2 = tester
        .widget<BoardButton>(find.widgetWithText(BoardButton, 'Continue'));
    expect(cont2.onPressed, isNotNull);
  });

  testWidgets('Continue persists selection and invokes onCompleted',
      (tester) async {
    var completed = 0;
    await pumpStep(tester, onCompleted: () => completed++);

    await tester.tap(find.text('Civil Service Exam'));
    await tester.pump();
    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(completed, equals(1));
    expect(await AppPreferencesRepository(db).selectedExamId(), equals('cse'));
  });

  testWidgets('save failure shows SnackBar and preserves selection',
      (tester) async {
    var completed = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          appPreferencesRepositoryProvider.overrideWith(
            (ref) => _ThrowingPrefsRepo(db),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: OnboardingPickerStep(
              onCompleted: () => completed++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Civil Service Exam'));
    await tester.pump();
    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't save selection. Try again."), findsOneWidget);
    expect(completed, equals(0));
    final cont = tester.widget<BoardButton>(
      find.widgetWithText(BoardButton, 'Continue'),
    );
    expect(cont.onPressed, isNotNull);
  });
}
