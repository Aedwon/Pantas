import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/components/lesson_svg.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

// Credits use secondaryLabel under the Task8b contrast ruling.

class ContentRenderer extends StatelessWidget {
  const ContentRenderer({
    this.blocks,
    this.text,
    this.style,
    this.maxLines,
    this.figureBuilder,
    this.readerFigures = false,
    super.key,
  }) : assert(blocks != null || text != null, 'Provide blocks or text.');
  final List<Map<String, Object?>>? blocks;
  final String? text;
  final TextStyle? style;
  final int? maxLines;
  final Widget Function(BuildContext, Map<String, Object?>)? figureBuilder;
  final bool readerFigures;
  static List<Map<String, Object?>> _parseTextToBlocks(String text) {
    final children = <Map<String, Object?>>[];
    final markerBuffer = StringBuffer('\uE000');
    while (text.contains(markerBuffer.toString())) {
      markerBuffer.write('\uE000');
    }
    final marker = markerBuffer.toString();
    final math = <String, String>{};
    final protected = text.replaceAllMapped(RegExp(r'\$([^$]+)\$'), (match) {
      final token = '$marker${math.length}$marker';
      math[token] = match.group(0)!;
      return token;
    });
    String restore(String run) {
      var restored = run;
      for (final entry in math.entries) {
        restored = restored.replaceAll(entry.key, entry.value);
      }
      return restored;
    }

    final markdown = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*|(?<!_)_([^_]+?)_(?!_)');
    var end = 0;
    for (final match in markdown.allMatches(protected)) {
      if (match.start > end) {
        children.add({
          'text': restore(protected.substring(end, match.start)),
          'marks': <String>[],
        });
      }
      final strong = match.group(1);
      children.add({
        'text': restore(strong ?? match.group(2) ?? match.group(3) ?? ''),
        'marks': <String>[if (strong == null) 'em' else 'strong'],
      });
      end = match.end;
    }
    if (end < protected.length) {
      children.add(
        {'text': restore(protected.substring(end)), 'marks': <String>[]},
      );
    }
    return [
      {'_type': 'block', 'style': 'normal', 'children': children},
    ];
  }

  /// Splits question text into plain runs and Markdown pipe tables.
  ///
  /// Lessons arrive with tables already parsed into blocks. Question stems are
  /// plain strings, so a table written in a stem would otherwise show its
  /// pipes as text. A table needs a header line and a delimiter line of
  /// dashes, as in the lesson parser; anything else stays plain text.
  static List<({String text, List<List<String>>? rows})> splitTables(
    String text,
  ) {
    if (!text.contains('|')) return [(text: text, rows: null)];
    final delimiter = RegExp(r'^:?-+:?$');
    final lines = text.split('\n');
    final out = <({String text, List<List<String>>? rows})>[];
    final plain = <String>[];
    void flushPlain() {
      final joined = plain.join('\n').trim();
      if (joined.isNotEmpty) out.add((text: joined, rows: null));
      plain.clear();
    }

    var i = 0;
    while (i < lines.length) {
      final line = lines[i].trim();
      if (line.startsWith('|') &&
          i + 1 < lines.length &&
          lines[i + 1].trim().startsWith('|')) {
        final header = splitTableRow(line);
        final rule = splitTableRow(lines[i + 1].trim());
        if (rule.length == header.length && rule.every(delimiter.hasMatch)) {
          flushPlain();
          final rows = <List<String>>[header];
          var next = i + 2;
          while (next < lines.length && lines[next].trim().startsWith('|')) {
            rows.add(splitTableRow(lines[next].trim()));
            next++;
          }
          // A ragged row is padded so the table still draws.
          final width =
              rows.fold<int>(0, (m, r) => r.length > m ? r.length : m);
          final padded = [
            for (final r in rows)
              [
                ...r,
                for (var k = r.length; k < width; k++) '',
              ],
          ];
          out.add((text: '', rows: padded));
          i = next;
          continue;
        }
      }
      plain.add(lines[i]);
      i++;
    }
    flushPlain();
    return out.isEmpty ? [(text: text, rows: null)] : out;
  }

  /// Cells of one table row. A pipe inside `$...$` belongs to the maths, as in
  /// an absolute value, so it does not end the cell.
  static List<String> splitTableRow(String line) {
    var content = line.trim();
    if (content.startsWith('|')) content = content.substring(1);
    if (content.endsWith('|')) {
      content = content.substring(0, content.length - 1);
    }
    final cells = <String>[];
    final cell = StringBuffer();
    var inMath = false;
    for (var i = 0; i < content.length; i++) {
      final char = content[i];
      if (char == r'$') inMath = !inMath;
      if (char == '|' && !inMath) {
        cells.add(cell.toString().trim());
        cell.clear();
      } else {
        cell.write(char);
      }
    }
    cells.add(cell.toString().trim());
    return cells;
  }

  String string(Object? value) => value is String ? value : '';
  List<Map<String, Object?>> maps(Object? value) => value is List<Object?>
      ? value.whereType<Map<String, Object?>>().toList()
      : const [];
  Widget fallback(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.fill,
          border: Border.all(color: context.colors.separator),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          readerFigures
              ? 'Content unavailable. Update the app.'
              : 'This part cannot be shown yet.',
          style: context.type.footnote.copyWith(color: context.colors.label),
        ),
      );
  Widget paragraph(
    BuildContext context,
    Map<String, Object?> block, {
    String? marker,
  }) {
    final name = string(block['style']);
    final base = style ?? context.type.body.copyWith(height: 1.55);
    final phoneType = switch (name) {
      'h1' => context.type.pageTitle.copyWith(height: 1.15),
      'h2' => context.type.sectionHero
          .copyWith(fontSize: 22, height: 1.25, letterSpacing: -.264),
      'h3' || 'h4' || 'h5' || 'h6' => context.type.emphasized
          .copyWith(fontSize: 18, height: 1.3, letterSpacing: -.216),
      'blockquote' => base.copyWith(fontWeight: FontWeight.w500),
      _ => base,
    };
    final wide = readerFigures && context.wideWeb;
    // Every section label is the same 24 px heading on wide web, Core
    // Concept included. It was a small gray label that read as less than the
    // sections after it (Aedwon, Nov 3).
    final type = wide && name == 'h2'
        ? context.webTokens.style(
            24,
            weight: FontWeight.w700,
            spacing: -.384,
            height: 1.3,
          )
        : phoneType;
    final spans = <InlineSpan>[];
    final spoken = StringBuffer();
    var hasMath = false;
    var validSpeech = true;
    for (final run in maps(block['children'])) {
      final source = string(run['text']);
      final marks = run['marks'] is List<Object?>
          ? (run['marks']! as List<Object?>).whereType<String>().toSet()
          : <String>{};
      final runStyle = type.copyWith(
        fontWeight: marks.contains('strong') ? FontWeight.w600 : null,
        fontStyle: marks.contains('em') ? FontStyle.italic : null,
        decoration:
            marks.contains('underline') ? TextDecoration.underline : null,
      );
      if (marks.contains('latex')) {
        spans.add(
          inlineMathSpan(
            source,
            style: runStyle,
            onErrorFallback: readerFigures ? fallback : null,
          ),
        );
        final label = inlineMathExpressionSemanticsLabel(source);
        if (label == null) {
          validSpeech = false;
        } else {
          spoken.write(label);
        }
        hasMath = true;
      } else {
        spans.addAll(
          inlineMathSpans(
            source,
            style: runStyle,
            onErrorFallback: readerFigures ? fallback : null,
          ),
        );
        final label = inlineMathSemantics(source);
        if (label == null) {
          validSpeech = false;
        } else {
          spoken.write(label.label);
          hasMath = hasMath || label.hasMath;
        }
      }
    }
    final numbered = readerFigures && name.startsWith('h')
        ? RegExp(r'^#(\d+):\s*(.*)$').firstMatch(
            maps(block['children']).map((r) => string(r['text'])).join(),
          )
        : null;
    if (numbered != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            numbered.group(1)!,
            style: type.copyWith(
              color: context.colors.secondaryLabel,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: MathText(numbered.group(2)!, style: type)),
        ],
      );
    }
    Widget body = Text.rich(
      TextSpan(children: spans),
      style: type,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
    );
    if (hasMath && validSpeech) {
      body = Semantics(
        label: '${marker == null ? '' : '$marker '}$spoken',
        excludeSemantics: true,
        child: body,
      );
    }
    if (marker != null) {
      final level =
          block['level'] is num ? (block['level']! as num).toInt() : 1;
      body = Padding(
        padding: EdgeInsets.only(left: ((level - 1).clamp(0, 4)) * 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              marker,
              style: base.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.secondaryLabel,
              ),
            ),
            SizedBox(width: readerFigures ? 10 : 12),
            Expanded(child: body),
          ],
        ),
      );
    }
    if (name == 'blockquote') {
      body = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: context.colors.chevron, width: 3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 0, 2),
          child: body,
        ),
      );
    }
    return body;
  }

  Widget table(BuildContext context, Map<String, Object?> block) {
    final raw = block['rows'];
    if (raw is! List<Object?> || raw.isEmpty) return fallback(context);
    final rows = <List<String>>[];
    for (final row in raw) {
      final cells = row is Map<String, Object?> ? row['cells'] : row;
      if (cells is! List<Object?> ||
          cells.isEmpty ||
          cells.any((c) => c is! String)) {
        return fallback(context);
      }
      rows.add(cells.cast<String>());
    }
    if (rows.any((r) => r.length != rows.first.length)) {
      return fallback(context);
    }
    // The first column labels each row, so it stays left-aligned even when
    // its values are numbers such as years. Another column is right-aligned
    // only when every body cell in it is a number.
    final numeric = [
      for (var c = 0; c < rows.first.length; c++)
        c > 0 &&
            rows.length > 1 &&
            rows.skip(1).every((r) => _isNumberCell(r[c])),
    ];
    final line = BorderSide(color: context.colors.separator, width: .5);
    return LayoutBuilder(
      builder: (context, box) {
        final available = box.maxWidth.isFinite ? box.maxWidth : 0.0;
        // A column stops growing at three quarters of the page width, so a
        // long cell wraps instead of pushing the table far off screen.
        final cap = (available * .75).clamp(160.0, 320.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _FitWidth(
            available: available,
            child: Table(
              defaultColumnWidth: MinColumnWidth(
                const IntrinsicColumnWidth(flex: 1),
                FixedColumnWidth(cap),
              ),
              border: TableBorder(horizontalInside: line, bottom: line),
              children: [
                for (var i = 0; i < rows.length; i++)
                  TableRow(
                    decoration: i == 0
                        ? BoxDecoration(color: context.colors.fill)
                        : null,
                    children: [
                      for (var c = 0; c < rows[i].length; c++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: _cell(
                            context,
                            rows[i][c],
                            header: i == 0,
                            numeric: numeric[c],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cell(
    BuildContext context,
    String text, {
    required bool header,
    required bool numeric,
  }) {
    final cellStyle = context.type.subhead.copyWith(
      fontWeight: header ? FontWeight.w600 : FontWeight.w400,
      fontFeatures: numeric ? const [FontFeature.tabularFigures()] : null,
    );
    // Bold and italic marks in a cell, as in `**$T$**`, need the same parsing
    // as a paragraph. Plain cells keep the lighter path.
    if (text.contains('*')) {
      return ContentRenderer(text: text, style: cellStyle);
    }
    return MathText(
      text,
      textAlign: numeric ? TextAlign.right : TextAlign.left,
      style: cellStyle,
    );
  }

  static final _numberCell = RegExp(r'^[+\-\u2212]?[₱$]?[\d,]+(\.\d+)?%?$');

  /// A plain or currency number, with or without `$...$` around it, as in
  /// `\text{₱}12,500`.
  static bool _isNumberCell(String cell) {
    var text = cell.trim();
    if (text.length > 1 && text.startsWith(r'$') && text.endsWith(r'$')) {
      text = text.substring(1, text.length - 1).trim();
    }
    text = text.replaceAll(r'\text{₱}', '₱').replaceAll(r'\$', r'$');
    return _numberCell.hasMatch(text);
  }

  Widget example(BuildContext context, Map<String, Object?> block) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            string(block['title']),
            style: context.type.emphasized
                .copyWith(fontSize: 18, height: 1.3, letterSpacing: -.216),
          ),
          const SizedBox(height: 10),
          MathText(
            string(block['body']),
            style: context.type.body.copyWith(height: 1.55),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SOLUTION',
                  style: context.type.sectionHeader
                      .copyWith(fontSize: 12, letterSpacing: .48),
                ),
                const SizedBox(height: 10),
                MathText(
                  string(block['solution']),
                  style: context.type.body.copyWith(height: 1.55),
                ),
              ],
            ),
          ),
        ],
      );
  Widget dispatch(
    BuildContext context,
    Map<String, Object?> block, {
    String? marker,
  }) {
    final type = string(block['_type']);
    switch (type) {
      case 'block':
        return paragraph(context, block, marker: marker);
      case 'latex':
        return MathText(
          string(block['body']),
          display: true,
          semanticsLabel: block['semanticsLabel'] is String
              ? block['semanticsLabel']! as String
              : null,
          style: style,
          onErrorFallback: readerFigures ? fallback : null,
        );
      case 'table':
        return readerFigures
            ? _FigureFrame(
                reader: true,
                imageSemantics: false,
                figure: Builder(builder: (context) => table(context, block)),
                label: string(block['semanticsLabel']),
                credit: string(block['credit']),
              )
            : table(context, block);
      case 'example':
        return example(context, block);
      case 'figureSpec':
        final spec = block['spec'];
        if (spec is! Map<String, Object?>) return fallback(context);
        final figure =
            figureBuilder?.call(context, spec) ?? FigureRegistry.build(spec);
        if (figure == null) return fallback(context);
        return _FigureFrame(
          reader: readerFigures,
          figure: figure,
          label: string(block['semanticsLabel']),
          credit: string(block['credit']),
        );
      case 'image':
        final asset = block['asset'];
        final url = asset is Map<String, Object?>
            ? string(asset['url'])
            : string(block['url']);
        if (url.isEmpty) {
          return readerFigures
              ? const SizedBox.shrink()
              : const _ImageFailure(onRetry: null);
        }
        return _ContentImage(
          reader: readerFigures,
          url: url,
          label: string(block['alt']),
          credit: asset is Map<String, Object?> &&
                  string(asset['credit']).isNotEmpty
              ? string(asset['credit'])
              : string(block['credit']),
        );
      default:
        return fallback(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (blocks == null) {
      // A line limit means a list row showing a preview, which never carries
      // a whole table.
      final segments = maxLines == null
          ? splitTables(text!)
          : [(text: text!, rows: null as List<List<String>>?)];
      if (segments.length == 1 && segments.first.rows == null) {
        return paragraph(context, _parseTextToBlocks(text!).first);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            if (segments[i].rows case final rows?)
              table(context, {'rows': rows})
            else
              paragraph(
                context,
                _parseTextToBlocks(segments[i].text).first,
              ),
          ],
        ],
      );
    }
    final children = <Widget>[];
    final counters = <int, int>{};
    final visible = blocks!.where((block) {
      if (!readerFigures || block['_type'] != 'image') return true;
      final asset = block['asset'];
      return (asset is Map<String, Object?>
              ? string(asset['url'])
              : string(block['url']))
          .isNotEmpty;
    }).toList();
    for (var index = 0; index < visible.length; index++) {
      final block = visible[index];
      final plain =
          maps(block['children']).map((r) => string(r['text'])).join().trim();
      if (readerFigures &&
          block['_type'] == 'block' &&
          RegExp(r'^Solution\s*:?$', caseSensitive: false).hasMatch(plain)) {
        var end = index + 1;
        while (end < visible.length &&
            !(visible[end]['_type'] == 'block' &&
                string(visible[end]['style']).startsWith('h')) &&
            visible[end]['_type'] != 'image' &&
            visible[end]['_type'] != 'figureSpec') {
          end++;
        }
        if (children.isNotEmpty) children.add(const SizedBox(height: 18));
        children.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SOLUTION',
                  style: context.type.sectionHeader
                      .copyWith(fontSize: 12, letterSpacing: .48),
                ),
                const SizedBox(height: 10),
                ContentRenderer(
                  blocks: visible.sublist(index + 1, end),
                  readerFigures: true,
                  style: style,
                ),
              ],
            ),
          ),
        );
        index = end - 1;
        counters.clear();
        continue;
      }
      final list = block['_type'] == 'block' ? string(block['listItem']) : '';
      String? marker;
      if (list.isNotEmpty) {
        final level =
            block['level'] is num ? (block['level']! as num).toInt() : 1;
        counters.removeWhere((key, value) => key > level);
        if (list == 'number') {
          counters[level] = (counters[level] ?? 0) + 1;
          marker = '${counters[level]}.';
        } else {
          marker = '•';
        }
      } else if (block['_type'] == 'block') {
        counters.clear();
      }
      if (children.isNotEmpty) {
        children.add(
          SizedBox(
            height: string(block['style']) == 'h2'
                ? 32
                : readerFigures &&
                        list.isNotEmpty &&
                        index > 0 &&
                        string(visible[index - 1]['listItem']).isNotEmpty
                    ? 8
                    : 18,
          ),
        );
      }
      children.add(dispatch(context, block, marker: marker));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// Sizes a table to its content: as wide as its cells need when that fits the
/// page, so a short table stays compact. A wider table fills the page and its
/// cells wrap, and one that cannot wrap enough is as wide as its narrowest
/// layout and scrolls sideways.
class _FitWidth extends SingleChildRenderObjectWidget {
  const _FitWidth({required this.available, required super.child});
  final double available;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFitWidth(available);

  @override
  void updateRenderObject(BuildContext context, _RenderFitWidth renderObject) =>
      renderObject.available = available;
}

class _RenderFitWidth extends RenderProxyBox {
  _RenderFitWidth(this._available);
  double _available;
  double get available => _available;
  set available(double value) {
    if (value == _available) return;
    _available = value;
    markNeedsLayout();
  }

  double _width(RenderBox child) {
    final min = child.getMinIntrinsicWidth(double.infinity);
    final max = child.getMaxIntrinsicWidth(double.infinity);
    if (min >= _available) return min;
    return max < _available ? max : _available;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child!;
    return child.getDryLayout(BoxConstraints.tightFor(width: _width(child)));
  }

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(
      BoxConstraints.tightFor(width: _width(child)),
      parentUsesSize: true,
    );
    size = child.size;
  }
}

class _FigureFrame extends StatelessWidget {
  const _FigureFrame({
    required this.figure,
    required this.label,
    required this.credit,
    this.reader = false,
    this.imageSemantics = true,
    this.expandable = true,
    this.followTheme = false,
  });
  final bool reader;
  final bool imageSemantics;
  final bool expandable;
  final bool followTheme;
  final Widget figure;
  final String label;
  final String credit;
  Future<void> expand(BuildContext context) {
    if (!reader) return _legacyExpand(context);
    return _openViewer(context);
  }

  Future<void> _legacyExpand(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.of(context).pop(),
          },
          child: Dialog.fullscreen(
            backgroundColor: context.colors.figureViewerBackground,
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Close figure',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        PantasIcons.close,
                        color: context.colors.onFigureViewer,
                        size: 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 5,
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: ColoredBox(
                            color: followTheme
                                ? context.colors.surface
                                : context.colors.figureBackground,
                            child: followTheme
                                ? Semantics(
                                    container: true,
                                    label: label,
                                    image: true,
                                    excludeSemantics: true,
                                    child: figure,
                                  )
                                : Theme(
                                    data: buildLightTheme(),
                                    child: figure,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (credit.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        credit,
                        style: context.type.caption.copyWith(
                          color: context.colors.onFigureViewer
                              .withValues(alpha: .6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
  Future<void> _openViewer(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierLabel: 'Close figure',
        barrierColor: context.colors.transparent,
        transitionDuration:
            still ? Duration.zero : const Duration(milliseconds: 380),
        reverseTransitionDuration:
            still ? Duration.zero : const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondary) => _FigureViewer(
          figure: followTheme
              ? Semantics(
                  container: true,
                  label: label,
                  image: true,
                  excludeSemantics: true,
                  child: figure,
                )
              : figure,
          credit: credit,
          arrival: animation,
          followTheme: followTheme,
        ),
        transitionsBuilder: (context, animation, secondary, child) =>
            AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final opening = animation.status != AnimationStatus.reverse;
            final value = opening
                ? (animation.value * 380 / 280).clamp(0.0, 1.0)
                : animation.value;
            final opacity = PantasCurves.ease.transform(value);
            return ExcludeFocus(
              excluding: opacity == 0,
              child: ExcludeSemantics(
                excluding: opacity == 0,
                child: Opacity(
                  key: const ValueKey('reader-viewer-fade'),
                  opacity: opacity,
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              key: reader ? const ValueKey('reader-figure-frame') : null,
              foregroundDecoration: reader
                  ? BoxDecoration(
                      border: Border.all(
                        color: context.colors.separator,
                        width: .5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    )
                  : null,
              child: Stack(
                children: [
                  Container(
                    width: reader && context.wideWeb ? double.infinity : null,
                    padding: reader && context.wideWeb
                        ? const EdgeInsets.all(22)
                        : null,
                    alignment:
                        reader && context.wideWeb ? Alignment.center : null,
                    color: followTheme
                        ? context.colors.surface
                        : reader
                            ? context.colors.readerFigureBackground
                            : context.colors.figureBackground,
                    child: imageSemantics
                        ? Semantics(
                            label: label,
                            image: true,
                            excludeSemantics: true,
                            child: (followTheme
                                ? figure
                                : Theme(
                                    data: buildLightTheme(),
                                    child: figure,
                                  )),
                          )
                        : (followTheme
                            ? figure
                            : Theme(data: buildLightTheme(), child: figure)),
                  ),
                  if (expandable)
                    Positioned(
                      right: 1,
                      top: 1,
                      child: SizedBox.square(
                        dimension: 44,
                        child: IconButton(
                          tooltip: 'Expand figure',
                          onPressed: () => expand(context),
                          padding: EdgeInsets.zero,
                          icon: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: context.wideWeb
                                  ? BoxShape.rectangle
                                  : BoxShape.circle,
                              borderRadius: context.wideWeb
                                  ? BorderRadius.circular(9)
                                  : null,
                              color: context.wideWeb
                                  ? context.colors.background
                                  : context.colors.shadow.withValues(alpha: .5),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              PantasIcons.expandFigure,
                              size: 16,
                              color: context.wideWeb
                                  ? context.colors.secondaryLabel
                                  : context.colors.onFigureViewer,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (credit.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              credit,
              style: context.type.caption.copyWith(
                fontSize: reader
                    ? context.wideWeb
                        ? 13
                        : 11
                    : null,
                fontWeight: FontWeight.w400,
                color: context.colors.secondaryLabel,
              ),
            ),
          ],
        ],
      );
}

class _FigureViewer extends StatefulWidget {
  const _FigureViewer({
    required this.figure,
    required this.credit,
    required this.arrival,
    this.followTheme = false,
  });
  final Widget figure;
  final String credit;
  final Animation<double> arrival;
  final bool followTheme;
  @override
  State<_FigureViewer> createState() => _FigureViewerState();
}

class _FigureViewerState extends State<_FigureViewer> {
  final _zoom = TransformationController();
  Widget get figure => widget.figure;
  String get credit => widget.credit;
  Animation<double> get arrival => widget.arrival;
  bool get followTheme => widget.followTheme;

  /// The window the figure is shown in. It is exactly as large as the figure,
  /// so a zoom of one shows the whole figure.
  final _window = GlobalKey();

  static const double _maxZoom = 5;

  /// Zooms by [factor] about [focal], a point in the window, between one and
  /// [_maxZoom] times. The figure never leaves the window: a zoom out that
  /// would show past an edge slides back until the edge meets the window.
  void _zoomAt(Offset focal, double factor) {
    final box = _window.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final size = box.size;
    final current = _zoom.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(1.0, _maxZoom);
    if (next == current) return;
    final scene = _zoom.toScene(focal);
    final x = (focal.dx - scene.dx * next).clamp(size.width * (1 - next), 0.0);
    final y = (focal.dy - scene.dy * next).clamp(size.height * (1 - next), 0.0);
    _zoom.value = Matrix4.identity()
      ..translateByDouble(x, y, 0, 1)
      ..scaleByDouble(next, next, 1, 1);
  }

  /// The keys zoom about the middle of the window.
  void _scale(double factor) {
    final box = _window.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _zoomAt(box.size.center(Offset.zero), factor);
  }

  /// The wheel and a trackpad pinch zoom wherever the pointer is on the
  /// screen, not only over the figure. Over the figure, the viewer's own
  /// handler registers first and wins.
  void _signal(PointerSignalEvent event) {
    final box = _window.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final factor = switch (event) {
      PointerScrollEvent() => math.exp(-event.scrollDelta.dy / 200),
      PointerScaleEvent() => event.scale,
      _ => null,
    };
    if (factor == null) return;
    GestureBinding.instance.pointerSignalResolver.register(
      event,
      (_) => _zoomAt(box.globalToLocal(event.position), factor),
    );
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  Widget _wideViewer(BuildContext context) => Focus(
        autofocus: true,
        child: Material(
          key: const ValueKey('web-figure-scrim'),
          color: context.webTokens.figureScrim,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: InteractiveViewer(
                        key: _window,
                        transformationController: _zoom,
                        minScale: 1,
                        maxScale: _maxZoom,
                        child: Container(
                          key: const ValueKey('web-figure-card'),
                          padding: const EdgeInsets.all(40),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width - 96,
                            maxHeight: MediaQuery.sizeOf(context).height - 180,
                          ),
                          decoration: BoxDecoration(
                            color: followTheme
                                ? context.colors.surface
                                : context.colors.readerFigureBackground,
                            borderRadius: BorderRadius.circular(18),
                            border:
                                Border.all(color: context.webTokens.cardEdge),
                          ),
                          child: followTheme
                              ? figure
                              : Theme(data: buildLightTheme(), child: figure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${credit.isEmpty ? '' : '$credit · '}'
                      'Scroll or + − to zoom · Esc to close',
                      textAlign: TextAlign.center,
                      style: context.webTokens
                          .style(14, color: context.webTokens.figureCaption),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 18,
                right: 18,
                child: IconButton(
                  tooltip: 'Close figure',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        context.colors.onFigureViewer.withValues(alpha: .12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    PantasIcons.close,
                    color: context.colors.onFigureViewer,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          if (context.wideWeb)
            const SingleActivator(LogicalKeyboardKey.equal): () => _scale(1.25),
          if (context.wideWeb)
            const SingleActivator(LogicalKeyboardKey.equal, shift: true): () =>
                _scale(1.25),
          if (context.wideWeb)
            const SingleActivator(LogicalKeyboardKey.minus): () => _scale(.8),
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
        },
        child: Listener(
          onPointerSignal: _signal,
          child: context.wideWeb
              ? _wideViewer(context)
              : Material(
                  color: context.colors.figureViewerBackground,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox.square(
                              dimension: 44,
                              child: IconButton(
                                tooltip: 'Close figure',
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  PantasIcons.close,
                                  size: 22,
                                  color: context.colors.onFigureViewer,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: InteractiveViewer(
                              key: _window,
                              transformationController: _zoom,
                              minScale: 1,
                              maxScale: _maxZoom,
                              child: AnimatedBuilder(
                                animation: arrival,
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width,
                                  child: ColoredBox(
                                    color: followTheme
                                        ? context.colors.surface
                                        : context.colors.readerFigureBackground,
                                    child: (followTheme
                                        ? figure
                                        : Theme(
                                            data: buildLightTheme(),
                                            child: figure,
                                          )),
                                  ),
                                ),
                                builder: (context, child) => Transform.scale(
                                  key: const ValueKey(
                                    'reader-viewer-scale',
                                  ),
                                  scale: .92 +
                                      .08 *
                                          const Cubic(.25, .9, .3, 1)
                                              .transform(arrival.value),
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (credit.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              credit,
                              textAlign: TextAlign.center,
                              style: context.type.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: context.colors.onFigureViewer
                                    .withValues(alpha: .6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      );
}

class _ContentImage extends StatefulWidget {
  const _ContentImage({
    required this.url,
    required this.label,
    required this.credit,
    this.reader = false,
  });
  final bool reader;
  final String url;
  final String label;
  final String credit;
  @override
  State<_ContentImage> createState() => _ContentImageState();
}

class _ContentImageState extends State<_ContentImage> {
  int _retry = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.url.startsWith('data:') &&
        lessonDataUrlBytes(widget.url) == null) {
      return _ImageFailure(
        reader: widget.reader,
        onRetry: () => setState(() => _retry++),
      );
    }
    if (isLessonSvg(widget.url)) {
      final loader = lessonSvgLoader(widget.url, context.colors);
      final failure = _ImageFailure(
        reader: widget.reader,
        onRetry: () => setState(() => _retry++),
      );
      // The PNG path draws with BoxFit.contain and no width, so a figure takes
      // its own size up to the frame's width. SvgPicture's defaults are the
      // same (contain, no width), and a test compares both sizes.
      if (!widget.reader) {
        // Like a PNG here: the frame holds the figure, its loading space and
        // its failure.
        return _FigureFrame(
          label: widget.label,
          credit: widget.credit,
          imageSemantics: false,
          followTheme: true,
          figure: SvgPicture(
            loader,
            key: ValueKey((widget.url, _retry)),
            semanticsLabel: widget.label,
            excludeFromSemantics: widget.label.isEmpty,
            placeholderBuilder: (context) => const SizedBox(height: 223),
            errorBuilder: (context, error, stackTrace) => failure,
          ),
        );
      }
      // Like a reader PNG: loading inside the frame, failure in its own box.
      return SvgPicture(
        loader,
        key: ValueKey((widget.url, _retry)),
        semanticsLabel: widget.label,
        excludeFromSemantics: widget.label.isEmpty,
        placeholderBuilder: (context) => _FigureFrame(
          reader: true,
          followTheme: true,
          label: widget.label,
          credit: widget.credit,
          expandable: false,
          imageSemantics: false,
          figure: const SizedBox(height: 223),
        ),
        errorBuilder: (context, error, stackTrace) => failure,
        imageBuilder: (context, child) => _FigureFrame(
          reader: true,
          followTheme: true,
          label: widget.label,
          credit: widget.credit,
          imageSemantics: false,
          figure: child,
        ),
      );
    }
    if (widget.url.startsWith('data:image/')) {
      return _FigureFrame(
        reader: widget.reader,
        label: widget.label,
        credit: widget.credit,
        imageSemantics: false,
        figure: Image.memory(
          lessonDataUrlBytes(widget.url)!,
          fit: BoxFit.contain,
          semanticLabel: widget.label,
          excludeFromSemantics: widget.label.isEmpty,
          errorBuilder: (context, error, stackTrace) => _ImageFailure(
            reader: widget.reader,
            onRetry: () => setState(() => _retry++),
          ),
        ),
      );
    }
    final image = Image.network(
      widget.url,
      key: ValueKey(_retry),
      fit: BoxFit.contain,
      semanticLabel: widget.label,
      excludeFromSemantics: widget.label.isEmpty,
      frameBuilder: widget.reader
          ? (context, child, frame, synchronous) => _FigureFrame(
                reader: true,
                label: widget.label,
                credit: widget.credit,
                imageSemantics: false,
                expandable: frame != null || synchronous,
                figure: frame == null && !synchronous
                    ? SizedBox(height: 223, child: child)
                    : child,
              )
          : null,
      errorBuilder: (context, error, stackTrace) => _ImageFailure(
        reader: widget.reader,
        onRetry: () => setState(() => _retry++),
      ),
    );
    if (widget.reader) return image;
    return _FigureFrame(
      label: widget.label,
      credit: widget.credit,
      imageSemantics: false,
      figure: image,
    );
  }
}

class _ImageFailure extends StatelessWidget {
  const _ImageFailure({required this.onRetry, this.reader = false});
  final bool reader;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          key: reader ? const ValueKey('reader-image-failure') : null,
          constraints: reader ? const BoxConstraints(minHeight: 223) : null,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: reader ? context.colors.background : context.colors.fill,
            borderRadius: BorderRadius.circular(14),
            border: reader
                ? Border.all(color: context.colors.separator, width: .5)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(
                  PantasIcons.imageFailed,
                  size: reader ? 30 : 32,
                  color: context.colors.chevron,
                ),
              ),
              SizedBox(height: reader ? 6 : 10),
              Text(
                reader
                    ? 'This illustration didn’t load.'
                    : 'Image could not load.',
                textAlign: TextAlign.center,
                style: reader ? context.type.footnote : context.type.subhead,
              ),
              if (reader) const SizedBox(height: 6),
              if (!reader || onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  style: reader
                      ? TextButton.styleFrom(minimumSize: const Size(44, 44))
                      : null,
                  child: Text(
                    reader ? 'Try Again' : 'Retry',
                    style: (reader
                            ? context.type.footnote
                                .copyWith(fontWeight: FontWeight.w600)
                            : context.type.subheadStrong)
                        .copyWith(color: context.colors.accent),
                  ),
                ),
            ],
          ),
        ),
      );
}
