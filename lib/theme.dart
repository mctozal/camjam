import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  // 🌟 Set Black Background
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    centerTitle: true,
    toolbarHeight: 100,
    titleTextStyle: TextStyle(
      fontSize: 16,
    ),
  ),

  // 🌟 Define Color Scheme
  colorScheme: ColorScheme.dark(
    primary: Colors.white, // Primary Green
    secondary: Colors.green, // Secondary Purple
    onPrimary: Colors.white, // White Text on Primary
    onSecondary: Colors.white, // White Text on Secondary
  ),

  // 🌟 Apply SF Pro Text Font
  fontFamily: 'SF Pro Text',

  // 🌟 Define Text Theme
  textTheme: TextTheme(
    headlineLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
  ),

  // 🌟 Button Themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14), // Button Border Radius
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'SF Pro Text'),
    ),
  ),

  // 🌟 Customize Individual Button Colors
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.green, // Green text
      side: BorderSide(color: Colors.green), // Green Border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.purple, // Purple text
      textStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'SF Pro Text'),
    ),
  ),

  // 🌟 Input Field Styling
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF484848), // Slight White Tint for Fields
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Color(0xFF5d5d5d), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    labelStyle: TextStyle(color: Colors.grey[200]),
  ),

  // 🌟 Card Theme
  cardTheme: CardTheme(
    color: Colors.white10,
    shadowColor: Colors.black26,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
);
