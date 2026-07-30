import 'package:pantas/features/lesson/domain/models/study_map.dart';

sealed class LessonEnding {
  const LessonEnding();
}

final class TopicFinished extends LessonEnding {
  const TopicFinished({
    required this.studentName,
    required this.topicName,
    required this.examAndSubject,
    required this.footing,
    required this.dateLine,
    required this.next,
  });

  final String? studentName;
  final String topicName;
  final String examAndSubject;
  final String footing;
  final String dateLine;
  final StudyTopic? next;

  String? get nextTopicMeta {
    if (next == null) return null;
    return formatNextTopicMeta(next!);
  }
}

final class TopicStoppedShort extends LessonEnding {
  const TopicStoppedShort({
    required this.studentName,
    required this.topicName,
    required this.examAndSubject,
    required this.footing,
    required this.dateLine,
    required this.unread,
  });

  final String? studentName;
  final String topicName;
  final String examAndSubject;
  final String footing;
  final String dateLine;
  final List<StudyLesson> unread;
}

final class DayFinished extends LessonEnding {
  const DayFinished();
}

String formatNextTopicMeta(StudyTopic topic) {
  final count = topic.lessons.length;
  final lessonWord = count == 1 ? 'lesson' : 'lessons';
  final countSegment = count <= 10 && _numberToWord(count) != null
      ? '${_numberToWord(count)} $lessonWord'
      : (count == 1 ? '1 lesson' : '$count lessons');

  final totalMinutes = topic.lessons.fold<int>(
    0,
    (sum, l) => sum + l.estimatedMinutes,
  );

  final durationSegment = _formatDurationOfMaterial(totalMinutes);

  return '$countSegment, $durationSegment.';
}

String? _numberToWord(int n) {
  return switch (n) {
    1 => 'One',
    2 => 'Two',
    3 => 'Three',
    4 => 'Four',
    5 => 'Five',
    6 => 'Six',
    7 => 'Seven',
    8 => 'Eight',
    9 => 'Nine',
    10 => 'Ten',
    _ => null,
  };
}

String _formatDurationOfMaterial(int totalMinutes) {
  if (totalMinutes < 60) {
    if (totalMinutes == 1) {
      return 'about 1 minute of material';
    }
    return 'about $totalMinutes minutes of material';
  }

  final hours = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;

  if (mins == 0) {
    if (hours == 1) {
      return 'about an hour of material';
    }
    return 'about $hours hours of material';
  }

  final hourPhrase = hours == 1 ? 'an hour' : '$hours hours';
  final minPhrase = _minutesToWords(mins);

  return 'about $hourPhrase and $minPhrase of material';
}

String _minutesToWords(int mins) {
  final map = {
    5: 'five',
    10: 'ten',
    15: 'fifteen',
    20: 'twenty',
    25: 'twenty-five',
    30: 'thirty',
    35: 'thirty-five',
    40: 'forty',
    45: 'forty-five',
    50: 'fifty',
    55: 'fifty-five',
  };
  if (map.containsKey(mins)) {
    return map[mins]!;
  }
  return '$mins minutes';
}
