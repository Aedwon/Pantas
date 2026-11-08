// ignore_for_file: cascade_invocations
//
// Reads design/system/tokens.json (and the recipe table in motion.md) and
// writes the Dart token classes into lib/core/ui/theme/tokens/.
//
//   dart run tool/design_system/generate_tokens.dart          write the files
//   dart run tool/design_system/generate_tokens.dart --check  exit 1 on drift
//
// Naming follows design/system/tools/flutter_names.py: strip the family
// prefix, lowerCamelCase, a leading digit takes the family letter, a Dart
// reserved word or Object member takes the family noun as a suffix.
import 'dart:convert';
import 'dart:io';

const _outDir = 'lib/core/ui/theme/tokens';
const _header = '''
// GENERATED, do not edit.
// Source: design/system/tokens.json
// Generator: tool/design_system/generate_tokens.dart
// Regenerate: dart run tool/design_system/generate_tokens.dart
''';

const _reserved = <String>{
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', //
  'default', 'do', 'else', 'enum', 'extends', 'false', 'final', 'finally',
  'for', 'if', 'in', 'is', 'new', 'null', 'rethrow', 'return', 'super',
  'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while', 'with',
  'abstract', 'as', 'covariant', 'deferred', 'dynamic', 'export',
  'extension', 'external', 'factory', 'Function', 'get', 'implements',
  'import', 'interface', 'late', 'library', 'mixin', 'operator', 'part',
  'required', 'set', 'static', 'typedef', 'await', 'yield',
  // Object members and ThemeExtension members.
  'hashCode', 'runtimeType', 'toString', 'noSuchMethod', 'copyWith', 'lerp',
  'type',
};

class _Family {
  const _Family(this.key, this.cls, this.prefix, this.letter, this.suffix);
  final String key;
  final String cls;
  final String prefix;
  final String letter;
  final String suffix;
}

const _spacing = _Family('spacing', 'PantasSpace', 'space-', 's', 'Space');
const _radius = _Family('radius', 'PantasRadius', 'radius-', 'r', 'Radius');
const _shadow = _Family('shadow', 'PantasShadow', 'elev-', 'e', 'Shadow');
const _border = _Family('border', 'PantasBorder', 'border-', 'b', 'Border');
const _layout = _Family('layout', 'PantasLayout', 'layout-', 'l', 'Layout');
const _size = _Family('size', 'PantasSize', 'size-', 'z', 'Size');
const _easing = _Family('easing', 'PantasCurves', 'motion-', 'm', 'Curve');
const _duration =
    _Family('duration', 'PantasDurations', 'dur-', 'd', 'Duration');
const _zIndex = _Family('zIndex', 'PantasZ', 'z-', 'z', 'Z');
const _opacity =
    _Family('opacity', 'PantasOpacity', 'opacity-', 'o', 'Opacity');
const _color = _Family('color', 'PantasColors', '', 'c', 'Color');

String _camel(String n) => n.replaceAllMapped(
      RegExp('-([a-z0-9])'),
      (m) => m.group(1)!.toUpperCase(),
    );

String _field(_Family f, String tokenName) {
  var n = tokenName;
  if (f.prefix.isNotEmpty && n.startsWith(f.prefix)) {
    n = n.substring(f.prefix.length);
  }
  var out = _camel(n);
  if (RegExp('^[0-9]').hasMatch(out)) out = f.letter + out;
  if (_reserved.contains(out)) out = out + f.suffix;
  return out;
}

String _fmt(num v) {
  final r = double.parse(v.toStringAsFixed(4));
  if (r == r.roundToDouble()) return r.round().toString();
  return r.toString();
}

/// Parses a CSS length: px, rem (x16) or a bare number.
double _length(String v) {
  final s = v.trim();
  if (s.endsWith('rem')) return double.parse(s.substring(0, s.length - 3)) * 16;
  if (s.endsWith('px')) return double.parse(s.substring(0, s.length - 2));
  return double.parse(s);
}

String _doc(String text, {String indent = '  '}) {
  final words = text.replaceAll(RegExp(r'\s+'), ' ').trim().split(' ');
  final lines = <String>[];
  var line = '';
  for (final w in words) {
    if (line.isNotEmpty && line.length + w.length + 1 > 70) {
      lines.add(line);
      line = w;
    } else {
      line = line.isEmpty ? w : '$line $w';
    }
  }
  if (line.isNotEmpty) lines.add(line);
  return lines.map((l) => '$indent/// $l').join('\n');
}

String _hexColor(String hex) {
  final h = hex.replaceFirst('#', '').toUpperCase();
  if (h.length == 6) return 'Color(0xFF$h)';
  if (h.length == 8) return 'Color(0x${h.substring(6)}${h.substring(0, 6)})';
  throw FormatException('bad color $hex');
}

String _rgbaColor(String rgba) {
  final m =
      RegExp(r'rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)')
          .firstMatch(rgba)!;
  final r = int.parse(m.group(1)!);
  final g = int.parse(m.group(2)!);
  final b = int.parse(m.group(3)!);
  final a = (double.parse(m.group(4)!) * 255).round();
  String two(int x) => x.toRadixString(16).padLeft(2, '0').toUpperCase();
  return 'Color(0x${two(a)}${two(r)}${two(g)}${two(b)})';
}

class _Gen {
  _Gen(this.tokens, this.motion);
  final Map<String, dynamic> tokens;
  final String motion;
  final files = <String, String>{};

  List<Map<String, dynamic>> _list(String key) =>
      ((tokens[key] as Map<String, dynamic>)['tokens'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

  String _usage(Map<String, dynamic> t) => (t['usage'] as String?) ?? '';

  void run() {
    _colors();
    _type();
    _doubles(_spacing, 'Spacing scale (logical px).');
    _radii();
    _shadows();
    _doubles(_border, 'Ring and hairline widths (logical px).');
    _layouts();
    _doubles(_size, 'Component sizes (logical px, rem x 16).');
    _curves();
    _durations();
    _ints();
    _doubles(_opacity, 'Opacity values.');
    _recipes();
  }

  void _put(String file, String body) {
    files['$file.dart'] = '$_header\n$body';
  }

  // ---- colors -----------------------------------------------------------

  void _colors() {
    final list = _list('color');
    final prims = <String, String>{};
    final roles = <String, Map<String, String>>{};
    for (final t in list) {
      final v = t['value'];
      if (v is String) {
        prims[t['name'] as String] = v;
      } else {
        roles[t['name'] as String] = (v as Map<String, dynamic>).cast();
      }
    }
    String primField(String n) => _field(_color, n);

    String resolve(String name, String theme) {
      var v = roles[name]![theme]!;
      while (v.startsWith('{')) {
        final ref = v.substring(1, v.length - 1);
        if (prims.containsKey(ref)) return primField(ref);
        v = roles[ref]![theme]!;
      }
      return _hexColor(v);
    }

    final b = StringBuffer()
      ..writeln("import 'package:flutter/material.dart';")
      ..writeln()
      ..writeln('/// Every color role of the design system, light and dark.')
      ..writeln('///')
      ..writeln('/// Roles are instance fields: read them from the theme with')
      ..writeln('/// `context.colors`. Primitives are static constants for the')
      ..writeln('/// generator and tests only; components use roles.')
      ..writeln('@immutable')
      ..writeln('class PantasColors extends ThemeExtension<PantasColors> {')
      ..writeln('  const PantasColors({');
    for (final n in roles.keys) {
      b.writeln('    required this.${_field(_color, n)},');
    }
    b.writeln('  });');
    b.writeln();
    for (final t in list) {
      final n = t['name'] as String;
      if (prims.containsKey(n)) continue;
      b
        ..writeln(_doc(_usage(t)))
        ..writeln('  final Color ${_field(_color, n)};');
    }
    b.writeln();
    for (final n in prims.keys) {
      b.writeln(
        '  static const ${primField(n)} = ${_hexColor(prims[n]!)};',
      );
    }
    for (final theme in ['light', 'dark']) {
      b
        ..writeln()
        ..writeln('  static const $theme = PantasColors(');
      for (final n in roles.keys) {
        b.writeln('    ${_field(_color, n)}: ${resolve(n, theme)},');
      }
      b.writeln('  );');
    }
    b
      ..writeln()
      ..writeln('  @override')
      ..writeln('  PantasColors copyWith({');
    for (final n in roles.keys) {
      b.writeln('    Color? ${_field(_color, n)},');
    }
    b.writeln('  }) =>');
    b.writeln('      PantasColors(');
    for (final n in roles.keys) {
      final f = _field(_color, n);
      b.writeln('        $f: $f ?? this.$f,');
    }
    b
      ..writeln('      );')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  PantasColors lerp(ThemeExtension<PantasColors>? other, '
          'double t) {')
      ..writeln('    if (other is! PantasColors) return this;')
      ..writeln('    return PantasColors(');
    for (final n in roles.keys) {
      final f = _field(_color, n);
      b.writeln('      $f: Color.lerp($f, other.$f, t)!,');
    }
    b
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}');
    _put('pantas_colors', b.toString());
  }

  // ---- type -------------------------------------------------------------

  void _type() {
    final type = tokens['type'] as Map<String, dynamic>;
    final b = StringBuffer()
      ..writeln("import 'package:flutter/material.dart';")
      ..writeln()
      ..writeln('/// Every text style of the design system. Sizes are rem x 16')
      ..writeln(
        '/// logical px; letter spacing is em x size. No color: apply it',
      )
      ..writeln('/// at the use site with `copyWith(color: ...)`.')
      ..writeln('abstract final class PantasType {');
    for (final g
        in (type['groups'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      for (final s
          in (g['styles'] as List<dynamic>).cast<Map<String, dynamic>>()) {
        final name = s['name'] as String;
        final sizeRaw = s['fontSize'] as String;
        // `em` sizes (math-display) are relative to the 18px reader body.
        final size = sizeRaw.endsWith('rem')
            ? _length(sizeRaw)
            : double.parse(sizeRaw.substring(0, sizeRaw.length - 2)) * 18;
        final serif = s['family'] == 'serif';
        final fam = serif ? 'Source Serif 4' : 'Geist';
        final w = s['fontWeight'];
        final h = s['lineHeight'];
        final ls = s['letterSpacing'] as String?;
        final tabular =
            _usage(s).contains('abular') || name.startsWith('phone-display');
        b
          ..writeln(_doc('${_usage(s)} (${_fmt(size)}/$w)'))
          ..writeln('  static const ${_camel(name)} = TextStyle(')
          ..writeln("    fontFamily: '$fam',")
          ..writeln('    fontSize: ${_fmt(size)},')
          ..writeln('    fontWeight: FontWeight.w$w,')
          ..writeln('    height: ${_fmt(h as num)},');
        if (ls != null) {
          final em = double.parse(ls.substring(0, ls.length - 2));
          b.writeln('    letterSpacing: ${_fmt(em * size)},');
        }
        if (tabular) {
          b.writeln('    fontFeatures: [FontFeature.tabularFigures()],');
        }
        b.writeln('  );');
      }
    }
    b.writeln('}');
    _put('pantas_type', b.toString());
  }

  // ---- plain scales -----------------------------------------------------

  void _doubles(_Family f, String summary) {
    final b = StringBuffer()
      ..writeln('/// $summary')
      ..writeln('abstract final class ${f.cls} {');
    for (final t in _list(f.key)) {
      final raw = (t['value'] as String).trim();
      final v = _length(raw);
      final isDouble = f.key != 'zIndex';
      final doc = raw.endsWith('rem')
          ? '${_usage(t)} ($raw: scale by the text scaler at the use site.)'
          : _usage(t);
      b
        ..writeln(_doc(doc))
        ..writeln(
          '  static const ${isDouble ? 'double ' : ''}'
          '${_field(f, t['name'] as String)} = ${_fmt(v)};',
        );
    }
    b.writeln('}');
    _put(_fileOf(f.cls), b.toString());
  }

  String _fileOf(String cls) {
    final snake = cls.replaceAllMapped(
      RegExp('(?<=[a-z])[A-Z]'),
      (m) => '_${m.group(0)}',
    );
    return snake.toLowerCase();
  }

  void _ints() {
    final b = StringBuffer()
      ..writeln('/// Paint order of overlays (z-index).')
      ..writeln('abstract final class ${_zIndex.cls} {');
    for (final t in _list('zIndex')) {
      b
        ..writeln(_doc(_usage(t)))
        ..writeln(
          '  static const int ${_field(_zIndex, t['name'] as String)} = '
          '${int.parse((t['value'] as String).trim())};',
        );
    }
    b.writeln('}');
    _put('pantas_z', b.toString());
  }

  void _radii() {
    final b = StringBuffer()
      ..writeln("import 'package:flutter/painting.dart';")
      ..writeln()
      ..writeln('/// Corner radii (logical px). `full` is a pill or a circle.')
      ..writeln('abstract final class PantasRadius {');
    for (final t in _list('radius')) {
      b
        ..writeln(_doc(_usage(t)))
        ..writeln(
          '  static const double ${_field(_radius, t['name'] as String)} = '
          '${_fmt(_length(t['value'] as String))};',
        );
    }
    b
      ..writeln()
      ..writeln('  /// `radius-full` as a shape.')
      ..writeln('  static const StadiumBorder fullShape = StadiumBorder();')
      ..writeln('}');
    _put('pantas_radius', b.toString());
  }

  // ---- layout -----------------------------------------------------------

  void _layouts() {
    final b = StringBuffer()
      ..writeln('/// A CSS flex triple: grow, shrink and basis (logical px).')
      ..writeln('///')
      ..writeln(
        '/// The shell lays these out like CSS flex-wrap: place items at',
      )
      ..writeln('/// their basis, wrap when they no longer fit, then share the')
      ..writeln('/// free space by `grow`.')
      ..writeln('class PantasFlex {')
      ..writeln('  const PantasFlex(this.grow, this.shrink, this.basis);')
      ..writeln()
      ..writeln('  final double grow;')
      ..writeln('  final double shrink;')
      ..writeln('  final double basis;')
      ..writeln('}')
      ..writeln()
      ..writeln('/// Page, column, bar and breakpoint measures.')
      ..writeln('abstract final class PantasLayout {');
    for (final t in _list('layout')) {
      final raw = (t['value'] as String).trim();
      final parts = raw.split(RegExp(r'\s+'));
      final f = _field(_layout, t['name'] as String);
      b.writeln(_doc(_usage(t)));
      if (parts.length == 3) {
        b.writeln(
          '  static const $f = PantasFlex('
          '${_fmt(double.parse(parts[0]))}, ${_fmt(double.parse(parts[1]))}, '
          '${_fmt(_length(parts[2]))});',
        );
      } else {
        b.writeln('  static const double $f = ${_fmt(_length(raw))};');
      }
    }
    b.writeln('}');
    _put('pantas_layout', b.toString());
  }

  // ---- shadows ----------------------------------------------------------

  List<String> _splitTop(String s) {
    final out = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '(') depth++;
      if (c == ')') depth--;
      if (c == ',' && depth == 0) {
        out.add(s.substring(start, i).trim());
        start = i + 1;
      }
    }
    out.add(s.substring(start).trim());
    return out;
  }

  String _boxShadow(String part) {
    final m =
        RegExp(r'(rgba\([^)]*\)|#[0-9A-Fa-f]{6,8})\s*$').firstMatch(part)!;
    final color = m.group(1)!;
    final nums = part
        .substring(0, m.start)
        .trim()
        .split(RegExp(r'\s+'))
        .map(_length)
        .toList();
    final c = color.startsWith('#') ? _hexColor(color) : _rgbaColor(color);
    final args = <String>['color: $c'];
    if (nums[0] != 0 || nums[1] != 0) {
      args.add('offset: Offset(${_fmt(nums[0])}, ${_fmt(nums[1])})');
    }
    if (nums[2] != 0) args.add('blurRadius: ${_fmt(nums[2])}');
    if (nums.length > 3 && nums[3] != 0) {
      args.add('spreadRadius: ${_fmt(nums[3])}');
    }
    return 'BoxShadow(${args.join(', ')},)';
  }

  void _shadows() {
    final list = _list('shadow');
    final b = StringBuffer()
      ..writeln("import 'package:flutter/material.dart';")
      ..writeln()
      ..writeln(
        '/// Elevation shadows per theme. Rings are borders, not shadows.',
      )
      ..writeln('@immutable')
      ..writeln('class PantasShadow extends ThemeExtension<PantasShadow> {')
      ..writeln('  const PantasShadow({');
    for (final t in list) {
      b.writeln('    required this.${_field(_shadow, t['name'] as String)},');
    }
    b
      ..writeln('  });')
      ..writeln();
    for (final t in list) {
      b
        ..writeln(_doc(_usage(t)))
        ..writeln(
          '  final List<BoxShadow> ${_field(_shadow, t['name'] as String)};',
        );
    }
    for (final theme in ['light', 'dark']) {
      b
        ..writeln()
        ..writeln('  static const $theme = PantasShadow(');
      for (final t in list) {
        final v = (t['value'] as Map<String, dynamic>)[theme] as String;
        final parts = _splitTop(v).map(_boxShadow).join(', ');
        b.writeln('    ${_field(_shadow, t['name'] as String)}: [$parts,],');
      }
      b.writeln('  );');
    }
    b
      ..writeln()
      ..writeln('  @override')
      ..writeln('  PantasShadow copyWith({');
    for (final t in list) {
      b.writeln(
        '    List<BoxShadow>? ${_field(_shadow, t['name'] as String)},',
      );
    }
    b
      ..writeln('  }) =>')
      ..writeln('      PantasShadow(');
    for (final t in list) {
      final f = _field(_shadow, t['name'] as String);
      b.writeln('        $f: $f ?? this.$f,');
    }
    b
      ..writeln('      );')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  PantasShadow lerp(ThemeExtension<PantasShadow>? other, '
          'double t) {')
      ..writeln('    if (other is! PantasShadow) return this;')
      ..writeln('    return PantasShadow(');
    for (final t in list) {
      final f = _field(_shadow, t['name'] as String);
      b.writeln('      $f: BoxShadow.lerpList($f, other.$f, t)!,');
    }
    b
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}');
    _put('pantas_shadow', b.toString());
  }

  // ---- motion -----------------------------------------------------------

  String _cubic(String a) {
    final nums = a
        .replaceAll(RegExp(r'[()\s]'), '')
        .split(',')
        .map((e) => _fmt(double.parse(e)))
        .join(', ');
    return 'Cubic($nums)';
  }

  void _curves() {
    final b = StringBuffer()
      ..writeln("import 'package:flutter/animation.dart';")
      ..writeln()
      ..writeln('/// Easing curves by role.')
      ..writeln('abstract final class PantasCurves {');
    for (final t in _list('easing')) {
      final v = (t['value'] as String).trim();
      final f = _field(_easing, t['name'] as String);
      b.writeln(_doc(_usage(t)));
      if (v == 'linear') {
        b.writeln('  static const Curve $f = Curves.linear;');
      } else {
        final inner = v.substring('cubic-bezier'.length);
        b.writeln('  static const $f = ${_cubic(inner)};');
      }
    }
    b.writeln('}');
    _put('pantas_curves', b.toString());
  }

  int _ms(String v) {
    final s = v.trim();
    if (s == '0') return 0;
    if (s.endsWith('ms')) return int.parse(s.substring(0, s.length - 2));
    if (s.endsWith('s')) {
      return (double.parse(s.substring(0, s.length - 1)) * 1000).round();
    }
    throw FormatException('bad duration $v');
  }

  void _durations() {
    final b = StringBuffer()
      ..writeln('/// Durations by role.')
      ..writeln('abstract final class PantasDurations {');
    for (final t in _list('duration')) {
      b
        ..writeln(_doc(_usage(t)))
        ..writeln(
          '  static const ${_field(_duration, t['name'] as String)} = '
          'Duration(milliseconds: ${_ms(t['value'] as String)});',
        );
    }
    b.writeln('}');
    _put('pantas_durations', b.toString());
  }

  void _recipes() {
    final m = RegExp(r'### Recipe values.*?\n(\|.*?)\n\n', dotAll: true)
        .firstMatch(motion)!;
    final rows = m.group(1)!.split('\n').skip(2);
    String? tokenField(String raw) {
      final t = RegExp('`((?:dur|motion)-[a-z0-9-]+)`').firstMatch(raw);
      if (t == null) return null;
      final name = t.group(1)!;
      return name.startsWith('dur-')
          ? 'PantasDurations.${_field(_duration, name)}'
          : 'PantasCurves.${_field(_easing, name)}';
    }

    String duration(String raw) {
      final tf = tokenField(raw);
      if (tf != null) return tf;
      final ms = _ms(raw.replaceAll('`', ''));
      return ms == 0 ? 'Duration.zero' : 'Duration(milliseconds: $ms)';
    }

    String curve(String raw) {
      final tf = tokenField(raw);
      if (tf != null) return tf;
      final p = RegExp(r'\(([^)]*)\)').firstMatch(raw)!;
      return _cubic(p.group(1)!);
    }

    final b = StringBuffer()
      ..writeln("import 'package:flutter/animation.dart';")
      ..writeln(
        "import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';",
      )
      ..writeln(
        "import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';",
      )
      ..writeln()
      ..writeln('/// Duration, delay and curve of one named motion recipe.')
      ..writeln('class PantasMotionRecipe {')
      ..writeln('  const PantasMotionRecipe({')
      ..writeln('    required this.duration,')
      ..writeln('    required this.delay,')
      ..writeln('    required this.curve,')
      ..writeln('  });')
      ..writeln()
      ..writeln('  final Duration duration;')
      ..writeln('  final Duration delay;')
      ..writeln('  final Curve curve;')
      ..writeln('}')
      ..writeln()
      ..writeln('/// Recipe values from design/system/motion.md.')
      ..writeln('abstract final class PantasMotionRecipes {');
    for (final row in rows) {
      final cells = row.split('|').map((e) => e.trim()).toList();
      // cells: '', recipe, selector, duration, delay, curve, field, ''
      final field = cells[6].replaceAll('`', '');
      b
        ..writeln(_doc(cells[1]))
        ..writeln('  static const $field = PantasMotionRecipe(')
        ..writeln('    duration: ${duration(cells[3])},')
        ..writeln('    delay: ${duration(cells[4])},')
        ..writeln('    curve: ${curve(cells[5])},')
        ..writeln('  );');
    }
    b.writeln('}');
    _put('pantas_motion_recipes', b.toString());
  }
}

Future<Map<String, String>> generate(Directory root) async {
  final tokens = jsonDecode(
    File('${root.path}/design/system/tokens.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final motion =
      File('${root.path}/design/system/motion.md').readAsStringSync();
  final gen = _Gen(tokens, motion)..run();
  // Format with the project's own dart format so the output is stable.
  final tmp = Directory('${root.path}/.dart_tool/design_tokens_gen')
    ..createSync(recursive: true);
  final paths = <String>[];
  for (final e in gen.files.entries) {
    final f = File('${tmp.path}/${e.key}')..writeAsStringSync(e.value);
    paths.add(f.path);
  }
  final r = await Process.run(
    Platform.resolvedExecutable,
    ['format', ...paths],
    workingDirectory: root.path,
  );
  if (r.exitCode != 0) {
    stderr.writeln('dart format failed:\n${r.stdout}\n${r.stderr}');
    exit(2);
  }
  final out = <String, String>{};
  for (final e in gen.files.keys) {
    out[e] = File('${tmp.path}/$e').readAsStringSync();
  }
  tmp.deleteSync(recursive: true);
  return out;
}

Future<void> main(List<String> args) async {
  final root = Directory.current;
  if (!File('${root.path}/design/system/tokens.json').existsSync()) {
    stderr.writeln('Run from the repository root.');
    exit(2);
  }
  final check = args.contains('--check');
  final out = await generate(root);
  final dir = Directory('${root.path}/$_outDir');
  var drift = false;
  if (check) {
    final existing = dir.existsSync()
        ? dir.listSync().whereType<File>().map((f) => f.uri.pathSegments.last)
        : <String>[];
    for (final name in {...existing, ...out.keys}) {
      final f = File('${dir.path}/$name');
      final want = out[name];
      if (want == null) {
        stderr.writeln('Unexpected file: $_outDir/$name');
        drift = true;
      } else if (!f.existsSync() || f.readAsStringSync() != want) {
        stderr.writeln('Out of date: $_outDir/$name');
        drift = true;
      }
    }
    if (drift) {
      stderr.writeln(
        'Run: dart run tool/design_system/generate_tokens.dart',
      );
      exit(1);
    }
    stdout.writeln('Design tokens are up to date (${out.length} files).');
    return;
  }
  dir.createSync(recursive: true);
  for (final f in dir.listSync().whereType<File>()) {
    if (!out.containsKey(f.uri.pathSegments.last)) f.deleteSync();
  }
  for (final e in out.entries) {
    File('${dir.path}/${e.key}').writeAsStringSync(e.value);
  }
  stdout.writeln('Wrote ${out.length} files to $_outDir.');
}
