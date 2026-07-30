import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeOpenTopic extends OpenTopicController {
  TopicId? _value;

  @override
  Future<TopicId?> build() async => _value;

  @override
  Future<void> toggle(TopicId topicId) async {
    _value = _value == topicId ? null : topicId;
    state = AsyncData(_value);
  }

  @override
  Future<void> close() async {
    _value = null;
    state = const AsyncData(null);
  }
}
