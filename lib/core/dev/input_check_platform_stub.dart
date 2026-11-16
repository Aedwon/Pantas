import 'package:pantas/core/dev/input_check.dart';

/// Only a browser has a session to keep the choice in.
InputCheckStore createInputCheckStore() => const NoInputCheckStore();

/// Only a browser has a screen refresh to count. Returns the stop function.
void Function() startVsyncCounter(void Function() onVsync) => () {};

/// Only a browser has a page to publish the numbers to.
void publishInputCheck(Map<String, Object?> data) {}
