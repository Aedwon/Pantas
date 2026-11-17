/// Small standalone checks, deliberately independent of Flutter's TeX renderer.
List<String> checkMarkup(String text) {
  final failures = <String>[];
  bool escaped(int index) {
    var slashes = 0;
    for (var i = index - 1; i >= 0 && text[i] == r'\'; i--) {
      slashes++;
    }
    return slashes.isOdd;
  }

  int? start;
  for (var i = 0; i < text.length; i++) {
    if (text[i] != r'$' || escaped(i)) continue;
    if (start == null) {
      start = i + 1;
    } else {
      failures.addAll(_math(text.substring(start, i)));
      start = null;
    }
  }
  if (start != null) failures.add('unpaired math delimiter');
  return failures;
}

List<String> _math(String span) {
  final failures = <String>[];
  // Each brace records whether it is a numerator or denominator argument.
  final fractionArguments = <bool>[];
  final savedPending = <int>[];
  var pendingArguments = 0;
  for (var i = 0; i < span.length; i++) {
    final char = span[i];
    if (char == r'\') {
      final command = RegExp(r'^\\([A-Za-z]+|.)').firstMatch(span.substring(i));
      if (command == null) continue;
      final name = command.group(1)!;
      if (name == 'frac' || name == 'dfrac') {
        if (name == 'frac' && !fractionArguments.contains(true)) {
          failures.add(r'top-level \frac must use \dfrac');
        }
        pendingArguments = 2;
      }
      i += command.group(0)!.length - 1;
    } else if (char == '{') {
      fractionArguments.add(pendingArguments > 0);
      if (pendingArguments > 0) pendingArguments--;
      savedPending.add(pendingArguments);
      pendingArguments = 0;
    } else if (char == '}') {
      if (fractionArguments.isEmpty) {
        failures.add('unbalanced math braces');
      } else {
        fractionArguments.removeLast();
        pendingArguments = savedPending.removeLast();
      }
    }
  }
  if (fractionArguments.isNotEmpty) failures.add('unbalanced math braces');
  return failures;
}
