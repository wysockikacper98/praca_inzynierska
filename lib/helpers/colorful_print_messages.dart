enum PrintColor {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
}

void printColor({
  required String text,
  required PrintColor color,
}) {
  String defaultColor = '\x1B[30m';
  const String reset = '\x1B[0m';
  switch (color) {
    case PrintColor.black:
      defaultColor = '\x1B[30m';
      break;
    case PrintColor.red:
      defaultColor = '\x1B[31m';
      break;
    case PrintColor.green:
      defaultColor = '\x1B[32m';
      break;
    case PrintColor.yellow:
      defaultColor = '\x1B[33m';
      break;
    case PrintColor.blue:
      defaultColor = '\x1B[34m';
      break;
    case PrintColor.magenta:
      defaultColor = '\x1B[35m';
      break;
    case PrintColor.cyan:
      defaultColor = '\x1B[36m';
      break;
    case PrintColor.white:
      defaultColor = '\x1B[37m';
      break;
  }
  print('$defaultColor$text$reset');
}
