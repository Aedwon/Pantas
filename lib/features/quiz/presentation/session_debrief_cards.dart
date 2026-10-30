import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/quiz/application/session_debrief_provider.dart';
import 'package:pantas/features/quiz/data/session_diagnosis_api.dart';

class SessionDebriefCards extends StatelessWidget {
  const SessionDebriefCards({
    required this.plan,
    required this.diagnosis,
    required this.pro,
    required this.wide,
    required this.onDismiss,
    required this.onPaywall,
    required this.onLesson,
    required this.onMistakes,
    required this.onRecommendation,
    this.showDiagnosis = true,
    this.paused = false,
    super.key,
  });
  final DebriefPlanData? plan;
  final SessionDiagnosisData? diagnosis;
  final bool pro;
  final bool wide;
  final bool showDiagnosis;
  final bool paused;
  final VoidCallback onDismiss;
  final VoidCallback onPaywall;
  final ValueChanged<String> onLesson;
  final VoidCallback onMistakes;
  final VoidCallback onRecommendation;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final next = plan?.next;
    final count = diagnosis?.tracedCount ?? 0;
    final show = showDiagnosis && !paused && count > 0;
    final detail = pro && show ? diagnosis?.detail : null;
    final traced = _tracedGroups(detail?['traced']);
    final within = _groups(detail?['withinLesson']);
    final free = show && !pro;
    final sections = <Widget>[];
    if (next != null) {
      sections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _heading(context, 'Next'),
            _card([
              _row(
                context,
                onTap: onRecommendation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      next.title,
                      maxLines: wide ? 1 : null,
                      overflow: wide ? TextOverflow.ellipsis : null,
                      style:
                          t.style(17, height: 1.35, spacing: wide ? 0 : -.204),
                    ),
                    Text(
                      next.because,
                      style: t.style(
                        wide ? 14 : 13,
                        height: wide ? 1.4 : 1.35,
                        color: t.colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              if (free) _freeRow(context, count),
            ]),
          ],
        ),
      );
    }

    if (free && next == null) {
      sections.add(_card([_freeRow(context, count)]));
    }

    if (traced.isNotEmpty) {
      sections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _heading(context, 'Where your misses came from', dismiss: true),
            _card(
              [
                for (final group in traced) _traceRow(context, group),
                for (final group in within) _withinRow(context, group),
              ],
              divided: true,
            ),
          ],
        ),
      );
    }
    if (sections.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, section) in sections.indexed) ...[
          if (index > 0) SizedBox(height: wide ? 32 : 22),
          section,
        ],
      ],
    );
  }

  List<Map<String, Object?>> _groups(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final value in raw)
        if (value is Map<String, Object?> &&
            plan?.lessonTitles[value['prerequisite'] ?? value['lesson']] !=
                null &&
            _questions(value).isNotEmpty)
          value,
    ];
  }

  List<Map<String, Object?>> _tracedGroups(Object? raw) {
    final groups = <String, List<Map<String, Object?>>>{};
    for (final group in _groups(raw)) {
      final id = group['prerequisite']! as String;
      (groups[id] ??= []).addAll(_questions(group));
    }
    return [
      for (final entry in groups.entries)
        {
          'prerequisite': entry.key,
          'questions': entry.value
            ..sort(
              (a, b) =>
                  (a['position']! as int).compareTo(b['position']! as int),
            ),
        },
    ];
  }

  List<Map<String, Object?>> _questions(Map<String, Object?> row) {
    final raw = row['questions'];
    if (raw is! List) return const [];
    return [
      for (final q in raw)
        if (q is Map<String, Object?> && q['position'] is int) q,
    ];
  }

  Widget _card(List<Widget> children, {bool divided = false}) {
    final rows = <Widget>[
      for (final (index, child) in children.indexed) ...[
        if (divided && index > 0)
          Builder(
            builder: (context) => Divider(
              height: .5,
              thickness: .5,
              indent: wide ? 62 : 0,
              endIndent: wide ? 20 : 0,
              color: context.webTokens.colors.separator,
            ),
          ),
        child,
      ],
    ];
    return wide
        ? WebCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            ),
          )
        : GroupedSection(children: rows);
  }

  Widget _heading(BuildContext context, String title, {bool dismiss = false}) =>
      Padding(
        padding: EdgeInsets.fromLTRB(wide ? 4 : 16, 0, wide ? 4 : 16, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: wide ? 34 : 30),
              child: Padding(
                padding: EdgeInsets.only(bottom: wide ? 9 : 7),
                child: Semantics(
                  header: true,
                  child: Text(
                    title.toUpperCase(),
                    style: context.webTokens.eb.copyWith(height: 1.35),
                  ),
                ),
              ),
            ),
            if (dismiss)
              Positioned(
                top: wide ? -10 : -12,
                right: wide ? -8 : -14,
                child: _dismiss(context),
              ),
          ],
        ),
      );

  Widget _dismiss(BuildContext context) => SizedBox.square(
        dimension: 44,
        child: IconButton(
          tooltip: 'Dismiss this note',
          onPressed: onDismiss,
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.close,
            size: 16,
            color: context.webTokens.colors.tertiaryLabel,
          ),
        ),
      );

  Widget _row(
    BuildContext context, {
    required Widget child,
    required VoidCallback onTap,
    Widget? leading,
    bool alignTop = false,
  }) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 20 : 16,
            vertical: wide ? 15 : 11,
          ),
          child: Row(
            crossAxisAlignment: alignTop && !wide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading,
                SizedBox(width: wide ? 16 : 12),
              ],
              Expanded(child: child),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: context.webTokens.dark
                    ? const Color(0xFF5C5C5C)
                    : context.webTokens.colors.chevron,
              ),
            ],
          ),
        ),
      );

  Widget _freeRow(BuildContext context, int count) {
    final t = context.webTokens;
    final text = '$count of your misses ${count == 1 ? 'traces' : 'trace'} '
        'to an earlier lesson.';
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.colors.separator, width: .5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label:
                  'PRO. $text See which. Opens the paywall at the diagnosis.',
              excludeSemantics: true,
              onTap: onPaywall,
              child: InkWell(
                onTap: onPaywall,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(wide ? 20 : 16, 12, 0, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: t.dark
                                ? const Color(0xFF3A2E0A)
                                : const Color(0xFFFBF0C8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PRO',
                            style: t.style(
                              11,
                              weight: FontWeight.w700,
                              spacing: .55,
                              color: t.dark
                                  ? const Color(0xFFF2C94C)
                                  : const Color(0xFF7A5B00),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '$text '),
                                TextSpan(
                                  text: wide ? 'See which →' : 'See which',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: t.colors.accent,
                                  ),
                                ),
                              ],
                            ),
                            style: t.style(15, height: wide ? 1.5 : 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _dismiss(context),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _traceRow(BuildContext context, Map<String, Object?> group) {
    final t = context.webTokens;
    final questions = _questions(group);
    final title = plan!.lessonTitles[group['prerequisite']]!;
    return _row(
      context,
      onTap: () => onLesson(group['prerequisite']! as String),
      alignTop: true,
      leading: Container(
        width: 26,
        height: 26,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: t.colors.accentTint),
        child: Icon(
          Icons.north_west,
          size: 14,
          color: t.tintText,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${questions.length} '
            '${questions.length == 1 ? 'traces' : 'trace'} to $title',
            style: t.style(17, height: 1.35),
          ),
          for (final question in questions.take(3))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _number(context, question['position']! as int),
                  const SizedBox(width: 10),
                  if (question['mistake'] case final String note)
                    Expanded(
                      child: Text(
                        firstMistakeSentence(note),
                        style: t.style(
                          14,
                          height: wide ? 1.45 : 1.4,
                          color: t.colors.secondaryLabel,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (questions.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'and ${questions.length - 3} more: '
                '${_questionLabel(questions.skip(3).toList())}',
                style: t.style(13, color: t.colors.tertiaryLabel),
              ),
            ),
        ],
      ),
    );
  }

  Widget _number(BuildContext context, int number) => Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.webTokens.colors.wrongTint,
        ),
        child: Text(
          '$number',
          style: context.webTokens.style(
            12,
            weight: FontWeight.w600,
            color: context.webTokens.colors.wrongText,
          ),
        ),
      );

  String _questionLabel(List<Map<String, Object?>> questions) =>
      '${questions.length == 1 ? 'Question' : 'Questions'} '
      '${questions.map((q) => q['position']).join(', ')}';

  Widget _withinRow(BuildContext context, Map<String, Object?> group) {
    final questions = _questions(group);
    final title = plan!.lessonTitles[group['lesson']]!;
    final t = context.webTokens;
    return _row(
      context,
      onTap: onMistakes,
      leading: Container(
        width: wide ? 26 : 22,
        height: wide ? 26 : 22,
        alignment: Alignment.center,
        decoration: wide
            ? BoxDecoration(
                shape: BoxShape.circle,
                color: t.colors.wrongTint,
              )
            : null,
        child: Icon(Icons.close, size: 16, color: t.colors.wrongText),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${questions.length} ${questions.length == 1 ? 'is' : 'are'} '
            'in $title itself',
            style: t.style(17, height: 1.35),
          ),
          Text(
            _questionLabel(questions),
            style: t.style(
              wide ? 14 : 13,
              height: 1.4,
              color: t.colors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sentence punctuation must end a word, so decimals remain intact.
String firstMistakeSentence(String note) {
  final end = RegExp(r'[.!?](?=\s|$)').firstMatch(note);
  return end == null ? note.trim() : note.substring(0, end.end).trim();
}
