import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/ending_reveal.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

class WebEndingLayout extends StatelessWidget {
  const WebEndingLayout({
    required this.ending,
    required this.onLesson,
    required this.onHome,
    this.nextTopic,
    this.nextDetail,
    this.onNext,
    this.held = false,
    super.key,
  });
  final LessonEnding ending;
  final ValueChanged<String> onLesson;
  final VoidCallback onHome;
  final StudyTopic? nextTopic;
  final String? nextDetail;
  final VoidCallback? onNext;

  /// Whether this is an inert preview: its reveals hold at their start.
  final bool held;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    if (ending is DayFinished) {
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(
            LogicalKeyboardKey.enter,
            includeRepeats: false,
          ): onHome,
        },
        child: Focus(
          autofocus: true,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The phone reveals the line 200 ms in, over 600 ms. Here the
                // button comes with it, so it is not alone on the page first.
                EndingReveal(
                  held: held,
                  delay: 200,
                  duration: 600,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: t.colors.accentFill,
                        child: Icon(
                          Icons.check,
                          size: 32,
                          color: t.colors.onAccent,
                        ),
                      ),
                      const SizedBox(height: PantasSpace.s20),
                      Text(
                        'That’s enough for today.',
                        style: t.h1,
                      ),
                      const SizedBox(height: PantasSpace.s20),
                      WebButton(
                        label: 'Back to Home',
                        keyHint: 'Enter',
                        onPressed: onHome,
                      ),
                    ],
                  ),
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
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s40,
              PantasSpace.s28,
              PantasSpace.s40,
              PantasSpace.s56,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The phone reveals the plate 160 ms in, over 500 ms.
                EndingReveal(
                  held: held,
                  delay: 160,
                  duration: 500,
                  child: Container(
                    width: 360,
                    height: 450,
                    padding: const EdgeInsets.symmetric(
                      horizontal: PantasSpace.s28,
                      vertical: PantasSpace.s32,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(PantasRadius.r2xl),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [t.colors.heroStart, t.colors.topicDoneEnd],
                      ),
                      boxShadow: context.shadows.modal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          exam.toUpperCase(),
                          style: PantasType.webEyebrow.copyWith(
                            fontWeight: FontWeight.w700,
                            color: t.colors.onHeroSecondary,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: PantasType.phoneDisplayS.copyWith(
                                color: t.colors.onHero,
                              ),
                            ),
                            const SizedBox(height: PantasSpace.s10),
                            Text(
                              footing,
                              style: PantasType.webLead
                                  .copyWith(color: t.colors.onHero),
                            ),
                          ],
                        ),
                        Text(
                          date,
                          style: PantasType.webRowSub.copyWith(
                            color: t.colors.onHeroSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: PantasSpace.s56),
                Flexible(
                  // The phone reveals the unread list 500 ms in, over 450 ms.
                  child: EndingReveal(
                    held: held,
                    delay: 500,
                    duration: 450,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (unread.isNotEmpty) ...[
                            Text(
                              'STILL UNREAD',
                              style: t.eb.copyWith(height: 22 / 13),
                            ),
                            const SizedBox(height: PantasSpace.s4),
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
                            const SizedBox(height: PantasSpace.s20),
                          ],
                          if (next != null && next.lessons.isNotEmpty)
                            WebReaderNext(
                              label: 'Next topic · ${next.name}',
                              title: next.lessons.first.title,
                              detail: nextDetail,
                              topGap: 0,
                              onPressed: onNext ??
                                  () => onLesson(next.lessons.first.id),
                            ),
                        ],
                      ),
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
