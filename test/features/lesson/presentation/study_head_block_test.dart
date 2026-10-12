import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_head_block.dart';

import '../../../helpers/pump_app.dart';

StudyMap mapWith({
  int read = 0,
  int total = 4,
  int minutesLeft = 0,
}) =>
    StudyMap(
      examShortName: 'UPCAT',
      subjects: const [],
      readCount: read,
      totalCount: total,
      minutesLeftToRead: minutesLeft,
    );

void main() {
  testWidgets('the head prints the exam and both figures', (tester) async {
    await tester.pumpAppWithProviders(
      StudyHeadBlock(map: mapWith(read: 1, minutesLeft: 150)),
      overrides: [
        lastOpenedLessonProvider.overrideWith((ref) async => null),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('UPCAT'), findsNothing);
    expect(find.text('25'), findsNothing);
    expect(find.text('covered'), findsNothing);
    expect(find.text('2'), findsNothing);
    expect(find.text('left to read'), findsNothing);
  });

  testWidgets('under an hour left reads in minutes', (tester) async {
    await tester.pumpAppWithProviders(
      StudyHeadBlock(map: mapWith(minutesLeft: 45)),
      overrides: [
        lastOpenedLessonProvider.overrideWith((ref) async => null),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('45'), findsNothing);
    expect(find.text('m'), findsNothing);
  });

  testWidgets('nothing opened yet hides the resume row', (tester) async {
    await tester.pumpAppWithProviders(
      StudyHeadBlock(map: mapWith()),
      overrides: [
        lastOpenedLessonProvider.overrideWith((ref) async => null),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('LAST OPENED'), findsNothing);
    expect(find.text('Resume'), findsNothing);
  });

  testWidgets('a last opened lesson offers to resume', (tester) async {
    const lesson = Lesson(
      id: 'l1',
      topicId: 't1',
      title: 'Balancing equations',
      summary: 'How to balance.',
      bodyJson: [],
      estimatedMinutes: 12,
    );

    await tester.pumpAppWithProviders(
      StudyHeadBlock(map: mapWith()),
      overrides: [
        lastOpenedLessonProvider.overrideWith((ref) async => lesson),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('LAST OPENED'), findsOneWidget);
    expect(find.text('Balancing equations'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });
}
