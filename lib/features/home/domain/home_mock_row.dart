/// The mock row Home leads with on a mock day. The duration comes from the
/// exam's stored blueprint, never from a constant.
class HomeMockRow {
  const HomeMockRow({required this.subtitle, this.duration});

  factory HomeMockRow.fromBlueprint({
    required String examShortName,
    required int durationMinutes,
  }) =>
      HomeMockRow(
        subtitle: '$examShortName simulation',
        duration: formatMockDuration(durationMinutes),
      );

  final String subtitle;
  final String? duration;
}

/// "2 hr 45 min", "3 hr", "45 min".
String formatMockDuration(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return '$rest min';
  if (rest == 0) return '$hours hr';
  return '$hours hr $rest min';
}
