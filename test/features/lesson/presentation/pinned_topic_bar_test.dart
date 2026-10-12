import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/pinned_topic_bar.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('pinned row is 47px, has no count and closes from the keyboard',
      (tester) async {
    var closed = 0;
    await tester.pumpApp(
      PinnedTopicBar(
        topic: const StudyTopic(
          id: 't',
          name: 'Geometry',
          lessons: [],
          readCount: 0,
          hasBookmark: false,
        ),
        onClose: () => closed++,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Geometry'), findsOneWidget);
    expect(find.text('open'), findsNothing);
    expect(find.textContaining('/'), findsNothing);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('pinned-topic-collapse')))
          .height,
      47,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(closed, 1);
  });
}
