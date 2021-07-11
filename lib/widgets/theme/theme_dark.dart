import 'package:flutter/material.dart';

ThemeData themeDark() {
  return ThemeData.dark();
}


TextStyle textFormStyle(){
  return TextStyle(color: Colors.black);
}


// Custom Button Style

ButtonStyle elevatedButtonFilterStyle() {
  return ElevatedButton.styleFrom(
    primary: Colors.brown,
  );
}