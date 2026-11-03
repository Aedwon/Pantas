import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Leaves a routed page: back to the page before it when there is one,
/// otherwise to [fallback].
///
/// A page opened directly, or after a reload, is the first in its Navigator.
/// There `Navigator.maybePop` does nothing and `GoRouter.pop` throws, so Back
/// would be dead. [result] goes to whoever pushed the page and is dropped when
/// the page goes to [fallback].
///
/// A PopScope on the page is respected unless [respectPopScope] is false. A
/// page whose own PopScope calls this must pass false, or it would ask itself
/// again. Only for pages, not dialogs or sheets, which always have a page
/// under them.
///
/// With no router above (a widget test under a plain Navigator) there is no
/// fallback to go to, and nothing happens when the page cannot pop.
void leavePage(
  BuildContext context, {
  required String fallback,
  Object? result,
  bool respectPopScope = true,
}) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    if (respectPopScope) {
      navigator.maybePop(result).ignore();
    } else {
      navigator.pop(result);
    }
    return;
  }
  GoRouter.maybeOf(context)?.go(fallback);
}
