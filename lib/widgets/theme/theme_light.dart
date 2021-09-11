import 'package:flutter/material.dart';

const MaterialColor kOrangeColor = const MaterialColor(
  0xFFE64A19,
  const <int, Color>{
    50: const Color(0xFFfcede8),
    100: const Color(0xFFf7c8ba),
    200: const Color(0xFFf2a48c),
    300: const Color(0xFFed805e),
    400: const Color(0xFFeb6d47),
    500: const Color(0xFFE64A19),
    600: const Color(0xFFcf4217),
    700: const Color(0xFFa13312),
    800: const Color(0xFF73250d),
    900: const Color(0xFF451608),
  },
);

const MaterialColor kGreenColor = const MaterialColor(
  0xFF009A5C,
  const <int, Color>{
    50: const Color(0xFFccffeb),
    100: const Color(0xFF80ffcc),
    200: const Color(0xFF4dffb8),
    300: const Color(0xFF1affa3),
    400: const Color(0xFF00e68a),
    500: const Color(0xFF009A5C),
    600: const Color(0xFF00663d),
    700: const Color(0xFF004d2e),
    800: const Color(0xFF00331f),
    900: const Color(0xFF001a0f),
  },
);
const MaterialColor kDeepGreenColor = const MaterialColor(
  0xFF196F64,
  const <int, Color>{
    50: const Color(0xFFd5f6f1),
    100: const Color(0xFF97e7dd),
    200: const Color(0xFF6edecf),
    300: const Color(0xFF2fd0ba),
    400: const Color(0xFF219182),
    500: const Color(0xFF196F64),
    600: const Color(0xFF13534b),
    700: const Color(0xFF0e3e38),
    800: const Color(0xFF092a25),
    900: const Color(0xFF051513),
  },
);

const Color primaryColorLight = Color(0xFFFFF3E2);
const Color primaryColor = Color(0xFFFBAD59);

ThemeData themeLight() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColorLight: primaryColorLight,
    primaryColor: primaryColor,
    primaryColorDark: Color(0xFF222222),
    toggleableActiveColor: kGreenColor,
    tabBarTheme: tabBarTheme(),
    primaryIconTheme: IconThemeData(color: primaryColorLight),
    // iconTheme: IconThemeData(color: primaryColorLight),
    appBarTheme: appBarTheme(),

    scaffoldBackgroundColor: primaryColorLight,
    // textTheme: TextTheme(subtitle1: TextStyle(color: Color(0xFF222222))),
    cardTheme: cardTheme(),
    //Buttons Theme
    elevatedButtonTheme: elevatedButtonTheme(),
    textButtonTheme: textButtonTheme(),
    colorScheme: ColorScheme
        .fromSwatch(primarySwatch: kDeepGreenColor)
        .copyWith(secondary: kOrangeColor),
  );
}

//Text Styles

TextStyle textFormStyle() {
  return TextStyle(color: Colors.white);
}

TextStyle textDrawerStyle() {
  return TextStyle(
    fontSize: 20,
    fontStyle: FontStyle.italic,
    color: primaryColorLight,
  );
}

//Buttons Styles Theme

TabBarTheme tabBarTheme() {
  return TabBarTheme(
    indicator: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.zero,
      color: kOrangeColor.shade200,
    ),
    labelColor: Colors.blue,
    unselectedLabelColor: Colors.grey,
  );
}

TextButtonThemeData textButtonTheme() {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      // primary: Colors.black,
      shape: StadiumBorder(),
    ),
  );
}

ElevatedButtonThemeData elevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
  );
}

// Custom Button Style

ButtonStyle elevatedButtonFilterStyle() {
  return ElevatedButton.styleFrom(
    primary: kDeepGreenColor.shade100,
    onPrimary: Colors.black54,
    elevation: 5,
  );
}

// Widgets Styles
CardTheme cardTheme() {
  return CardTheme(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))),
    color: Color(0xFFFEC674),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    titleTextStyle: TextStyle(
      color: primaryColorLight,
      fontSize: 30,
      fontFamily: 'Dancing Script',
      fontWeight: FontWeight.w700,
    ),
    backgroundColor: primaryColor,
    centerTitle: true,
  );
}

//Colors Styles

LinearGradient defaultLinearGradient() {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    // transform: GradientTransform,
    colors: [
      primaryColor,
      primaryColorLight,
    ],
  );
}
