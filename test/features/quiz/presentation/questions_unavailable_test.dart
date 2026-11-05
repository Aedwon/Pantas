import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/presentation/questions_unavailable.dart';

void main() {
  testWidgets('a page opened directly with no questions has a way out',
      (tester) async {
    var retried = 0;
    final router = GoRouter(
      initialLocation: '/quiz/viewer/missing',
      routes: [
        GoRoute(
          path: '/quiz',
          builder: (_, __) => const Scaffold(body: Text('quiz page')),
        ),
        GoRoute(
          path: '/quiz/viewer/:id',
          builder: (_, __) => Scaffold(
            body: QuestionsUnavailable(onRetry: () => retried++),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load your questions.'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    expect(retried, 1);
    // Nothing is behind this page, so Back goes to Quiz.
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('quiz page'), findsOneWidget);
  });

  testWidgets('questions that do not exist say so and offer no Try Again',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/quiz/viewer/nope',
      routes: [
        GoRoute(
          path: '/quiz',
          builder: (_, __) => const Scaffold(body: Text('quiz page')),
        ),
        GoRoute(
          path: '/quiz/viewer/:id',
          builder: (_, __) => Scaffold(
            body: QuestionsUnavailable(onRetry: () {}, notFound: true),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('We could not find those questions.'), findsOneWidget);
    expect(find.text('Could not load your questions.'), findsNothing);
    expect(find.text('Try Again'), findsNothing);
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('quiz page'), findsOneWidget);
  });
}
