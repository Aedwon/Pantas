import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart' show signInHold;
import 'package:pantas/app/sign_in/sign_in_parts.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';
import 'package:pantas/features/child_setup/presentation/parents_frame.dart';

/// Where the code gate opens. Push it with a [GuardianGateRequest] as the
/// route's `extra`; it pops with the proof id, or null if the parent backs out.
const String guardianGatePath = '/parents/code';

// The wrong-code beat of the beta sign-in screen: red boxes hold, fade, then
// the digits clear.
const _wrongHold = Duration(milliseconds: 1440);
const _wrongFade = Duration(milliseconds: 240);

enum _Phase { sending, entering, verifying, ok, wrong, wrongFading, dead }

enum _Note {
  wrong,
  resent,
  tooManyTries,
  expired,
  dailyLimit,
  rateLimited,
  sendFailed,
  checkFailed,
  wait,
}

/// Board 8A: the guardian code gate. A 6-digit code goes to the parent's
/// email. The parent enters it here, inside the child's session, and the page
/// returns the proof the guarded action needs. The code entry is the beta
/// sign-in's: the same boxes, paste, one-time-code autofill, automatic check at
/// the sixth digit, wrong-code beat and resend cooldown. It serves any action;
/// the caller names the action phrase.
class GuardianCodeGatePage extends ConsumerStatefulWidget {
  const GuardianCodeGatePage({
    required this.request,
    this.wideFrame,
    super.key,
  });

  final GuardianGateRequest request;

  /// How wide web draws the page (the Settings pane). Null is the default.
  final ParentsWideFrame? wideFrame;

  @override
  ConsumerState<GuardianCodeGatePage> createState() =>
      _GuardianCodeGatePageState();
}

class _GuardianCodeGatePageState extends ConsumerState<GuardianCodeGatePage> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  late final CodeDigitsFormatter _formatter = CodeDigitsFormatter(
    replacing: () => _phase == _Phase.wrong || _phase == _Phase.wrongFading,
  );
  late final TapGestureRecognizer _dpoTap = TapGestureRecognizer()
    ..onTap = _openDpoMail;

  _Phase _phase = _Phase.sending;
  _Note? _note;
  String? _maskedEmail;
  // The parent has used up today's codes: nothing can be sent or checked.
  bool _limitReached = false;
  int _waitLeft = 0;
  int _shake = 0;
  // Bumped when a new code is asked for, so a late answer for an old one is
  // ignored.
  int _flow = 0;
  Timer? _wrongTimer;
  Timer? _holdTimer;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _code.addListener(_keepCursorAtEnd);
    unawaited(_send(initial: true));
  }

  @override
  void dispose() {
    _code.removeListener(_keepCursorAtEnd);
    _wrongTimer?.cancel();
    _holdTimer?.cancel();
    _tick?.cancel();
    _dpoTap.dispose();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  // The boxes show the digits in order, so the caret always sits at the end.
  void _keepCursorAtEnd() {
    final end = _code.text.length;
    final selection = _code.selection;
    if (!selection.isCollapsed || selection.baseOffset != end) {
      _code.selection = TextSelection.collapsed(offset: end);
    }
  }

  void _openDpoMail() =>
      unawaited(ref.read(dpoMailOpenerProvider)(GuardianGateCopy.dpoEmail));

  // ----------------------------------------------------------- send a code

  Future<void> _send({required bool initial}) async {
    final flow = ++_flow;
    _wrongTimer?.cancel();
    if (!initial) {
      setState(() {
        _phase = _Phase.sending;
        _note = null;
      });
    }
    try {
      final sent =
          await ref.read(childSetupGatewayProvider).requestGuardianCode(
                action: widget.request.action,
                childId: widget.request.childId,
              );
      if (!mounted || flow != _flow) return;
      _startWait(sent.resendAfterSeconds);
      _code.clear();
      setState(() {
        _maskedEmail = sent.maskedEmail;
        _phase = _Phase.entering;
        _note = initial ? null : _Note.resent;
      });
      _focus.requestFocus();
    } on GuardianGateException catch (error) {
      if (!mounted || flow != _flow) return;
      switch (error.failure) {
        case GuardianGateFailure.dailyLimit:
          _limitReached = true;
          _fail(_Note.dailyLimit, dead: true);
        case GuardianGateFailure.rateLimited:
          _fail(_Note.rateLimited);
        case _:
          _fail(_Note.sendFailed);
      }
    } on Object {
      if (mounted && flow == _flow) _fail(_Note.sendFailed);
    }
  }

  void _fail(_Note note, {bool dead = false}) {
    if (dead) _code.clear();
    setState(() {
      _phase = dead ? _Phase.dead : _Phase.entering;
      _note = note;
    });
  }

  void _startWait(int seconds) {
    _tick?.cancel();
    _waitLeft = seconds < 0 ? 0 : seconds;
    if (_waitLeft == 0) return;
    _tick = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _waitLeft--;
      if (_waitLeft <= 0) timer.cancel();
      setState(() {});
    });
  }

  void _resend() {
    if (_phase == _Phase.sending || _phase == _Phase.verifying) return;
    if (_limitReached) return;
    // Asking again inside the cooldown only repeats the wait.
    if (_waitLeft > 0) {
      setState(() => _note = _Note.wait);
      return;
    }
    unawaited(_send(initial: false));
  }

  // ------------------------------------------------------------ check code

  void _onChanged(String text) {
    var changed = false;
    if (_phase == _Phase.wrong || _phase == _Phase.wrongFading) {
      // Typing again ends the wrong-code beat at once.
      _wrongTimer?.cancel();
      _phase = _Phase.entering;
      changed = true;
    }
    if (_note != null && _phase == _Phase.entering) {
      _note = null;
      changed = true;
    }
    if (changed) setState(() {});
    if (text.length == 6) unawaited(_verify());
  }

  Future<void> _verify() async {
    if (_phase != _Phase.entering) return;
    final code = _code.text;
    if (code.length != 6) return;
    final flow = _flow;
    setState(() {
      _phase = _Phase.verifying;
      _note = null;
    });
    try {
      final proof =
          await ref.read(childSetupGatewayProvider).verifyGuardianCode(
                action: widget.request.action,
                childId: widget.request.childId,
                code: code,
              );
      if (!mounted || flow != _flow) return;
      // The sign-in's own beat: the boxes ring, then the page leaves.
      setState(() => _phase = _Phase.ok);
      _holdTimer = Timer(signInHold, () {
        if (mounted) Navigator.of(context).pop(proof);
      });
    } on GuardianGateException catch (error) {
      if (mounted && flow == _flow) _refused(error);
    } on Object {
      if (mounted && flow == _flow) _fail(_Note.checkFailed);
    }
  }

  void _refused(GuardianGateException error) {
    switch (error.failure) {
      case GuardianGateFailure.wrong:
        _showWrongCode();
      case GuardianGateFailure.expired:
        _fail(_Note.expired, dead: true);
      case GuardianGateFailure.tooManyTries:
        _fail(_Note.tooManyTries, dead: true);
      case GuardianGateFailure.rateLimited:
        _fail(_Note.rateLimited);
      case _:
        _fail(_Note.checkFailed);
    }
  }

  void _showWrongCode() {
    setState(() {
      _phase = _Phase.wrong;
      _note = _Note.wrong;
      _shake++;
    });
    _wrongTimer?.cancel();
    _wrongTimer = Timer(_wrongHold, () {
      if (!mounted) return;
      setState(() => _phase = _Phase.wrongFading);
      _wrongTimer = Timer(_wrongFade, () {
        if (!mounted) return;
        _code.clear();
        setState(() => _phase = _Phase.entering);
        _focus.requestFocus();
      });
    });
  }

  // ------------------------------------------------------------------ view

  CodeTone get _tone => switch (_phase) {
        _Phase.ok => CodeTone.ok,
        _Phase.wrong => CodeTone.bad,
        _Phase.wrongFading => CodeTone.fadingBad,
        _ => CodeTone.normal,
      };

  bool get _canConfirm =>
      (_phase == _Phase.entering ||
          _phase == _Phase.wrong ||
          _phase == _Phase.wrongFading) &&
      _code.text.length == 6;

  static String _clock(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  /// The words of [_note] with the data protection officer's address set as a
  /// link where it appears.
  InlineSpan? _noteSpan(TextStyle style) {
    final link = style.copyWith(
      color: context.colors.accent,
      fontWeight: FontWeight.w600,
    );
    InlineSpan dpo() => TextSpan(
          text: GuardianGateCopy.dpoEmail,
          style: link,
          recognizer: _dpoTap,
          mouseCursor: SystemMouseCursors.click,
        );
    return switch (_note) {
      null => null,
      _Note.wrong => const TextSpan(text: GuardianGateCopy.wrongCode),
      _Note.resent => const TextSpan(text: GuardianGateCopy.resent),
      _Note.tooManyTries => const TextSpan(text: GuardianGateCopy.tooManyTries),
      _Note.expired => const TextSpan(text: GuardianGateCopy.expired),
      _Note.dailyLimit => TextSpan(
          children: [
            const TextSpan(text: GuardianGateCopy.dailyLimitLead),
            dpo(),
            const TextSpan(text: GuardianGateCopy.dailyLimitTail),
          ],
        ),
      _Note.rateLimited => const TextSpan(text: GuardianGateCopy.rateLimited),
      _Note.sendFailed => const TextSpan(text: GuardianGateCopy.sendFailed),
      _Note.checkFailed => const TextSpan(text: GuardianGateCopy.checkFailed),
      _Note.wait => TextSpan(
          text: GuardianGateCopy.waitToResend(_clock(_waitLeft)),
        ),
    };
  }

  Widget _message() {
    final error = _note == _Note.wrong;
    final style = PantasType.webSmall.copyWith(
      color: error ? context.colors.dangerText : context.colors.textSecondary,
    );
    final span = _noteSpan(style);
    if (span == null) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s4,
          PantasSpace.s6,
          PantasSpace.s4,
          PantasSpace.s0,
        ),
        child: Text.rich(TextSpan(style: style, children: [span])),
      ),
    );
  }

  Widget _finePrint() {
    final style = SignInStyle(context, wide: context.wideWeb);
    return LinkLine(
      prefix: GuardianGateCopy.finePrintLead,
      link: GuardianGateCopy.dpoEmail,
      suffix: GuardianGateCopy.finePrintTail,
      style: style,
      onTap: _openDpoMail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final masked = _maskedEmail;
    final style = SignInStyle(context, wide: context.wideWeb);
    final dead = _phase == _Phase.dead;
    final tail = GuardianGateCopy.bodyTail(
      action: request.actionPhrase,
      nickname: request.nickname,
    );
    return ParentsFrame(
      wideFrame: widget.wideFrame,
      title: GuardianGateCopy.title(
        action: request.actionPhrase,
        nickname: request.nickname,
      ),
      lead: masked == null ? null : '${GuardianGateCopy.bodyLead}$masked$tail',
      onBack: () => Navigator.of(context).maybePop(),
      bottom: ParentsButton(
        label: GuardianGateCopy.confirm,
        busy: _phase == _Phase.verifying,
        onPressed: _canConfirm ? () => unawaited(_verify()) : null,
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PantasFieldLabel(GuardianGateCopy.fieldLabel),
            const SizedBox(height: PantasSpace.s6),
            CodeBoxes(
              controller: _code,
              focusNode: _focus,
              style: style,
              formatter: _formatter,
              tone: _tone,
              shakeTick: _shake,
              locked: _phase == _Phase.verifying ||
                  _phase == _Phase.ok ||
                  _phase == _Phase.sending,
              dimmed: dead,
              onChanged: _onChanged,
              onSubmitted: () => unawaited(_verify()),
            ),
            _message(),
          ],
        ),
        const SizedBox(height: parentsGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The sign-in's resend control: its countdown line while the
            // cooldown runs, the button once it is over or the code is dead.
            if (_waitLeft > 0 && !dead && !_limitReached)
              Text(
                GuardianGateCopy.waitingToResend(_clock(_waitLeft)),
                textAlign: TextAlign.center,
                style: style.small,
              )
            else
              ParentsButton(
                label: GuardianGateCopy.sendNewCode,
                text: true,
                onPressed: _limitReached ? null : _resend,
              ),
            const SizedBox(height: PantasSpace.s6),
            _finePrint(),
          ],
        ),
      ],
    );
  }
}
