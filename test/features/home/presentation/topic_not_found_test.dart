import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/presentation/performance_screen.dart';

void main() {
  testWidgets('a topic address the exam does not have says so, with no retry',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStudyCoverageProvider.overrideWithValue(true),
          topicDetailProvider('nope').overrideWith(
            (_) => Future<TopicDetail>.error(const TopicNotFound('nope')),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MediaQuery(
            data: MediaQueryData(size: Size(390, 844), disableAnimations: true),
            child: TopicScreen(topicId: 'nope'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('We could not find that topic.'), findsOneWidget);
    expect(find.text('Try Again'), findsNothing);
    expect(find.text('Could not load your topic.'), findsNothing);
  });

  testWidgets('a topic read that failed for another reason still retries',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStudyCoverageProvider.overrideWithValue(true),
          topicDetailProvider('geo').overrideWith(
            (_) => Future<TopicDetail>.error(StateError('offline')),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MediaQuery(
            data: MediaQueryData(size: Size(390, 844), disableAnimations: true),
            child: TopicScreen(topicId: 'geo'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load your topic.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });
}
