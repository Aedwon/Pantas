import 'package:pantas/core/ui/components/pro_tag.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet('pro_mark', [
    GoldenState('Pro mark', (_) => const ProMark()),
  ]);
}
