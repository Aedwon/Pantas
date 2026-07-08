import 'package:cse_cet_reviewer/core/ui/components/pennant_mark.dart';
import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PennantMark(isSet: isBookmarked),
      ),
    );
  }
}
