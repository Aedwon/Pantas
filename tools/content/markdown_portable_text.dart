import 'dart:convert';

import 'lesson_asset_map.dart';

/// Converts a lesson Markdown body into Portable Text blocks.
///
/// Handles headings, paragraphs, lists, blockquotes, display and inline LaTeX,
/// Markdown tables, and structured `<!-- FIGURE: ... -->` and
/// `<!-- ILLUSTRATION: ... -->` markers.
///
/// Throws [FormatException] with lesson path and line number when:
/// - A `FIGURE` marker contains invalid JSON or is not a JSON object.
/// - An `ILLUSTRATION` marker has no entry in [assets].
/// - A Markdown table contains mismatched column counts or an invalid
///   delimiter.
List<Map<String, Object?>> markdownToPortableText(
  String body, {
  required LessonIdentity lesson,
  required LessonAssetMap assets,
}) {
  final blocks = <Map<String, Object?>>[];
  final paragraph = <String>[];
  final quote = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(_textBlock(paragraph.join(' '), 'normal'));
    paragraph.clear();
  }

  void flushQuote() {
    if (quote.isEmpty) return;
    blocks.add(_textBlock(quote.join(' '), 'blockquote'));
    quote.clear();
  }

  void flushAll() {
    flushParagraph();
    flushQuote();
  }

  final heading = RegExp(r'^(#{1,6})\s+(.*)$');
  final bullet = RegExp(r'^(\s*)[-*+]\s+(.*)$');
  final numbered = RegExp(r'^(\s*)\d+\.\s+(.*)$');
  final displayMath = RegExp(r'^\$\$(.*)\$\$$');
  final figureRegex = RegExp(r'<!--\s*FIGURE:\s*(.*?)\s*-->', dotAll: true);
  final illustrationRegex =
      RegExp(r'<!--\s*ILLUSTRATION:\s*(.*?)\s*-->', dotAll: true);
  final delimiterPattern = RegExp(r'^\s*:?-+:?\s*$');

  var illustrationSeq = 0;
  final lines = body.split('\n');

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final lineNumber = i + 1;
    final trimmed = line.trim();

    if (trimmed.isEmpty) {
      flushAll();
      i++;
      continue;
    }

    // Check FIGURE marker
    final figureMatch = figureRegex.firstMatch(trimmed);
    if (figureMatch != null) {
      flushAll();
      final rawJson = figureMatch.group(1)!.trim();
      final Object? decoded;
      try {
        decoded = jsonDecode(rawJson);
      } catch (e) {
        throw FormatException(
          'Invalid FIGURE JSON at ${lesson.path}:$lineNumber: $e',
        );
      }
      if (decoded is! Map) {
        throw FormatException(
          'Invalid FIGURE JSON at ${lesson.path}:$lineNumber: '
          'expected JSON object',
        );
      }
      final jsonMap = decoded.cast<String, Object?>();
      final String semanticsLabel;
      final Map<String, Object?> spec;
      if (jsonMap.containsKey('spec') && jsonMap['spec'] is Map) {
        spec = (jsonMap['spec']! as Map).cast<String, Object?>();
        semanticsLabel = (jsonMap['semanticsLabel'] as String?) ?? '';
      } else {
        semanticsLabel = (jsonMap['semanticsLabel'] as String?) ?? '';
        spec = Map<String, Object?>.from(jsonMap)..remove('semanticsLabel');
      }
      blocks.add({
        '_type': 'figureSpec',
        'spec': spec,
        'semanticsLabel': semanticsLabel,
      });
      i++;
      continue;
    }

    // Check ILLUSTRATION marker
    final illusMatch = illustrationRegex.firstMatch(trimmed);
    if (illusMatch != null) {
      flushAll();
      illustrationSeq++;
      final entry = assets.lookup(lesson, illustrationSeq);
      if (entry == null) {
        throw FormatException(
          'Missing asset-map entry for '
          '"${lesson.assetKey(illustrationSeq)}" at ${lesson.path}:$lineNumber',
        );
      }
      final desc = illusMatch.group(1)!.trim();
      blocks.add({
        '_type': 'image',
        'asset': {
          'url': entry.url,
        },
        'alt': entry.alt.isNotEmpty ? entry.alt : desc,
      });
      i++;
      continue;
    }

    // Other HTML comments are ignored placeholders or authoring notes
    if (trimmed.startsWith('<!--')) {
      flushAll();
      i++;
      continue;
    }

    // Display math
    final math = displayMath.firstMatch(trimmed);
    if (math != null) {
      flushAll();
      blocks.add({'_type': 'latex', 'body': math.group(1)!.trim()});
      i++;
      continue;
    }

    // Headings
    final headingMatch = heading.firstMatch(trimmed);
    if (headingMatch != null) {
      flushAll();
      blocks.add(
        _textBlock(headingMatch.group(2)!, 'h${headingMatch.group(1)!.length}'),
      );
      i++;
      continue;
    }

    // Blockquote
    if (trimmed.startsWith('>')) {
      flushParagraph();
      quote.add(trimmed.replaceFirst(RegExp(r'^>\s*'), ''));
      i++;
      continue;
    }

    // Bullet list items
    final bulletMatch = bullet.firstMatch(line);
    if (bulletMatch != null) {
      flushAll();
      blocks.add(
        _textBlock(bulletMatch.group(2)!, 'normal')
          ..['listItem'] = 'bullet'
          ..['level'] = _indentLevel(bulletMatch.group(1)!),
      );
      i++;
      continue;
    }

    // Numbered list items
    final numberedMatch = numbered.firstMatch(line);
    if (numberedMatch != null) {
      flushAll();
      blocks.add(
        _textBlock(numberedMatch.group(2)!, 'normal')
          ..['listItem'] = 'number'
          ..['level'] = _indentLevel(numberedMatch.group(1)!),
      );
      i++;
      continue;
    }

    // Markdown tables
    if (trimmed.startsWith('|')) {
      flushAll();
      final headerCells = _parseTableRow(trimmed);
      if (headerCells.isEmpty) {
        throw FormatException(
          'Malformed Markdown table header at ${lesson.path}:$lineNumber',
        );
      }
      final columnCount = headerCells.length;

      // Delimiter row must immediately follow
      if (i + 1 >= lines.length) {
        throw FormatException(
          'Missing Markdown table delimiter row at ${lesson.path}:$lineNumber',
        );
      }
      final delimiterLine = lines[i + 1].trim();
      if (!delimiterLine.startsWith('|')) {
        throw FormatException(
          'Malformed Markdown table delimiter at '
          '${lesson.path}:${lineNumber + 1}',
        );
      }
      final delimiterCells = _parseTableRow(delimiterLine);
      if (delimiterCells.length != columnCount ||
          !delimiterCells.every(delimiterPattern.hasMatch)) {
        throw FormatException(
          'Malformed Markdown table delimiter at '
          '${lesson.path}:${lineNumber + 1}',
        );
      }

      final rows = <List<String>>[headerCells];
      var nextRowIdx = i + 2;
      while (nextRowIdx < lines.length &&
          lines[nextRowIdx].trim().startsWith('|')) {
        final rowLine = lines[nextRowIdx].trim();
        final rowLineNumber = nextRowIdx + 1;
        final dataCells = _parseTableRow(rowLine);
        if (dataCells.length != columnCount) {
          throw FormatException(
            'Malformed Markdown table row at ${lesson.path}:$rowLineNumber: '
            'expected $columnCount columns, got ${dataCells.length}',
          );
        }
        rows.add(dataCells);
        nextRowIdx++;
      }

      blocks.add({
        '_type': 'table',
        'rows': rows,
      });
      i = nextRowIdx;
      continue;
    }

    // Standard paragraph text
    flushQuote();
    paragraph.add(trimmed);
    i++;
  }

  flushAll();
  return blocks;
}

List<String> _parseTableRow(String line) {
  var content = line.trim();
  if (content.startsWith('|')) {
    content = content.substring(1);
  }
  if (content.endsWith('|')) {
    content = content.substring(0, content.length - 1);
  }
  return content.split('|').map((cell) => cell.trim()).toList();
}

int _indentLevel(String indent) => indent.length ~/ 2 + 1;

Map<String, Object?> _textBlock(String text, String style) => {
      '_type': 'block',
      'style': style,
      'children': _inlineSpans(text),
    };

final _inline = RegExp(r'\$([^$]+)\$|\*\*(.+?)\*\*|\*(.+?)\*');

List<Map<String, Object?>> _inlineSpans(String text) {
  final spans = <Map<String, Object?>>[];
  var cursor = 0;

  void addPlain(String value) {
    if (value.isEmpty) return;
    spans.add({'_type': 'span', 'text': value, 'marks': <String>[]});
  }

  for (final match in _inline.allMatches(text)) {
    addPlain(text.substring(cursor, match.start));
    final (value, mark) = switch (match) {
      _ when match.group(1) != null => (match.group(1)!, 'latex'),
      _ when match.group(2) != null => (match.group(2)!, 'strong'),
      _ => (match.group(3)!, 'em'),
    };
    spans.add({
      '_type': 'span',
      'text': mark == 'latex' ? value.trim() : value,
      'marks': [mark],
    });
    cursor = match.end;
  }
  addPlain(text.substring(cursor));

  if (spans.isEmpty) addPlain('');
  return spans;
}
