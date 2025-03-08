// lib/presentation/viewmodels/settings_viewmodel.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/user_settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final UserSettingsRepository _settingsRepository;

  UserSettings? _settings;
  ThemeMode _themeMode = ThemeMode.light; // Початкове значення
  bool _isLoading = false;
  String? _error;

  SettingsViewModel(this._settingsRepository) {
    _loadSettings();
    _loadThemeMode();
  }

  UserSettings? get settings => _settings;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _settingsRepository.getSettings();
    result.fold(
          (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
          (settings) {
        _settings = settings;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadThemeMode() async {
    final result = await _settingsRepository.getThemeMode();
    result.fold(
          (failure) {
        _error = failure.message;
        notifyListeners();
      },
          (themeMode) {
        print('Завантажено тему: $themeMode'); // Debugging
        _themeMode = themeMode;
        notifyListeners();
      },
    );
  }

  Future<bool> saveSettings(UserSettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _settingsRepository.saveSettings(settings);
    return result.fold(
          (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
          (savedSettings) {
        _settings = savedSettings;
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> setThemeMode(ThemeMode mode) async {
    print('Встановлюємо тему в ViewModel: $mode'); // Debugging
    final result = await _settingsRepository.saveThemeMode(mode);
    return result.fold(
          (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
          (_) {
        _themeMode = mode;
        notifyListeners();
        return true;
      },
    );
  }
}