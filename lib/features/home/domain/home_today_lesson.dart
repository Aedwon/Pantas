class HomeTodayLesson {
  const HomeTodayLesson({
    required this.id,
    required this.title,
    required this.subject,
    required this.minutes,
    required this.read,
    this.fraction,
    this.advanced = false,
  });
  final String id;
  final String title;
  final String subject;
  final int minutes;
  final bool read;
  final double? fraction;
  final bool advanced;
}
