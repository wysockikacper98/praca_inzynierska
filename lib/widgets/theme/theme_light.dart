import 'package:flutter/material.dart';

const MaterialColor kOrangeColor = const MaterialColor(
  0xFFE64A19,
  const <int, Color>{
    50: const Color(0xFFE64A19),
    100: const Color(0xFFE64A19),
    200: const Color(0xFFE64A19),
    300: const Color(0xFFE64A19),
    400: const Color(0xFFE64A19),
    500: const Color(0xFFE64A19),
    600: const Color(0xFFE64A19),
    700: const Color(0xFFE64A19),
    800: const Color(0xFFE64A19),
    900: const Color(0xFFE64A19),
  },
);

const MaterialColor kGreenColor = const MaterialColor(
  0xFF009A5C,
  const <int, Color>{
    50: const Color(0xFF009A5C),
    100: const Color(0xFF009A5C),
    200: const Color(0xFF009A5C),
    300: const Color(0xFF009A5C),
    400: const Color(0xFF009A5C),
    500: const Color(0xFF009A5C),
    600: const Color(0xFF009A5C),
    700: const Color(0xFF009A5C),
    800: const Color(0xFF009A5C),
    900: const Color(0xFF009A5C),
  },
);
const MaterialColor kDeepGreenColor = const MaterialColor(
  0xFF196F64,
  const <int, Color>{
    50: const Color(0xFF196F64),
    100: const Color(0xFF196F64),
    200: const Color(0xFF196F64),
    300: const Color(0xFF196F64),
    400: const Color(0xFF196F64),
    500: const Color(0xFF196F64),
    600: const Color(0xFF196F64),
    700: const Color(0xFF196F64),
    800: const Color(0xFF196F64),
    900: const Color(0xFF196F64),
  },
);

ThemeData themeLight() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFFFFF3E2),
    primaryColorDark: Color(0xFF222222),
    accentColor: kOrangeColor,
    primarySwatch: kDeepGreenColor,
    toggleableActiveColor: kGreenColor,

    primaryIconTheme: IconThemeData(color: Color(0xFFFFF3E2)),

    appBarTheme: appBarTheme(),

    scaffoldBackgroundColor: Color(0xFFFFF3E2),
    // textTheme: TextTheme(subtitle1: TextStyle(color: Color(0xFF222222))),
    cardTheme: cardTheme(),
    //Buttons Theme
    elevatedButtonTheme: elevatedButtonTheme(),
    textButtonTheme: textButtonTheme(),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    textTheme: TextTheme(
      headline6: TextStyle(
        color: Color(0xFFFFF3E2),
        fontSize: 30,
        fontFamily: 'Dancing Script',
        fontWeight: FontWeight.w700,
      ),
    ),
    backgroundColor: Color(0xFFFBAD59),centerTitle: true,
  );
}

TextStyle textFormStyle() {
  return TextStyle(color: Colors.white);
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

CardTheme cardTheme() {
  return CardTheme(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))),
    color: Color(0xFFFEC674),
  );
}
