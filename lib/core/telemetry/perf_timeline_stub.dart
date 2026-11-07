final Stopwatch _sinceStart = Stopwatch()..start();

/// Milliseconds since this isolate began. Native builds have no page.
int nowMs() => _sinceStart.elapsedMilliseconds;

void browserMark(String name) {}

/// The marks the page's own scripts made. None outside the web.
List<(String, int)> pageMarks() => const [];
