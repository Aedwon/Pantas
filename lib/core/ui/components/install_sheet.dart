import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Opens the iPhone "Show Me How" sheet: three steps to add Pantas to the
/// Home Screen (PWA install board, option A).
Future<void> showInstallSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: context.colors.scrim,
    barrierLabel: 'Close',
    constraints: const BoxConstraints(maxWidth: PantasLayout.search),
    builder: (context) => const InstallSheet(),
  );
}

class InstallSheet extends StatelessWidget {
  const InstallSheet({super.key});

  /// The sheet clears the home indicator: 34 below the last control.
  /// The grabber is 36 wide and 5 high.
  static const double _grabberWidth = PantasSpace.s32 + PantasSpace.s4;
  static const double _grabberHeight = PantasSpace.s4 + 1;

  static const double _bottom = PantasSpace.s32 + PantasSpace.s2;

  static const _steps = <(String, String)>[
    ('Tap Share', 'It is in the Safari toolbar at the bottom.'),
    ('Tap Add to Home Screen', 'Scroll down in the list to find it.'),
    ('Tap Add', 'Pantas appears on your Home Screen.'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: 'Add Pantas to your Home Screen',
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceModal,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(PantasRadius.lg),
          ),
          boxShadow: context.shadows.sheet,
        ),
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s20,
          PantasSpace.s8,
          PantasSpace.s20,
          _bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  key: const ValueKey('install-sheet-grabber'),
                  width: _grabberWidth,
                  height: _grabberHeight,
                  decoration: BoxDecoration(
                    color: c.dividerStrong,
                    borderRadius: BorderRadius.circular(PantasRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: PantasSpace.s16),
              Semantics(
                header: true,
                child: Text(
                  'Add Pantas to your Home Screen',
                  style: PantasType.phoneTitle3.copyWith(color: c.textPrimary),
                ),
              ),
              const SizedBox(height: PantasSpace.s6),
              Text(
                'Then it opens like any app. Your progress stays the same.',
                style: t.sub,
              ),
              const SizedBox(height: PantasSpace.s18),
              for (var i = 0; i < _steps.length; i++) ...[
                if (i > 0) const SizedBox(height: PantasSpace.s14),
                _Step(
                  number: i + 1,
                  title: _steps[i].$1,
                  detail: _steps[i].$2,
                ),
              ],
              const SizedBox(height: PantasSpace.s14),
              const _SafariBar(),
              const SizedBox(height: PantasSpace.s16),
              Align(
                alignment: Alignment.centerRight,
                child: WebButton(
                  label: 'Got It',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.detail,
  });

  final int number;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: PantasSize.avatar,
          height: PantasSize.avatar,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: t.colors.divider,
              width: PantasBorder.ringStrong,
            ),
          ),
          child: ExcludeSemantics(
            child: Text(
              '$number',
              style: PantasType.webLabel.copyWith(
                color: t.colors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: PantasSpace.s14),
        Expanded(
          child: Semantics(
            label: 'Step $number. $title. $detail',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PantasType.webTitleSm.copyWith(
                    color: t.colors.textPrimary,
                  ),
                ),
                Text(
                  detail,
                  style: PantasType.webRowSub.copyWith(
                    color: t.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A picture of Safari's bottom toolbar with the Share button ringed.
class _SafariBar extends StatelessWidget {
  const _SafariBar();

  static final _sharePaths = [
    '<path d="M12 15V3"/>',
    '<path d="m8 7 4-4 4 4"/>',
    '<path d="M7 10H6a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-8a1 1 0 0 0-1-1h-1"/>', // ignore: lines_longer_than_80_chars
  ].join();

  static String _icon(String shapes, Color color) {
    final hex = (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
        'fill="none" stroke="#$hex" stroke-width="1.8" '
        'stroke-linecap="round" stroke-linejoin="round">$shapes</svg>';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final muted = t.colors.iconMuted;
    Widget icon(String shapes, Color color) => SvgPicture.string(
          _icon(shapes, color),
          width: 22,
          height: 22,
        );
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PantasSpace.s18,
          vertical: PantasSpace.s10,
        ),
        decoration: BoxDecoration(
          color: t.colors.fill,
          borderRadius: BorderRadius.circular(PantasRadius.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            icon('<path d="m14.5 5.5-6.5 6.5 6.5 6.5"/>', muted),
            icon('<path d="m9.5 5.5 6.5 6.5-6.5 6.5"/>', muted),
            // The ring sits outside the 22 point layout box, as drawn.
            SizedBox.square(
              dimension: 22,
              child: OverflowBox(
                maxWidth: 36,
                maxHeight: 36,
                child: Container(
                  key: const ValueKey('install-share-ring'),
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(PantasRadius.md),
                    border: Border.all(
                      color: t.colors.accent,
                      width: PantasBorder.ringSelected,
                    ),
                  ),
                  child: icon(_sharePaths, t.colors.accent),
                ),
              ),
            ),
            icon('<path d="M5 5.5h14v14H5z"/><path d="M12 5.5v14"/>', muted),
            icon(
              [
                '<rect x="4" y="6" width="12" height="12" rx="2"/>',
                '<path d="M8 6V4h12v12h-2"/>',
              ].join(),
              muted,
            ),
          ],
        ),
      ),
    );
  }
}
