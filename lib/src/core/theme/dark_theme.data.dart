
import 'package:kiosk/src/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class DarkTheme {
  DarkTheme._();

  static TextTheme textTheme = const TextTheme(
    // bodyText1: TextStyle(
    //   color: Colors.white,
    //   fontSize: 18.0,
    //   fontWeight: FontWeight.w400,
    // ),
    bodyLarge: TextStyle(
        color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
    // bodyText2: TextStyle(color: AppColors.kLabelColor, fontSize: 17.0),
    bodySmall: TextStyle(color: AppColors.white),
    titleMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    titleSmall: TextStyle(
      color: Colors.white,
    ),
    // headline1: TextStyle(color: AppColors.white),
    // headline2: TextStyle(color: AppColors.white),
    displaySmall: TextStyle(color: AppColors.white),
    headlineMedium: TextStyle(color: AppColors.white, fontSize: 22.0),
    headlineSmall: TextStyle(color: AppColors.white, fontSize: 18.0),
    titleLarge: TextStyle(color: AppColors.white),

    displayLarge: TextStyle(
        color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 20),
    // headline2: TextStyle(color: Colors.black),
    displayMedium: TextStyle(
        color: AppColors.white, fontWeight: FontWeight.normal, fontSize: 16),
  );

  static get getTheme => ThemeData(
    primaryColor: AppColors.primaryColor,
    primaryColorDark:  AppColors.kDarkGrey,
    primaryColorLight: AppColors.white,
    scaffoldBackgroundColor: Colors.black,
    brightness: Brightness.dark,
    textTheme: textTheme,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(getColor),
      ),
    ),
    dialogBackgroundColor:AppColors.kDarkerGrey,
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: AppColors.kDarkGrey,
    ),
    appBarTheme: const AppBarTheme(
      color: AppColors.kDarkGrey,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.kDarkGrey,
      unselectedItemColor: AppColors.kLighterGrey,
      selectedItemColor: AppColors.primaryColor,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.white,
      secondary: Colors.white,
      onSecondary: AppColors.primaryColor,
      surface: AppColors.kDarkGrey,
      onSurface: Colors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith(getColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith(getColor),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
    ), bottomAppBarTheme: BottomAppBarTheme(color: AppColors.kLightGrey),
  );

  static Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.primaryColor;
    }
    return AppColors.primaryColor;
  }
}
