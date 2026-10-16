import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/domain/use_cases/decide_ending.dart';
import 'package:pantas/features/lesson/presentation/pages/topic_ending_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookplate.dart';

import '../../../helpers/accessibility.dart';

void main() {
  final date = DateTime(2026, 10, 2);
  StudyTopic topic({required bool complete}) => StudyTopic(
        id: 'geometry',
        name: 'Geometry',
        lessons: [
          const StudyLesson(
            id: 'l1',
            title: 'Circles',
            estimatedMinutes: 10,
            isRead: true,
            isBookmarked: false,
          ),
          StudyLesson(
            id: 'l2',
            title: 'Congruence',
            estimatedMinutes: 8,
            isRead: complete,
            isBookmarked: false,
          ),
        ],
        readCount: complete ? 2 : 1,
        hasBookmark: false,
      );

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      for (final complete in [false, true]) {
        testWidgets('topic plate complete=$complete dark=$dark scale=$scale',
            (tester) async {
          final ending = decideEnding(
            topic: topic(complete: complete),
            subject:
                const StudySubject(id: 'math', name: 'Mathematics', topics: []),
            examShortName: 'UPCAT',
            studentName: 'Aedwon',
            today: date,
            nextTopic: null,
          );
          await pumpAccessibilitySurface(
            tester,
            ProviderScope(
              child: TopicEndingPage(topicId: 'geometry', ending: ending),
            ),
            brightness: dark ? Brightness.dark : Brightness.light,
            textScale: scale,
            viewportSize: Size(scale == 1 ? 390 : 320, 844),
            disableAnimations: true,
          );
          expect(find.text('Aedwon'), findsNothing);
          expect(find.byType(Bookplate), findsNothing);
          expect(find.text('Geometry'), findsOneWidget);
          expect(find.text('UPCAT · Mathematics'), findsOneWidget);
          expect(find.text(PantasDates.full(date)), findsOneWidget);
          expect(
            find.text(
              complete ? '2 lessons, all read' : '1 of 2 lessons read',
            ),
            findsOneWidget,
          );
          expect(find.text('Study'), findsOneWidget);
          final card = tester
              .widget<Container>(find.byKey(const ValueKey('ending-plate')));
          final decoration = card.decoration! as BoxDecoration;
          final colors = dark ? PantasColors.dark : PantasColors.light;
          expect(decoration.color, colors.surface);
          expect(decoration.borderRadius, BorderRadius.circular(18));
          expect((decoration.border! as Border).top.width, .5);
          expect((decoration.border! as Border).top.color, colors.separator);
          expect(
            card.padding,
            const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          );
          if (!complete) {
            expect(find.text('STILL UNREAD'), findsOneWidget);
            expect(find.byType(GroupedSection), findsOneWidget);
            expect(find.byType(ListRow), findsOneWidget);
            expect(find.text('8 min'), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('finished day names Home at both return controls',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ProviderScope(
        child: TopicEndingPage(topicId: 'geometry', ending: DayFinished()),
      ),
      disableAnimations: true,
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
    expect(find.text("That's enough for today."), findsOneWidget);
    expect(find.byKey(const ValueKey('ending-plate')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
