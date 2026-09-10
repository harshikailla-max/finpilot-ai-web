import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============================================================
  // FINPILOT LUXURY OBSIDIAN & MIDNIGHT PALETTE
  // ============================================================

  static const Color background = Color(0xFF050814);
  static const Color background2 = Color(0xFF080C18);
  static const Color background3 = Color(0xFF0B1020);

  static const Color card = Color(0xFF101626);
  static const Color cardLight = Color(0xFF141B2D);
  static const Color cardElevated = Color(0xFF182033);

  // Executive Futuristic Accents
  static const Color purple = Color(0xFF6C5CE7);
  static const Color brightPurple = Color(0xFF8B7CFF);
  static const Color lavender = Color(0xFF9A8CFF);

  // Cyan & Blue Accents
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color blue = Color(0xFF72DFFF);

  // Semantic Indicators
  static const Color pink = Color(0xFFF472B6);
  static const Color orange = Color(0xFFF59E0B);
  static const Color green = Color(0xFF4ADE80);
  static const Color red = Color(0xFFFF5C7A);

  // High-Contrast Luxury Typography
  static const Color white = Color(0xFFF7F8FC);
  static const Color textSecondary = Color(0xFFB8C0D4);
  static const Color textMuted = Color(0xFF747E98);

  // ============================================================
  // BACKWARD COMPATIBILITY
  // ============================================================
  // These keep your existing screens working.

  static const Color primary = purple;
  static const Color primaryLight = brightPurple;

  static const Color secondary = cyan;
  static const Color accent = cyan;

  static const Color backgroundDark = background;
  static const Color surface = card;

  static const Color textPrimary = white;

  // ============================================================
  // GRADIENTS
  // ============================================================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      purple,
      brightPurple,
      cyan,
    ],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6D4AFF),
      Color(0xFFA855F7),
    ],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      cyan,
      blue,
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF142544),
      Color(0xFF0A1730),
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF08152A),
      Color(0xFF050D1C),
      Color(0xFF071326),
    ],
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: purple,
      secondary: cyan,
      surface: card,
      onPrimary: white,
      onSecondary: background,
      onSurface: white,
    ),

    // ==========================================================
    // TEXT
    // ==========================================================

    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          color: white,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          color: white,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: TextStyle(
          color: white,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: white,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: white,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: white,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: white,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: white,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: white,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: white,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // ==========================================================
    // APP BAR
    // ==========================================================

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: white,
    ),

    // ==========================================================
    // CARD
    // ==========================================================

    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
    ),

    // ==========================================================
    // INPUT FIELDS
    // ==========================================================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: white.withValues(alpha: 0.08),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: white.withValues(alpha: 0.08),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: purple,
          width: 1.2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: red,
          width: 1.2,
        ),
      ),

      hintStyle: const TextStyle(
        color: textMuted,
      ),

      labelStyle: const TextStyle(
        color: textSecondary,
      ),
    ),

    // ==========================================================
    // ELEVATED BUTTON
    // ==========================================================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: purple,
        foregroundColor: white,
        elevation: 0,

        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 15,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ==========================================================
    // OUTLINED BUTTON
    // ==========================================================

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: white,

        side: BorderSide(
          color: white.withValues(alpha: 0.15),
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 14,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    // ==========================================================
    // TEXT BUTTON
    // ==========================================================

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cyan,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // ==========================================================
    // ICONS
    // ==========================================================

    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 22,
    ),

    // ==========================================================
    // DIVIDERS
    // ==========================================================

    dividerTheme: DividerThemeData(
      color: white.withValues(alpha: 0.07),
      thickness: 1,
      space: 1,
    ),

    // ==========================================================
    // PROGRESS INDICATORS
    // ==========================================================

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: purple,
      linearTrackColor: Color(0xFF182744),
    ),

    // ==========================================================
    // CHECKBOX
    // ==========================================================

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return purple;
          }
          return Colors.transparent;
        },
      ),
      side: BorderSide(
        color: white.withValues(alpha: 0.25),
      ),
    ),

    // ==========================================================
    // SWITCH
    // ==========================================================

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return cyan;
          }
          return textSecondary;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return purple.withValues(alpha: 0.45);
          }
          return Colors.white.withValues(alpha: 0.08);
        },
      ),
    ),

    // ==========================================================
    // CHIP
    // ==========================================================

    chipTheme: ChipThemeData(
      backgroundColor: card,
      selectedColor: purple.withValues(alpha: 0.20),
      side: BorderSide(
        color: white.withValues(alpha: 0.08),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelStyle: const TextStyle(
        color: textSecondary,
      ),
    ),

    // ==========================================================
    // DIALOG
    // ==========================================================

    dialogTheme: DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: white.withValues(alpha: 0.10),
        ),
      ),
    ),

    // ==========================================================
    // BOTTOM SHEET
    // ==========================================================

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: background2,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: background2,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),

    // ==========================================================
    // SNACKBAR
    // ==========================================================

    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardLight,
      contentTextStyle: const TextStyle(
        color: white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ==========================================================
    // NAVIGATION BAR
    // ==========================================================

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: background2,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Color(0x338B5CF6),
      elevation: 0,

      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),

      iconTheme: const WidgetStatePropertyAll(
        IconThemeData(
          color: textSecondary,
        ),
      ),
    ),

    // ==========================================================
    // TAB BAR
    // ==========================================================

    tabBarTheme: TabBarThemeData(
      labelColor: white,
      unselectedLabelColor: textMuted,
      indicatorColor: brightPurple,
      dividerColor: Colors.transparent,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // ==========================================================
    // TOOLTIP
    // ==========================================================

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: white.withValues(alpha: 0.10),
        ),
      ),
      textStyle: const TextStyle(
        color: white,
        fontSize: 11,
      ),
    ),

    // ==========================================================
    // DROPDOWN
    // ==========================================================

    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(card),
        surfaceTintColor: const WidgetStatePropertyAll(
          Colors.transparent,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: white.withValues(alpha: 0.10),
            ),
          ),
        ),
      ),
    ),
  );
}