import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The reader advances upward, because that is the direction it is pulled.
///
/// The platform default slid the next lesson in from the right while the
/// gesture that asked for it had been a pull up the screen. The motion
/// contradicted the hand that started it.
///
/// A lesson is a sheet in a bound volume, so the volume feeds: the sheet
/// being left keeps travelling up and off, and the next one follows it into
/// place. Both move the same way at the same moment, which is what makes it
/// read as one movement continued rather than two animations.
///
/// The outgoing sheet travels **less** than the incoming one and fades as it
/// goes. Moving both a full screen height is literal and reads as heavy; the
/// shorter travel puts the leaving sheet behind the arriving one, which is
/// where the eye expects the page it has finished with to be.
const Duration readerAdvanceDuration = Duration(milliseconds: 380);

/// How a lesson arrived, which is what decides how it moves.
///
/// **The motion describes the relationship, not the destination.** Tapping a
/// lesson in a list is going forward into it, and the row's chevron already
/// points that way, so it comes from the right and `< Study` sends it back.
/// Pulling up at the end of a lesson is advancing to the next sheet, so that
/// one keeps coming from below. Same screen, two entrances, each matching the
/// gesture that opened it.
enum ReaderEntry { forward, advance }

CustomTransitionPage<void> readerPage({
  required LocalKey key,
  required Widget child,
  ReaderEntry entry = ReaderEntry.forward,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: readerAdvanceDuration,
    reverseTransitionDuration: readerAdvanceDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ReaderAdvanceTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        entry: entry,
        child: child,
      );
    },
  );
}

/// Public so a test can drive it without a router.
class ReaderAdvanceTransition extends StatelessWidget {
  const ReaderAdvanceTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    this.entry = ReaderEntry.advance,
    super.key,
  });

  final ReaderEntry entry;

  final Animation<double> animation;

  /// Runs when *this* page is the one being left behind.
  final Animation<double> secondaryAnimation;

  final Widget child;

  /// How far the sheet being left travels, as a fraction of the screen.
  static const double _departingTravel = 0.34;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

    final from =
        entry == ReaderEntry.advance ? const Offset(0, 1) : const Offset(1, 0);
    final to = entry == ReaderEntry.advance
        ? const Offset(0, -_departingTravel)
        : const Offset(-_departingTravel, 0);

    final arriving = Tween<Offset>(
      begin: from,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    final departing = Tween<Offset>(
      begin: Offset.zero,
      end: to,
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    return SlideTransition(
      position: departing,
      child: FadeTransition(
        // Not to nothing: a sheet that vanishes reads as deleted rather than
        // passed.
        opacity: Tween<double>(begin: 1, end: 0.25).animate(secondaryAnimation),
        child: SlideTransition(
          position: arriving,
          child: child,
        ),
      ),
    );
  }
}
