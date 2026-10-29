import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

/// Composition lives here so the shell only receives data and callbacks.
class WebRouteShell extends ConsumerWidget {
  const WebRouteShell({required this.path, required this.child, super.key});
  final String path;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!context.wideWeb) return child;
    if (!webSidebarRoute(path)) {
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
              showWebLessonSearch(context),
        },
        child: child,
      );
    }
    final person = ref.watch(userSettingsProvider).valueOrNull?.name ?? '';
    final exam = ref.watch(activeExamShortNameProvider);
    final pro = ref.watch(proForActiveExamProvider).valueOrNull ?? false;
    const tabs = ['/home', '/study', '/quiz', '/settings'];
    final activeIndex =
        tabs.indexWhere((tab) => path == tab || path.startsWith('$tab/'));
    return WebShellFrame(
      activeIndex: activeIndex,
      person: person,
      exam: exam,
      plan: pro ? 'Pro' : 'Free',
      child: child,
      onSearch: () => showWebLessonSearch(context),
      onNavigate: (index) {
        ref.read(telemetryProvider).log(
          TelemetryEvent.tabOpened,
          properties: {'tab': tabs[index].substring(1)},
        );
        context.go(tabs[index]);
      },
    );
  }
}
