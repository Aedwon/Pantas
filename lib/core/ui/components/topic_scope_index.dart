import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/ink_checkbox.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum TopicScopeCheckState { off, partial, on }

extension TopicScopeCheckStateX on TopicScopeCheckState {
  InkCheckState get asInkCheckState => switch (this) {
        TopicScopeCheckState.off => InkCheckState.off,
        TopicScopeCheckState.partial => InkCheckState.partial,
        TopicScopeCheckState.on => InkCheckState.on,
      };
}

class TopicScopeLessonData {
  const TopicScopeLessonData({
    required this.id,
    required this.title,
    this.isRead = true,
  });

  final String id;
  final String title;
  final bool isRead;
}

class TopicScopeTopicData {
  const TopicScopeTopicData({
    required this.id,
    required this.name,
    this.hasQuestions = true,
    this.lessons = const [],
  });

  final String id;
  final String name;
  final bool hasQuestions;
  final List<TopicScopeLessonData> lessons;

  bool get canUnfold => lessons.isNotEmpty;
}

class TopicScopeSubjectData {
  const TopicScopeSubjectData({
    required this.id,
    required this.name,
    required this.topics,
  });

  final String id;
  final String name;
  final List<TopicScopeTopicData> topics;
}

/// Hierarchical subject and topic index used by both "What's included" in
/// Settings and the Quiz tab's practice picker.
class TopicScopeIndex extends StatelessWidget {
  const TopicScopeIndex({
    required this.subjects,
    required this.topicState,
    required this.onToggleTopic,
    this.subjectState,
    this.onToggleSubject,
    this.lessonState,
    this.onToggleLesson,
    this.unfoldedTopicIds = const {},
    this.onToggleUnfold,
    this.showLessons = false,
    super.key,
  });

  final List<TopicScopeSubjectData> subjects;
  final TopicScopeCheckState Function(TopicScopeTopicData topic) topicState;
  final ValueChanged<TopicScopeTopicData> onToggleTopic;
  final TopicScopeCheckState Function(TopicScopeSubjectData subject)?
      subjectState;
  final ValueChanged<TopicScopeSubjectData>? onToggleSubject;
  final TopicScopeCheckState Function(TopicScopeLessonData lesson)? lessonState;
  final void Function(TopicScopeTopicData topic, TopicScopeLessonData lesson)?
      onToggleLesson;
  final Set<String> unfoldedTopicIds;
  final ValueChanged<String>? onToggleUnfold;
  final bool showLessons;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final subject in subjects) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(
              children: [
                if (onToggleSubject != null) ...[
                  InkCheckbox(
                    state: (subjectState?.call(subject) ??
                            TopicScopeCheckState.off)
                        .asInkCheckState,
                    onTap: () => onToggleSubject?.call(subject),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    subject.name,
                    style:
                        styles.headlineSmall.copyWith(color: colors.inkMuted),
                  ),
                ),
              ],
            ),
          ),
          for (final topic in subject.topics) ...[
            TopicScopeRow(
              topic: topic,
              state: topicState(topic),
              isUnfolded: unfoldedTopicIds.contains(topic.id),
              onToggle: () => onToggleTopic(topic),
              onUnfold: onToggleUnfold != null
                  ? () => onToggleUnfold!(topic.id)
                  : null,
            ),
            if (showLessons && unfoldedTopicIds.contains(topic.id))
              for (final lesson in topic.lessons)
                LessonScopeRow(
                  lesson: lesson,
                  state: lessonState?.call(lesson) ?? TopicScopeCheckState.off,
                  onToggle: () => onToggleLesson?.call(topic, lesson),
                ),
          ],
        ],
      ],
    );
  }
}

class TopicScopeRow extends StatelessWidget {
  const TopicScopeRow({
    required this.topic,
    required this.state,
    required this.onToggle,
    this.isUnfolded = false,
    this.onUnfold,
    super.key,
  });

  final TopicScopeTopicData topic;
  final TopicScopeCheckState state;
  final bool isUnfolded;
  final VoidCallback onToggle;
  final VoidCallback? onUnfold;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.ruleFaint,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: topic.hasQuestions ? onToggle : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    InkCheckbox(
                      state: state.asInkCheckState,
                      enabled: topic.hasQuestions,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        topic.name,
                        style: topic.hasQuestions
                            ? styles.bodyMedium
                            : styles.bodyMedium
                                .copyWith(color: colors.inkMuted),
                      ),
                    ),
                    if (!topic.hasQuestions)
                      Text(
                        'no questions yet',
                        style:
                            styles.bodySmall.copyWith(color: colors.inkMuted),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (topic.canUnfold && onUnfold != null)
            InkWell(
              key: ValueKey('caret_${topic.id}'),
              onTap: onUnfold,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  isUnfolded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: colors.inkMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LessonScopeRow extends StatelessWidget {
  const LessonScopeRow({
    required this.lesson,
    required this.state,
    required this.onToggle,
    super.key,
  });

  final TopicScopeLessonData lesson;
  final TopicScopeCheckState state;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.ruleFaint,
          ),
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              const SizedBox(width: 22),
              InkCheckbox(state: state.asInkCheckState, size: 14),
              const SizedBox(width: 12),
              Expanded(child: Text(lesson.title, style: styles.bodyMedium)),
              if (!lesson.isRead)
                Text(
                  'not read yet',
                  style: styles.bodySmall.copyWith(color: colors.rust),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
