import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_popover.dart';

import '../golden_harness.dart';

const _window = Size(320, 230);

Widget _open(List<Widget> items) => _Opened(items);

/// Opens the popover after the first frame: it cannot open while building.
class _Opened extends StatefulWidget {
  const _Opened(this.items);

  final List<Widget> items;

  @override
  State<_Opened> createState() => _OpenedState();
}

class _OpenedState extends State<_Opened> {
  final _controller = PantasPopoverController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.open());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PantasPopover(
            controller: _controller,
            trigger: const SizedBox(width: 200, height: 40),
            label: 'Exam',
            role: PantasPopoverRole.picker,
            children: widget.items,
          ),
        ),
      );
}

void main() {
  goldenSheet(
    'popover',
    [
      GoldenState(
        'Items',
        (_) => _open([
          PantasPopoverItem(label: 'UPCAT', onPressed: () {}),
          PantasPopoverItem(
            label: 'ACET',
            selected: true,
            check: true,
            onPressed: () {},
          ),
          const PantasPopoverItem(label: 'DCAT'),
          const PantasPopoverSeparator(),
          PantasPopoverItem(label: 'Other exam', onPressed: () {}),
        ]),
        window: _window,
      ),
      GoldenState(
        'Item hover',
        (_) => _open([
          PantasPopoverItem(label: 'UPCAT', onPressed: () {}),
          PantasPopoverItem(label: 'ACET', onPressed: () {}),
          PantasPopoverItem(label: 'DCAT', onPressed: () {}),
        ]),
        action: GoldenAction.hover,
        at: const Alignment(-0.4, -0.25),
        window: _window,
      ),
      GoldenState(
        'Empty',
        (_) => _open(const [PantasPopoverEmpty('No results')]),
        window: _window,
      ),
    ],
    columns: 2,
    web: true,
  );
}
