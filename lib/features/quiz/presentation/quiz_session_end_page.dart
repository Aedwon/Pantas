import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/completed_quiz_provider.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_note_boundary.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';
import 'package:pantas/features/quiz/presentation/web_session_results.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_providers.dart';
import 'package:pantas/features/review_prompt/domain/review_eligibility.dart';

class QuizSessionEndPage extends ConsumerStatefulWidget {
  const QuizSessionEndPage({
    required this.attemptId,
    this.sessionOverride,
    this.custom = false,
    this.fresh = false,
    this.all = false,
    this.mistakesOnly = false,
    this.proIsActive,
    super.key,
  });
  final String attemptId;
  final QuizSession? sessionOverride;
  final bool custom;
  final bool fresh;
  final bool all;
  final bool mistakesOnly;
  final bool? proIsActive;
  @override
  ConsumerState<QuizSessionEndPage> createState() => _QuizSessionEndPageState();
}

class _QuizSessionEndPageState extends ConsumerState<QuizSessionEndPage> {
  late final AppDatabase _db;
  late final AuthState? _auth;
  late final String? _uid;
  late final String? _lifetime;
  String? _exam;
  late final Future<QuizNoteBoundary?> _boundary;
  late Future<CompletedQuizData> _future;
  ProviderSubscription<AsyncValue<CompletedQuizData>>? _subscription;
  bool _rated = false;
  CompletedQuizRequest get _request => (
        boundary: _boundary,
        attemptId: widget.attemptId,
        session: widget.sessionOverride,
        attempt: null,
        custom: widget.custom
      );
  @override
  void initState() {
    super.initState();
    _db = ref.read(appDatabaseProvider);
    _auth = ref.read(authStateProvider).unwrapPrevious().asData?.value;
    _uid = switch (_auth) {
      AnonymousAuthState(:final uid) => uid,
      SignedInAuthState(:final user) => user.uid,
      _ => null
    };
    _lifetime = ref.read(todayQuizPreparerProvider).accountLifetimeToken;
    _exam = ref
        .read(activeExamFocusProvider)
        .unwrapPrevious()
        .asData
        ?.value
        .exam
        ?.id;
    _boundary = QuizNoteBoundary.capture(_db, isCurrent: _current);
    _future = _load();
  }

  bool _current() =>
      mounted &&
      _uid != null &&
      _lifetime != null &&
      ref.read(authStateProvider).unwrapPrevious().asData?.value == _auth &&
      identical(ref.read(appDatabaseProvider), _db) &&
      ref.read(todayQuizPreparerProvider).accountLifetimeToken == _lifetime &&
      (_exam == null ||
          ref
                  .read(activeExamFocusProvider)
                  .unwrapPrevious()
                  .asData
                  ?.value
                  .exam
                  ?.id ==
              _exam);
  Future<CompletedQuizData> _load() async {
    final boundary = await _boundary;
    if (boundary == null ||
        !await boundary.allows() ||
        (boundary.ownerUid != null && boundary.ownerUid != _uid)) {
      throw StateError('Completed quiz ownership changed');
    }
    final focus = await ref.read(activeExamFocusProvider.future);
    _exam ??= focus.exam?.id;
    if (_exam == null || !_current()) {
      throw StateError('Completed quiz exam changed');
    }
    _subscription ??=
        ref.listenManual(completedQuizProvider(_request), (_, __) {});
    final data = await ref.read(completedQuizProvider(_request).future);
    if (data.attempt.examId != _exam ||
        data.attempt.completedAt == null ||
        data.attempt.items.isEmpty ||
        !await boundary.allows()) {
      throw StateError('Completed quiz is unavailable');
    }
    if (widget.fresh && !widget.all && !_rated) {
      _rated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_current()) return;
        final (correct, total) = data.attempt.score;
        unawaited(
          ref
              .read(reviewPromptControllerProvider)
              .maybeAsk(
                justFinishedWell: ReviewEligibility.finishedWell(
                  correct: correct,
                  total: total,
                ),
              )
              .catchError((Object _) {}),
        );
      });
    }
    return data;
  }

  void _reload() {
    if (!mounted) return;
    ref.invalidate(completedQuizProvider(_request));
    final future = _load()..ignore();
    setState(() {
      _future = future;
    });
  }

  void _done(CompletedQuizData data) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      if (widget.custom && router.canPop()) router.pop();
    } else {
      router.pushReplacement('/quiz');
    }
  }

  Future<void> _question(int index, {bool notes = false}) async {
    await context.push<void>(
      '/quiz/viewer/${widget.attemptId}?index=$index&notes=$notes&fromAll=${widget.all}',
    );
    _reload();
  }

  Future<void> _all({bool mistakes = false}) async {
    await context
        .push<void>('/quiz/all/${widget.attemptId}?mistakes=$mistakes');
    _reload();
  }

  Widget _list(CompletedQuizData data) {
    final colors = context.colors;
    final (correct, total) = data.attempt.score;
    final indices = [
      for (var i = 0; i < total; i++)
        if (!widget.mistakesOnly || !data.attempt.items[i].isCorrect) i,
    ];
    if (context.wideWeb) {
      void back() {
        if (context.canPop()) {
          context.pop();
        } else {
          context.pushReplacement('/quiz/debrief/${widget.attemptId}');
        }
      }

      return WebQuizQuestionList(
        session: data.session,
        attempt: data.attempt,
        subjectNames: data.subjectNames,
        mistakesOnly: widget.mistakesOnly,
        onBack: back,
        onQuestion: (index) => unawaited(_question(index)),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.pushReplacement('/quiz/debrief/${widget.attemptId}');
                }
              },
              icon: Icon(PantasIcons.back, size: 24),
              label: const Text('Session'),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mistakesOnly ? 'Your mistakes' : 'All questions',
                        style: context.type.pageTitle.copyWith(fontSize: 28),
                      ),
                      Text(
                        '$correct of $total correct',
                        style: context.type.subhead,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GroupedSection(
                  children: [
                    for (final (position, index) in indices.indexed)
                      Builder(
                        builder: (context) {
                          final question = data.session.questions[index];
                          final item = data.attempt.items[index];
                          final title = question.shortLabel ?? question.stem;
                          return ListRow(
                            title: title,
                            titleWidget: question.shortLabel == null
                                ? DefaultTextStyle(
                                    style: context.type.body,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    child: MathText(title),
                                  )
                                : null,
                            subtitle: data.subjectNames[question.topicId],
                            leading: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.isCorrect
                                    ? colors.accentTint
                                    : colors.wrongTint,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: context.type.caption.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: item.isCorrect
                                      ? colors.accent
                                      : colors.wrongText,
                                ),
                              ),
                            ),
                            divider: position < indices.length - 1,
                            onTap: () => unawaited(_question(index)),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..watch(authStateProvider)
      ..watch(activeExamFocusProvider)
      ..watch(appDatabaseProvider);
    final pro = widget.proIsActive ??
        ref.watch(proForActiveExamProvider).unwrapPrevious().asData?.value ??
        false;
    final paused = widget.proIsActive == null &&
        ref.watch(entitlementProvider).valueOrNull?.state ==
            EntitlementState.paused;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: FutureBuilder<CompletedQuizData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError || !_current()) {
            return errorFor('questions', _reload);
          }
          final data = snapshot.data;
          if (data == null) {
            return context.wideWeb
                ? const WebDebriefLoading()
                : loadingFor(const AsyncLoading<void>());
          }
          if (widget.all) return _list(data);
          final misses = [
            for (var i = 0; i < data.attempt.items.length; i++)
              if (!data.attempt.items[i].isCorrect) i,
          ];
          return SessionEndBody(
            session: data.session,
            attempt: data.attempt,
            subjectNames: data.subjectNames,
            sourceLine: data.sourceLine,
            proIsActive: pro,
            proPaused: paused,
            onDone: () => _done(data),
            onQuestion: (index) => unawaited(_question(index)),
            onAll: () => unawaited(_all()),
            onMistakes: () => unawaited(_all(mistakes: true)),
            onNotes: () {
              if (misses.isNotEmpty) {
                unawaited(_question(misses.first, notes: true));
              }
            },
            onNext: data.session.reviewBatch != null &&
                    data.session.reviewBatch!.ordinal <
                        data.session.reviewBatch!.total
                ? () => ref
                    .read(quizControllerProvider.notifier)
                    .continueReviews(data.session)
                : null,
          );
        },
      ),
    );
  }
}
