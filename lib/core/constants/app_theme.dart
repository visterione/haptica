import 'package:flutter/material.dart';

class AppTheme {
  // Приватний конструктор для заборони створення екземплярів
  AppTheme._();

  // Основні кольори
  static const Color primaryColor = Color(0xFFFFD700);     // Жовтий (Primary)
  static const Color primaryDarkColor = Color(0xFFFFC300); // Темно-жовтий
  static const Color accentColor = Color(0xFF3D5AFE);      // Акцентний синій
  static const Color textColor = Color(0xFF212121);        // Основний текст
  static const Color textLightColor = Color(0xFF757575);   // Другорядний текст
  static const Color backgroundColor = Color(0xFFFAFAFA);  // Фон
  static const Color errorColor = Color(0xFFD32F2F);       // Помилка
  static const Color successColor = Color(0xFF388E3C);     // Успіх
  static const Color warningColor = Color(0xFFFFA000);     // Попередження
  static const Color cardColor = Color(0xFFFFFFFF);        // Колір карток

  // Константи для темної теми
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardColor = Color(0xFF2D2D2D);

  // Градієнтні схеми
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryDarkColor],
  );

  // Розміри тексту
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 22.0;
  static const double fontSizeXXLarge = 26.0;

  // Радіуси заокруглень
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusRegular = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Відступи
  static const double paddingSmall = 4.0;
  static const double paddingRegular = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Тіні
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 4.0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];

  // Стилі тексту
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: fontSizeRegular,
    color: textColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: fontSizeSmall,
    color: textLightColor,
  );

  // Основна тема додатку (світла)
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    primaryColorDark: primaryDarkColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      background: backgroundColor,
    ),
    cardColor: cardColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle,
      displayMedium: subheadingStyle,
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle,
      bodySmall: captionStyle,
    ),
    fontFamily: 'Montserrat',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingRegular,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: const BorderSide(color: accentColor),
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingRegular,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.all(paddingMedium),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      hintStyle: captionStyle,
      errorStyle: captionStyle.copyWith(color: errorColor),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
      ),
      margin: const EdgeInsets.all(paddingRegular),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textColor,
      contentTextStyle: captionStyle.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.black12,
      space: paddingRegular,
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textLightColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      titleTextStyle: subheadingStyle,
      contentTextStyle: bodyStyle,
    ),
  );

  // Темна тема
  static ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    primaryColorDark: primaryDarkColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      background: darkBackground,
      surface: darkSurface,
    ),
    cardColor: darkCardColor,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: headingStyle.copyWith(color: Colors.white),
      displayMedium: subheadingStyle.copyWith(color: Colors.white),
      bodyLarge: bodyStyle.copyWith(color: Colors.white),
      bodyMedium: bodyStyle.copyWith(color: Colors.white),
      bodySmall: captionStyle.copyWith(color: Colors.white70),
    ),
    fontFamily: 'Montserrat',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingRegular,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: const BorderSide(color: accentColor),
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingRegular,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      contentPadding: const EdgeInsets.all(paddingMedium),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      hintStyle: captionStyle.copyWith(color: Colors.white54),
      errorStyle: captionStyle.copyWith(color: errorColor),
    ),
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
      ),
      margin: const EdgeInsets.all(paddingRegular),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1F1F1F),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.white24,
      space: paddingRegular,
      thickness: 1,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      titleTextStyle: subheadingStyle.copyWith(color: Colors.white),
      contentTextStyle: bodyStyle.copyWith(color: Colors.white),
    ),
  );
}