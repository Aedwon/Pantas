/// The phone reader's topic eyebrow: upper case, without a parenthetical
/// aside, so the longest topic ("Spatial & Abstract (Non-Verbal) Reasoning")
/// fits one caps line on a 360 px phone. The full name stays everywhere else
/// and is what screen readers hear. Never an ellipsis: larger text wraps.
/// UX ruling, Fable 5.2, Nov 23 (docs/superpowers/decisions/
/// 2026-11-17-fable-backlog-rulings.md, "Nov 23, CSE release UX council").
String readerEyebrowText(String topicName) {
  final short = topicName
      .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return (short.isEmpty ? topicName : short).toUpperCase();
}
