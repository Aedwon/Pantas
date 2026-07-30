import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class ReaderGap extends StatelessWidget {
  const ReaderGap({
    required this.isRead,
    required this.examId,
    required this.lessonId,
    super.key,
  });

  final bool isRead;
  final ExamId? examId;
  final LessonId lessonId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRead) ...[
            Row(
              children: [
                Text(
                  '✓',
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.board,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Read',
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'marked automatically',
                  style: textStyles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: colors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          if (examId != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/quiz/inline/$examId/$lessonId'),
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.ink),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Quiz yourself, 5 questions',
                    textAlign: TextAlign.center,
                    style: textStyles.labelLarge.copyWith(
                      color: colors.ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
