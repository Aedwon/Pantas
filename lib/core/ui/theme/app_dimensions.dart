import 'package:flutter/material.dart';

abstract final class AppDimensions {
  // Border radii
  static const double radiusXS = 6;
  static const double radiusSM = 8;
  static const double radiusMD = 10;
  static const double radiusLG = 14;
  static const double radiusXL = 20;
  static const double radiusFull = 999;

  // Tap targets
  static const double minTapTarget = 48;

  // Shadows
  static const BoxShadow shadowSM = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  );
  static const BoxShadow shadowMD = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  static const BoxShadow shadowLG = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  );
  static const BoxShadow shadowPrimary = BoxShadow(
    color: Color(0x591F6BFF),
    blurRadius: 10,
    offset: Offset(0, 3),
  );
}
