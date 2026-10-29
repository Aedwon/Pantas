import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

class WebEndingLayout extends StatelessWidget {
  const WebEndingLayout({
    required this.ending,
    required this.onLesson,
    required this.onHome,
    this.nextTopic,
    this.nextDetail,
    this.onNext,
    super.key,
  });
  final LessonEnding ending;
  final ValueChanged<String> onLesson;
  final VoidCallback onHome;
  final StudyTopic? nextTopic;
  final String? nextDetail;
  final VoidCallback? onNext;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    if (ending is DayFinished) {
      return CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.enter): onHome},
        child: Focus(
          autofocus: true,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: t.colors.accentFill,
                  child: const Icon(Icons.check, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 22),
                Text(
                  'That’s enough for today.',
                  style: t.h1,
                ),
                const SizedBox(height: 28),
                WebButton(
                  label: 'Back to Home',
                  keyHint: 'Enter',
                  onPressed: onHome,
                ),
              ],
            ),
          ),
        ),
      );
    }
    final (name, exam, footing, date, unread, next) = switch (ending) {
      TopicFinished(
        :final topicName,
        :final examAndSubject,
        :final footing,
        :final dateLine,
        :final next
      ) =>
        (
          topicName,
          examAndSubject,
          footing,
          dateLine,
          const <StudyLesson>[],
          nextTopic ?? next
        ),
      TopicStoppedShort(
        :final topicName,
        :final examAndSubject,
        :final footing,
        :final dateLine,
        :final unread
      ) =>
        (topicName, examAndSubject, footing, dateLine, unread, nextTopic),
      DayFinished() => throw StateError('Handled above'),
    };
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 30, 40, 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 360,
                  height: 450,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0E8B76), Color(0xFF075C4E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF075C4E).withValues(alpha: .28),
                        blurRadius: 60,
                        offset: const Offset(0, 30),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        exam.toUpperCase(),
                        style: t.style(
                          13,
                          weight: FontWeight.w700,
                          spacing: .78,
                          color: Colors.white.withValues(alpha: .75),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: t.style(
                              44,
                              weight: FontWeight.w700,
                              spacing: -1.32,
                              height: 1.05,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            footing,
                            style: t.style(
                              17,
                              color: Colors.white.withValues(alpha: .9),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        date,
                        style: t.style(
                          14,
                          color: Colors.white.withValues(alpha: .75),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 56),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (unread.isNotEmpty) ...[
                          Text('Still unread', style: t.eb),
                          const SizedBox(height: 9),
                          WebCard(
                            child: Column(
                              children: [
                                for (final lesson in unread)
                                  WebRow(
                                    title: lesson.title,
                                    value: '${lesson.estimatedMinutes} min',
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: t.colors.tertiaryLabel,
                                      size: 16,
                                    ),
                                    onPressed: () => onLesson(lesson.id),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (next != null && next.lessons.isNotEmpty)
                          WebReaderNext(
                            label: 'Next topic · ${next.name}',
                            title: next.lessons.first.title,
                            detail: nextDetail,
                            onPressed:
                                onNext ?? () => onLesson(next.lessons.first.id),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
