import 'package:flutter/material.dart';

ThemeData appLightTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6BFF)),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

ThemeData appDarkTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1F6BFF),
        brightness: Brightness.dark,
      ),
    );
