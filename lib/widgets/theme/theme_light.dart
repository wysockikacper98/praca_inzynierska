import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

// New colors

const MaterialColor pastelDeepGreenColor = const MaterialColor(
  0xFF5BAB9E,
  const <int, Color>{
    50: const Color(0xFFddeeeb),
    100: const Color(0xFFbcdcd7),
    200: const Color(0xFFabd4cd),
    300: const Color(0xFF89c2b9),
    400: const Color(0xFF68b1a5),
    500: const Color(0xFF5BAB9E),
    600: const Color(0xFF45877c),
    700: const Color(0xFF34655d),
    800: const Color(0xFF23433e),
    900: const Color(0xFF11221f),
  },
);

const MaterialColor pastelLightBlueColor = const MaterialColor(
  0xFF91C1CB,
  const <int, Color>{
    50: const Color(0xFFdcecef),
    100: const Color(0xFFcbe2e7),
    200: const Color(0xFFbad8de),
    300: const Color(0xFFa8cfd6),
    400: const Color(0xFF97c5ce),
    500: const Color(0xFF91C1CB),
    600: const Color(0xFF74b1be),
    700: const Color(0xFF529ead),
    800: const Color(0xFF417e8b),
    900: const Color(0xFF315f68),
  },
);

const MaterialColor pastelBlueColor = const MaterialColor(
  0xFF3B557A,
  const <int, Color>{
    50: const Color(0xFFcbd7e6),
    100: const Color(0xFFa9bcd6),
    200: const Color(0xFF87a1c5),
    300: const Color(0xFF6486b4),
    400: const Color(0xFF4b6c9b),
    500: const Color(0xFF3B557A),
    600: const Color(0xFF324867),
    700: const Color(0xFF293c56),
    800: const Color(0xFF213045),
    900: const Color(0xFF192434),
  },
);
const MaterialColor pastelStrongBlueColor = const MaterialColor(
  0xFF2F4496,
  const <int, Color>{
    50: const Color(0xFFb1bce7),
    100: const Color(0xFF8b9bda),
    200: const Color(0xFF6479ce),
    300: const Color(0xFF3d58c2),
    400: const Color(0xFF374fae),
    500: const Color(0xFF2F4496),
    600: const Color(0xFF2b3d88),
    700: const Color(0xFF253574),
    800: const Color(0xFF1f2c61),
    900: const Color(0xFF18234e),
  },
);

const MaterialColor pastelOrangeColor = const MaterialColor(
  0xFFFFBC92,
  const <int, Color>{
    50: const Color(0xFFffffff),
    100: const Color(0xFFffefe6),
    200: const Color(0xFFffe0cc),
    300: const Color(0xFFffd0b3),
    400: const Color(0xFFffc099),
    500: const Color(0xFFFFBC92),
    600: const Color(0xFFffa166),
    700: const Color(0xFFff8133),
    800: const Color(0xFFe65800),
    900: const Color(0xFF993b00),
  },
);

const MaterialColor pastelStrongOrangeColor = const MaterialColor(
  0xFFF8B445,
  const <int, Color>{
    50: const Color(0xFFfdebce),
    100: const Color(0xFFfce1b5),
    200: const Color(0xFFfbd79d),
    300: const Color(0xFFfbcd84),
    400: const Color(0xFFfac36b),
    500: const Color(0xFFF8B445),
    600: const Color(0xFFf7a522),
    700: const Color(0xFFf69b09),
    800: const Color(0xFFdd8c08),
    900: const Color(0xFFac6d06),
  },
);

ThemeData themeLight() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColorLight: pastelOrangeColor.shade100,
    primaryColor: pastelOrangeColor,
    primaryColorDark: Color(0xFF222222),
    toggleableActiveColor: kGreenColor,
    tabBarTheme: tabBarTheme(),
    primaryIconTheme: IconThemeData(color: primaryColorLight),
    // iconTheme: IconThemeData(color: primaryColorLight),
    chipTheme: chipThemeData(),
    appBarTheme: appBarTheme(),

    scaffoldBackgroundColor: pastelOrangeColor.shade100,
    // textTheme: TextTheme(subtitle1: TextStyle(color: Color(0xFF222222))),
    // cardTheme: cardTheme(),
    //Buttons Theme
    elevatedButtonTheme: elevatedButtonTheme(),
    textButtonTheme: textButtonTheme(),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: pastelOrangeColor,
      primaryColorDark: pastelBlueColor,
      accentColor: pastelStrongOrangeColor,
    ).copyWith(
      surface: pastelLightBlueColor,
      secondary: pastelStrongOrangeColor,
      secondaryVariant: pastelOrangeColor,
    ),
  );
}

//Text Styles

TextStyle textFormStyle() {
  return TextStyle(color: Colors.white);
}

TextStyle textStyleForHeadline() {
  return GoogleFonts.lato(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: pastelBlueColor,
  );
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
      primary: pastelBlueColor,
      shape: StadiumBorder(),
    ),
  );
}

ElevatedButtonThemeData elevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: StadiumBorder(),
      onPrimary: pastelBlueColor,
    ),
  );
}

ChipThemeData chipThemeData() {
  return ChipThemeData(
    elevation: 5,
    backgroundColor: Colors.grey,
    disabledColor: Colors.black38,
    checkmarkColor: Colors.white.withOpacity(0.8),
    selectedColor: pastelBlueColor,
    secondarySelectedColor: kOrangeColor.shade300,
    padding: EdgeInsets.all(5.0),
    labelStyle: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white.withOpacity(0.8),
    ),
    secondaryLabelStyle: TextStyle(
      color: primaryColorLight,
    ),
    brightness: Brightness.light,
  );
}

// Widgets Styles
CardTheme cardTheme() {
  return CardTheme(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))),
    color: pastelDeepGreenColor,
    elevation: 0.0,
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    titleTextStyle: GoogleFonts.lato(
      fontSize: 30,
      color: pastelBlueColor,
    ),
    // TextStyle(
    //   color: primaryColorLight,
    //   fontSize: 30,
    //   fontFamily: 'Dancing Script',
    //   fontWeight: FontWeight.w700,
    // ),
    iconTheme: IconThemeData(size: 30, color: pastelBlueColor),
    backgroundColor: pastelOrangeColor.shade400,
    centerTitle: true,
    elevation: 0.0,
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
