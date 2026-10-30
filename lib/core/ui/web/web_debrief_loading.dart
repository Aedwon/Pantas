import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';

/// L_DebriefSlow: the focus debrief page while its results load. The score
/// gauge column is on the left, the breakdown and the action on the right.
class WebDebriefLoading extends StatelessWidget {
  const WebDebriefLoading({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(40, 104, 40, 40),
        child: Center(
          child: SizedBox(
            width: 1000,
            child: SkeletonPulse(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SkeletonBlock(width: 300, height: 40, radius: 10),
                        SizedBox(height: 18),
                        SkeletonBlock(width: 264, height: 140, radius: 140),
                        SizedBox(height: 18),
                        SkeletonBlock(width: 340, height: 30, radius: 10),
                      ],
                    ),
                  ),
                  SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SkeletonBlock(width: 120, height: 14),
                        ),
                        SizedBox(height: 16),
                        SkeletonCard(height: 210),
                        SizedBox(height: 16),
                        SkeletonBlock(height: 54, radius: 16, section: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
