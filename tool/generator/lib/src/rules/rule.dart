import 'dart:math';

import '../model.dart';

abstract class Rule {
  String get name;
  int get version;
  Variant generate(ProblemType t, Random r, int index);
}

/// Real rules register here as their separately assigned tasks land.
final ruleRegistry = <String, Rule>{};
