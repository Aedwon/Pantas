import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'reader board type, spacing and lesson scale $brightness $scale',
          (tester) async {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        final contentDb = openTestContentDatabase();
        addTearDown(contentDb.close);
        final prefs = AppPreferencesRepository(db);
        await prefs.setDeviceValue('lesson_text_scale', '1.25');
        const reader = ReaderContext(
          lesson: Lesson(
            id: 'l',
            topicId: 't',
            title: 'Layers of the Earth and Composition',
            summary: '',
            estimatedMinutes: 10,
            bodyJson: [
              {
                '_type': 'block',
                'style': 'h2',
                'children': [
                  {'text': 'Core Concept'},
                ],
              },
              {
                '_type': 'block',
                'style': 'normal',
                'children': [
                  {'text': 'Earth has several layers.'},
                ],
              }
            ],
          ),
          topicId: 't',
          topicName: 'Earth Science and Astronomy',
          next: null,
          positionInTopic: 1,
          lessonsInTopic: 1,
          topicLessons: [],
          isRead: false,
          isBookmarked: false,
          examId: null,
        );
        await pumpAccessibilitySurface(
          tester,
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              contentDatabaseProvider.overrideWithValue(contentDb),
              readerContextProvider('l').overrideWith((_) async => reader),
            ],
            child: const LessonPage(lessonId: 'l'),
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
        );
        await tester.pumpAndSettle();
        expect(find.byType(LessonTextScale), findsOneWidget);
        final eyebrow =
            tester.widget<Text>(find.text('EARTH SCIENCE AND ASTRONOMY'));
        expect(eyebrow.style!.fontSize, 13);
        expect(eyebrow.style!.fontWeight, FontWeight.w600);
        expect(eyebrow.style!.letterSpacing, .52);
        final title = tester.widget<Text>(
          find.text('Layers of the Earth and Composition').first,
        );
        expect(title.style!.fontSize, 30);
        expect(title.style!.fontWeight, FontWeight.w700);
        expect(title.style!.height, 1.15);
        expect(title.style!.letterSpacing, -.66);
        expect(
          tester.getTopLeft(find.text('EARTH SCIENCE AND ASTRONOMY')).dx,
          24,
        );
        expect(
          tester
                  .getTopLeft(
                    find.text('Layers of the Earth and Composition').first,
                  )
                  .dy -
              tester.getBottomLeft(find.text('EARTH SCIENCE AND ASTRONOMY')).dy,
          closeTo(18, .1),
        );
        final bodyContext =
            tester.element(find.text('Earth has several layers.'));
        expect(
          MediaQuery.textScalerOf(bodyContext).scale(17),
          17 * scale * 1.25,
        );
        final colors = bodyContext.colors;
        final luminances = [
          colors.label.computeLuminance(),
          colors.surface.computeLuminance(),
        ]..sort();
        expect(
          (luminances.last + .05) / (luminances.first + .05),
          greaterThanOrEqualTo(4.5),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      });
    }
  }
}
