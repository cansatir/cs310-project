import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const pagePadding = 16.0;
  static const sectionSpacing = 24.0;

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
