import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';

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
    final still = MediaQuery.disableAnimationsOf(context);
    final colors = context.colors;
    final readLine = Row(
      children: [
        CustomPaint(
          key: const ValueKey('reader-read-check'),
          size: const Size(18, 18),
          painter: _ReadCheckPainter(colors.accent),
        ),
        const SizedBox(width: 8),
        Text(
          'Read',
          style: context.type.subhead.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.label,
          ),
        ),
      ],
    );
    if (context.wideWeb) {
      return Container(
        margin: const EdgeInsets.only(top: 36),
        padding: const EdgeInsets.only(top: 28),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.webTokens.strongDivider,
              width: .5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (isRead) readLine,
            const Spacer(),
            if (examId != null)
              WebButton(
                label: 'Quiz yourself, 5 questions',
                variant: WebButtonVariant.white,
                onPressed: () =>
                    startLessonQuiz(context, lessonId, examId: examId!),
              ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isRead)
          TweenAnimationBuilder<double>(
            key: ValueKey(lessonId),
            tween: Tween(begin: still ? 1 : 0, end: 1),
            duration: still ? Duration.zero : const Duration(milliseconds: 350),
            curve: PantasCurves.popB,
            child: readLine,
            builder: (_, value, child) => Transform.scale(
              alignment: Alignment.centerLeft,
              scale: .6 + .4 * value,
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            ),
          )
        else
          SizedBox(height: MediaQuery.textScalerOf(context).scale(15) * 1.35),
        if (examId != null) ...[
          const SizedBox(height: 18),
          if (context.wideWeb)
            Align(
              alignment: Alignment.centerLeft,
              child: WebButton(
                label: 'Quiz yourself, 5 questions',
                variant: WebButtonVariant.white,
                onPressed: () =>
                    startLessonQuiz(context, lessonId, examId: examId!),
              ),
            )
          else
            PantasButton(
              label: 'Quiz yourself, 5 questions',
              variant: PantasButtonVariant.neutral,
              onPressed: () =>
                  startLessonQuiz(context, lessonId, examId: examId!),
            ),
        ],
      ],
    );
  }
}

class _ReadCheckPainter extends CustomPainter {
  const _ReadCheckPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 24, size.height / 24)
      ..drawPath(
        Path()
          ..moveTo(5, 12.5)
          ..lineTo(9.5, 17)
          ..lineTo(19, 7),
        Paint()
          ..color = color
          ..strokeWidth = 2.6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_ReadCheckPainter oldDelegate) =>
      oldDelegate.color != color;
}
