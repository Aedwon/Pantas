import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// A development value that W5 must replace with a published figure.
/// The reason is code metadata and never reaches the student.
///
/// It is plain figure text (`web-body`, `text-primary`): the figure frame
/// (`figure-bg`, `radius-md`, 1px `divider` ring) is drawn by whatever holds
/// the figure.
class PlaceholderFigure extends StatelessWidget {
  const PlaceholderFigure(this.value, {required this.reason, super.key})
      : assert(reason != '', 'A placeholder needs its missing-source reason.');

  final num value;
  final String reason;

  @override
  Widget build(BuildContext context) => Text(
        '$value',
        style: PantasType.webBody.copyWith(color: context.colors.textPrimary),
      );
}
