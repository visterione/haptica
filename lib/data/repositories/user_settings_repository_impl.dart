// lib/data/repositories/user_settings_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../datasources/database_helper.dart';
import '../models/user_settings_model.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  final DatabaseHelper _databaseHelper;

  UserSettingsRepositoryImpl(this._databaseHelper);

  @override
  Future<Either<Failure, UserSettings>> getSettings() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(DatabaseHelper.tableUserSettings);

      Map<String, dynamic> settingsMap = {};
      for (var setting in result) {
        final name = setting['setting_name'] as String;
        final value = setting['setting_value'];
        settingsMap[name] = value;
      }

      final settings = UserSettingsModel.fromMap(settingsMap);
      return Right(settings);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося отримати налаштування: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserSettings>> saveSettings(UserSettings settings) async {
    try {
      final db = await _databaseHelper.database;
      final model = UserSettingsModel.fromEntity(settings);
      final now = DateTime.now().toIso8601String();

      final batch = db.batch();
      final settingsMap = model.toMap();

      for (var entry in settingsMap.entries) {
        batch.update(
          DatabaseHelper.tableUserSettings,
          {
            'setting_value': entry.value.toString(),
            'updated_at': now,
          },
          where: 'setting_name = ?',
          whereArgs: [entry.key],
        );
      }

      await batch.commit();
      return Right(settings);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося зберегти налаштування: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ThemeMode>> getThemeMode() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableUserSettings,
        where: 'setting_name = ?',
        whereArgs: ['theme_mode'],
      );

      if (result.isEmpty) {
        return const Right(ThemeMode.light);
      }

      final themeString = result.first['setting_value'] as String;
      ThemeMode themeMode = ThemeMode.light;

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

      return Right(themeMode);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося отримати тему: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveThemeMode(ThemeMode mode) async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now().toIso8601String();

      String themeString;
      switch (mode) {
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
        default:
          themeString = 'light';
      }

      await db.update(
        DatabaseHelper.tableUserSettings,
        {
          'setting_value': themeString,
          'updated_at': now,
        },
        where: 'setting_name = ?',
        whereArgs: ['theme_mode'],
      );

      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Не вдалося зберегти тему: ${e.toString()}'));
    }
  }
}