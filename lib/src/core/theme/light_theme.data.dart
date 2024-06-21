import 'package:kiosk/src/core/constants/app_colors.dart';
import 'package:flutter/material.dart';


class LightTheme {
  LightTheme._();

  static TextTheme textTheme = const TextTheme(
    // subtitle1: TextStyle(
    //   color: Color(0xFF333333),
    //   fontWeight: FontWeight.w400,
    //   fontSize: 16,
    // ),
    // subtitle2: TextStyle(
    //   color: const Color(0xFF333333),
    // ),
    // bodyText1: TextStyle(
    //   color: Color(0xFF111111),
    //   fontWeight: FontWeight.w400,
    //   fontSize: 18,
    // ),
    // bodyText2: TextStyle(
    //     color: AppColors.kLabelColor,
    //     fontSize: 17.0),
    bodyLarge: TextStyle(
        color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
    bodySmall: TextStyle(color: Colors.black),
    //headline1: TextStyle(color: Colors.black),
    displayLarge: TextStyle(
        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    // headline2: TextStyle(color: Colors.black),
    displayMedium: TextStyle(
        color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16),
    displaySmall: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(
      color: Colors.black,
      fontSize: 22.0,
    ),
    headlineSmall: TextStyle(color: Colors.black, fontSize: 18.0),
    titleLarge: TextStyle(color: Colors.black),
  );

  static get getTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.appColor, //const Color(0xFFeef0ef),
    colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
    primaryColor: AppColors.primaryColor,
    primaryColorDark: AppColors.primaryColor,
    indicatorColor: AppColors.primaryColor,
    iconTheme: const IconThemeData(color: Colors.black),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      // iconTheme: IconThemeData(color: AppColors.primaryColor)
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.appColor,
      selectedItemColor: AppColors.primaryColor,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.kNormalBlue,
        foregroundColor: AppColors.foreGroundColor),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith(getColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith(getColor),
      ),
    ),
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
