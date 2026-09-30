import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/roadmap/domain/mock_day.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

void main() {
  const free = RoadmapMockFacts(examHasMock: true, proIsActive: false);
  const pro = RoadmapMockFacts(examHasMock: true, proIsActive: true);

  group('MockDay.place', () {
    for (final mock in [free, pro]) {
      final tier = mock.proIsActive ? 'Pro' : 'Free';

      test('$tier clamps the November review date to December 1', () {
        expect(
          MockDay.place(
            today: DateTime(2026, 9, 30),
            examDay: DateTime(2026, 12, 7),
            reviewOnlyFrom: DateTime(2026, 11, 30),
            mock: mock,
            mockSubmittedInWindow: false,
          ),
          DateTime(2026, 12),
        );
      });

      for (final daysLeft in [2, 3]) {
        test('$tier places the mock one day before an exam $daysLeft days out',
            () {
          expect(
            MockDay.place(
              today: DateTime(2026, 12, 7 - daysLeft),
              examDay: DateTime(2026, 12, 7),
              reviewOnlyFrom: DateTime(2026, 12, 7),
              mock: mock,
              mockSubmittedInWindow: false,
            ),
            DateTime(2026, 12, 6),
          );
        });
      }

      test('$tier keeps a review date inside the window', () {
        expect(
          MockDay.place(
            today: DateTime(2026, 9, 30),
            examDay: DateTime(2026, 12, 7),
            reviewOnlyFrom: DateTime(2026, 12, 3),
            mock: mock,
            mockSubmittedInWindow: false,
          ),
          DateTime(2026, 12, 3),
        );
      });

      test('$tier never places the mock before today', () {
        expect(
          MockDay.place(
            today: DateTime(2026, 12, 4, 23, 59),
            examDay: DateTime(2026, 12, 7),
            reviewOnlyFrom: DateTime(2026, 11, 30),
            mock: mock,
            mockSubmittedInWindow: false,
          ),
          DateTime(2026, 12, 4),
        );
      });

      for (final daysLeft in [-1, 0, 1]) {
        test('$tier schedules no mock with $daysLeft days left', () {
          expect(
            MockDay.place(
              today: DateTime(2026, 12, 7 - daysLeft),
              examDay: DateTime(2026, 12, 7),
              reviewOnlyFrom: DateTime(2026, 12, 7),
              mock: mock,
              mockSubmittedInWindow: false,
            ),
            isNull,
          );
        });
      }

      test('$tier schedules no mock without an exam date', () {
        expect(
          MockDay.place(
            today: DateTime(2026, 9, 30),
            examDay: null,
            reviewOnlyFrom: null,
            mock: mock,
            mockSubmittedInWindow: false,
          ),
          isNull,
        );
      });

      test('$tier does not schedule a second mock in the window', () {
        expect(
          MockDay.place(
            today: DateTime(2026, 12, 4),
            examDay: DateTime(2026, 12, 7),
            reviewOnlyFrom: DateTime(2026, 11, 30),
            mock: mock,
            mockSubmittedInWindow: true,
          ),
          isNull,
        );
      });
    }

    test('an exam without a mock has no mock day', () {
      expect(
        MockDay.place(
          today: DateTime(2026, 9, 30),
          examDay: DateTime(2026, 12, 7),
          reviewOnlyFrom: DateTime(2026, 11, 30),
          mock: const RoadmapMockFacts(examHasMock: false, proIsActive: true),
          mockSubmittedInWindow: false,
        ),
        isNull,
      );
    });

    for (final (submittedDay, expected) in [
      (16, DateTime(2026, 12)),
      (17, DateTime(2026, 12)),
      (20, DateTime(2026, 12, 4)),
      (22, DateTime(2026, 12, 6)),
      (23, null),
    ]) {
      test('Free cooldown from November $submittedDay respects the window', () {
        expect(
          MockDay.place(
            today: DateTime(2026, 9, 30),
            examDay: DateTime(2026, 12, 7),
            reviewOnlyFrom: DateTime(2026, 11, 30),
            mock: RoadmapMockFacts(
              examHasMock: true,
              proIsActive: false,
              lastSubmittedAt: DateTime(2026, 11, submittedDay, 23, 59),
            ),
            mockSubmittedInWindow: false,
          ),
          expected,
        );
      });
    }

    test('Pro ignores a cooldown that would exceed the window', () {
      expect(
        MockDay.place(
          today: DateTime(2026, 9, 30),
          examDay: DateTime(2026, 12, 7),
          reviewOnlyFrom: DateTime(2026, 11, 30),
          mock: RoadmapMockFacts(
            examHasMock: true,
            proIsActive: true,
            lastSubmittedAt: DateTime(2026, 11, 23, 23, 59),
          ),
          mockSubmittedInWindow: false,
        ),
        DateTime(2026, 12),
      );
    });

    test('window offsets use local calendar days across spring DST', () {
      expect(
        MockDay.place(
          today: DateTime(2026, 3),
          examDay: DateTime(2026, 3, 10),
          reviewOnlyFrom: DateTime(2026, 3, 3),
          mock: free,
          mockSubmittedInWindow: false,
        ),
        DateTime(2026, 3, 4),
      );
    });

    test('Free cooldown uses calendar days across fall DST', () {
      expect(
        MockDay.place(
          today: DateTime(2026, 10, 20),
          examDay: DateTime(2026, 11, 7),
          reviewOnlyFrom: DateTime(2026, 10, 31),
          mock: RoadmapMockFacts(
            examHasMock: true,
            proIsActive: false,
            lastSubmittedAt: DateTime(2026, 10, 20, 23, 59),
          ),
          mockSubmittedInWindow: false,
        ),
        DateTime(2026, 11, 3),
      );
    });
  });
}
