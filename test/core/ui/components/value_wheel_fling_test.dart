import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';

import '../../../helpers/pump_app.dart';

// Beta finding (Nov 10, Android 10, phone web): the birth year wheel moved one
// year per swipe. Each item the fling passed was reported as the new
// selection, the parent rebuilt with it, and the wheel jumped to that same
// item, which ended the fling. A fling must travel in proportion to its speed.

final _years = [for (var y = 1960; y <= 2020; y++) '$y'];

class _Host extends StatefulWidget {
  const _Host({required this.birthYear, required this.onChanged});
  final bool birthYear;
  final ValueChanged<int> onChanged;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int selected = 40;

  void _pick(int i) {
    setState(() => selected = i);
    widget.onChanged(i);
  }

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: 200,
          height: 260,
          child: widget.birthYear
              ? ValueWheel.birthYear(
                  values: _years,
                  selectedIndex: selected,
                  onSelected: _pick,
                  label: 'Birth year',
                )
              : ValueWheel(
                  values: _years,
                  selectedIndex: selected,
                  onSelected: _pick,
                  label: 'Year',
                ),
        ),
      );
}

void main() {
  for (final birthYear in [true, false]) {
    testWidgets(
        '${birthYear ? 'birth year' : 'plain'} wheel: a fast fling travels '
        'many rows, not one', (tester) async {
      var last = 40;
      await tester.pumpApp(
        _Host(birthYear: birthYear, onChanged: (i) => last = i),
      );
      await tester.pumpAndSettle();
      await tester.fling(
        find.byType(ListWheelScrollView),
        const Offset(0, 300),
        2500,
      );
      await tester.pumpAndSettle();
      expect(40 - last, greaterThan(5), reason: 'selected index $last');
    });
  }
}
