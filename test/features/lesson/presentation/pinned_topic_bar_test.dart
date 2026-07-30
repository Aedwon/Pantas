import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/pinned_topic_bar.dart';

import '../../../helpers/pump_app.dart';
import 'fake_open_topic.dart';

const topic = StudyTopic(
  id: 't1',
  name: 'Algebra',
  lessons: [],
  readCount: 6,
  hasBookmark: false,
);

Future<void> pumpBar(WidgetTester tester, {VoidCallback? onScrollBack}) async {
  await tester.pumpAppWithProviders(
    Scaffold(
      body: PinnedTopicBar(
        topic: topic,
        onScrollBack: onScrollBack ?? () {},
      ),
    ),
    overrides: [openTopicProvider.overrideWith(FakeOpenTopic.new)],
  );
}

void main() {
  testWidgets('the bar names the open topic and its fraction', (tester) async {
    await pumpBar(tester);
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('6 / 0'), findsOneWidget);
  });

  testWidgets('the caret points down while the topic is open', (tester) async {
    await pumpBar(tester);
    await tester.pumpAndSettle();

    expect(
      tester.widget<InkChevron>(find.byType(InkChevron)).pointsDown,
      isTrue,
    );
  });

  testWidgets('tapping the name scrolls back rather than collapsing',
      (tester) async {
    var scrolledBack = false;
    await pumpBar(tester, onScrollBack: () => scrolledBack = true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    expect(scrolledBack, isTrue);
  });

  testWidgets('the caret has its own tap target', (tester) async {
    await pumpBar(tester);
    await tester.pumpAndSettle();

    final caretTarget = find.byKey(const ValueKey('pinned-topic-collapse'));
    expect(tester.getSize(caretTarget).width, greaterThanOrEqualTo(48));
  });
}
