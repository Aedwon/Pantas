import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The mock setup page before its blueprint loads: the app bar, the title and
/// item line, the section table, then the strict mode row and start button.
class MockSetupSkeleton extends StatelessWidget {
  const MockSetupSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return const Scaffold(
        body: SkeletonPulse(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              PantasSpace.s0,
              PantasSpace.s6,
              PantasSpace.s0,
              PantasSpace.s0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: PantasSpace.s40),
                SkeletonBlock(width: 420, height: 40, radius: 10),
                SizedBox(height: PantasSpace.s6),
                SkeletonBlock(width: 260, height: 22),
                SizedBox(height: PantasSpace.s28),
                _WideColumns(),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mock exam')),
      body: const SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            PantasSpace.s20,
            PantasSpace.s18,
            PantasSpace.s20,
            PantasSpace.s32,
          ),
          child: SkeletonPulse(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SkeletonBlock(width: 260, height: 32, radius: 9),
                SizedBox(height: PantasSpace.s6),
                SkeletonBlock(width: 200, height: 20),
                SizedBox(height: PantasSpace.s28),
                SkeletonBlock(height: 200, radius: 14, section: true),
                SizedBox(height: PantasSpace.s24),
                SkeletonBlock(height: 66),
                SizedBox(height: PantasSpace.s28),
                SkeletonBlock(height: 40),
                SizedBox(height: PantasSpace.s10),
                SkeletonBlock(height: 66),
                SizedBox(height: PantasSpace.s28),
                SkeletonBlock(height: 52, radius: 14),
                SizedBox(height: PantasSpace.s8),
                Center(child: SkeletonBlock(width: 180, height: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WideColumns extends StatelessWidget {
  const _WideColumns();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          const rules = SkeletonCard(height: 360);
          const controls = SkeletonCard(height: 280);
          if (constraints.maxWidth < 820) {
            return const Column(
              children: [rules, SizedBox(height: PantasSpace.s24), controls],
            );
          }
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 14, child: rules),
              SizedBox(width: PantasSpace.s24),
              Expanded(flex: 10, child: controls),
            ],
          );
        },
      );
}

/// A mock question screen before its paper is ready.
class MockSessionSkeleton extends StatelessWidget {
  const MockSessionSkeleton({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: SafeArea(child: SkeletonQuestionPage()));
}

/// Phone mock results: the score card, then the subject group.
class MockResultsSkeleton extends StatelessWidget {
  const MockResultsSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const SkeletonResultsPage();
}
