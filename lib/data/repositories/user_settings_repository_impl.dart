// lib/data/repositories/user_settings_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../datasources/database_helper.dart';
import '../datasources/local_storage_service.dart';
import '../models/user_settings_model.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  final DatabaseHelper _databaseHelper;
  final LocalStorageService _localStorage;

  UserSettingsRepositoryImpl(this._databaseHelper, this._localStorage);

  @override
  Future<Either<Failure, UserSettings>> getSettings() async {
    try {
      // Отримуємо налаштування з локального сховища
      final themeMode = _localStorage.getThemeMode();
      final language = _localStorage.getLanguage();
      final textToSpeech = _localStorage.getTextToSpeech();
      final bluetoothAutoConnect = _localStorage.getBluetoothAutoConnect();
      final recognitionThreshold = _localStorage.getRecognitionThreshold();
      final hapticFeedback = _localStorage.getHapticFeedback();
      final showOnboarding = _localStorage.getShowOnboarding();

      final settings = UserSettings(
        themeMode: themeMode,
        language: language,
        useTextToSpeech: textToSpeech,
        bluetoothAutoConnect: bluetoothAutoConnect,
        recognitionThreshold: recognitionThreshold,
        hapticFeedback: hapticFeedback,
        showOnboarding: showOnboarding,
        updatedAt: DateTime.now(),
      );

      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(message: 'Не вдалося отримати налаштування: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserSettings>> saveSettings(UserSettings settings) async {
    try {
      // Зберігаємо налаштування в локальне сховище
      await _localStorage.saveAllSettings(
        themeMode: settings.themeMode,
        language: settings.language,
        textToSpeech: settings.useTextToSpeech,
        bluetoothAutoConnect: settings.bluetoothAutoConnect,
        recognitionThreshold: settings.recognitionThreshold,
        hapticFeedback: settings.hapticFeedback,
        showOnboarding: settings.showOnboarding,
      );

      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(message: 'Не вдалося зберегти налаштування: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ThemeMode>> getThemeMode() async {
    try {
      final themeMode = _localStorage.getThemeMode();
      return Right(themeMode);
    } catch (e) {
      return Left(CacheFailure(message: 'Не вдалося отримати тему: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveThemeMode(ThemeMode mode) async {
    try {
      final result = await _localStorage.saveThemeMode(mode);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: 'Не вдалося зберегти тему: ${e.toString()}'));
    }
  }
}