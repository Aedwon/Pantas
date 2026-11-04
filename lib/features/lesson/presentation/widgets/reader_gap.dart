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
    // The Read line pops in once per lesson, on the phone and the wide page.
    Widget readPop(Widget child) => TweenAnimationBuilder<double>(
          key: ValueKey(lessonId),
          tween: Tween(begin: still ? 1 : 0, end: 1),
          duration: still ? Duration.zero : const Duration(milliseconds: 350),
          curve: PantasCurves.popB,
          child: child,
          builder: (_, value, child) => Transform.scale(
            alignment: Alignment.centerLeft,
            scale: .6 + .4 * value,
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          ),
        );
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
      final t = context.webTokens;
      return Container(
        margin: const EdgeInsets.only(top: 36),
        padding: const EdgeInsets.only(top: 28),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: t.strongDivider,
              width: .5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (isRead)
              readPop(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      key: const ValueKey('reader-read-check'),
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.colors.accentFill,
                      ),
                      child: const CustomPaint(
                        size: Size(15, 15),
                        painter: _ReadCheckPainter(Colors.white, width: 3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Read', style: t.style(17, weight: FontWeight.w600)),
                  ],
                ),
              ),
            const Spacer(),
            if (examId != null)
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.standard,
                  backgroundColor: t.disabledBackground,
                  foregroundColor: t.colors.label,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  textStyle: t.style(15, weight: FontWeight.w600),
                ),
                onPressed: () =>
                    startLessonQuiz(context, lessonId, examId: examId!),
                child: const Text('Quiz yourself, 5 questions'),
              ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isRead)
          readPop(readLine)
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
  const _ReadCheckPainter(this.color, {this.width = 2.6});
  final Color color;
  final double width;
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
          ..strokeWidth = width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_ReadCheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}
