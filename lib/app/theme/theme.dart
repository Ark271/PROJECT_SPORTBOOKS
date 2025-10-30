import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Light theme
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF2E5AAC),
  );

  // Dùng Be Vietnam Pro cho toàn bộ text (không set fontFamily thủ công)
  final textTheme = GoogleFonts.beVietnamProTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: base.appBarTheme.copyWith(
      centerTitle: true,
      titleTextStyle:
          textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      border: const UnderlineInputBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(48),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(48),
      ),
    ),
  );
}

/// Dark theme
ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFF2E5AAC),
  );

  final textTheme = GoogleFonts.beVietnamProTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: base.appBarTheme.copyWith(
      centerTitle: true,
      titleTextStyle:
          textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      behavior: SnackBarBehavior.floating,
    ),
  );
}
