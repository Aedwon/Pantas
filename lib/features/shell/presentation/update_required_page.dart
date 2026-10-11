import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Whether this build is below the minimum the server publishes.
///
/// A published minimum of 0 blocks nothing, which is the state every
/// install is in until someone sets it deliberately.
bool updateIsRequired({
  required int currentBuild,
  required int minimumSupportedBuild,
}) {
  if (minimumSupportedBuild <= 0) return false;
  return currentBuild < minimumSupportedBuild;
}

/// The only modal in the app a student cannot dismiss.
///
/// That is justified only because the alternative is an app that is
/// actively wrong. It says the one thing the student can act on and
/// nothing else: no version numbers, no changelog, no apology.
class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({super.key, this.storeUrl});

  /// Overridden in tests. Null uses the platform's own listing.
  final Uri? storeUrl;

  static final Uri _playListing = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.aedwon.pantas',
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(36, 8, 36, 120),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Semantics(
                              label: 'Pantas',
                              image: true,
                              child: SizedBox.square(
                                dimension: 96,
                                child: CustomPaint(
                                  painter: _PantasLogoPainter(
                                    ink: context.colors.label,
                                    tassel: context.colors.accent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                'Pantas needs an update to keep working.',
                                textAlign: TextAlign.center,
                                style: context.type.sectionHero
                                    .copyWith(height: 1.25),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colors.background.withValues(alpha: 0),
                        context.colors.background,
                      ],
                      stops: const [0, .26],
                    ),
                  ),
                  child: PantasButton(
                    label: 'Update',
                    onPressed: () => _openStore(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    await launchUrl(
      storeUrl ?? _playListing,
      mode: LaunchMode.externalApplication,
    );
  }
}

// Exact paths and viewBox from SY_Update. Colors come from W1 in both themes.
class _PantasLogoPainter extends CustomPainter {
  const _PantasLogoPainter({required this.ink, required this.tassel});
  final Color ink;
  final Color tassel;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(size.width / 640, size.height / 640)
      ..translate(-307, -309);
    final accentPaint = Paint()..color = tassel;
    canvas
      ..drawLine(
        const Offset(887, 515.69),
        const Offset(887, 664),
        Paint()
          ..color = tassel
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(const Offset(887, 682), 20, accentPaint)
      ..drawPath(
        Path()
          ..moveTo(877, 699)
          ..lineTo(897, 699)
          ..lineTo(912, 774)
          ..quadraticBezierTo(915, 790, 899, 791)
          ..lineTo(875, 791)
          ..quadraticBezierTo(859, 790, 862, 774)
          ..close(),
        accentPaint,
      );
    final paint = Paint()..color = ink;
    canvas
      ..drawPath(
        Path()
          ..moveTo(363.97, 493.76)
          ..lineTo(614.06, 374.19)
          ..arcToPoint(
            const Offset(639.94, 374.19),
            radius: const Radius.circular(30),
          )
          ..lineTo(890.03, 493.76)
          ..arcToPoint(
            const Offset(890.03, 526.24),
            radius: const Radius.circular(18),
          )
          ..lineTo(639.94, 645.81)
          ..arcToPoint(
            const Offset(614.06, 645.81),
            radius: const Radius.circular(30),
          )
          ..lineTo(363.97, 526.24)
          ..arcToPoint(
            const Offset(363.97, 493.76),
            radius: const Radius.circular(18),
          )
          ..close(),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(443.45, 593.06)
          ..lineTo(519.45, 629.40)
          ..arcToPoint(
            const Offset(524, 636.62),
            radius: const Radius.circular(8),
          )
          ..lineTo(524, 878)
          ..arcToPoint(
            const Offset(512, 890),
            radius: const Radius.circular(12),
          )
          ..lineTo(478, 890)
          ..arcToPoint(
            const Offset(432, 844),
            radius: const Radius.circular(46),
          )
          ..lineTo(432, 600.28)
          ..arcToPoint(
            const Offset(443.45, 593.06),
            radius: const Radius.circular(8),
          )
          ..close(),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(728, 638.53)
          ..quadraticBezierTo(728, 632.53, 734, 629.63)
          ..lineTo(814, 591.44)
          ..quadraticBezierTo(820, 588.54, 820, 594.54)
          ..lineTo(820, 696)
          ..arcToPoint(
            const Offset(670, 846),
            radius: const Radius.circular(150),
          )
          ..lineTo(584, 846)
          ..arcToPoint(
            const Offset(572, 834),
            radius: const Radius.circular(12),
          )
          ..lineTo(572, 766)
          ..arcToPoint(
            const Offset(584, 754),
            radius: const Radius.circular(12),
          )
          ..lineTo(670, 754)
          ..arcToPoint(
            const Offset(728, 696),
            radius: const Radius.circular(58),
            clockwise: false,
          )
          ..close(),
        paint,
      );
  }

  @override
  bool shouldRepaint(_PantasLogoPainter oldDelegate) =>
      ink != oldDelegate.ink || tassel != oldDelegate.tassel;
}
