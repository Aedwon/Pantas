import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// Phone assessment results: the centered title and exam line, the score
/// gauge, the subject group, then the plan start group.
class AssessmentResultsSkeleton extends StatelessWidget {
  const AssessmentResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            PantasSpace.s16,
            PantasSpace.s56,
            PantasSpace.s16,
            PantasSpace.s24,
          ),
          child: SkeletonPulse(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: SkeletonBlock(width: 240, height: 32, radius: 9)),
                SizedBox(height: PantasSpace.s6),
                Center(child: SkeletonBlock(width: 200, height: 18)),
                SizedBox(height: PantasSpace.s20),
                SkeletonBlock(height: 120, radius: 18, section: true),
                SizedBox(height: PantasSpace.s20),
                SkeletonSection(height: 244, headerWidth: 130),
                SizedBox(height: PantasSpace.s20),
                SkeletonSection(height: 72, headerWidth: 150),
              ],
            ),
          ),
        ),
      );
}
