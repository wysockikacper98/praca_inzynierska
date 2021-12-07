import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      prefs.setString(key, value);
    } else {
      print("Invalid Type");
    }
  }

  static Future<String?> readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

}
