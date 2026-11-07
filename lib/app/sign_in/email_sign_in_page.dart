import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/sign_in/sign_in_parts.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/email_code_auth.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';

/// True while the sign-in screen plays its signed-in beat. The beta gate holds
/// the screen in place until the beat ends, so signing in does not swap the
/// screen for the gate's loading state in the middle of the check mark.
final signInHoldProvider = StateProvider<bool>((ref) => false);

/// How long the screen holds after the check mark has drawn.
const signInHold = Duration(milliseconds: 1200);

// The wrong-code board: red boxes hold, then fade, then the digits clear.
const _wrongHold = Duration(milliseconds: 1440);
const _wrongFade = Duration(milliseconds: 240);

final _emailShape = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

enum _Step { email, code }

enum _Phase { entering, verifying, signedIn, wrong, wrongFading, expired }

/// The sign-in screens: email, six-digit code, and "not on the beta list".
class EmailSignInPage extends ConsumerStatefulWidget {
  const EmailSignInPage({this.beta = false, this.denied = false, super.key});

  /// True on the beta gate, which also shows the BETA mark and goes back to
  /// the gate after sign-in.
  final bool beta;

  /// Signed in, but not selected for the beta.
  final bool denied;

  @override
  ConsumerState<EmailSignInPage> createState() => _EmailSignInPageState();
}

class _EmailSignInPageState extends ConsumerState<EmailSignInPage> {
  final _email = TextEditingController();
  final _emailFocus = FocusNode();
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  final _resend = _Countdown();
  final _wait = _Countdown();
  late final CodeDigitsFormatter _formatter = CodeDigitsFormatter(
    replacing: () => _phase == _Phase.wrong || _phase == _Phase.wrongFading,
  );
  late final StateController<bool> _hold;
  late final EmailCodeAuth _codes;

  _Step _step = _Step.email;
  _Phase _phase = _Phase.entering;

  // Email step.
  bool _sending = false;
  bool _googleBusy = false;
  bool _emailInvalid = false;
  String? _emailMessage;
  int _emailShake = 0;

  // Code step.
  String _sentTo = '';
  String? _challengeId;
  // Bumped each time the code step opens or closes, so a late answer from an
  // earlier visit is ignored.
  int _flow = 0;
  // The address a code cooldown was reported for, while the email step waits.
  String? _waitEmail;
  bool _resending = false;
  bool _released = false;
  String? _codeMessage;
  bool _codeMessageIsError = false;
  int _codeShake = 0;

  // Not on the list.
  bool _signingOut = false;

  Timer? _wrongTimer;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _hold = ref.read(signInHoldProvider.notifier);
    _codes = ref.read(emailCodeAuthProvider);
    _code.addListener(_keepCursorAtEnd);
  }

  @override
  void dispose() {
    _resend.dispose();
    _wait.dispose();
    _wrongTimer?.cancel();
    _holdTimer?.cancel();
    _code.removeListener(_keepCursorAtEnd);
    // A check still running must not sign anyone in once this screen is gone,
    // whatever the screen was showing.
    _codes.cancelVerification();
    final hold = _hold;
    // Leaving the screen must not leave the gate held.
    Future<void>.microtask(() {
      if (hold.mounted && hold.state) hold.state = false;
    });
    _email.dispose();
    _emailFocus.dispose();
    _code.dispose();
    _codeFocus.dispose();
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

  bool get _celebrating =>
      _phase == _Phase.verifying || _phase == _Phase.signedIn;

  // ------------------------------------------------------------ email step

  Future<void> _continueEmail() async {
    if (_sending || _googleBusy) return;
    final email = _email.text.trim();
    if (!_emailShape.hasMatch(email)) {
      _refuseEmail('Enter a full email address, like juan@gmail.com.');
      return;
    }
    // The server said to wait for this address. Asking again only repeats it.
    if (_wait.left.value > 0 && _waitEmail == email.toLowerCase()) return;
    setState(() {
      _sending = true;
      _emailInvalid = false;
      _emailMessage = null;
    });
    try {
      final request = await _codes.requestCode(email);
      if (!mounted) return;
      final id = request.challengeId;
      if (id == null) {
        // A cooldown for a code this screen did not ask for: no code step
        // without a challenge. Show the wait and let Continue try again later.
        _waitEmail = email.toLowerCase();
        _wait.start(request.resendAfterSeconds);
      } else {
        _wait.stop();
        _waitEmail = null;
        _openCodeStep(email, id, request.resendAfterSeconds);
      }
    } on EmailCodeException catch (error) {
      if (!mounted) return;
      switch (error.failure) {
        case EmailCodeFailure.invalidEmail:
          _refuseEmail('Enter a full email address, like juan@gmail.com.');
        case EmailCodeFailure.tooManyRequests:
          setState(() {
            _emailMessage = 'Too many codes requested. Try again later.';
          });
        case _:
          setState(() {
            _emailMessage = "We couldn't send the code. Try again.";
          });
      }
    } on Object {
      if (mounted) {
        setState(() => _emailMessage = "We couldn't send the code. Try again.");
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _refuseEmail(String message) {
    setState(() {
      _emailInvalid = true;
      _emailMessage = message;
      _emailShake++;
    });
    _emailFocus.requestFocus();
  }

  Future<void> _google() async {
    if (_googleBusy || _sending) return;
    setState(() {
      _googleBusy = true;
      _emailInvalid = false;
      _emailMessage = null;
    });
    // An account switch signs the old session out first. Without the hold the
    // gate rebuilds this screen then, and its dispose cancels the switch
    // halfway (Nov 7). The code check holds the gate the same way.
    _hold.state = true;
    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!mounted) return;
      if (result is FailedSignInResult) {
        _hold.state = false;
        setState(() => _emailMessage = "We couldn't sign you in. Try again.");
      } else if (result is CancelledSignInResult) {
        _hold.state = false;
      } else {
        // The access check reruns for the new account.
        ref.invalidate(betaAccessProvider);
        _hold.state = false;
        _leave();
      }
    } on Object {
      if (mounted) {
        _hold.state = false;
        setState(() => _emailMessage = "We couldn't sign you in. Try again.");
      }
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  // ------------------------------------------------------------- code step

  void _openCodeStep(String email, String challengeId, int resendAfterSeconds) {
    _wrongTimer?.cancel();
    _code.clear();
    _flow++;
    _resend.start(resendAfterSeconds);
    setState(() {
      _sentTo = email;
      _challengeId = challengeId;
      _step = _Step.code;
      _phase = _Phase.entering;
      _codeMessage = null;
    });
  }

  void _onCodeChanged(String text) {
    var changed = false;
    if (_phase == _Phase.wrong || _phase == _Phase.wrongFading) {
      // Typing again ends the wrong-code beat at once.
      _wrongTimer?.cancel();
      _phase = _Phase.entering;
      changed = true;
    }
    if (_codeMessage != null && _phase == _Phase.entering) {
      _codeMessage = null;
      changed = true;
    }
    if (changed) setState(() {});
    if (text.length == 6) unawaited(_verify());
  }

  void _submitCode() {
    if (_code.text.length == 6) {
      unawaited(_verify());
    } else {
      setState(() => _codeShake++);
      _codeFocus.requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_celebrating || _phase == _Phase.expired) return;
    final code = _code.text;
    final challengeId = _challengeId;
    // A new code is on its way: this one is about to be replaced.
    if (code.length != 6 || challengeId == null || _resending) return;
    final flow = _flow;
    setState(() {
      _phase = _Phase.verifying;
      _codeMessage = null;
    });
    _hold.state = true;
    try {
      final result = await _codes.verifyCode(challengeId, code);
      if (!mounted || flow != _flow) return;
      if (result is FailedSignInResult || result is CancelledSignInResult) {
        _failCode("We couldn't sign you in. Try again.");
      } else {
        _signedIn();
      }
    } on EmailCodeException catch (error) {
      if (mounted && flow == _flow) _codeRefused(error);
    } on Object {
      if (mounted && flow == _flow) {
        _failCode("We couldn't sign you in. Try again.");
      }
    }
  }

  void _signedIn() {
    // The access check reruns for the new account while the check mark plays.
    ref.invalidate(betaAccessProvider);
    setState(() => _phase = _Phase.signedIn);
    _holdTimer = Timer(signInHold, () {
      if (!mounted) return;
      _hold.state = false;
      // If the account is not on the list, the next screen takes over now.
      setState(() => _released = true);
      _leave();
    });
  }

  void _codeRefused(EmailCodeException error) {
    switch (error.failure) {
      case EmailCodeFailure.wrong:
        _showWrongCode();
      case EmailCodeFailure.expired:
        _expireCode('This code expired. Get a new one to keep going.');
      case EmailCodeFailure.tooManyTries:
        _expireCode('Too many tries. Get a new code to keep going.');
      case EmailCodeFailure.rateLimited:
        _failCode('Too many tries. Try again later.');
      case EmailCodeFailure.disabled:
        _failCode("This account can't sign in. Write to $supportEmail.");
      case _:
        _failCode("We couldn't sign you in. Try again.");
    }
  }

  void _failCode(String message) {
    _hold.state = false;
    setState(() {
      _phase = _Phase.entering;
      _codeMessage = message;
      _codeMessageIsError = false;
    });
  }

  void _expireCode(String message) {
    _hold.state = false;
    _code.clear();
    setState(() {
      _phase = _Phase.expired;
      _codeMessage = message;
      _codeMessageIsError = false;
    });
  }

  void _showWrongCode() {
    _hold.state = false;
    setState(() {
      _phase = _Phase.wrong;
      _codeMessage = "That code isn't right. Check the email and try again.";
      _codeMessageIsError = true;
      _codeShake++;
    });
    _wrongTimer?.cancel();
    _wrongTimer = Timer(_wrongHold, () {
      if (!mounted) return;
      setState(() => _phase = _Phase.wrongFading);
      _wrongTimer = Timer(_wrongFade, () {
        if (!mounted) return;
        _code.clear();
        setState(() => _phase = _Phase.entering);
        _codeFocus.requestFocus();
      });
    });
  }

  Future<void> _resendCode() async {
    if (_resending || _celebrating) return;
    final flow = _flow;
    setState(() {
      _resending = true;
      _codeMessage = null;
    });
    try {
      final request = await _codes.requestCode(_sentTo);
      if (!mounted || flow != _flow || _celebrating) return;
      _resend.start(request.resendAfterSeconds);
      final id = request.challengeId;
      if (id == null) {
        // Still cooling down from an earlier code: nothing new was sent.
        if (_phase == _Phase.expired) {
          setState(() {
            final wait = _clock(request.resendAfterSeconds);
            _codeMessage = 'You can request a code in $wait.';
            _codeMessageIsError = false;
          });
        }
        return;
      }
      _wrongTimer?.cancel();
      _code.clear();
      setState(() {
        _challengeId = id;
        _phase = _Phase.entering;
      });
      _codeFocus.requestFocus();
    } on EmailCodeException catch (error) {
      if (!mounted || flow != _flow) return;
      setState(() {
        _codeMessage = error.failure == EmailCodeFailure.tooManyRequests
            ? 'Too many codes requested. Try again later.'
            : "We couldn't send the code. Try again.";
        _codeMessageIsError = false;
      });
    } on Object {
      if (mounted && flow == _flow) {
        setState(() {
          _codeMessage = "We couldn't send the code. Try again.";
          _codeMessageIsError = false;
        });
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _useDifferentEmail() {
    if (_phase == _Phase.signedIn) return;
    // Leaving cancels any check in flight and ends the hold, whatever the
    // screen shows: the check's token must not sign anyone in.
    _codes.cancelVerification();
    _hold.state = false;
    _flow++;
    _wrongTimer?.cancel();
    _resend.stop();
    _code.clear();
    _challengeId = null;
    setState(() {
      _resending = false;
      _step = _Step.email;
      _phase = _Phase.entering;
      _codeMessage = null;
      _emailInvalid = false;
      _emailMessage = null;
    });
  }

  // ----------------------------------------------------------- not on list

  Future<void> _signOutToEmail() async {
    if (_signingOut) return;
    _codes.cancelVerification();
    _hold.state = false;
    setState(() => _signingOut = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      _flow++;
      _resend.stop();
      _wait.stop();
      _challengeId = null;
      _email.clear();
      _code.clear();
      setState(() {
        _step = _Step.email;
        _phase = _Phase.entering;
        _emailInvalid = false;
        _emailMessage = null;
      });
    } on Object {
      // The gate stays on this screen; the button works again.
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  void _leave() {
    ref.invalidate(betaAccessProvider);
    context.go(widget.beta ? '/beta' : '/home');
  }

  // ------------------------------------------------------------------ view

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= signInWideFrom;
    final style = SignInStyle(context, wide: wide);
    final denied = widget.denied && (!_celebrating || _released);
    return SignInFrame(
      child: denied
          ? _NotOnList(
              style: style,
              email: _signedInEmail(),
              busy: _signingOut,
              onSwitch: _signOutToEmail,
            )
          : wide
              ? _wideLayout(style)
              : _phoneLayout(style),
    );
  }

  String _signedInEmail() {
    final state = ref.watch(authStateProvider).valueOrNull;
    return state is SignedInAuthState ? state.user.email : '';
  }

  Widget _logo(SignInStyle style) {
    final size = style.wide ? 120.0 : 104.0;
    return Center(
      child: StartAfter(
        delay: const Duration(milliseconds: 100),
        placeholder: SizedBox.square(dimension: size),
        child: PantasEffects.pop(
          duration: const Duration(milliseconds: 600),
          builder: (context, _, child) => child!,
          child: PantasLogo(size: size),
        ),
      ),
    );
  }

  Widget _phoneLayout(SignInStyle style) {
    return SignInScroll(
      builder: (_) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 132),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _logo(style),
                const SizedBox(height: 28),
                SignInRise(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: StepSwitcher(stepKey: _step, child: _header(style)),
                ),
              ],
            ),
          ),
          SignInRise(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 450),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
              child: StepSwitcher(
                stepKey: _step,
                delay: const Duration(milliseconds: 100),
                child: _form(style),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The email step's nominal height: logo, text and form. The logo sits where
  // the laptop board puts it, and the code step grows downward from there so
  // the logo never moves between steps.
  static const _wideContent = 468.0;

  Widget _wideLayout(SignInStyle style) {
    return SignInScroll(
      builder: (height) {
        // Page padding 40 and 28, plus the support line and its 24 px gap.
        final top = math.max<double>(0, (height - 110 - _wideContent) / 2);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(top: top),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _logo(style),
                      const SizedBox(height: 32),
                      SignInRise(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 300),
                        child: StepSwitcher(
                          stepKey: _step,
                          child: _header(style),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SignInRise(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 450),
                        child: StepSwitcher(
                          stepKey: _step,
                          delay: const Duration(milliseconds: 100),
                          child: _form(style),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SupportLine(style: style),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(SignInStyle style) {
    final wide = style.wide;
    final gap = wide ? 12.0 : 10.0;
    final side = wide ? 0.0 : (_step == _Step.email ? 20.0 : 24.0);
    final Widget title;
    final Widget subtitle;
    if (_step == _Step.email) {
      title = Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Welcome to Pantas'),
            if (widget.beta)
              WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: wide ? 6 : 4, top: wide ? 7 : 5),
                  child: Text(
                    'BETA',
                    style: style.input.copyWith(
                      fontSize: wide ? 13 : 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: wide ? 1.04 : 0.88,
                      height: 1,
                      color: style.accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
        textAlign: TextAlign.center,
        style: style.title,
      );
      subtitle = Text(
        widget.beta
            ? 'Sign in with the email you applied with.'
            : 'Sign in with your email.',
        textAlign: TextAlign.center,
        style: style.subtitle,
      );
    } else {
      title = Text(
        'Enter the code',
        textAlign: TextAlign.center,
        style: style.title,
      );
      subtitle = Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'We sent a 6-digit code to '),
            TextSpan(text: _sentTo, style: style.emphasis),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
        style: style.subtitle,
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: side),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [title, SizedBox(height: gap), subtitle],
      ),
    );
  }

  Widget _label(SignInStyle style, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Text(text, style: style.fieldLabel),
      );

  Widget _form(SignInStyle style) =>
      _step == _Step.email ? _emailForm(style) : _codeForm(style);

  Widget _emailForm(SignInStyle style) {
    final wide = style.wide;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(style, 'Email'),
        SignInShake(
          tick: _emailShake,
          child: SignInField(
            controller: _email,
            focusNode: _emailFocus,
            style: style,
            invalid: _emailInvalid,
            onChanged: (text) {
              // A different address is not waiting on the old cooldown.
              if (_waitEmail != null &&
                  text.trim().toLowerCase() != _waitEmail) {
                _wait.stop();
                _waitEmail = null;
              }
              if (_emailInvalid || _emailMessage != null) {
                setState(() {
                  _emailInvalid = false;
                  _emailMessage = null;
                });
              }
            },
            onSubmitted: _continueEmail,
          ),
        ),
        SignInMessage(
          message: _emailMessage,
          style: style,
          top: 8,
          gap: 12,
          error: _emailInvalid,
          // The message follows the shake by a beat.
          delay: const Duration(milliseconds: 100),
        ),
        SignInButton(
          label: 'Continue',
          style: style,
          state: _sending ? SignInButtonState.busy : SignInButtonState.idle,
          keyHint: wide ? 'Enter' : null,
          onPressed: _continueEmail,
        ),
        ValueListenableBuilder<int>(
          valueListenable: _wait.left,
          builder: (context, left, _) => SmoothSize(
            child: left > 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'You can request a code in ${_clock(left)}.',
                      textAlign: TextAlign.center,
                      style: style.small,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
        const SizedBox(height: 8),
        SignInTextButton(
          label: 'Use Google Instead',
          style: style,
          icon: const GoogleMark(),
          onPressed: _google,
        ),
        if (!wide) ...[
          const SizedBox(height: 14),
          SupportLine(style: style),
        ],
      ],
    );
  }

  CodeTone get _tone => switch (_phase) {
        _Phase.signedIn => CodeTone.ok,
        _Phase.wrong => CodeTone.bad,
        _Phase.wrongFading => CodeTone.fadingBad,
        _ => CodeTone.normal,
      };

  Widget _codeForm(SignInStyle style) {
    final wide = style.wide;
    final expired = _phase == _Phase.expired;
    final button = expired
        ? SignInButton(
            label: 'Send a New Code',
            style: style,
            state: _resending ? SignInButtonState.busy : SignInButtonState.idle,
            onPressed: _resendCode,
          )
        : SignInButton(
            label: 'Continue',
            style: style,
            state: switch (_phase) {
              _Phase.verifying => SignInButtonState.busy,
              _Phase.signedIn => SignInButtonState.done,
              _ => SignInButtonState.idle,
            },
            keyHint: wide ? 'Enter' : null,
            onPressed: _submitCode,
          );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(style, 'Code'),
        CodeBoxes(
          controller: _code,
          focusNode: _codeFocus,
          style: style,
          formatter: _formatter,
          tone: _tone,
          shakeTick: _codeShake,
          locked: _celebrating,
          dimmed: expired,
          onChanged: _onCodeChanged,
          onSubmitted: _submitCode,
        ),
        SignInMessage(
          message: _codeMessage,
          style: style,
          top: 10,
          gap: _codeMessage == null ? 16 : 12,
          error: _codeMessageIsError,
          delay: Duration(milliseconds: _codeMessageIsError ? 120 : 200),
          duration: Duration(milliseconds: _codeMessageIsError ? 180 : 300),
        ),
        button,
        if (expired) ...[
          const SizedBox(height: 8),
          SignInTextButton(
            label: 'Use a Different Email',
            style: style,
            onPressed: _useDifferentEmail,
          ),
          if (!wide) ...[
            const SizedBox(height: 14),
            SupportLine(style: style),
          ],
        ] else ...[
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _resend.left,
            builder: (context, left, _) => left > 0
                ? Text(
                    "Didn't get it? You can resend in ${_clock(left)}.",
                    textAlign: TextAlign.center,
                    style: style.small,
                  )
                : LinkLine(
                    prefix: "Didn't get it? ",
                    link: 'Resend Code',
                    bold: true,
                    style: style,
                    onTap: _resendCode,
                  ),
          ),
          const SizedBox(height: 6),
          SignInTextButton(
            label: 'Use a Different Email',
            style: style,
            onPressed: _useDifferentEmail,
          ),
        ],
      ],
    );
  }

  static String _clock(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// The "not on the beta list" screen.
class _NotOnList extends StatelessWidget {
  const _NotOnList({
    required this.style,
    required this.email,
    required this.busy,
    required this.onSwitch,
  });

  final SignInStyle style;
  final String email;
  final bool busy;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final wide = style.wide;
    final Widget explanation = Text.rich(
      TextSpan(
        children: email.isEmpty
            ? const [
                TextSpan(
                  text: "You're signed in. If you applied with a different "
                      'email, sign in with that one.',
                ),
              ]
            : [
                const TextSpan(text: "You're signed in as "),
                TextSpan(text: email, style: style.emphasis),
                const TextSpan(
                  text: '. If you applied with a different email, sign in '
                      'with that one.',
                ),
              ],
      ),
      textAlign: TextAlign.center,
      style: style.subtitle,
    );
    final top = SignInRise(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: wide ? 0 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LockMark(color: style.lock),
            const SizedBox(height: 22),
            Text(
              "This email isn't on the beta list",
              textAlign: TextAlign.center,
              style: style.title,
            ),
            const SizedBox(height: 8),
            explanation,
          ],
        ),
      ),
    );
    final bottom = SignInRise(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 150),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SignInButton(
            label: 'Use a Different Email',
            style: style,
            tonal: true,
            state: busy ? SignInButtonState.busy : SignInButtonState.idle,
            onPressed: onSwitch,
          ),
          const SizedBox(height: 14),
          SupportLine(
            style: style,
            note: 'Selected testers get an email from Pantas.\n',
          ),
        ],
      ),
    );
    if (wide) {
      return SignInScroll(
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [top, const SizedBox(height: 32), bottom],
              ),
            ),
          ),
        ),
      );
    }
    return SignInScroll(
      builder: (_) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.only(top: 196), child: top),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
            child: bottom,
          ),
        ],
      ),
    );
  }
}

/// A whole-second countdown that other widgets can listen to.
class _Countdown {
  final left = ValueNotifier<int>(0);
  Timer? _timer;

  void start(int seconds) {
    _timer?.cancel();
    left.value = math.max(0, seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (left.value <= 1) {
        left.value = 0;
        timer.cancel();
      } else {
        left.value -= 1;
      }
    });
  }

  void stop() {
    _timer?.cancel();
    left.value = 0;
  }

  void dispose() {
    _timer?.cancel();
    left.dispose();
  }
}
