import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/reader_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

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

/// How long a lesson takes to rise into place, and to drop away again.
///
/// The page-level time on the approved motion board (item 5).
const Duration readerRiseDuration = PantasDurations.medium2;

/// How far a lesson rises while it fades in, in logical pixels.
const double readerRiseTravel = 24;

/// The board's "shared ease". The back motion runs the same curve with the
/// animation value falling, so leaving is the exact reverse of arriving.
const Curve readerRiseCurve = PantasCurves.move;

/// How a lesson arrived, which is what decides how it moves.
///
/// **The motion describes the relationship, not the destination.** Tapping a
/// lesson in a list is going forward into it, and the row's chevron already
/// points that way, so it comes from the right and `< Study` sends it back.
/// Pulling up at the end of a lesson is advancing to the next sheet, so that
/// one keeps coming from below. Same screen, two entrances, each matching the
/// gesture that opened it.
///
/// `rise` is a lesson opened from anywhere that is not a lesson: a list, a
/// plan, a search. The page behind stays exactly where it is, with its sidebar
/// or tab bar, and the lesson fades in while it rises a short way and settles.
/// It is never asked for directly: [readerPage] turns `forward` into `rise`
/// when no lesson is underneath, so a caller only says how the lesson was
/// opened.
enum ReaderEntry { forward, advance, rise }

Page<void> readerPage({
  required LocalKey key,
  required Widget child,
  ReaderEntry entry = ReaderEntry.forward,
}) =>
    _ReaderPage(key: key, child: child, entry: entry);

/// A lesson moves aside for another lesson and for nothing else.
///
/// Flutter gives a route's `secondaryAnimation` to any page route pushed on
/// top of it, so the figure viewer, which is a page route, carried the lesson
/// 34% to the side and faded it. Declining here leaves the secondary animation
/// at rest for every route that is not a lesson. Dialogs and sheets were
/// already still, because they are not page routes.
class _ReaderPage extends Page<void> {
  const _ReaderPage({
    required LocalKey super.key,
    required this.child,
    required this.entry,
  });

  final Widget child;
  final ReaderEntry entry;

  @override
  Route<void> createRoute(BuildContext context) =>
      _ReaderRoute(this, _resolve(context));

  /// Which entrance this lesson gets, decided before the route exists because
  /// the route's duration is fixed when it is created.
  ///
  /// Only a plain `forward` is open to change. A lesson opened over another
  /// lesson keeps the slide it always had.
  ReaderEntry _resolve(BuildContext context) {
    if (entry != ReaderEntry.forward) return entry;
    // The context is the navigator's own, so its widget lists the pages.
    final navigator = context.widget;
    if (navigator is! Navigator) return ReaderEntry.rise;
    final at = navigator.pages.indexOf(this);
    final overLesson = at > 0 && navigator.pages[at - 1] is _ReaderPage;
    return overLesson ? ReaderEntry.forward : ReaderEntry.rise;
  }
}

class _ReaderRoute extends PageRoute<void> {
  _ReaderRoute(_ReaderPage page, this._entry) : super(settings: page);

  final ReaderEntry _entry;

  _ReaderPage get _page => settings as _ReaderPage;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is _ReaderRoute;

  @override
  Duration get transitionDuration =>
      _entry == ReaderEntry.rise ? readerRiseDuration : readerAdvanceDuration;

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: _page.child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      ReaderAdvanceTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        entry: _entry,
        child: child,
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

    // `rise` has no direction of its own to leave in, so a lesson that was
    // opened this way and is later covered moves aside as `forward` does.
    final sideways = entry != ReaderEntry.advance;
    final from = sideways ? const Offset(1, 0) : const Offset(0, 1);
    final to = sideways
        ? const Offset(-_departingTravel, 0)
        : const Offset(0, -_departingTravel);

    final departing = Tween<Offset>(
      begin: Offset.zero,
      end: to,
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: readerEaseOut,
        reverseCurve: readerEaseIn,
      ),
    );

    final beneath = SlideTransition(
      position: departing,
      child: FadeTransition(
        // Not to nothing: a sheet that vanishes reads as deleted rather than
        // passed.
        opacity: Tween<double>(begin: 1, end: 0.25).animate(secondaryAnimation),
        child: entry == ReaderEntry.rise
            ? child
            : SlideTransition(
                position: Tween<Offset>(
                  begin: from,
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: readerEaseOut,
                    reverseCurve: readerEaseIn,
                  ),
                ),
                child: child,
              ),
      ),
    );

    return entry == ReaderEntry.rise ? _rise(beneath) : beneath;
  }

  /// Fade in while rising a few pixels, then settle.
  ///
  /// One opacity and one translation, nothing else: no blur, no resize and no
  /// change to the page behind. The lesson is already its own repaint
  /// boundary, so each frame only moves and blends a picture that is already
  /// drawn. The same curve runs both ways, so leaving is the arrival played
  /// backward.
  Widget _rise(Widget lesson) {
    final eased = CurveTween(curve: readerRiseCurve).animate(animation);
    return FadeTransition(
      opacity: eased,
      child: AnimatedBuilder(
        animation: eased,
        child: lesson,
        builder: (context, lesson) => Transform.translate(
          offset: Offset(0, (1 - eased.value) * readerRiseTravel),
          child: lesson,
        ),
      ),
    );
  }
}
