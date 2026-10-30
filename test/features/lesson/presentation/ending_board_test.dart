import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/domain/use_cases/decide_ending.dart';
import 'package:pantas/features/lesson/presentation/pages/topic_ending_page.dart';

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

  for (final scale in [1.0, 2.0]) {
    testWidgets(
        'unread long title stays single-line with full semantics scale=$scale',
        (tester) async {
      const title = 'Similarity and Congruence in Complex Geometric Figures';
      const ending = TopicStoppedShort(
        studentName: null,
        topicName: 'Geometry',
        examAndSubject: 'UPCAT · Mathematics',
        footing: '1 of 2 lessons read',
        dateLine: 'October 2, 2026',
        unread: [
          StudyLesson(
            id: 'long',
            title: title,
            estimatedMinutes: 8,
            isRead: false,
            isBookmarked: false,
          ),
        ],
      );
      final semantics = tester.ensureSemantics();
      try {
        await pumpAccessibilitySurface(
          tester,
          const ProviderScope(
            child: TopicEndingPage(topicId: 'geometry', ending: ending),
          ),
          textScale: scale,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        final row = tester.widget<ListRow>(find.byType(ListRow));
        expect(row.wrapTitle, isFalse);
        final label = tester.widget<Text>(find.text(title));
        expect(label.maxLines, 1);
        expect(label.overflow, TextOverflow.ellipsis);
        expect(
          find.bySemanticsLabel(RegExp(RegExp.escape(title))),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }

  for (final reduced in [true, false]) {
    testWidgets(
        'direct topic adapter uses shared delayed loading reduced=$reduced',
        (tester) async {
      final load = Completer<StudyMap?>();
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [studyMapProvider.overrideWith((_) => load.future)],
          child: const TopicEndingPage(topicId: 'geometry'),
        ),
        disableAnimations: reduced,
      );
      expect(find.byType(SkeletonPulse), findsWidgets);
      final opacity = find.byKey(const ValueKey('loading-shapes-opacity'));
      expect(opacity, findsNothing);
      await tester.pump(const Duration(milliseconds: 299));
      expect(opacity, findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      expect(opacity, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 325));
      expect(
        tester.widget<Opacity>(opacity).opacity,
        reduced ? 1 : lessThan(1),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      load.complete(null);
    });
  }

  for (final failure in [true, false]) {
    testWidgets('direct topic adapter retains message on error=$failure',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [
            studyMapProvider.overrideWith((_) async {
              if (failure) throw StateError('fixture');
              return null;
            }),
          ],
          child: const TopicEndingPage(topicId: 'geometry'),
        ),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      final finder = find.text(
        failure ? 'Failed to load topic ending.' : 'Study map unavailable.',
      );
      expect(finder, findsOneWidget);
      final label = tester.widget<Text>(finder);
      final context = tester.element(finder);
      expect(label.style!.fontSize, context.type.body.fontSize);
      expect(label.style!.color, context.colors.secondaryLabel);
      expect(tester.takeException(), isNull);
    });
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
