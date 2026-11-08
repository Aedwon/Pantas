import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/days_card.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';
import 'package:pantas/features/beta_feedback/presentation/survey_controls.dart';
import 'package:pantas/features/beta_feedback/presentation/survey_sent.dart';

const feedbackPath = '/settings/beta-feedback';

/// The width of the "keep using" control on wide web. The system sets no
/// width for it; the board draws 320.
const _q4Width = 320.0;

enum _Phase { form, sending, sent }

/// The exit survey: seven questions, sent once.
class ExitSurveyPage extends ConsumerStatefulWidget {
  const ExitSurveyPage({required this.frame, super.key});
  final FeedbackFrame frame;

  @override
  ConsumerState<ExitSurveyPage> createState() => _ExitSurveyPageState();
}

class _ExitSurveyPageState extends ConsumerState<ExitSurveyPage> {
  int? _usage;
  int? _ease;
  int? _useful;
  int? _keep;
  int? _recommend;
  final _improve = TextEditingController();
  final _other = TextEditingController();
  bool _listOpen = false;
  _Phase _phase = _Phase.form;

  @override
  void initState() {
    super.initState();
    // Typing changes the progress and the Send button.
    _improve.addListener(_changed);
    _other.addListener(_changed);
  }

  @override
  void dispose() {
    _improve.dispose();
    _other.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  int get _answered => [
        _usage,
        _ease,
        _useful,
        _keep,
        _recommend,
        if (_improve.text.trim().isNotEmpty) 1,
        if (_other.text.trim().isNotEmpty) 1,
      ].where((a) => a != null).length;

  bool get _ready =>
      _usage != null &&
      _ease != null &&
      _useful != null &&
      _keep != null &&
      _recommend != null &&
      _improve.text.trim().isNotEmpty;

  Future<void> _send() async {
    if (!_ready || _phase != _Phase.form) return;
    setState(() => _phase = _Phase.sending);
    final answers = SurveyAnswers(
      usage: SurveyUsage.values[_usage!],
      ease: _ease! + 1,
      usefulness: _useful! + 1,
      keepUsing: SurveyContinue.values[_keep!],
      recommend: _recommend!,
      improve: _improve.text.trim(),
      other: _other.text.trim(),
    );
    try {
      await ref.read(betaFeedbackApiProvider).submitSurvey(answers);
    } on BetaFeedbackException catch (e) {
      if (!mounted) return;
      if (e.failure == BetaFeedbackFailure.alreadyDone) {
        _finish();
        return;
      }
      setState(() => _phase = _Phase.form);
      fbToast(
        context,
        e.failure == BetaFeedbackFailure.notAllowed
            ? 'The survey is closed.'
            : 'Could not send. Try again.',
      );
      return;
    } on Exception {
      if (!mounted) return;
      setState(() => _phase = _Phase.form);
      fbToast(context, 'Could not send. Try again.');
      return;
    }
    if (mounted) _finish();
  }

  void _finish() {
    ref.invalidate(betaRewardProvider);
    setState(() => _phase = _Phase.sent);
  }

  void _back() => leavePage(context, fallback: feedbackPath);

  @override
  Widget build(BuildContext context) {
    Widget frame(
      List<Widget> children, {
      bool heading = true,
      String? subline,
      double gap = 24,
    }) =>
        widget.frame(
          title: 'Exit Survey',
          subline: subline,
          backLabel: 'Feedback',
          onBack: _back,
          headingGap: gap,
          heading: heading,
          children: children,
        );

    if (_phase == _Phase.sent) {
      return frame([SurveySent(onBack: _back)], heading: false);
    }
    final reward = ref.watch(betaRewardProvider);
    final data = reward.valueOrNull;
    if (data == null) {
      return frame([
        if (reward.hasError)
          Text(
            'Could not load the survey.',
            style: context.fbSub,
          )
        else
          const SkeletonPulse(child: SkeletonBlock(height: 120)),
      ]);
    }
    final status = surveyStatus(data, ref.watch(betaFeedbackClockProvider)());
    if (status == SurveyStatus.sent) {
      return frame([SurveySent(onBack: _back)], heading: false);
    }
    if (status != SurveyStatus.open) {
      // Opened by a link while the survey is not open: back to Feedback.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final router = GoRouter.maybeOf(context);
          if (router != null) router.go(feedbackPath);
        }
      });
      return frame(const []);
    }
    return _form(context, data, frame);
  }

  Widget _form(
    BuildContext context,
    BetaReward reward,
    Widget Function(List<Widget>, {bool heading, String? subline, double gap})
        frame,
  ) {
    final wide = context.fbWide;
    final sent = ref.watch(sentFeedbackProvider).valueOrNull ?? const [];
    final gap = SizedBox(height: wide ? 30 : 28);
    final sending = _phase == _Phase.sending;

    final expander = SentFeedbackExpander(
      items: sent,
      open: _listOpen,
      onToggle: () => setState(() => _listOpen = !_listOpen),
    );
    final q1 = SurveyQuestion(
      title: '1. How often did you use Pantas this week?',
      child: LetterOptions(
        labels: const ['Every day', 'Most days', 'A few days', 'Once'],
        selected: _usage,
        onPick: (i) => setState(() => _usage = i),
      ),
    );
    final q2 = SurveyQuestion(
      title: '2. How easy was Pantas to use?',
      ends: ('Hard', 'Easy'),
      child: SurveySegmented(
        id: 'q2',
        labels: const ['1', '2', '3', '4', '5'],
        firstValue: 1,
        selected: _ease,
        onPick: (i) => setState(() => _ease = i),
      ),
    );
    final q3 = SurveyQuestion(
      title: wide
          ? '3. How useful was it for your exam?'
          : '3. How useful was Pantas for your exam prep?',
      ends: ('Not useful', 'Very useful'),
      child: SurveySegmented(
        id: 'q3',
        labels: const ['1', '2', '3', '4', '5'],
        firstValue: 1,
        selected: _useful,
        onPick: (i) => setState(() => _useful = i),
      ),
    );
    final q4Control = SurveySegmented(
      id: 'q4',
      labels: const ['Yes', 'Maybe', 'No'],
      selected: _keep,
      onPick: (i) => setState(() => _keep = i),
    );
    final q4 = SurveyQuestion(
      title: '4. Will you keep using Pantas after the beta?',
      child: wide
          ? Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _q4Width),
                child: q4Control,
              ),
            )
          : q4Control,
    );
    final q5 = SurveyQuestion(
      title: '5. How likely are you to recommend Pantas to a friend?',
      ends: ('Not likely', 'Very likely'),
      child: SurveyPills(
        selected: _recommend,
        onPick: (i) => setState(() => _recommend = i),
      ),
    );
    final q6 = SurveyQuestion(
      title: '6. What should we improve most?',
      child: SurveyTextBox(
        id: 'q6',
        label: '6. What should we improve most?',
        controller: _improve,
        rows: wide ? 3 : 4,
      ),
    );
    final q7 = SurveyQuestion(
      title: '7. Anything else you want to tell us?',
      optional: true,
      child: SurveyTextBox(
        id: 'q7',
        label: '7. Anything else you want to tell us? Optional',
        controller: _other,
        rows: wide ? 2 : 3,
      ),
    );

    final button = FbButton(
      onPressed: _ready && !sending ? _send : null,
      busy: sending,
      child: sending ? const FbSpinner() : const Text('Send Survey'),
    );
    final appeal = wide
        ? Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s4,
              PantasSpace.s14,
              PantasSpace.s4,
              PantasSpace.s0,
            ),
            child: Text(
              'Think a day was missed? Email support@pantas.study by Nov 30.',
              style: context.fbSmall,
            ),
          )
        : const FbFootnote(
            'Think a day was missed? Email support@pantas.study by Nov 30.',
          );

    final body = <Widget>[
      if (wide) ...[
        SurveyProgress(answered: _answered),
        const SizedBox(height: PantasSpace.s20),
      ],
      expander,
      if (!wide)
        const FbFootnote('Look back at what you sent while you answer.'),
      gap,
      q1,
      gap,
      if (wide)
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: q2),
            const SizedBox(width: PantasSpace.s24),
            Expanded(child: q3),
          ],
        )
      else ...[q2, gap, q3],
      gap,
      q4,
      gap,
      q5,
      gap,
      q6,
      gap,
      q7,
      const SizedBox(height: PantasSpace.s28),
      if (wide)
        Row(
          children: [
            button,
            const SizedBox(width: PantasSpace.s14),
            Text(
              _ready
                  ? 'You can send it once.'
                  : 'Answer questions 1 to 6 to send.',
              style: context.fbSmall,
            ),
          ],
        )
      else
        button,
      appeal,
    ];
    final subline = '7 questions. You can send it once, until '
        '${monthDay(surveyLastDay(reward))}.';
    return frame(
      wide ? [_rise(body)] : body,
      subline: subline,
      gap: wide ? 16 : 24,
    );
  }

  /// The wide form rises in as one block when the page opens.
  Widget _rise(List<Widget> body) => FbRise(
        dy: 14,
        duration: const Duration(milliseconds: 450),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: body,
        ),
      );
}
