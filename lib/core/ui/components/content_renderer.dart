import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/components/lesson_svg.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/reader_blocks.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

// Credits use secondaryLabel under the Task8b contrast ruling.

/// Sent up the tree once a reader example has finished opening, so the page
/// can measure its new length. See `_ExampleCard`.
class ReaderResizedNotification extends Notification {
  const ReaderResizedNotification();
}

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

  /// The reader's body text: 18 px on wide web and 16 px on a phone, a step
  /// dimmer than bold. Only the reader uses it; the rest of the app keeps its
  /// own body color.
  TextStyle readerBody(BuildContext context) {
    final wide = context.wideWeb;
    return (style ?? context.type.body).copyWith(
      fontSize: wide ? 18 : 16,
      height: wide ? 1.7 : 1.6,
      letterSpacing: -.08,
      fontWeight: FontWeight.w400,
      color: context.colors.readerBody,
    );
  }

  TextStyle _readerH2(BuildContext context) {
    final wide = context.wideWeb;
    return context.type.sectionHero.copyWith(
      fontSize: wide ? 32 : 26,
      height: 1.18,
      letterSpacing: wide ? -.65 : -.42,
      fontWeight: FontWeight.w700,
      color: context.colors.label,
    );
  }

  TextStyle _readerH3(BuildContext context, {double? size}) =>
      context.type.emphasized.copyWith(
        fontSize: size ?? (context.wideWeb ? 21 : 18),
        height: 1.28,
        letterSpacing: -.3,
        fontWeight: FontWeight.w600,
        color: context.colors.label,
      );

  /// The text runs of [runs] as spans, with the spoken form of any math.
  ({List<InlineSpan> spans, String spoken, bool hasMath, bool validSpeech})
      _inline(
    BuildContext context,
    List<Map<String, Object?>> runs,
    TextStyle type,
  ) {
    final spans = <InlineSpan>[];
    final spoken = StringBuffer();
    var hasMath = false;
    var validSpeech = true;
    for (final run in runs) {
      final source = string(run['text']);
      final marks = run['marks'] is List<Object?>
          ? (run['marks']! as List<Object?>).whereType<String>().toSet()
          : <String>{};
      final runStyle = type.copyWith(
        fontWeight: marks.contains('strong') ? FontWeight.w600 : null,
        // Bold is a step brighter than body text in the reader.
        color: readerFigures && marks.contains('strong')
            ? context.colors.readerStrong
            : null,
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
    return (
      spans: spans,
      spoken: spoken.toString(),
      hasMath: hasMath,
      validSpeech: validSpeech,
    );
  }

  /// Takes the leading `#3:` off a heading's runs, so the number can be drawn
  /// apart from the title. Returns the runs unchanged when there is none.
  ({String? number, List<Map<String, Object?>> runs}) _numbered(
    List<Map<String, Object?>> runs,
  ) {
    final match = RegExp(r'^#(\d+):\s*').firstMatch(
      runs.map((r) => string(r['text'])).join(),
    );
    if (match == null) return (number: null, runs: runs);
    var cut = match.end;
    final out = <Map<String, Object?>>[];
    for (final run in runs) {
      final text = string(run['text']);
      if (cut <= 0) {
        out.add(run);
      } else if (text.length <= cut) {
        cut -= text.length;
      } else {
        out.add({...run, 'text': text.substring(cut)});
        cut = 0;
      }
    }
    return (number: match.group(1), runs: out);
  }

  /// [body] with the spoken form of its math, when it has any.
  Widget _spoken(
    Widget body,
    ({
      List<InlineSpan> spans,
      String spoken,
      bool hasMath,
      bool validSpeech
    }) inline, {
    String? marker,
  }) =>
      inline.hasMath && inline.validSpeech
          ? Semantics(
              label: '${marker == null ? '' : '$marker '}${inline.spoken}',
              excludeSemantics: true,
              child: body,
            )
          : body;

  /// A small uppercase label that speaks as written, such as "Solution".
  Widget caps(String label, TextStyle style) => Semantics(
        label: label,
        excludeSemantics: true,
        child: Text(label.toUpperCase(), style: style),
      );

  Widget paragraph(
    BuildContext context,
    Map<String, Object?> block, {
    String? marker,
    ReaderSection section = ReaderSection.plain,
    bool step = false,
  }) {
    final name = string(block['style']);
    final base = readerFigures
        ? readerBody(context)
        : style ?? context.type.body.copyWith(height: 1.55);
    final phoneType = switch (name) {
      'h1' => context.type.pageTitle.copyWith(height: 1.15),
      'h2' when readerFigures => _readerH2(context),
      'h2' => context.type.sectionHero
          .copyWith(fontSize: 22, height: 1.25, letterSpacing: -.264),
      'h3' when readerFigures => _readerH3(context),
      'h3' || 'h4' || 'h5' || 'h6' => context.type.emphasized
          .copyWith(fontSize: 18, height: 1.3, letterSpacing: -.216),
      'blockquote' when readerFigures => base.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.55,
          color: section == ReaderSection.traps
              ? context.colors.readerWarnText
              : context.colors.readerNoteText,
        ),
      'blockquote' => base.copyWith(fontWeight: FontWeight.w500),
      // A step is not a paragraph, so it has no tracking and a tighter line.
      _ when step => base.copyWith(
          height: context.wideWeb ? 1.67 : 1.6,
          letterSpacing: 0,
        ),
      _ => base,
    };
    final type = phoneType;
    final runs = maps(block['children']);
    final numbered = readerFigures && name.startsWith('h')
        ? _numbered(runs)
        : (number: null, runs: runs);
    final inline = _inline(context, numbered.runs, type);
    if (numbered.number != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            numbered.number!,
            style: type.copyWith(
              color: context.colors.secondaryLabel,
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _spoken(
              Text.rich(TextSpan(children: inline.spans), style: type),
              inline,
            ),
          ),
        ],
      );
    }
    Widget body = Text.rich(
      TextSpan(children: inline.spans),
      style: type,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
    );
    body = _spoken(body, inline, marker: marker);
    if (marker != null) {
      final level =
          block['level'] is num ? (block['level']! as num).toInt() : 1;
      final markerStyle = base.copyWith(
        fontWeight: FontWeight.w500,
        color: readerFigures && marker == '•'
            ? context.colors.tertiaryLabel
            : context.colors.secondaryLabel,
        fontFeatures: step ? const [FontFeature.tabularFigures()] : null,
        height: step ? type.height : null,
      );
      body = Padding(
        padding: EdgeInsets.only(left: ((level - 1).clamp(0, 4)) * 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A solution step keeps its number in a 22 px column, so the text
            // of step 9 and step 10 starts at the same place.
            if (step)
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 22),
                child: Text(marker, style: markerStyle),
              )
            else
              Text(marker, style: markerStyle),
            SizedBox(width: readerFigures ? 9 : 12),
            Expanded(child: body),
          ],
        ),
      );
    }
    if (name == 'blockquote') {
      if (readerFigures) return _note(context, body, section);
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

  /// A reader note: a tinted card. "Mnemonics" labels it Remember, "Traps"
  /// swaps to the warn colors and Watch out, and any other section keeps the
  /// accent tint with no label.
  Widget _note(BuildContext context, Widget body, ReaderSection section) {
    final c = context.colors;
    final warn = section == ReaderSection.traps;
    final label = switch (section) {
      ReaderSection.mnemonics => 'Remember',
      ReaderSection.traps => 'Watch out',
      _ => null,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: warn ? c.readerWarnTint : c.accentTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null) ...[
            caps(
              label,
              context.type.sectionHeader.copyWith(
                fontSize: 12,
                letterSpacing: .48,
                color: warn ? c.readerWarn : c.accent,
              ),
            ),
            const SizedBox(height: 6),
          ],
          body,
        ],
      ),
    );
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
    ReaderSection section = ReaderSection.plain,
    bool step = false,
  }) {
    final type = string(block['_type']);
    switch (type) {
      case 'block':
        return paragraph(
          context,
          block,
          marker: marker,
          section: section,
          step: step,
        );
      case 'latex':
        return MathText(
          string(block['body']),
          display: true,
          semanticsLabel: block['semanticsLabel'] is String
              ? block['semanticsLabel']! as String
              : null,
          // Display maths takes the bold color, one step above the text.
          style: readerFigures
              ? readerBody(context).copyWith(
                  fontSize: 19,
                  color: context.colors.readerStrong,
                )
              : style,
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

  /// The space above a section heading in the reader. The first section of a
  /// lesson has none, so the sections are told apart by space alone.
  static double sectionGap(BuildContext context) => context.wideWeb ? 104 : 72;

  Widget _readerColumn(
    BuildContext context,
    List<Map<String, Object?>> blocks,
  ) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _stack(
          _readerSlots(context, planReaderBlocks(blocks)),
        ).children,
      );

  /// The slots one under another, with the larger of the two margins between
  /// neighbors, as the page collapses them. The tail is the last margin.
  ({List<Widget> children, double tail}) _stack(List<_Slot> slots) {
    final children = <Widget>[];
    for (var i = 0; i < slots.length; i++) {
      if (i > 0) {
        final prev = slots[i - 1];
        final gap = prev.list && slots[i].list
            ? 8.0
            : math.max(prev.below, slots[i].above);
        if (gap > 0) children.add(SizedBox(height: gap));
      }
      children.add(slots[i].child);
    }
    return (children: children, tail: slots.isEmpty ? 0 : slots.last.below);
  }

  List<_Slot> _readerSlots(
    BuildContext context,
    List<ReaderItem> items, {
    bool solution = false,
    bool choices = false,
  }) {
    final wide = context.wideWeb;
    final slots = <_Slot>[];
    final counters = <int, int>{};
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (item is ReaderExample) {
        counters.clear();
        slots.add(_Slot(_exampleCard(context, item)));
        continue;
      }
      final plain = item as ReaderPlain;
      final block = plain.block;
      // A "Solution:" line outside any example card keeps its open panel.
      if (!solution && isSolutionMarker(block)) {
        var end = index + 1;
        while (end < items.length &&
            items[end] is ReaderPlain &&
            !_endsSolution((items[end] as ReaderPlain).block)) {
          end++;
        }
        counters.clear();
        slots.add(
          _Slot(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: context.colors.readerDeep,
                borderRadius: BorderRadius.circular(14),
              ),
              child: _solutionBody(
                context,
                [
                  for (final later in items.sublist(index + 1, end))
                    (later as ReaderPlain).block,
                ],
                plain.section,
              ),
            ),
          ),
        );
        index = end - 1;
        continue;
      }
      if (choices) {
        final split = splitReaderChoices(block);
        if (split != null) {
          if (split.stem.isNotEmpty) {
            slots.add(
              _Slot(
                dispatch(
                  context,
                  {...block, 'children': split.stem},
                  section: plain.section,
                ),
              ),
            );
          }
          slots.add(
            _Slot(_choiceRows(context, split.choices), above: 4),
          );
          counters.clear();
          continue;
        }
      }
      final isBlock = block['_type'] == 'block';
      final list = isBlock ? string(block['listItem']) : '';
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
      } else if (isBlock) {
        counters.clear();
      }
      final style = isBlock ? string(block['style']) : '';
      final (above, below) = switch (style) {
        'h2' => (sectionGap(context), wide ? 20.0 : 16.0),
        'h3' => (wide ? 40.0 : 30.0, wide ? 12.0 : 10.0),
        'blockquote' => (
            0.0,
            plain.section == ReaderSection.traps ? 16.0 : 18.0
          ),
        _ when block['_type'] == 'latex' => (6.0, 22.0),
        _ when list.isNotEmpty && solution => (0.0, 8.0),
        _ => (0.0, 18.0),
      };
      slots.add(
        _Slot(
          dispatch(
            context,
            block,
            marker: marker,
            section: plain.section,
            step: solution && list == 'number',
          ),
          above: above,
          below: below,
          list: list.isNotEmpty,
        ),
      );
    }
    return slots;
  }

  /// Whether [block] ends an open solution: a heading or a figure.
  bool _endsSolution(Map<String, Object?> block) =>
      (block['_type'] == 'block' && string(block['style']).startsWith('h')) ||
      block['_type'] == 'image' ||
      block['_type'] == 'figureSpec';

  /// The label and the steps of one solution.
  Widget _solutionBody(
    BuildContext context,
    List<Map<String, Object?>> blocks,
    ReaderSection section, {
    bool inCard = false,
  }) {
    final stack = _stack(
      _readerSlots(
        context,
        [for (final block in blocks) ReaderPlain(block, section)],
        solution: true,
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        caps(
          'Solution',
          context.type.sectionHeader.copyWith(fontSize: 12, letterSpacing: .48),
        ),
        const SizedBox(height: 10),
        ...stack.children,
        // The last margin stays inside the panel, so a solution ending in a
        // paragraph has more room under it than one ending in a step.
        if (inCard && stack.tail > 0) SizedBox(height: stack.tail),
      ],
    );
  }

  /// Answer choices as rows, a hairline above each, the letter in the accent.
  Widget _choiceRows(BuildContext context, List<ReaderChoice> choices) {
    final c = context.colors;
    final wide = context.wideWeb;
    final text = readerBody(context).copyWith(
      height: wide ? 1.67 : 1.6,
      letterSpacing: 0,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final choice in choices)
          Container(
            key: ValueKey('reader-choice-${choice.letter}'),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.separator)),
            ),
            child: _choiceRow(context, choice, text),
          ),
      ],
    );
  }

  Widget _choiceRow(
    BuildContext context,
    ReaderChoice choice,
    TextStyle text,
  ) {
    final inline = _inline(context, choice.runs, text);
    final letter = text.copyWith(
      fontWeight: FontWeight.w600,
      color: context.colors.accent,
    );
    return _spoken(
      Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: SizedBox(
                width: 26,
                child: Text('${choice.letter})', style: letter),
              ),
            ),
            ...inline.spans,
          ],
        ),
        style: text,
      ),
      inline,
      marker: '${choice.letter}.',
    );
  }

  Widget _exampleCard(BuildContext context, ReaderExample example) {
    final title = _numbered(maps(example.title['children']));
    final titleStyle = _readerH3(context, size: 19);
    final inline = _inline(context, title.runs, titleStyle);
    final stem = _stack(
      _readerSlots(
        context,
        [
          for (final block in example.stem)
            ReaderPlain(block, ReaderSection.examples),
        ],
        choices: true,
      ),
    );
    final wide = context.wideWeb;
    final solution = example.solution.isEmpty
        ? null
        : _solutionBody(
            context,
            example.solution,
            ReaderSection.examples,
            inCard: true,
          );
    return _ExampleCard(
      key: ValueKey('reader-example-${example.number}'),
      wide: wide,
      label: 'Example ${example.number}',
      title: _spoken(
        Text.rich(TextSpan(children: inline.spans), style: titleStyle),
        inline,
      ),
      stem: stem.children,
      stemTail: stem.tail,
      solution: solution,
    );
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
    final visible = blocks!.where((block) {
      if (!readerFigures || block['_type'] != 'image') return true;
      final asset = block['asset'];
      return (asset is Map<String, Object?>
              ? string(asset['url'])
              : string(block['url']))
          .isNotEmpty;
    }).toList();
    if (readerFigures) return _readerColumn(context, visible);
    final children = <Widget>[];
    final counters = <int, int>{};
    for (var index = 0; index < visible.length; index++) {
      final block = visible[index];
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
        children
            .add(SizedBox(height: string(block['style']) == 'h2' ? 32 : 18));
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

/// One reader block with the margins the page puts around it.
class _Slot {
  const _Slot(
    this.child, {
    this.above = 0,
    this.below = 18,
    this.list = false,
  });
  final Widget child;
  final double above;
  final double below;
  final bool list;
}

/// An example in the reader: a card with its title, its question, and a
/// solution kept behind a button until the student asks for it.
///
/// The card owns whether the solution is open. It starts closed each time the
/// lesson is opened and stays open for the rest of that visit.
class _ExampleCard extends StatefulWidget {
  const _ExampleCard({
    required this.wide,
    required this.label,
    required this.title,
    required this.stem,
    required this.stemTail,
    required this.solution,
    super.key,
  });

  final bool wide;
  final String label;
  final Widget title;
  final List<Widget> stem;
  final double stemTail;
  final Widget? solution;

  @override
  State<_ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<_ExampleCard> {
  final _button = FocusNode(debugLabel: 'Show solution');
  final _panel = FocusNode(debugLabel: 'Solution', skipTraversal: true);
  bool _open = false;

  @override
  void dispose() {
    _button.dispose();
    _panel.dispose();
    super.dispose();
  }

  void _reveal() {
    // A keyboard student pressed the button, which is about to leave, so focus
    // moves to the solution instead of being lost.
    final moveFocus = _button.hasFocus;
    setState(() => _open = true);
    if (moveFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _panel.requestFocus();
      });
    }
    // Without the size animation the page already has its new length.
    if (MediaQuery.disableAnimationsOf(context)) _resized();
  }

  /// Tells the page, once the frame is laid out, that its length changed.
  void _resized() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) const ReaderResizedNotification().dispatch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final wide = widget.wide;
    final side = wide ? 24.0 : 16.0;
    final still = MediaQuery.disableAnimationsOf(context);
    final solution = widget.solution;
    Widget? region;
    if (solution != null) {
      if (_open) {
        final panel = Focus(
          focusNode: _panel,
          child: Container(
            key: const ValueKey('reader-solution-panel'),
            padding: EdgeInsets.fromLTRB(
              side,
              wide ? 18 : 16,
              side,
              wide ? 14 : 10,
            ),
            decoration: BoxDecoration(
              color: c.readerDeep,
              border: Border(top: BorderSide(color: c.separator)),
            ),
            child: solution,
          ),
        );
        region = still
            ? panel
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) =>
                    Opacity(opacity: value, child: child),
                child: panel,
              );
      } else {
        region = Padding(
          padding: EdgeInsets.fromLTRB(side, 0, side, 18),
          child: TextButton(
            key: const ValueKey('reader-solution-button'),
            focusNode: _button,
            onPressed: _reveal,
            style: TextButton.styleFrom(
              backgroundColor: c.accentTint,
              foregroundColor: c.accent,
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: context.type.emphasized.copyWith(
                fontSize: 16,
                letterSpacing: 0,
              ),
            ),
            child: const Text('Show solution'),
          ),
        );
      }
      // A zero-length AnimatedSize re-enters its own layout, so reduced
      // motion skips it and the panel appears at once.
      if (!still) {
        region = AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          onEnd: _resized,
          child: region,
        );
      }
    }
    return Container(
      key: const ValueKey('reader-example-card'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.separator),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(side, wide ? 22 : 18, side, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.label,
                  style: context.type.sectionHeader.copyWith(
                    fontSize: 13,
                    height: 1.28,
                    letterSpacing: .26,
                    color: c.accent,
                  ),
                ),
                const SizedBox(height: 4),
                widget.title,
                if (widget.stem.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...widget.stem,
                ],
              ],
            ),
          ),
          SizedBox(
            height: solution == null
                ? widget.stemTail
                : math.max(widget.stemTail, 18),
          ),
          if (region != null) region,
          SizedBox(height: wide ? 8 : 4),
        ],
      ),
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

  /// Opens the figure at the width it has in the page, so a figure that lays
  /// itself out by width keeps the same shape in the viewer.
  Future<void> expand(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final frame = context.findRenderObject() as RenderBox?;
    final inset = reader && context.wideWeb ? 44.0 : 0.0;
    final figureWidth = frame != null && frame.hasSize
        ? math.max(frame.size.width - inset, 1).toDouble()
        : MediaQuery.sizeOf(context).width;
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
          figureWidth: figureWidth,
          reader: reader,
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
    required this.figureWidth,
    this.reader = true,
    this.followTheme = false,
  });
  final Widget figure;
  final String credit;
  final Animation<double> arrival;
  final double figureWidth;
  final bool reader;
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

  /// The window the figure is zoomed in. It fills the screen, so a zoomed
  /// figure grows past its card and can be panned across the whole screen.
  final _window = GlobalKey();

  /// A wide viewer already opens up to twice the size in the page, so it needs
  /// less room to zoom than a phone.
  double get _maxZoom => context.wideWeb ? 3 : 5;

  /// Wheel distance for a zoom of e. One notch is a gentle step.
  static const double _wheelScale = 600;

  /// How much larger than in the page the figure may open.
  static const double _maxFitScale = 2;

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
      PointerScrollEvent() => math.exp(-event.scrollDelta.dy / _wheelScale),
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

  Color _figureBackground(BuildContext context) => followTheme
      ? context.colors.surface
      : widget.reader
          ? context.colors.readerFigureBackground
          : context.colors.figureBackground;

  Widget get _themedFigure =>
      followTheme ? figure : Theme(data: buildLightTheme(), child: figure);

  /// A click beside the figure closes the viewer; a click on it does not.
  Widget _zoomWindow(
    BuildContext context, {
    required EdgeInsets margin,
    required Widget card,
  }) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          key: _window,
          transformationController: _zoom,
          minScale: 1,
          maxScale: _maxZoom,
          scaleFactor: _wheelScale,
          child: Padding(
            padding: margin,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: AnimatedBuilder(
                  animation: arrival,
                  child: card,
                  builder: (context, child) => Transform.scale(
                    key: const ValueKey('reader-viewer-scale'),
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
        ),
      );

  Widget _wideViewer(BuildContext context) => Focus(
        autofocus: true,
        child: Material(
          key: const ValueKey('web-figure-scrim'),
          color: context.webTokens.figureScrim,
          child: Stack(
            children: [
              Positioned.fill(
                child: ValueListenableBuilder<Matrix4>(
                  valueListenable: _zoom,
                  builder: (context, value, child) => MouseRegion(
                    cursor: value.getMaxScaleOnAxis() > 1
                        ? SystemMouseCursors.grab
                        : MouseCursor.defer,
                    child: child,
                  ),
                  child: _zoomWindow(
                    context,
                    margin: const EdgeInsets.fromLTRB(48, 72, 48, 72),
                    card: Container(
                      key: const ValueKey('web-figure-card'),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: _figureBackground(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: context.webTokens.cardEdge),
                      ),
                      child: _FittedFigure(
                        width: widget.figureWidth,
                        maxScale: _maxFitScale,
                        child: _themedFigure,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 22,
                child: IgnorePointer(
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.webTokens.figureScrim,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          '${credit.isEmpty ? '' : '$credit · '}'
                          'Scroll or + − to zoom · Esc to close',
                          textAlign: TextAlign.center,
                          style: context.webTokens.style(
                            14,
                            color: context.webTokens.figureCaption,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 18,
                right: 18,
                child: IconButton(
                  tooltip: 'Close figure',
                  style: IconButton.styleFrom(
                    backgroundColor: context.webTokens.figureScrim,
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

  Widget _phoneViewer(BuildContext context) => Material(
        color: context.colors.figureViewerBackground,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: _zoomWindow(
                  context,
                  margin: EdgeInsets.only(
                    top: 56,
                    bottom: credit.isEmpty ? 16 : 48,
                  ),
                  card: ColoredBox(
                    color: _figureBackground(context),
                    child: _FittedFigure(
                      width: widget.figureWidth,
                      maxScale: _maxFitScale,
                      child: _themedFigure,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 8,
                child: SizedBox.square(
                  dimension: 44,
                  child: IconButton(
                    tooltip: 'Close figure',
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.figureViewerBackground
                          .withValues(alpha: .72),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      PantasIcons.close,
                      size: 22,
                      color: context.colors.onFigureViewer,
                    ),
                  ),
                ),
              ),
              if (credit.isNotEmpty)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: IgnorePointer(
                    child: Text(
                      credit,
                      textAlign: TextAlign.center,
                      style: context.type.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color:
                            context.colors.onFigureViewer.withValues(alpha: .6),
                      ),
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
          if (context.wideWeb) ...{
            const SingleActivator(LogicalKeyboardKey.equal): () => _scale(1.25),
            const SingleActivator(LogicalKeyboardKey.equal, shift: true): () =>
                _scale(1.25),
            const SingleActivator(LogicalKeyboardKey.add): () => _scale(1.25),
            const SingleActivator(LogicalKeyboardKey.add, shift: true): () =>
                _scale(1.25),
            const SingleActivator(LogicalKeyboardKey.numpadAdd): () =>
                _scale(1.25),
            const SingleActivator(LogicalKeyboardKey.minus): () => _scale(.8),
            const SingleActivator(LogicalKeyboardKey.numpadSubtract): () =>
                _scale(.8),
          },
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
        },
        child: Listener(
          onPointerSignal: _signal,
          child: context.wideWeb ? _wideViewer(context) : _phoneViewer(context),
        ),
      );
}

/// Lays [child] out at [width], then scales it to fit the space it is given,
/// up to [maxScale] times. Only the scale changes, so the figure keeps the
/// shape it has in the page, and its parent wraps the scaled size.
class _FittedFigure extends SingleChildRenderObjectWidget {
  const _FittedFigure({
    required this.width,
    required this.maxScale,
    required Widget super.child,
  });
  final double width;
  final double maxScale;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFittedFigure(width, maxScale);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFittedFigure renderObject,
  ) {
    renderObject
      ..figureWidth = width
      ..maxScale = maxScale;
  }
}

class _RenderFittedFigure extends RenderProxyBox {
  _RenderFittedFigure(this._figureWidth, this._maxScale);

  double _figureWidth;
  double get figureWidth => _figureWidth;
  set figureWidth(double value) {
    if (value == _figureWidth) return;
    _figureWidth = value;
    markNeedsLayout();
  }

  double _maxScale;
  double get maxScale => _maxScale;
  set maxScale(double value) {
    if (value == _maxScale) return;
    _maxScale = value;
    markNeedsLayout();
  }

  double _scale = 1;

  Matrix4 get _transform => Matrix4.diagonal3Values(_scale, _scale, 1);

  @override
  void performLayout() {
    final box = child;
    if (box == null) {
      size = constraints.smallest;
      return;
    }
    box.layout(
      BoxConstraints.tightFor(width: _figureWidth),
      parentUsesSize: true,
    );
    final natural = box.size;
    _scale = natural.isEmpty
        ? 1
        : math.min(
            _maxScale,
            math.min(
              constraints.maxWidth / natural.width,
              constraints.maxHeight / natural.height,
            ),
          );
    size = constraints.constrain(natural * _scale);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      super.paint,
      oldLayer: layer as TransformLayer?,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final box = child;
    if (box == null) return false;
    return result.addWithPaintTransform(
      transform: _transform,
      position: position,
      hitTest: (result, position) => box.hitTest(result, position: position),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transform);
  }
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
