// lib/data/models/user_settings_model.dart
import 'package:flutter/material.dart' show ThemeMode;
import '../../domain/entities/user_settings.dart';

class UserSettingsModel extends UserSettings {
  const UserSettingsModel({
    int? id,
    required ThemeMode themeMode,
    required String language,
    required bool useTextToSpeech,
    required bool bluetoothAutoConnect,
    required double recognitionThreshold,
    required bool hapticFeedback,
    required bool showOnboarding,
    required DateTime updatedAt,
  }) : super(
    id: id,
    themeMode: themeMode,
    language: language,
    useTextToSpeech: useTextToSpeech,
    bluetoothAutoConnect: bluetoothAutoConnect,
    recognitionThreshold: recognitionThreshold,
    hapticFeedback: hapticFeedback,
    showOnboarding: showOnboarding,
    updatedAt: updatedAt,
  );

  /// Створення моделі з карти налаштувань
  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    String themeString = map['theme_mode'] as String? ?? 'light';
    ThemeMode themeMode;

    switch (themeString) {
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'system':
        themeMode = ThemeMode.system;
        break;
      default:
        themeMode = ThemeMode.light;
    }

    return UserSettingsModel(
      id: map['setting_id'] as int?,
      themeMode: themeMode,
      language: map['language'] as String? ?? 'uk',
      useTextToSpeech: _parseBool(map['use_text_to_speech']),
      bluetoothAutoConnect: _parseBool(map['bluetooth_auto_connect']),
      recognitionThreshold: _parseDouble(map['recognition_threshold']) ?? 0.85,
      hapticFeedback: _parseBool(map['haptic_feedback']),
      showOnboarding: _parseBool(map['show_onboarding']),
      updatedAt: DateTime.parse(map['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Перетворення у карту для збереження
  Map<String, dynamic> toMap() {
    String themeString;
    switch (themeMode) {
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
      default:
        themeString = 'light';
    }

    return {
      'theme_mode': themeString,
      'language': language,
      'use_text_to_speech': useTextToSpeech.toString(),
      'bluetooth_auto_connect': bluetoothAutoConnect.toString(),
      'recognition_threshold': recognitionThreshold.toString(),
      'haptic_feedback': hapticFeedback.toString(),
      'show_onboarding': showOnboarding.toString(),
    };
  }

  /// Створення з сутності
  factory UserSettingsModel.fromEntity(UserSettings settings) {
    return UserSettingsModel(
      id: settings.id,
      themeMode: settings.themeMode,
      language: settings.language,
      useTextToSpeech: settings.useTextToSpeech,
      bluetoothAutoConnect: settings.bluetoothAutoConnect,
      recognitionThreshold: settings.recognitionThreshold,
      hapticFeedback: settings.hapticFeedback,
      showOnboarding: settings.showOnboarding,
      updatedAt: settings.updatedAt,
    );
  }

  /// Допоміжний метод для розбору булевого значення
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  /// Допоміжний метод для розбору числа з плаваючою точкою
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}