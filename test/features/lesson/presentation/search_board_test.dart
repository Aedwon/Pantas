import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('result metrics and contrast dark=$dark scale=$scale',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final colors = dark ? PantasColors.dark : PantasColors.light;
        await tester.pumpWidget(ProviderScope(
          overrides: [
            searchQueryProvider.overrideWith((_) => 'stoich'),
            searchResultsProvider.overrideWith((_) async => const [
                  LessonSearchHit(
                      lessonId: 'l1',
                      title: 'Stoichiometry',
                      topicName: 'Chemistry',
                      estimatedMinutes: 13,
                      titleMatch: SearchSnippet(
                          text: 'Stoichiometry',
                          matchStart: 0,
                          matchLength: 6)),
                ]),
          ],
          child: MaterialApp(
            theme: ThemeData(
                scaffoldBackgroundColor: colors.background,
                extensions: [colors, PantasType.create(colors: colors)]),
            home: MediaQuery(
              data: MediaQueryData(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true),
              child: const Scaffold(
                  body: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SearchResults())),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        final label = tester.widget<Text>(find.text('1 LESSON'));
        expect(label.style!.fontSize, 13);
        expect(label.style!.fontWeight, FontWeight.w600);
        expect(label.style!.height, 1.35);
        expect(label.style!.letterSpacing, .26);
        final minutes = tester.widget<Text>(find.text('13 min'));
        expect(minutes.style!.fontSize, 15);
        expect(minutes.style!.height, 1.35);
        final row = tester.widget<ListRow>(find.byType(ListRow));
        expect(row.verticalPadding, 12);
        final title = tester.widget<Text>(find.text('Stoichiometry'));
        expect(title.style!.fontSize, 17);
        expect(title.style!.letterSpacing, -.204);
        expect(title.maxLines, 1);
        expect(title.overflow, TextOverflow.ellipsis);
        for (final text in [label, minutes, title]) {
          final foreground = text.style!.color!;
          final background = text == label ? colors.background : colors.surface;
          final a = foreground.computeLuminance();
          final b = background.computeLuminance();
          expect((a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05)),
              greaterThanOrEqualTo(4.5));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
