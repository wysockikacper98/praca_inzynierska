import 'package:flutter/material.dart';

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

ThemeData themeDark() {
  return ThemeData.dark();
}

TextStyle textFormStyle() {
  return TextStyle(color: Colors.black);
}

// Custom Button Style

ButtonStyle elevatedButtonFilterStyle() {
  return ElevatedButton.styleFrom(
    primary: Colors.brown,
  );
}
