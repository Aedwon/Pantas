import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';

const addImageKey = ValueKey('add-image');
Key removeKey(int n) => ValueKey('remove-image-$n');

const _maxImages = 3;

/// The screenshot tiles. The system sets no size for them; the boards draw 64
/// on wide web and 72 on the phone.
const _thumbWide = 64.0;
const _thumbPhone = 72.0;
const _idChars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

/// 20 random letters and digits. A retry of the same draft reuses one.
String newFeedbackId() {
  final random = math.Random.secure();
  return String.fromCharCodes(
    List.generate(
      20,
      (_) => _idChars.codeUnitAt(random.nextInt(_idChars.length)),
    ),
  );
}

enum _Phase { idle, sending, done }

class _Draft {
  _Draft(this.id, this.image, this.riseDelay);
  final int id;
  final PickedImage image;
  final Duration riseDelay;
  bool leaving = false;
}

/// The text box, the screenshots and the Send Feedback button.
class FeedbackCompose extends ConsumerStatefulWidget {
  const FeedbackCompose({required this.onSent, super.key});

  /// Called with the row the server stored, so Sent can show it at once.
  final ValueChanged<SentFeedback> onSent;

  @override
  ConsumerState<FeedbackCompose> createState() => _FeedbackComposeState();
}

class _FeedbackComposeState extends ConsumerState<FeedbackCompose> {
  final _text = TextEditingController();
  final _drafts = <_Draft>[];
  final _focus = FocusNode();
  StreamSubscription<List<PickedImage>>? _drops;
  _Phase _phase = _Phase.idle;
  String? _feedbackId;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _text.addListener(_edited);
    _focus.addListener(_edited);
    _drops = ref.read(betaImageSourceProvider).dropsAndPastes().listen(_add);
  }

  @override
  void dispose() {
    unawaited(_drops?.cancel());
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _last = '';

  /// Storage takes a feedback id once and never changes it, so a changed
  /// draft needs a new id.
  void _edited() {
    if (_text.text != _last) {
      _last = _text.text;
      _feedbackId = null;
    }
    setState(() {});
  }

  Iterable<_Draft> get _active => _drafts.where((d) => !d.leaving);
  bool get _hasContent => _text.text.trim().isNotEmpty || _active.isNotEmpty;
  bool get _canSend => _phase == _Phase.idle && _hasContent;

  Future<void> _pick() async {
    final room = _maxImages - _active.length;
    if (room <= 0 || _phase != _Phase.idle) return;
    final picked = await ref.read(betaImageSourceProvider).pick(max: room);
    if (mounted) _add(picked);
  }

  void _add(List<PickedImage> picked) {
    if (!mounted || _phase != _Phase.idle) return;
    PickedImageProblem? first;
    var added = 0;
    setState(() {
      for (final image in picked) {
        final problem = problemWith(image);
        if (problem != null) {
          first ??= problem;
          continue;
        }
        if (_active.length >= _maxImages) continue;
        _drafts.add(
          _Draft(_nextId++, image, Duration(milliseconds: 80 * added)),
        );
        added++;
      }
    });
    if (added > 0) _feedbackId = null;
    final problem = first;
    if (problem != null) {
      showPantasToast(
        context,
        problem == PickedImageProblem.wrongType
            ? 'Use a PNG, JPEG or WebP image.'
            : 'Each image must be 5 MB or smaller.',
      );
    }
  }

  void _remove(_Draft draft) {
    _feedbackId = null;
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _drafts.remove(draft));
    } else {
      setState(() => draft.leaving = true);
    }
  }

  Future<void> _send() async {
    if (!_canSend) return;
    final text = _text.text.trim();
    final images = [for (final d in _active) d.image];
    final id = _feedbackId ??= newFeedbackId();
    setState(() => _phase = _Phase.sending);
    final SentFeedback sent;
    try {
      sent = await ref
          .read(betaFeedbackApiProvider)
          .send(feedbackId: id, text: text, images: images);
    } on Exception {
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      showPantasToast(context, 'Could not send. Try again.');
      return;
    }
    if (!mounted) return;
    widget.onSent(sent);
    final still = MediaQuery.disableAnimationsOf(context);
    if (!still) {
      // The check draws in 350 ms and holds 600 ms.
      setState(() => _phase = _Phase.done);
      await Future<void>.delayed(const Duration(milliseconds: 950));
      if (!mounted) return;
    }
    _last = '';
    _text.clear();
    setState(() {
      _drafts.clear();
      _feedbackId = null;
      _phase = _Phase.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    final active = _active.length;
    final fieldStyle = context.fbBody;
    final field = Semantics(
      label: 'Your feedback',
      textField: true,
      child: TextField(
        // ds-raw: shares one well with the screenshot tiles
        controller: _text,
        focusNode: _focus,
        readOnly: _phase != _Phase.idle,
        minLines: wide ? 4 : 5,
        maxLines: wide ? 4 : 5,
        keyboardType: TextInputType.multiline,
        style: fieldStyle,
        cursorColor: c.accent,
        decoration: InputDecoration.collapsed(
          hintText: 'What worked, what broke, what you would change',
          hintStyle: fieldStyle.copyWith(color: c.textSecondary),
        ),
      ),
    );
    final size = wide ? _thumbWide : _thumbPhone;
    final tiles = Row(
      children: [
        for (var i = 0; i < _drafts.length; i++) ...[
          _Thumb(
            key: ValueKey('thumb-${_drafts[i].id}'),
            draft: _drafts[i],
            number: i + 1,
            size: size,
            onRemove: () => _remove(_drafts[i]),
            onGone: () => setState(() => _drafts.remove(_drafts[i])),
          ),
        ],
        if (active < _maxImages)
          _AddTile(count: active, size: size, onTap: _pick),
        if (wide && active < _maxImages) ...[
          const SizedBox(width: PantasSpace.s16),
          Flexible(
            child: Text(
              'or drop or paste screenshots here',
              style: context.fbSmall,
            ),
          ),
        ],
      ],
    );
    final card = FbFieldWell(
      lit: _focus.hasFocus,
      padding: const EdgeInsets.all(PantasSpace.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [field, const SizedBox(height: PantasSpace.s14), tiles],
      ),
    );

    final applePlatform = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final chipOn = wide && WebKeyboardHints.visibleOf(context);
    final foreground =
        _canSend || _phase != _Phase.idle ? c.onAccent : c.textDisabled;
    final button = FbButton(
      onPressed: _canSend ? _send : null,
      busy: _phase != _Phase.idle,
      minWidth: wide ? 0 : null,
      child: switch (_phase) {
        _Phase.sending => const FbSpinner(),
        _Phase.done => FbDrawnGlyph(
            FbGlyphKind.check,
            key: const ValueKey('send-done'),
            size: PantasSize.icon,
            color: c.onAccent,
            stroke: 2.6,
          ),
        _Phase.idle => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Send Feedback'),
              if (chipOn) ...[
                const SizedBox(width: PantasSpace.s10),
                _KeyChip(
                  label: applePlatform ? '⌘ Enter' : 'Ctrl Enter',
                  color: foreground,
                ),
              ],
            ],
          ),
      },
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        const SizedBox(height: PantasSpace.s14),
        button,
      ],
    );
    if (!wide) return body;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.enter,
          meta: true,
          includeRepeats: false,
        ): _send,
        const SingleActivator(
          LogicalKeyboardKey.enter,
          control: true,
          includeRepeats: false,
        ): _send,
      },
      child: body,
    );
  }
}

class _KeyChip extends StatelessWidget {
  const _KeyChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Container(
          height: PantasSize.icon,
          padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(PantasRadius.xs),
          ),
          child: Text(
            label,
            style: PantasType.webKeyHintSm.copyWith(color: color),
          ),
        ),
      );
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.count,
    required this.size,
    required this.onTap,
  });
  final int count;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    return Semantics(
      button: true,
      label: 'Add image',
      excludeSemantics: true,
      child: GestureDetector(
        key: addImageKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: c.accentTint,
              borderRadius: BorderRadius.circular(PantasRadius.md),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FbGlyph(
                  FbGlyphKind.plus,
                  size: PantasSize.icon,
                  color: c.accentTintText,
                ),
                const SizedBox(height: PantasSpace.s2),
                Text(
                  '$count of $_maxImages',
                  style:
                      PantasType.webKeyHintSm.copyWith(color: c.accentTintText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.draft,
    required this.number,
    required this.size,
    required this.onRemove,
    required this.onGone,
    super.key,
  });
  final _Draft draft;
  final int number;
  final double size;
  final VoidCallback onRemove;
  final VoidCallback onGone;

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    final still = MediaQuery.disableAnimationsOf(context);

    final thumb = SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PantasRadius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: c.fill),
            Image.memory(
              draft.image.bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            Positioned(
              top: PantasSpace.s0,
              right: PantasSpace.s0,
              child: Semantics(
                button: true,
                label: 'Remove image $number',
                excludeSemantics: true,
                child: GestureDetector(
                  key: removeKey(number),
                  behavior: HitTestBehavior.opaque,
                  onTap: onRemove,
                  // The whole 44 corner takes the tap; the badge sits in it.
                  child: SizedBox.square(
                    dimension: PantasSize.targetTouch,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(PantasSpace.s4),
                        child: Container(
                          width: PantasSize.icon,
                          height: PantasSize.icon,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.scrim,
                            shape: BoxShape.circle,
                          ),
                          child: FbGlyph(
                            FbGlyphKind.close,
                            size: PantasSpace.s12,
                            color: c.onAccent,
                            stroke: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // Leaving fades and shrinks (160 ms, ease); arriving rises in.
    return TweenAnimationBuilder<double>(
      tween: Tween(end: draft.leaving ? 0 : 1),
      duration: still ? Duration.zero : PantasDurations.short2,
      curve: PantasCurves.fade,
      onEnd: () {
        if (draft.leaving) onGone();
      },
      builder: (context, v, child) => Align(
        alignment: Alignment.centerLeft,
        widthFactor: v,
        child: Opacity(opacity: v, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: PantasSpace.s10),
        child: FbRise(delay: draft.riseDelay, child: thumb),
      ),
    );
  }
}
