import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/wrapped/application/wrapped_trigger_bus.dart';
import 'package:pantas/features/wrapped/domain/wrapped_trigger_event.dart';

void main() {
  test('emits wrapped trigger events without replaying old events', () async {
    final bus = WrappedTriggerBus();
    addTearDown(bus.close);
    final event = WrappedTriggerEvent(
      artifactId: 'post_mock_recap',
      examId: 'exam_cse',
      userId: 'user_1',
      firedAt: DateTime.utc(2026, 6, 10),
    );

    final first = expectLater(bus.stream, emits(event));
    bus.emit(event);
    await first;

    await expectLater(
      bus.stream.timeout(const Duration(milliseconds: 10)),
      emitsError(isA<TimeoutException>()),
    );
  });
}
