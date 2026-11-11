String formatMockRemaining(Duration remaining) {
  final seconds = remaining.inSeconds.clamp(0, 1 << 31);
  final hours = seconds ~/ 3600;
  final minutes = (seconds ~/ 60) % 60;
  final secs = seconds % 60;
  return '${hours > 0 ? '$hours:' : ''}'
      '${minutes.toString().padLeft(2, '0')}:'
      '${secs.toString().padLeft(2, '0')}';
}
