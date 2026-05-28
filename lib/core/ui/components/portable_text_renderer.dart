import 'package:cached_network_image/cached_network_image.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class PortableTextRenderer extends StatelessWidget {
  const PortableTextRenderer({required this.blocks, super.key});

  final List<Map<String, dynamic>> blocks;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    // Numbered-list counters per indent level. Any non-list block ends the
    // list, so counters reset; a deeper level resets counters below it.
    final numberCounters = <int, int>{};
    for (final block in blocks) {
      final listItem =
          block['_type'] == 'block' ? block['listItem'] as String? : null;
      if (listItem == null) {
        numberCounters.clear();
        children.add(_dispatch(context, block));
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
      children.add(_BlockRenderer(block: block, marker: marker, level: level));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _dispatch(BuildContext context, Map<String, dynamic> block) {
    final type = block['_type'] as String? ?? '';
    return switch (type) {
      'block' => _BlockRenderer(block: block),
      'latex' => _LatexBlockRenderer(block: block),
      'image' => _ImageBlockRenderer(block: block),
      _ => _UnknownBlockPlaceholder(blockType: type),
    };
  }
}

class _BlockRenderer extends StatelessWidget {
  const _BlockRenderer({required this.block, this.marker, this.level = 1});

  final Map<String, dynamic> block;

  /// List marker ("•" or "3.") when this block is a list item.
  final String? marker;

  /// List indent level (1-based); only meaningful when [marker] is set.
  final int level;

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

    final indent =
        marker == null ? 0.0 : 12.0 + 16.0 * (level - 1).clamp(0, 4);

    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4, left: indent),
      child: Text.rich(
        TextSpan(
          children: [
            if (marker != null) TextSpan(text: '$marker  '),
            for (final child in children) _buildInlineSpan(child),
          ],
        ),
        style: baseStyle,
      ),
    );
  }

  InlineSpan _buildInlineSpan(Map<String, dynamic> child) {
    final text = child['text'] as String? ?? '';
    final marks = (child['marks'] as List? ?? []).cast<String>();

    if (marks.contains('latex')) {
      return WidgetSpan(
        child: Math.tex(
          text,
          mathStyle: MathStyle.text,
          onErrorFallback: (_) =>
              const _UnknownBlockPlaceholder(blockType: 'latex-inline'),
        ),
      );
    }

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
    return TextSpan(text: text, style: style);
  }
}

class _LatexBlockRenderer extends StatelessWidget {
  const _LatexBlockRenderer({required this.block});
  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final text = block['body'] as String? ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Math.tex(
          text,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => const SkeletonBox(height: 200),
          errorWidget: (_, __, ___) =>
              const _UnknownBlockPlaceholder(blockType: 'image'),
        ),
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
        color: colors.border,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Text(
        'Content unavailable — update the app',
        style:
            context.textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
      ),
    );
  }
}
