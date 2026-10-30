import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/settings.dart';

class NamePage extends ConsumerStatefulWidget {
  const NamePage({super.key});
  @override
  ConsumerState<NamePage> createState() => _NamePageState();
}

class _NamePageState extends ConsumerState<NamePage> {
  final _controller = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  bool _failed = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _back() async {
    if (_saving || !_loaded) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      await ref.read(settingsActionsProvider).setName(_controller.text);
      if (mounted) Navigator.of(context).pop();
    } catch (error, stack) {
      await telemetry.recordError(error, stack);
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    if (!_loaded && settings.hasValue) {
      _controller.text = settings.value!.name ?? '';
      _loaded = true;
    }
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: SettingsPanePage(
        section: 'Account',
        title: 'Name',
        backLabel: 'Account',
        onBack: _saving ? null : _back,
        children: [
          if (context.wideWeb)
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _controller,
                      enabled: _loaded && !_saving,
                      style: context.webTokens.style(16),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        filled: true,
                        fillColor: context.webTokens.colors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.webTokens.colors.separator,
                          ),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _back(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shown on Home and on your profile. '
                      'Clear it to remove your name.',
                      style: context.webTokens.sm,
                    ),
                  ],
                ),
              ),
            )
          else
            SettingsSection(
              footer:
                  'Shown on Home and on your profile. Clear it to remove your '
                  'name.',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _controller,
                    enabled: _loaded && !_saving,
                    decoration: const InputDecoration(border: InputBorder.none),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _back(),
                  ),
                ),
              ],
            ),
          if (_failed) saveFailureLine(_back),
        ],
      ),
    );
  }
}
