// The design lint canary. `tool/checks/design_lint.dart` expects exactly this
// finding. If the plugin reports nothing here, it did not load and the run
// fails instead of passing with an empty result. Keep the literal.
import 'package:flutter/widgets.dart';

Widget designLintCanary() => const SizedBox(width: 1234);
