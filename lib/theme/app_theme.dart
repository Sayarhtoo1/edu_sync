import 'package:flutter/material.dart';

// --- Color Palette (Inspired by Admin Panel Screen) ---
const Color appBackgroundColor = Color(0xFFF5F0FF); // Very light pastel purple
const Color cardBackgroundColor = Colors.white;
const Color textDarkGrey = Color(0xFF2C2C2C);
const Color textLightGrey = Color(0xFF8C8C8C);

// Accent colors for summary items / contextual theming
const Color accentStudents = Color(0xFFE0C7FF); // Pastel Purple
const Color iconBgStudents = Color(0xFFD4D0FB); // Slightly darker purple for icon bg
const Color iconColorStudents = Color(0xFF7A6FF0); // Icon color

const Color accentTeachers = Color(0xFFC7E9FF); // Pastel Blue
const Color iconBgTeachers = Color(0xFFB3E0FD);
const Color iconColorTeachers = Color(0xFF3B9EFF);

const Color accentParents = Color(0xFFFFD6C7); // Pastel Orange
const Color iconBgParents = Color(0xFFFFDAB3);
const Color iconColorParents = Color(0xFFFFA726);

const Color accentEarnings = Color(0xFFD5F5D1); // Pastel Green (can be used for forms/reports or general success)
const Color iconBgEarnings = Color(0xFFC8E6C9);
const Color iconColorEarnings = Color(0xFF4CAF50);

// Default Accent (if no specific context applies, can use one of the above or a neutral one)
const Color defaultAccentColor = iconColorStudents; // Using student icon color as a default primary

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: defaultAccentColor,
      scaffoldBackgroundColor: appBackgroundColor, // Default background for all scaffolds
      colorScheme: ColorScheme.light(
        primary: defaultAccentColor,
        secondary: accentTeachers, // Example secondary, can be adjusted
        surface: cardBackgroundColor,
        error: Colors.red.shade700,
        onPrimary: Colors.white,
        onSecondary: textDarkGrey,
        onSurface: textDarkGrey,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: appBackgroundColor, // Or Colors.transparent if a more blended look is desired
        elevation: 0,
        iconTheme: IconThemeData(color: textDarkGrey),
        titleTextStyle: TextStyle(
          color: textDarkGrey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins', // Assuming Poppins is used, ensure it's in pubspec.yaml
        ),
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textDarkGrey, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        headlineMedium: TextStyle(color: textDarkGrey, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        headlineSmall: TextStyle(color: textDarkGrey, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        titleLarge: TextStyle(color: textDarkGrey, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        titleMedium: TextStyle(color: textDarkGrey, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
        titleSmall: TextStyle(color: textDarkGrey, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
        bodyLarge: TextStyle(color: textDarkGrey, fontFamily: 'Poppins'),
        bodyMedium: TextStyle(color: textDarkGrey, fontFamily: 'Poppins'),
        bodySmall: TextStyle(color: textLightGrey, fontFamily: 'Poppins'),
        labelLarge: TextStyle(color: defaultAccentColor, fontWeight: FontWeight.w600, fontFamily: 'Poppins'), // For buttons
        labelMedium: TextStyle(color: textLightGrey, fontFamily: 'Poppins'),
        labelSmall: TextStyle(color: textLightGrey, fontFamily: 'Poppins'),
      ).apply(
        bodyColor: textDarkGrey,
        displayColor: textDarkGrey,
        fontFamily: 'Poppins', // Default font family
      ),
      cardTheme: CardThemeData(
        color: cardBackgroundColor,
        elevation: 1.0, // Subtle shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Default card margin
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackgroundColor.withAlpha(200), // Slightly transparent white or a very light grey
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: defaultAccentColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textLightGrey, fontFamily: 'Poppins'),
        hintStyle: const TextStyle(color: textLightGrey, fontFamily: 'Poppins'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: defaultAccentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: defaultAccentColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: defaultAccentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        titleTextStyle: const TextStyle(color: textDarkGrey, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        contentTextStyle: const TextStyle(color: textDarkGrey, fontFamily: 'Poppins'),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBackgroundColor,
        selectedItemColor: defaultAccentColor,
        unselectedItemColor: textLightGrey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
        elevation: 8.0, // Add some elevation
      ),
      // Add other theme properties as needed (e.g., chipTheme, tabBarTheme)
    );
  }

  // Helper method to get contextual accent color
  // This can be expanded or used directly in screens
  static Color getAccentColorForContext(String context) {
    switch (context.toLowerCase()) {
      case 'student':
      case 'students':
        return iconColorStudents;
      case 'teacher':
      case 'teachers':
      case 'staff':
        return iconColorTeachers;
      case 'parent':
      case 'parents':
        return iconColorParents;
      case 'form':
      case 'report':
      case 'earning':
      case 'finance':
      case 'success':
        return iconColorEarnings;
      default:
        return defaultAccentColor;
    }
  }
}
