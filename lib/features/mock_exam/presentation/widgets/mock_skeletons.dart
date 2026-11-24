import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_page.dart';

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
    // The loaded phone page (MK_SetupCSE): the Quiz link row, 16 px sides, the
    // title block 4 px in, the table, the rule line and the strict card, and
    // the Start button pinned under them.
    return const Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                MockSetupBackLink(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      PantasSpace.s16,
                      PantasSpace.s8,
                      PantasSpace.s16,
                      PantasLayout.reserveBar,
                    ),
                    child: SkeletonPulse(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: PantasSpace.s4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonBlock(
                                  width: 260,
                                  height: 32,
                                  radius: 9,
                                ),
                                SizedBox(height: PantasSpace.s4),
                                SkeletonBlock(width: 200, height: 20),
                              ],
                            ),
                          ),
                          SizedBox(height: _blockGap),
                          SkeletonBlock(height: 200, radius: 14, section: true),
                          SizedBox(height: _blockGap),
                          SkeletonBlock(height: 66, radius: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s14,
                  PantasSpace.s16,
                  _barBottom,
                ),
                child: SkeletonPulse(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SkeletonBlock(height: 52, radius: 14),
                      SizedBox(height: PantasSpace.s8),
                      Center(child: SkeletonBlock(width: 180, height: 15)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page's 22 px column gap and 30 px bar bottom (MK_SetupCSE).
// ds-board: MK_SetupCSE column gap 22
const double _blockGap = PantasSpace.s20 + PantasSpace.s2;
// ds-board: MK_SetupCSE bar padding-bottom 30
const double _barBottom = PantasSpace.s28 + PantasSpace.s2;

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
