import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';

/// Phone assessment results: the centered title and exam line, the score
/// gauge, the subject group, then the plan start group.
class AssessmentResultsSkeleton extends StatelessWidget {
  const AssessmentResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, 52, 16, 24),
          child: SkeletonPulse(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: SkeletonBlock(width: 240, height: 32, radius: 9)),
                SizedBox(height: 6),
                Center(child: SkeletonBlock(width: 200, height: 18)),
                SizedBox(height: 22),
                SkeletonBlock(height: 120, radius: 18, section: true),
                SizedBox(height: 22),
                SkeletonSection(height: 244, headerWidth: 130),
                SizedBox(height: 22),
                SkeletonSection(height: 72, headerWidth: 150),
              ],
            ),
          ),
        ),
      );
}
