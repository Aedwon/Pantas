part of 'content_renderer.dart';

/// What an example card needs to hand its figures to the figure column.
class _HeldExampleHook {
  _HeldExampleHook(this.moved, this.open);

  /// The figure blocks that now sit in the figure column. Identity, not
  /// equality: two figures can have the same words.
  final Set<Map<String, Object?>> moved;
  final ValueNotifier<bool> open;
}

/// The lesson as the held layout wants it: text blocks and figure plates.
class HeldFlow {
  const HeldFlow({required this.entries, required this.figures});
  final List<HeldEntry> entries;
  final List<HeldFigure> figures;
}

/// Whether [block] is a figure the held layout may put in the margin.
bool _marginFigure(Map<String, Object?> block) =>
    block['_type'] == 'figureSpec' &&
    block['spec'] is Map<String, Object?> &&
    !_wideArt(block['spec']! as Map<String, Object?>) &&
    FigureRegistry.build(block['spec']! as Map<String, Object?>) != null;

/// Rule 6: art much wider than it is tall (the angle gallery, the Earth's
/// motions triptych, the orbital shapes) goes inline at the text width. The
/// painters draw to whatever width they get, so the kinds that are built as
/// a row of panels are the ones that read as wide.
bool _wideArt(Map<String, Object?> spec) {
  final type = spec['type'];
  return type is String &&
      (type.endsWith('gallery') ||
          type.endsWith('triptych') ||
          type == 'orbital-shapes' ||
          type == 'atomic-models');
}

bool _isFigureBlock(Map<String, Object?> block) =>
    block['_type'] == 'figureSpec' || block['_type'] == 'image';

extension HeldFlowBuilder on ContentRenderer {
  /// Builds the held layout's blocks. Figures that can sit in the margin
  /// become plates; every other figure stays in the text, as on the phone.
  ///
  /// [inline] names figures (by position in the lesson) that the stack cap
  /// sent back into the text. [open] holds one signal per example, kept by
  /// the page, so a card and its plate agree across rebuilds.
  HeldFlow heldFlow(
    BuildContext context, {
    Set<int> inline = const {},
    required Map<int, ValueNotifier<bool>> open,
  }) {
    final visible = blocks!.where((block) {
      if (block['_type'] != 'image') return true;
      final asset = block['asset'];
      return (asset is Map<String, Object?>
              ? string(asset['url'])
              : string(block['url']))
          .isNotEmpty;
    }).toList();
    final items = planReaderBlocks(visible);
    final entries = <HeldEntry>[];
    final texts = <String>[];
    final figures = <HeldFigure>[];
    final counters = <int, int>{};
    var run = <ReaderItem>[];
    var nextId = 0;

    void add(_Slot slot) {
      entries.add(
        HeldEntry(
          child: RepaintBoundary(child: slot.child),
          kind: slot.kind,
          above: slot.above,
          below: slot.below,
          list: slot.list,
          major: slot.major,
        ),
      );
      texts.add(slot.text);
    }

    void flush() {
      if (run.isEmpty) return;
      _readerSlots(context, run, sharedCounters: counters).forEach(add);
      run = [];
    }

    int headingBefore(int index) {
      for (var i = index; i >= 0; i--) {
        if (entries[i].kind == FlowKind.heading) return i;
      }
      return 0;
    }

    for (final item in items) {
      if (item is ReaderExample) {
        flush();
        counters.clear();
        final moved = HashSet<Map<String, Object?>>.identity();
        Map<String, Object?>? problem;
        Map<String, Object?>? solution;
        for (final block in item.stem) {
          if (_isFigureBlock(block) && _marginFigure(block)) {
            final id = nextId++;
            if (!inline.contains(id) && problem == null) {
              moved.add(block);
              problem = block;
            }
          }
        }
        for (final block in item.solution) {
          if (_isFigureBlock(block) && _marginFigure(block)) {
            final id = nextId++;
            if (!inline.contains(id) && solution == null) {
              moved.add(block);
              solution = block;
            }
          }
        }
        final signal =
            open.putIfAbsent(item.number, () => ValueNotifier(false));
        add(
          _Slot(
            _exampleCard(
              context,
              item,
              held: _HeldExampleHook(moved, signal),
            ),
            kind: FlowKind.example,
            below: 18,
          ),
        );
        if (problem != null || solution != null) {
          final at = entries.length - 1;
          figures.add(
            HeldFigure(
              id: nextId - 1,
              anchorStart: at,
              anchorEnd: at,
              blockStart: headingBefore(at),
              example: true,
              plate: _ExamplePlate(
                problem: problem == null ? null : _plateFor(context, problem),
                solution:
                    solution == null ? null : _plateFor(context, solution),
                open: signal,
              ),
            ),
          );
        }
        continue;
      }
      final plain = item as ReaderPlain;
      final block = plain.block;
      if (!_isFigureBlock(block)) {
        run.add(item);
        continue;
      }
      flush();
      final id = nextId++;
      if (!_marginFigure(block) || inline.contains(id)) {
        add(_Slot(dispatch(context, block), below: 16));
        continue;
      }
      var end = entries.isEmpty ? 0 : entries.length - 1;
      var start = end;
      if (entries.isNotEmpty && entries[end].list) {
        while (start > 0 && entries[start - 1].list) {
          start--;
        }
        if (start > 0 && texts[start - 1].trimRight().endsWith(':')) start--;
      }
      figures.add(
        HeldFigure(
          id: id,
          anchorStart: start,
          anchorEnd: end,
          blockStart: entries.isEmpty ? 0 : headingBefore(start),
          plate: RepaintBoundary(child: _plateFor(context, block)),
        ),
      );
    }
    flush();
    return HeldFlow(entries: entries, figures: figures);
  }

  Widget _plateFor(BuildContext context, Map<String, Object?> block) {
    final spec = block['spec']! as Map<String, Object?>;
    return _FigureFrame(
      reader: true,
      plate: true,
      figure: figureBuilder?.call(context, spec) ?? FigureRegistry.build(spec)!,
      label: string(block['semanticsLabel']),
      credit: '',
    );
  }
}

/// The plate of an example: the problem's figure, which gives way to the
/// solution's figure in the same place when the solution opens. Problem out
/// over 180 ms, solution in over 240 ms, on the shared ease; reduced motion
/// is a 150 ms fade.
class _ExamplePlate extends StatelessWidget {
  const _ExamplePlate({
    required this.problem,
    required this.solution,
    required this.open,
  });

  final Widget? problem;
  final Widget? solution;
  final ValueListenable<bool> open;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    Widget layer(Widget child, {required bool shownWhenOpen}) =>
        ValueListenableBuilder<bool>(
          valueListenable: open,
          child: child,
          builder: (context, isOpen, child) {
            final visible = isOpen == shownWhenOpen;
            return IgnorePointer(
              ignoring: !visible,
              child: ExcludeSemantics(
                excluding: !visible,
                child: AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  curve: PantasCurves.move,
                  duration: still
                      ? const Duration(milliseconds: 150)
                      : Duration(milliseconds: visible ? 240 : 180),
                  child: child,
                ),
              ),
            );
          },
        );
    final first = problem;
    final second = solution;
    return RepaintBoundary(
      child: Stack(
        children: [
          if (first != null)
            second == null ? first : layer(first, shownWhenOpen: false),
          if (second != null) layer(second, shownWhenOpen: true),
        ],
      ),
    );
  }
}

/// Whether any figure of [blocks] can go in the figure column. A lesson with
/// none keeps the single centered column.
bool lessonHasMarginFigures(List<Map<String, Object?>> blocks) =>
    blocks.any(_marginFigure);
