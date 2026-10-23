import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/presentation/widgets/ending_content.dart';
import 'package:pantas/features/lesson/presentation/widgets/lesson_contents_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/pull_to_advance.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_gap.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_rail.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';

/// The reader.
///
/// **Advancing to the next lesson is not a navigation.** It used to push a
/// route, which meant the page transition carried the bar and the rail with
/// it: one `< Study` slid out while an identical one slid in. Both describe
/// the reader rather than the lesson, so both stay still and only the body
/// travels, in the direction the pull went.
class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({
    required this.lessonId,
    this.origin = ReaderOrigin.study,
    this.resume = false,
    this.dayContext,
    this.initialEnding = false,
    super.key,
  });

  final LessonId lessonId;
  final ReaderOrigin origin;
  final LessonDayContext? dayContext;
  final bool resume;
  final bool initialEnding;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  late LessonId _lessonId = widget.lessonId;

  /// The last lesson that actually loaded.
  ///
  /// Held so an advance never falls back to the loading skeleton. That
  /// skeleton replaces the whole body, chrome included, so a swap flashed the
  /// bar and the rail out and back: *"the entire app still has a moment of
  /// loading sort of"*. The reader keeps showing what it has until the next
  /// lesson is ready, and the body is off screen while it waits, so there is
  /// nothing to see and nothing to flash.
  ReaderContext? _shown;
  LessonEnding? _ending;
  bool _initialEndingShown = false;
  ({LessonId id, Object? error})? _selectionFailure;
  int _navigationEpoch = 0;
  int _pullEpoch = 0;
  bool _actorKnown = false;
  String? _lastActor;
  bool _examKnown = false;
  String? _lastExam;

  LessonId? _warmedId;
  ProviderSubscription<Object?>? _warm;

  ReaderBoundary? _boundary;
  bool _captureAlive = true;
  bool _boundaryAlive = true;
  bool _captureFailed = false;
  StreamSubscription<Object?>? _boundaryChanges;
  final _lifetimeSubscriptions = <ProviderSubscription<Object?>>[];

  String? _actor(AuthState? state) => switch (state) {
        AnonymousAuthState(:final uid) => 'anonymous:$uid',
        SignedInAuthState(:final user) => 'signed:${user.uid}',
        _ => null,
      };

  @override
  void initState() {
    super.initState();
    _lifetimeSubscriptions
      ..add(
        ref.listenManual<AsyncValue<AuthState>>(
          authStateProvider,
          (_, after) {
            if (!after.hasValue) return;
            final actor = _actor(after.valueOrNull);
            if (_actorKnown && actor != _lastActor) _expire();
            _actorKnown = true;
            _lastActor = actor;
          },
          fireImmediately: true,
        ),
      )
      ..add(
        ref.listenManual<AsyncValue<ActiveExamFocus>>(
          activeExamFocusProvider,
          (_, after) {
            if (!after.hasValue) return;
            final exam = after.requireValue.exam?.id;
            if (_examKnown && exam != _lastExam) _expire();
            _examKnown = true;
            _lastExam = exam;
          },
          fireImmediately: true,
        ),
      );
    _boundaryChanges = ref
        .read(appDatabaseProvider)
        .tableUpdates(
          TableUpdateQuery.onTable(ref.read(appDatabaseProvider).syncMeta),
        )
        .listen((updates) {
      if (_boundary == null) {
        _expire();
        return;
      }
      final boundary = _boundary;
      if (boundary != null && _boundaryAlive) {
        unawaited(_validateBoundary(boundary));
      }
    });
    unawaited(_captureInitial());
  }

  Future<void> _captureInitial() async {
    final positions = ref.read(readerPositionRepositoryProvider);
    final tokenFuture =
        positions.captureToken(isCurrent: () => mounted && _captureAlive);
    final actor = ref.read(authStateProvider.future);
    final focusFuture = ref.read(activeExamFocusProvider.future);
    try {
      final token = await tokenFuture;
      await actor;
      if (!mounted || !_captureAlive || token == null) return;
      final focus = await focusFuture;
      if (!mounted || !_captureAlive) return;
      final exam = focus.exam?.id;
      if (exam == null) return _expire();
      final boundary = ReaderBoundary(examId: exam, token: token);
      final valid = await positions.isBoundaryCurrent(
        boundary,
        isCurrent: () => mounted && _captureAlive,
      );
      if (!mounted || !_captureAlive) return;
      if (!valid) return _expire();
      ref.invalidate(readerContextProvider(_lessonId));
      setState(() => _boundary = boundary);
    } on Exception {
      if (mounted) _expire();
    }
  }

  Future<bool> _checkBoundary(
    ReaderBoundary boundary, {
    required bool Function() isCurrent,
  }) async {
    if (!mounted || !isCurrent()) return false;
    final positions = ref.read(readerPositionRepositoryProvider);
    try {
      return await positions.isBoundaryCurrent(boundary, isCurrent: isCurrent);
    } catch (_) {
      // An unreadable boundary cannot authorize a handoff or retained preview.
      return false;
    }
  }

  Future<void> _validateBoundary(ReaderBoundary boundary) async {
    final current =
        await _checkBoundary(boundary, isCurrent: () => _boundaryAlive);
    if (!current && mounted) _expire();
  }

  void _expire() {
    _captureAlive = false;
    _boundaryAlive = false;
    _warm?.close();
    _warm = null;
    _shown = null;
    _selectionFailure = null;
    _navigationEpoch++;
    if (mounted) setState(() => _captureFailed = true);
  }

  @override
  void didUpdateWidget(covariant LessonPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new route for the same page, so follow it.
    if (oldWidget.lessonId != widget.lessonId) {
      _navigationEpoch++;
      _pullEpoch = -1;
      _warm?.close();
      _warm = null;
      _warmedId = null;
      _selectionFailure = null;
      _ending = null;
      _initialEndingShown = false;
      _lessonId = widget.lessonId;
      _shown = null;
    }
  }

  @override
  void dispose() {
    _captureAlive = false;
    _warm?.close();
    unawaited(_boundaryChanges?.cancel());
    for (final subscription in _lifetimeSubscriptions) {
      subscription.close();
    }
    super.dispose();
  }

  LessonDayContext? _dayContextFor(LessonId id) {
    final day = widget.dayContext;
    if (day == null) return null;
    final index = day.lessonIds.indexOf(id);
    if (index < 0) return null;
    return LessonDayContext(
      date: day.date,
      lessonIds: day.lessonIds,
      index: index,
    );
  }

  Future<void> _showSelectionFailure(
    LessonId id,
    Object? error,
    int epoch,
  ) async {
    final boundary = _boundary;
    if (boundary == null || !_boundaryAlive || epoch != _navigationEpoch) {
      return;
    }
    final valid = await _checkBoundary(
      boundary,
      isCurrent: () => _boundaryAlive && epoch == _navigationEpoch,
    );
    if (!mounted || epoch != _navigationEpoch) return;
    if (!valid) return _expire();
    setState(() => _selectionFailure = (id: id, error: error));
  }

  Future<void> _advanceTo(LessonId next, {bool retry = false}) async {
    final epoch = ++_navigationEpoch;
    if (!mounted || !_boundaryAlive) return;
    if (retry) ref.invalidate(readerContextProvider(next));
    try {
      final target = await ref.read(readerContextProvider(next).future);
      if (!mounted || !_boundaryAlive || epoch != _navigationEpoch) return;
      if (target == null) {
        await _showSelectionFailure(next, null, epoch);
        return;
      }
      if (target.boundary?.token != _boundary?.token ||
          target.examId != _boundary?.examId) {
        return _expire();
      }
      await _activate(target, epoch: epoch);
    } catch (error) {
      if (mounted && _boundaryAlive && epoch == _navigationEpoch) {
        await _showSelectionFailure(next, error, epoch);
      }
    }
  }

  Future<void> _activate(ReaderContext next, {int? epoch}) async {
    final request = epoch ?? ++_navigationEpoch;
    final boundary = _boundary;
    if (!_boundaryAlive ||
        boundary == null ||
        request != _navigationEpoch ||
        next.boundary?.token != boundary.token ||
        next.examId != boundary.examId) {
      return;
    }
    final valid = await _checkBoundary(
      boundary,
      isCurrent: () => _boundaryAlive && request == _navigationEpoch,
    );
    if (!mounted || request != _navigationEpoch) return;
    if (!valid) return _expire();
    setState(() {
      _shown = next;
      _selectionFailure = null;
      _lessonId = next.lesson.id;
      _ending = null;
    });
  }

  Future<void> _showEnding(LessonEnding ending, int epoch) async {
    final boundary = _boundary;
    if (boundary == null || !_boundaryAlive || epoch != _navigationEpoch) {
      return;
    }
    final valid = await _checkBoundary(
      boundary,
      isCurrent: () => _boundaryAlive && epoch == _navigationEpoch,
    );
    if (!mounted || epoch != _navigationEpoch) return;
    if (!valid) return _expire();
    setState(() => _ending = ending);
  }

  LessonId? _destinationId(ReaderContext reader) {
    if (_ending is DayFinished) return null;
    if (_ending != null) return reader.nextTopic?.lessons.firstOrNull?.id;
    final day = _dayContextFor(reader.lesson.id);
    if (day != null) {
      return day.index + 1 < day.lessonIds.length
          ? day.lessonIds[day.index + 1]
          : null;
    }
    return reader.next?.id;
  }

  /// Loads the next lesson while this one is still being read.
  ///
  /// Kept subscribed so the provider is not disposed before the pull lands.
  /// Without it the advance waits on a database read at exactly the moment
  /// the movement is meant to be continuous.
  void _warmNext(LessonId? nextId) {
    if (nextId == _warmedId) return;
    _warmedId = nextId;
    _warm?.close();
    _warm = nextId == null
        ? null
        : ref.listenManual(readerContextProvider(nextId), (_, __) {});
  }

  @override
  Widget build(BuildContext context) {
    final lessonId = _lessonId;
    final origin = widget.origin;
    if (_captureFailed) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: _ReaderFallback(
          origin: origin,
          child: StateView(
            message: 'Could not load this lesson.',
            icon: Icon(PantasIcons.studyTab),
            boardLayout: true,
          ),
        ),
      );
    }
    if (_boundary == null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: _ReaderFallback(
          origin: origin,
          child: SingleChildScrollView(
            child: loadingFor(const AsyncLoading<Object?>()),
          ),
        ),
      );
    }
    final failure = _selectionFailure;
    if (failure != null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: _ReaderFallback(
          origin: origin,
          child: errorFor(
            'lesson',
            () => unawaited(_advanceTo(failure.id, retry: true)),
            error: failure.error,
            message: failure.error == null
                ? 'Lesson not found.'
                : 'Could not load this lesson.',
            icon: Icon(PantasIcons.studyTab),
            boardLayout: true,
          ),
        ),
      );
    }
    final asyncReader = ref.watch(readerContextProvider(lessonId));
    final loaded = asyncReader.valueOrNull;
    if (loaded != null) {
      if (loaded.boundary?.token != _boundary!.token ||
          loaded.examId != _boundary!.examId) {
        _shown = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _expire();
        });
      } else {
        _shown = loaded;
        if (widget.initialEnding && !_initialEndingShown) {
          _ending = loaded.topicEnding;
          _initialEndingShown = true;
        }
      }
    }
    final reader = _shown;
    final nextId = reader == null ? null : _destinationId(reader);
    final nextValue =
        nextId == null ? null : ref.watch(readerContextProvider(nextId));
    final next = nextValue?.valueOrNull;
    final readyNext = next?.boundary?.token == _boundary?.token &&
            next?.examId == _boundary?.examId
        ? next
        : null;
    final day = reader == null ? null : _dayContextFor(reader.lesson.id);
    final endingTarget = reader == null || _ending != null || nextId != null
        ? null
        : day != null
            ? const DayFinished()
            : reader.topicEnding;
    final title = endingTarget is DayFinished
        ? ''
        : endingTarget != null
            ? reader!.topicName
            : _ending != null
                ? reader?.nextTopic?.name
                : readyNext?.lesson.title;

    return Scaffold(
      backgroundColor: reader == null || _ending != null
          ? context.colors.background
          : context.colors.surface,
      body: switch ((reader, asyncReader)) {
        (_, AsyncError(:final error)) => _ReaderFallback(
            origin: origin,
            child: errorFor(
              'lesson',
              () => ref.invalidate(readerContextProvider(lessonId)),
              error: error,
              message: 'Could not load this lesson.',
              icon: Icon(PantasIcons.studyTab),
              boardLayout: true,
            ),
          ),
        (final ReaderContext reader, _) => Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  if (mounted && _boundaryAlive) _warmNext(nextId);
                },
              );
              return _ReaderBody(
                reader: reader,
                dayContext: _dayContextFor(reader.lesson.id),
                origin: origin,
                resume: widget.resume && reader.lesson.id == widget.lessonId,
                onAdvance: _advanceTo,
                isCurrent: () => _boundaryAlive,
                onExpired: _expire,
                onCancelPending: () => _navigationEpoch++,
                ending: _ending,
                destinationTitle: title,
                destinationKey: nextId ??
                    (endingTarget is DayFinished
                        ? 'day-ending'
                        : 'topic-ending-${reader.topicId}'),
                incoming: readyNext,
                endingTarget: endingTarget,
                nextFailed: nextId != null &&
                    ((nextValue?.hasError ?? false) ||
                        ((nextValue?.hasValue ?? false) && readyNext == null)),
                onRetryNext: () {
                  if (nextId != null) {
                    ref.invalidate(readerContextProvider(nextId));
                  }
                },
                onPullStart: () => _pullEpoch = ++_navigationEpoch,
                onPull: readyNext != null
                    ? () => unawaited(_activate(readyNext, epoch: _pullEpoch))
                    : endingTarget != null
                        ? () => unawaited(_showEnding(endingTarget, _pullEpoch))
                        : null,
              );
            },
          ),
        (_, AsyncLoading()) => _ReaderFallback(
            origin: origin,
            child: SingleChildScrollView(child: loadingFor(asyncReader)),
          ),
        _ => _ReaderFallback(
            origin: origin,
            child: StateView(
              message: 'Lesson not found.',
              boardLayout: true,
              icon: Icon(PantasIcons.studyTab),
            ),
          ),
      },
    );
  }
}

class _ReaderFallback extends StatelessWidget {
  const _ReaderFallback({required this.origin, required this.child});
  final ReaderOrigin origin;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: context.colors.surface,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  ),
                  onPressed: () => origin.leave(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PantasIcons.back,
                        size: 24,
                        color: context.colors.accent,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        origin.backLabel(context),
                        style: context.type.body
                            .copyWith(color: context.colors.accent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
}

class _ReaderBody extends ConsumerStatefulWidget {
  const _ReaderBody({
    required this.reader,
    required this.origin,
    required this.onAdvance,
    required this.isCurrent,
    required this.onExpired,
    required this.onCancelPending,
    required this.ending,
    required this.destinationTitle,
    required this.destinationKey,
    required this.incoming,
    required this.endingTarget,
    required this.nextFailed,
    required this.onRetryNext,
    required this.onPull,
    required this.onPullStart,
    this.dayContext,
    this.resume = false,
  });

  final bool resume;
  final LessonEnding? ending;
  final String? destinationTitle;
  final Object destinationKey;
  final ReaderContext? incoming;
  final LessonEnding? endingTarget;
  final bool nextFailed;
  final VoidCallback onRetryNext;
  final VoidCallback? onPull;
  final VoidCallback onPullStart;
  final bool Function() isCurrent;
  final VoidCallback onExpired;
  final VoidCallback onCancelPending;
  final ReaderContext reader;
  final ReaderOrigin origin;
  final LessonDayContext? dayContext;

  /// Swaps the lesson in place. Not a navigation: see [LessonPage].
  final void Function(LessonId) onAdvance;

  @override
  ConsumerState<_ReaderBody> createState() => _ReaderBodyState();
}

class _ReaderBodyState extends ConsumerState<_ReaderBody>
    with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  final _scrollOffset = ValueNotifier<double>(0);
  final _progress = ValueNotifier<double>(0);
  final _transition = ValueNotifier<double>(0);

  /// Whether the end of the lesson is on screen. Drives the pull handle.
  final _isAtEnd = ValueNotifier<bool>(false);
  ReadMarkingController? _markingController;
  late final ReaderPositionRepository _positions;
  Timer? _positionDelay;
  int _positionIntent = 0;
  ({
    ReaderContext reader,
    double offset,
    double fraction,
    int activation,
    int intent,
  })? _failedPosition;
  bool _resumeFailed = false;
  bool _contentsOpen = false;
  bool _contentsCovering = false;
  Timer? _contentsClose;
  int _contentsEpoch = 0;
  bool _appVisible = true;
  ModalRoute<Object?>? _route;
  Animation<double>? _routeCover;
  int _activation = 0;
  bool _activityFailed = false;
  bool _bookmarkPending = false;
  Future<void> Function()? _bookmarkRetry;

  bool _owns(ReaderContext reader, int activation) =>
      activation == _activation &&
      mounted &&
      widget.isCurrent() &&
      widget.ending == null &&
      widget.reader.lesson.id == reader.lesson.id;

  void _updateVisibility() {
    _markingController?.setVisible(
      visible: mounted &&
          _appVisible &&
          !_contentsCovering &&
          (_route?.isCurrent ?? true) &&
          (_routeCover?.value ?? 0) == 0 &&
          widget.ending == null,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of<Object?>(context);
    final cover = _route?.secondaryAnimation;
    if (_routeCover != cover) {
      _routeCover?.removeListener(_updateVisibility);
      _routeCover = cover;
      _routeCover?.addListener(_updateVisibility);
    }
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _appVisible = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _updateVisibility();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appVisible = state == AppLifecycleState.resumed;
    _updateVisibility();
  }

  void _setContents(bool open) {
    _contentsClose?.cancel();
    final epoch = ++_contentsEpoch;
    setState(() {
      _contentsOpen = open;
      _contentsCovering = true;
    });
    _updateVisibility();
    if (!open) {
      final delay = MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 400);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || epoch != _contentsEpoch) return;
        _contentsClose = Timer(delay, () {
          if (!mounted || epoch != _contentsEpoch) return;
          _contentsCovering = false;
          _updateVisibility();
        });
      });
    }
  }

  Future<void> _retryActivity(ReaderContext reader, int activation) async {
    if (!_owns(reader, activation)) return;
    final marking = _markingController;
    final bookmark = _bookmarkRetry;
    await marking?.retry();
    if (!_owns(reader, activation)) return;
    await bookmark?.call();
  }

  Future<void> _saveBookmark(
    ReaderContext reader,
    bool desired,
    int activation,
  ) async {
    if (_bookmarkPending || !_owns(reader, activation)) return;
    final boundary = reader.boundary;
    if (boundary == null) return;
    _bookmarkPending = true;
    try {
      await toggleBookmark(
        ref,
        reader.lesson.id,
        boundary: boundary,
        isCurrent: () => _owns(reader, activation),
        bookmarked: desired,
      );
      if (_owns(reader, activation)) setState(() => _bookmarkRetry = null);
    } catch (_) {
      if (_owns(reader, activation)) {
        setState(
          () =>
              _bookmarkRetry = () => _saveBookmark(reader, desired, activation),
        );
      }
    } finally {
      if (_owns(reader, activation)) _bookmarkPending = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _positions = ref.read(readerPositionRepositoryProvider);
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isCurrent() || widget.ending != null) return;
      _initMarking();
      if (widget.resume) {
        unawaited(_resumePosition(widget.reader, _activation));
      } else {
        _syncScrollState();
      }
    });
  }

  Future<void> _resumePosition(ReaderContext reader, int activation) async {
    final exam = reader.examId;
    final boundary = reader.boundary;
    bool current() => _owns(reader, activation);
    if (!current()) return;
    if (exam == null || boundary == null) return _syncScrollState();
    try {
      final offset = await _positions.read(exam, reader.lesson.id);
      if (!current()) return;
      final valid =
          await _positions.isBoundaryCurrent(boundary, isCurrent: current);
      if (!current() || !_scrollController.hasClients) return;
      if (!valid) return widget.onExpired();
      _scrollController.jumpTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
      if (_resumeFailed) setState(() => _resumeFailed = false);
      _syncScrollState();
    } on Exception catch (error) {
      if (current()) setState(() => _resumeFailed = true);
      debugPrint('Reader position could not load: ${error.runtimeType}');
    }
  }

  Future<void> _savePosition(
    ReaderContext reader,
    double offset,
    double fraction, {
    int? activation,
    int? positionIntent,
    bool retry = false,
  }) async {
    final exam = reader.examId;
    final boundary = reader.boundary;
    final reportingOwner = activation ?? _activation;
    final intent = positionIntent ?? _positionIntent;
    // Outgoing/disposal saves deliberately preserve the measured old position.
    // Active timers and UI retries retain their original activation instead.
    // Supersession must be visible inside the queued transaction, before the
    // newer save's awaiting caller has published success or failure.
    bool current() =>
        widget.isCurrent() &&
        (activation == null || _owns(reader, activation)) &&
        (!retry || intent == _positionIntent);
    if (exam == null || boundary == null || !current()) return;
    try {
      final saved = await _positions.writeGuarded(
        boundary,
        reader.lesson.id,
        offset.clamp(0.0, double.infinity),
        fraction: fraction,
        isCurrent: current,
      );
      if (!saved && current()) widget.onExpired();
      if (_owns(reader, reportingOwner) &&
          intent == _positionIntent &&
          _failedPosition != null) {
        setState(() => _failedPosition = null);
      }
    } on Exception {
      if (_owns(reader, reportingOwner) && intent == _positionIntent) {
        setState(
          () => _failedPosition = (
            reader: reader,
            offset: offset,
            fraction: fraction,
            activation: reportingOwner,
            intent: intent,
          ),
        );
      }
    }
  }

  /// A lesson short enough not to scroll never fires a scroll event, so the
  /// end is already on screen and nothing would ever say so.
  void _syncScrollState() {
    if (!mounted || !_scrollController.hasClients) return;
    _onScroll();
  }

  void _initMarking() {
    final activation = _activation;
    final reader = widget.reader;
    final progressRepo = ref.read(lessonProgressRepositoryProvider);
    final prefsRepo = ref.read(appPreferencesRepositoryProvider);
    _markingController = ReadMarkingController(
      lessonId: reader.lesson.id,
      examId: reader.examId,
      progressRepository: progressRepo,
      preferencesRepository: prefsRepo,
      positions: _positions,
      boundary: reader.boundary,
      isCurrent: () => _owns(reader, activation),
      readMetrics: () => _scrollController.hasClients
          ? (
              offset: _scrollController.offset,
              maxExtent: _scrollController.position.maxScrollExtent
            )
          : null,
      onSaveFailed: ({required bool failed}) {
        if (_owns(reader, activation)) setState(() => _activityFailed = failed);
      },
      onOpened: () {
        if (_owns(reader, activation)) {
          ref
            ..invalidate(lastOpenedLessonProvider)
            ..invalidate(recentlyOpenedLessonsProvider);
        }
      },
      onMarked: () {
        if (_owns(reader, activation)) {
          ref
            ..read(roadmapRevisionProvider.notifier).bump()
            ..invalidate(studyMapProvider)
            ..invalidate(readerContextProvider(reader.lesson.id));
        }
      },
    );
    _updateVisibility();
    unawaited(_markingController!.onOpen());
  }

  @override
  void didUpdateWidget(covariant _ReaderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reader.lesson.id != widget.reader.lesson.id ||
        oldWidget.ending != widget.ending) {
      // The body stays mounted across an advance, so the controller keeps
      // the offset the last lesson was left at and the new one opened part
      // way down. A lesson starts at its first line.
      _activation++;
      if (_contentsCovering) _setContents(false);
      _activityFailed = false;
      _failedPosition = null;
      _resumeFailed = false;
      _bookmarkRetry = null;
      _bookmarkPending = false;
      _positionDelay?.cancel();
      if (oldWidget.ending == null) {
        unawaited(
          _savePosition(
            oldWidget.reader,
            _scrollOffset.value,
            _progress.value,
          ),
        );
      }
      _markingController?.dispose();
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      _scrollOffset.value = 0;
      _progress.value = 0;
      _transition.value = 0;
      _isAtEnd.value = false;
      if (widget.ending == null) _initMarking();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Again after layout: the offset is clamped against the old lesson's
        // extent until the new one has been measured.
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        _syncScrollState();
      });
    }
  }

  @override
  void dispose() {
    _activation++;
    WidgetsBinding.instance.removeObserver(this);
    _routeCover?.removeListener(_updateVisibility);
    _contentsClose?.cancel();
    _contentsEpoch++;
    _positionDelay?.cancel();
    if (widget.ending == null) {
      unawaited(
        _savePosition(widget.reader, _scrollOffset.value, _progress.value),
      );
    }
    _markingController?.dispose();
    _scrollController.dispose();
    _scrollOffset.dispose();
    _progress.dispose();
    _transition.dispose();
    _isAtEnd.dispose();
    super.dispose();
  }

  /// Scroll position is published through notifiers, never `setState`.
  ///
  /// `setState` here rebuilt the whole page on **every scroll frame**, and
  /// the whole page includes the lesson body: every block, every formula,
  /// each of which is a laid-out widget. That is the jank in the reader and
  /// nowhere else, because no other screen rebuilds this much this often.
  ///
  /// Only the bar, the rail and the pull handle listen, and each rebuilds
  /// alone.
  void _onScroll() {
    if (!_scrollController.hasClients || widget.ending != null) return;
    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;

    _scrollOffset.value = offset;
    _positionDelay?.cancel();
    final reader = widget.reader;
    final activation = _activation;
    final intent = ++_positionIntent;
    final fraction = maxExtent > 0 ? (offset / maxExtent).clamp(0.0, 1.0) : 1.0;
    _positionDelay = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(
        _savePosition(
          reader,
          offset,
          fraction,
          activation: activation,
          positionIntent: intent,
        ),
      ),
    );
    _progress.value =
        maxExtent > 0 ? (offset / maxExtent).clamp(0.0, 1.0) : 1.0;
    // Within a line or so of the bottom, not exactly on it: a reader who
    // has stopped a few pixels short has still reached the end, and
    // rounding in the scroll metrics means exact equality is rare.
    _isAtEnd.value = maxExtent <= 0 || offset >= maxExtent - 24;

    if (widget.ending == null) {
      _markingController?.onScroll(offset: offset, maxExtent: maxExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reader = widget.reader;
    final activation = _activation;
    final failedPosition = _failedPosition;
    final ending = widget.ending;
    final next = widget.incoming;
    Widget lesson(
      ReaderContext value, {
      ScrollController? controller,
      Widget? footer,
    }) =>
        _LessonContent(
          reader: value,
          controller: controller,
          footer: footer,
          positionFailed: controller != null && failedPosition != null,
          activityFailed:
              controller != null && (_activityFailed || _bookmarkRetry != null),
          onRetryActivity: () => unawaited(_retryActivity(reader, activation)),
          resumeFailed: controller != null && _resumeFailed,
          onResume: () => unawaited(_resumePosition(value, activation)),
          onSave: () {
            if (failedPosition == null || _failedPosition != failedPosition) {
              return;
            }
            unawaited(
              _savePosition(
                failedPosition.reader,
                failedPosition.offset,
                failedPosition.fraction,
                activation: failedPosition.activation,
                positionIntent: failedPosition.intent,
                retry: true,
              ),
            );
          },
          nextFailed: controller != null && widget.nextFailed,
          onRetryNext: widget.onRetryNext,
        );
    Widget plate(LessonEnding value) => EndingContent(
          ending: value,
          onLesson: widget.onAdvance,
          onHome: () => context.go('/home'),
        );
    return PantasSheet(
      label: 'Contents',
      readerContents: true,
      open: _contentsOpen,
      onDismiss: () => _setContents(false),
      page: SafeArea(
        child: Column(
          children: [
            if (ending != null)
              ReaderBar.ending(origin: widget.origin)
            else
              ReaderBar(
                title: reader.lesson.title,
                lessonId: reader.lesson.id,
                dayContext: widget.dayContext,
                origin: widget.origin,
                isBookmarked: reader.isBookmarked,
                onBookmark: () => unawaited(
                  _saveBookmark(reader, !reader.isBookmarked, activation),
                ),
                onContents: () {
                  widget.onCancelPending();
                  _transition.value = 0;
                  _setContents(true);
                },
                scrollOffset: _scrollOffset,
                advanceProgress: _transition,
              ),
            AnimatedBuilder(
              animation: Listenable.merge([_progress, _transition]),
              builder: (_, __) {
                final reset =
                    widget.dayContext == null && ending == null && next != null
                        ? PantasCurves.slideA.transform(_transition.value)
                        : 0.0;
                return ReaderRail(
                  progress: ending != null ? 1 : _progress.value * (1 - reset),
                  dayContext: ending != null ? null : widget.dayContext,
                );
              },
            ),
            Expanded(
              child: PullToAdvance(
                enabled: !_contentsOpen,
                isAtEnd: ending != null
                    ? const AlwaysStoppedAnimation(true)
                    : _isAtEnd,
                nextTitle: widget.destinationTitle,
                lessonId: reader.lesson.id,
                contentKey: ending == null
                    ? reader.lesson.id
                    : 'ending-${reader.lesson.id}',
                destinationKey: widget.destinationKey,
                requireIncoming: true,
                onAdvance: widget.onPull,
                onTransition: (value) => _transition.value = value,
                onCommit: widget.onPullStart,
                finishDay: widget.endingTarget is DayFinished,
                incomingChild: next != null
                    ? ColoredBox(
                        color: context.colors.surface,
                        child: lesson(next),
                      )
                    : widget.endingTarget != null
                        ? ColoredBox(
                            color: context.colors.background,
                            child: plate(widget.endingTarget!),
                          )
                        : null,
                footerPadding: ending != null
                    ? const EdgeInsets.only(bottom: 48)
                    : const EdgeInsets.fromLTRB(0, 36, 0, 60),
                contentBuilder: ending == null
                    ? (footer) => lesson(
                          reader,
                          controller: _scrollController,
                          footer: footer,
                        )
                    : null,
                child: ending != null ? plate(ending) : null,
              ),
            ),
          ],
        ),
      ),
      child: LessonContentsSheet(
        key: const ValueKey('lesson-contents'),
        reader: reader,
        dayContext: widget.dayContext,
        onSelectLesson: (id) {
          _setContents(false);
          if (id != reader.lesson.id) widget.onAdvance(id);
        },
      ),
    );
  }
}

/// Pure layout shared by the active reader and the inert incoming preview.
/// Only the active owner supplies a controller, persistence, or read marking.
class _LessonContent extends StatelessWidget {
  const _LessonContent({
    required this.reader,
    required this.onResume,
    required this.onSave,
    required this.onRetryNext,
    required this.onRetryActivity,
    this.controller,
    this.footer,
    this.positionFailed = false,
    this.resumeFailed = false,
    this.nextFailed = false,
    this.activityFailed = false,
  });
  final ReaderContext reader;
  final ScrollController? controller;
  final Widget? footer;
  final bool positionFailed;
  final bool resumeFailed;
  final bool nextFailed;
  final bool activityFailed;
  final VoidCallback onRetryActivity;
  final VoidCallback onResume;
  final VoidCallback onSave;
  final VoidCallback onRetryNext;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: controller,
        primary: false,
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LessonTextScale(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    reader.topicName.toUpperCase(),
                    style:
                        context.type.sectionHeader.copyWith(letterSpacing: .52),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    reader.lesson.title,
                    style: context.type.pageTitle.copyWith(height: 1.15),
                  ),
                  const SizedBox(height: 18),
                  ContentRenderer(
                    blocks: reader.lesson.bodyJson,
                    readerFigures: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (resumeFailed) errorFor('reading position', onResume),
            if (positionFailed) saveFailureLine(onSave),
            if (activityFailed) saveFailureLine(onRetryActivity),
            ReaderGap(
              isRead: reader.isRead,
              examId: reader.examId,
              lessonId: reader.lesson.id,
            ),
            if (nextFailed)
              errorFor(
                'lesson',
                onRetryNext,
                message: 'Could not load this lesson.',
                icon: Icon(PantasIcons.studyTab),
                boardLayout: true,
              ),
            if (footer != null) footer!,
          ],
        ),
      );
}
