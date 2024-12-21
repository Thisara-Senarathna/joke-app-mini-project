import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static const _jokesKey = 'cachedJokes';

  Future<void> saveJokes(List<dynamic> jokes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_jokesKey, json.encode(jokes));
  }

  Future<List<dynamic>?> getCachedJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final jokes = prefs.getString(_jokesKey);
    if (jokes != null) {
      return json.decode(jokes);
    }
    return null;
  }
}
