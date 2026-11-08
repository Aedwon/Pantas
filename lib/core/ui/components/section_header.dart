import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// The header above a section: an eyebrow title at the left and an optional
/// link at the right.
///
/// Wide screens use the 13/600 uppercase eyebrow (`web-eyebrow`). The phone
/// uses `phone-section-header`. Inside a card ([inCard]) the title is the
/// 20/700 `web-h3` and the side padding is gone, so title and link sit on the
/// card's own 20 inset (D184, D189). The row wraps when narrow, so the link
/// drops under a long title.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    this.link,
    this.phone = false,
    this.inCard = false,
    super.key,
  });

  final String title;

  /// The link at the right, usually a `WebTextLink`. Navigation only; an
  /// action that changes the section is a small tertiary button instead.
  final Widget? link;

  /// The phone header: `phone-section-header`, padding 0 16 7.
  final bool phone;

  /// Inside a card: `web-h3`, no side padding, 8 below.
  final bool inCard;

  /// The phone header's 7 below the text (phone board 0 16 7).
  static const double _phoneBelow = PantasSpace.s6 + PantasSpace.s2 / 2;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final TextStyle style;
    final String text;
    if (inCard) {
      style = PantasType.webH3.copyWith(color: c.textPrimary);
      text = title;
    } else if (phone) {
      style = PantasType.phoneSectionHeader.copyWith(color: c.textSecondary);
      text = title.toUpperCase();
    } else {
      style = PantasType.webEyebrow.copyWith(color: c.textSecondary);
      text = title.toUpperCase();
    }
    final padding = inCard
        ? const EdgeInsets.only(bottom: PantasSpace.s8)
        : phone
            ? const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s0,
                PantasSpace.s16,
                _phoneBelow,
              )
            : const EdgeInsets.fromLTRB(
                PantasSpace.s4,
                PantasSpace.s0,
                PantasSpace.s4,
                PantasSpace.s8,
              );
    return Padding(
      padding: padding,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: PantasSpace.s12,
        runSpacing: PantasSpace.s4,
        children: [
          Semantics(
            header: true,
            child: Text(text, style: style),
          ),
          if (link != null) link!,
        ],
      ),
    );
  }
}

/// The eyebrow above a desktop card (`.group-label`): padding 0 16 8.
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s16,
          PantasSpace.s0,
          PantasSpace.s16,
          PantasSpace.s8,
        ),
        child: Semantics(
          header: true,
          child: Text(
            text.toUpperCase(),
            style: PantasType.webEyebrow
                .copyWith(color: context.colors.textSecondary),
          ),
        ),
      );
}

/// The note under a card (`.group-note`): 13/400 `text-secondary`, padding 8
/// 16 0.
class GroupNote extends StatelessWidget {
  const GroupNote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s16,
          PantasSpace.s8,
          PantasSpace.s16,
          PantasSpace.s0,
        ),
        child: Text(
          text,
          style:
              PantasType.webSmall.copyWith(color: context.colors.textSecondary),
        ),
      );
}
