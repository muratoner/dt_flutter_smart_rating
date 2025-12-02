import 'package:shared_preferences/shared_preferences.dart';

class SmartRatingStorage {
  static const String _keyLastShownDate = 'smart_rating_last_shown_date';
  static const String _keyLastActionDate = 'smart_rating_last_action_date';

  Future<void> setLastShownDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastShownDate, date.toIso8601String());
  }

  Future<DateTime?> getLastShownDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyLastShownDate);
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  Future<void> setLastActionDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastActionDate, date.toIso8601String());
  }

  Future<DateTime?> getLastActionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyLastActionDate);
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }
}
