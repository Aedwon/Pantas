import 'package:pantas/features/wrapped/domain/wrapped_trigger_event.dart';

class WrappedBatcher {
  const WrappedBatcher();

  List<WrappedTriggerEvent> batch(List<WrappedTriggerEvent> events) {
    final standalone = <WrappedTriggerEvent>[];
    final batchableByDay = <String, List<WrappedTriggerEvent>>{};
    for (final event in events) {
      if (!event.isBatchable) {
        standalone.add(event);
        continue;
      }
      batchableByDay.putIfAbsent(_dayKey(event.firedAt), () => []).add(event);
    }

    final batched = <WrappedTriggerEvent>[];
    for (final entry in batchableByDay.entries) {
      final events = entry.value;
      if (events.length == 1) {
        batched.add(events.single);
      } else {
        final first = events.first;
        batched.add(
          WrappedTriggerEvent(
            artifactId: 'milestone_batch_${entry.key}',
            examId: first.examId,
            userId: first.userId,
            firedAt: first.firedAt,
            children: List.unmodifiable(events),
          ),
        );
      }
    }
    return [...standalone, ...batched]
      ..sort((a, b) => a.firedAt.compareTo(b.firedAt));
  }

  String _dayKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
