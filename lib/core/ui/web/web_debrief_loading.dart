import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';

class WebDebriefLoading extends StatelessWidget {
  const WebDebriefLoading({super.key});
  @override
  Widget build(BuildContext context) {
    Widget shape(double width, double height, double radius) => SizedBox(
          width: width,
          height: height,
          child: LoadingShapes(
            shapes: [
              LoadingShape(widthFraction: 1, height: height, radius: radius),
            ],
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 104, 40, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    shape(300, 40, 10),
                    const SizedBox(height: 18),
                    shape(264, 140, 140),
                    const SizedBox(height: 18),
                    shape(340, 30, 10),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shape(120, 14, 6),
                    const SizedBox(height: 16),
                    shape(double.infinity, 210, 18),
                    const SizedBox(height: 16),
                    shape(double.infinity, 54, 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
