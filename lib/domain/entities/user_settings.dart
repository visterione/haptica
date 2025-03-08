// lib/domain/entities/user_settings.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;

class UserSettings extends Equatable {
  final int? id;
  final ThemeMode themeMode;
  final String language;
  final bool useTextToSpeech;
  final bool bluetoothAutoConnect;
  final double recognitionThreshold;
  final bool hapticFeedback;
  final bool showOnboarding;
  final DateTime updatedAt;

  const UserSettings({
    this.id,
    required this.themeMode,
    required this.language,
    required this.useTextToSpeech,
    required this.bluetoothAutoConnect,
    required this.recognitionThreshold,
    required this.hapticFeedback,
    required this.showOnboarding,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    themeMode,
    language,
    useTextToSpeech,
    bluetoothAutoConnect,
    recognitionThreshold,
    hapticFeedback,
    showOnboarding,
    updatedAt
  ];

  UserSettings copyWith({
    int? id,
    ThemeMode? themeMode,
    String? language,
    bool? useTextToSpeech,
    bool? bluetoothAutoConnect,
    double? recognitionThreshold,
    bool? hapticFeedback,
    bool? showOnboarding,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      useTextToSpeech: useTextToSpeech ?? this.useTextToSpeech,
      bluetoothAutoConnect: bluetoothAutoConnect ?? this.bluetoothAutoConnect,
      recognitionThreshold: recognitionThreshold ?? this.recognitionThreshold,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      showOnboarding: showOnboarding ?? this.showOnboarding,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}