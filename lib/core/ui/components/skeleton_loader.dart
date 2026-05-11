import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    required this.height,
    this.width,
    this.borderRadius,
    super.key,
  });

  final double height;
  final double? width;
  final double? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      return _buildStatic(context);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => _buildShimmer(context),
    );
  }

  Widget _buildStatic(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? AppDimensions.radiusSM,
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(_animation.value - 1, 0),
          end: Alignment(_animation.value + 1, 0),
          colors: [colors.border, colors.background, colors.border],
        ),
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? AppDimensions.radiusSM,
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: const [AppDimensions.shadowSM],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(height: 10, width: 80),
              SkeletonBox(height: 10, width: 60),
            ],
          ),
          SizedBox(height: 12),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: 6),
          SkeletonBox(height: 14, width: 240),
          SizedBox(height: 14),
          SkeletonBox(height: 44, width: double.infinity, borderRadius: 10),
          SizedBox(height: 6),
          SkeletonBox(height: 44, width: double.infinity, borderRadius: 10),
          SizedBox(height: 6),
          SkeletonBox(height: 44, width: double.infinity, borderRadius: 10),
        ],
      ),
    );
  }
}
