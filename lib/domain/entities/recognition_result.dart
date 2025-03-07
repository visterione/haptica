import 'package:equatable/equatable.dart';
import 'gesture.dart';

/// Клас, що представляє результат розпізнавання жесту
class RecognitionResult extends Equatable {
  /// Унікальний ідентифікатор результату
  final int? id;

  /// Розпізнаний жест
  final Gesture gesture;

  /// Рівень впевненості в розпізнаванні (0.0-1.0)
  final double confidence;

  /// Необроблені дані з сенсорів у форматі JSON
  final String? rawData;

  /// Час розпізнавання
  final DateTime timestamp;

  /// Конструктор
  const RecognitionResult({
    this.id,
    required this.gesture,
    required this.confidence,
    this.rawData,
    required this.timestamp,
  });

  /// Створення копії з новими значеннями
  RecognitionResult copyWith({
    int? id,
    Gesture? gesture,
    double? confidence,
    String? rawData,
    DateTime? timestamp,
  }) {
    return RecognitionResult(
      id: id ?? this.id,
      gesture: gesture ?? this.gesture,
      confidence: confidence ?? this.confidence,
      rawData: rawData ?? this.rawData,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Перевіряє, чи розпізнавання достатньо надійне
  bool get isReliable => confidence >= 0.85;

  @override
  List<Object?> get props => [id, gesture, confidence, rawData, timestamp];

  @override
  String toString() => 'RecognitionResult { id: $id, gesture: ${gesture.name}, '
      'confidence: $confidence, timestamp: $timestamp }';
}