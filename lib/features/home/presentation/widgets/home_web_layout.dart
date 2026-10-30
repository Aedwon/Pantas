import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Home's two canvas columns. The shell already owns the sidebar.
class HomeWebLayout extends StatelessWidget {
  const HomeWebLayout({
    required this.header,
    required this.today,
    this.notice,
    this.performance,
    this.onRecord,
    this.onTendencies,
    this.footer,
    super.key,
  });
  final Widget header;
  final Widget today;
  final Widget? notice;
  final Widget? performance;
  final VoidCallback? onRecord;
  final VoidCallback? onTendencies;

  /// Sits at the very bottom, under both columns.
  final Widget? footer;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 26),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final left = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        today,
                        if (notice != null) ...[
                          const SizedBox(height: 20),
                          notice!,
                        ],
                        if (onRecord != null && onTendencies != null) ...[
                          const SizedBox(height: 28),
                          const WebText(
                            'More about you',
                            kind: WebTextKind.eyebrow,
                          ),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              Expanded(
                                child: WebCard(
                                  child: WebRow(
                                    title: 'Your record',
                                    leading: Icon(
                                      Icons.show_chart,
                                      color: context.webTokens.colors.accent,
                                      size: 24,
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      size: 16,
                                    ),
                                    divider: false,
                                    onPressed: onRecord,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: WebCard(
                                  child: WebRow(
                                    title: 'Your tendencies',
                                    leading: Icon(
                                      Icons.auto_awesome_outlined,
                                      color: context.webTokens.colors.accent,
                                      size: 24,
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      size: 16,
                                    ),
                                    divider: false,
                                    onPressed: onTendencies,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                    if (performance == null) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(width: 640, child: left),
                      );
                    }
                    if (constraints.maxWidth < 848) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          left,
                          const SizedBox(height: 28),
                          performance!,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width:
                              480 + (constraints.maxWidth - 848) * 1.45 / 2.45,
                          child: left,
                        ),
                        const SizedBox(width: 28),
                        Expanded(child: performance!),
                      ],
                    );
                  },
                ),
                if (footer != null) footer!,
              ],
            ),
          ),
        ),
      );
}

/// The three Today lists are right drawers. Date editing is a centered dialog.
class HomeWebOverlay extends StatefulWidget {
  const HomeWebOverlay({
    required this.page,
    required this.child,
    required this.open,
    required this.onDismiss,
    required this.label,
    this.drawer = false,
    this.dialogWidth = 560,
    super.key,
  });
  final Widget page;
  final Widget child;
  final bool open;
  final VoidCallback onDismiss;
  final String label;
  final bool drawer;
  final double dialogWidth;
  @override
  State<HomeWebOverlay> createState() => _HomeWebOverlayState();
}

class _HomeWebOverlayState extends State<HomeWebOverlay> {
  final _controller = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    if (widget.open) _controller.show();
  }

  @override
  void didUpdateWidget(HomeWebOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.open) {
          _controller.show();
        } else if (_controller.isShowing) {
          _controller.hide();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !widget.open,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && widget.open) widget.onDismiss();
        },
        child: OverlayPortal(
          overlayLocation: OverlayChildLocation.rootOverlay,
          controller: _controller,
          overlayChildBuilder: (context) => Positioned.fill(
            child: Stack(
              children: [
                ModalBarrier(
                  color: Colors.black.withValues(alpha: .28),
                  onDismiss: widget.onDismiss,
                  semanticsLabel: 'Close ${widget.label}',
                ),
                Align(
                  alignment:
                      widget.drawer ? Alignment.centerRight : Alignment.center,
                  child: CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.escape):
                          widget.onDismiss,
                    },
                    child: FocusScope(
                      autofocus: true,
                      child: Focus(
                        child: Semantics(
                          scopesRoute: true,
                          explicitChildNodes: true,
                          namesRoute: true,
                          label: widget.label,
                          child: Material(
                            key: ValueKey(
                              widget.drawer
                                  ? 'home-web-drawer'
                                  : 'home-web-dialog',
                            ),
                            color: widget.drawer
                                ? context.webTokens.colors.background
                                : context.webTokens.colors.surface,
                            borderRadius: widget.drawer
                                ? null
                                : BorderRadius.circular(22),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              width: widget.drawer ? 440 : widget.dialogWidth,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.sizeOf(context).height -
                                      (widget.drawer ? 0 : 48),
                                ),
                                child: widget.drawer
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          widget.child,
                                          Positioned(
                                            top: 14,
                                            right: 16,
                                            child: IconButton(
                                              tooltip: 'Close',
                                              onPressed: widget.onDismiss,
                                              icon: const Icon(
                                                Icons.close,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Stack(
                                        children: [
                                          widget.child,
                                          Positioned(
                                            top: 14,
                                            right: 16,
                                            child: IconButton(
                                              tooltip: 'Close',
                                              onPressed: widget.onDismiss,
                                              icon: const Icon(
                                                Icons.close,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: ExcludeFocus(
            excluding: widget.open,
            child: ExcludeSemantics(excluding: widget.open, child: widget.page),
          ),
        ),
      );
}

class HomeWebNotice extends StatelessWidget {
  const HomeWebNotice({
    required this.title,
    required this.onClose,
    this.detail,
    this.expanded = false,
    this.onToggle,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.editor,
    this.icon,
    this.iconColor,
    super.key,
  });
  final String title;
  final String? detail;
  final bool expanded;
  final VoidCallback onClose;
  final VoidCallback? onToggle;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? editor;
  final IconData? icon;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Container(
      decoration: BoxDecoration(
        color: t.colors.surface,
        border: Border.all(color: t.colors.separator),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onToggle,
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon ?? PantasIcons.addDate,
                        size: 18,
                        color: iconColor ?? t.colors.secondaryLabel,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: t.style(15, weight: FontWeight.w500),
                        ),
                      ),
                      if (detail != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          expanded ? Icons.expand_more : Icons.chevron_right,
                          size: 15,
                          color: t.colors.secondaryLabel,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Dismiss',
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 14),
              ),
            ],
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (detail != null) Text(detail!, style: t.sub),
                  if (editor != null) ...[
                    const SizedBox(height: 12),
                    editor!,
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    children: [
                      if (secondaryLabel != null)
                        WebButton(
                          label: secondaryLabel!,
                          variant: WebButtonVariant.tertiary,
                          onPressed: onSecondary,
                        ),
                      if (primaryLabel != null)
                        WebButton(
                          label: primaryLabel!,
                          variant: WebButtonVariant.secondary,
                          onPressed: onPrimary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// L_PlanSlow. Shapes appear only after 300ms. No invented progress or
/// loading text.
class HomeWebLoading extends StatelessWidget {
  const HomeWebLoading({
    this.performance = false,
    this.header = false,
    this.more = false,
    super.key,
  });
  final bool performance;
  final bool header;
  final bool more;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: header
            ? const SkeletonCard(height: 66)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SkeletonBlock(
                      width: performance ? 140 : 80,
                      height: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SkeletonCard(height: performance ? 520 : 330),
                  if (more) ...[
                    const SizedBox(height: 28),
                    const SkeletonCard(height: 96),
                  ],
                ],
              ),
      );
}

class HomeWebQuestionsSheet extends StatelessWidget {
  const HomeWebQuestionsSheet({
    required this.title,
    required this.done,
    required this.total,
    required this.rows,
    required this.startLabel,
    this.onStart,
    this.busy = false,
    this.failure,
    super.key,
  });
  final String title;
  final int done;
  final int total;
  final List<Widget> rows;
  final String startLabel;
  final VoidCallback? onStart;
  final bool busy;
  final Widget? failure;
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          if (onStart != null && !busy)
            const SingleActivator(LogicalKeyboardKey.enter): onStart!,
        },
        child: Focus(
          autofocus: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WebText(title, kind: WebTextKind.h2),
                      Text(
                        '$done of $total${title == 'Lessons' ? ' read' : ''}',
                        style: context.webTokens.sub,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: title == 'Lessons'
                        ? Column(mainAxisSize: MainAxisSize.min, children: rows)
                        : WebCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: rows,
                            ),
                          ),
                  ),
                ),
                if (failure != null) failure!,
                if (onStart != null) ...[
                  const SizedBox(height: 14),
                  WebButton(
                    label: startLabel,
                    keyHint: 'Enter',
                    large: true,
                    onPressed: onStart,
                    busy: busy,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}
