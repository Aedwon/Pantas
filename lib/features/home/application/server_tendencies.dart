import 'dart:math' as math;

import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';

/// Formats only findings the authoritative reader returned. No evidence test
/// or hidden Pro signal runs on the client web path.
HowYouWork serverTendencies(StudyInsights source, {required String? name}) {
  final id = source.profileId;
  final profile = archetypeCatalog.where((a) => a.id == id).firstOrNull;
  final cards = <Tendency>[];
  for (final (key, kind, heading, left, right, _) in [
    (
      'pressure',
      TendencyId.underPressure,
      'Under pressure',
      'practicing',
      'under time',
      'Answer practice questions and finish one full length mock'
    ),
    (
      'speed',
      TendencyId.howYouAnswer,
      'How long you answer',
      'when correct',
      'when wrong',
      'Answer timed questions correctly and incorrectly'
    ),
    (
      'study',
      TendencyId.howYouStudy,
      'How you study',
      'read first',
      'answered first',
      'Read a lesson and answer questions in its topic'
    ),
    (
      'memory',
      TendencyId.howLongYouRemember,
      'How long you remember',
      'memory holds',
      'lapse rate',
      'Review more questions'
    ),
    (
      'stamina',
      TendencyId.stamina,
      'Stamina',
      'first half',
      'second half',
      'Finish one full length mock'
    ),
  ]) {
    final raw = source.tendencies?[key];
    final finding = raw == null ? null : studyMap(raw);
    final confidence = finding == null
        ? TendencyConfidence.early
        : TendencyConfidence.values.byName(studyString(finding['confidence']));
    final value = confidence == TendencyConfidence.clear
        ? studyMap(finding!['value'])
        : null;
    double number(String field) {
      final item = value?[field];
      if (item is! num || !item.isFinite) {
        throw const FormatException('Invalid finding');
      }
      return item.toDouble();
    }

    String percent(String field) => '${(100 * number(field)).round()}%';
    String? a;
    String? b;
    String? sentence;
    String? gap;
    var loss = false;
    if (value != null) {
      switch (kind) {
        case TendencyId.underPressure:
          a = percent('practiceAccuracy');
          b = percent('mockAccuracy');
          loss = number('mockAccuracy') < number('practiceAccuracy');
          sentence = loss
              ? 'Your accuracy drops under exam pressure.'
              : 'Your accuracy rises under exam pressure.';
        case TendencyId.stamina:
          a = percent('firstHalfAccuracy');
          b = percent('secondHalfAccuracy');
          loss = number('secondHalfAccuracy') < number('firstHalfAccuracy');
          sentence = loss
              ? 'Your accuracy drops in the second half of a mock.'
              : 'Your accuracy rises in the second half of a mock.';
        case TendencyId.howYouStudy:
          final read = number('readThenQuizCount');
          final answered = number('quizFirstCount');
          if (read + answered <= 0) {
            throw const FormatException('Missing study observations');
          }
          final share = (100 * read / (read + answered)).round();
          a = '$share%';
          b = '${100 - share}%';
          sentence = read > answered
              ? 'You usually read the lesson first.'
              : 'You usually go straight to the questions.';
        case TendencyId.howYouAnswer:
          final correct = math.exp(number('correctLogMean')) / 1000;
          final wrong = math.exp(number('incorrectLogMean')) / 1000;
          a = '${correct.round()}s';
          b = '${wrong.round()}s';
          loss = wrong > correct;
          final diff = (wrong - correct).abs();
          gap =
              '${diff.round() == 0 ? diff.toStringAsFixed(1) : diff.round()}s';
          sentence = loss
              ? 'You take longer on questions you get wrong.'
              : 'You answer faster on questions you get wrong.';
        case TendencyId.howLongYouRemember:
          a = '${number('averageStability').round()}d';
          b = percent('lapseRate');
          sentence =
              'You retain information for days before needing to refresh.';
      }
    }
    cards.add(
      Tendency(
        id: kind,
        heading: heading,
        leftLabel: left,
        rightLabel: right,
        gap: gap,
        leftFigure: a,
        rightFigure: b,
        sentence: sentence,
        isLoss: loss,
        unlockAction: _unmetCopy(key, finding),
        confidence: confidence,
      ),
    );
  }
  final hours = source.whenYouWork;
  String hour(int h) => h == 0
      ? '12 am'
      : h == 12
          ? '12 pm'
          : h < 12
              ? '$h am'
              : '${h - 12} pm';
  return HowYouWork(
    name: name,
    archetype: profile?.label,
    archetypeLine: profile == null ? null : archetypeIdentityLine(profile.id),
    tendencies: cards,
    whenYouWork: hours == null
        ? const []
        : [
            (
              title: 'Peak hour',
              subtext: '',
              meta: hour(studyWhole(hours['peakHour']))
            ),
            (
              title: 'Average session',
              subtext: '',
              meta: '${(hours['averageMinutes']! as num).round()} min'
            ),
            (
              title: 'Total sessions',
              subtext: '',
              meta: '${studyWhole(hours['sessionCount'])}'
            ),
          ],
  );
}

String _unmetCopy(String key, Map<String, Object?>? finding) {
  final requirements = finding?['unmetRequirements'];
  if (requirements is! List || requirements.isEmpty) return '';
  final missing = requirements.cast<String>().toSet();
  return switch (key) {
    'pressure' => missing.contains('practice') && missing.contains('mock')
        ? 'Answer practice questions and finish one full length mock'
        : missing.contains('practice')
            ? 'Answer practice questions'
            : 'Finish one full length mock',
    'speed' => missing.contains('correct') && missing.contains('incorrect')
        ? 'Answer timed questions correctly and incorrectly'
        : missing.contains('correct')
            ? 'Answer timed questions correctly'
            : 'Answer timed questions incorrectly',
    'study' => missing.contains('lesson') && missing.contains('practice')
        ? 'Read a lesson and answer questions in its topic'
        : missing.contains('practice')
            ? 'Answer questions in a topic you have read'
            : missing.contains('lesson')
                ? 'Read a lesson in a topic you have practiced'
                : 'Read a lesson and answer questions in its topic',
    'stamina' => 'Finish one full length mock',
    'memory' => 'Review more questions',
    _ => '',
  };
}
