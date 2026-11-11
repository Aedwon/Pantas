import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// L_DebriefSlow: the focus debrief page while its results load. The score
/// gauge column is on the left, the breakdown and the action on the right.
class WebDebriefLoading extends StatelessWidget {
  const WebDebriefLoading({super.key});

  /// The two columns sit in a 1000 wide frame: the content column less a
  /// 40 gutter on each side.
  static const double _frame =
      PantasLayout.contentMax - PantasSpace.s40 - PantasSpace.s40;

  /// Space above the frame, under the focus header.
  static const double _top = PantasSpace.s56 + PantasSpace.s40 + PantasSpace.s8;

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(
          PantasSpace.s40,
          _top,
          PantasSpace.s40,
          PantasSpace.s40,
        ),
        child: Center(
          child: SizedBox(
            width: _frame,
            child: SkeletonPulse(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SkeletonBlock(
                          width: 300,
                          height: PantasSpace.s40,
                          radius: PantasRadius.md,
                        ),
                        SizedBox(height: PantasSpace.s18),
                        SkeletonBlock(
                          width: 264,
                          height: 140,
                          radius: PantasRadius.full,
                        ),
                        SizedBox(height: PantasSpace.s18),
                        SkeletonBlock(
                          width: 340,
                          height: PantasSpace.s28 + PantasSpace.s2,
                          radius: PantasRadius.md,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: PantasSpace.s44 + PantasSpace.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SkeletonBlock(width: 120, height: 14),
                        ),
                        SizedBox(height: PantasSpace.s16),
                        SkeletonCard(height: 210),
                        SizedBox(height: PantasSpace.s16),
                        SkeletonBlock(
                          height: PantasSpace.s56 - PantasSpace.s2,
                          radius: PantasRadius.lg,
                          section: true,
                        ),
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
