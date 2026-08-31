import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/accessible_math.dart';
import 'package:pantas/core/ui/components/inline_math_text.dart';
import 'package:pantas/core/ui/figures/lesson_figure_widget.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class PortableTextRenderer extends StatelessWidget {
  const PortableTextRenderer({
    this.blocks,
    this.text,
    this.maxLines,
    super.key,
  }) : assert(
          blocks != null || text != null,
          'Either blocks or text must be provided',
        );

  final List<Map<String, dynamic>>? blocks;
  final String? text;
  final int? maxLines;

  static List<Map<String, dynamic>> _parseTextToBlocks(String text) {
    final children = <Map<String, dynamic>>[];
    final regex = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*|(?<!_)_([^_]+?)_(?!_)');
    var lastMatchEnd = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        children.add({
          'text': text.substring(lastMatchEnd, match.start),
          'marks': <String>[],
        });
      }
      final strong = match.group(1);
      final starEmphasis = match.group(2);
      final underscoreEmphasis = match.group(3);
      if (strong != null) {
        children.add({
          'text': strong,
          'marks': <String>['strong'],
        });
      } else if (starEmphasis != null) {
        children.add({
          'text': starEmphasis,
          'marks': <String>['em'],
        });
      } else if (underscoreEmphasis != null) {
        children.add({
          'text': underscoreEmphasis,
          'marks': <String>['em'],
        });
      }
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      children.add({
        'text': text.substring(lastMatchEnd),
        'marks': <String>[],
      });
    }
    return [
      {
        '_type': 'block',
        'style': 'normal',
        'children': children,
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final effectiveBlocks = blocks ?? _parseTextToBlocks(text!);
    // Numbered-list counters per indent level. A paragraph or heading ends
    // the list and resets them; a deeper level resets the counters below
    // it.
    //
    // An embedded object does not end it. A step that shows its working
    // puts a display formula between two items, and treating that as the
    // end of the list restarted the numbering: "1, 2, 3" then "1" again,
    // which is what a reader sees in every worked example in Mathematics.
    final numberCounters = <int, int>{};
    for (final block in effectiveBlocks) {
      final isParagraph = block['_type'] == 'block';
      final listItem = isParagraph ? block['listItem'] as String? : null;
      if (listItem == null) {
        if (isParagraph) numberCounters.clear();
        children.add(_dispatch(context, block, isFirst: children.isEmpty));
        continue;
      }
      final level = (block['level'] as num?)?.toInt() ?? 1;
      numberCounters.removeWhere((l, _) => l > level);
      String marker;
      if (listItem == 'number') {
        numberCounters[level] = (numberCounters[level] ?? 0) + 1;
        marker = '${numberCounters[level]}.';
      } else {
        marker = '•';
      }
      children.add(
        _BlockRenderer(
          block: block,
          marker: marker,
          level: level,
          maxLines: maxLines,
          isFirst: children.isEmpty,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _dispatch(
    BuildContext context,
    Map<String, dynamic> block, {
    required bool isFirst,
  }) {
    final type = block['_type'] as String? ?? '';
    return switch (type) {
      'block' =>
        _BlockRenderer(block: block, maxLines: maxLines, isFirst: isFirst),
      'latex' => _LatexBlockRenderer(block: block),
      'image' => _ImageBlockRenderer(block: block),
      'figureSpec' => _FigureSpecBlockRenderer(block: block),
      'table' => _TableBlockRenderer(block: block),
      _ => _UnknownBlockPlaceholder(blockType: type),
    };
  }
}

class _FigureSpecBlockRenderer extends StatelessWidget {
  const _FigureSpecBlockRenderer({required this.block});

  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final rawSpec = block['spec'];
    if (rawSpec is! Map) {
      return const _UnknownBlockPlaceholder(blockType: 'figureSpec');
    }
    final spec = <String, Object?>{};
    for (final entry in rawSpec.entries) {
      if (entry.key is! String) {
        return const _UnknownBlockPlaceholder(blockType: 'figureSpec');
      }
      spec[entry.key as String] = entry.value;
    }
    final semanticsLabel = block['semanticsLabel'];
    return LessonFigureWidget(
      spec: spec,
      semanticsLabel: semanticsLabel is String ? semanticsLabel : '',
    );
  }
}

class _TableBlockRenderer extends StatelessWidget {
  const _TableBlockRenderer({required this.block});

  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final rawRows = block['rows'];
    if (rawRows is! List || rawRows.isEmpty) {
      return const _UnknownBlockPlaceholder(blockType: 'table');
    }

    final rows = <List<String>>[];
    int? width;
    for (final rawRow in rawRows) {
      if (rawRow is! List || rawRow.isEmpty) {
        return const _UnknownBlockPlaceholder(blockType: 'table');
      }
      final row = <String>[];
      for (final cell in rawRow) {
        if (cell is! String) {
          return const _UnknownBlockPlaceholder(blockType: 'table');
        }
        row.add(cell);
      }
      width ??= row.length;
      if (row.length != width) {
        return const _UnknownBlockPlaceholder(blockType: 'table');
      }
      rows.add(row);
    }

    final colors = context.colors;
    final bodyStyle = context.textStyles.bodySmall.copyWith(color: colors.ink);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: colors.rule),
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
              TableRow(
                children: [
                  for (final cell in rows[rowIndex])
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        cell,
                        style: rowIndex == 0
                            ? bodyStyle.copyWith(fontWeight: FontWeight.w700)
                            : bodyStyle,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _BlockRenderer extends StatelessWidget {
  const _BlockRenderer({
    required this.block,
    this.marker,
    this.level = 1,
    this.maxLines,
    this.isFirst = false,
  });

  final Map<String, dynamic> block;

  /// List marker ("•" or "3.") when this block is a list item.
  final String? marker;

  /// List indent level (1-based); only meaningful when [marker] is set.
  final int level;

  final int? maxLines;

  /// The opening block takes no gap above: the page already sets its own
  /// top padding and the lesson title sits directly over it.
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final style = block['style'] as String? ?? 'normal';
    final children =
        (block['children'] as List? ?? []).cast<Map<String, dynamic>>();
    final textStyles = context.textStyles;

    final baseStyle = switch (style) {
      'h1' => textStyles.displayLarge,
      'h2' => textStyles.displaySmall,
      'h3' => textStyles.headlineMedium,
      'h4' || 'h5' || 'h6' => textStyles.headlineSmall,
      'blockquote' =>
        textStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic),
      _ => textStyles.bodyMedium,
    };

    final indent = marker == null ? 0.0 : 12.0 + 16.0 * (level - 1).clamp(0, 4);

    // Every block used to take the same 4 above and below, so a heading had
    // no more air than the sentence before it and the page read as one
    // undifferentiated column.
    //
    // A heading takes its space **above**, not below. The gap belongs to the
    // section it opens: bound tightly to its own first line, separated from
    // the section that ended. Equal space either side makes a heading float
    // between two blocks instead of belonging to one, which is grouping
    // without hierarchy.
    final (double above, double below) = isFirst
        ? (0, _spaceBelow(style))
        : (_spaceAbove(style), _spaceBelow(style));

    final richText = Text.rich(
      TextSpan(
        children: [
          if (marker != null) TextSpan(text: '$marker  '),
          for (final child in children)
            _buildInlineSpan(child, baseStyle: baseStyle),
        ],
      ),
      style: baseStyle,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
    final semanticsLabel = _inlineSentenceSemantics(children);

    return Padding(
      padding: EdgeInsets.only(top: above, bottom: below, left: indent),
      child: semanticsLabel == null
          ? richText
          : Semantics(
              label: semanticsLabel,
              excludeSemantics: true,
              child: richText,
            ),
    );
  }

  String? _inlineSentenceSemantics(List<Map<String, dynamic>> children) {
    final label = StringBuffer();
    if (marker != null) label.write('$marker  ');
    var hasMath = false;

    for (final child in children) {
      final text = child['text'] as String? ?? '';
      final marks = (child['marks'] as List? ?? []).cast<String>();
      if (marks.contains('latex')) {
        final mathLabel = inlineMathExpressionSemanticsLabel(text);
        if (mathLabel == null) return null;
        label.write(mathLabel);
        hasMath = true;
        continue;
      }

      final semantics = inlineMathSemantics(text);
      if (semantics == null) return null;
      label.write(semantics.label);
      hasMath = hasMath || semantics.hasMath;
    }

    return hasMath ? label.toString() : null;
  }

  /// The gap that separates a block from the one before it.
  static double _spaceAbove(String style) => switch (style) {
        'h1' => 34,
        'h2' => 30,
        'h3' => 24,
        'h4' || 'h5' || 'h6' => 18,
        'blockquote' => 14,
        _ => 5,
      };

  /// The gap below, which stays small on a heading so it stays attached to
  /// the text it introduces.
  static double _spaceBelow(String style) => switch (style) {
        'h1' || 'h2' => 9,
        'h3' || 'h4' || 'h5' || 'h6' => 7,
        'blockquote' => 14,
        _ => 5,
      };

  InlineSpan _inlineMath(String latex, {TextStyle? style}) => inlineMathSpan(
        latex,
        style: style,
        onErrorFallback: (_) =>
            const _UnknownBlockPlaceholder(blockType: 'latex-inline'),
      );

  InlineSpan _buildInlineSpan(
    Map<String, dynamic> child, {
    required TextStyle baseStyle,
  }) {
    final text = child['text'] as String? ?? '';
    final marks = (child['marks'] as List? ?? []).cast<String>();

    TextStyle? style;
    if (marks.contains('strong')) {
      style = const TextStyle(fontWeight: FontWeight.w700);
    }
    if (marks.contains('em')) {
      style =
          (style ?? const TextStyle()).copyWith(fontStyle: FontStyle.italic);
    }
    final decorations = <TextDecoration>[
      if (marks.contains('underline')) TextDecoration.underline,
      if (marks.contains('strike-through')) TextDecoration.lineThrough,
    ];
    if (decorations.isNotEmpty) {
      style = (style ?? const TextStyle())
          .copyWith(decoration: TextDecoration.combine(decorations));
    }

    final effectiveStyle = baseStyle.merge(style);
    if (marks.contains('latex')) {
      return _inlineMath(text, style: effectiveStyle);
    }

    // A span can carry `$…$` without a latex mark: the mark is added when
    // this renderer is handed a plain string, and lesson bodies arrive as
    // blocks that never went through that step. Those dollars reached the
    // screen as dollars.
    return TextSpan(
      children: inlineMathSpans(
        text,
        style: effectiveStyle,
        onErrorFallback: (_) =>
            const _UnknownBlockPlaceholder(blockType: 'latex-inline'),
      ),
      style: style,
    );
  }
}

class _LatexBlockRenderer extends StatelessWidget {
  const _LatexBlockRenderer({required this.block});
  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final text = block['body'] as String? ?? '';
    final rawSemanticsLabel = block['semanticsLabel'];
    final semanticsLabel =
        rawSemanticsLabel is String ? rawSemanticsLabel.trim() : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: AccessibleMath(
          latex: text,
          semanticsLabel: semanticsLabel == null || semanticsLabel.isEmpty
              ? null
              : semanticsLabel,
          onErrorFallback: (_) =>
              const _UnknownBlockPlaceholder(blockType: 'latex'),
        ),
      ),
    );
  }
}

class _ImageBlockRenderer extends StatelessWidget {
  const _ImageBlockRenderer({required this.block});
  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final asset = block['asset'] as Map<String, dynamic>? ?? {};
    final url = asset['url'] as String? ?? '';
    final alt = (block['alt'] as String?)?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: alt == null || alt.isEmpty
          ? ExcludeSemantics(child: _image(context, url))
          : Semantics(
              label: alt,
              image: true,
              excludeSemantics: true,
              child: _image(context, url),
            ),
    );
  }

  Widget _image(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSurface),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(
          height: 200,
          color: context.colors.ruleFaint,
        ),
        errorWidget: (_, __, ___) =>
            const _UnknownBlockPlaceholder(blockType: 'image'),
      ),
    );
  }
}

class _UnknownBlockPlaceholder extends StatelessWidget {
  const _UnknownBlockPlaceholder({required this.blockType});
  final String blockType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.ruleFaint,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSurface),
      ),
      child: Text(
        'Content unavailable. Update the app.',
        style: context.textStyles.bodySmall.copyWith(color: colors.inkMuted),
      ),
    );
  }
}
