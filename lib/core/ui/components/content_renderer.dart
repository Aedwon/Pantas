import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/components/lesson_svg.dart';
import 'package:pantas/core/ui/components/math_support.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
      return paragraph(context, _parseTextToBlocks(text!).first);
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
                  ColoredBox(
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
                              shape: BoxShape.circle,
                              color:
                                  context.colors.shadow.withValues(alpha: .5),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              PantasIcons.expandFigure,
                              size: 16,
                              color: context.colors.onFigureViewer,
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
                fontSize: reader ? 11 : null,
                fontWeight: FontWeight.w400,
                color: context.colors.secondaryLabel,
              ),
            ),
          ],
        ],
      );
}

class _FigureViewer extends StatelessWidget {
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
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
        },
        child: Material(
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
                      minScale: 1,
                      maxScale: 5,
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
                if (credit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
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
              ],
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
