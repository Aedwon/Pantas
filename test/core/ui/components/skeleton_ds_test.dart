import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/skeleton_fade.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/web/web_debrief_loading.dart';

import '../../../helpers/ds_matrix.dart';

BoxDecoration _decoration(WidgetTester tester, Finder block) =>
    tester.widget<Container>(block).decoration! as BoxDecoration;

void main() {
  dsMatrix(
    'Skeleton pages fit every width, theme and text scale',
    (context) => const SizedBox(
      height: 700,
      child: SkeletonRevealScope(
        immediate: true,
        child: Column(
          children: [
            Expanded(child: SkeletonQuestionPage()),
          ],
        ),
      ),
    ),
    scroll: false,
  );

  dsMatrix(
    'Skeleton results page fits',
    (context) => const SkeletonRevealScope(
      immediate: true,
      child: SkeletonResultsPage(),
    ),
    scroll: false,
  );

  dsMatrix(
    'Web debrief loading fits',
    (context) => const SkeletonRevealScope(
      immediate: true,
      child: SingleChildScrollView(child: WebDebriefLoading()),
    ),
    scroll: false,
  );

  dsMatrix(
    'Skeleton blocks use fill-skeleton and the system radii',
    (context) => const SkeletonRevealScope(
      immediate: true,
      child: SkeletonPulse(
        child: Column(
          children: [
            SkeletonBlock(height: 14, width: 120),
            SkeletonBlock(height: 40, width: 120),
            SkeletonCard(height: 80, width: 120),
            SkeletonBlock(height: 40, width: 40, radius: PantasRadius.full),
          ],
        ),
      ),
    ),
    check: (tester, cell) async {
      final colors = cell.dark ? PantasColors.dark : PantasColors.light;
      final blocks = find.descendant(
        of: find.byType(SkeletonPulse),
        matching: find.byType(Container),
      );
      expect(_decoration(tester, blocks.at(0)).color, colors.fillSkeleton);
      // Lines `radius-xs` (5), blocks `radius-md` (12), cards `radius-xl` (18),
      // avatars `radius-full`.
      expect(
        _decoration(tester, blocks.at(0)).borderRadius,
        BorderRadius.circular(PantasRadius.xs),
      );
      expect(
        _decoration(tester, blocks.at(1)).borderRadius,
        BorderRadius.circular(PantasRadius.md),
      );
      expect(
        _decoration(tester, blocks.at(2)).borderRadius,
        BorderRadius.circular(PantasRadius.xl),
      );
      expect(
        _decoration(tester, blocks.at(3)).borderRadius,
        BorderRadius.circular(PantasRadius.full),
      );
    },
  );

  testWidgets('Loading shapes use the line radius', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const SkeletonRevealScope(immediate: true, child: LoadingShapes()),
    );
    final block = find.descendant(
      of: find.byType(LoadingShapes),
      matching: find.byType(SkeletonBlock),
    );
    expect(block, findsNWidgets(3));
    expect(
      _decoration(
        tester,
        find
            .descendant(of: block.first, matching: find.byType(Container))
            .first,
      ).borderRadius,
      BorderRadius.circular(PantasRadius.xs),
    );
  });

  testWidgets('Skeleton appears after 300ms and pulses 1 to 0.45 over 1300ms',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const SkeletonPulse(child: SkeletonBlock(height: 14, width: 100)),
    );
    // Pumped 500ms by the harness, so it is showing and mid pulse.
    final opacity = find.byKey(const ValueKey('loading-shapes-opacity'));
    expect(opacity, findsOneWidget);
    var min = 1.0;
    var max = 0.0;
    for (var i = 0; i < 26; i++) {
      await tester.pump(PantasDurations.pulse ~/ 26);
      final value = tester.widget<Opacity>(opacity).opacity;
      if (value < min) min = value;
      if (value > max) max = value;
    }
    expect(min, closeTo(.45, .02));
    expect(max, closeTo(1, .02));
  });

  testWidgets('Skeleton is hidden for the first 300ms', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: false),
        home: const SkeletonPulse(child: SkeletonBlock(height: 14, width: 100)),
      ),
    );
    await tester.pump(PantasDurations.wait ~/ 2);
    expect(find.byType(SkeletonBlock), findsNothing);
    await tester.pump(PantasDurations.wait);
    expect(find.byType(SkeletonBlock), findsOneWidget);
  });

  testWidgets('Skeleton holds still under reduced motion', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: const SkeletonPulse(
            child: SkeletonBlock(height: 14, width: 100),
          ),
        ),
      ),
    );
    final opacity = find.byKey(const ValueKey('loading-shapes-opacity'));
    final first = tester.widget<Opacity>(opacity).opacity;
    await tester.pump(PantasDurations.pulse ~/ 3);
    expect(tester.widget<Opacity>(opacity).opacity, first);
    expect(first, 1);
  });

  testWidgets('Skeleton hand-off fades shapes out and content in',
      (tester) async {
    var loading = true;
    late StateSetter change;
    await pumpDs(
      tester,
      dsCells.first,
      StatefulBuilder(
        builder: (_, setState) {
          change = setState;
          return SkeletonFade(
            loading: loading,
            skeleton: const SizedBox(height: 40, width: 100),
            content: const SizedBox(height: 40, width: 100, child: Text('Hi')),
          );
        },
      ),
    );
    change(() => loading = false);
    await tester.pump();
    // 200ms out, 300ms in after 60ms: the whole hand-off is 360ms.
    await tester.pump(const Duration(milliseconds: 100));
    final shapes = tester.widget<FadeTransition>(
      find.byKey(SkeletonFade.shapesFadeKey),
    );
    final content = tester.widget<FadeTransition>(
      find.byKey(SkeletonFade.contentFadeKey),
    );
    expect(shapes.opacity.value, inExclusiveRange(0, 1));
    expect(content.opacity.value, inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(SkeletonFade.shapesFadeKey), findsNothing);
  });
}
