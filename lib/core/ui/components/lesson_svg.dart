import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

bool isLessonSvg(String url) {
  final uri = Uri.tryParse(url);
  return (uri?.path.toLowerCase().endsWith('.svg') ?? false) ||
      (uri?.scheme == 'data' && uri?.data?.mimeType == 'image/svg+xml');
}

/// Resolves SVG fallback lists to the bundled Flutter font family names.
String resolveLessonSvgFonts(String svg) {
  const families = {
    'Geist': 'Geist',
    'KaTeX_Main': 'packages/flutter_math_fork/KaTeX_Main',
    'KaTeX_Math': 'packages/flutter_math_fork/KaTeX_Math',
  };
  return svg.replaceAllMapped(
    RegExp(r'''(?<=\s)font-family\s*=\s*(["'])(.*?)\1'''),
    (match) {
      for (final name in match[2]!.split(',')) {
        final family =
            name.trim().replaceAll(RegExp(r'''^["']|["']$'''), '').trim();
        final resolved = families[family];
        if (resolved != null) {
          return 'font-family=${match[1]}$resolved${match[1]}';
        }
      }
      return match[0]!;
    },
  );
}

mixin _LessonSvgFonts<T> on SvgLoader<T> {
  @override
  String provideSvg(T? message) =>
      resolveLessonSvgFonts(super.provideSvg(message));
}

class _LessonSvgBytesLoader extends SvgBytesLoader with _LessonSvgFonts<void> {
  const _LessonSvgBytesLoader(super.bytes, {super.theme, super.colorMapper});
}

class _LessonSvgNetworkLoader extends SvgNetworkLoader
    with _LessonSvgFonts<Uint8List> {
  const _LessonSvgNetworkLoader(super.url, {super.theme, super.colorMapper});
}

class _LessonSvgAssetLoader extends SvgAssetLoader
    with _LessonSvgFonts<ByteData> {
  const _LessonSvgAssetLoader(
    super.assetName, {
    super.theme,
    super.colorMapper,
  });
}

/// Reserved authoring tokens. See docs/content/lesson-svg-authoring.md.
@immutable
class LessonSvgColors extends ColorMapper {
  const LessonSvgColors(this.colors);
  final PantasColors colors;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) =>
      switch (color.toARGB32()) {
        0xFF010101 => colors.label,
        0xFF020202 => colors.secondaryLabel,
        0xFF030303 => colors.surface,
        0xFF040404 => colors.separator,
        0xFF050505 => colors.accent,
        0xFF060606 => colors.destructive,
        0xFF070707 => colors.warningText,
        _ => color,
      };

  @override
  bool operator ==(Object other) =>
      other is LessonSvgColors && other.colors == colors;
  @override
  int get hashCode => colors.hashCode;
}

// Decoded data-URL bytes by URL, least recently used first. A rebuild or a
// theme change builds a new loader; reusing the same bytes keeps the loaders
// equal when nothing else changed, so flutter_svg does not parse again.
// Bounded so a long lesson cannot hold every figure in memory.
final _dataUrlBytes = <String, Uint8List>{};
const _dataUrlBytesLimit = 16;

/// The bytes a `data:` URL carries, or null when the URL is malformed.
///
/// Content can arrive with a damaged figure URL. Callers show their existing
/// failure state for null instead of throwing while a widget builds.
Uint8List? lessonDataUrlBytes(String url) {
  var bytes = _dataUrlBytes.remove(url);
  if (bytes == null) {
    try {
      bytes = Uri.tryParse(url)?.data?.contentAsBytes();
    } on FormatException {
      return null;
    }
    if (bytes == null) return null;
  }
  _dataUrlBytes[url] = bytes;
  if (_dataUrlBytes.length > _dataUrlBytesLimit) {
    _dataUrlBytes.remove(_dataUrlBytes.keys.first);
  }
  return bytes;
}

BytesLoader lessonSvgLoader(String url, PantasColors colors) {
  final theme = SvgTheme(currentColor: colors.label);
  final mapper = LessonSvgColors(colors);
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme == 'data') {
    // Malformed input gets empty bytes: the SVG parser rejects them and the
    // picture shows its error state. Callers normally check the URL first.
    return _LessonSvgBytesLoader(
      lessonDataUrlBytes(url) ?? Uint8List(0),
      theme: theme,
      colorMapper: mapper,
    );
  }
  if (uri.scheme == 'https' || uri.scheme == 'http') {
    return kIsWeb
        ? _LessonSvgNetworkLoader(url, theme: theme, colorMapper: mapper)
        : _CachedLessonSvgLoader(url, theme: theme, colorMapper: mapper);
  }
  return _LessonSvgAssetLoader(
    url.startsWith('asset:') ? url.substring(6) : url,
    theme: theme,
    colorMapper: mapper,
  );
}

/// Uses the PNG path's disk cache without introducing another cache or package.
class _CachedLessonSvgLoader extends SvgLoader<Uint8List> {
  const _CachedLessonSvgLoader(this.url, {super.theme, super.colorMapper});
  final String url;

  @override
  Future<Uint8List> prepareMessage(BuildContext? context) async {
    final file =
        await CachedNetworkImageProvider.defaultCacheManager.getSingleFile(url);
    return file.readAsBytes();
  }

  @override
  String provideSvg(Uint8List? message) =>
      resolveLessonSvgFonts(utf8.decode(message!));

  @override
  int get hashCode => Object.hash(url, theme, colorMapper);
  @override
  bool operator ==(Object other) =>
      other is _CachedLessonSvgLoader &&
      other.url == url &&
      other.theme == theme &&
      other.colorMapper == colorMapper;
}
