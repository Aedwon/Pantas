import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/install/install_platform.dart';
import 'package:pantas/core/platform/install/install_providers.dart';
import 'package:pantas/core/ui/components/install_card.dart';
import 'package:pantas/core/ui/components/install_sheet.dart';
import 'package:pantas/features/home/application/home_install_offer.dart';

/// The install card at the bottom of Home (Aedwon, 30 October 2026: at the
/// bottom, so it is not intrusive). Takes no space when nothing is offered.
class HomeInstallSlot extends ConsumerWidget {
  const HomeInstallSlot({this.topGap = 24, super.key});

  final double topGap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(homeInstallOfferProvider);
    if (path == InstallPath.none) return const SizedBox.shrink();
    final controller = ref.read(installControllerProvider.notifier);
    return Padding(
      padding: EdgeInsets.only(top: topGap),
      child: InstallCard(
        path: path,
        onPrimary: () => path == InstallPath.native
            ? unawaited(controller.install())
            : unawaited(showInstallSheet(context)),
        onNotNow: controller.notNow,
      ),
    );
  }
}
