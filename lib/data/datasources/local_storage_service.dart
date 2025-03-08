// lib/data/datasources/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LocalStorageService {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _textToSpeechKey = 'text_to_speech';
  static const String _bluetoothAutoConnectKey = 'bluetooth_auto_connect';
  static const String _recognitionThresholdKey = 'recognition_threshold';
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _showOnboardingKey = 'show_onboarding';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // Методи для читання/запису ThemeMode
  Future<bool> saveThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
      default:
        value = 'light';
    }
    print('Збереження теми: $value'); // Debugging
    return await _prefs.setString(_themeKey, value);
  }

  ThemeMode getThemeMode() {
    final themeString = _prefs.getString(_themeKey);
    print('Отримано тему з локального сховища: $themeString'); // Debugging

    if (themeString == null) {
      print('Тема не знайдена, встановлюємо за замовчуванням light');
      return ThemeMode.light;
    }

    switch (themeString) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  // Методи для інших налаштувань
  Future<bool> saveLanguage(String language) async {
    return await _prefs.setString(_languageKey, language);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'uk';
  }

  Future<bool> saveTextToSpeech(bool enabled) async {
    return await _prefs.setBool(_textToSpeechKey, enabled);
  }

  bool getTextToSpeech() {
    return _prefs.getBool(_textToSpeechKey) ?? false;
  }

  Future<bool> saveBluetoothAutoConnect(bool enabled) async {
    return await _prefs.setBool(_bluetoothAutoConnectKey, enabled);
  }

  bool getBluetoothAutoConnect() {
    return _prefs.getBool(_bluetoothAutoConnectKey) ?? true;
  }

  Future<bool> saveRecognitionThreshold(double threshold) async {
    return await _prefs.setDouble(_recognitionThresholdKey, threshold);
  }

  double getRecognitionThreshold() {
    return _prefs.getDouble(_recognitionThresholdKey) ?? 0.85;
  }

  Future<bool> saveHapticFeedback(bool enabled) async {
    return await _prefs.setBool(_hapticFeedbackKey, enabled);
  }

  bool getHapticFeedback() {
    return _prefs.getBool(_hapticFeedbackKey) ?? true;
  }

  Future<bool> saveShowOnboarding(bool show) async {
    return await _prefs.setBool(_showOnboardingKey, show);
  }

  bool getShowOnboarding() {
    return _prefs.getBool(_showOnboardingKey) ?? true;
  }

  // Метод для збереження всіх налаштувань одночасно
  Future<bool> saveAllSettings({
    required ThemeMode themeMode,
    required String language,
    required bool textToSpeech,
    required bool bluetoothAutoConnect,
    required double recognitionThreshold,
    required bool hapticFeedback,
    required bool showOnboarding,
  }) async {
    try {
      await saveThemeMode(themeMode);
      await saveLanguage(language);
      await saveTextToSpeech(textToSpeech);
      await saveBluetoothAutoConnect(bluetoothAutoConnect);
      await saveRecognitionThreshold(recognitionThreshold);
      await saveHapticFeedback(hapticFeedback);
      await saveShowOnboarding(showOnboarding);
      return true;
    } catch (e) {
      print('Помилка збереження налаштувань: $e');
      return false;
    }
  }
}