import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/ink_magnifier.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';

/// The search field replacing the app bar title in place.
class SearchFieldBar extends ConsumerStatefulWidget {
  const SearchFieldBar({required this.onCancel, super.key});

  final VoidCallback onCancel;

  @override
  ConsumerState<SearchFieldBar> createState() => _SearchFieldBarState();
}

class _SearchFieldBarState extends ConsumerState<SearchFieldBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // A callback passed to onChanged, not a property setter: the lint reads the
  // one-line body and misses that this is a handler.
  // ignore: use_setters_to_change_properties
  void _onChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  void _handleCancel() {
    ref.read(searchQueryProvider.notifier).state = '';
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final corpusSizeAsync = ref.watch(searchCorpusSizeProvider);

    final corpusCount = corpusSizeAsync.valueOrNull ?? 0;
    final placeholder = 'Search $corpusCount lessons';

    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.ink,
            ),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkMagnifier(color: colors.inkMuted),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onChanged,
                style: styles.bodyLarge.copyWith(color: colors.ink),
                cursorColor: colors.ink,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: styles.bodyLarge.copyWith(color: colors.inkMuted),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              button: true,
              label: 'Cancel search',
              onTap: _handleCancel,
              child: ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _handleCancel,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: styles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
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
  }
}
