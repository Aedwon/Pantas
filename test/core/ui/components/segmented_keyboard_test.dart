import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/ds_matrix.dart';

const _labels = ['Day', 'Week', 'Month'];

/// A switch that keeps its own selection, followed by one more control, so a
/// second Tab shows whether the switch is a single Tab stop.
class _Host extends StatefulWidget {
  const _Host({required this.build, required this.log});
  final Widget Function(int selected, ValueChanged<int> onChanged) build;
  final List<int> log;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 358,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.build(_selected, (next) {
              widget.log.add(next);
              setState(() => _selected = next);
            }),
            TextButton(onPressed: () {}, child: const Text('After')),
          ],
        ),
      );
}

String? _focusedLabel(WidgetTester tester) {
  final focus = FocusManager.instance.primaryFocus;
  if (focus?.context == null) return null;
  for (final label in [..._labels, 'After']) {
    final inside = find.descendant(
      of: find.byElementPredicate((e) => e == focus!.context),
      matching: find.text(label),
    );
    if (inside.evaluate().isNotEmpty) return label;
  }
  return null;
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump(const Duration(milliseconds: 400));
}

void _keyboardScript({
  required String name,
  required Widget Function(int selected, ValueChanged<int> onChanged) build,
  required DsCell cell,
}) {
  testWidgets('$name: roving focus and keys ($cell)', (tester) async {
    final log = <int>[];
    await pumpDs(tester, cell, _Host(build: build, log: log));
    expect(tester.takeException(), isNull);

    // One Tab stop: the first Tab lands on the selected segment, the second
    // leaves the switch.
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focusedLabel(tester), 'Week');
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focusedLabel(tester), 'After');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await _press(tester, LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(_focusedLabel(tester), 'Week');

    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(log, [2]);
    expect(_focusedLabel(tester), 'Month');
    // Wraps from the last to the first.
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(log, [2, 0]);
    expect(_focusedLabel(tester), 'Day');
    // And from the first to the last.
    await _press(tester, LogicalKeyboardKey.arrowLeft);
    expect(log, [2, 0, 2]);
    expect(_focusedLabel(tester), 'Month');
    await _press(tester, LogicalKeyboardKey.arrowUp);
    expect(log.last, 1);
    expect(_focusedLabel(tester), 'Week');
    await _press(tester, LogicalKeyboardKey.arrowDown);
    expect(log.last, 2);
    await _press(tester, LogicalKeyboardKey.home);
    expect(log.last, 0);
    expect(_focusedLabel(tester), 'Day');
    await _press(tester, LogicalKeyboardKey.end);
    expect(log.last, 2);
    expect(_focusedLabel(tester), 'Month');

    // The new selection is now the one Tab stop.
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focusedLabel(tester), 'After');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await _press(tester, LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(_focusedLabel(tester), 'Month');
    expect(tester.takeException(), isNull);
  });
}

void main() {
  setUpAll(loadDsFonts);

  // At 390 the phone switch runs, at 1100 and 1440 the wide control: the
  // matrix covers both widgets, light and dark, at text scale 1.0 and 2.0.
  for (final cell in dsCells) {
    _keyboardScript(
      name: 'SegmentedSwitch',
      cell: cell,
      build: (selected, onChanged) => SegmentedSwitch(
        labels: _labels,
        selected: selected,
        onChanged: onChanged,
      ),
    );
  }

  for (final cell in [dsCells[0], dsCells[3], dsCells[4], dsCells[7]]) {
    _keyboardScript(
      name: 'WebSegmentedControl',
      cell: cell,
      build: (selected, onChanged) => WebSegmentedControl(
        labels: _labels,
        selected: selected,
        onChanged: onChanged,
      ),
    );
    _keyboardScript(
      name: 'SegmentedSwitch.bookmarks',
      cell: cell,
      build: (selected, onChanged) => SegmentedSwitch.bookmarks(
        labels: _labels,
        selected: selected,
        onChanged: onChanged,
      ),
    );
  }

  for (final cell in [dsCells[0], dsCells[3]]) {
    _keyboardScript(
      name: 'SegmentedSwitch with Pro marks',
      cell: cell,
      build: (selected, onChanged) => SegmentedSwitch(
        labels: _labels,
        selected: selected,
        onChanged: onChanged,
        proMarks: const [1, 2],
      ),
    );
  }

  testWidgets('a disabled bookmarks switch takes no keys', (tester) async {
    final log = <int>[];
    await pumpDs(
      tester,
      dsCells.first,
      SegmentedSwitch.bookmarks(
        labels: _labels,
        selected: 0,
        onChanged: log.add,
        enabled: false,
      ),
    );
    await _press(tester, LogicalKeyboardKey.tab);
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(log, isEmpty);
  });
}
