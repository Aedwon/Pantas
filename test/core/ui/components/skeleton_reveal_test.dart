import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

// Loading shapes wait 300 ms before they show, so a fast load never flashes
// them. Under the splash hand-off the shapes must already be drawn when the
// logo starts to fade, so that scope shows them at the first frame.
void main() {
  Widget host({SkeletonRevealScope? scope}) {
    const shapes = SkeletonPulse(child: SkeletonBlock(width: 100, height: 20));
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(body: scope ?? shapes),
    );
  }

  testWidgets('by default the shapes show after 300 ms', (tester) async {
    await tester.pumpWidget(host());
    expect(find.byType(SkeletonBlock), findsNothing);
    await tester.pump(const Duration(milliseconds: 299));
    expect(find.byType(SkeletonBlock), findsNothing);
    await tester.pump(const Duration(milliseconds: 2));
    expect(find.byType(SkeletonBlock), findsOneWidget);
  });

  testWidgets('under the hand-off scope the shapes show at the first frame',
      (tester) async {
    await tester.pumpWidget(
      host(
        scope: const SkeletonRevealScope(
          immediate: true,
          child: SkeletonPulse(child: SkeletonBlock(width: 100, height: 20)),
        ),
      ),
    );
    expect(find.byType(SkeletonBlock), findsOneWidget);
    // The pulse still runs.
    await tester.pump(const Duration(milliseconds: 300));
    const pulse = ValueKey('loading-shapes-opacity');
    expect(find.byKey(pulse), findsOneWidget);
  });

  testWidgets('a scope that is not immediate keeps the 300 ms wait',
      (tester) async {
    await tester.pumpWidget(
      host(
        scope: const SkeletonRevealScope(
          immediate: false,
          child: SkeletonPulse(child: SkeletonBlock(width: 100, height: 20)),
        ),
      ),
    );
    expect(find.byType(SkeletonBlock), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SkeletonBlock), findsOneWidget);
  });
}
