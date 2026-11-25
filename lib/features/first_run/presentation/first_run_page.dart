import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/first_run/application/first_run_data.dart';
import 'package:pantas/features/first_run/application/first_run_providers.dart';
import 'package:pantas/features/first_run/domain/first_run_progress.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_end.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_header.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_intro.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_lesson.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_question.dart';

/// The whole first run on one route, `/try`: intro, lesson, three questions
/// and the end. Nothing here is recorded as study (plan ruling 13): no
/// answer, attempt, schedule, streak or event.
class FirstRunPage extends ConsumerStatefulWidget {
  const FirstRunPage({super.key});

  @override
  ConsumerState<FirstRunPage> createState() => _FirstRunPageState();
}

class _FirstRunPageState extends ConsumerState<FirstRunPage> {
  FirstRunProgress? _progress;

  /// A question shown read only: the learner looked back, or opened a mistake
  /// from the end screen. Null when the live step shows.
  int? _look;
  bool _leaving = false;

  void _update(FirstRunProgress next) {
    setState(() => _progress = next);
    unawaited(ref.read(firstRunStoreProvider).save(next));
  }

  void _go(FirstRunStep step) => _update(_progress!.copyWith(step: step));

  Future<void> _leave() async {
    if (_leaving) return;
    _leaving = true;
    try {
      await ref.read(firstRunFinisherProvider)();
    } finally {
      if (mounted) context.go('/home');
    }
  }

  /// The question the learner is up to: the first not checked, else the last.
  FirstRunStep _questionStep(FirstRunData data) {
    final p = _progress!;
    for (var i = 0; i < data.questions.length; i++) {
      if (!p.checked.contains(data.questions[i].id)) {
        return FirstRunStepQuestion.forQuestion(i);
      }
    }
    return FirstRunStep.question3;
  }

  void _back(FirstRunData? data) {
    final p = _progress!;
    if (_look != null) {
      setState(() => _look = null);
      return;
    }
    switch (p.step) {
      case FirstRunStep.intro:
        break;
      case FirstRunStep.lesson:
        _go(FirstRunStep.intro);
      case FirstRunStep.question1:
        _go(FirstRunStep.lesson);
      case FirstRunStep.question2:
      case FirstRunStep.question3:
        setState(() => _look = p.step.questionIndex! - 1);
      case FirstRunStep.end:
        unawaited(_leave());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(firstRunPendingProvider);
    if (_progress == null) {
      final loaded = pending.valueOrNull;
      if (loaded != null) {
        _progress = loaded;
      } else {
        if (pending.hasValue) {
          // No run is open: Home, where the router sends it too.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/home');
          });
        }
        return Scaffold(backgroundColor: context.colors.bgPage);
      }
    }
    final p = _progress!;
    final dataAsync = p.step == FirstRunStep.intro
        ? null
        : ref.watch(firstRunDataProvider(p.examId));
    final data = dataAsync?.valueOrNull;
    final wide = context.wideWeb;
    return PopScope(
      canPop: p.step == FirstRunStep.intro && _look == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back(data);
      },
      child: Scaffold(
        backgroundColor: context.colors.bgPage,
        body: CallbackShortcuts(
          bindings: wide ? _shortcuts(p, data) : const {},
          child: Focus(
            autofocus: true,
            child: _step(context, p, dataAsync, data),
          ),
        ),
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> _shortcuts(
    FirstRunProgress p,
    FirstRunData? data,
  ) =>
      {
        if (p.step != FirstRunStep.end)
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              unawaited(_leave()),
        const SingleActivator(LogicalKeyboardKey.enter): () {
          switch (p.step) {
            case FirstRunStep.intro:
              _go(FirstRunStep.lesson);
            case FirstRunStep.lesson:
              if (data != null) _go(_questionStep(data));
            case FirstRunStep.question1:
            case FirstRunStep.question2:
            case FirstRunStep.question3:
              if (data != null) _enterOnQuestion(data);
            case FirstRunStep.end:
              unawaited(_leave());
          }
        },
      };

  void _enterOnQuestion(FirstRunData data) {
    final p = _progress!;
    final index = _look ?? p.step.questionIndex!;
    final id = data.questions[index].id;
    if (_look == null && !p.checked.contains(id)) {
      if (p.picks.containsKey(id)) _check(id);
      return;
    }
    _next(data);
  }

  Widget _step(
    BuildContext context,
    FirstRunProgress p,
    AsyncValue<FirstRunData>? dataAsync,
    FirstRunData? data,
  ) {
    if (p.step == FirstRunStep.intro) {
      return FirstRunIntro(
        onStart: () => _go(FirstRunStep.lesson),
        onSkip: () => unawaited(_leave()),
      );
    }
    if (data == null) return _waiting(context, p, dataAsync!);
    switch (p.step) {
      case FirstRunStep.intro:
        return const SizedBox.shrink();
      case FirstRunStep.lesson:
        return FirstRunLesson(
          data: data,
          onSkip: () => unawaited(_leave()),
          onAnswer: () => _go(_questionStep(data)),
        );
      case FirstRunStep.question1:
      case FirstRunStep.question2:
      case FirstRunStep.question3:
      case FirstRunStep.end:
        if (p.step == FirstRunStep.end && _look == null) {
          return FirstRunEnd(
            outcomes: [for (final q in data.questions) _isRight(q.id, data)],
            stems: [for (final q in data.questions) q.stem],
            subjectName: data.subjectName,
            onDone: () => unawaited(_leave()),
            onOpenMistake: (i) => setState(() => _look = i),
          );
        }
        return _question(context, p, data);
    }
  }

  bool _isRight(String questionId, FirstRunData data) {
    final picked = _progress!.picks[questionId];
    final q = data.questions.firstWhere((q) => q.id == questionId);
    return q.choices.any((c) => c.id == picked && c.isCorrect);
  }

  Widget _question(
    BuildContext context,
    FirstRunProgress p,
    FirstRunData data,
  ) {
    final live = p.step.questionIndex;
    final index = _look ?? live!;
    final question = data.questions[index];
    // Anything shown read only was checked before.
    final revealed = _look != null || p.checked.contains(question.id);
    return FirstRunQuestion(
      key: ValueKey('first-run-question-$index-${_look != null}'),
      question: question,
      index: index,
      subject: data.subjectName,
      eyebrow: data.eyebrow,
      lessonTitle: data.lesson.title,
      pickedChoiceId: p.picks[question.id],
      revealed: revealed,
      outcomes: [
        for (final q in data.questions)
          p.checked.contains(q.id) ? _isRight(q.id, data) : null,
      ],
      onPick: (id) => _update(p.copyWith(picks: {...p.picks, question.id: id})),
      onCheck: () => _check(question.id),
      onPrevious: index == 0 ? null : () => setState(() => _look = index - 1),
      onNext: () => _next(data),
      onSkip: () => unawaited(_leave()),
      onFromLesson: () {
        setState(() => _look = null);
        _go(FirstRunStep.lesson);
      },
    );
  }

  void _check(String questionId) {
    final p = _progress!;
    if (!p.picks.containsKey(questionId)) return;
    _update(p.copyWith(checked: {...p.checked, questionId}));
  }

  void _next(FirstRunData data) {
    final p = _progress!;
    final live = p.step.questionIndex;
    final index = _look ?? live ?? 2;
    if (_look != null) {
      final lastLook = live ?? 2;
      if (index >= lastLook) {
        setState(() => _look = null);
      } else {
        setState(() => _look = index + 1);
      }
      return;
    }
    _go(
      index >= 2
          ? FirstRunStep.end
          : FirstRunStepQuestion.forQuestion(index + 1),
    );
  }

  Widget _waiting(
    BuildContext context,
    FirstRunProgress p,
    AsyncValue<FirstRunData> data,
  ) =>
      Column(
        children: [
          FirstRunHeader(onSkip: () => unawaited(_leave())),
          Expanded(
            child: data.hasError
                ? StateView(
                    message: ref.watch(contentLimitReachedProvider)
                        ? contentLimitMessage
                        : 'This needs a connection.',
                    onRetry: () => ref.invalidate(firstRunDataProvider),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
}
