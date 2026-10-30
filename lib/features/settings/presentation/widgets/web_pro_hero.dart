import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

class WebProHero extends StatelessWidget {
  const WebProHero({required this.heading, this.detail, super.key});
  final String heading;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final headingColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PANTAS PRO',
          style: t.sm.copyWith(
            color: t.colors.accent,
            fontWeight: FontWeight.w700,
            letterSpacing: .52,
          ),
        ),
        const SizedBox(height: 8),
        Text(heading, style: t.h2),
        if (detail != null) ...[
          const SizedBox(height: 8),
          Text(detail!, style: t.sub),
        ],
      ],
    );
    final features = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final feature in [
          (PantasIcons.unlimitedMocks, 'Unlimited mock exams'),
          (PantasIcons.answerNotes, 'Notes on why your answer was wrong'),
          (PantasIcons.studyHabits, 'The figures behind your study habits'),
          (PantasIcons.proBackup, "Progress that's always backed up"),
          (PantasIcons.topicResults, 'Results by topic and lesson'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(feature.$1, size: 20, color: t.colors.accent),
                const SizedBox(width: 10),
                Expanded(child: Text(feature.$2, style: t.style(16))),
              ],
            ),
          ),
      ],
    );
    return Container(
      key: const ValueKey('pro-hero'),
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: t.dark ? Border.all(color: t.cardEdge) : null,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.colors.surface, t.colors.surface, t.colors.accentTint],
          stops: const [0, .55, 1],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 544) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [headingColumn, const SizedBox(height: 24), features],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headingColumn),
              const SizedBox(width: 24),
              Expanded(child: features),
            ],
          );
        },
      ),
    );
  }
}
