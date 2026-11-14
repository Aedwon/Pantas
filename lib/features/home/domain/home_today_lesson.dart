class HomeTodayLesson {
  const HomeTodayLesson({
    required this.id,
    required this.title,
    required this.subject,
    required this.read,
    this.fraction,
    this.advanced = false,
    this.part,
    this.partCount,
  });
  final String id;
  final String title;
  final String subject;
  final int? part;
  final int? partCount;
  final bool read;
  final double? fraction;
  final bool advanced;
}
