// lib/domain/repositories/user_settings_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' show ThemeMode;
import '../../core/errors/failures.dart';
import '../entities/user_settings.dart';

abstract class UserSettingsRepository {
  Future<Either<Failure, UserSettings>> getSettings();
  Future<Either<Failure, UserSettings>> saveSettings(UserSettings settings);
  Future<Either<Failure, ThemeMode>> getThemeMode();
  Future<Either<Failure, bool>> saveThemeMode(ThemeMode mode);
}