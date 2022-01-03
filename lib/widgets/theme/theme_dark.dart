import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const MaterialColor greyColor = const MaterialColor(
  0xFF808080,
  const <int, Color>{
    50: const Color(0xFFbfbfbf),
    100: const Color(0xFFb3b3b3),
    200: const Color(0xFFa6a6a6),
    300: const Color(0xFF999999),
    400: const Color(0xFF8c8c8c),
    500: const Color(0xFF808080),
    600: const Color(0xFF737373),
    700: const Color(0xFF595959),
    800: const Color(0xFF404040),
    900: const Color(0xFF262626),
  },
);

const MaterialColor purpleColor = const MaterialColor(
  0xFFBF5AF2,
  const <int, Color>{
    50: const Color(0xFFf6e7fd),
    100: const Color(0xFFedd0fb),
    200: const Color(0xFFe4b8f9),
    300: const Color(0xFFdaa1f7),
    400: const Color(0xFFd189f5),
    500: const Color(0xFFBF5AF2),
    600: const Color(0xFFad2bee),
    700: const Color(0xFF9311d4),
    800: const Color(0xFF730da5),
    900: const Color(0xFF520a76),
  },
);

const MaterialColor greenColor = const MaterialColor(
  0xFF00B589,
  const <int, Color>{
    50: const Color(0xFFE1F7F1),
    100: const Color(0xFFB5EADB),
    200: const Color(0xFF83DEC4),
    300: const Color(0xFF4ACFAC),
    400: const Color(0xFF01C29A),
    500: const Color(0xFF00B589),
    600: const Color(0xFF008060),
    700: const Color(0xFF00664d),
    800: const Color(0xFF004d39),
    900: const Color(0xFF003326),
  },
);

ThemeData themeDark() {
  return ThemeData(
    brightness: Brightness.dark,
    chipTheme: chipThemeData(),
    appBarTheme: appBarTheme(),
    scaffoldBackgroundColor: const Color(0xFF2A2A2A),
    elevatedButtonTheme: elevatedButtonTheme(),
    textButtonTheme: textButtonTheme(),
    colorScheme: ColorScheme.dark().copyWith(
      secondary: greenColor,
      surface: purpleColor.shade900,
      primary: purpleColor.shade600,
    ),
  );
}

TextStyle textFormStyle() {
  return TextStyle(color: Colors.black);
}

// Custom Button Style

ElevatedButtonThemeData elevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: greenColor,
      shape: StadiumBorder(),
      onPrimary: const Color(0xFFFBF5FE),
    ),
  );
}

TextButtonThemeData textButtonTheme() {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      primary: greenColor,
      shape: StadiumBorder(),
    ),
  );
}

ChipThemeData chipThemeData() {
  return ChipThemeData(
    elevation: 5,
    backgroundColor: Colors.grey.shade700,
    disabledColor: Colors.black38,
    checkmarkColor: Colors.white.withOpacity(0.8),
    selectedColor: purpleColor.shade900,
    secondarySelectedColor: purpleColor.shade900,
    padding: EdgeInsets.all(5.0),
    labelStyle: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white.withOpacity(0.8),
    ),
    secondaryLabelStyle: TextStyle(
      color: Colors.white.withOpacity(0.8),
    ),
    brightness: Brightness.light,
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    titleTextStyle: GoogleFonts.lato(
      fontSize: 30,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(size: 30, color: Colors.white),
    backgroundColor: Color(0xFF1F1F1F),
    centerTitle: true,
    elevation: 0.0,
  );
}
