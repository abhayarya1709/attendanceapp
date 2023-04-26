import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;

// call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    try {
      // if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      // }
    } catch (e) {
      print(e.toString());
    }
    return _prefs;
  }

//sets
  static Future<bool> setBool(String key, bool? value) async =>
      await _prefs.setBool(key, value ?? false);

  static Future<bool> setDouble(String key, double? value) async =>
      await _prefs.setDouble(key, value ?? 0.0);

  static Future<bool> setInt(String key, int? value) async =>
      await _prefs.setInt(key, value ?? 0);

  static Future<bool> setString(String key, String? value) async =>
      await _prefs.setString(key, value ?? "");

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);

//gets
  static bool getBool(String key) => _prefs.getBool(key) ?? false;

  static double getDouble(String key) => _prefs.getDouble(key) ?? 0.0;

  static int getInt(String key,{int byDefault=0}) => _prefs.getInt(key) ?? byDefault;

  static String getString(String key) => _prefs.getString(key) ?? "";

  static List<String> getStringList(String key) =>
      _prefs.getStringList(key) ?? [];

//deletes..
  static Future<bool> remove(String key) async =>
      await _prefs.remove(key) ?? false;

  static Future<bool> clear() async => await _prefs.clear();
}