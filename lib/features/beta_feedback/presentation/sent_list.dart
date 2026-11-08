import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';

String sentItemPath(String id) => '/settings/beta-feedback/sent/$id';

/// What a sent row says: the tester's text, or the image count when there is
/// no text.
String sentLine(SentFeedback item) => item.text.trim().isEmpty
    ? imageCount(item.attachments.length)
    : item.text.trim();

/// The "SENT" header and card. A row that arrives after the list is first
/// shown slides in at the top.
class SentSection extends StatefulWidget {
  const SentSection({required this.items, super.key});
  final List<SentFeedback> items;

  @override
  State<SentSection> createState() => _SentSectionState();
}

class _SentSectionState extends State<SentSection> {
  late final Set<String> _known = {for (final i in widget.items) i.id};
  final _fresh = <String>{};

  @override
  void didUpdateWidget(SentSection old) {
    super.didUpdateWidget(old);
    for (final item in widget.items) {
      if (_known.add(item.id)) _fresh.add(item.id);
    }
  }

  Widget _row(List<SentFeedback> items, int i) {
    final row = _SentRow(item: items[i], last: i == items.length - 1);
    if (!_fresh.contains(items[i].id)) return row;
    return _Insert(key: ValueKey('sent-new-${items[i].id}'), child: row);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();
    final wide = context.fbWide;
    return Padding(
      padding: EdgeInsets.only(top: wide ? PantasSpace.s28 : PantasSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FbSectionHeader('SENT'),
          FbCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) _row(items, i),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A new row: grows from nothing, fading in and rising 8 px (300 ms).
class _Insert extends StatelessWidget {
  const _Insert({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: PantasDurations.flip,
      curve: PantasCurves.enter,
      builder: (context, e, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: e.clamp(0.0, 1.0),
          child: Opacity(
            opacity: e.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 8 * (1 - e)),
              child: child,
            ),
          ),
        ),
      ),
      child: child,
    );
  }
}

class _SentRow extends StatelessWidget {
  const _SentRow({required this.item, required this.last});
  final SentFeedback item;
  final bool last;

  void _open(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router != null) unawaited(router.push<void>(sentItemPath(item.id)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    final images = item.attachments.length;
    final hasText = item.text.trim().isNotEmpty;
    if (context.fbWide) {
      final meta = images > 0 && hasText
          ? '${imageCount(images)} · ${monthDay(item.createdAt)}'
          : monthDay(item.createdAt);
      return WebRow(
        title: sentLine(item),
        titleStyle: PantasType.webBody.copyWith(color: c.textPrimary),
        value: meta,
        valueStyle: PantasType.webSub.copyWith(color: c.textSecondary),
        horizontalPadding: 16,
        verticalPadding: 12,
        compact: true,
        divider: !last,
        chevron: WebRowChevron.always,
        onPressed: () => _open(context),
      );
    }
    final meta = images > 0 && hasText
        ? '${stamp(item.createdAt)} · ${imageCount(images)}'
        : stamp(item.createdAt);
    return ListRow(
      title: sentLine(item),
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sentLine(item),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: PantasType.phoneSubhead.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: PantasSpace.s2),
          Text(meta, style: context.fbSmall),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        PantasSpace.s16,
        PantasSpace.s12,
        PantasSpace.s16,
        PantasSpace.s12,
      ),
      divider: !last,
      dividerInset: 16,
      onTap: () => _open(context),
    );
  }
}
