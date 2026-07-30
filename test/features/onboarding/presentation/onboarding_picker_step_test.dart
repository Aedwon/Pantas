import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_picker_step.dart';

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
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'cse',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentExam(
      contentDb,
      examId: 'upcat',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
    );
  });

  tearDown(() => db.close());

  Future<void> pumpStep(
    WidgetTester tester, {
    VoidCallback? onCompleted,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
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
          contentDatabaseProvider.overrideWithValue(contentDb),
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

  testWidgets('the branch row sits below a rule, apart from the exams',
      (tester) async {
    await pumpStep(tester);

    expect(find.text("My exam isn't on this list"), findsOneWidget);
  });

  testWidgets('tapping the branch row does not select anything',
      (tester) async {
    await pumpStep(tester);

    await tester.tap(find.text("My exam isn't on this list"));
    await tester.pumpAndSettle();

    final cont = tester
        .widget<BoardButton>(find.widgetWithText(BoardButton, 'Continue'));
    expect(cont.onPressed, isNull);
  });

  testWidgets('a custom track is never listed as an exam', (tester) async {
    await seedContentExam(
      contentDb,
      examId: 'custom_1',
      code: 'custom',
      name: 'My Custom Exam',
      shortName: 'My Custom Exam',
      isCustom: true,
    );

    await pumpStep(tester);

    expect(find.text('My Custom Exam'), findsNothing);
  });
}
