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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) _dispatch(context, block),
      ],
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
  const _BlockRenderer({required this.block});

  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final style = block['style'] as String? ?? 'normal';
    final children =
        (block['children'] as List? ?? []).cast<Map<String, dynamic>>();
    final textStyles = context.textStyles;

    final TextStyle baseStyle = switch (style) {
      'h1' => textStyles.displayLarge,
      'h2' => textStyles.displaySmall,
      'h3' => textStyles.headlineMedium,
      'h4' || 'h5' || 'h6' => textStyles.headlineSmall,
      'blockquote' =>
        textStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic),
      _ => textStyles.bodyMedium,
    };

    final hasLatex = children.any((child) {
      final marks = (child['marks'] as List? ?? []);
      return marks.contains('latex');
    });

    if (hasLatex) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text.rich(
          TextSpan(
            children: [
              for (final child in children) _buildInlineSpan(child, baseStyle),
            ],
          ),
        ),
      );
    }

    final text = children.map((c) => c['text'] as String? ?? '').join();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: baseStyle),
    );
  }

  InlineSpan _buildInlineSpan(
    Map<String, dynamic> child,
    TextStyle base,
  ) {
    final text = child['text'] as String? ?? '';
    final marks = (child['marks'] as List? ?? []).cast<String>();

    if (marks.contains('latex')) {
      return WidgetSpan(
        child: Math.tex(
          text,
          mathStyle: MathStyle.text,
          onErrorFallback: (_) =>
              _UnknownBlockPlaceholder(blockType: 'latex-inline'),
        ),
      );
    }

    return TextSpan(text: text, style: base);
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
          mathStyle: MathStyle.display,
          onErrorFallback: (_) => _UnknownBlockPlaceholder(blockType: 'latex'),
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
              _UnknownBlockPlaceholder(blockType: 'image'),
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
