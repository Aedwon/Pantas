import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

SearchField _desktop({String? value}) => SearchField(
      onChanged: (_) {},
      hint: 'Lessons, topics',
      keyHint: const WebKeyHint('Ctrl K'),
      controller: TextEditingController(text: value),
    );

void main() {
  goldenSheet(
    'search_field',
    [
      ...interactionStates('Phone', (_) => _phone(), web: false, width: 300),
      GoldenState(
        'Outlined',
        (_) => SearchField(
          onChanged: (_) {},
          hint: 'Lessons, topics',
          outlined: true,
        ),
        web: false,
        width: 300,
      ),
      GoldenState(
        'Phone, with a value',
        (_) => _phone('Fractions'),
        web: false,
        width: 300,
      ),
      GoldenState('Desktop, key hint', (_) => _desktop(), width: 300),
      GoldenState(
        'Desktop, hover',
        (_) => _desktop(),
        action: GoldenAction.hover,
        width: 300,
      ),
      GoldenState(
        'Desktop, focus',
        (_) => _desktop(),
        action: GoldenAction.focus,
        width: 300,
      ),
      GoldenState(
        'Desktop, with a value',
        (_) => _desktop(value: 'Fractions'),
        width: 300,
      ),
    ],
    cellWidth: 300,
    columns: 4,
    web: true,
  );
}

SearchField _phone([String? value]) => SearchField(
      onChanged: (_) {},
      hint: 'Lessons, topics',
      controller: TextEditingController(text: value),
    );
