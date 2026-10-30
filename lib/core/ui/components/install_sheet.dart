import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Opens the iPhone "Show Me How" sheet: three steps to add Pantas to the
/// Home Screen (PWA install board, option A).
Future<void> showInstallSheet(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: dark ? const Color(0x8C000000) : const Color(0x521D1D1F),
    barrierLabel: 'Close',
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (context) => const InstallSheet(),
  );
}

class InstallSheet extends StatelessWidget {
  const InstallSheet({super.key});

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
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: t.dark ? Border.all(color: t.cardEdge) : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 60,
              offset: Offset(0, -20),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 34),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: c.separator,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  'Add Pantas to your Home Screen',
                  style: t.h2.copyWith(fontSize: 22, letterSpacing: -.396),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Then it opens like any app. Your progress stays the same.',
                style: t.sub,
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < _steps.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _Step(
                  number: i + 1,
                  title: _steps[i].$1,
                  detail: _steps[i].$2,
                ),
              ],
              const SizedBox(height: 14),
              const _SafariBar(),
              const SizedBox(height: 16),
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
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: t.colors.separator, width: 1.5),
          ),
          child: ExcludeSemantics(
            child: Text(
              '$number',
              style: t.style(
                14,
                weight: FontWeight.w600,
                color: t.colors.secondaryLabel,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Semantics(
            label: 'Step $number. $title. $detail',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.style(16, weight: FontWeight.w600)),
                Text(
                  detail,
                  style: t.style(14, color: t.colors.secondaryLabel),
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
    final muted = t.colors.tertiaryLabel;
    Widget icon(String shapes, Color color) => SvgPicture.string(
          _icon(shapes, color),
          width: 22,
          height: 22,
        );
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: t.colors.fill,
          borderRadius: BorderRadius.circular(14),
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
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.colors.accent, width: 2),
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
