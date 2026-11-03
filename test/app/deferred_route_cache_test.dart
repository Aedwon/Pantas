import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/routes/deferred_route.dart';

void main() {
  // A page that must hold still (Settings on wide web) cannot show one frame
  // of "loading" every time a row opens a page of a library already loaded.
  Widget host({String? cacheKey}) => ProviderScope(
        child: MaterialApp(
          home: DeferredRoute(
            cacheKey: cacheKey,
            loadLibrary: () => Future<void>.delayed(
              const Duration(milliseconds: 10),
            ),
            builder: (_) => const Text('ready'),
          ),
        ),
      );

  testWidgets('the first route loads, the next one with the same key does not',
      (tester) async {
    await tester.pumpWidget(host(cacheKey: 'library-a'));
    expect(find.text('ready'), findsNothing);
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text('ready'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(host(cacheKey: 'library-a'));
    expect(find.text('ready'), findsOneWidget, reason: 'on the first frame');
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text('ready'), findsOneWidget);
  });

  testWidgets('a route without a key still shows loading first',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(host());
    expect(find.text('ready'), findsNothing);
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text('ready'), findsOneWidget);
  });

  testWidgets('another key is a different library', (tester) async {
    await tester.pumpWidget(host(cacheKey: 'library-b'));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(host(cacheKey: 'library-c'));
    expect(find.text('ready'), findsNothing);
    await tester.pump(const Duration(milliseconds: 20));
  });
}
