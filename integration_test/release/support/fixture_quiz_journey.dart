import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'release_harness.dart';
import 'test_content_fixture.dart';

Future<void> startReleaseFixtureQuiz(WidgetTester tester) async {
  await tapReleaseControl(tester, find.text('Quiz').last);
  await tester.scrollUntilVisible(
    find.text('Customize your own'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tapReleaseControl(tester, find.text('Customize your own'));
  await tapReleaseControl(
    tester,
    find.byKey(const ValueKey('scope-select-${ReleaseTestContentIds.topic}')),
  );
  await tapReleaseControl(tester, find.text('Start'));
}
