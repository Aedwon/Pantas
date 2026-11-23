import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:pantas/core/config/seller_facts.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/paywall/domain/checkout_declaration.dart';

/// The declaration tick beside Pay on every web checkout (boards CB_Ph,
/// CB_Wide, S4P_T, S4W_T). Unchecked at first. The link opens the Terms and
/// never ticks the box; it takes keyboard focus and Enter opens it.
class DeclarationCard extends StatelessWidget {
  const DeclarationCard({
    required this.kind,
    required this.ticked,
    required this.onToggle,
    required this.onOpenTerms,
    super.key,
  });

  final DeclarationKind kind;
  final bool ticked;

  /// Null while a payment is in progress.
  final VoidCallback? onToggle;
  final VoidCallback onOpenTerms;

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final style = PantasType.webRowTitleSettings
        .copyWith(color: context.colors.textPrimary);
    final row = CheckboxRow(
      title: declarationLabel(kind),
      selected: ticked,
      gap: PantasSpace.s14,
      standardDensity: true,
      squareEdges: wide,
      interactiveContent: true,
      onTap: onToggle,
      // One text flow, so the sentence wraps as one. The link is a span.
      content: Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(text: declarationLead(kind)),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: _TermsLink(
                style: style.copyWith(color: context.webTokens.colors.accent),
                onOpen: onOpenTerms,
              ),
            ),
            const TextSpan(text: declarationTail),
          ],
        ),
      ),
    );
    return wide ? WebCard(child: row) : GroupedSection(children: [row]);
  }
}

/// A link that tabs, shows focus, and opens on a tap or Enter. A tap on it
/// does not reach the row, so the box does not change.
class _TermsLink extends StatelessWidget {
  const _TermsLink({required this.style, required this.onOpen});
  final TextStyle style;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        link: true,
        label: declarationLink,
        excludeSemantics: true,
        onTap: onOpen,
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                onOpen();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onOpen,
            child: Text(declarationLink, style: style),
          ),
        ),
      );
}

/// The seller line beside Pay (ruling D3): the proprietor, trading name, place,
/// phone and support email. The email is a mail link. A fact that is missing
/// shows as a visible bracket.
class SellerLine extends StatefulWidget {
  const SellerLine({
    required this.facts,
    required this.style,
    required this.textAlign,
    required this.onEmail,
    super.key,
  });

  final SellerFacts facts;
  final TextStyle style;
  final TextAlign textAlign;
  final VoidCallback onEmail;

  @override
  State<SellerLine> createState() => _SellerLineState();
}

class _SellerLineState extends State<SellerLine> {
  final _tap = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _tap.onTap = widget.onEmail;
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          style: widget.style,
          children: [
            TextSpan(text: widget.facts.lineBeforeEmail),
            TextSpan(
              text: sellerEmail,
              style: widget.style.copyWith(
                color: context.webTokens.colors.accent,
              ),
              recognizer: _tap,
              mouseCursor: SystemMouseCursors.click,
            ),
          ],
        ),
        textAlign: widget.textAlign,
      );
}
