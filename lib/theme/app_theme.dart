import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const brandColor = Color(0xFF6750A4);
  static const smallSpacing = 8.0;
  static const mediumSpacing = 12.0;
  static const pagePadding = 16.0;
  static const sectionSpacing = 24.0;

  static ThemeData get light => withTypography(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: brandColor),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
  );

  static Color secondaryTextColor(ThemeData theme) =>
      theme.colorScheme.onSurfaceVariant;

  static ThemeData withTypography(ThemeData base) {
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
