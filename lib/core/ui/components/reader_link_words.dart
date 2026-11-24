/// Which words of a passage name a part of the figure beside it, as plain
/// text rules (spec "Linked words"). No content is added: the words come from
/// the figure's own labels.
library;

/// The part of a figure label that a lesson would write about: the text
/// before " = " or ":", without "Center " or "Point ".
String labelCore(String label) {
  var core = label.split(RegExp(r' = |:')).first.trim();
  for (final prefix in ['Center ', 'Point ']) {
    if (core.startsWith(prefix)) core = core.substring(prefix.length).trim();
  }
  return core;
}

/// One linked word: a stretch of one run of text.
class LinkMatch {
  const LinkMatch({
    required this.run,
    required this.start,
    required this.end,
    required this.label,
  });

  /// Which run of the paragraph, and which characters of it.
  final int run;
  final int start;
  final int end;

  /// The label's core, which names the part.
  final String label;
}

/// Math written the way a name is: `\overline{AB}` reads as AB.
String _mathName(String math) => math
    .replaceAllMapped(
      RegExp(r'\\(?:overline|overrightarrow|widehat)\{([^}]*)\}'),
      (m) => m.group(1)!,
    )
    .replaceAll(RegExp(r'\\(angle|triangle|text|mathrm)\b'), '')
    .replaceAll(RegExp(r'[\s{}\\,]'), '');

/// The links of one paragraph, given its [runs] and the label [cores] of the
/// figure beside it. A label of two letters or fewer matches math that says
/// exactly that; a longer one matches a whole bold word, in any case. Each
/// label links its first mention only.
List<LinkMatch> findLinks(
  List<Map<String, Object?>> runs,
  Iterable<String> labels,
) {
  final out = <LinkMatch>[];
  final used = <String>{};
  for (final raw in labels) {
    final core = labelCore(raw);
    if (core.isEmpty || used.contains(core.toLowerCase())) continue;
    if (!RegExp('[A-Za-z]').hasMatch(core)) continue;
    final short = core.length <= 2;
    for (var i = 0; i < runs.length; i++) {
      final text = runs[i]['text'];
      final marks = runs[i]['marks'];
      if (text is! String || marks is! List<Object?>) continue;
      if (short) {
        if (marks.contains('latex') && _mathName(text) == core) {
          out.add(LinkMatch(run: i, start: 0, end: text.length, label: core));
          used.add(core.toLowerCase());
          break;
        }
      } else if (marks.contains('strong') && !marks.contains('latex')) {
        final found = RegExp(
          '(?<![A-Za-z0-9])${RegExp.escape(core)}(?![A-Za-z0-9])',
          caseSensitive: false,
        ).firstMatch(text);
        if (found != null) {
          out.add(
            LinkMatch(
              run: i,
              start: found.start,
              end: found.end,
              label: core,
            ),
          );
          used.add(core.toLowerCase());
          break;
        }
      }
    }
  }
  return out;
}
