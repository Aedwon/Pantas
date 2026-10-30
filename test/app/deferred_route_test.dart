import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/routes/deferred_route.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

void main() {
  Widget app(Future<void> Function() load) => ProviderScope(
        child: MaterialApp(
          theme: buildLightTheme(),
          home: DeferredRoute(
            loadLibrary: load,
            builder: (_) => const Text('Loaded page'),
          ),
        ),
      );

  testWidgets('shows loading before building the loaded page', (tester) async {
    final ready = Completer<void>();
    await tester.pumpWidget(app(() => ready.future));
    await tester.pump(const Duration(milliseconds: 301));
    expect(find.byType(LoadingShapes), findsOneWidget);
    expect(find.text('Loaded page'), findsNothing);
    ready.complete();
    await tester.pumpAndSettle();
    expect(find.text('Loaded page'), findsOneWidget);
    expect(find.byType(LoadingShapes), findsNothing);
  });

  testWidgets('failed load retries and then opens the page', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      app(() async {
        calls++;
        if (calls == 1) throw StateError('offline');
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.text('Loaded page'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Loaded page'), findsOneWidget);
  });
}
