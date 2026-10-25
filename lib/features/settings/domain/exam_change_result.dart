class ExamChangeResult {
  const ExamChangeResult({
    required this.examShortName,
    required this.carryableCount,
    required this.routeSettled,
  });
  final String examShortName;
  final int carryableCount;
  final Future<void> routeSettled;
}
