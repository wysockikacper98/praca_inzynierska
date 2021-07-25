

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:praca_inzynierska/widgets/theme/theme_dark.dart';
import 'package:praca_inzynierska/widgets/theme/theme_light.dart';

class ThemeProvider with ChangeNotifier{

  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode{
    if(themeMode == ThemeMode.system){
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    }else{
      return
    }
  }



}