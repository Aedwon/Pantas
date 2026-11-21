import 'dart:async';

import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/onboarding/presentation/child/child_step_frame.dart';

/// Where the nickname step opens after the short child notice.
const String childNicknamePath = '/onboarding/child/nickname';

/// Board S7N: the nickname step. It serves setup and Add a Child, so it only
/// collects the nickname. [onSubmit] saves it and throws if it could not;
/// [onDone] runs after a save.
class ChildNicknameScreen extends StatefulWidget {
  const ChildNicknameScreen({
    required this.onSubmit,
    required this.onDone,
    super.key,
  });

  final Future<void> Function(String nickname) onSubmit;
  final VoidCallback onDone;

  @override
  State<ChildNicknameScreen> createState() => _ChildNicknameScreenState();
}

class _ChildNicknameScreenState extends State<ChildNicknameScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _ready => _controller.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (_saving || !_ready) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_controller.text.trim());
      if (mounted) widget.onDone();
    } on Object {
      if (mounted) setState(() => _error = ChildSetupCopy.nicknameFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ChildStepFrame(
        title: ChildSetupCopy.nicknameTitle,
        actions: [
          ChildStepButton(
            label: ChildSetupCopy.nicknameContinue,
            busy: _saving,
            onPressed: _ready && !_saving ? () => unawaited(_save()) : null,
          ),
        ],
        children: [
          PantasField(
            label: ChildSetupCopy.nicknameLabel,
            controller: _controller,
            focusNode: _focus,
            helpText: ChildSetupCopy.nicknameHelp,
            errorText: _error,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.nickname],
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => unawaited(_save()),
          ),
        ],
      );
}
