import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _completedKey = 'completed_chapters';

  Future<void> saveCompleted(List<String> completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey, completed);
  }

  Future<List<String>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_completedKey) ?? [];
  }
}
