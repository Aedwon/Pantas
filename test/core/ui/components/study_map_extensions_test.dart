import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_map_entry.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_topic_section.dart';

import '../../../helpers/pump_app.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Study Today metrics, contrast and keyboard $dark $scale',
          (tester) async {
        var opened = 0;
        await tester.pumpApp(
          Builder(
            builder: (context) => Theme(
              data: Theme.of(context).copyWith(
                extensions: [
                  if (dark) PantasColors.dark else PantasColors.light,
                  context.type,
                ],
              ),
              child: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Builder(
                  builder: (context) => Material(
                    color: context.colors.pickerBackground,
                    child: StudyLessonRow(
                      lesson: const StudyLesson(
                        id: 'l1',
                        title: 'Circles',
                        estimatedMinutes: 8,
                        isRead: false,
                        isBookmarked: false,
                      ),
                      isToday: true,
                      onTap: () => opened++,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final today = tester.widget<Text>(find.text('Today'));
        expect(today.style!.fontSize, 12);
        expect(today.style!.fontWeight, FontWeight.w600);
        expect(today.style!.height, 1.35);
        final tag = tester
            .widget<Container>(find.byKey(const ValueKey('study-today-tag')));
        final background = (tag.decoration! as BoxDecoration).color!;
        expect(
          contrast(today.style!.color!, background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('study-today-tag'))).height,
          scale == 1 ? 22 : closeTo(32.4, .5),
        );
        expect(tag.padding, const EdgeInsets.symmetric(horizontal: 8));
        final title = tester.widget<Text>(find.text('Circles'));
        expect(title.style!.fontSize, 17);
        expect(title.style!.height, 1.35);
        expect(title.maxLines, isNull);
        expect(
          contrast(
            title.style!.color!,
            (dark ? PantasColors.dark : PantasColors.light).pickerBackground,
          ),
          greaterThanOrEqualTo(4.5),
        );
        final minutes = tester.widget<Text>(find.text('8 min'));
        expect(minutes.style!.fontSize, 15);
        expect(
          contrast(
            minutes.style!.color!,
            (dark ? PantasColors.dark : PantasColors.light).pickerBackground,
          ),
          greaterThanOrEqualTo(4.5),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(opened, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('entry follows delayed 450ms house curve at intermediate frames',
      (tester) async {
    await tester.pumpApp(
      const StudyMapEntry(
        delay: Duration(milliseconds: 100),
        child: Text('Subject'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
    await tester.pump(const Duration(milliseconds: 225));
    final value = PantasCurves.houseOut.transform(.5);
    expect(
      tester.widget<Opacity>(find.byType(Opacity)).opacity,
      closeTo(value, .001),
    );
    expect(
      tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.byType(StudyMapEntry),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .getTranslation()
          .y,
      closeTo(12 * (1 - value), .001),
    );
    await tester.pumpAndSettle();
  });
  testWidgets('study ring has board track and fill strokes', (tester) async {
    await tester.pumpApp(
      const ProgressRing.study(
        fraction: .5,
        delay: Duration(milliseconds: 100),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final ring = find.byKey(const ValueKey('progress-ring-paint'));
    expect(ring, paints..circle(strokeWidth: 2));
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      ring,
      paints
        ..circle(strokeWidth: 2)
        ..something((method, args) {
          if (method != #drawArc) return false;
          expect(
            args[2] as double,
            closeTo(
              3.141592653589793 * PantasCurves.houseOut.transform(.5),
              .001,
            ),
          );
          expect((args[4] as Paint).strokeWidth, closeTo(2.4, .00001));
          return true;
        }),
    );
    await tester.pumpAndSettle();
  });
}
