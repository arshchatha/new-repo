
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppTheme {
  static const MaterialColor blueSwatch = Colors.blue;
  static const MaterialColor redSwatch = Colors.red;
  static const Color blackColor = Colors.black;
  static const Color reddishPink = Color(0xFFE91E63);

  static ThemeData buildBlueTheme() {
    return ThemeData(
      primarySwatch: blueSwatch, // Use predefined MaterialColor
      brightness: Brightness.light,
      primaryColor: blueSwatch,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: blueSwatch,
        brightness: Brightness.light,
      ).copyWith(
        secondary: reddishPink,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: blueSwatch,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        toolbarTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: blackColor, fontSize: 16),
        bodyMedium: TextStyle(color: blackColor.withOpacity(0.7), fontSize: 14),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: blueSwatch,
        textTheme: ButtonTextTheme.primary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: blueSwatch,
        unselectedItemColor: blackColor.withOpacity(0.6),
      ),
    );
  }

  static ThemeData buildRedTheme() {
    return ThemeData(
      primarySwatch: redSwatch,
      brightness: Brightness.light,
      primaryColor: redSwatch,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: redSwatch,
        accentColor: redSwatch.shade700,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: redSwatch,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        toolbarTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: blackColor, fontSize: 16),
        bodyMedium: TextStyle(color: blackColor.withOpacity(0.7), fontSize: 14),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: redSwatch,
        textTheme: ButtonTextTheme.primary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: redSwatch,
        unselectedItemColor: blackColor.withOpacity(0.6),
      ),
    );
  }

  static ThemeData buildRasketTheme() {
    const Color rasketBlue = Color(0xFF007BFF);
    const Color rasketReddishPink = Color(0xFFE91E63);
    const Color rasketWhite = Colors.white;
    const Color rasketBlack = Colors.black;

    return ThemeData(
      primaryColor: rasketBlue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: rasketWhite,
      colorScheme: ColorScheme.light(
        primary: rasketBlue,
        secondary: rasketReddishPink,
        background: rasketWhite,
        onPrimary: rasketWhite,
        onSecondary: rasketWhite,
      ),
      appBarTheme: AppBarTheme(
        color: rasketBlue,
        iconTheme: IconThemeData(color: rasketWhite),
        titleTextStyle: TextStyle(color: rasketWhite, fontSize: 20, fontWeight: FontWeight.bold),
        toolbarTextStyle: TextStyle(color: rasketWhite, fontSize: 18),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: rasketBlack, fontSize: 16),
        bodyMedium: TextStyle(color: rasketBlack.withOpacity(0.7), fontSize: 14),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: rasketBlue,
        textTheme: ButtonTextTheme.primary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: rasketBlue,
        unselectedItemColor: rasketBlack.withOpacity(0.6),
      ),
    );
  }
}
