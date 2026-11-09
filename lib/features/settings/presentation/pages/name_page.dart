import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/settings.dart';

/// The board's 20 px clear glyph (ST_Name).
final _clearGlyph = [
  '<svg viewBox="0 0 256 256"><path d="',
  'M165.66,101.66,139.31,128l26.35,26.34',
  'a8,8,0,0,1-11.32,11.32L128,139.31l-26',
  '.34,26.35a8,8,0,0,1-11.32-11.32L116.6',
  '9,128,90.34,101.66a8,8,0,0,1,11.32-11',
  '.32L128,116.69l26.34-26.35a8,8,0,0,1,',
  '11.32,11.32ZM232,128A104,104,0,1,1,12',
  '8,24,104.11,104.11,0,0,1,232,128Zm-16',
  ',0a88,88,0,1,0-88,88A88.1,88.1,0,0,0,',
  '216,128Z"/></svg>',
].join();

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

  /// Wide web saves as the student types (ST_Name). The phone saves on the way
  /// back, as its board says.
  Timer? _typing;
  Future<void> Function()? _flushTyping;
  @override
  void dispose() {
    // A name typed in the last moments is still saved when the page closes.
    final flush = _flushTyping;
    if (_typing?.isActive ?? false) {
      _typing!.cancel();
      if (flush != null) unawaited(flush());
    }
    _controller.dispose();
    super.dispose();
  }

  void _typed(String text) {
    final actions = ref.read(settingsActionsProvider);
    final telemetry = ref.read(telemetryProvider);
    Future<void> save() async {
      try {
        await actions.setName(text);
        if (mounted && _failed) setState(() => _failed = false);
      } catch (error, stack) {
        await telemetry.recordError(error, stack);
        if (mounted) setState(() => _failed = true);
      }
    }

    _flushTyping = save;
    _typing?.cancel();
    _typing = Timer(const Duration(milliseconds: 500), () {
      _typing = null;
      unawaited(save());
    });
  }

  Future<void> _back() async {
    if (_saving || !_loaded) return;
    _typing?.cancel();
    _typing = null;
    setState(() {
      _saving = true;
      _failed = false;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      await ref.read(settingsActionsProvider).setName(_controller.text);
      if (mounted) {
        leavePage(
          context,
          fallback: '/settings/account',
          respectPopScope: false,
        );
      }
    } catch (error, stack) {
      await telemetry.recordError(error, stack);
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  OutlineInputBorder _fieldBorder(BuildContext context, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(PantasRadius.md),
        borderSide: BorderSide(
          color: width > 1
              ? context.webTokens.colors.accent
              : context.webTokens.colors.separator,
          width: width,
        ),
      );

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
        compactTitle: true,
        backLabel: 'Account',
        onBack: _saving ? null : _back,
        children: [
          if (context.wideWeb)
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: PantasLayout.modal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Board `.field.focus`: 48 px, white, 2 px accent edge.
                    SizedBox(
                      height: PantasSize.field,
                      child: Semantics(
                        label: 'Name',
                        child: TextField(
                          // ds-raw: needs textCapitalization, no label
                          controller: _controller,
                          enabled: _loaded && !_saving,
                          style: PantasType.webRowTitleSettings
                              .copyWith(color: context.colors.textPrimary),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: context.webTokens.colors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: PantasSpace.s14,
                            ),
                            border: _fieldBorder(
                              context,
                              PantasBorder.ringSelected,
                            ),
                            enabledBorder: _fieldBorder(
                              context,
                              PantasBorder.ringSelected,
                            ),
                            focusedBorder: _fieldBorder(
                              context,
                              PantasBorder.ringSelected,
                            ),
                            disabledBorder:
                                _fieldBorder(context, PantasBorder.ring),
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: _typed,
                          onSubmitted: (_) => _back(),
                        ),
                      ),
                    ),
                    const SizedBox(height: PantasSpace.s8),
                    Text(
                      'Shown on Home and on your profile. '
                      'Clear it to remove your name. It saves as you type.',
                      style: context.webTokens.sm,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ST_Name: a 48 px white field, 14 px corners, a 1.5 px
                // accent edge and a clear button.
                Container(
                  height: PantasSize.field,
                  padding: const EdgeInsets.only(
                    left: PantasSpace.s16,
                    right: PantasSpace.s12,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(PantasRadius.lg),
                    border: Border.all(
                      color: context.colors.accent,
                      width: PantasBorder.ringStrong,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          // ds-raw: needs textCapitalization, no label
                          controller: _controller,
                          enabled: _loaded && !_saving,
                          style: context.type.body,
                          cursorColor: context.colors.accent,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) => _back(),
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (context, value, _) => value.text.isEmpty
                            ? const SizedBox.shrink()
                            : Semantics(
                                button: true,
                                label: 'Clear name',
                                excludeSemantics: true,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _controller.clear,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: PantasSpace.s8,
                                    ),
                                    child: SvgPicture.string(
                                      _clearGlyph,
                                      width: 20,
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        context.colors.chevron,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    PantasSpace.s6,
                    PantasSpace.s16,
                    PantasSpace.s0,
                  ),
                  child: Text(
                    'Shown on Home and on your profile. Clear it to remove '
                    'your name.',
                    style: context.type.footnote.copyWith(height: 1.4),
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
