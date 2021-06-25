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

const Color primaryColorLight = Color(0xFFFFF3E2);
const Color primaryColor = Color(0xFFFBAD59);

ThemeData themeLight() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColorLight: primaryColorLight,
    primaryColor: primaryColor,
    primaryColorDark: Color(0xFF222222),
    accentColor: kOrangeColor,
    primarySwatch: kDeepGreenColor,
    toggleableActiveColor: kGreenColor,

    primaryIconTheme: IconThemeData(color: primaryColorLight),
    // iconTheme: IconThemeData(color: primaryColorLight),
    appBarTheme: appBarTheme(),

    scaffoldBackgroundColor: primaryColorLight,
    // textTheme: TextTheme(subtitle1: TextStyle(color: Color(0xFF222222))),
    cardTheme: cardTheme(),
    //Buttons Theme
    elevatedButtonTheme: elevatedButtonTheme(),
    textButtonTheme: textButtonTheme(),
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


//Buttons Styles

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
    textTheme: TextTheme(
      headline6: TextStyle(
        color: primaryColorLight,
        fontSize: 30,
        fontFamily: 'Dancing Script',
        fontWeight: FontWeight.w700,
      ),
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
