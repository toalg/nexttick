import 'package:flutter/material.dart';

/// Premium NextTick theme combining HabitKit's vibrant energy with Things' refined elegance
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Enhanced vibrant color palette inspired by HabitKit
  static const _vibrantPrimary = Color(0xFF6366F1); // NextTick brand
  static const _vibrantSecondary = Color(0xFF10B981); // Success green
  static const _vibrantTertiary = Color(0xFFF59E0B); // Warm orange
  static const _vibrantAccent = Color(0xFF8B5CF6); // Purple accent
  static const _vibrantSuccess = Color(0xFF22C55E); // Bright green
  static const _vibrantWarning = Color(0xFFF97316); // Vibrant orange
  static const _vibrantError = Color(0xFFEF4444); // Bright red

  // Light theme with vibrant, sophisticated colors
  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF6366F1), // NextTick vibrant primary
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0E7FF),
    onPrimaryContainer: Color(0xFF1E1B4B),
    secondary: Color(0xFF10B981), // Vibrant success green
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD1FAE5),
    onSecondaryContainer: Color(0xFF064E3B),
    tertiary: Color(0xFFF59E0B), // Warm energetic orange
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFEF3C7),
    onTertiaryContainer: Color(0xFF92400E),
    error: Color(0xFFEF4444), // Bright error red
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEF2F2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: Color(0xFFFFFFFF), // Pure white surface
    onSurface: Color(0xFF0F172A),
    surfaceContainerHighest: Color(0xFFF8FAFC), // Subtle surface variation
    onSurfaceVariant: Color(0xFF475569),
    outline: Color(0xFFE2E8F0), // Soft outline
    outlineVariant: Color(0xFFF1F5F9),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF8FAFC),
    inversePrimary: Color(0xFFA5B4FC),
    surfaceTint: Color(0xFF6366F1),
  );

  // Dark theme with sophisticated, vibrant colors
  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA5B4FC), // Vibrant primary for dark
    onPrimary: Color(0xFF1E1B4B),
    primaryContainer: Color(0xFF4338CA),
    onPrimaryContainer: Color(0xFFE0E7FF),
    secondary: Color(0xFF6EE7B7), // Bright success green
    onSecondary: Color(0xFF064E3B),
    secondaryContainer: Color(0xFF065F46),
    onSecondaryContainer: Color(0xFFD1FAE5),
    tertiary: Color(0xFFFCD34D), // Bright energetic orange
    onTertiary: Color(0xFF92400E),
    tertiaryContainer: Color(0xFFB45309),
    onTertiaryContainer: Color(0xFFFEF3C7),
    error: Color(0xFFF87171), // Bright error red
    onError: Color(0xFF7F1D1D),
    errorContainer: Color(0xFF991B1B),
    onErrorContainer: Color(0xFFFEF2F2),
    surface: Color(0xFF1E293B), // Rich dark surface
    onSurface: Color(0xFFF8FAFC),
    surfaceContainerHighest: Color(0xFF334155), // Subtle dark variation
    onSurfaceVariant: Color(0xFFCBD5E1),
    outline: Color(0xFF475569), // Soft dark outline
    outlineVariant: Color(0xFF334155),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFF8FAFC),
    onInverseSurface: Color(0xFF1E293B),
    inversePrimary: Color(0xFF6366F1),
    surfaceTint: Color(0xFFA5B4FC),
  );

  /// Light theme configuration with premium polish
  static ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: _buildPremiumTextTheme(_lightColorScheme),
      appBarTheme: _buildPremiumAppBarTheme(_lightColorScheme),
      cardTheme: _buildPremiumCardTheme(_lightColorScheme),
      elevatedButtonTheme: _buildPremiumElevatedButtonTheme(_lightColorScheme),
      floatingActionButtonTheme: _buildPremiumFloatingActionButtonTheme(
        _lightColorScheme,
      ),
      inputDecorationTheme: _buildPremiumInputDecorationTheme(
        _lightColorScheme,
      ),
      chipTheme: _buildPremiumChipTheme(_lightColorScheme),
      bottomNavigationBarTheme: _buildPremiumBottomNavigationBarTheme(
        _lightColorScheme,
      ),
      navigationBarTheme: _buildPremiumNavigationBarTheme(_lightColorScheme),
      iconTheme: _buildPremiumIconTheme(_lightColorScheme),
      dividerTheme: _buildPremiumDividerTheme(_lightColorScheme),
    );

  /// Dark theme configuration with premium polish
  static ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      textTheme: _buildPremiumTextTheme(_darkColorScheme),
      appBarTheme: _buildPremiumAppBarTheme(_darkColorScheme),
      cardTheme: _buildPremiumCardTheme(_darkColorScheme),
      elevatedButtonTheme: _buildPremiumElevatedButtonTheme(_darkColorScheme),
      floatingActionButtonTheme: _buildPremiumFloatingActionButtonTheme(
        _darkColorScheme,
      ),
      inputDecorationTheme: _buildPremiumInputDecorationTheme(_darkColorScheme),
      chipTheme: _buildPremiumChipTheme(_darkColorScheme),
      bottomNavigationBarTheme: _buildPremiumBottomNavigationBarTheme(
        _darkColorScheme,
      ),
      navigationBarTheme: _buildPremiumNavigationBarTheme(_darkColorScheme),
      iconTheme: _buildPremiumIconTheme(_darkColorScheme),
      dividerTheme: _buildPremiumDividerTheme(_darkColorScheme),
    );

  /// Premium text theme with sophisticated typography
  static TextTheme _buildPremiumTextTheme(final ColorScheme colorScheme) => TextTheme(
      // Display styles - large, impactful headlines
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w300, // Light for elegance
        letterSpacing: -0.25,
        height: 1.12,
        color: colorScheme.onSurface,
        shadows: [
          Shadow(
            color: colorScheme.shadow.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        height: 1.16,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
        color: colorScheme.onSurface,
      ),

      // Headline styles - section headers
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600, // Semibold for emphasis
        letterSpacing: 0,
        height: 1.25,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.29,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: colorScheme.onSurface,
      ),

      // Title styles - card headers, important text
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorScheme.onSurface,
      ),

      // Body styles - main content
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: colorScheme.onSurfaceVariant,
      ),

      // Label styles - buttons, chips
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: colorScheme.onSurfaceVariant,
      ),
    );

  /// Premium AppBar theme with subtle elevation
  static AppBarTheme _buildPremiumAppBarTheme(final ColorScheme colorScheme) => AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
    );

  /// Premium Card theme with sophisticated elevation
  static CardThemeData _buildPremiumCardTheme(final ColorScheme colorScheme) => CardThemeData(
      color: colorScheme.surface,
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );

  /// Premium ElevatedButton theme with vibrant colors
  static ElevatedButtonThemeData _buildPremiumElevatedButtonTheme(
    final ColorScheme colorScheme,
  ) => ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
    );

  /// Premium FloatingActionButton theme
  static FloatingActionButtonThemeData _buildPremiumFloatingActionButtonTheme(
    final ColorScheme colorScheme,
  ) => FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );

  /// Premium InputDecoration theme
  static InputDecorationTheme _buildPremiumInputDecorationTheme(
    final ColorScheme colorScheme,
  ) => InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      hintStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
      ),
    );

  /// Premium Chip theme with vibrant colors
  static ChipThemeData _buildPremiumChipTheme(final ColorScheme colorScheme) => ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.8),
      selectedColor: colorScheme.primaryContainer,
      disabledColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 1,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
    );

  /// Premium BottomNavigationBar theme
  static BottomNavigationBarThemeData _buildPremiumBottomNavigationBarTheme(
    final ColorScheme colorScheme,
  ) => BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );

  /// Premium NavigationBar theme (Material 3)
  static NavigationBarThemeData _buildPremiumNavigationBarTheme(
    final ColorScheme colorScheme,
  ) => NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((final states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          );
        }
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((final states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.onPrimaryContainer, size: 24);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
      }),
    );

  /// Premium Icon theme
  static IconThemeData _buildPremiumIconTheme(final ColorScheme colorScheme) => IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);

  /// Premium Divider theme
  static DividerThemeData _buildPremiumDividerTheme(final ColorScheme colorScheme) => DividerThemeData(
      color: colorScheme.outline.withOpacity(0.2),
      thickness: 1,
      space: 1,
    );

  /// Get theme mode from system preference
  static ThemeMode getThemeMode(final String? themePreference) {
    switch (themePreference) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Check if current theme is dark
  static bool isDarkTheme(final BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  /// Get color scheme from context
  static ColorScheme getColorScheme(final BuildContext context) => Theme.of(context).colorScheme;

  /// Get vibrant accent colors for habit categories
  static List<Color> get habitCategoryColors => [
    _vibrantPrimary, // Primary habits
    _vibrantSecondary, // Health & fitness
    _vibrantTertiary, // Learning & growth
    _vibrantAccent, // Creative & hobbies
    _vibrantSuccess, // Productivity
    _vibrantWarning, // Social & relationships
  ];

  /// Get gradient for premium elements
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [_vibrantPrimary, _vibrantAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Get success gradient
  static LinearGradient get successGradient => const LinearGradient(
    colors: [_vibrantSecondary, _vibrantSuccess],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Get energetic gradient
  static LinearGradient get energeticGradient => const LinearGradient(
    colors: [_vibrantTertiary, _vibrantWarning],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
