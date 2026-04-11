import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF6D3F);
  static const Color primaryDark = Color(0xFFE85A2A);
  static const Color accentColor = Color(0xFF00D4AA);
  static const Color errorColor = Color(0xFFFF4D6D);
  static const Color warningColor = Color(0xFFFFB830);
  static const Color successColor = Color(0xFF00C48C);

  // Dark theme colors
  static const Color darkBg = Color(0xFF0D0D14);
  static const Color darkSurface = Color(0xFF14141F);
  static const Color darkCard = Color(0xFF1A1A28);
  static const Color darkCardHover = Color(0xFF20202F);
  static const Color darkBorder = Color(0xFF252535);
  static const Color darkTextPrimary = Color(0xFFF0F0FF);
  static const Color darkTextSecondary = Color(0xFF8888AA);
  static const Color darkTextMuted = Color(0xFF55556A);

  // Light theme colors
  static const Color lightBg = Color(0xFFF5F5FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8E8F0);
  static const Color lightTextPrimary = Color(0xFF0D0D1A);
  static const Color lightTextSecondary = Color(0xFF666688);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: darkSurface,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(
      const TextTheme(
        displayLarge:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),
        displayMedium:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),
        displaySmall:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        headlineLarge:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),
        headlineMedium:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        headlineSmall:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleLarge:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500),
        titleSmall:
            TextStyle(color: darkTextSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: darkTextPrimary),
        bodyMedium: TextStyle(color: darkTextSecondary),
        bodySmall: TextStyle(color: darkTextMuted),
        labelLarge:
            TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        labelMedium:
            TextStyle(color: darkTextSecondary, fontWeight: FontWeight.w500),
        labelSmall:
            TextStyle(color: darkTextMuted, fontWeight: FontWeight.w500),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: darkTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: const TextStyle(color: darkTextSecondary),
      hintStyle: const TextStyle(color: darkTextMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:
            GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? primaryColor : darkTextMuted),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? primaryColor.withValues(alpha: 0.3)
              : darkBorder),
    ),
    dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: darkCard,
      labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 12),
      side: const BorderSide(color: darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: lightSurface,
      error: errorColor,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:
            GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
  );
}
