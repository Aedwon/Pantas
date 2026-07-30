import 'dart:async';

import 'package:pantas/features/wrapped/domain/wrapped_trigger_event.dart';

class WrappedTriggerBus {
  WrappedTriggerBus();

  final _controller = StreamController<WrappedTriggerEvent>.broadcast();

  Stream<WrappedTriggerEvent> get stream => _controller.stream;

  void emit(WrappedTriggerEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  Future<void> close() => _controller.close();
}
