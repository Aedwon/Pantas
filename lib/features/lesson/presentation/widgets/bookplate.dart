import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A bookplate for a finished topic or a topic stopped short.
class Bookplate extends StatefulWidget {
  const Bookplate({
    required this.studentName,
    required this.topicName,
    required this.examAndSubject,
    required this.footing,
    required this.dateLine,
    super.key,
  });

  final String? studentName;
  final String topicName;
  final String examAndSubject;
  final String footing;
  final String dateLine;

  @override
  State<Bookplate> createState() => _BookplateState();
}

class _BookplateState extends State<Bookplate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 660),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 1.0, curve: Curves.fastOutSlowIn),
    );

    _translateY = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final hasName =
        widget.studentName != null && widget.studentName!.isNotEmpty;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translateY.value),
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          key: const ValueKey('bookplate-card'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.rule,
              // ignore: avoid_redundant_argument_values
              width: AppDimensions.hairline,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasName) ...[
                Text(
                  widget.studentName!,
                  textAlign: TextAlign.center,
                  style: textStyles.titleSmall.copyWith(
                    color: colors.inkMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: AppDimensions.hairline,
                  color: colors.ruleFaint,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                widget.topicName,
                textAlign: TextAlign.center,
                style: textStyles.displayLarge.copyWith(
                  fontSize: 31,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.examAndSubject,
                textAlign: TextAlign.center,
                style: textStyles.captionSmall.copyWith(
                  color: colors.inkMuted,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: AppDimensions.hairline,
                color: colors.ruleFaint,
              ),
              const SizedBox(height: 14),
              Text(
                widget.footing,
                textAlign: TextAlign.center,
                style: textStyles.bodySmall.copyWith(
                  color: colors.inkMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.dateLine,
                textAlign: TextAlign.center,
                style: textStyles.bodySmall.copyWith(
                  color: colors.inkMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
