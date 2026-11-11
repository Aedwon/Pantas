import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// Page transitions for web builds (Aedwon's Nov 4 pick, option C on the
/// Wide Page Motion canvas): wide pages slide, on a solid background.
///
/// Wide pages paint no background of their own, so without one the page being
/// left shows through the page arriving. Desktop browsers all slide, so
/// Windows and Linux match the Mac. A phone keeps its platform's transition.
const webPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: SolidWidePageTransitionsBuilder(
      PredictiveBackPageTransitionsBuilder(),
    ),
    TargetPlatform.iOS: SolidWidePageTransitionsBuilder(
      CupertinoPageTransitionsBuilder(),
    ),
    TargetPlatform.macOS: SolidWidePageTransitionsBuilder(
      CupertinoPageTransitionsBuilder(),
    ),
    TargetPlatform.windows: SolidWidePageTransitionsBuilder(
      CupertinoPageTransitionsBuilder(),
    ),
    TargetPlatform.linux: SolidWidePageTransitionsBuilder(
      CupertinoPageTransitionsBuilder(),
    ),
  },
);

/// Runs [delegate] and, on wide web, puts the page on the shell's background.
class SolidWidePageTransitionsBuilder extends PageTransitionsBuilder {
  const SolidWidePageTransitionsBuilder(this.delegate);

  final PageTransitionsBuilder delegate;

  @override
  Duration get transitionDuration => delegate.transitionDuration;

  @override
  Duration get reverseTransitionDuration => delegate.reverseTransitionDuration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      delegate.delegatedTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      delegate.buildTransitions(
        route,
        context,
        animation,
        secondaryAnimation,
        context.wideWeb
            ? ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: child,
              )
            : child,
      );
}
