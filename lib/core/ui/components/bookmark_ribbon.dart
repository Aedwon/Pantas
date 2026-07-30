import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';

class BookmarkRibbon extends StatelessWidget {
  const BookmarkRibbon({
    required this.isBookmarked,
    required this.onTap,
    super.key,
  });

  final bool isBookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isBookmarked ? 'Remove bookmark' : 'Bookmark question',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(
            child: PennantMark(isSet: isBookmarked),
          ),
        ),
      ),
    );
  }
}
