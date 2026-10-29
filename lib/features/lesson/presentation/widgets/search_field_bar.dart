import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';

class SearchFieldBar extends ConsumerWidget {
  const SearchFieldBar({
    required this.onCancel,
    this.onEditingChanged,
    this.entryAnimation = false,
    this.autofocus = false,
    super.key,
  });

  final bool entryAnimation;
  final bool autofocus;
  final VoidCallback onCancel;
  final ValueChanged<bool>? onEditingChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Material(
        type: MaterialType.transparency,
        child: SearchField(
          title: 'Study',
          autofocus: autofocus,
          fieldEntryDelay:
              entryAnimation ? const Duration(milliseconds: 100) : null,
          titleInset: 4,
          hint: 'Lessons, topics',
          onChanged: (query) =>
              ref.read(searchQueryProvider.notifier).state = query,
          onEditingChanged: (editing) {
            onEditingChanged?.call(editing);
            if (!editing) onCancel();
          },
        ),
      );
}
