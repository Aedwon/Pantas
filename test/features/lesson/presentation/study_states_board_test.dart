import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      for (final state in ['error', 'empty', 'no-exam']) {
        testWidgets('Study $state stays accessible $brightness $scale',
            (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                studyMapProvider.overrideWith((_) async {
                  if (state == 'error') throw Exception('private error');
                  if (state == 'no-exam') return null;
                  return const StudyMap(
                    examShortName: 'UPCAT',
                    subjects: [],
                    readCount: 0,
                    totalCount: 0,
                    minutesLeftToRead: 0,
                  );
                }),
              ],
              child: MaterialApp(
                theme: brightness == Brightness.dark
                    ? buildDarkTheme()
                    : buildLightTheme(),
                home: MediaQuery(
                  data: MediaQueryData(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: true,
                  ),
                  child: const StudyTabHome(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(StateView), findsOneWidget);
          expect(find.text('Study'), findsOneWidget);
          final view = tester.widget<StateView>(find.byType(StateView));
          expect(
            view.message,
            switch (state) {
              'error' => 'Could not load your topics.',
              'empty' => 'Nothing to study yet',
              _ => 'Choose your exam',
            },
          );
          expect(
            find.text('Try a Quick Quiz'),
            state == 'empty' ? findsOneWidget : findsNothing,
          );
          expect(
            find.text('Choose Exam'),
            state == 'no-exam' ? findsOneWidget : findsNothing,
          );
          expect(find.textContaining('private'), findsNothing);
          expect(
            find.byWidgetPredicate(
              (w) => w is Semantics && (w.properties.liveRegion ?? false),
            ),
            findsWidgets,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
