import 'dart:convert';

import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();

    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Science',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Chemistry',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l1',
      topicId: 't1',
      title: 'Lesson l1',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 10,
    );

    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('e1');
    await NotificationRationaleRepository(db).markShown();
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          entitlementProvider.overrideWith(
            (_) => Stream.value(const Entitlement.free()),
          ),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('/study with a topicId opens that topic', (tester) async {
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    container.read(routerProvider).go('/study?topicId=t1');
    await tester.pumpAndSettle();

    expect(find.text('Lesson l1'), findsOneWidget);
  });

  testWidgets('/study/topic/t1 is no longer a route', (tester) async {
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    container.read(routerProvider).go('/study/topic/t1');
    await tester.pumpAndSettle();

    expect(find.textContaining('no routes for location'), findsOneWidget);
  });
}
