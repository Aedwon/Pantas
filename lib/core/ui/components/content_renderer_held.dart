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

/// Whether [block] is a figure the held layout may put in the margin: its
/// type is on the registry's margin list (rule 6: wide art stays inline).
bool _marginFigure(Map<String, Object?> block) =>
    block['_type'] == 'figureSpec' &&
    block['spec'] is Map<String, Object?> &&
    FigureRegistry.isMargin(block['spec']! as Map<String, Object?>) &&
    FigureRegistry.build(block['spec']! as Map<String, Object?>) != null;

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
    required Map<int, ValueNotifier<bool>> open,
    Set<int> inline = const {},
  }) {
    final visible = blocks!.where((block) {
      if (block['_type'] != 'image') return true;
      final asset = block['asset'];
      return (asset is Map<String, Object?>
              ? string(asset['url'])
              : string(block['url']))
          .isNotEmpty;
    }).toList();
    final prepared = _prepare(planReaderBlocks(visible));
    final items = prepared.items;
    final ids = prepared.ids;
    final entries = <HeldEntry>[];
    final texts = <String>[];
    final figures = <HeldFigure>[];
    final counters = <int, int>{};
    var run = <ReaderItem>[];

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
        var plateId = -1;
        for (final block in item.stem) {
          if (_isFigureBlock(block) && _marginFigure(block)) {
            final id = ids[block]!;
            if (!inline.contains(id) && problem == null) {
              moved.add(block);
              problem = block;
              plateId = id;
            }
          }
        }
        for (final block in item.solution) {
          if (_isFigureBlock(block) && _marginFigure(block)) {
            final id = ids[block]!;
            if (!inline.contains(id) && solution == null) {
              moved.add(block);
              solution = block;
              plateId = id;
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
          ),
        );
        if (problem != null || solution != null) {
          final at = entries.length - 1;
          figures.add(
            HeldFigure(
              id: plateId,
              anchorStart: at,
              anchorEnd: at,
              blockStart: headingBefore(at),
              example: true,
              plate: _ExamplePlate(
                problem: problem == null
                    ? null
                    : _plateFor(context, problem, plateId),
                solution: solution == null
                    ? null
                    : _plateFor(context, solution, plateId),
                open: signal,
                newLabels: problem == null || solution == null
                    ? const {}
                    : {
                        for (final l in _linkLabels(solution))
                          if (!_linkLabels(problem).contains(l)) l,
                      },
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
      final id = ids[block]!;
      if (!_marginFigure(block) || inline.contains(id)) {
        add(_Slot(dispatch(context, block), below: 16));
        continue;
      }
      final end = entries.isEmpty ? 0 : entries.length - 1;
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
          plate: RepaintBoundary(child: _plateFor(context, block, id)),
        ),
      );
    }
    flush();
    return HeldFlow(entries: entries, figures: figures);
  }

  Widget _plateFor(BuildContext context, Map<String, Object?> block, int id) {
    final spec = block['spec']! as Map<String, Object?>;
    return _FigureFrame(
      reader: true,
      plate: true,
      figure: FigureHighlightFor(
        figure: id,
        child:
            figureBuilder?.call(context, spec) ?? FigureRegistry.build(spec)!,
      ),
      label: string(block['semanticsLabel']),
      credit: '',
    );
  }
}

/// The plate of an example: the problem's figure, which gives way to the
/// solution's figure in the same place when the solution opens. Problem out
/// over 180 ms, solution in over 240 ms, on the shared ease; then the marks
/// the solution adds draw in over 240 ms. Reduced motion is a 150 ms fade.
class _ExamplePlate extends StatefulWidget {
  const _ExamplePlate({
    required this.problem,
    required this.solution,
    required this.open,
    this.newLabels = const {},
  });

  final Widget? problem;
  final Widget? solution;
  final ValueListenable<bool> open;

  /// Labels of the solution figure that the problem figure did not have.
  final Set<String> newLabels;

  @override
  State<_ExamplePlate> createState() => _ExamplePlateState();
}

class _ExamplePlateState extends State<_ExamplePlate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: markDrawDelay + markDrawDuration,
      value: widget.open.value ? 1 : 0,
    );
    widget.open.addListener(_opened);
  }

  void _opened() {
    if (widget.open.value) unawaited(_clock.forward(from: 0));
  }

  @override
  void dispose() {
    widget.open.removeListener(_opened);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    Widget layer(Widget child, {required bool shownWhenOpen}) =>
        ValueListenableBuilder<bool>(
          valueListenable: widget.open,
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
    final first = widget.problem;
    var second = widget.solution;
    if (second != null && first != null && widget.newLabels.isNotEmpty) {
      final shown = second;
      second = AnimatedBuilder(
        animation: _clock,
        child: shown,
        builder: (context, child) => NewMarks(
          labels: widget.newLabels,
          amount: markDrawProgress(
            _clock.duration! * _clock.value,
            reduced: still,
          ),
          child: child!,
        ),
      );
    }
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

/// The labels of a figure that a text can name. Only the geometry painter
/// draws each label as its own part, so only its figures carry links.
List<String> _linkLabels(Map<String, Object?> block) {
  final spec = block['spec'];
  if (spec is! Map<String, Object?> || spec['kind'] != 'geometry-diagram') {
    return const [];
  }
  final labels = spec['labels'];
  return labels is List<Object?> ? labels.whereType<String>().toList() : [];
}

/// Gives every figure of the lesson its number, and marks the paragraphs of
/// each figure's passage with the labels the text can name.
({List<ReaderItem> items, Map<Map<String, Object?>, int> ids}) _prepare(
  List<ReaderItem> source,
) {
  final ids = HashMap<Map<String, Object?>, int>.identity();
  var next = 0;
  final figures = <int>[];
  for (var k = 0; k < source.length; k++) {
    final item = source[k];
    if (item is ReaderExample) {
      for (final b in [...item.stem, ...item.solution]) {
        if (_isFigureBlock(b)) ids[b] = next++;
      }
    } else if (item is ReaderPlain && _isFigureBlock(item.block)) {
      ids[item.block] = next++;
      if (_marginFigure(item.block)) figures.add(k);
    }
  }

  bool isFigure(int k) =>
      source[k] is ReaderPlain &&
      _isFigureBlock((source[k] as ReaderPlain).block);
  bool listItem(int k) {
    final item = source[k];
    return item is ReaderPlain &&
        item.block['_type'] == 'block' &&
        item.block['listItem'] is String &&
        (item.block['listItem']! as String).isNotEmpty;
  }

  // Where each figure's anchor starts and ends.
  final anchors = <int, ({int start, int end})>{};
  for (final k in figures) {
    var end = k - 1;
    while (end >= 0 && isFigure(end)) {
      end--;
    }
    if (end < 0) continue;
    var start = end;
    if (listItem(end)) {
      while (start > 0 && listItem(start - 1)) {
        start--;
      }
      final before = start > 0 ? source[start - 1] : null;
      if (before is ReaderPlain &&
          readerBlockText(before.block).trimRight().endsWith(':')) {
        start--;
      }
    }
    anchors[k] = (start: start, end: end);
  }
  final starts = {for (final a in anchors.values) a.start};

  final marked = List<ReaderItem>.of(source);
  Map<String, Object?> mark(
    Map<String, Object?> block,
    int id,
    List<String> l,
  ) =>
      block['_links'] != null || block['_type'] != 'block' || l.isEmpty
          ? block
          : {
              ...block,
              '_links': <String, Object?>{'figure': id, 'labels': l},
            };

  for (final k in figures) {
    final anchor = anchors[k];
    final plain = source[k] as ReaderPlain;
    final labels = _linkLabels(plain.block);
    if (anchor == null || labels.isEmpty) continue;
    var stop = source.length;
    for (var t = anchor.end + 1; t < source.length; t++) {
      final item = source[t];
      final style = item is ReaderPlain && item.block['_type'] == 'block'
          ? item.block['style']
          : null;
      if (item is ReaderExample ||
          style == 'h2' ||
          style == 'h3' ||
          style == 'blockquote' ||
          (starts.contains(t) && t > anchor.end)) {
        stop = t;
        break;
      }
    }
    for (var t = anchor.start; t < stop; t++) {
      final item = marked[t];
      if (item is! ReaderPlain) continue;
      final style = item.block['style'];
      if (style == 'h2' || style == 'h3' || style == 'blockquote') continue;
      marked[t] = ReaderPlain(
        mark(item.block, ids[plain.block]!, labels),
        item.section,
      );
    }
  }
  // An example's own figures name parts of the text of its card.
  for (var k = 0; k < marked.length; k++) {
    final item = marked[k];
    if (item is! ReaderExample) continue;
    Map<String, Object?>? problem;
    Map<String, Object?>? solution;
    for (final b in item.stem) {
      if (_isFigureBlock(b) && _marginFigure(b)) problem ??= b;
    }
    for (final b in item.solution) {
      if (_isFigureBlock(b) && _marginFigure(b)) solution ??= b;
    }
    final shown = solution ?? problem;
    if (shown == null) continue;
    // The problem names parts of the problem's figure. Once the solution is
    // open it names parts of the solution's figure, which is the one in view.
    final id = ids[shown]!;
    final problemLabels = problem == null ? <String>[] : _linkLabels(problem);
    marked[k] = ReaderExample(
      number: item.number,
      title: item.title,
      stem: [for (final b in item.stem) mark(b, id, problemLabels)],
      solution: [
        for (final b in item.solution) mark(b, id, _linkLabels(shown)),
      ],
    );
  }
  return (items: marked, ids: ids);
}
