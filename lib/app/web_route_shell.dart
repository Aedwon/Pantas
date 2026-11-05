import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

/// Composition lives here so the shell only receives data and callbacks.
class WebRouteShell extends ConsumerStatefulWidget {
  const WebRouteShell({required this.path, required this.child, super.key});
  final String path;
  final Widget child;

  @override
  ConsumerState<WebRouteShell> createState() => _WebRouteShellState();
}

class _WebRouteShellState extends ConsumerState<WebRouteShell> {
  /// Keeps the page's state when the layout tier changes and the widgets
  /// around it do. A phone turned on its side moves from the phone layout to
  /// the tablet one, and without a key the page was rebuilt from nothing: the
  /// reader lost its place and closed the figure viewer (7X-2).
  final GlobalKey _pageKey = GlobalKey(debugLabel: 'route page');

  @override
  Widget build(BuildContext context) {
    final path = widget.path;
    final child = KeyedSubtree(key: _pageKey, child: widget.child);
    if (context.webTier == WebLayoutTier.tabletPortrait) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: SizedBox(width: 640, child: child),
        ),
      );
    }
    if (!context.wideWeb) return child;
    // The guardian screens and onboarding are full screen: no sidebar and no
    // tabs, at every wide size (3M-10: the tabs showed at 1024 to 1279).
    if (path.startsWith('/guardian') || path.startsWith('/onboarding')) {
      return child;
    }
    // A legal page opened during onboarding has no main navigation.
    if (path.startsWith('/legal/') && ref.watch(legalInOnboardingProvider)) {
      return child;
    }
    if (!webSidebarRoute(path) && context.webTier == WebLayoutTier.desktop) {
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
              showWebLessonSearch(context),
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
              showWebLessonSearch(context),
        },
        child: child,
      );
    }
    if (webFocusRoute(path)) return child;
    const tabs = ['/home', '/study', '/quiz', '/settings'];
    // Plan, Performance, Record and Tendencies belong to Home on the boards.
    const homeGroup = ['/record', '/tendencies', '/plan', '/performance'];
    // Legal pages open from Settings and keep it highlighted (ST_Privacy).
    final activeIndex =
        homeGroup.any((r) => path == r || path.startsWith('$r/'))
            ? 0
            : path.startsWith('/legal/')
                ? 3
                : tabs.indexWhere(
                    (tab) => path == tab || path.startsWith('$tab/'),
                  );
    void navigate(int index) {
      ref.read(telemetryProvider).log(
        TelemetryEvent.tabOpened,
        properties: {'tab': tabs[index].substring(1)},
      );
      context.go(tabs[index]);
    }

    if (!webSidebarRoute(path)) {
      // Existing focus bars sit 28px above this shortened viewport. This puts
      // them 12px above the 64px navigation, with content insets kept intact.
      return WebTabletNavigation(
        activeIndex: activeIndex,
        onNavigate: navigate,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 72),
          child: child,
        ),
      );
    }
    final person = ref.watch(userSettingsProvider).valueOrNull?.name ?? '';
    final exam = ref.watch(activeExamShortNameProvider);
    final pro = ref.watch(proForActiveExamProvider).valueOrNull ?? false;
    return WebShellFrame(
      activeIndex: activeIndex,
      person: person,
      exam: exam,
      plan: pro ? 'Pro' : 'Free',
      onSearch: () => showWebLessonSearch(context),
      onNavigate: navigate,
      child: child,
    );
  }
}
