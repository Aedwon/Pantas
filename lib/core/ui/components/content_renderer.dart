import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

// RD_Real's credit is small secondary text.
// Keep its board color visible to review.
const figureCreditColor = Color(0xFF8E8E93);

class ContentRenderer extends StatelessWidget {
  const ContentRenderer({
    this.blocks,
    this.text,
    this.style,
    this.figureBuilder,
    super.key,
  }) : assert(blocks != null || text != null, 'Provide blocks or text.');
  final List<Map<String, Object?>>? blocks;
  final String? text;
  final TextStyle? style;
  final Widget Function(BuildContext, Map<String, Object?>)? figureBuilder;
  static List<Map<String, Object?>> _parseTextToBlocks(String text) {
    final children = <Map<String, Object?>>[];
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
          'This part cannot be shown yet.',
          style: context.type.footnote,
        ),
      );
  Widget paragraph(
    BuildContext context,
    Map<String, Object?> block, {
    String? marker,
  }) {
    final name = string(block['style']);
    final base = style ?? context.type.body.copyWith(height: 1.55);
    final type = switch (name) {
      'h1' => context.type.pageTitle.copyWith(height: 1.15),
      'h2' => context.type.sectionHero
          .copyWith(fontSize: 22, height: 1.25, letterSpacing: -.264),
      'h3' || 'h4' || 'h5' || 'h6' => context.type.emphasized
          .copyWith(fontSize: 18, height: 1.3, letterSpacing: -.216),
      'blockquote' => base.copyWith(fontWeight: FontWeight.w500),
      _ => base,
    };
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
        spans.add(inlineMathSpan(source, style: runStyle));
        final label = inlineMathExpressionSemanticsLabel(source);
        if (label == null) {
          validSpeech = false;
        } else {
          spoken.write(label);
        }
        hasMath = true;
      } else {
        spans.addAll(inlineMathSpans(source, style: runStyle));
        final label = inlineMathSemantics(source);
        if (label == null) {
          validSpeech = false;
        } else {
          spoken.write(label.label);
          hasMath = hasMath || label.hasMath;
        }
      }
    }
    Widget body = Text.rich(TextSpan(children: spans), style: type);
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
            const SizedBox(width: 12),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder(
          horizontalInside:
              BorderSide(color: context.colors.separator, width: .5),
          bottom: BorderSide(color: context.colors.separator, width: .5),
        ),
        children: [
          for (var i = 0; i < rows.length; i++)
            TableRow(
              children: [
                for (final cell in rows[i])
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: MathText(
                      cell,
                      style: context.type.subhead.copyWith(
                        fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
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
        );
      case 'table':
        return table(context, block);
      case 'example':
        return example(context, block);
      case 'figureSpec':
        final spec = block['spec'];
        if (spec is! Map<String, Object?>) return fallback(context);
        final figure =
            figureBuilder?.call(context, spec) ?? FigureRegistry.build(spec);
        if (figure == null) return fallback(context);
        return _FigureFrame(
          figure: figure,
          label: string(block['semanticsLabel']),
          credit: string(block['credit']),
        );
      case 'image':
        final asset = block['asset'];
        final url = asset is Map<String, Object?>
            ? string(asset['url'])
            : string(block['url']);
        if (url.isEmpty) return const _ImageFailure(onRetry: null);
        return _ContentImage(
          url: url,
          label: string(block['alt']),
          credit: string(block['credit']),
        );
      default:
        return fallback(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (blocks == null) {
      return paragraph(context, _parseTextToBlocks(text!).first);
    }
    final children = <Widget>[];
    final counters = <int, int>{};
    for (final block in blocks!) {
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

class _FigureFrame extends StatelessWidget {
  const _FigureFrame({
    required this.figure,
    required this.label,
    required this.credit,
  });
  final Widget figure;
  final String label;
  final String credit;
  Future<void> expand(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.of(context).pop(),
          },
          child: Dialog.fullscreen(
            backgroundColor: Colors.black,
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
                        color: Colors.white,
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
                            color: Colors.white,
                            child: Theme(
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
                          color: Colors.white.withValues(alpha: .6),
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
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                ColoredBox(
                  color: Colors.white,
                  child: Semantics(
                    label: label,
                    image: true,
                    excludeSemantics: true,
                    child: Theme(data: buildLightTheme(), child: figure),
                  ),
                ),
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
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: .5),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          PantasIcons.expandFigure,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (credit.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              credit,
              style: context.type.caption.copyWith(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).brightness == Brightness.light
                    ? figureCreditColor
                    : context.colors.secondaryLabel,
              ),
            ),
          ],
        ],
      );
}

class _ContentImage extends StatefulWidget {
  const _ContentImage({
    required this.url,
    required this.label,
    required this.credit,
  });
  final String url;
  final String label;
  final String credit;
  @override
  State<_ContentImage> createState() => _ContentImageState();
}

class _ContentImageState extends State<_ContentImage> {
  int _retry = 0;
  @override
  Widget build(BuildContext context) => _FigureFrame(
        label: widget.label,
        credit: widget.credit,
        figure: Image.network(
          widget.url,
          key: ValueKey(_retry),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              _ImageFailure(onRetry: () => setState(() => _retry++)),
        ),
      );
}

class _ImageFailure extends StatelessWidget {
  const _ImageFailure({required this.onRetry});
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.fill,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PantasIcons.imageFailed,
              size: 32,
              color: context.colors.chevron,
            ),
            const SizedBox(height: 10),
            Text('Image could not load.', style: context.type.subhead),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: context.type.subheadStrong
                    .copyWith(color: context.colors.accent),
              ),
            ),
          ],
        ),
      );
}
