// Core service for local persistence (SharedPreferences).
// All features import from here — single source of truth.
import 'package:shared_preferences/shared_preferences.dart';
import '../security/ollama_host.dart';

// IMPORTANT : SharedPreferences est utilisé ici pour des préférences non-sensibles.
// Pour des secrets (mots de passe, clés d'API), utilisez flutter_secure_storage.
class StorageService {
  static const _completedKey = 'completed_chapters';
  static const _ollamaHostKey = 'ollama_host';

  // Network Transparency
  static const _offlineModeKey = 'offline_mode';
  static const _securityUpdatesKey = 'security_updates';
  static const _contentUpdatesKey = 'content_updates';

  // Ghost AI
  static const _ollamaModelKey = 'ollama_model';
  static const _tutorPersonalityKey = 'tutor_personality';

  // Personalization
  static const _terminalFontSizeKey = 'terminal_font_size';
  static const _terminalThemeKey = 'terminal_theme';
  static const _appThemeKey = 'app_theme';

  Future<void> saveCompleted(List<String> completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey, completed);
  }

  Future<List<String>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_completedKey) ?? [];
  }

  Future<String> getOllamaHost() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ollamaHostKey) ?? OllamaHost.defaultBaseUrl;
    try {
      return OllamaHost.normalize(raw);
    } catch (_) {
      // Défense en profondeur : si les prefs ont été modifiées (desktop / appareil compromis),
      // revenir à un host sûr.
      return OllamaHost.defaultBaseUrl;
    }
  }

  Future<void> saveOllamaHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = OllamaHost.normalize(host);
    await prefs.setString(_ollamaHostKey, normalized);
  }

  // --- Generic Getters/Setters ---

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<String> getString(String key, {String defaultValue = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<double> getDouble(String key, {double defaultValue = 14.0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  // --- Specific Settings Getters/Setters ---

  Future<bool> getOfflineMode() => getBool(_offlineModeKey, defaultValue: false);
  Future<void> setOfflineMode(bool value) => setBool(_offlineModeKey, value);

  Future<bool> getSecurityUpdates() => getBool(_securityUpdatesKey, defaultValue: true);
  Future<void> setSecurityUpdates(bool value) => setBool(_securityUpdatesKey, value);

  Future<bool> getContentUpdates() => getBool(_contentUpdatesKey, defaultValue: true);
  Future<void> setContentUpdates(bool value) => setBool(_contentUpdatesKey, value);

  Future<String> getOllamaModel() => getString(_ollamaModelKey, defaultValue: 'qwen2.5:1.5b');
  Future<void> setOllamaModel(String value) => setString(_ollamaModelKey, value);

  Future<String> getTutorPersonality() => getString(_tutorPersonalityKey, defaultValue: 'Socratique');
  Future<void> setTutorPersonality(String value) => setString(_tutorPersonalityKey, value);

  Future<double> getTerminalFontSize() => getDouble(_terminalFontSizeKey, defaultValue: 14.0);
  Future<void> setTerminalFontSize(double value) => setDouble(_terminalFontSizeKey, value);

  Future<String> getTerminalTheme() => getString(_terminalThemeKey, defaultValue: 'Dark');
  Future<void> setTerminalTheme(String value) => setString(_terminalThemeKey, value);

  Future<String> getAppTheme() => getString(_appThemeKey, defaultValue: 'System');
  Future<void> setAppTheme(String value) => setString(_appThemeKey, value);

  // --- Reset & Cleanup ---

  Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming chat history is stored with certain keys, or we might need a separate service.
    // For now, let's clear keys that start with 'chat_history_'
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('chat_history_')) {
        await prefs.remove(key);
      }
    }
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
  }
}
