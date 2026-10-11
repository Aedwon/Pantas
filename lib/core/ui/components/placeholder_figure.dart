import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A development value that W5 must replace with a published figure.
/// The reason is code metadata and never reaches the student.
class PlaceholderFigure extends StatelessWidget {
  const PlaceholderFigure(this.value, {required this.reason, super.key})
      : assert(reason != '', 'A placeholder needs its missing-source reason.');

  final num value;
  final String reason;

  @override
  Widget build(BuildContext context) =>
      Text('$value', style: context.type.body);
}
