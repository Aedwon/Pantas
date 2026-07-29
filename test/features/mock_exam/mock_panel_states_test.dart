import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

class _FakeMockBlueprintRepo implements MockBlueprintRepo {
  @override
  ContentDatabase get database => throw UnimplementedError();

  @override
  Future<List<MockBlueprint>> byExam(String examId) async {
    if (examId == 'exam_no_blueprint') return [];
    return [
      const MockBlueprint(
        id: 'bp_1',
        examId: 'exam_cse',
        name: 'CSE Practice',
        durationMinutes: 90,
        sectionsJson: '[]',
        totalPublishedItems: 90,
      ),
    ];
  }
}

void main() {
  group('MockPanel no blueprint state', () {
    testWidgets(
        'states plainly that the paper is not ready with no call to action and no invented figures',
        (tester) async {
      await tester.pumpApp(
        MockPanel(
          availability: const MockAvailability.noBlueprint(),
          lastAttempt: null,
          proIsActive: false,
          onTake: () {},
          onResume: () {},
          onViewResults: () {},
        ),
      );

      // Must say the paper is not ready plainly
      expect(find.text('This exam has no mock paper ready yet.'), findsOneWidget);

      // No call to action or dead button to take the exam
      expect(find.text('Take the exam'), findsNothing);
      expect(find.text('Take another'), findsNothing);
      expect(find.byType(BoardButton), findsNothing);

      // No invented figures (no duration, no item count, no date, no coming soon)
      expect(find.textContaining('3 hours'), findsNothing);
      expect(find.textContaining('questions'), findsNothing);
      expect(find.textContaining('coming soon'), findsNothing);
      expect(find.textContaining('Your next one opens on'), findsNothing);
    });
  });

  group('mockAvailabilityProvider no blueprint state', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('returns noBlueprint when exam has no blueprint', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          mockBlueprintRepoProvider.overrideWithValue(_FakeMockBlueprintRepo()),
          mockEntitlementProvider.overrideWithValue(
            const MockEntitlementSnapshot(proIsActive: false),
          ),
          mockAvailabilityClockProvider.overrideWithValue(
            () => DateTime.utc(2026, 8, 11),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        mockAvailabilityProvider(
          const MockAvailabilityRequest(
            userId: 'user_1',
            examId: 'exam_no_blueprint',
          ),
        ).future,
      );

      expect(result.state, MockAvailabilityState.noBlueprint);
    });
  });
}
